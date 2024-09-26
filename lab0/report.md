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
> `auipc`（Add Upper Immediate to PC）用于把符号位扩展的20位（左移12位）立即数加到pc上，结果写入x[rd]。即：`x[rd] = pc + sext(immediate[31:12] << 12)` 。
在这里，我们将`0x0`进行扩展，并加到当前的PC上，最后将结果保存在寄存器`t0`。    
此时寄存器`t0`的值为：`0x1000`，即十进制值`4096`。

#### 2：0x1004:      `addi    a1,t0,32`
这条指令将寄存器`t0`的值与`32`相加，并将结果储存在寄存器`a1`。    
此时寄存器`a1`的值为：`0x1020`，即十进制值`4128`

#### 3：0x1008:      `csrr    a0,mhartid`
> `csrr`（Control and Status Register Read）用于把控制状态寄存器csr的值写入x[rd]。即：`x[rd] = CSRs[csr]` 。

在这里，这条指令将寄存器`mhartid`的值存储到寄存器`a0`中，其中寄存器`mhartid`存储着当前硬件线程的唯一标识符。    
此时寄存器`a0`的值为：`0x0`，即十进制值`0`。

#### 4：0x100c:      `ld      t0,24(t0)`
> `ld`（Load Doubleword）用于从地址x[rs1] + sign-extend(offset)读取八个字节，写入x[rd]。即：`x[rd] = M[x[rs1] + sext(offset)][63:0]` 。

在这里，这条指令从内存地址`t0`偏移`24`的地方读取了八个字节，并写入到了寄存器`t0`。
此时寄存器`t0`的值为：`0x80000000`，即十进制值`2147483648`。

#### 5：0x1010:      `jr      t0`
最后，我们跳转到地址`0x80000000`，这里也是OpenSBI.bin被加载到的地址。随后的从`0x80000000`到`80200000`完成的是把操作系统加载到内存的工作，并将控制权转移到操作系统。

## 练习二 实验中重要的知识点及其对应的课程知识点

## 练习三 实验未涉及但在课程中很重要的知识点