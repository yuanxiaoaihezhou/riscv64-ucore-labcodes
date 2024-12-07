# lab4:进程管理
## 练习0
本实验依赖实验2/3。请把你做的实验2/3的代码填入本实验中代码中有“LAB2”,“LAB3”的注释相应部分。
## 练习1：分配并初始化一个进程控制块（需要编码）
`alloc_proc`函数（位于`kern/process/proc.c`中）负责分配并返回一个新的`struct proc_struct`结构，用于存储新建立的内核线程的管理信息。ucore需要对这个结构进行最基本的初始化，你需要完成这个初始化过程。

请在实验报告中简要说明你的设计实现过程。请回答如下问题：

请说明`proc_struct`中`struct context context`和`struct trapframe *tf`成员变量含义和在本实验中的作用是啥？（提示通过看代码和编程调试可以判断出来）

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