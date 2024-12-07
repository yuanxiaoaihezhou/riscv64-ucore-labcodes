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

## 扩展练习：说明语句`local_intr_save(intr_flag);....local_intr_restore(intr_flag);`是如何实现开关中断的？