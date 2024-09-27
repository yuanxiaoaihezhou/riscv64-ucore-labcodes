# lab1 断，都可以断

## 练习 1：理解内核启动中的程序入口操作
阅读 kern/init/entry.S 内容代码，结合操作系统内核启动流程，说明指令 la sp, bootstacktop 完成了什么操作，目的是什么？tail kern_init 完成了什么操作，目的是什么？
## Answer:
### 对 `la sp, bootstacktop`的理解
- **作用**：这条指令将符号 bootstacktop 的地址加载到栈指针寄存器 sp 中。sp 寄存器是栈指针，用于跟踪当前栈的顶部位置。la 是 "load address" 的缩写，它将地址加载到寄存器中。
- **目的**：在内核启动时，需要为内核**分配一个初始的栈空间**，以便执行后续的函数调用和中断处理。这里，bootstacktop 是在 .data 段中定义的，表示内核栈的顶部。通过将 sp 设置为 bootstacktop，内核启动时就有了自己的栈空间，确保后续的操作能够正常使用堆栈。

### 对`tail kern_init`的理解
- **作用**：tail 是一种无条件跳转指令，类似于 j 指令，但会优化调用堆栈的使用。tail kern_init 表示跳转到 kern_init 函数的入口。与常见的 jal 指令不同，**tail 不会保存返回地址到堆栈中**。
- **目的**：在启动完成栈指针的设置之后，tail kern_init 直接跳转到 kern_init 函数，进入内核的初始化流程。使用 tail 是为了节省堆栈空间，因为在这个阶段已经不再需要返回到 kern_entry。这是一个典型的内核启动优化手段。

## 练习2：完善中断处理 （需要编程）
请编程完善trap.c中的中断处理函数trap，在对时钟中断进行处理的部分填写kern/trap/trap.c函数中处理时钟中断的部分，使操作系统每遇到100次时钟中断后，调用print_ticks子程序，向屏幕上打印一行文字”100 ticks”，在打印完10行后调用sbi.h中的shut_down()函数关机。

要求完成问题1提出的相关函数实现，提交改进后的源代码包（可以编译执行），并在实验报告中简要说明实现过程和定时器中断中断处理的流程。实现要求的部分代码后，运行整个系统，大约每1秒会输出一次”100 ticks”，输出10行。
- 改写`interrupt_handler`函数
```
void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    switch (cause) {
        case IRQ_S_TIMER:
            // (1) 设置下次时钟中断
            clock_set_next_event();

            // (2) 计数器（ticks）加一
            static int ticks = 0;
            ticks++;

            // (3) 当计数器加到 100 的时候，输出 "100 ticks"，并打印次数加一
            if (ticks % 100 == 0)
            {
                num++; // 全局变量，记录打印次数
                print_ticks();

                // (4) 判断打印次数，当打印次数为 10 时，调用关机函数
                if (num == 10)
                {
                    sbi_shutdown();
                }
            }
            break;
        // 其他中断类型的处理...
        // ...
    }
}
```
- 执行：`make qemu`，查看结果
  ![alt text](image-1.png)
  成功输出10行”100 ticks”并关机。

## 扩展练习 Challenge1：描述与理解中断流程

回答：描述ucore中处理中断异常的流程（从异常的产生开始），其中mov a0，sp的目的是什么？SAVE_ALL中寄寄存器保存在栈中的位置是什么确定的？对于任何中断，__alltraps 中都需要保存所有寄存器吗？请说明理由。
