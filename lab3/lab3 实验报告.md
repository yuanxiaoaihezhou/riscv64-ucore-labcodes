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
    pde_t *pdep1 = &pgdir[PDX1(la)]; // 获取二级页表目录
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
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];  // 找到一级页表目录项
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
根据FIFO算法思想，在页面置换时，我们需要换出的是最先使用的页面（先入先出嘛），即最先加入到链表的节点对应的页面。在链表中，最先加入页面对应的节点就是头节点`head`的上一个节点，调用`list_prev()`即可。找到该节点后我们将其删除并获取被删除节点的页面对象，这里使用了`le2page`将链表节点转换为页面对象，并将其复制给`ptr_page`指向的指针。    
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
