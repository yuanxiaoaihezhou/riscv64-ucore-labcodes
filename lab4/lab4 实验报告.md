# lab4:进程管理
## 练习0
本实验依赖实验2/3。请把你做的实验2/3的代码填入本实验中代码中有“LAB2”,“LAB3”的注释相应部分。
## 练习1：分配并初始化一个进程控制块（需要编码）
`alloc_proc`函数（位于`kern/process/proc.c`中）负责分配并返回一个新的`struct proc_struct`结构，用于存储新建立的内核线程的管理信息。ucore需要对这个结构进行最基本的初始化，你需要完成这个初始化过程。

请在实验报告中简要说明你的设计实现过程。请回答如下问题：

请说明`proc_struct`中`struct context context`和`struct trapframe *tf`成员变量含义和在本实验中的作用是啥？（提示通过看代码和编程调试可以判断出来）


## Answer

`alloc_proc` 函数编写如下：

```c
static struct proc_struct *
alloc_proc(void) {
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
    if (proc != NULL) {
    //LAB4:EXERCISE1 YOUR CODE 2213524
    /*
     * below fields in proc_struct need to be initialized
     *       enum proc_state state;                      // Process state
     *       int pid;                                    // Process ID
     *       int runs;                                   // the running times of Proces
     *       uintptr_t kstack;                           // Process kernel stack
     *       volatile bool need_resched;                 // bool value: need to be rescheduled to release CPU?
     *       struct proc_struct *parent;                 // the parent process
     *       struct mm_struct *mm;                       // Process's memory management field
     *       struct context context;                     // Switch here to run process
     *       struct trapframe *tf;                       // Trap frame for current interrupt
     *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */

    // 初始化进程状态为未初始化
        proc->state = PROC_UNINIT;

        // 进程ID暂时设为-1，稍后由do_fork分配
        proc->pid = -1;

        // 运行次数初始化为0
        proc->runs = 0;

        // 内核栈地址初始化为0，稍后由do_fork设置
        proc->kstack = 0;

        // 需要重新调度标志初始化为false
        proc->need_resched = 0;

        // 父进程指针设为 NULL
        proc->parent = NULL;

        // 内存管理结构体指针初始化为NULL，稍后由do_fork复制或共享
        proc->mm = NULL;

        // 上下文结构体清零
        memset(&(proc->context), 0, sizeof(struct context));

        // 陷阱帧指针初始化为NULL，稍后由copy_thread设置
        proc->tf = NULL;

        // 页目录表基地址初始化为ucore内核表的起始地址
        proc->cr3 = boot_cr3;

        // 进程标志初始化为0
        proc->flags = 0;

        // 进程名称初始化为空字符串
        memset(proc->name, 0, PROC_NAME_LEN);

    }
    return proc;
}
```

### 设计与实现过程

在实现 `alloc_proc` 函数时，主要目标是确保新分配的 `proc_struct` 结构体具备所有必要的初始状态和资源，以便后续的进程创建和管理能够顺利进行。以下是具体的设计与实现步骤：

1. **内存分配：**
   - 使用 `kalloc()` 函数分配一块内存，用于存储新的 `proc_struct` 结构体。
   - 如果内存分配失败，函数返回 `NULL`，表示无法创建新进程。

2. **初始化进程状态为未初始化**
   - 设置进程状态`proc->state`为 `PROC_UNINIT`，表示进程尚未初始化完毕。

3. **PID 初始化：**
   - 将 `pid` 初始化为 `-1`，表示尚未分配有效的 PID。PID 将在 `do_fork` 函数中通过 `get_pid()` 函数分配。

4. **运行次数初始化：**
   - 将 `runs` 字段初始化为 `0`，用于记录进程被调度执行的次数。

5. **内核栈指针初始化：**
   - 将 `kstack` 初始化为 `NULL`。内核栈将在 `do_fork` 函数中通过 `setup_kstack()` 函数分配。

6. **重新调度标志初始化：**
   - 将 `need_resched` 字段设置为 `false`，表示当前进程不需要立即进行重新调度。

7. **父进程指针初始化：**
   - 将 `parent` 指针初始化为 `NULL`。父进程将在 `do_fork` 函数中设置为当前进程。

8. **内存管理结构指针初始化：**
   - 将 `mm` 指针初始化为 `NULL`。内存管理结构将在 `do_fork` 函数中通过 `copy_mm()` 函数设置。

9. **上下文结构初始化：**
   - 使用 `memset` 将 `context` 结构体清零，确保所有寄存器状态都有已知的初始值。

10. **陷阱帧指针初始化：**
    - 将 `tf` 指针初始化为 `NULL`。陷阱帧将在 `do_fork` 函数中设置。

11. **页目录表基地址初始化：**
    - 将 `cr3` 初始化为 `boot_cr3`。即ucore内核表的起始地址。

12. **进程标志初始化：**
    - 将 `flags` 字段初始化为 `0`，表示进程没有任何特殊标志。

13. **进程名称初始化：**
    - 使用 `memset` 将进程名称初始化为空字符串。实际名称将在进程创建时设置。


通过以上步骤，`alloc_proc` 函数确保新创建的 `proc_struct` 结构体具备所有必要的初始状态，为后续的进程创建和管理打下基础。

### 回答问题

**请说明 `proc_struct` 中 `struct context context` 和 `struct trapframe *tf` 成员变量的含义及在本实验中的作用。**

**回答：**

在 `proc_struct` 结构体中，`struct context context` 和 `struct trapframe *tf` 是两个关键的成员变量，分别用于保存和恢复进程的执行状态。以下是对它们的详细解释：

1. **`struct context context`**

   - **含义：**
     - `context` 结构体用于保存进程在 CPU 上执行时的寄存器状态。它包含了**被调度进程**在上下文切换时需要保存的所有必要寄存器（如 `ra`、`sp`、`s0`~`s11` 等）。
     - 具体而言，`context` 通常包括**被调用者保存寄存器（callee-saved registers）**，这些寄存器在函数调用过程中需要被保存和恢复，以确保进程能够在被切换回来时继续正确执行。

   - **作用：**
     - **上下文切换**：在**进程调度**过程中，当操作系统决定将 CPU 的控制权从当前进程切换到另一个进程时，`context` 结构体中的寄存器状态会被保存到当前进程的 `context` 中，并从即将运行的进程的 `context` 中恢复寄存器状态。这样可以确保每个进程在被切换回来时，能够从上次被切换出去的位置继续执行。

   - **在本实验中的作用：**
     - 在 `do_fork` 函数中，通过调用 `copy_thread()` 函数，将当前进程的 `context` 复制到新进程的 `context` 中，确保新进程在被调度时能够拥有独立的执行环境。
     - 在 `proc_run` 函数中，通过调用 `switch_to()` 函数，使用 `context` 实现实际的上下文切换，将 CPU 的控制权从一个进程转移到另一个进程。

2. **`struct trapframe *tf`**

   - **含义：**
     - `trapframe` 结构体用于保存进程在陷入内核态（如发生系统调用、中断、异常等）时的寄存器状态和其他上下文信息。它包含了通用寄存器、程序计数器 (`epc`)、状态寄存器 (`status`)、以及其他与`trap`相关的信息。
     - `tf` 是一个指针，指向当前进程的 `trapframe`，用于在陷阱处理过程中保存和恢复进程的状态。

   - **作用：**
     - **中断处理**：当进程发生系统调用或中断时，处理器会将当前执行状态保存到 `trapframe` 中，然后转移到内核态进行相应的处理。处理完成后，通过 `trapframe` 恢复进程的执行状态，使其能够继续执行。
     - **进程创建与初始化**：在 `do_fork` 函数中，通过设置新进程的 `trapframe`，确保新进程在被调度时能够正确启动，执行指定的函数。

   - **在本实验中的作用：**
     - 在 `kernel_thread` 函数中，初始化 `trapframe` 并通过 `do_fork` 创建新进程时，`tf` 被用于设置新进程的初始寄存器状态，包括要执行的函数指针和参数。
     - 在 `do_fork` 函数中，通过调用 `copy_thread()` 函数，将父进程的 `trapframe` 复制到新进程的 `trapframe` 中，确保新进程能够从正确的入口点开始执行。




## 练习2：为新创建的内核线程分配资源（需要编码）
创建一个内核线程需要分配和设置好很多资源。`kernel_thread`函数通过调用`do_fork`函数完成具体内核线程的创建工作。`do_kernel`函数会调用`alloc_proc`函数来分配并初始化一个进程控制块，但`alloc_proc`只是找到了一小块内存用以记录进程的必要信息，并没有实际分配这些资源。ucore一般通过`do_fork`实际创建新的内核线程。`do_fork`的作用是，创建当前内核线程的一个副本，它们的执行上下文、代码、数据都一样，但是存储位置不同。因此，我们实际需要"fork"的东西就是`stack`和`trapframe`。在这个过程中，需要给新内核线程分配资源，并且复制原进程的状态。你需要完成在`kern/process/proc.c`中的`do_fork`函数中的处理过程。它的大致执行步骤包括：

- 调用alloc_proc，首先获得一块用户信息块。
- 为进程分配一个内核栈。
- 复制原进程的内存管理信息到新进程（但内核线程不必做此事）
- 复制原进程上下文到新进程
- 将新进程添加到进程列表
- 唤醒新进程
- 返回新进程号

请在实验报告中简要说明你的设计实现过程。请回答如下问题：

- 请说明ucore是否做到给每个新fork的线程一个唯一的id？请说明你的分析和理由。
## Answer:
由于文件中已经给出了`do_fork`函数的框架，我们只需要根据提示一步步书写即可。
#### 第一步：调用alloc_proc，首先获得一块用户信息块。
```c++
    proc = alloc_proc();
    if (proc == NULL) {
        goto fork_out;
    }
```
这一步直接调用`alloc_proc()`来分配一个新的 `proc_struct` 表示新的进程。
#### 第二步：为进程分配一个内核栈。
```c++
  if (setup_kstack(proc) != 0) {
        goto bad_fork_cleanup_kstack;
    }
```
通过 `setup_kstack()` 函数为新进程分配内核栈。内核栈用于保存进程在内核态运行时的上下文，如果分配失败，跳转到错误清理函数。这一步是确保每个进程有自己的内核栈空间，不同进程的栈相互独立，以保证进程间不会相互干扰。
#### 第三步：复制原进程的内存管理信息到新进程（但内核线程不必做此事）
```c++
  if (copy_mm(clone_flags, proc) != 0) {
        goto bad_fork_cleanup_proc;
    }
```
`copy_mm()` 函数会将父进程的内存管理信息复制到新进程中。内存映射由 `clone_flags` 决定，它指定了父子进程是否共享内存、文件描述符等。
#### 第四步：复制原进程上下文到新进程
```c++
    copy_thread(proc, stack, tf);
```
这一步会将父进程的线程上下文（寄存器、栈信息、陷阱帧）复制到子进程中，保证子进程能够从父进程中断的地方开始执行，使得执行上下文连贯。子进程从复制的栈开始执行，父进程的状态也被继承。
#### 第五步：将新进程添加到进程列表
```c++
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        proc->pid = get_pid();  // 为新进程分配一个唯一的PID
        hash_proc(proc);        // 将进程添加到哈希表
        list_add(&proc_list, &(proc->list_link));  // 将进程添加到全局进程链表
    }
    local_intr_restore(intr_flag);
```
这里先通过 `get_pid()` 函数为新进程分配一个进程 ID，新进程的 PID 被分配后，`hash_proc()` 和 `list_add()` 分别将进程添加到进程哈希表和全局进程链表中。哈希表用于快速查找进程，链表用于顺序调度。目的是将新进程纳入到操作系统的进程管理中， 使其能够被调度并执行。
#### 第六步：唤醒新进程
```c++
   wakeup_proc(proc);
```
`wakeup_proc()` 将新进程的状态设置为可运行，使其能够参与调度, 一旦子进程的创建完成，它就会被放入调度队列中，准备执行。
#### 第七步：返回新进程号
```c++
   ret = proc->pid;
```
最后，ret 变量被赋值为新进程的 PID，这个值将作为 `do_fork` 函数的返回值。父进程返回子进程的 PID，而子进程返回 0。这一步确保父进程能够获得子进程的 PID， 子进程能够正确地判断自己是否是子进程。
####  请说明ucore是否做到给每个新fork的线程一个唯一的id？
在第五步中，我们调用了`get_pid`函数来分配进程ID，它的实现也在`proc.c`文件中：
```c++
static int
get_pid(void) {
    static_assert(MAX_PID > MAX_PROCESS);
    struct proc_struct *proc;
    list_entry_t *list = &proc_list, *le;
    static int next_safe = MAX_PID, last_pid = MAX_PID;
    if (++ last_pid >= MAX_PID) {
        last_pid = 1;
        goto inside;
    }
    if (last_pid >= next_safe) {
    inside:
        next_safe = MAX_PID;
    repeat:
        le = list;
        while ((le = list_next(le)) != list) {
            proc = le2proc(le, list_link);
            if (proc->pid == last_pid) {
                if (++ last_pid >= next_safe) {
                    if (last_pid >= MAX_PID) {
                        last_pid = 1;
                    }
                    next_safe = MAX_PID;
                    goto repeat;
                }
            }
            else if (proc->pid > last_pid && next_safe > proc->pid) {
                next_safe = proc->pid;
            }
        }
    }
    return last_pid;
}
```
总而言之，函数遍历  `proc_list`（即所有的进程列表），查找一个不冲突的 PID。如果 `last_pid` 与现有进程冲突，就会增加 `last_pid`，直到找到一个可用的 PID。由于 last_pid 会一直递增，每次调用 `get_pid()` 都能获得一个唯一的 PID。也就是说每个新进程在被创建时，都会使用 `get_pid()` 获得一个唯一的 PID。然后，进程会被添加到进程哈希表中，后续调度时可以通过 PID 来查找和管理这些进程。

## 练习3：编写`proc_run` 函数（需要编码）
`proc_run`用于将指定的进程切换到CPU上运行。它的大致执行步骤包括：

- 检查要切换的进程是否与当前正在运行的进程相同，如果相同则不需要切换。
- 禁用中断。你可以使用`/kern/sync/sync.h`中定义好的宏`local_intr_save(x)`和`local_intr_restore(x)`来实现关、开中断。
- 切换当前进程为要运行的进程。
- 切换页表，以便使用新进程的地址空间。/libs/riscv.h中提供了lcr3(unsigned int cr3)函数，可实现修改CR3寄存器值的功能。
- 实现上下文切换。/kern/process中已经预先编写好了switch.S，其中定义了switch_to()函数。可实现两个进程的context切换。
- 允许中断。

请回答如下问题：

- 在本实验的执行过程中，创建且运行了几个内核线程？

## Answer

编写好的 `proc_run` 函数如下：

```c
void
proc_run(struct proc_struct *proc) {
    if (proc != current) {
        // LAB4:EXERCISE3 YOUR CODE 2213524
        /*
        * Some Useful MACROs, Functions and DEFINEs, you can use them in below implementation.
        * MACROs or Functions:
        *   local_intr_save():        Disable interrupts
        *   local_intr_restore():     Enable Interrupts
        *   lcr3():                   Modify the value of CR3 register
        *   switch_to():              Context switching between two processes
        */

        // 禁用中断，保存当前中断状态
        bool intr_flag;
        struct proc_struct *pre=current;
        local_intr_save(intr_flag);
        {
            //将当前运行的进程设置为proc
            current=proc;
            //切换到新进程的页目录表
            lcr3(proc->cr3);
            //进行上下文切换，从当前进程切换到新进程
            switch_to(&(pre->context),&(proc->context));
        }
        local_intr_restore(intr_flag);
       
    }
}
```

### 编写思路

在编写 `proc_run` 函数时，主要目标是实现进程上下文的安全、高效切换。以下是详细的设计与实现思路：

1. **检查进程相同性**：
    - 首先判断要切换的进程 `proc` 是否与当前进程 `current` 相同。
    - 如果相同，则无需进行任何操作，直接返回。这一步骤避免了不必要的上下文切换，提高了系统效率。

2. **禁用中断**：
    - 使用 `local_intr_save(intr_flag)` 宏禁用当前 CPU 的中断，并保存之前的中断状态到 `intr_flag`。
    - 禁用中断的目的是确保上下文切换过程的原子性，防止在切换过程中被中断打断，导致系统状态不一致或数据结构损坏。

3. **切换当前进程**：
    - 将全局指针 `current` 更新为要运行的进程 `proc`。
    - 这一步骤确保了系统能正确跟踪当前正在运行的进程。

4. **切换页表**：
    - 使用 `lcr3(proc->cr3)` 函数将 CR3 寄存器设置为新进程的页目录表基地址。
    - 切换页表是为了切换到新进程的地址空间，确保新进程能够访问其独立的虚拟内存空间。

5. **上下文切换**：
    - 调用 `switch_to(&(pre->context), &(proc->context))` 函数，实现从当前进程 `pre` 到新进程 `proc` 的上下文切换。
    - `switch_to` 函数负责保存当前进程的寄存器状态，并恢复新进程的寄存器状态，完成实际的 CPU 控制权切换。

6. **恢复中断**：
    - 使用 `local_intr_restore(intr_flag)` 宏恢复之前保存的中断状态。
    - 恢复中断后，系统可以继续响应中断和其他事件。


### 回答问题

**在本实验的执行过程中，创建且运行了几个内核线程？**

**Answer：**

在本实验的执行过程中，创建且运行了 **两个** 内核线程：

1. **空闲进程 (`idleproc`)**：
    - 在系统启动时，`proc_init` 函数调用 `alloc_proc` 分配并初始化了空闲进程 `idleproc`。
    - `idleproc` 的 PID 通常被设定为 `0`，是系统中永远存在的进程，用于在没有其他可运行进程时占用 CPU。
    - `idleproc` 通过调用 `cpu_idle` 函数，进入无限循环，等待调度器调度其他进程。

2. **初始化进程 (`initproc`)**：
    - 在 `proc_init` 函数中，通过调用 `kernel_thread(init_main, "Hello world!!", 0)` 创建了初始化进程 `initproc`。
    - `initproc` 的 PID 被设定为 `1`，是系统启动后创建的第一个内核线程。
    - `initproc` 负责进一步创建和管理用户态主线程或其他内核线程，并执行系统初始化任务。



## 扩展练习：说明语句`local_intr_save(intr_flag);....local_intr_restore(intr_flag);`是如何实现开关中断的？

## Answer：
我们先看相关的实现：
```c++
static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
        intr_disable();
        return 1;
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
    }
}

#define local_intr_save(x)      do { x = __intr_save(); } while (0)
#define local_intr_restore(x)   __intr_restore(x);
```
`__intr_save()`：如果当前`sstatus`寄存器的`SIE`位为 1（启用状态），则调用`intr_disable()`禁用中断，并返回`1`表示中断原本是开启的；否则，返回`0`表示中断原本是关闭的。

`__intr_restore()`：如果传入的参数`flag`为真，则调用 `intr_enable()`启用中断。

也就是说，宏`local_intr_save(intr_flag);`通过调用`__intr_save()`保存当前中断状态到传入的`intr_flag`中。这个操作的目的是在后续的执行中暂时禁用中断以防止在进程切换过程中被中断打断，并且保存当前中断状态以备后续恢复。

宏`local_intr_restore(intr_flag);`则通过之前保存的中断状态来启用或禁用中断。

