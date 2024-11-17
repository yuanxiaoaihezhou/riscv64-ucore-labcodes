# lab3 缺页异常和页面置换

## 练习1：理解基于FIFO的页面替换算法（思考题）
描述FIFO页面置换算法下，一个页面从被换入到被换出的过程中，会经过代码里哪些函数/宏的处理（或者说，需要调用哪些函数/宏），并用简单的一两句话描述每个函数在过程中做了什么？（为了方便同学们完成练习，所以实际上我们的项目代码和实验指导的还是略有不同，例如我们将FIFO页面置换算法头文件的大部分代码放在了`kern/mm/swap_fifo.c`文件中，这点请同学们注意）
 - 至少正确指出10个不同的函数分别做了什么？如果少于10个将酌情给分。我们认为只要函数原型不同，就算两个不同的函数。要求指出对执行过程有实际影响,删去后会导致输出结果不同的函数（例如assert）而不是cprintf这样的函数。如果你选择的函数不能完整地体现”从换入到换出“的过程，比如10个函数都是页面换入的时候调用的，或者解释功能的时候只解释了这10个函数在页面换入时的功能，那么也会扣除一定的分数

## Answer：
```c++
static int pgfault_handler(struct trapframe *tf) {
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
    }
    panic("unhandled page fault.\n");
}
```
我们可以看到，当程序触发页异常的时候，会分发到该函数，而从该函数的代码我们知道真正的处理函数为`do_pgfault()`。
> `do_pgfault()`函数原型如下：
> ```c++
> int do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr)
> ```
> 在该函数中进行页面的换入换出等操作

在`do_pgfault()`函数里我们首先会调用`find_vma()`函数。
> `find_vma()`函数原型如下：
> ```c++
> struct vma_struct * find_vma(struct mm_struct *mm, uintptr_t addr)
> ```
> 该函数会在`vma`结构体链表中找到一个满足`vma->vm_start<=addr && addr < vma->vm_end`条件的`vma`结构体。
> 这里用于检测地址是否合法。

随后我们调用`get_pte()`函数。
```c++
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
    pde_t *pdep1 = &pgdir[PDX1(la)]; // 获取一级页表目录
    if (!(*pdep1 & PTE_V)) {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
    }
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];  // 找到二级页表目录项
    if (!(*pdep0 & PTE_V)) {
    	struct Page *page;
    	if (!create || (page = alloc_page()) == NULL) {
    		return NULL;
    	}
    	set_page_ref(page, 1);
    	uintptr_t pa = page2pa(page);
    	memset(KADDR(pa), 0, PGSIZE);
    	*pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)]; // 返回一级页表页表项
}
```
> `get_pte`函数会根据得到的虚拟地址，在三级页表中进行查找。在查找页表项的时候，如果页表项无效的话会给页表项分配一个全是0的页并建立映射。最后返回虚拟地址对应的一级页表的页表项。
获取`pte`后，我们会检测该页表项是否为空，如果为空（即页面不存在），我们调用`pgdir_alloc_page`函数分配一个新的物理页面，并映射到错误地址。
> ```c++
> struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm)
> ```
在`pgdir_alloc_page`中，我们首先调用`alloc_page()`函数，而该函数实际上是`#define alloc_page() alloc_pages(1)`，所以我们直接转到`alloc_pages()`。
```c++
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;

    while (1) {
        local_intr_save(intr_flag);
        { page = pmm_manager->alloc_pages(n); }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;

        extern struct mm_struct *check_mm_struct;
        swap_out(check_mm_struct, n, 0);
    }
    return page;
}
```
在`alloc_pages()`中，我们首先根据物理页面分配算法分配一个物理页面，然后调用`swap_out()`。    
```c++
int swap_out(struct mm_struct *mm, int n, int in_tick)
{
     int i;
     for (i = 0; i != n; ++ i)
     {
          uintptr_t v;
          struct Page *page;
          int r = sm->swap_out_victim(mm, &page, in_tick);
          if (r != 0) {
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
                  break;
          }          
          
          v=page->pra_vaddr; 
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
          assert((*ptep & PTE_V) != 0);

          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
                    cprintf("SWAP: failed to save\n");
                    sm->map_swappable(mm, v, page, 0);
                    continue;
          }
          else {
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
                    free_page(page);
          }
          
          tlb_invalidate(mm->pgdir, v);
     }
     return i;
}
```
`swap_out()`则会根据页面置换算法选择出一个应该换出的页面并写入到磁盘中，同时将此页面释放。我们可以从函数实现看到找出需要换出的页面是由指定`swap_manager`的`swap_out_victim()`实现的，在这里我们探究FIFO算法，所以找到FIFO的`swap_out_victim()`
```c++
static int
_fifo_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
         assert(head != NULL);
     assert(in_tick==0);
    list_entry_t* entry = list_prev(head);
    if (entry != head) {
        list_del(entry);
        *ptr_page = le2page(entry, pra_page_link);
    } else {
        *ptr_page = NULL;
    }
    return 0;
}
```
根据FIFO算法思想，在页面置换时，我们需要换出的是最先使用的页面（先入先出嘛），即最先加入到链表的节点对应的页面。在链表中，最先加入页面对应的节点就是头节点`head`的上一个节点，调用`list_prev()`即可。找到该节点后我们将其删除并获取被删除节点的页面对象，这里使用了宏`le2page`将链表节点转换为页面对象，并将其复制给`ptr_page`指向的指针。   
```c++
#define le2page(le, member)                 \
    to_struct((le), struct Page, member)
``` 
随后我们需要将页面内容写入磁盘，该过程由以下两个函数实现：
```c++
int // 此函数封装了磁盘的读操作。
swapfs_read(swap_entry_t entry, struct Page *page) {
 return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
}
```
```c++
int // 此函数封装了磁盘的写操作。
swapfs_write(swap_entry_t entry, struct Page *page) {
 return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
}
```
在`pgdir_alloc_page()`调用`alloc_page()`获得分配的页面后会调用 `page_insert()`
```c++
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
    pte_t *ptep = get_pte(pgdir, la, 1);
    if (ptep == NULL) {
        return -E_NO_MEM;
    }
    page_ref_inc(page);
    if (*ptep & PTE_V) {
        struct Page *p = pte2page(*ptep);
        if (p == page) {
            page_ref_dec(page);
        } else {
            page_remove_pte(pgdir, la, ptep);
        }
    }
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
    tlb_invalidate(pgdir, la);
    return 0;
}
```
`page_insert()`用于将虚拟地址和页面之间建立映射关系。   
```c++
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
    pte_t *ptep = get_pte(pgdir, la, 1);
    if (ptep == NULL) {
        return -E_NO_MEM;
    }
    page_ref_inc(page);
    if (*ptep & PTE_V) {
        struct Page *p = pte2page(*ptep);
        if (p == page) {
            page_ref_dec(page);
        } else {
            page_remove_pte(pgdir, la, ptep);
        }
    }
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
    tlb_invalidate(pgdir, la);
    return 0;
}
```
首先，使用`get_pte()`获取页表项，然后判断页表项对应的页面和将要建立映射的页面是否相同。如果不同的话调用`page_remove_pte()`将页表项失效并调用`pte_create()`建立新的页表项并将其赋值给`get_pte()`找到的页表项的地址。
> `page_remove_pte()`执行时会找到`pte`对应的页面，减少其引用，并将页面释放。
> `pte_create()`直接根据物理页号进行偏移并对标志位进行设置。

接下来`pgdir_alloc_page()`调用`swap_map_swappable()`。
> `swap_map_swappable()`用于将页面加入相应的链表，设置页面可交换。

如果`do_pgfault()`获取的`pte`不为空的话，则首先会调用`swap_in()`。

> `swap_in()`的作用是分配一个页面并从磁盘中将相应的值写入到此页面上。

然后会调用`page_insert`函数进行页面的映射以及调用 `swap_map_swappable()`将页面加入相应的链表，设置页面可交换。

## 练习2：深入理解不同分页模式的工作原理（思考题）
get_pte()函数（位于`kern/mm/pmm.c`）用于在页表中查找或创建页表项，从而实现对指定线性地址对应的物理页的访问和映射操作。这在操作系统中的分页机制下，是实现虚拟内存与物理内存之间映射关系非常重要的内容。
 - get_pte()函数中有两段形式类似的代码， 结合sv32，sv39，sv48的异同，解释这两段代码为什么如此相像。
 - 目前get_pte()函数将页表项的查找和页表项的分配合并在一个函数里，你认为这种写法好吗？有没有必要把两个功能拆开？

## Answer：
首先我们明确`sv32`，`sv39`，`sv48`的异同：
>`sv32` (32-bit VAs for RV32)
用于32位的RISC-V架构。
虚拟地址是32位。（其中高十位是其在二级页表的页内偏移，中十位是其在一级页表的页内偏移，低十二位是其在所分配的物理页上的页内偏移）
使用两级页表。

>`sv39` (39-bit VAs for RV64)
用于64位的RISC-V架构。
虚拟地址是39位。（9+9+9+12）
使用三级页表。

>`sv48` (48-bit VAs for RV64)
同样是为64位的RISC-V架构设计的。
虚拟地址是48位。（9+9+9+12）
使用四级页表。

`get_pte()`的逻辑类似于递归查找，根据`PDX1`和三级页表`PDE`找到二级页表`PDE`，再结合`PDX0`找到一级页表`PDE`，根据`PTX`找到`PTE`。

这里会有两个结果：
- 页表项有效：已经存在合适页表，返回该页表项地址。
- 页表项无效：
 - 如果当前处理的是最底层的页表级别，表示已经到达页表的叶子，需要创建一个新的页表项，并将其添加到当前页表中。
 - 如果当前处理的不是最底层的页表级别，表示需要继续往下一级的页表查找或创建。函数会继续向下寻找，在下一级的页表上执行相同的操作。

这两段代码相似的原因是，不论是处理`sv32`、`sv39`还是`sv48`的页表，它们的基本结构和操作逻辑是相似的。不同的只是地址空间大小和页表的层次结构。因此，为了处理不同的地址空间大小，可以重用类似的代码结构，仅仅根据具体的需求调整页表项的大小和页表的层次结构。

这么写法好。目前没有必要拆分两个功能，目前我们只使用了一个标记位（创建位）就进行了分配。而且建立映射分配的前提是找不到，所以在分配前我们必须查找，查找必然是分配的必要条件，完全没有必要用两个函数，如果我们只需要查找的话可以通过标志位进行设置。

## 练习3：给未被映射的地址映射上物理页（需要编程）

补充完成do_pgfault（mm/vmm.c）函数，给未被映射的地址映射上物理页。设置访问权限 的时候需要参考页面所在 VMA 的权限，同时需要注意映射物理页时需要操作内存控制 结构所指定的页表，而不是内核的页表。

请在实验报告中简要说明你的设计实现过程。请回答如下问题：

- 请描述页目录项（Page Directory Entry）和页表项（Page Table Entry）中组成部分对ucore实现页替换算法的潜在用处。
- 如果ucore的缺页服务例程在执行过程中访问内存，出现了页访问异常，请问硬件要做哪些事情？
  - 数据结构Page的全局变量（其实是一个数组）的每一项与页表中的页目录项和页表项有无对应关系？如果有，其对应关系是啥？

## Answer：

补充完整的`do_pgfault（mm/vmm.c）函数`如下：

```c
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);

    pgfault_num++;
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
        goto failed;
    }

    /* IF (write an existed addr ) OR
     *    (write an non_existed addr && addr is writable) OR
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
        perm |= (PTE_R | PTE_W);
    } else if (vma->vm_flags & VM_READ) {
        perm |= PTE_R;
    } else if (vma->vm_flags & VM_EXEC) {
        perm |= PTE_X;
    }
    addr = ROUNDDOWN(addr, PGSIZE);

    ret = -E_NO_MEM;

    pte_t *ptep=NULL;
    /*
    * Maybe you want help comment, BELOW comments can help you finish the code
    *
    * Some Useful MACROs and DEFINEs, you can use them in below implementation.
    * MACROs or Functions:
    *   get_pte : get an pte and return the kernel virtual address of this pte for la
    *             if the PT contians this pte didn't exist, alloc a page for PT (notice the 3th parameter '1')
    *   pgdir_alloc_page : call alloc_page & page_insert functions to allocate a page size memory & setup
    *             an addr map pa<--->la with linear address la and the PDT pgdir
    * DEFINES:
    *   VM_WRITE  : If vma->vm_flags & VM_WRITE == 1/0, then the vma is writable/non writable
    *   PTE_W           0x002                   // page table/directory entry flags bit : Writeable
    *   PTE_U           0x004                   // page table/directory entry flags bit : User can access
    * VARIABLES:
    *   mm->pgdir : the PDT of these vma
    *
    */


    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
                                         //PT(Page Table) isn't existed, then
                                         //create a PT.
    if (ptep == NULL) {
        cprintf("get_pte failed in do_pgfault\n");
        goto failed;
    }

    if (*ptep == 0) {
        // 页表项为空，分配新的物理页并建立映射
        struct Page *page = pgdir_alloc_page(mm->pgdir, addr, perm);
        if (page  == NULL) {
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
            goto failed;
        }
        // 将页面标记为可交换，并加入到交换管理器
        /*if (swap_init_ok) {
            swap_map_swappable(mm, addr, page, 1);
            page->pra_vaddr = addr;
        }*/
    } else {
        /*LAB3 EXERCISE 3: YOUR CODE 2213524
        * 请你根据以下信息提示，补充函数
        * 现在我们认为pte是一个交换条目，那我们应该从磁盘加载数据并放到带有phy addr的页面，
        * 并将phy addr与逻辑addr映射，触发交换管理器记录该页面的访问情况
        *
        *  一些有用的宏和定义，可能会对你接下来代码的编写产生帮助(显然是有帮助的)
        *  宏或函数:
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
            struct Page *page = NULL;
            // 你要编写的内容在这里，请基于上文说明以及下文的英文注释完成代码编写
            //(1）According to the mm AND addr, try
            //to load the content of right disk page
            //into the memory which page managed.
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.

            // (1) Load the content from disk into a new page
            if (swap_in(mm, addr, &page) != 0) {
                cprintf("swap_in in do_pgfault failed\n");
                goto failed;
            }
            // (2) Insert the page into the page table with correct permissions
            if (page_insert(mm->pgdir, page, addr, perm) != 0) {
                cprintf("page_insert in do_pgfault failed\n");
                free_page(page);
                goto failed;
            }
            // (3) Mark the page as swappable
            swap_map_swappable(mm, addr, page, 1);

            page->pra_vaddr = addr;
        } else {
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
failed:
    return ret;
}
```

### `do_pgfault` 函数的设计与实现过程

#### **设计目标**
- 处理缺页异常，将引发异常的地址正确映射到物理内存。
- 遵循分段和分页的内存管理机制，确保根据虚拟内存区域（VMA）的权限正确设置页表权限。
- 支持交换（Swap）机制，以处理内存不足的场景。

#### **实现过程**
1. **获取VMA和权限检查**
   - 首先，通过调用 `find_vma` 函数检查触发缺页异常的地址是否属于某个虚拟内存区域（VMA）。
   - 如果地址不在任何VMA范围内，说明访问的是无效地址，直接返回错误。
   - 如果地址在某个VMA中，根据VMA的权限标志（如 `VM_READ`, `VM_WRITE`, `VM_EXEC`）设置页表权限位（如 `PTE_R`, `PTE_W`, `PTE_X`, `PTE_U`）。

2. **页表项检查**
   - 使用 `get_pte` 函数查找缺页地址的页表项（PTE），若页表项不存在，则分配页表。
   - 检查页表项是否为空：
     - 如果为空，说明该页尚未分配，调用 `pgdir_alloc_page` 为虚拟地址分配一个新的物理页，并插入页表。
     - 如果页表项非空，则说明该页在磁盘上的交换空间，需要从磁盘加载页面数据。

3. **分配和映射新页**
   - 如果页表项为空：
     - 调用 `pgdir_alloc_page` 分配一个物理页并映射到虚拟地址。
     - 如果交换机制已初始化（`swap_init_ok` 为真），将该页标记为可交换，并记录其逻辑地址。
   - 如果页表项非空：
     - 调用 `swap_in` 从磁盘加载页面数据到内存。
     - 使用 `page_insert` 将加载的页面插入到页表。
     - 如果交换机制已初始化，标记该页为可交换。

4. **记录页面访问情况**
   - 更新交换管理器中的页面访问记录，例如访问计数或最近访问标志。
   - 更新全局缺页计数器 `pgfault_num`，便于调试和统计。

5. **返回状态**
   - 如果所有步骤执行成功，返回 `0` 表示缺页处理完成。
   - 如果任何步骤失败，返回相应的错误码。

---

#### **关键设计点**
- **权限设置：**
  根据 VMA 的权限标志动态设置页表项权限，确保只允许合法的内存访问。
- **与交换机制结合：**
  在页表项非空但页面不在内存时，调用 `swap_in` 从磁盘加载页面，实现内存与磁盘的透明交互。
- **代码鲁棒性：**
  通过检查每一步的返回值，确保在内存分配、页表更新或交换操作失败时适当清理并返回错误。

---

#### **实现流程图**

1. **查找VMA并检查地址合法性：**
   - 是合法地址：
     - 继续；
   - 非法地址：
     - 返回错误。

2. **检查页表项：**
   - 页表项为空：
     - 分配新物理页并映射。
   - 页表项非空：
     - 从磁盘加载数据到物理内存，并更新页表。

3. **更新页面状态：**
   - 标记为可交换；
   - 更新访问记录。

4. **返回状态：**
   - 成功：返回 `0`；
   - 失败：返回错误码。


### 回答问题

1. **请描述页目录项（Page Directory Entry）和页表项（Page Table Entry）中组成部分对ucore实现页替换算法的潜在用处。**

   页目录项（PDE）和页表项（PTE）是用于实现分页机制的关键数据结构，它们包含的字段对页替换算法的实现有以下潜在用处：
   
   - **PTE的P标志位（Present bit）：** 用于指示该页是否驻留在内存中。如果P位为0，表明该页不在内存中且可能在磁盘上，可以通过该位触发缺页异常，进入页替换逻辑。
   - **PTE的访问位（Accessed bit）：** 在某些算法（如Clock算法）中，用于判断该页最近是否被访问。访问位是由硬件设置的，提供了页替换的重要参考依据。
   - **PTE的脏位（Dirty bit）：** 标记页面是否被写入。如果需要替换该页且脏位为1，则需要将该页写回磁盘，避免数据丢失。
   - **PTE的用户/内核标志（User/Supervisor bit）：** 用于区分页面是否允许用户态访问，在设计页替换策略时，可以限制某些敏感页面不参与替换。
   - **页表项中的物理地址：** 用于找到物理页帧。当需要将某个物理页替换到磁盘时，可以通过PTE找到对应的物理地址。

   总之，页表项的状态标志（P位、访问位、脏位）和物理地址信息为页替换算法提供了页面访问和驻留状态的依据。


2. **如果ucore的缺页服务例程在执行过程中访问内存，出现了页访问异常，请问硬件要做哪些事情？**

   如果缺页服务例程在访问内存时触发了新的页访问异常，硬件将执行以下操作：
   
   - **记录异常信息：**
     - 将发生异常的线性地址存储到 `satp` 中的异常寄存器（如 `stval`）。
     - 在异常号寄存器（如 `scause`）中记录异常类型（如非法访问、页面不存在）。
   - **跳转到异常处理程序：**
     - 硬件将控制权移交给内核中定义的异常向量表的对应入口，进入通用异常处理逻辑。
   - **触发内核处理：**
     - 内核从 `scause` 和 `stval` 获取异常原因和地址。
     - 再次执行页表检查或调整逻辑，可能递归调用 `do_pgfault` 处理多层异常。

   如果异常是由于缺页服务代码逻辑不正确（如误访问未映射区域），则内核可能会触发 panic 终止操作。



3. **数据结构Page的全局变量（其实是一个数组）的每一项与页表中的页目录项和页表项有无对应关系？如果有，其对应关系是啥？**

   数据结构 `Page` 是全局维护的物理页框信息数组，其每一项与页表中的页目录项和页表项有如下对应关系：

   - **映射关系：**
     - 每一个 `Page` 对象对应一个物理页帧。
     - 页表项（PTE）中的物理地址字段指向对应的物理页帧，而该物理页帧的信息可以通过 `Page` 数据结构获取。
   - **管理关系：**
     - 页表项负责记录线性地址到物理地址的映射，而 `Page` 结构保存了该物理地址对应的页帧状态（如引用计数 `ref`，是否可交换，链表指针 `page_link` 和 `pra_page_link` 等）。
   - **具体关联：**
     - 页表项的物理地址字段指向某个物理页的起始地址，而该物理页的元信息存储在全局 `Page` 数组中，通过计算物理页地址和页大小（`PGSIZE`）的偏移，可以从全局数组中找到对应的 `Page` 对象。

   这种设计实现了虚拟地址到物理页帧的映射，同时通过 `Page` 数组维护页帧状态，用于页替换和内存管理。


### 总结

- 页目录项和页表项中访问位、脏位、P位等字段直接支持页替换算法的设计和实现。
- 硬件在缺页异常时会记录异常信息，并跳转到异常处理逻辑处理异常。
- `Page` 数据结构是全局维护的物理页框信息，提供了物理页帧的状态管理，与页表项通过物理地址建立关联，支持虚拟内存到物理内存的高效映射和管理。


## 练习4：补充完成Clock页替换算法（需要编程）

通过之前的练习，相信大家对FIFO的页面替换算法有了更深入的了解，现在请在我们给出的框架上，填写代码，实现 Clock页替换算法（mm/swap_clock.c）。(提示:要输出curr_ptr的值才能通过make grade)

请在实验报告中简要说明你的设计实现过程。请回答如下问题：

- 比较Clock页替换算法和FIFO算法的不同。

## Answer

### **Clock页替换算法设计实现过程**

1. **算法目标**  
   Clock页替换算法改进了FIFO算法，引入了访问位（`visited`），通过模拟时钟指针循环遍历页面，优先替换未被访问的页面，避免替换近期活跃的页面。

2. **数据结构设计**
   - **循环双向链表**：
     - 用`pra_list_head`管理所有可替换页面，模拟时钟。
     - `curr_ptr`作为时钟指针，用于遍历页面链表。
   - **页面访问位**：
     - 每个页面包含一个`visited`标志位，表示该页面是否被最近访问。
     - 访问过的页面`visited=1`，否则为`0`。

3. **算法逻辑**
   - **初始化**：
     - 将`pra_list_head`初始化为空链表。
     - `curr_ptr`指向链表头。
     - 通过`mm->sm_priv`与页替换算法关联。

   - **页面插入**：
     - 使用`list_add_before`将页面插入到链表末尾。
     - 标记新插入的页面`visited=1`，表示该页面已被访问。

   - **页面替换**：
     - 遍历链表，模拟时钟指针：
       1. 如果`curr_ptr`指向的页面`visited=0`，选择该页面为替换目标：
          - 删除该页面节点。
          - 返回该页面指针作为被替换的页面。
       2. 如果`visited=1`，将其置为`0`，继续移动`curr_ptr`。
       3. 如果到达链表头，重新开始遍历。

   - **输出调试信息**：
     - 在替换页面时，输出`curr_ptr`指针的值，便于调试和通过测试。

4. **关键代码**
   - **clock_mm初始化**
     ```c
     static int
     _clock_init_mm(struct mm_struct *mm)
     {     
     /*LAB3 EXERCISE 4: YOUR CODE 2213524*/ 
     // 初始化 pra_list_head 为一个空链表
     list_init(&pra_list_head);
     // 将 curr_ptr 指向 pra_list_head，表示当前指针从链表头开始
     curr_ptr = &pra_list_head;
     // 将 mm 的私有数据指针 sm_priv 指向 pra_list_head，便于后续访问
     mm->sm_priv = &pra_list_head;

     return 0;
     }
     ```

     当有一个新的进程时，初始化一个新的`pra_list_head`，并将`curr_ptr`和`mm->sm_priv`都指向这个新的`pra_list_head`，便于后续访问。

   - **页面插入逻辑**：
     ```c
     static int
     _clock_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
     {
         list_entry_t *entry=&(page->pra_page_link);
 
         assert(entry != NULL && curr_ptr != NULL);
         //record the page access situlation
         /*LAB3 EXERCISE 4: YOUR CODE 2213524*/ 
         // link the most recent arrival page at the back of the pra_list_head qeueue.
         // 将页面page插入到页面链表pra_list_head的末尾
         // 将页面的visited标志置为1，表示该页面已被访问
    
         // 将页面插入到页面链表的表头之前，即链表的末尾
         list_entry_t *head=(list_entry_t*) mm->sm_priv;
         list_add_before(head, entry);

         // 设置页面的访问标志
         page->visited = 1;

         return 0;
     }
     ```
     页面被插入链表末尾，同时设置`visited=1`。

   - **页面替换逻辑**：
     ```c
     static int
     _clock_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
     {
         list_entry_t *head=(list_entry_t*) mm->sm_priv;
             assert(head != NULL);
         assert(in_tick==0);

         //  pte_t *ptep;
         //  struct Page *page;
         //  list_entry_t *next;
         /* Select the victim */
         //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
         //(2)  set the addr of addr of this page to ptr_page
         while (1) {
            /*LAB3 EXERCISE 4: YOUR CODE 2213524*/ 
            // 编写代码
            // 遍历页面链表pra_list_head，查找最早未被访问的页面
            // 获取当前页面对应的Page结构指针
            // 如果当前页面未被访问，则将该页面从页面链表中删除，并将该页面指针赋值给ptr_page作为换出页面
            // 如果当前页面已被访问，则将visited标志置为0，表示该页面已被重新访问
            
            // 当前指针指向的页面
            
            if (curr_ptr == head) {
                // 如果回到链表头，重置指针
                curr_ptr = list_next(curr_ptr);
            }

            struct Page *page = le2page(curr_ptr, pra_page_link);
            if (page->visited == 0) {
                // 如果页面未被访问，则选择该页面为替换页面
                *ptr_page = page;
                list_entry_t *tmp=curr_ptr;
                // cprintf("curr_ptr %p\n", curr_ptr);
                cprintf("curr_ptr %p\n", curr_ptr);

                curr_ptr = list_next(curr_ptr); // 更新 curr_ptr
                // 将该页面从链表中移除
                list_del(tmp);
                return 0;
            } else {
                // 如果页面已被访问，重置其访问标志
                page->visited = 0;
                curr_ptr = list_next(curr_ptr);
            }
         }

         return 0;
     }
     ```
     模拟时钟指针，检查访问位，选择合适的页面进行替换。


5. **总结**

Clock页替换算法通过维护一个循环链表和`visited`标志位，优先替换不活跃的页面，减少缺页率。设计中重点关注链表操作的正确性、访问位的重置逻辑，以及`curr_ptr`的循环遍历，最终实现了高效的页面替换。


### **Clock页替换算法和FIFO算法的不同**

#### **1. 算法思想**
- **FIFO（First-In-First-Out）**
  - 按页面进入内存的顺序替换最早进入的页面。
  - 简单易实现，无需额外信息。
  - 存在**Belady异常**：页面增加可能导致缺页率上升。

- **Clock算法**
  - 是FIFO的改进版本，引入了访问位（`visited`标志）来减少不必要的页面替换。
  - 页面替换遵循“时钟指针”遍历链表：
    - 如果访问位为0，则替换该页面。
    - 如果访问位为1，重置为0，并继续指针移动。
  - 避免了盲目替换活跃页面，提高性能。


#### **2. 数据结构**
- **FIFO**
  - 一个队列管理页面，先进先出。
  - 只需简单的链表或数组存储页面顺序。
  
- **Clock**
  - 使用循环双向链表模拟时钟，`curr_ptr`指针作为时钟指针。
  - 需要每个页面存储一个访问位，用于判断页面是否最近被访问。


#### **3. 替换逻辑**
- **FIFO**
  - 替换逻辑简单：
    - 直接替换队列头部的页面。
- **Clock**
  - 替换逻辑更加智能：
    - 如果当前指针指向的页面未被访问（`visited = 0`），替换该页面。
    - 如果被访问（`visited = 1`），重置访问位为0，并移动指针到下一个页面，继续检查。


#### **4. 性能对比**
- **FIFO**
  - 低开销，适用于小型系统。
  - 对访问模式不敏感，可能频繁替换常用页面，导致性能低下。
- **Clock**
  - 考虑了页面的访问状态，避免替换近期被访问的页面，性能更优。
  - 适用于需要频繁内存访问的系统。
  - 比FIFO稍高的实现复杂度。


### **总结**
- **Clock算法改进了FIFO**，在页面替换时考虑访问状态，避免频繁替换活跃页面。
- **实现过程关注链表的循环遍历、`visited`标志位的处理、以及`curr_ptr`指针的正确性**。
- 在实际系统中，Clock算法是性能和开销平衡较好的页替换算法之一，是LRU（Least Recently Used）算法的近似实现，广泛用于操作系统内存管理。




## 练习5：阅读代码和实现手册，理解页表映射方式相关知识（思考题）
如果我们采用”一个大页“ 的页表映射方式，相比分级页表，有什么好处、优势，有什么坏处、风险？
## Answer：
好处：
 - 减少页表项数量和页表大小：一个大页将一块连续的物理内存映射到一块连续的虚拟地址空间，所以我们在页表中只需要一个表项来映射整块内存，显著减少页表大小。
 - 减少内存访问次数，提升性能：一个大页只需要一次查找就可以会获得物理地址，减少了对页表的访问，提高了性能。
 - 提高TLB命中率：一个大页很显然相对小页涵盖的地址范围更广，更多的虚拟地址范围会映射到相同的物理页帧上，显然大页在TLB中的缓存命中率更高。
坏处：
 - 内存碎片问题：一个大页可能会导致产生更多的内存碎片，因为大页表必须保持连续的物理地址范围，这可能限制了内存的动态分配和回收能力，对内存的利用率降低。
 - 内存浪费：一个大页会导致每个页面都很大，对于需要内存不多的程序来说会对内存产生很大的浪费。
 - 页面置换时性能降低：当需要将一个大页从物理内存换出时，会产生一次较大的I/O操作，相比分级页表性能更差些。
 - TLB失效的代价更高：如果程序访问的内存模式导致了大页的TLB失效，那么失效的代价会比小页模式下更高，因为大页失效会导致丢失的地址范围更大。