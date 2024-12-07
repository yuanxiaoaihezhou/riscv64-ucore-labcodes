# lab4 进程管理

## 扩展练习 Challenge：
说明语句`local_intr_save(intr_flag);....local_intr_restore(intr_flag);`是如何实现开关中断的？

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

