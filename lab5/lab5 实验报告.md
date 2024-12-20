# lab5:用户程序

## 练习1: 加载应用程序并执行（需要编码）
do_execv函数调用`load_icode`（位于kern/process/proc.c中）来加载并解析一个处于内存中的ELF执行文件格式的应用程序。你需要补充`load_icode`的第6步，建立相应的用户内存空间来放置应用程序的代码段、数据段等，且要设置好`proc_struct`结构中的成员变量trapframe中的内容，确保在执行此进程后，能够从应用程序设定的起始执行地址开始执行。需设置正确的trapframe内容。

请在实验报告中简要说明你的设计实现过程。

- 请简要描述这个用户态进程被ucore选择占用CPU执行（RUNNING态）到具体执行应用程序第一条指令的整个经过。

## Answer:

### 1. **完善 `load_icode` 函数的第6步**

在 `load_icode` 函数中，第6步的任务是设置 `trapframe` 以确保新加载的用户进程能够从应用程序设定的起始执行地址开始执行。具体来说，需要正确初始化 `trapframe` 结构体中的关键成员，包括栈指针 (`sp`)、程序计数器 (`epc`) 和状态寄存器 (`status`)。

以下是补充完善后的 `load_icode` 函数：

```c
/* load_icode - load the content of binary program(ELF format) as the new content of current process
 * @binary:  the memory addr of the content of binary program
 * @size:    the size of the content of binary program
 */
static int
load_icode(unsigned char *binary, size_t size) {
    if (current->mm != NULL) {
        panic("load_icode: current->mm must be empty.\n");
    }

    int ret = -E_NO_MEM;
    struct mm_struct *mm;
    //(1) create a new mm for current process
    if ((mm = mm_create()) == NULL) {
        goto bad_mm;
    }
    //(2) create a new PDT, and mm->pgdir= kernel virtual addr of PDT
    if (setup_pgdir(mm) != 0) {
        goto bad_pgdir_cleanup_mm;
    }
    //(3) copy TEXT/DATA section, build BSS parts in binary to memory space of process
    struct Page *page;
    //(3.1) get the file header of the binary program (ELF format)
    struct elfhdr *elf = (struct elfhdr *)binary;
    //(3.2) get the entry of the program section headers of the binary program (ELF format)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
    //(3.3) This program is valid?
    if (elf->e_magic != ELF_MAGIC) {
        ret = -E_INVAL_ELF;
        goto bad_elf_cleanup_pgdir;
    }

    uint32_t vm_flags, perm;
    struct proghdr *ph_end = ph + elf->e_phnum;
    for (; ph < ph_end; ph ++) {
    //(3.4) find every program section headers
        if (ph->p_type != ELF_PT_LOAD) {
            continue ;
        }
        if (ph->p_filesz > ph->p_memsz) {
            ret = -E_INVAL_ELF;
            goto bad_cleanup_mmap;
        }
        if (ph->p_filesz == 0) {
            // continue ;
        }
    //(3.5) call mm_map fun to setup the new vma ( ph->p_va, ph->p_memsz)
        vm_flags = 0, perm = PTE_U | PTE_V;
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
        // modify the perm bits here for RISC-V
        if (vm_flags & VM_READ) perm |= PTE_R;
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
        if (vm_flags & VM_EXEC) perm |= PTE_X;
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
            goto bad_cleanup_mmap;
        }
        unsigned char *from = binary + ph->p_offset;
        size_t off, size;
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);

        ret = -E_NO_MEM;

     //(3.6) alloc memory, and copy the contents of every program section (from, from+end) to process's memory (la, la+end)
        end = ph->p_va + ph->p_filesz;
     //(3.6.1) copy TEXT/DATA section of binary program
        while (start < end) {
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
                goto bad_cleanup_mmap;
            }
            off = start - la, size = PGSIZE - off, la += PGSIZE;
            if (end < la) {
                size -= la - end;
            }
            memcpy(page2kva(page) + off, from, size);
            start += size, from += size;
        }

      //(3.6.2) build BSS section of binary program
        end = ph->p_va + ph->p_memsz;
        if (start < la) {
            /* ph->p_memsz == ph->p_filesz */
            if (start == end) {
                continue ;
            }
            off = start + PGSIZE - la, size = PGSIZE - off;
            if (end < la) {
                size -= la - end;
            }
            memset(page2kva(page) + off, 0, size);
            start += size;
            assert((end < la && start == end) || (end >= la && start == la));
        }
        while (start < end) {
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
                goto bad_cleanup_mmap;
            }
            off = start - la, size = PGSIZE - off, la += PGSIZE;
            if (end < la) {
                size -= la - end;
            }
            memset(page2kva(page) + off, 0, size);
            start += size;
        }
    }
    //(4) build user stack memory
    vm_flags = VM_READ | VM_WRITE | VM_STACK;
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
        goto bad_cleanup_mmap;
    }
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
    
    //(5) set current process's mm, sr3, and set CR3 reg = physical addr of Page Directory
    mm_count_inc(mm);
    current->mm = mm;
    current->cr3 = PADDR(mm->pgdir);
    lcr3(PADDR(mm->pgdir));

    //(6) setup trapframe for user environment
    struct trapframe *tf = current->tf;
    // Keep sstatus
    uintptr_t sstatus = tf->status;
    memset(tf, 0, sizeof(struct trapframe));
    /* LAB5:EXERCISE1 YOUR CODE
     * should set tf->gpr.sp, tf->epc, tf->status
     * NOTICE: If we set trapframe correctly, then the user level process can return to USER MODE from kernel. So
     *          tf->gpr.sp should be user stack top (the value of sp)
     *          tf->epc should be entry point of user program (the value of sepc)
     *          tf->status should be appropriate for user program (the value of sstatus)
     *          hint: check meaning of SPP, SPIE in SSTATUS, use them by SSTATUS_SPP, SSTATUS_SPIE(defined in risv.h)
     */

    // 3.1 设置用户栈指针
    tf->gpr.sp=USTACKTOP;

    // 3.2 设置程序计数器到用户程序的入口点，elf->e_entry是程序入口地址,定义在elf.h中
    tf->epc=elf->e_entry;

    // 3.3 设置状态寄存器
    // 将 SPP 清零（用户模式），设置 SPIE 位以启用中断
    tf->status=(sstatus|SSTATUS_SPIE)&(~SSTATUS_SPP);

    ret = 0;
out:
    return ret;
bad_cleanup_mmap:
    exit_mmap(mm);
bad_elf_cleanup_pgdir:
    put_pgdir(mm);
bad_pgdir_cleanup_mm:
    mm_destroy(mm);
bad_mm:
    goto out;
}
```

### 2. **设计实现过程简述**

#### 2.1 **创建内存管理结构 (`mm_struct`)**

首先，检查当前进程是否已有内存管理结构体 (`mm_struct`)。如果有，调用 `panic` 函数，因为 `load_icode` 应用于没有内存映射的进程。

```c
if (current->mm != NULL) {
    panic("load_icode: current->mm must be empty.\n");
}
```

#### 2.2 **创建页目录表 (Page Directory Table, PDT)**

调用 `mm_create` 创建一个新的 `mm_struct`，然后通过 `setup_pgdir` 初始化页目录表。如果任一步骤失败，进行相应的错误处理。

```c
if ((mm = mm_create()) == NULL) {
    goto bad_mm;
}
if (setup_pgdir(mm) != 0) {
    goto bad_pgdir_cleanup_mm;
}
```

#### 2.3 **解析 ELF 文件并映射内存**

遍历 ELF 文件的程序头表，找到所有类型为 `ELF_PT_LOAD` 的段，调用 `mm_map` 为每个段设置虚拟内存区域，并分配物理页面将程序内容复制到相应的虚拟地址空间。同时，处理 BSS 段，将其初始化为零。

```c
struct elfhdr *elf = (struct elfhdr *)binary;
struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
if (elf->e_magic != ELF_MAGIC) {
    ret = -E_INVAL_ELF;
    goto bad_elf_cleanup_pgdir;
}

for (; ph < ph_end; ph ++) {
    if (ph->p_type != ELF_PT_LOAD) {
        continue ;
    }
    if (ph->p_filesz > ph->p_memsz) {
        ret = -E_INVAL_ELF;
        goto bad_cleanup_mmap;
    }
    // 设置内存访问权限
    // 调用 mm_map 映射虚拟地址
    // 分配物理页面并复制内容
    // 初始化 BSS 段
}
```

#### 2.4 **建立用户栈**

调用 `mm_map` 为用户栈分配内存空间，并分配多个物理页面确保栈的完整性。

```c
vm_flags = VM_READ | VM_WRITE | VM_STACK;
if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
    goto bad_cleanup_mmap;
}
assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
```

#### 2.5 **设置进程的内存管理和页目录表**

增加 `mm_struct` 的引用计数，设置当前进程的内存管理结构和页目录表的物理地址，并切换到新的页目录表。

```c
mm_count_inc(mm);
current->mm = mm;
current->cr3 = PADDR(mm->pgdir);
lcr3(PADDR(mm->pgdir));
```

#### 2.6 **设置 `trapframe` 以启动用户程序**

这是关键步骤，确保新进程能够从用户程序的入口地址开始执行，并且具有正确的执行环境。

```c
struct trapframe *user_tf = current->tf;
// 保留原有的 sstatus
uintptr_t sstatus = user_tf->status;
// 清空 trapframe
memset(user_tf, 0, sizeof(struct trapframe));
// 3.1 设置用户栈指针
    tf->gpr.sp=USTACKTOP;

    // 3.2 设置程序计数器到用户程序的入口点，elf->e_entry是程序入口地址,定义在elf.h中
    tf->epc=elf->e_entry;

    // 3.3 设置状态寄存器
    // 将 SPP 清零（用户模式），设置 SPIE 位以启用中断
    tf->status=(sstatus|SSTATUS_SPIE)&(~SSTATUS_SPP);

    ret = 0;
```

**详细说明：**

1. **保留原有的 `sstatus`**：
   - 保存陷阱发生时的 `status` 寄存器值，以便在设置新的 `status` 时保留必要的状态信息。

2. **清空 `trapframe`**：
   - 使用 `memset` 将 `trapframe` 结构体清零，确保所有字段被初始化，避免未初始化的数据导致不可预知的行为。

3. **设置用户栈指针 (`sp`)**：
   - 将 `sp` 设置为用户栈的顶端地址 `USTACKTOP`，确保用户程序在执行时有一个有效的栈空间。

4. **设置程序计数器 (`epc`)**：
   - 将 `epc` 设置为 ELF 文件中的入口点地址 `e_entry`，确保用户程序从正确的起始地址开始执行。

5. **设置状态寄存器 (`status`)**：
   - 清除 `SPP` 位（Supervisor Previous Privilege），将执行权限设置为用户模式。
   - 设置 `SPIE` 位（Supervisor Previous Interrupt Enable），启用中断，使用户程序在返回时能够响应中断。

#### 2.7 **完成函数并返回**

设置完成后，将 `ret` 设为 `0` 表示成功，并跳转到 `out` 标签返回。

```c
ret = 0;
out:
    return ret;
```

### 3. **用户态进程从被调度到执行第一条指令的过程**

以下是用户态进程从被 ucore 调度为 RUNNING 状态，到执行应用程序第一条指令的完整过程：

1. **进程创建与初始化**：
   - 调用 `do_execve` 系统调用，内部调用 `load_icode` 函数加载并解析 ELF 文件。
   - `load_icode` 函数完成内存映射、栈建立和 `trapframe` 设置，确保新进程拥有独立的地址空间和正确的执行环境。

2. **将进程状态设置为可运行**：
   - 在 `do_execve` 或 `load_icode` 完成后，进程的状态被设置为 `PROC_RUNNABLE`，表示该进程可以被调度器调度执行。

3. **进程调度**：
   - 调度器（`schedule` 函数）选择一个可运行的进程（包括刚刚加载的用户进程）进行执行。
   - 调用 `proc_run` 函数，将选中的进程调度到 CPU 上运行。

4. **上下文切换**：
   - 在 `proc_run` 中，通过禁用中断、切换页目录表和调用 `switch_to` 函数实现上下文切换。
   - `switch_to` 函数保存当前进程的上下文（寄存器状态等），并恢复即将运行的进程的上下文。

5. **恢复用户态执行环境**：
   - 恢复后的进程拥有其对应的 `trapframe`，包括用户栈指针 (`sp`)、程序计数器 (`epc`) 和状态寄存器 (`status`)。
   - 通过 `lcr3` 切换到进程的页目录表，确保虚拟内存映射正确。

6. **从用户态返回执行**：
   - 调用 `usertrapret` 或类似的函数，利用 `trapframe` 中保存的状态恢复用户态执行。
   - CPU 从内核态切换回用户态，开始执行用户程序的第一条指令，从 `epc` 指定的入口地址开始。

7. **执行用户程序**：
   - 用户程序的第一条指令在正确的用户态和地址空间中开始执行。
   - 用户程序按照其代码逻辑运行，使用设置好的栈空间和数据段。


## 练习2: 父进程复制自己的内存空间给子进程（需要编码）
创建子进程的函数`do_fork`在执行中将拷贝当前进程（即父进程）的用户内存地址空间中的合法内容到新进程中（子进程），完成内存资源的复制。具体是通过`copy_range`函数（位于kern/mm/pmm.c中）实现的，请补充`copy_range`的实现，确保能够正确执行。

请在实验报告中简要说明你的设计实现过程。

- 如何设计实现Copy on Write机制？给出概要设计，鼓励给出详细设计。
> Copy-on-write（简称COW）的基本概念是指如果有多个使用者对一个资源A（比如内存块）进行读操作，则每个使用者只需获得一个指向同一个资源A的指针，就可以该资源了。若某使用者需要对这个资源A进行写操作，系统会对该资源进行拷贝操作，从而使得该“写操作”使用者获得一个该资源A的“私有”拷贝—资源B，可对资源B进行写操作。该“写操作”使用者对资源B的改变对于其他的使用者而言是不可见的，因为其他使用者看到的还是资源A。

## Answer：
### 实现过程
```c++
// 获取源页面所在的虚拟地址（注意，此时的PDT是内核状态下的页目录表）
void * kva_src=page2kva(page);
// 获取目标页面所在的虚拟地址
void * kva_dst=page2kva(npage);
// 页面数据复制
memcpy(kva_dst,kva_src,PGSIZE);
//将该页面设置至对应的PTE中
ret = page_insert(to, npage, start, perm);
```
我们在`do_fork()`中调用`copy_mm()`，该函数会根据`clone_flags`来确定是否需要克隆使用当前进程的进程管理结构。如果不需要，我们新建一个新的mm结构体并设置其中的页表基地址。我们对`oldmm`上锁，之后进入`dup_mmap(mm, oldmm)`。

在`dup_mmap(mm, oldmm)`中，我们循环把双向链表上的每一块VMA卸下并创造同一范围内的nvma挂到新的`mmstruct`，随后进入`cpoy_range()`。

在`copy_range()`中，我们从`start`开始在`from`页表上找页表项，在`to`页表上同样找页表项，如果没有找到则创建一个新的页表项。我们找到from页表项指向的物理页（page结构体），然后分配一个页结构体给进程B，获取两个页结构体管理的页的实际虚拟地址后把from页的内容复制到to页的内容中，最后把页和页表项关联起来，并通过perm设置其权限。

### COW的概要设计
当一个用户父进程创建子进程时，父进程会将申请的用户内存空间设置为只读状态，而子进程则可以共享父进程的用户内存空间中的页面。当父进程或子进程尝试修改此用户内存空间中的某页面时，系统能够通过`page fault`异常机制检测到这一操作，并自动进行内存页面的拷贝。这一过程确保了两个进程各自拥有独立的内存页面，从而使得一个进程对内存的修改不会影响到另一个进程。

- **页目录表的拷贝**：在执行`do_fork`时，子进程的页目录表会直接拷贝自父进程的页目录表。在`dup_mmap`过程中，只需保留拷贝虚拟内存区域（VMA）链表的部分，而无需调用`copy_range`来为子进程分配新的物理内存。

- **内存页面的共享**：父进程的内存空间对应的所有Page结构的引用计数（ref）均会加1，以表明子进程也在使用这些内存页面。

- **写权限的控制**：父子进程的页目录表的写权限会被取消。当父进程或子进程尝试执行写操作时，将触发页面访问异常。系统随后会进入页面访问异常处理函数，在该函数中进行内存拷贝，并恢复页目录表的写权限，确保两个进程的内存空间独立且互不影响。

## 练习3: 阅读分析源代码，理解进程执行 fork/exec/wait/exit 的实现，以及系统调用的实现（不需要编码）
请在实验报告中简要说明你对 fork/exec/wait/exit函数的分析。并回答如下问题：

请分析fork/exec/wait/exit的执行流程。重点关注哪些操作是在用户态完成，哪些是在内核态完成？内核态与用户态程序是如何交错执行的？内核态执行结果是如何返回给用户程序的？
请给出ucore中一个用户态进程的执行状态生命周期图（包执行状态，执行状态之间的变换关系，以及产生变换的事件或函数调用）。（字符方式画即可）
执行：make grade。如果所显示的应用程序检测都输出ok，则基本正确。（使用的是qemu-1.0.1）

## Challenge：实现 Copy on Write （COW）机制

给出实现源码,测试用例和设计报告（包括在cow情况下的各种状态转换（类似有限状态自动机）的说明）。

这个扩展练习涉及到本实验和上一个实验“虚拟内存管理”。在ucore操作系统中，当一个用户父进程创建自己的子进程时，父进程会把其申请的用户空间设置为只读，子进程可共享父进程占用的用户内存空间中的页面（这就是一个共享的资源）。当其中任何一个进程修改此用户内存空间中的某页面时，ucore会通过page fault异常获知该操作，并完成拷贝内存页面，使得两个进程都有各自的内存页面。这样一个进程所做的修改不会被另外一个进程可见了。请在ucore中实现这样的COW机制。

## Challenge：说明该用户程序是何时被预先加载到内存中的？与我们常用操作系统的加载有何区别，原因是什么？