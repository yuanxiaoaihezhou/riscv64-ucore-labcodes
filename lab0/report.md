# 实验0.5 
## 练习一 使用GDB验证启动流程
使用`make debug`启动qemu并监听1234端口后，我们使用`make gdb`连接到qemu，经过一系列提示信息后终端输出：
```
Reading symbols from bin/kernel...
The target architecture is assumed to be riscv:rv6< c to continue without paging--
4
Remote debugging using localhost:1234
0x0000000000001000 in ?? ()
(gdb) 
```
我们可以看到，RISC-V加电后复位到0x1000处，我们使用`x/10i $pc`查看接下来执行的10条指令：
```
(gdb) x/10i $pc
=> 0x1000:      auipc   t0,0x0
   0x1004:      addi    a1,t0,32
   0x1008:      csrr    a0,mhartid
   0x100c:      ld      t0,24(t0)
   0x1010:      jr      t0
   0x1014:      unimp
   0x1016:      unimp
   0x1018:      unimp
   0x101a:      0x8000
   0x101c:      unimp
```
我们分别进行说明：

#### 1：0x1000:      `auipc   t0,0x0`
> `auipc`用于将一个20位的立即数符号扩展为32位，然后将其加到PC的高20位中，生成一个32位的地址