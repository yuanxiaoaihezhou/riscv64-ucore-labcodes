
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02052b7          	lui	t0,0xc0205
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	037a                	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000a:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc020000e:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200012:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200016:	137e                	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc0200018:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc020001c:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200020:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200024:	c0205137          	lui	sp,0xc0205

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200028:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020002c:	03228293          	addi	t0,t0,50 # ffffffffc0200032 <kern_init>
    jr t0
ffffffffc0200030:	8282                	jr	t0

ffffffffc0200032 <kern_init>:
void grade_backtrace(void);


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	00006517          	auipc	a0,0x6
ffffffffc0200036:	fde50513          	addi	a0,a0,-34 # ffffffffc0206010 <free_area>
ffffffffc020003a:	00006617          	auipc	a2,0x6
ffffffffc020003e:	44e60613          	addi	a2,a2,1102 # ffffffffc0206488 <end>
int kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
int kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	714010ef          	jal	ra,ffffffffc020175e <memset>
    cons_init();  // init the console
ffffffffc020004e:	3fc000ef          	jal	ra,ffffffffc020044a <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00001517          	auipc	a0,0x1
ffffffffc0200056:	71e50513          	addi	a0,a0,1822 # ffffffffc0201770 <etext>
ffffffffc020005a:	090000ef          	jal	ra,ffffffffc02000ea <cputs>

    print_kerninfo();
ffffffffc020005e:	0dc000ef          	jal	ra,ffffffffc020013a <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200062:	402000ef          	jal	ra,ffffffffc0200464 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc0200066:	022010ef          	jal	ra,ffffffffc0201088 <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc020006a:	3fa000ef          	jal	ra,ffffffffc0200464 <idt_init>

    clock_init();   // init clock interrupt
ffffffffc020006e:	39a000ef          	jal	ra,ffffffffc0200408 <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200072:	3e6000ef          	jal	ra,ffffffffc0200458 <intr_enable>



    /* do nothing */
    while (1)
ffffffffc0200076:	a001                	j	ffffffffc0200076 <kern_init+0x44>

ffffffffc0200078 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200078:	1141                	addi	sp,sp,-16
ffffffffc020007a:	e022                	sd	s0,0(sp)
ffffffffc020007c:	e406                	sd	ra,8(sp)
ffffffffc020007e:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200080:	3cc000ef          	jal	ra,ffffffffc020044c <cons_putc>
    (*cnt) ++;
ffffffffc0200084:	401c                	lw	a5,0(s0)
}
ffffffffc0200086:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200088:	2785                	addiw	a5,a5,1
ffffffffc020008a:	c01c                	sw	a5,0(s0)
}
ffffffffc020008c:	6402                	ld	s0,0(sp)
ffffffffc020008e:	0141                	addi	sp,sp,16
ffffffffc0200090:	8082                	ret

ffffffffc0200092 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200092:	1101                	addi	sp,sp,-32
ffffffffc0200094:	862a                	mv	a2,a0
ffffffffc0200096:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200098:	00000517          	auipc	a0,0x0
ffffffffc020009c:	fe050513          	addi	a0,a0,-32 # ffffffffc0200078 <cputch>
ffffffffc02000a0:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000a2:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000a4:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a6:	1e2010ef          	jal	ra,ffffffffc0201288 <vprintfmt>
    return cnt;
}
ffffffffc02000aa:	60e2                	ld	ra,24(sp)
ffffffffc02000ac:	4532                	lw	a0,12(sp)
ffffffffc02000ae:	6105                	addi	sp,sp,32
ffffffffc02000b0:	8082                	ret

ffffffffc02000b2 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000b2:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000b4:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000b8:	8e2a                	mv	t3,a0
ffffffffc02000ba:	f42e                	sd	a1,40(sp)
ffffffffc02000bc:	f832                	sd	a2,48(sp)
ffffffffc02000be:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c0:	00000517          	auipc	a0,0x0
ffffffffc02000c4:	fb850513          	addi	a0,a0,-72 # ffffffffc0200078 <cputch>
ffffffffc02000c8:	004c                	addi	a1,sp,4
ffffffffc02000ca:	869a                	mv	a3,t1
ffffffffc02000cc:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02000ce:	ec06                	sd	ra,24(sp)
ffffffffc02000d0:	e0ba                	sd	a4,64(sp)
ffffffffc02000d2:	e4be                	sd	a5,72(sp)
ffffffffc02000d4:	e8c2                	sd	a6,80(sp)
ffffffffc02000d6:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000d8:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000da:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000dc:	1ac010ef          	jal	ra,ffffffffc0201288 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e0:	60e2                	ld	ra,24(sp)
ffffffffc02000e2:	4512                	lw	a0,4(sp)
ffffffffc02000e4:	6125                	addi	sp,sp,96
ffffffffc02000e6:	8082                	ret

ffffffffc02000e8 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000e8:	a695                	j	ffffffffc020044c <cons_putc>

ffffffffc02000ea <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000ea:	1101                	addi	sp,sp,-32
ffffffffc02000ec:	e822                	sd	s0,16(sp)
ffffffffc02000ee:	ec06                	sd	ra,24(sp)
ffffffffc02000f0:	e426                	sd	s1,8(sp)
ffffffffc02000f2:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02000f4:	00054503          	lbu	a0,0(a0)
ffffffffc02000f8:	c51d                	beqz	a0,ffffffffc0200126 <cputs+0x3c>
ffffffffc02000fa:	0405                	addi	s0,s0,1
ffffffffc02000fc:	4485                	li	s1,1
ffffffffc02000fe:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200100:	34c000ef          	jal	ra,ffffffffc020044c <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc0200104:	00044503          	lbu	a0,0(s0)
ffffffffc0200108:	008487bb          	addw	a5,s1,s0
ffffffffc020010c:	0405                	addi	s0,s0,1
ffffffffc020010e:	f96d                	bnez	a0,ffffffffc0200100 <cputs+0x16>
    (*cnt) ++;
ffffffffc0200110:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200114:	4529                	li	a0,10
ffffffffc0200116:	336000ef          	jal	ra,ffffffffc020044c <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020011a:	60e2                	ld	ra,24(sp)
ffffffffc020011c:	8522                	mv	a0,s0
ffffffffc020011e:	6442                	ld	s0,16(sp)
ffffffffc0200120:	64a2                	ld	s1,8(sp)
ffffffffc0200122:	6105                	addi	sp,sp,32
ffffffffc0200124:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200126:	4405                	li	s0,1
ffffffffc0200128:	b7f5                	j	ffffffffc0200114 <cputs+0x2a>

ffffffffc020012a <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020012a:	1141                	addi	sp,sp,-16
ffffffffc020012c:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020012e:	326000ef          	jal	ra,ffffffffc0200454 <cons_getc>
ffffffffc0200132:	dd75                	beqz	a0,ffffffffc020012e <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200134:	60a2                	ld	ra,8(sp)
ffffffffc0200136:	0141                	addi	sp,sp,16
ffffffffc0200138:	8082                	ret

ffffffffc020013a <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020013a:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc020013c:	00001517          	auipc	a0,0x1
ffffffffc0200140:	65450513          	addi	a0,a0,1620 # ffffffffc0201790 <etext+0x20>
void print_kerninfo(void) {
ffffffffc0200144:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200146:	f6dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014a:	00000597          	auipc	a1,0x0
ffffffffc020014e:	ee858593          	addi	a1,a1,-280 # ffffffffc0200032 <kern_init>
ffffffffc0200152:	00001517          	auipc	a0,0x1
ffffffffc0200156:	65e50513          	addi	a0,a0,1630 # ffffffffc02017b0 <etext+0x40>
ffffffffc020015a:	f59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020015e:	00001597          	auipc	a1,0x1
ffffffffc0200162:	61258593          	addi	a1,a1,1554 # ffffffffc0201770 <etext>
ffffffffc0200166:	00001517          	auipc	a0,0x1
ffffffffc020016a:	66a50513          	addi	a0,a0,1642 # ffffffffc02017d0 <etext+0x60>
ffffffffc020016e:	f45ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200172:	00006597          	auipc	a1,0x6
ffffffffc0200176:	e9e58593          	addi	a1,a1,-354 # ffffffffc0206010 <free_area>
ffffffffc020017a:	00001517          	auipc	a0,0x1
ffffffffc020017e:	67650513          	addi	a0,a0,1654 # ffffffffc02017f0 <etext+0x80>
ffffffffc0200182:	f31ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200186:	00006597          	auipc	a1,0x6
ffffffffc020018a:	30258593          	addi	a1,a1,770 # ffffffffc0206488 <end>
ffffffffc020018e:	00001517          	auipc	a0,0x1
ffffffffc0200192:	68250513          	addi	a0,a0,1666 # ffffffffc0201810 <etext+0xa0>
ffffffffc0200196:	f1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019a:	00006597          	auipc	a1,0x6
ffffffffc020019e:	6ed58593          	addi	a1,a1,1773 # ffffffffc0206887 <end+0x3ff>
ffffffffc02001a2:	00000797          	auipc	a5,0x0
ffffffffc02001a6:	e9078793          	addi	a5,a5,-368 # ffffffffc0200032 <kern_init>
ffffffffc02001aa:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001ae:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001b2:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b4:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001b8:	95be                	add	a1,a1,a5
ffffffffc02001ba:	85a9                	srai	a1,a1,0xa
ffffffffc02001bc:	00001517          	auipc	a0,0x1
ffffffffc02001c0:	67450513          	addi	a0,a0,1652 # ffffffffc0201830 <etext+0xc0>
}
ffffffffc02001c4:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001c6:	b5f5                	j	ffffffffc02000b2 <cprintf>

ffffffffc02001c8 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001c8:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001ca:	00001617          	auipc	a2,0x1
ffffffffc02001ce:	69660613          	addi	a2,a2,1686 # ffffffffc0201860 <etext+0xf0>
ffffffffc02001d2:	04e00593          	li	a1,78
ffffffffc02001d6:	00001517          	auipc	a0,0x1
ffffffffc02001da:	6a250513          	addi	a0,a0,1698 # ffffffffc0201878 <etext+0x108>
void print_stackframe(void) {
ffffffffc02001de:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001e0:	1cc000ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02001e4 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001e4:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001e6:	00001617          	auipc	a2,0x1
ffffffffc02001ea:	6aa60613          	addi	a2,a2,1706 # ffffffffc0201890 <etext+0x120>
ffffffffc02001ee:	00001597          	auipc	a1,0x1
ffffffffc02001f2:	6c258593          	addi	a1,a1,1730 # ffffffffc02018b0 <etext+0x140>
ffffffffc02001f6:	00001517          	auipc	a0,0x1
ffffffffc02001fa:	6c250513          	addi	a0,a0,1730 # ffffffffc02018b8 <etext+0x148>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001fe:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200200:	eb3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200204:	00001617          	auipc	a2,0x1
ffffffffc0200208:	6c460613          	addi	a2,a2,1732 # ffffffffc02018c8 <etext+0x158>
ffffffffc020020c:	00001597          	auipc	a1,0x1
ffffffffc0200210:	6e458593          	addi	a1,a1,1764 # ffffffffc02018f0 <etext+0x180>
ffffffffc0200214:	00001517          	auipc	a0,0x1
ffffffffc0200218:	6a450513          	addi	a0,a0,1700 # ffffffffc02018b8 <etext+0x148>
ffffffffc020021c:	e97ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200220:	00001617          	auipc	a2,0x1
ffffffffc0200224:	6e060613          	addi	a2,a2,1760 # ffffffffc0201900 <etext+0x190>
ffffffffc0200228:	00001597          	auipc	a1,0x1
ffffffffc020022c:	6f858593          	addi	a1,a1,1784 # ffffffffc0201920 <etext+0x1b0>
ffffffffc0200230:	00001517          	auipc	a0,0x1
ffffffffc0200234:	68850513          	addi	a0,a0,1672 # ffffffffc02018b8 <etext+0x148>
ffffffffc0200238:	e7bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    }
    return 0;
}
ffffffffc020023c:	60a2                	ld	ra,8(sp)
ffffffffc020023e:	4501                	li	a0,0
ffffffffc0200240:	0141                	addi	sp,sp,16
ffffffffc0200242:	8082                	ret

ffffffffc0200244 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200244:	1141                	addi	sp,sp,-16
ffffffffc0200246:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200248:	ef3ff0ef          	jal	ra,ffffffffc020013a <print_kerninfo>
    return 0;
}
ffffffffc020024c:	60a2                	ld	ra,8(sp)
ffffffffc020024e:	4501                	li	a0,0
ffffffffc0200250:	0141                	addi	sp,sp,16
ffffffffc0200252:	8082                	ret

ffffffffc0200254 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200254:	1141                	addi	sp,sp,-16
ffffffffc0200256:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200258:	f71ff0ef          	jal	ra,ffffffffc02001c8 <print_stackframe>
    return 0;
}
ffffffffc020025c:	60a2                	ld	ra,8(sp)
ffffffffc020025e:	4501                	li	a0,0
ffffffffc0200260:	0141                	addi	sp,sp,16
ffffffffc0200262:	8082                	ret

ffffffffc0200264 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200264:	7115                	addi	sp,sp,-224
ffffffffc0200266:	ed5e                	sd	s7,152(sp)
ffffffffc0200268:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020026a:	00001517          	auipc	a0,0x1
ffffffffc020026e:	6c650513          	addi	a0,a0,1734 # ffffffffc0201930 <etext+0x1c0>
kmonitor(struct trapframe *tf) {
ffffffffc0200272:	ed86                	sd	ra,216(sp)
ffffffffc0200274:	e9a2                	sd	s0,208(sp)
ffffffffc0200276:	e5a6                	sd	s1,200(sp)
ffffffffc0200278:	e1ca                	sd	s2,192(sp)
ffffffffc020027a:	fd4e                	sd	s3,184(sp)
ffffffffc020027c:	f952                	sd	s4,176(sp)
ffffffffc020027e:	f556                	sd	s5,168(sp)
ffffffffc0200280:	f15a                	sd	s6,160(sp)
ffffffffc0200282:	e962                	sd	s8,144(sp)
ffffffffc0200284:	e566                	sd	s9,136(sp)
ffffffffc0200286:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200288:	e2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020028c:	00001517          	auipc	a0,0x1
ffffffffc0200290:	6cc50513          	addi	a0,a0,1740 # ffffffffc0201958 <etext+0x1e8>
ffffffffc0200294:	e1fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    if (tf != NULL) {
ffffffffc0200298:	000b8563          	beqz	s7,ffffffffc02002a2 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020029c:	855e                	mv	a0,s7
ffffffffc020029e:	3a4000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc02002a2:	00001c17          	auipc	s8,0x1
ffffffffc02002a6:	726c0c13          	addi	s8,s8,1830 # ffffffffc02019c8 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002aa:	00001917          	auipc	s2,0x1
ffffffffc02002ae:	6d690913          	addi	s2,s2,1750 # ffffffffc0201980 <etext+0x210>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b2:	00001497          	auipc	s1,0x1
ffffffffc02002b6:	6d648493          	addi	s1,s1,1750 # ffffffffc0201988 <etext+0x218>
        if (argc == MAXARGS - 1) {
ffffffffc02002ba:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002bc:	00001b17          	auipc	s6,0x1
ffffffffc02002c0:	6d4b0b13          	addi	s6,s6,1748 # ffffffffc0201990 <etext+0x220>
        argv[argc ++] = buf;
ffffffffc02002c4:	00001a17          	auipc	s4,0x1
ffffffffc02002c8:	5eca0a13          	addi	s4,s4,1516 # ffffffffc02018b0 <etext+0x140>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002cc:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002ce:	854a                	mv	a0,s2
ffffffffc02002d0:	33a010ef          	jal	ra,ffffffffc020160a <readline>
ffffffffc02002d4:	842a                	mv	s0,a0
ffffffffc02002d6:	dd65                	beqz	a0,ffffffffc02002ce <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002d8:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002dc:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002de:	e1bd                	bnez	a1,ffffffffc0200344 <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc02002e0:	fe0c87e3          	beqz	s9,ffffffffc02002ce <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002e4:	6582                	ld	a1,0(sp)
ffffffffc02002e6:	00001d17          	auipc	s10,0x1
ffffffffc02002ea:	6e2d0d13          	addi	s10,s10,1762 # ffffffffc02019c8 <commands>
        argv[argc ++] = buf;
ffffffffc02002ee:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002f0:	4401                	li	s0,0
ffffffffc02002f2:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002f4:	436010ef          	jal	ra,ffffffffc020172a <strcmp>
ffffffffc02002f8:	c919                	beqz	a0,ffffffffc020030e <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002fa:	2405                	addiw	s0,s0,1
ffffffffc02002fc:	0b540063          	beq	s0,s5,ffffffffc020039c <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200300:	000d3503          	ld	a0,0(s10)
ffffffffc0200304:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200306:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200308:	422010ef          	jal	ra,ffffffffc020172a <strcmp>
ffffffffc020030c:	f57d                	bnez	a0,ffffffffc02002fa <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc020030e:	00141793          	slli	a5,s0,0x1
ffffffffc0200312:	97a2                	add	a5,a5,s0
ffffffffc0200314:	078e                	slli	a5,a5,0x3
ffffffffc0200316:	97e2                	add	a5,a5,s8
ffffffffc0200318:	6b9c                	ld	a5,16(a5)
ffffffffc020031a:	865e                	mv	a2,s7
ffffffffc020031c:	002c                	addi	a1,sp,8
ffffffffc020031e:	fffc851b          	addiw	a0,s9,-1
ffffffffc0200322:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200324:	fa0555e3          	bgez	a0,ffffffffc02002ce <kmonitor+0x6a>
}
ffffffffc0200328:	60ee                	ld	ra,216(sp)
ffffffffc020032a:	644e                	ld	s0,208(sp)
ffffffffc020032c:	64ae                	ld	s1,200(sp)
ffffffffc020032e:	690e                	ld	s2,192(sp)
ffffffffc0200330:	79ea                	ld	s3,184(sp)
ffffffffc0200332:	7a4a                	ld	s4,176(sp)
ffffffffc0200334:	7aaa                	ld	s5,168(sp)
ffffffffc0200336:	7b0a                	ld	s6,160(sp)
ffffffffc0200338:	6bea                	ld	s7,152(sp)
ffffffffc020033a:	6c4a                	ld	s8,144(sp)
ffffffffc020033c:	6caa                	ld	s9,136(sp)
ffffffffc020033e:	6d0a                	ld	s10,128(sp)
ffffffffc0200340:	612d                	addi	sp,sp,224
ffffffffc0200342:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200344:	8526                	mv	a0,s1
ffffffffc0200346:	402010ef          	jal	ra,ffffffffc0201748 <strchr>
ffffffffc020034a:	c901                	beqz	a0,ffffffffc020035a <kmonitor+0xf6>
ffffffffc020034c:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc0200350:	00040023          	sb	zero,0(s0)
ffffffffc0200354:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200356:	d5c9                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200358:	b7f5                	j	ffffffffc0200344 <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc020035a:	00044783          	lbu	a5,0(s0)
ffffffffc020035e:	d3c9                	beqz	a5,ffffffffc02002e0 <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc0200360:	033c8963          	beq	s9,s3,ffffffffc0200392 <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc0200364:	003c9793          	slli	a5,s9,0x3
ffffffffc0200368:	0118                	addi	a4,sp,128
ffffffffc020036a:	97ba                	add	a5,a5,a4
ffffffffc020036c:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200370:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200374:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200376:	e591                	bnez	a1,ffffffffc0200382 <kmonitor+0x11e>
ffffffffc0200378:	b7b5                	j	ffffffffc02002e4 <kmonitor+0x80>
ffffffffc020037a:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc020037e:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200380:	d1a5                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200382:	8526                	mv	a0,s1
ffffffffc0200384:	3c4010ef          	jal	ra,ffffffffc0201748 <strchr>
ffffffffc0200388:	d96d                	beqz	a0,ffffffffc020037a <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020038a:	00044583          	lbu	a1,0(s0)
ffffffffc020038e:	d9a9                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200390:	bf55                	j	ffffffffc0200344 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200392:	45c1                	li	a1,16
ffffffffc0200394:	855a                	mv	a0,s6
ffffffffc0200396:	d1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020039a:	b7e9                	j	ffffffffc0200364 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020039c:	6582                	ld	a1,0(sp)
ffffffffc020039e:	00001517          	auipc	a0,0x1
ffffffffc02003a2:	61250513          	addi	a0,a0,1554 # ffffffffc02019b0 <etext+0x240>
ffffffffc02003a6:	d0dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    return 0;
ffffffffc02003aa:	b715                	j	ffffffffc02002ce <kmonitor+0x6a>

ffffffffc02003ac <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02003ac:	00006317          	auipc	t1,0x6
ffffffffc02003b0:	07c30313          	addi	t1,t1,124 # ffffffffc0206428 <is_panic>
ffffffffc02003b4:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02003b8:	715d                	addi	sp,sp,-80
ffffffffc02003ba:	ec06                	sd	ra,24(sp)
ffffffffc02003bc:	e822                	sd	s0,16(sp)
ffffffffc02003be:	f436                	sd	a3,40(sp)
ffffffffc02003c0:	f83a                	sd	a4,48(sp)
ffffffffc02003c2:	fc3e                	sd	a5,56(sp)
ffffffffc02003c4:	e0c2                	sd	a6,64(sp)
ffffffffc02003c6:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02003c8:	020e1a63          	bnez	t3,ffffffffc02003fc <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02003cc:	4785                	li	a5,1
ffffffffc02003ce:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc02003d2:	8432                	mv	s0,a2
ffffffffc02003d4:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003d6:	862e                	mv	a2,a1
ffffffffc02003d8:	85aa                	mv	a1,a0
ffffffffc02003da:	00001517          	auipc	a0,0x1
ffffffffc02003de:	63650513          	addi	a0,a0,1590 # ffffffffc0201a10 <commands+0x48>
    va_start(ap, fmt);
ffffffffc02003e2:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003e4:	ccfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003e8:	65a2                	ld	a1,8(sp)
ffffffffc02003ea:	8522                	mv	a0,s0
ffffffffc02003ec:	ca7ff0ef          	jal	ra,ffffffffc0200092 <vcprintf>
    cprintf("\n");
ffffffffc02003f0:	00002517          	auipc	a0,0x2
ffffffffc02003f4:	ca050513          	addi	a0,a0,-864 # ffffffffc0202090 <commands+0x6c8>
ffffffffc02003f8:	cbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02003fc:	062000ef          	jal	ra,ffffffffc020045e <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200400:	4501                	li	a0,0
ffffffffc0200402:	e63ff0ef          	jal	ra,ffffffffc0200264 <kmonitor>
    while (1) {
ffffffffc0200406:	bfed                	j	ffffffffc0200400 <__panic+0x54>

ffffffffc0200408 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc0200408:	1141                	addi	sp,sp,-16
ffffffffc020040a:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc020040c:	02000793          	li	a5,32
ffffffffc0200410:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200414:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200418:	67e1                	lui	a5,0x18
ffffffffc020041a:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc020041e:	953e                	add	a0,a0,a5
ffffffffc0200420:	2b8010ef          	jal	ra,ffffffffc02016d8 <sbi_set_timer>
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200426:	00006797          	auipc	a5,0x6
ffffffffc020042a:	0007b523          	sd	zero,10(a5) # ffffffffc0206430 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042e:	00001517          	auipc	a0,0x1
ffffffffc0200432:	60250513          	addi	a0,a0,1538 # ffffffffc0201a30 <commands+0x68>
}
ffffffffc0200436:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc0200438:	b9ad                	j	ffffffffc02000b2 <cprintf>

ffffffffc020043a <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020043a:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020043e:	67e1                	lui	a5,0x18
ffffffffc0200440:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc0200444:	953e                	add	a0,a0,a5
ffffffffc0200446:	2920106f          	j	ffffffffc02016d8 <sbi_set_timer>

ffffffffc020044a <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc020044a:	8082                	ret

ffffffffc020044c <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc020044c:	0ff57513          	andi	a0,a0,255
ffffffffc0200450:	26e0106f          	j	ffffffffc02016be <sbi_console_putchar>

ffffffffc0200454 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200454:	29e0106f          	j	ffffffffc02016f2 <sbi_console_getchar>

ffffffffc0200458 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200458:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc020045c:	8082                	ret

ffffffffc020045e <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc020045e:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200462:	8082                	ret

ffffffffc0200464 <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc0200464:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200468:	00000797          	auipc	a5,0x0
ffffffffc020046c:	2e478793          	addi	a5,a5,740 # ffffffffc020074c <__alltraps>
ffffffffc0200470:	10579073          	csrw	stvec,a5
}
ffffffffc0200474:	8082                	ret

ffffffffc0200476 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200476:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200478:	1141                	addi	sp,sp,-16
ffffffffc020047a:	e022                	sd	s0,0(sp)
ffffffffc020047c:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020047e:	00001517          	auipc	a0,0x1
ffffffffc0200482:	5d250513          	addi	a0,a0,1490 # ffffffffc0201a50 <commands+0x88>
void print_regs(struct pushregs *gpr) {
ffffffffc0200486:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200488:	c2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020048c:	640c                	ld	a1,8(s0)
ffffffffc020048e:	00001517          	auipc	a0,0x1
ffffffffc0200492:	5da50513          	addi	a0,a0,1498 # ffffffffc0201a68 <commands+0xa0>
ffffffffc0200496:	c1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00001517          	auipc	a0,0x1
ffffffffc02004a0:	5e450513          	addi	a0,a0,1508 # ffffffffc0201a80 <commands+0xb8>
ffffffffc02004a4:	c0fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00001517          	auipc	a0,0x1
ffffffffc02004ae:	5ee50513          	addi	a0,a0,1518 # ffffffffc0201a98 <commands+0xd0>
ffffffffc02004b2:	c01ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00001517          	auipc	a0,0x1
ffffffffc02004bc:	5f850513          	addi	a0,a0,1528 # ffffffffc0201ab0 <commands+0xe8>
ffffffffc02004c0:	bf3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00001517          	auipc	a0,0x1
ffffffffc02004ca:	60250513          	addi	a0,a0,1538 # ffffffffc0201ac8 <commands+0x100>
ffffffffc02004ce:	be5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00001517          	auipc	a0,0x1
ffffffffc02004d8:	60c50513          	addi	a0,a0,1548 # ffffffffc0201ae0 <commands+0x118>
ffffffffc02004dc:	bd7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00001517          	auipc	a0,0x1
ffffffffc02004e6:	61650513          	addi	a0,a0,1558 # ffffffffc0201af8 <commands+0x130>
ffffffffc02004ea:	bc9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00001517          	auipc	a0,0x1
ffffffffc02004f4:	62050513          	addi	a0,a0,1568 # ffffffffc0201b10 <commands+0x148>
ffffffffc02004f8:	bbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00001517          	auipc	a0,0x1
ffffffffc0200502:	62a50513          	addi	a0,a0,1578 # ffffffffc0201b28 <commands+0x160>
ffffffffc0200506:	badff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00001517          	auipc	a0,0x1
ffffffffc0200510:	63450513          	addi	a0,a0,1588 # ffffffffc0201b40 <commands+0x178>
ffffffffc0200514:	b9fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00001517          	auipc	a0,0x1
ffffffffc020051e:	63e50513          	addi	a0,a0,1598 # ffffffffc0201b58 <commands+0x190>
ffffffffc0200522:	b91ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00001517          	auipc	a0,0x1
ffffffffc020052c:	64850513          	addi	a0,a0,1608 # ffffffffc0201b70 <commands+0x1a8>
ffffffffc0200530:	b83ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00001517          	auipc	a0,0x1
ffffffffc020053a:	65250513          	addi	a0,a0,1618 # ffffffffc0201b88 <commands+0x1c0>
ffffffffc020053e:	b75ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00001517          	auipc	a0,0x1
ffffffffc0200548:	65c50513          	addi	a0,a0,1628 # ffffffffc0201ba0 <commands+0x1d8>
ffffffffc020054c:	b67ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00001517          	auipc	a0,0x1
ffffffffc0200556:	66650513          	addi	a0,a0,1638 # ffffffffc0201bb8 <commands+0x1f0>
ffffffffc020055a:	b59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00001517          	auipc	a0,0x1
ffffffffc0200564:	67050513          	addi	a0,a0,1648 # ffffffffc0201bd0 <commands+0x208>
ffffffffc0200568:	b4bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00001517          	auipc	a0,0x1
ffffffffc0200572:	67a50513          	addi	a0,a0,1658 # ffffffffc0201be8 <commands+0x220>
ffffffffc0200576:	b3dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00001517          	auipc	a0,0x1
ffffffffc0200580:	68450513          	addi	a0,a0,1668 # ffffffffc0201c00 <commands+0x238>
ffffffffc0200584:	b2fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00001517          	auipc	a0,0x1
ffffffffc020058e:	68e50513          	addi	a0,a0,1678 # ffffffffc0201c18 <commands+0x250>
ffffffffc0200592:	b21ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00001517          	auipc	a0,0x1
ffffffffc020059c:	69850513          	addi	a0,a0,1688 # ffffffffc0201c30 <commands+0x268>
ffffffffc02005a0:	b13ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00001517          	auipc	a0,0x1
ffffffffc02005aa:	6a250513          	addi	a0,a0,1698 # ffffffffc0201c48 <commands+0x280>
ffffffffc02005ae:	b05ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00001517          	auipc	a0,0x1
ffffffffc02005b8:	6ac50513          	addi	a0,a0,1708 # ffffffffc0201c60 <commands+0x298>
ffffffffc02005bc:	af7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00001517          	auipc	a0,0x1
ffffffffc02005c6:	6b650513          	addi	a0,a0,1718 # ffffffffc0201c78 <commands+0x2b0>
ffffffffc02005ca:	ae9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00001517          	auipc	a0,0x1
ffffffffc02005d4:	6c050513          	addi	a0,a0,1728 # ffffffffc0201c90 <commands+0x2c8>
ffffffffc02005d8:	adbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00001517          	auipc	a0,0x1
ffffffffc02005e2:	6ca50513          	addi	a0,a0,1738 # ffffffffc0201ca8 <commands+0x2e0>
ffffffffc02005e6:	acdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00001517          	auipc	a0,0x1
ffffffffc02005f0:	6d450513          	addi	a0,a0,1748 # ffffffffc0201cc0 <commands+0x2f8>
ffffffffc02005f4:	abfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00001517          	auipc	a0,0x1
ffffffffc02005fe:	6de50513          	addi	a0,a0,1758 # ffffffffc0201cd8 <commands+0x310>
ffffffffc0200602:	ab1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00001517          	auipc	a0,0x1
ffffffffc020060c:	6e850513          	addi	a0,a0,1768 # ffffffffc0201cf0 <commands+0x328>
ffffffffc0200610:	aa3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00001517          	auipc	a0,0x1
ffffffffc020061a:	6f250513          	addi	a0,a0,1778 # ffffffffc0201d08 <commands+0x340>
ffffffffc020061e:	a95ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00001517          	auipc	a0,0x1
ffffffffc0200628:	6fc50513          	addi	a0,a0,1788 # ffffffffc0201d20 <commands+0x358>
ffffffffc020062c:	a87ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	00001517          	auipc	a0,0x1
ffffffffc020063a:	70250513          	addi	a0,a0,1794 # ffffffffc0201d38 <commands+0x370>
}
ffffffffc020063e:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200640:	bc8d                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200642 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200642:	1141                	addi	sp,sp,-16
ffffffffc0200644:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200646:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200648:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020064a:	00001517          	auipc	a0,0x1
ffffffffc020064e:	70650513          	addi	a0,a0,1798 # ffffffffc0201d50 <commands+0x388>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200652:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200654:	a5fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200658:	8522                	mv	a0,s0
ffffffffc020065a:	e1dff0ef          	jal	ra,ffffffffc0200476 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020065e:	10043583          	ld	a1,256(s0)
ffffffffc0200662:	00001517          	auipc	a0,0x1
ffffffffc0200666:	70650513          	addi	a0,a0,1798 # ffffffffc0201d68 <commands+0x3a0>
ffffffffc020066a:	a49ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00001517          	auipc	a0,0x1
ffffffffc0200676:	70e50513          	addi	a0,a0,1806 # ffffffffc0201d80 <commands+0x3b8>
ffffffffc020067a:	a39ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00001517          	auipc	a0,0x1
ffffffffc0200686:	71650513          	addi	a0,a0,1814 # ffffffffc0201d98 <commands+0x3d0>
ffffffffc020068a:	a29ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020068e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	00001517          	auipc	a0,0x1
ffffffffc020069a:	71a50513          	addi	a0,a0,1818 # ffffffffc0201db0 <commands+0x3e8>
}
ffffffffc020069e:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006a0:	bc09                	j	ffffffffc02000b2 <cprintf>

ffffffffc02006a2 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006a2:	11853783          	ld	a5,280(a0)
ffffffffc02006a6:	472d                	li	a4,11
ffffffffc02006a8:	0786                	slli	a5,a5,0x1
ffffffffc02006aa:	8385                	srli	a5,a5,0x1
ffffffffc02006ac:	06f76c63          	bltu	a4,a5,ffffffffc0200724 <interrupt_handler+0x82>
ffffffffc02006b0:	00001717          	auipc	a4,0x1
ffffffffc02006b4:	7e070713          	addi	a4,a4,2016 # ffffffffc0201e90 <commands+0x4c8>
ffffffffc02006b8:	078a                	slli	a5,a5,0x2
ffffffffc02006ba:	97ba                	add	a5,a5,a4
ffffffffc02006bc:	439c                	lw	a5,0(a5)
ffffffffc02006be:	97ba                	add	a5,a5,a4
ffffffffc02006c0:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02006c2:	00001517          	auipc	a0,0x1
ffffffffc02006c6:	76650513          	addi	a0,a0,1894 # ffffffffc0201e28 <commands+0x460>
ffffffffc02006ca:	b2e5                	j	ffffffffc02000b2 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006cc:	00001517          	auipc	a0,0x1
ffffffffc02006d0:	73c50513          	addi	a0,a0,1852 # ffffffffc0201e08 <commands+0x440>
ffffffffc02006d4:	baf9                	j	ffffffffc02000b2 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d6:	00001517          	auipc	a0,0x1
ffffffffc02006da:	6f250513          	addi	a0,a0,1778 # ffffffffc0201dc8 <commands+0x400>
ffffffffc02006de:	bad1                	j	ffffffffc02000b2 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006e0:	00001517          	auipc	a0,0x1
ffffffffc02006e4:	76850513          	addi	a0,a0,1896 # ffffffffc0201e48 <commands+0x480>
ffffffffc02006e8:	b2e9                	j	ffffffffc02000b2 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02006ea:	1141                	addi	sp,sp,-16
ffffffffc02006ec:	e406                	sd	ra,8(sp)
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc02006ee:	d4dff0ef          	jal	ra,ffffffffc020043a <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc02006f2:	00006697          	auipc	a3,0x6
ffffffffc02006f6:	d3e68693          	addi	a3,a3,-706 # ffffffffc0206430 <ticks>
ffffffffc02006fa:	629c                	ld	a5,0(a3)
ffffffffc02006fc:	06400713          	li	a4,100
ffffffffc0200700:	0785                	addi	a5,a5,1
ffffffffc0200702:	02e7f733          	remu	a4,a5,a4
ffffffffc0200706:	e29c                	sd	a5,0(a3)
ffffffffc0200708:	cf19                	beqz	a4,ffffffffc0200726 <interrupt_handler+0x84>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc020070a:	60a2                	ld	ra,8(sp)
ffffffffc020070c:	0141                	addi	sp,sp,16
ffffffffc020070e:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200710:	00001517          	auipc	a0,0x1
ffffffffc0200714:	76050513          	addi	a0,a0,1888 # ffffffffc0201e70 <commands+0x4a8>
ffffffffc0200718:	ba69                	j	ffffffffc02000b2 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc020071a:	00001517          	auipc	a0,0x1
ffffffffc020071e:	6ce50513          	addi	a0,a0,1742 # ffffffffc0201de8 <commands+0x420>
ffffffffc0200722:	ba41                	j	ffffffffc02000b2 <cprintf>
            print_trapframe(tf);
ffffffffc0200724:	bf39                	j	ffffffffc0200642 <print_trapframe>
}
ffffffffc0200726:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200728:	06400593          	li	a1,100
ffffffffc020072c:	00001517          	auipc	a0,0x1
ffffffffc0200730:	73450513          	addi	a0,a0,1844 # ffffffffc0201e60 <commands+0x498>
}
ffffffffc0200734:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200736:	bab5                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200738 <trap>:
            break;
    }
}

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200738:	11853783          	ld	a5,280(a0)
ffffffffc020073c:	0007c763          	bltz	a5,ffffffffc020074a <trap+0x12>
    switch (tf->cause) {
ffffffffc0200740:	472d                	li	a4,11
ffffffffc0200742:	00f76363          	bltu	a4,a5,ffffffffc0200748 <trap+0x10>
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
}
ffffffffc0200746:	8082                	ret
            print_trapframe(tf);
ffffffffc0200748:	bded                	j	ffffffffc0200642 <print_trapframe>
        interrupt_handler(tf);
ffffffffc020074a:	bfa1                	j	ffffffffc02006a2 <interrupt_handler>

ffffffffc020074c <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc020074c:	14011073          	csrw	sscratch,sp
ffffffffc0200750:	712d                	addi	sp,sp,-288
ffffffffc0200752:	e002                	sd	zero,0(sp)
ffffffffc0200754:	e406                	sd	ra,8(sp)
ffffffffc0200756:	ec0e                	sd	gp,24(sp)
ffffffffc0200758:	f012                	sd	tp,32(sp)
ffffffffc020075a:	f416                	sd	t0,40(sp)
ffffffffc020075c:	f81a                	sd	t1,48(sp)
ffffffffc020075e:	fc1e                	sd	t2,56(sp)
ffffffffc0200760:	e0a2                	sd	s0,64(sp)
ffffffffc0200762:	e4a6                	sd	s1,72(sp)
ffffffffc0200764:	e8aa                	sd	a0,80(sp)
ffffffffc0200766:	ecae                	sd	a1,88(sp)
ffffffffc0200768:	f0b2                	sd	a2,96(sp)
ffffffffc020076a:	f4b6                	sd	a3,104(sp)
ffffffffc020076c:	f8ba                	sd	a4,112(sp)
ffffffffc020076e:	fcbe                	sd	a5,120(sp)
ffffffffc0200770:	e142                	sd	a6,128(sp)
ffffffffc0200772:	e546                	sd	a7,136(sp)
ffffffffc0200774:	e94a                	sd	s2,144(sp)
ffffffffc0200776:	ed4e                	sd	s3,152(sp)
ffffffffc0200778:	f152                	sd	s4,160(sp)
ffffffffc020077a:	f556                	sd	s5,168(sp)
ffffffffc020077c:	f95a                	sd	s6,176(sp)
ffffffffc020077e:	fd5e                	sd	s7,184(sp)
ffffffffc0200780:	e1e2                	sd	s8,192(sp)
ffffffffc0200782:	e5e6                	sd	s9,200(sp)
ffffffffc0200784:	e9ea                	sd	s10,208(sp)
ffffffffc0200786:	edee                	sd	s11,216(sp)
ffffffffc0200788:	f1f2                	sd	t3,224(sp)
ffffffffc020078a:	f5f6                	sd	t4,232(sp)
ffffffffc020078c:	f9fa                	sd	t5,240(sp)
ffffffffc020078e:	fdfe                	sd	t6,248(sp)
ffffffffc0200790:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200794:	100024f3          	csrr	s1,sstatus
ffffffffc0200798:	14102973          	csrr	s2,sepc
ffffffffc020079c:	143029f3          	csrr	s3,stval
ffffffffc02007a0:	14202a73          	csrr	s4,scause
ffffffffc02007a4:	e822                	sd	s0,16(sp)
ffffffffc02007a6:	e226                	sd	s1,256(sp)
ffffffffc02007a8:	e64a                	sd	s2,264(sp)
ffffffffc02007aa:	ea4e                	sd	s3,272(sp)
ffffffffc02007ac:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc02007ae:	850a                	mv	a0,sp
    jal trap
ffffffffc02007b0:	f89ff0ef          	jal	ra,ffffffffc0200738 <trap>

ffffffffc02007b4 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc02007b4:	6492                	ld	s1,256(sp)
ffffffffc02007b6:	6932                	ld	s2,264(sp)
ffffffffc02007b8:	10049073          	csrw	sstatus,s1
ffffffffc02007bc:	14191073          	csrw	sepc,s2
ffffffffc02007c0:	60a2                	ld	ra,8(sp)
ffffffffc02007c2:	61e2                	ld	gp,24(sp)
ffffffffc02007c4:	7202                	ld	tp,32(sp)
ffffffffc02007c6:	72a2                	ld	t0,40(sp)
ffffffffc02007c8:	7342                	ld	t1,48(sp)
ffffffffc02007ca:	73e2                	ld	t2,56(sp)
ffffffffc02007cc:	6406                	ld	s0,64(sp)
ffffffffc02007ce:	64a6                	ld	s1,72(sp)
ffffffffc02007d0:	6546                	ld	a0,80(sp)
ffffffffc02007d2:	65e6                	ld	a1,88(sp)
ffffffffc02007d4:	7606                	ld	a2,96(sp)
ffffffffc02007d6:	76a6                	ld	a3,104(sp)
ffffffffc02007d8:	7746                	ld	a4,112(sp)
ffffffffc02007da:	77e6                	ld	a5,120(sp)
ffffffffc02007dc:	680a                	ld	a6,128(sp)
ffffffffc02007de:	68aa                	ld	a7,136(sp)
ffffffffc02007e0:	694a                	ld	s2,144(sp)
ffffffffc02007e2:	69ea                	ld	s3,152(sp)
ffffffffc02007e4:	7a0a                	ld	s4,160(sp)
ffffffffc02007e6:	7aaa                	ld	s5,168(sp)
ffffffffc02007e8:	7b4a                	ld	s6,176(sp)
ffffffffc02007ea:	7bea                	ld	s7,184(sp)
ffffffffc02007ec:	6c0e                	ld	s8,192(sp)
ffffffffc02007ee:	6cae                	ld	s9,200(sp)
ffffffffc02007f0:	6d4e                	ld	s10,208(sp)
ffffffffc02007f2:	6dee                	ld	s11,216(sp)
ffffffffc02007f4:	7e0e                	ld	t3,224(sp)
ffffffffc02007f6:	7eae                	ld	t4,232(sp)
ffffffffc02007f8:	7f4e                	ld	t5,240(sp)
ffffffffc02007fa:	7fee                	ld	t6,248(sp)
ffffffffc02007fc:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc02007fe:	10200073          	sret

ffffffffc0200802 <buddy_system_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200802:	00006797          	auipc	a5,0x6
ffffffffc0200806:	80e78793          	addi	a5,a5,-2034 # ffffffffc0206010 <free_area>
ffffffffc020080a:	e79c                	sd	a5,8(a5)
ffffffffc020080c:	e39c                	sd	a5,0(a5)
}

// 初始化空闲页计数
static void buddy_system_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc020080e:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200812:	8082                	ret

ffffffffc0200814 <get_free_pages>:
}

// 获取空闲页数
static size_t get_free_pages(void) {
    return nr_free;
}
ffffffffc0200814:	00006517          	auipc	a0,0x6
ffffffffc0200818:	80c56503          	lwu	a0,-2036(a0) # ffffffffc0206020 <free_area+0x10>
ffffffffc020081c:	8082                	ret

ffffffffc020081e <simplified_print_tree>:
static void simplified_print_tree(void) {
ffffffffc020081e:	711d                	addi	sp,sp,-96
ffffffffc0200820:	e0ca                	sd	s2,64(sp)
    for (int i = 0; i < tree_size; i++) {
ffffffffc0200822:	00006917          	auipc	s2,0x6
ffffffffc0200826:	c2a90913          	addi	s2,s2,-982 # ffffffffc020644c <tree_size>
ffffffffc020082a:	00092703          	lw	a4,0(s2)
static void simplified_print_tree(void) {
ffffffffc020082e:	ec86                	sd	ra,88(sp)
ffffffffc0200830:	e8a2                	sd	s0,80(sp)
ffffffffc0200832:	e4a6                	sd	s1,72(sp)
ffffffffc0200834:	fc4e                	sd	s3,56(sp)
ffffffffc0200836:	f852                	sd	s4,48(sp)
ffffffffc0200838:	f456                	sd	s5,40(sp)
ffffffffc020083a:	f05a                	sd	s6,32(sp)
ffffffffc020083c:	ec5e                	sd	s7,24(sp)
ffffffffc020083e:	e862                	sd	s8,16(sp)
ffffffffc0200840:	e466                	sd	s9,8(sp)
ffffffffc0200842:	e06a                	sd	s10,0(sp)
    for (int i = 0; i < tree_size; i++) {
ffffffffc0200844:	08e05563          	blez	a4,ffffffffc02008ce <simplified_print_tree+0xb0>
ffffffffc0200848:	4481                	li	s1,0
ffffffffc020084a:	4c81                	li	s9,0
    int count = 1;
ffffffffc020084c:	4d05                	li	s10,1
ffffffffc020084e:	00006a17          	auipc	s4,0x6
ffffffffc0200852:	bf2a0a13          	addi	s4,s4,-1038 # ffffffffc0206440 <buddy_tree>
            cprintf("%d", buddy_tree[i]);
ffffffffc0200856:	00001997          	auipc	s3,0x1
ffffffffc020085a:	66a98993          	addi	s3,s3,1642 # ffffffffc0201ec0 <commands+0x4f8>
            if (count > 1) {
ffffffffc020085e:	4b85                	li	s7,1
            cprintf(" ");
ffffffffc0200860:	00001b17          	auipc	s6,0x1
ffffffffc0200864:	670b0b13          	addi	s6,s6,1648 # ffffffffc0201ed0 <commands+0x508>
                cprintf("(%d)", count);
ffffffffc0200868:	00001a97          	auipc	s5,0x1
ffffffffc020086c:	660a8a93          	addi	s5,s5,1632 # ffffffffc0201ec8 <commands+0x500>
            cprintf("\n");
ffffffffc0200870:	00002c17          	auipc	s8,0x2
ffffffffc0200874:	820c0c13          	addi	s8,s8,-2016 # ffffffffc0202090 <commands+0x6c8>
ffffffffc0200878:	a031                	j	ffffffffc0200884 <simplified_print_tree+0x66>
    for (int i = 0; i < tree_size; i++) {
ffffffffc020087a:	00092703          	lw	a4,0(s2)
ffffffffc020087e:	0491                	addi	s1,s1,4
ffffffffc0200880:	04ecd763          	bge	s9,a4,ffffffffc02008ce <simplified_print_tree+0xb0>
        if (i + 1 < tree_size && buddy_tree[i] == buddy_tree[i + 1]) {
ffffffffc0200884:	000a3783          	ld	a5,0(s4)
ffffffffc0200888:	8466                	mv	s0,s9
ffffffffc020088a:	2c85                	addiw	s9,s9,1
ffffffffc020088c:	97a6                	add	a5,a5,s1
ffffffffc020088e:	438c                	lw	a1,0(a5)
            cprintf("%d", buddy_tree[i]);
ffffffffc0200890:	854e                	mv	a0,s3
        if (i + 1 < tree_size && buddy_tree[i] == buddy_tree[i + 1]) {
ffffffffc0200892:	00ecd563          	bge	s9,a4,ffffffffc020089c <simplified_print_tree+0x7e>
ffffffffc0200896:	43dc                	lw	a5,4(a5)
ffffffffc0200898:	04b78963          	beq	a5,a1,ffffffffc02008ea <simplified_print_tree+0xcc>
            cprintf("%d", buddy_tree[i]);
ffffffffc020089c:	817ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
                cprintf("(%d)", count);
ffffffffc02008a0:	85ea                	mv	a1,s10
ffffffffc02008a2:	8556                	mv	a0,s5
            if (count > 1) {
ffffffffc02008a4:	017d0463          	beq	s10,s7,ffffffffc02008ac <simplified_print_tree+0x8e>
                cprintf("(%d)", count);
ffffffffc02008a8:	80bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
            cprintf(" ");
ffffffffc02008ac:	855a                	mv	a0,s6
ffffffffc02008ae:	805ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
            count = 1;
ffffffffc02008b2:	4d05                	li	s10,1
        if (((i + 2) & (i + 1)) == 0) {
ffffffffc02008b4:	2409                	addiw	s0,s0,2
ffffffffc02008b6:	008cf433          	and	s0,s9,s0
ffffffffc02008ba:	2401                	sext.w	s0,s0
ffffffffc02008bc:	fc5d                	bnez	s0,ffffffffc020087a <simplified_print_tree+0x5c>
            cprintf("\n");
ffffffffc02008be:	8562                	mv	a0,s8
ffffffffc02008c0:	ff2ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    for (int i = 0; i < tree_size; i++) {
ffffffffc02008c4:	00092703          	lw	a4,0(s2)
ffffffffc02008c8:	0491                	addi	s1,s1,4
ffffffffc02008ca:	faeccde3          	blt	s9,a4,ffffffffc0200884 <simplified_print_tree+0x66>
}
ffffffffc02008ce:	60e6                	ld	ra,88(sp)
ffffffffc02008d0:	6446                	ld	s0,80(sp)
ffffffffc02008d2:	64a6                	ld	s1,72(sp)
ffffffffc02008d4:	6906                	ld	s2,64(sp)
ffffffffc02008d6:	79e2                	ld	s3,56(sp)
ffffffffc02008d8:	7a42                	ld	s4,48(sp)
ffffffffc02008da:	7aa2                	ld	s5,40(sp)
ffffffffc02008dc:	7b02                	ld	s6,32(sp)
ffffffffc02008de:	6be2                	ld	s7,24(sp)
ffffffffc02008e0:	6c42                	ld	s8,16(sp)
ffffffffc02008e2:	6ca2                	ld	s9,8(sp)
ffffffffc02008e4:	6d02                	ld	s10,0(sp)
ffffffffc02008e6:	6125                	addi	sp,sp,96
ffffffffc02008e8:	8082                	ret
            count++;
ffffffffc02008ea:	2d05                	addiw	s10,s10,1
ffffffffc02008ec:	b7e1                	j	ffffffffc02008b4 <simplified_print_tree+0x96>

ffffffffc02008ee <buddy_system_init_memmap>:
static void buddy_system_init_memmap(struct Page *base, size_t n) {
ffffffffc02008ee:	7179                	addi	sp,sp,-48
ffffffffc02008f0:	f406                	sd	ra,40(sp)
ffffffffc02008f2:	f022                	sd	s0,32(sp)
ffffffffc02008f4:	ec26                	sd	s1,24(sp)
ffffffffc02008f6:	e84a                	sd	s2,16(sp)
ffffffffc02008f8:	e44e                	sd	s3,8(sp)
    assert(n > 0);
ffffffffc02008fa:	12058f63          	beqz	a1,ffffffffc0200a38 <buddy_system_init_memmap+0x14a>
    if (!is_power_of_two(n)) {
ffffffffc02008fe:	0005871b          	sext.w	a4,a1
    return (n & (n - 1)) == 0;
ffffffffc0200902:	fff7079b          	addiw	a5,a4,-1
ffffffffc0200906:	8ff9                	and	a5,a5,a4
    if (!is_power_of_two(n)) {
ffffffffc0200908:	2781                	sext.w	a5,a5
ffffffffc020090a:	842a                	mv	s0,a0
ffffffffc020090c:	86ba                	mv	a3,a4
ffffffffc020090e:	0e079d63          	bnez	a5,ffffffffc0200a08 <buddy_system_init_memmap+0x11a>
    nr_free += total_pages;
ffffffffc0200912:	00005517          	auipc	a0,0x5
ffffffffc0200916:	6fe50513          	addi	a0,a0,1790 # ffffffffc0206010 <free_area>
ffffffffc020091a:	4910                	lw	a2,16(a0)
    for(; page != base + total_pages; page++) {
ffffffffc020091c:	00271793          	slli	a5,a4,0x2
    tree_size = 2 * total_pages - 1; // 总结点数
ffffffffc0200920:	0017159b          	slliw	a1,a4,0x1
    for(; page != base + total_pages; page++) {
ffffffffc0200924:	97ba                	add	a5,a5,a4
    nr_free += total_pages;
ffffffffc0200926:	9e39                	addw	a2,a2,a4
    total_pages = floor_to_power_of_two(n); // 向下取整到最接近2的幂, 多余的页我们这里为了方便舍弃。
ffffffffc0200928:	00006497          	auipc	s1,0x6
ffffffffc020092c:	b2048493          	addi	s1,s1,-1248 # ffffffffc0206448 <total_pages>
    tree_size = 2 * total_pages - 1; // 总结点数
ffffffffc0200930:	00006917          	auipc	s2,0x6
ffffffffc0200934:	b1c90913          	addi	s2,s2,-1252 # ffffffffc020644c <tree_size>
ffffffffc0200938:	35fd                	addiw	a1,a1,-1
    for(; page != base + total_pages; page++) {
ffffffffc020093a:	078e                	slli	a5,a5,0x3
    total_pages = floor_to_power_of_two(n); // 向下取整到最接近2的幂, 多余的页我们这里为了方便舍弃。
ffffffffc020093c:	c098                	sw	a4,0(s1)
    tree_size = 2 * total_pages - 1; // 总结点数
ffffffffc020093e:	00b92023          	sw	a1,0(s2)
    nr_free += total_pages;
ffffffffc0200942:	c910                	sw	a2,16(a0)
    base_page = base;
ffffffffc0200944:	00006717          	auipc	a4,0x6
ffffffffc0200948:	ae873a23          	sd	s0,-1292(a4) # ffffffffc0206438 <base_page>
    for(; page != base + total_pages; page++) {
ffffffffc020094c:	97a2                	add	a5,a5,s0
ffffffffc020094e:	02f40c63          	beq	s0,a5,ffffffffc0200986 <buddy_system_init_memmap+0x98>
ffffffffc0200952:	87a2                	mv	a5,s0
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200954:	4609                	li	a2,2
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200956:	6798                	ld	a4,8(a5)
        assert(PageReserved(page));
ffffffffc0200958:	8b05                	andi	a4,a4,1
ffffffffc020095a:	cf5d                	beqz	a4,ffffffffc0200a18 <buddy_system_init_memmap+0x12a>
        page->flags = page->property = 0;
ffffffffc020095c:	0007a823          	sw	zero,16(a5)
ffffffffc0200960:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200964:	0007a023          	sw	zero,0(a5)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200968:	00878713          	addi	a4,a5,8
ffffffffc020096c:	40c7302f          	amoor.d	zero,a2,(a4)
    for(; page != base + total_pages; page++) {
ffffffffc0200970:	4094                	lw	a3,0(s1)
ffffffffc0200972:	02878793          	addi	a5,a5,40
ffffffffc0200976:	00269713          	slli	a4,a3,0x2
ffffffffc020097a:	9736                	add	a4,a4,a3
ffffffffc020097c:	070e                	slli	a4,a4,0x3
ffffffffc020097e:	9722                	add	a4,a4,s0
ffffffffc0200980:	fce79be3          	bne	a5,a4,ffffffffc0200956 <buddy_system_init_memmap+0x68>
    base->property = total_pages;
ffffffffc0200984:	2681                	sext.w	a3,a3
ffffffffc0200986:	c814                	sw	a3,16(s0)
    buddy_tree = (unsigned int *)(base + total_pages);
ffffffffc0200988:	00006997          	auipc	s3,0x6
ffffffffc020098c:	ab898993          	addi	s3,s3,-1352 # ffffffffc0206440 <buddy_tree>
    cprintf("\n-----------------Buddy System Initialized!------------------\n\n");
ffffffffc0200990:	00001517          	auipc	a0,0x1
ffffffffc0200994:	5a050513          	addi	a0,a0,1440 # ffffffffc0201f30 <commands+0x568>
    buddy_tree = (unsigned int *)(base + total_pages);
ffffffffc0200998:	00f9b023          	sd	a5,0(s3)
    cprintf("\n-----------------Buddy System Initialized!------------------\n\n");
ffffffffc020099c:	f16ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Base page address: %p, Total pages: %d\n", base, total_pages);
ffffffffc02009a0:	4090                	lw	a2,0(s1)
ffffffffc02009a2:	85a2                	mv	a1,s0
ffffffffc02009a4:	00001517          	auipc	a0,0x1
ffffffffc02009a8:	5cc50513          	addi	a0,a0,1484 # ffffffffc0201f70 <commands+0x5a8>
ffffffffc02009ac:	f06ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Buddy tree address: %p, Tree size: %d\n", buddy_tree, tree_size);
ffffffffc02009b0:	00092603          	lw	a2,0(s2)
ffffffffc02009b4:	0009b583          	ld	a1,0(s3)
ffffffffc02009b8:	00001517          	auipc	a0,0x1
ffffffffc02009bc:	5e050513          	addi	a0,a0,1504 # ffffffffc0201f98 <commands+0x5d0>
ffffffffc02009c0:	ef2ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    buddy_tree[0] = total_pages;
ffffffffc02009c4:	0009b683          	ld	a3,0(s3)
    unsigned int node_size = total_pages;
ffffffffc02009c8:	4090                	lw	a2,0(s1)
    for(int i = 1; i < tree_size; i++) {
ffffffffc02009ca:	4785                	li	a5,1
ffffffffc02009cc:	00468713          	addi	a4,a3,4
    buddy_tree[0] = total_pages;
ffffffffc02009d0:	c290                	sw	a2,0(a3)
    for(int i = 1; i < tree_size; i++) {
ffffffffc02009d2:	00092683          	lw	a3,0(s2)
ffffffffc02009d6:	02d7d263          	bge	a5,a3,ffffffffc02009fa <buddy_system_init_memmap+0x10c>
        if (is_power_of_two(i+1)) { // i是该层最后一个节点
ffffffffc02009da:	0017869b          	addiw	a3,a5,1
    return (n & (n - 1)) == 0;
ffffffffc02009de:	8ff5                	and	a5,a5,a3
        if (is_power_of_two(i+1)) { // i是该层最后一个节点
ffffffffc02009e0:	0007859b          	sext.w	a1,a5
ffffffffc02009e4:	0006879b          	sext.w	a5,a3
ffffffffc02009e8:	e199                	bnez	a1,ffffffffc02009ee <buddy_system_init_memmap+0x100>
            node_size /= 2;
ffffffffc02009ea:	0016561b          	srliw	a2,a2,0x1
        buddy_tree[i] = node_size;
ffffffffc02009ee:	c310                	sw	a2,0(a4)
    for(int i = 1; i < tree_size; i++) {
ffffffffc02009f0:	00092683          	lw	a3,0(s2)
ffffffffc02009f4:	0711                	addi	a4,a4,4
ffffffffc02009f6:	fed7c2e3          	blt	a5,a3,ffffffffc02009da <buddy_system_init_memmap+0xec>
}
ffffffffc02009fa:	70a2                	ld	ra,40(sp)
ffffffffc02009fc:	7402                	ld	s0,32(sp)
ffffffffc02009fe:	64e2                	ld	s1,24(sp)
ffffffffc0200a00:	6942                	ld	s2,16(sp)
ffffffffc0200a02:	69a2                	ld	s3,8(sp)
ffffffffc0200a04:	6145                	addi	sp,sp,48
ffffffffc0200a06:	8082                	ret
    size_t result = 1;
ffffffffc0200a08:	4785                	li	a5,1
            n >>= 1;
ffffffffc0200a0a:	8185                	srli	a1,a1,0x1
            result <<= 1;
ffffffffc0200a0c:	873e                	mv	a4,a5
ffffffffc0200a0e:	0786                	slli	a5,a5,0x1
        while (n) {
ffffffffc0200a10:	fded                	bnez	a1,ffffffffc0200a0a <buddy_system_init_memmap+0x11c>
    nr_free += total_pages;
ffffffffc0200a12:	2701                	sext.w	a4,a4
ffffffffc0200a14:	86ba                	mv	a3,a4
        return result >> 1;
ffffffffc0200a16:	bdf5                	j	ffffffffc0200912 <buddy_system_init_memmap+0x24>
        assert(PageReserved(page));
ffffffffc0200a18:	00001697          	auipc	a3,0x1
ffffffffc0200a1c:	50068693          	addi	a3,a3,1280 # ffffffffc0201f18 <commands+0x550>
ffffffffc0200a20:	00001617          	auipc	a2,0x1
ffffffffc0200a24:	4c060613          	addi	a2,a2,1216 # ffffffffc0201ee0 <commands+0x518>
ffffffffc0200a28:	04b00593          	li	a1,75
ffffffffc0200a2c:	00001517          	auipc	a0,0x1
ffffffffc0200a30:	4cc50513          	addi	a0,a0,1228 # ffffffffc0201ef8 <commands+0x530>
ffffffffc0200a34:	979ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc0200a38:	00001697          	auipc	a3,0x1
ffffffffc0200a3c:	4a068693          	addi	a3,a3,1184 # ffffffffc0201ed8 <commands+0x510>
ffffffffc0200a40:	00001617          	auipc	a2,0x1
ffffffffc0200a44:	4a060613          	addi	a2,a2,1184 # ffffffffc0201ee0 <commands+0x518>
ffffffffc0200a48:	04100593          	li	a1,65
ffffffffc0200a4c:	00001517          	auipc	a0,0x1
ffffffffc0200a50:	4ac50513          	addi	a0,a0,1196 # ffffffffc0201ef8 <commands+0x530>
ffffffffc0200a54:	959ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200a58 <buddy_system_alloc_pages>:
static struct Page *buddy_system_alloc_pages(size_t n) {
ffffffffc0200a58:	1141                	addi	sp,sp,-16
ffffffffc0200a5a:	e406                	sd	ra,8(sp)
ffffffffc0200a5c:	e022                	sd	s0,0(sp)
    assert(n > 0);
ffffffffc0200a5e:	14050863          	beqz	a0,ffffffffc0200bae <buddy_system_alloc_pages+0x156>
    unsigned int size = n;
ffffffffc0200a62:	0005069b          	sext.w	a3,a0
    return (n & (n - 1)) == 0;
ffffffffc0200a66:	fff5079b          	addiw	a5,a0,-1
ffffffffc0200a6a:	8ff5                	and	a5,a5,a3
    if (!is_power_of_two(size)) {
ffffffffc0200a6c:	2781                	sext.w	a5,a5
ffffffffc0200a6e:	862a                	mv	a2,a0
ffffffffc0200a70:	10079863          	bnez	a5,ffffffffc0200b80 <buddy_system_alloc_pages+0x128>
    if (buddy_tree[index] < size) {
ffffffffc0200a74:	00006817          	auipc	a6,0x6
ffffffffc0200a78:	9cc83803          	ld	a6,-1588(a6) # ffffffffc0206440 <buddy_tree>
ffffffffc0200a7c:	00082783          	lw	a5,0(a6)
ffffffffc0200a80:	10d7eb63          	bltu	a5,a3,ffffffffc0200b96 <buddy_system_alloc_pages+0x13e>
    for (node_size = total_pages; node_size != size; node_size /= 2) {
ffffffffc0200a84:	00006517          	auipc	a0,0x6
ffffffffc0200a88:	9c450513          	addi	a0,a0,-1596 # ffffffffc0206448 <total_pages>
ffffffffc0200a8c:	410c                	lw	a1,0(a0)
ffffffffc0200a8e:	10b68a63          	beq	a3,a1,ffffffffc0200ba2 <buddy_system_alloc_pages+0x14a>
    unsigned int index = 0;
ffffffffc0200a92:	4781                	li	a5,0
        if (buddy_tree[left_child(index)] >= size) {
ffffffffc0200a94:	0017989b          	slliw	a7,a5,0x1
ffffffffc0200a98:	0018879b          	addiw	a5,a7,1
ffffffffc0200a9c:	02079413          	slli	s0,a5,0x20
ffffffffc0200aa0:	01e45713          	srli	a4,s0,0x1e
ffffffffc0200aa4:	9742                	add	a4,a4,a6
ffffffffc0200aa6:	4318                	lw	a4,0(a4)
ffffffffc0200aa8:	00d77463          	bgeu	a4,a3,ffffffffc0200ab0 <buddy_system_alloc_pages+0x58>
            index = right_child(index);
ffffffffc0200aac:	0028879b          	addiw	a5,a7,2
    for (node_size = total_pages; node_size != size; node_size /= 2) {
ffffffffc0200ab0:	0015d59b          	srliw	a1,a1,0x1
ffffffffc0200ab4:	feb690e3          	bne	a3,a1,ffffffffc0200a94 <buddy_system_alloc_pages+0x3c>
    offset = (index + 1) * node_size - total_pages;
ffffffffc0200ab8:	0017841b          	addiw	s0,a5,1
ffffffffc0200abc:	02d4043b          	mulw	s0,s0,a3
    buddy_tree[index] = 0;
ffffffffc0200ac0:	02079593          	slli	a1,a5,0x20
ffffffffc0200ac4:	01e5d713          	srli	a4,a1,0x1e
ffffffffc0200ac8:	9742                	add	a4,a4,a6
ffffffffc0200aca:	00072023          	sw	zero,0(a4)
    offset = (index + 1) * node_size - total_pages;
ffffffffc0200ace:	4118                	lw	a4,0(a0)
ffffffffc0200ad0:	9c19                	subw	s0,s0,a4
    while (index) {
ffffffffc0200ad2:	c3b9                	beqz	a5,ffffffffc0200b18 <buddy_system_alloc_pages+0xc0>
        index = parent(index);
ffffffffc0200ad4:	37fd                	addiw	a5,a5,-1
        buddy_tree[index] = (buddy_tree[left_child(index)] > buddy_tree[right_child(index)]) ?
ffffffffc0200ad6:	ffe7f713          	andi	a4,a5,-2
ffffffffc0200ada:	ffe7f593          	andi	a1,a5,-2
ffffffffc0200ade:	2709                	addiw	a4,a4,2
ffffffffc0200ae0:	2585                	addiw	a1,a1,1
ffffffffc0200ae2:	1702                	slli	a4,a4,0x20
ffffffffc0200ae4:	02059513          	slli	a0,a1,0x20
ffffffffc0200ae8:	9301                	srli	a4,a4,0x20
ffffffffc0200aea:	01e55593          	srli	a1,a0,0x1e
ffffffffc0200aee:	070a                	slli	a4,a4,0x2
ffffffffc0200af0:	9742                	add	a4,a4,a6
ffffffffc0200af2:	95c2                	add	a1,a1,a6
                            buddy_tree[left_child(index)] : buddy_tree[right_child(index)];
ffffffffc0200af4:	0005a883          	lw	a7,0(a1)
ffffffffc0200af8:	430c                	lw	a1,0(a4)
        buddy_tree[index] = (buddy_tree[left_child(index)] > buddy_tree[right_child(index)]) ?
ffffffffc0200afa:	0017d71b          	srliw	a4,a5,0x1
ffffffffc0200afe:	070a                	slli	a4,a4,0x2
                            buddy_tree[left_child(index)] : buddy_tree[right_child(index)];
ffffffffc0200b00:	0005851b          	sext.w	a0,a1
ffffffffc0200b04:	0008831b          	sext.w	t1,a7
        index = parent(index);
ffffffffc0200b08:	0017d79b          	srliw	a5,a5,0x1
        buddy_tree[index] = (buddy_tree[left_child(index)] > buddy_tree[right_child(index)]) ?
ffffffffc0200b0c:	9742                	add	a4,a4,a6
                            buddy_tree[left_child(index)] : buddy_tree[right_child(index)];
ffffffffc0200b0e:	00657363          	bgeu	a0,t1,ffffffffc0200b14 <buddy_system_alloc_pages+0xbc>
ffffffffc0200b12:	85c6                	mv	a1,a7
        buddy_tree[index] = (buddy_tree[left_child(index)] > buddy_tree[right_child(index)]) ?
ffffffffc0200b14:	c30c                	sw	a1,0(a4)
    while (index) {
ffffffffc0200b16:	ffdd                	bnez	a5,ffffffffc0200ad4 <buddy_system_alloc_pages+0x7c>
    page = base_page + offset;
ffffffffc0200b18:	02041793          	slli	a5,s0,0x20
ffffffffc0200b1c:	9381                	srli	a5,a5,0x20
    for (struct Page *p = page; p < page + size; p++) {
ffffffffc0200b1e:	02069593          	slli	a1,a3,0x20
ffffffffc0200b22:	9181                	srli	a1,a1,0x20
    page = base_page + offset;
ffffffffc0200b24:	00279413          	slli	s0,a5,0x2
ffffffffc0200b28:	97a2                	add	a5,a5,s0
    for (struct Page *p = page; p < page + size; p++) {
ffffffffc0200b2a:	00259713          	slli	a4,a1,0x2
    page = base_page + offset;
ffffffffc0200b2e:	078e                	slli	a5,a5,0x3
    for (struct Page *p = page; p < page + size; p++) {
ffffffffc0200b30:	972e                	add	a4,a4,a1
    page = base_page + offset;
ffffffffc0200b32:	00006417          	auipc	s0,0x6
ffffffffc0200b36:	90643403          	ld	s0,-1786(s0) # ffffffffc0206438 <base_page>
ffffffffc0200b3a:	943e                	add	s0,s0,a5
    for (struct Page *p = page; p < page + size; p++) {
ffffffffc0200b3c:	070e                	slli	a4,a4,0x3
    page->property = size;
ffffffffc0200b3e:	c814                	sw	a3,16(s0)
    for (struct Page *p = page; p < page + size; p++) {
ffffffffc0200b40:	9722                	add	a4,a4,s0
ffffffffc0200b42:	87a2                	mv	a5,s0
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200b44:	55f5                	li	a1,-3
ffffffffc0200b46:	00e47a63          	bgeu	s0,a4,ffffffffc0200b5a <buddy_system_alloc_pages+0x102>
ffffffffc0200b4a:	00878513          	addi	a0,a5,8
ffffffffc0200b4e:	60b5302f          	amoand.d	zero,a1,(a0)
ffffffffc0200b52:	02878793          	addi	a5,a5,40
ffffffffc0200b56:	fee7eae3          	bltu	a5,a4,ffffffffc0200b4a <buddy_system_alloc_pages+0xf2>
    nr_free -= size;
ffffffffc0200b5a:	00005717          	auipc	a4,0x5
ffffffffc0200b5e:	4b670713          	addi	a4,a4,1206 # ffffffffc0206010 <free_area>
ffffffffc0200b62:	4b1c                	lw	a5,16(a4)
    cprintf("Allocated page address: %p, Requested size: %d, Allocated size: %d\n", page, n, size);
ffffffffc0200b64:	85a2                	mv	a1,s0
ffffffffc0200b66:	00001517          	auipc	a0,0x1
ffffffffc0200b6a:	45a50513          	addi	a0,a0,1114 # ffffffffc0201fc0 <commands+0x5f8>
    nr_free -= size;
ffffffffc0200b6e:	9f95                	subw	a5,a5,a3
ffffffffc0200b70:	cb1c                	sw	a5,16(a4)
    cprintf("Allocated page address: %p, Requested size: %d, Allocated size: %d\n", page, n, size);
ffffffffc0200b72:	d40ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
}
ffffffffc0200b76:	60a2                	ld	ra,8(sp)
ffffffffc0200b78:	8522                	mv	a0,s0
ffffffffc0200b7a:	6402                	ld	s0,0(sp)
ffffffffc0200b7c:	0141                	addi	sp,sp,16
ffffffffc0200b7e:	8082                	ret
        size = ceil_to_power_of_two(size);
ffffffffc0200b80:	02051793          	slli	a5,a0,0x20
ffffffffc0200b84:	9381                	srli	a5,a5,0x20
    size_t result = 1;
ffffffffc0200b86:	4685                	li	a3,1
        while (n) {
ffffffffc0200b88:	ee0786e3          	beqz	a5,ffffffffc0200a74 <buddy_system_alloc_pages+0x1c>
            n >>= 1;
ffffffffc0200b8c:	8385                	srli	a5,a5,0x1
            result <<= 1;
ffffffffc0200b8e:	0686                	slli	a3,a3,0x1
        while (n) {
ffffffffc0200b90:	fff5                	bnez	a5,ffffffffc0200b8c <buddy_system_alloc_pages+0x134>
        size = ceil_to_power_of_two(size);
ffffffffc0200b92:	2681                	sext.w	a3,a3
ffffffffc0200b94:	b5c5                	j	ffffffffc0200a74 <buddy_system_alloc_pages+0x1c>
        return NULL;
ffffffffc0200b96:	4401                	li	s0,0
}
ffffffffc0200b98:	60a2                	ld	ra,8(sp)
ffffffffc0200b9a:	8522                	mv	a0,s0
ffffffffc0200b9c:	6402                	ld	s0,0(sp)
ffffffffc0200b9e:	0141                	addi	sp,sp,16
ffffffffc0200ba0:	8082                	ret
    buddy_tree[index] = 0;
ffffffffc0200ba2:	00082023          	sw	zero,0(a6)
    offset = (index + 1) * node_size - total_pages;
ffffffffc0200ba6:	411c                	lw	a5,0(a0)
ffffffffc0200ba8:	40f6843b          	subw	s0,a3,a5
    while (index) {
ffffffffc0200bac:	b7b5                	j	ffffffffc0200b18 <buddy_system_alloc_pages+0xc0>
    assert(n > 0);
ffffffffc0200bae:	00001697          	auipc	a3,0x1
ffffffffc0200bb2:	32a68693          	addi	a3,a3,810 # ffffffffc0201ed8 <commands+0x510>
ffffffffc0200bb6:	00001617          	auipc	a2,0x1
ffffffffc0200bba:	32a60613          	addi	a2,a2,810 # ffffffffc0201ee0 <commands+0x518>
ffffffffc0200bbe:	06500593          	li	a1,101
ffffffffc0200bc2:	00001517          	auipc	a0,0x1
ffffffffc0200bc6:	33650513          	addi	a0,a0,822 # ffffffffc0201ef8 <commands+0x530>
ffffffffc0200bca:	fe2ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200bce <is_initial_state.isra.0>:
    for (int i = 0; i < tree_size; i++) {
ffffffffc0200bce:	00006897          	auipc	a7,0x6
ffffffffc0200bd2:	87e8a883          	lw	a7,-1922(a7) # ffffffffc020644c <tree_size>
    int node_size = total_pages;
ffffffffc0200bd6:	00006597          	auipc	a1,0x6
ffffffffc0200bda:	8725a583          	lw	a1,-1934(a1) # ffffffffc0206448 <total_pages>
    for (int i = 0; i < tree_size; i++) {
ffffffffc0200bde:	07105263          	blez	a7,ffffffffc0200c42 <is_initial_state.isra.0+0x74>
ffffffffc0200be2:	00006617          	auipc	a2,0x6
ffffffffc0200be6:	85e63603          	ld	a2,-1954(a2) # ffffffffc0206440 <buddy_tree>
ffffffffc0200bea:	4781                	li	a5,0
        if (buddy_tree[i] != node_size) {
ffffffffc0200bec:	4208                	lw	a0,0(a2)
    return (n & (n - 1)) == 0;
ffffffffc0200bee:	0027871b          	addiw	a4,a5,2
    for (int i = 0; i < tree_size; i++) {
ffffffffc0200bf2:	2785                	addiw	a5,a5,1
            node_size /= 2;
ffffffffc0200bf4:	01f5d69b          	srliw	a3,a1,0x1f
    return (n & (n - 1)) == 0;
ffffffffc0200bf8:	8f7d                	and	a4,a4,a5
ffffffffc0200bfa:	0005881b          	sext.w	a6,a1
            node_size /= 2;
ffffffffc0200bfe:	9ead                	addw	a3,a3,a1
        if (i != 0 && is_power_of_two(i + 1)) {
ffffffffc0200c00:	2701                	sext.w	a4,a4
        if (buddy_tree[i] != node_size) {
ffffffffc0200c02:	03051563          	bne	a0,a6,ffffffffc0200c2c <is_initial_state.isra.0+0x5e>
    for (int i = 0; i < tree_size; i++) {
ffffffffc0200c06:	03178e63          	beq	a5,a7,ffffffffc0200c42 <is_initial_state.isra.0+0x74>
        if (i != 0 && is_power_of_two(i + 1)) {
ffffffffc0200c0a:	e709                	bnez	a4,ffffffffc0200c14 <is_initial_state.isra.0+0x46>
            node_size /= 2;
ffffffffc0200c0c:	4016d59b          	sraiw	a1,a3,0x1
ffffffffc0200c10:	0005881b          	sext.w	a6,a1
        if (buddy_tree[i] != node_size) {
ffffffffc0200c14:	4248                	lw	a0,4(a2)
    return (n & (n - 1)) == 0;
ffffffffc0200c16:	0027871b          	addiw	a4,a5,2
    for (int i = 0; i < tree_size; i++) {
ffffffffc0200c1a:	2785                	addiw	a5,a5,1
            node_size /= 2;
ffffffffc0200c1c:	01f5d69b          	srliw	a3,a1,0x1f
    return (n & (n - 1)) == 0;
ffffffffc0200c20:	8f7d                	and	a4,a4,a5
ffffffffc0200c22:	0611                	addi	a2,a2,4
            node_size /= 2;
ffffffffc0200c24:	9ead                	addw	a3,a3,a1
        if (i != 0 && is_power_of_two(i + 1)) {
ffffffffc0200c26:	2701                	sext.w	a4,a4
        if (buddy_tree[i] != node_size) {
ffffffffc0200c28:	fd050fe3          	beq	a0,a6,ffffffffc0200c06 <is_initial_state.isra.0+0x38>
static int is_initial_state(void) {
ffffffffc0200c2c:	1141                	addi	sp,sp,-16
            cprintf("Buddy tree is not in initial state.\n");
ffffffffc0200c2e:	00001517          	auipc	a0,0x1
ffffffffc0200c32:	3da50513          	addi	a0,a0,986 # ffffffffc0202008 <commands+0x640>
static int is_initial_state(void) {
ffffffffc0200c36:	e406                	sd	ra,8(sp)
            cprintf("Buddy tree is not in initial state.\n");
ffffffffc0200c38:	c7aff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
}
ffffffffc0200c3c:	60a2                	ld	ra,8(sp)
ffffffffc0200c3e:	0141                	addi	sp,sp,16
            simplified_print_tree();
ffffffffc0200c40:	bef9                	j	ffffffffc020081e <simplified_print_tree>
    cprintf("Buddy tree is in initial state.\n");
ffffffffc0200c42:	00001517          	auipc	a0,0x1
ffffffffc0200c46:	3ee50513          	addi	a0,a0,1006 # ffffffffc0202030 <commands+0x668>
ffffffffc0200c4a:	c68ff06f          	j	ffffffffc02000b2 <cprintf>

ffffffffc0200c4e <buddy_check>:

// 检查buddy_tree的功能
static void buddy_check(void) {
ffffffffc0200c4e:	7179                	addi	sp,sp,-48
    cprintf("\n-----------------Buddy Check Begins!------------------\n\n");
ffffffffc0200c50:	00001517          	auipc	a0,0x1
ffffffffc0200c54:	40850513          	addi	a0,a0,1032 # ffffffffc0202058 <commands+0x690>
static void buddy_check(void) {
ffffffffc0200c58:	f406                	sd	ra,40(sp)
ffffffffc0200c5a:	f022                	sd	s0,32(sp)
ffffffffc0200c5c:	ec26                	sd	s1,24(sp)
ffffffffc0200c5e:	e84a                	sd	s2,16(sp)
ffffffffc0200c60:	e44e                	sd	s3,8(sp)
    cprintf("\n-----------------Buddy Check Begins!------------------\n\n");
ffffffffc0200c62:	c50ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    simplified_print_tree();
ffffffffc0200c66:	bb9ff0ef          	jal	ra,ffffffffc020081e <simplified_print_tree>

    cprintf("\n---------------------First Check!---------------------\n\n");
ffffffffc0200c6a:	00001517          	auipc	a0,0x1
ffffffffc0200c6e:	42e50513          	addi	a0,a0,1070 # ffffffffc0202098 <commands+0x6d0>
ffffffffc0200c72:	c40ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200c76:	4505                	li	a0,1
ffffffffc0200c78:	392000ef          	jal	ra,ffffffffc020100a <alloc_pages>
ffffffffc0200c7c:	10050063          	beqz	a0,ffffffffc0200d7c <buddy_check+0x12e>
ffffffffc0200c80:	842a                	mv	s0,a0
    simplified_print_tree();
ffffffffc0200c82:	b9dff0ef          	jal	ra,ffffffffc020081e <simplified_print_tree>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200c86:	4505                	li	a0,1
ffffffffc0200c88:	382000ef          	jal	ra,ffffffffc020100a <alloc_pages>
ffffffffc0200c8c:	892a                	mv	s2,a0
ffffffffc0200c8e:	1c050763          	beqz	a0,ffffffffc0200e5c <buddy_check+0x20e>
    simplified_print_tree();
ffffffffc0200c92:	b8dff0ef          	jal	ra,ffffffffc020081e <simplified_print_tree>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c96:	4505                	li	a0,1
ffffffffc0200c98:	372000ef          	jal	ra,ffffffffc020100a <alloc_pages>
ffffffffc0200c9c:	84aa                	mv	s1,a0
ffffffffc0200c9e:	18050f63          	beqz	a0,ffffffffc0200e3c <buddy_check+0x1ee>
    simplified_print_tree();
ffffffffc0200ca2:	b7dff0ef          	jal	ra,ffffffffc020081e <simplified_print_tree>
    free_page(p0);
ffffffffc0200ca6:	8522                	mv	a0,s0
ffffffffc0200ca8:	4585                	li	a1,1
ffffffffc0200caa:	39e000ef          	jal	ra,ffffffffc0201048 <free_pages>
    simplified_print_tree();
ffffffffc0200cae:	b71ff0ef          	jal	ra,ffffffffc020081e <simplified_print_tree>
    free_page(p1);
ffffffffc0200cb2:	4585                	li	a1,1
ffffffffc0200cb4:	854a                	mv	a0,s2
ffffffffc0200cb6:	392000ef          	jal	ra,ffffffffc0201048 <free_pages>
    simplified_print_tree();
ffffffffc0200cba:	b65ff0ef          	jal	ra,ffffffffc020081e <simplified_print_tree>
    free_page(p2);
ffffffffc0200cbe:	4585                	li	a1,1
ffffffffc0200cc0:	8526                	mv	a0,s1
ffffffffc0200cc2:	386000ef          	jal	ra,ffffffffc0201048 <free_pages>
    is_initial_state();
ffffffffc0200cc6:	f09ff0ef          	jal	ra,ffffffffc0200bce <is_initial_state.isra.0>

    cprintf("\n---------------------Second Check!---------------------\n\n");
ffffffffc0200cca:	00001517          	auipc	a0,0x1
ffffffffc0200cce:	46e50513          	addi	a0,a0,1134 # ffffffffc0202138 <commands+0x770>
ffffffffc0200cd2:	be0ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    struct Page *A, *B, *C, *D, *E;
    A = B = C = D = E = NULL;
    assert((A = alloc_pages(100)) != NULL);
ffffffffc0200cd6:	06400513          	li	a0,100
ffffffffc0200cda:	330000ef          	jal	ra,ffffffffc020100a <alloc_pages>
ffffffffc0200cde:	842a                	mv	s0,a0
ffffffffc0200ce0:	12050e63          	beqz	a0,ffffffffc0200e1c <buddy_check+0x1ce>
    simplified_print_tree();
ffffffffc0200ce4:	b3bff0ef          	jal	ra,ffffffffc020081e <simplified_print_tree>
    assert((B = alloc_pages(240)) != NULL);
ffffffffc0200ce8:	0f000513          	li	a0,240
ffffffffc0200cec:	31e000ef          	jal	ra,ffffffffc020100a <alloc_pages>
ffffffffc0200cf0:	84aa                	mv	s1,a0
ffffffffc0200cf2:	10050563          	beqz	a0,ffffffffc0200dfc <buddy_check+0x1ae>
    simplified_print_tree();
ffffffffc0200cf6:	b29ff0ef          	jal	ra,ffffffffc020081e <simplified_print_tree>
    assert((C = alloc_pages(64)) != NULL);
ffffffffc0200cfa:	04000513          	li	a0,64
ffffffffc0200cfe:	30c000ef          	jal	ra,ffffffffc020100a <alloc_pages>
ffffffffc0200d02:	892a                	mv	s2,a0
ffffffffc0200d04:	0c050c63          	beqz	a0,ffffffffc0200ddc <buddy_check+0x18e>
    simplified_print_tree();
ffffffffc0200d08:	b17ff0ef          	jal	ra,ffffffffc020081e <simplified_print_tree>
    assert((D = alloc_pages(253)) != NULL);
ffffffffc0200d0c:	0fd00513          	li	a0,253
ffffffffc0200d10:	2fa000ef          	jal	ra,ffffffffc020100a <alloc_pages>
ffffffffc0200d14:	89aa                	mv	s3,a0
ffffffffc0200d16:	c15d                	beqz	a0,ffffffffc0200dbc <buddy_check+0x16e>
    simplified_print_tree();
ffffffffc0200d18:	b07ff0ef          	jal	ra,ffffffffc020081e <simplified_print_tree>
    free_pages(B, 240);
ffffffffc0200d1c:	0f000593          	li	a1,240
ffffffffc0200d20:	8526                	mv	a0,s1
ffffffffc0200d22:	326000ef          	jal	ra,ffffffffc0201048 <free_pages>
    simplified_print_tree();
ffffffffc0200d26:	af9ff0ef          	jal	ra,ffffffffc020081e <simplified_print_tree>
    free_pages(A, 100);
ffffffffc0200d2a:	8522                	mv	a0,s0
ffffffffc0200d2c:	06400593          	li	a1,100
ffffffffc0200d30:	318000ef          	jal	ra,ffffffffc0201048 <free_pages>
    simplified_print_tree();
ffffffffc0200d34:	aebff0ef          	jal	ra,ffffffffc020081e <simplified_print_tree>
    assert((E = alloc_pages(75)) != NULL);
ffffffffc0200d38:	04b00513          	li	a0,75
ffffffffc0200d3c:	2ce000ef          	jal	ra,ffffffffc020100a <alloc_pages>
ffffffffc0200d40:	842a                	mv	s0,a0
ffffffffc0200d42:	cd29                	beqz	a0,ffffffffc0200d9c <buddy_check+0x14e>
    simplified_print_tree();
ffffffffc0200d44:	adbff0ef          	jal	ra,ffffffffc020081e <simplified_print_tree>
    free_pages(C, 64);
ffffffffc0200d48:	854a                	mv	a0,s2
ffffffffc0200d4a:	04000593          	li	a1,64
ffffffffc0200d4e:	2fa000ef          	jal	ra,ffffffffc0201048 <free_pages>
    simplified_print_tree();
ffffffffc0200d52:	acdff0ef          	jal	ra,ffffffffc020081e <simplified_print_tree>
    free_pages(E, 75);
ffffffffc0200d56:	8522                	mv	a0,s0
ffffffffc0200d58:	04b00593          	li	a1,75
ffffffffc0200d5c:	2ec000ef          	jal	ra,ffffffffc0201048 <free_pages>
    simplified_print_tree();
ffffffffc0200d60:	abfff0ef          	jal	ra,ffffffffc020081e <simplified_print_tree>
    free_pages(D, 253);
ffffffffc0200d64:	854e                	mv	a0,s3
ffffffffc0200d66:	0fd00593          	li	a1,253
ffffffffc0200d6a:	2de000ef          	jal	ra,ffffffffc0201048 <free_pages>
    is_initial_state();
}
ffffffffc0200d6e:	7402                	ld	s0,32(sp)
ffffffffc0200d70:	70a2                	ld	ra,40(sp)
ffffffffc0200d72:	64e2                	ld	s1,24(sp)
ffffffffc0200d74:	6942                	ld	s2,16(sp)
ffffffffc0200d76:	69a2                	ld	s3,8(sp)
ffffffffc0200d78:	6145                	addi	sp,sp,48
    is_initial_state();
ffffffffc0200d7a:	bd91                	j	ffffffffc0200bce <is_initial_state.isra.0>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200d7c:	00001697          	auipc	a3,0x1
ffffffffc0200d80:	35c68693          	addi	a3,a3,860 # ffffffffc02020d8 <commands+0x710>
ffffffffc0200d84:	00001617          	auipc	a2,0x1
ffffffffc0200d88:	15c60613          	addi	a2,a2,348 # ffffffffc0201ee0 <commands+0x518>
ffffffffc0200d8c:	0f900593          	li	a1,249
ffffffffc0200d90:	00001517          	auipc	a0,0x1
ffffffffc0200d94:	16850513          	addi	a0,a0,360 # ffffffffc0201ef8 <commands+0x530>
ffffffffc0200d98:	e14ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((E = alloc_pages(75)) != NULL);
ffffffffc0200d9c:	00001697          	auipc	a3,0x1
ffffffffc0200da0:	45c68693          	addi	a3,a3,1116 # ffffffffc02021f8 <commands+0x830>
ffffffffc0200da4:	00001617          	auipc	a2,0x1
ffffffffc0200da8:	13c60613          	addi	a2,a2,316 # ffffffffc0201ee0 <commands+0x518>
ffffffffc0200dac:	11500593          	li	a1,277
ffffffffc0200db0:	00001517          	auipc	a0,0x1
ffffffffc0200db4:	14850513          	addi	a0,a0,328 # ffffffffc0201ef8 <commands+0x530>
ffffffffc0200db8:	df4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((D = alloc_pages(253)) != NULL);
ffffffffc0200dbc:	00001697          	auipc	a3,0x1
ffffffffc0200dc0:	41c68693          	addi	a3,a3,1052 # ffffffffc02021d8 <commands+0x810>
ffffffffc0200dc4:	00001617          	auipc	a2,0x1
ffffffffc0200dc8:	11c60613          	addi	a2,a2,284 # ffffffffc0201ee0 <commands+0x518>
ffffffffc0200dcc:	10f00593          	li	a1,271
ffffffffc0200dd0:	00001517          	auipc	a0,0x1
ffffffffc0200dd4:	12850513          	addi	a0,a0,296 # ffffffffc0201ef8 <commands+0x530>
ffffffffc0200dd8:	dd4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((C = alloc_pages(64)) != NULL);
ffffffffc0200ddc:	00001697          	auipc	a3,0x1
ffffffffc0200de0:	3dc68693          	addi	a3,a3,988 # ffffffffc02021b8 <commands+0x7f0>
ffffffffc0200de4:	00001617          	auipc	a2,0x1
ffffffffc0200de8:	0fc60613          	addi	a2,a2,252 # ffffffffc0201ee0 <commands+0x518>
ffffffffc0200dec:	10d00593          	li	a1,269
ffffffffc0200df0:	00001517          	auipc	a0,0x1
ffffffffc0200df4:	10850513          	addi	a0,a0,264 # ffffffffc0201ef8 <commands+0x530>
ffffffffc0200df8:	db4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((B = alloc_pages(240)) != NULL);
ffffffffc0200dfc:	00001697          	auipc	a3,0x1
ffffffffc0200e00:	39c68693          	addi	a3,a3,924 # ffffffffc0202198 <commands+0x7d0>
ffffffffc0200e04:	00001617          	auipc	a2,0x1
ffffffffc0200e08:	0dc60613          	addi	a2,a2,220 # ffffffffc0201ee0 <commands+0x518>
ffffffffc0200e0c:	10b00593          	li	a1,267
ffffffffc0200e10:	00001517          	auipc	a0,0x1
ffffffffc0200e14:	0e850513          	addi	a0,a0,232 # ffffffffc0201ef8 <commands+0x530>
ffffffffc0200e18:	d94ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((A = alloc_pages(100)) != NULL);
ffffffffc0200e1c:	00001697          	auipc	a3,0x1
ffffffffc0200e20:	35c68693          	addi	a3,a3,860 # ffffffffc0202178 <commands+0x7b0>
ffffffffc0200e24:	00001617          	auipc	a2,0x1
ffffffffc0200e28:	0bc60613          	addi	a2,a2,188 # ffffffffc0201ee0 <commands+0x518>
ffffffffc0200e2c:	10900593          	li	a1,265
ffffffffc0200e30:	00001517          	auipc	a0,0x1
ffffffffc0200e34:	0c850513          	addi	a0,a0,200 # ffffffffc0201ef8 <commands+0x530>
ffffffffc0200e38:	d74ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200e3c:	00001697          	auipc	a3,0x1
ffffffffc0200e40:	2dc68693          	addi	a3,a3,732 # ffffffffc0202118 <commands+0x750>
ffffffffc0200e44:	00001617          	auipc	a2,0x1
ffffffffc0200e48:	09c60613          	addi	a2,a2,156 # ffffffffc0201ee0 <commands+0x518>
ffffffffc0200e4c:	0fd00593          	li	a1,253
ffffffffc0200e50:	00001517          	auipc	a0,0x1
ffffffffc0200e54:	0a850513          	addi	a0,a0,168 # ffffffffc0201ef8 <commands+0x530>
ffffffffc0200e58:	d54ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200e5c:	00001697          	auipc	a3,0x1
ffffffffc0200e60:	29c68693          	addi	a3,a3,668 # ffffffffc02020f8 <commands+0x730>
ffffffffc0200e64:	00001617          	auipc	a2,0x1
ffffffffc0200e68:	07c60613          	addi	a2,a2,124 # ffffffffc0201ee0 <commands+0x518>
ffffffffc0200e6c:	0fb00593          	li	a1,251
ffffffffc0200e70:	00001517          	auipc	a0,0x1
ffffffffc0200e74:	08850513          	addi	a0,a0,136 # ffffffffc0201ef8 <commands+0x530>
ffffffffc0200e78:	d34ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200e7c <buddy_system_free_pages>:
    if (!is_power_of_two(n)) {
ffffffffc0200e7c:	0005869b          	sext.w	a3,a1
    return (n & (n - 1)) == 0;
ffffffffc0200e80:	fff5879b          	addiw	a5,a1,-1
static void buddy_system_free_pages(struct Page *free_page, size_t n) {
ffffffffc0200e84:	1141                	addi	sp,sp,-16
    return (n & (n - 1)) == 0;
ffffffffc0200e86:	8ff5                	and	a5,a5,a3
static void buddy_system_free_pages(struct Page *free_page, size_t n) {
ffffffffc0200e88:	e022                	sd	s0,0(sp)
ffffffffc0200e8a:	e406                	sd	ra,8(sp)
    if (!is_power_of_two(n)) {
ffffffffc0200e8c:	2781                	sext.w	a5,a5
static void buddy_system_free_pages(struct Page *free_page, size_t n) {
ffffffffc0200e8e:	862e                	mv	a2,a1
ffffffffc0200e90:	842a                	mv	s0,a0
ffffffffc0200e92:	882e                	mv	a6,a1
    if (!is_power_of_two(n)) {
ffffffffc0200e94:	10079963          	bnez	a5,ffffffffc0200fa6 <buddy_system_free_pages+0x12a>
    assert(size > 0);
ffffffffc0200e98:	14068963          	beqz	a3,ffffffffc0200fea <buddy_system_free_pages+0x16e>
    for (; page != free_page + size; page++) {
ffffffffc0200e9c:	02081793          	slli	a5,a6,0x20
ffffffffc0200ea0:	9381                	srli	a5,a5,0x20
ffffffffc0200ea2:	00279813          	slli	a6,a5,0x2
ffffffffc0200ea6:	983e                	add	a6,a6,a5
ffffffffc0200ea8:	080e                	slli	a6,a6,0x3
ffffffffc0200eaa:	9822                	add	a6,a6,s0
ffffffffc0200eac:	03040363          	beq	s0,a6,ffffffffc0200ed2 <buddy_system_free_pages+0x56>
ffffffffc0200eb0:	87a2                	mv	a5,s0
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200eb2:	6798                	ld	a4,8(a5)
        assert(!PageReserved(page) && !PageProperty(page));
ffffffffc0200eb4:	8b05                	andi	a4,a4,1
ffffffffc0200eb6:	10071a63          	bnez	a4,ffffffffc0200fca <buddy_system_free_pages+0x14e>
ffffffffc0200eba:	6798                	ld	a4,8(a5)
ffffffffc0200ebc:	8b09                	andi	a4,a4,2
ffffffffc0200ebe:	10071663          	bnez	a4,ffffffffc0200fca <buddy_system_free_pages+0x14e>
        page->flags = 0;
ffffffffc0200ec2:	0007b423          	sd	zero,8(a5)
ffffffffc0200ec6:	0007a023          	sw	zero,0(a5)
    for (; page != free_page + size; page++) {
ffffffffc0200eca:	02878793          	addi	a5,a5,40
ffffffffc0200ece:	ff0792e3          	bne	a5,a6,ffffffffc0200eb2 <buddy_system_free_pages+0x36>
    nr_free += size;
ffffffffc0200ed2:	00005717          	auipc	a4,0x5
ffffffffc0200ed6:	13e70713          	addi	a4,a4,318 # ffffffffc0206010 <free_area>
ffffffffc0200eda:	4b1c                	lw	a5,16(a4)
    cprintf("Freed page address: %p, Requested size: %d, Freed size: %d\n", free_page, n, size);
ffffffffc0200edc:	85a2                	mv	a1,s0
ffffffffc0200ede:	00001517          	auipc	a0,0x1
ffffffffc0200ee2:	33a50513          	addi	a0,a0,826 # ffffffffc0202218 <commands+0x850>
    nr_free += size;
ffffffffc0200ee6:	9fb5                	addw	a5,a5,a3
ffffffffc0200ee8:	cb1c                	sw	a5,16(a4)
    cprintf("Freed page address: %p, Requested size: %d, Freed size: %d\n", free_page, n, size);
ffffffffc0200eea:	9c8ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    unsigned int offset = free_page - base_page;
ffffffffc0200eee:	00005797          	auipc	a5,0x5
ffffffffc0200ef2:	54a7b783          	ld	a5,1354(a5) # ffffffffc0206438 <base_page>
ffffffffc0200ef6:	40f407b3          	sub	a5,s0,a5
ffffffffc0200efa:	878d                	srai	a5,a5,0x3
ffffffffc0200efc:	00001717          	auipc	a4,0x1
ffffffffc0200f00:	76473703          	ld	a4,1892(a4) # ffffffffc0202660 <error_string+0x38>
ffffffffc0200f04:	02e78733          	mul	a4,a5,a4
    unsigned int index = offset + total_pages - 1;
ffffffffc0200f08:	00005797          	auipc	a5,0x5
ffffffffc0200f0c:	5407a783          	lw	a5,1344(a5) # ffffffffc0206448 <total_pages>
ffffffffc0200f10:	37fd                	addiw	a5,a5,-1
    while (buddy_tree[index]) {
ffffffffc0200f12:	00005517          	auipc	a0,0x5
ffffffffc0200f16:	52e53503          	ld	a0,1326(a0) # ffffffffc0206440 <buddy_tree>
    unsigned int node_size = 1;
ffffffffc0200f1a:	4585                	li	a1,1
    unsigned int index = offset + total_pages - 1;
ffffffffc0200f1c:	9fb9                	addw	a5,a5,a4
    while (buddy_tree[index]) {
ffffffffc0200f1e:	02079693          	slli	a3,a5,0x20
ffffffffc0200f22:	01e6d713          	srli	a4,a3,0x1e
ffffffffc0200f26:	972a                	add	a4,a4,a0
ffffffffc0200f28:	4314                	lw	a3,0(a4)
ffffffffc0200f2a:	c285                	beqz	a3,ffffffffc0200f4a <buddy_system_free_pages+0xce>
        node_size *= 2;
ffffffffc0200f2c:	4589                	li	a1,2
        if (index == 0) break;
ffffffffc0200f2e:	e789                	bnez	a5,ffffffffc0200f38 <buddy_system_free_pages+0xbc>
ffffffffc0200f30:	a061                	j	ffffffffc0200fb8 <buddy_system_free_pages+0x13c>
        node_size *= 2;
ffffffffc0200f32:	0015959b          	slliw	a1,a1,0x1
        if (index == 0) break;
ffffffffc0200f36:	c3c9                	beqz	a5,ffffffffc0200fb8 <buddy_system_free_pages+0x13c>
        index = parent(index);
ffffffffc0200f38:	37fd                	addiw	a5,a5,-1
    while (buddy_tree[index]) {
ffffffffc0200f3a:	0017d71b          	srliw	a4,a5,0x1
ffffffffc0200f3e:	070a                	slli	a4,a4,0x2
ffffffffc0200f40:	972a                	add	a4,a4,a0
ffffffffc0200f42:	4314                	lw	a3,0(a4)
        index = parent(index);
ffffffffc0200f44:	0017d79b          	srliw	a5,a5,0x1
    while (buddy_tree[index]) {
ffffffffc0200f48:	f6ed                	bnez	a3,ffffffffc0200f32 <buddy_system_free_pages+0xb6>
    buddy_tree[index] = node_size;
ffffffffc0200f4a:	c30c                	sw	a1,0(a4)
    while (index) {
ffffffffc0200f4c:	cba9                	beqz	a5,ffffffffc0200f9e <buddy_system_free_pages+0x122>
        index = parent(index);
ffffffffc0200f4e:	37fd                	addiw	a5,a5,-1
ffffffffc0200f50:	0017d69b          	srliw	a3,a5,0x1
        right_size = buddy_tree[right_child(index)];
ffffffffc0200f54:	0016871b          	addiw	a4,a3,1
        left_size = buddy_tree[left_child(index)];
ffffffffc0200f58:	ffe7f613          	andi	a2,a5,-2
        right_size = buddy_tree[right_child(index)];
ffffffffc0200f5c:	0017171b          	slliw	a4,a4,0x1
        left_size = buddy_tree[left_child(index)];
ffffffffc0200f60:	2605                	addiw	a2,a2,1
        right_size = buddy_tree[right_child(index)];
ffffffffc0200f62:	1702                	slli	a4,a4,0x20
ffffffffc0200f64:	9301                	srli	a4,a4,0x20
        left_size = buddy_tree[left_child(index)];
ffffffffc0200f66:	02061413          	slli	s0,a2,0x20
ffffffffc0200f6a:	01e45613          	srli	a2,s0,0x1e
        right_size = buddy_tree[right_child(index)];
ffffffffc0200f6e:	070a                	slli	a4,a4,0x2
        left_size = buddy_tree[left_child(index)];
ffffffffc0200f70:	962a                	add	a2,a2,a0
        right_size = buddy_tree[right_child(index)];
ffffffffc0200f72:	972a                	add	a4,a4,a0
        left_size = buddy_tree[left_child(index)];
ffffffffc0200f74:	4210                	lw	a2,0(a2)
        right_size = buddy_tree[right_child(index)];
ffffffffc0200f76:	4318                	lw	a4,0(a4)
            buddy_tree[index] = node_size;
ffffffffc0200f78:	1682                	slli	a3,a3,0x20
        node_size *= 2;
ffffffffc0200f7a:	0015959b          	slliw	a1,a1,0x1
            buddy_tree[index] = node_size;
ffffffffc0200f7e:	82f9                	srli	a3,a3,0x1e
        if (left_size + right_size == node_size) {
ffffffffc0200f80:	00e608bb          	addw	a7,a2,a4
        node_size *= 2;
ffffffffc0200f84:	882e                	mv	a6,a1
        index = parent(index);
ffffffffc0200f86:	0017d79b          	srliw	a5,a5,0x1
            buddy_tree[index] = node_size;
ffffffffc0200f8a:	96aa                	add	a3,a3,a0
        if (left_size + right_size == node_size) {
ffffffffc0200f8c:	00b88663          	beq	a7,a1,ffffffffc0200f98 <buddy_system_free_pages+0x11c>
            buddy_tree[index] = (left_size > right_size) ? left_size : right_size;
ffffffffc0200f90:	8832                	mv	a6,a2
ffffffffc0200f92:	00e67363          	bgeu	a2,a4,ffffffffc0200f98 <buddy_system_free_pages+0x11c>
ffffffffc0200f96:	883a                	mv	a6,a4
ffffffffc0200f98:	0106a023          	sw	a6,0(a3)
    while (index) {
ffffffffc0200f9c:	fbcd                	bnez	a5,ffffffffc0200f4e <buddy_system_free_pages+0xd2>
}
ffffffffc0200f9e:	60a2                	ld	ra,8(sp)
ffffffffc0200fa0:	6402                	ld	s0,0(sp)
ffffffffc0200fa2:	0141                	addi	sp,sp,16
ffffffffc0200fa4:	8082                	ret
        while (n) {
ffffffffc0200fa6:	cd91                	beqz	a1,ffffffffc0200fc2 <buddy_system_free_pages+0x146>
ffffffffc0200fa8:	87ae                	mv	a5,a1
    size_t result = 1;
ffffffffc0200faa:	4805                	li	a6,1
            n >>= 1;
ffffffffc0200fac:	8385                	srli	a5,a5,0x1
            result <<= 1;
ffffffffc0200fae:	0806                	slli	a6,a6,0x1
        while (n) {
ffffffffc0200fb0:	fff5                	bnez	a5,ffffffffc0200fac <buddy_system_free_pages+0x130>
    unsigned int size = ceil_to_power_of_two(n);
ffffffffc0200fb2:	0008069b          	sext.w	a3,a6
ffffffffc0200fb6:	b5cd                	j	ffffffffc0200e98 <buddy_system_free_pages+0x1c>
}
ffffffffc0200fb8:	60a2                	ld	ra,8(sp)
ffffffffc0200fba:	6402                	ld	s0,0(sp)
    buddy_tree[index] = node_size;
ffffffffc0200fbc:	c30c                	sw	a1,0(a4)
}
ffffffffc0200fbe:	0141                	addi	sp,sp,16
ffffffffc0200fc0:	8082                	ret
    unsigned int size = ceil_to_power_of_two(n);
ffffffffc0200fc2:	4685                	li	a3,1
ffffffffc0200fc4:	02850813          	addi	a6,a0,40
ffffffffc0200fc8:	b5e5                	j	ffffffffc0200eb0 <buddy_system_free_pages+0x34>
        assert(!PageReserved(page) && !PageProperty(page));
ffffffffc0200fca:	00001697          	auipc	a3,0x1
ffffffffc0200fce:	29e68693          	addi	a3,a3,670 # ffffffffc0202268 <commands+0x8a0>
ffffffffc0200fd2:	00001617          	auipc	a2,0x1
ffffffffc0200fd6:	f0e60613          	addi	a2,a2,-242 # ffffffffc0201ee0 <commands+0x518>
ffffffffc0200fda:	09b00593          	li	a1,155
ffffffffc0200fde:	00001517          	auipc	a0,0x1
ffffffffc0200fe2:	f1a50513          	addi	a0,a0,-230 # ffffffffc0201ef8 <commands+0x530>
ffffffffc0200fe6:	bc6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(size > 0);
ffffffffc0200fea:	00001697          	auipc	a3,0x1
ffffffffc0200fee:	26e68693          	addi	a3,a3,622 # ffffffffc0202258 <commands+0x890>
ffffffffc0200ff2:	00001617          	auipc	a2,0x1
ffffffffc0200ff6:	eee60613          	addi	a2,a2,-274 # ffffffffc0201ee0 <commands+0x518>
ffffffffc0200ffa:	09600593          	li	a1,150
ffffffffc0200ffe:	00001517          	auipc	a0,0x1
ffffffffc0201002:	efa50513          	addi	a0,a0,-262 # ffffffffc0201ef8 <commands+0x530>
ffffffffc0201006:	ba6ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc020100a <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020100a:	100027f3          	csrr	a5,sstatus
ffffffffc020100e:	8b89                	andi	a5,a5,2
ffffffffc0201010:	e799                	bnez	a5,ffffffffc020101e <alloc_pages+0x14>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0201012:	00005797          	auipc	a5,0x5
ffffffffc0201016:	44e7b783          	ld	a5,1102(a5) # ffffffffc0206460 <pmm_manager>
ffffffffc020101a:	6f9c                	ld	a5,24(a5)
ffffffffc020101c:	8782                	jr	a5
struct Page *alloc_pages(size_t n) {
ffffffffc020101e:	1141                	addi	sp,sp,-16
ffffffffc0201020:	e406                	sd	ra,8(sp)
ffffffffc0201022:	e022                	sd	s0,0(sp)
ffffffffc0201024:	842a                	mv	s0,a0
        intr_disable();
ffffffffc0201026:	c38ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc020102a:	00005797          	auipc	a5,0x5
ffffffffc020102e:	4367b783          	ld	a5,1078(a5) # ffffffffc0206460 <pmm_manager>
ffffffffc0201032:	6f9c                	ld	a5,24(a5)
ffffffffc0201034:	8522                	mv	a0,s0
ffffffffc0201036:	9782                	jalr	a5
ffffffffc0201038:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc020103a:	c1eff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc020103e:	60a2                	ld	ra,8(sp)
ffffffffc0201040:	8522                	mv	a0,s0
ffffffffc0201042:	6402                	ld	s0,0(sp)
ffffffffc0201044:	0141                	addi	sp,sp,16
ffffffffc0201046:	8082                	ret

ffffffffc0201048 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201048:	100027f3          	csrr	a5,sstatus
ffffffffc020104c:	8b89                	andi	a5,a5,2
ffffffffc020104e:	e799                	bnez	a5,ffffffffc020105c <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201050:	00005797          	auipc	a5,0x5
ffffffffc0201054:	4107b783          	ld	a5,1040(a5) # ffffffffc0206460 <pmm_manager>
ffffffffc0201058:	739c                	ld	a5,32(a5)
ffffffffc020105a:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc020105c:	1101                	addi	sp,sp,-32
ffffffffc020105e:	ec06                	sd	ra,24(sp)
ffffffffc0201060:	e822                	sd	s0,16(sp)
ffffffffc0201062:	e426                	sd	s1,8(sp)
ffffffffc0201064:	842a                	mv	s0,a0
ffffffffc0201066:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201068:	bf6ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020106c:	00005797          	auipc	a5,0x5
ffffffffc0201070:	3f47b783          	ld	a5,1012(a5) # ffffffffc0206460 <pmm_manager>
ffffffffc0201074:	739c                	ld	a5,32(a5)
ffffffffc0201076:	85a6                	mv	a1,s1
ffffffffc0201078:	8522                	mv	a0,s0
ffffffffc020107a:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc020107c:	6442                	ld	s0,16(sp)
ffffffffc020107e:	60e2                	ld	ra,24(sp)
ffffffffc0201080:	64a2                	ld	s1,8(sp)
ffffffffc0201082:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201084:	bd4ff06f          	j	ffffffffc0200458 <intr_enable>

ffffffffc0201088 <pmm_init>:
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc0201088:	00001797          	auipc	a5,0x1
ffffffffc020108c:	23078793          	addi	a5,a5,560 # ffffffffc02022b8 <buddy_system_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201090:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0201092:	1101                	addi	sp,sp,-32
ffffffffc0201094:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201096:	00001517          	auipc	a0,0x1
ffffffffc020109a:	25a50513          	addi	a0,a0,602 # ffffffffc02022f0 <buddy_system_pmm_manager+0x38>
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc020109e:	00005497          	auipc	s1,0x5
ffffffffc02010a2:	3c248493          	addi	s1,s1,962 # ffffffffc0206460 <pmm_manager>
void pmm_init(void) {
ffffffffc02010a6:	ec06                	sd	ra,24(sp)
ffffffffc02010a8:	e822                	sd	s0,16(sp)
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc02010aa:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02010ac:	806ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pmm_manager->init();
ffffffffc02010b0:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02010b2:	00005417          	auipc	s0,0x5
ffffffffc02010b6:	3c640413          	addi	s0,s0,966 # ffffffffc0206478 <va_pa_offset>
    pmm_manager->init();
ffffffffc02010ba:	679c                	ld	a5,8(a5)
ffffffffc02010bc:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02010be:	57f5                	li	a5,-3
ffffffffc02010c0:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc02010c2:	00001517          	auipc	a0,0x1
ffffffffc02010c6:	24650513          	addi	a0,a0,582 # ffffffffc0202308 <buddy_system_pmm_manager+0x50>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02010ca:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc02010cc:	fe7fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc02010d0:	46c5                	li	a3,17
ffffffffc02010d2:	06ee                	slli	a3,a3,0x1b
ffffffffc02010d4:	40100613          	li	a2,1025
ffffffffc02010d8:	16fd                	addi	a3,a3,-1
ffffffffc02010da:	07e005b7          	lui	a1,0x7e00
ffffffffc02010de:	0656                	slli	a2,a2,0x15
ffffffffc02010e0:	00001517          	auipc	a0,0x1
ffffffffc02010e4:	24050513          	addi	a0,a0,576 # ffffffffc0202320 <buddy_system_pmm_manager+0x68>
ffffffffc02010e8:	fcbfe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02010ec:	777d                	lui	a4,0xfffff
ffffffffc02010ee:	00006797          	auipc	a5,0x6
ffffffffc02010f2:	39978793          	addi	a5,a5,921 # ffffffffc0207487 <end+0xfff>
ffffffffc02010f6:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc02010f8:	00005517          	auipc	a0,0x5
ffffffffc02010fc:	35850513          	addi	a0,a0,856 # ffffffffc0206450 <npage>
ffffffffc0201100:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201104:	00005597          	auipc	a1,0x5
ffffffffc0201108:	35458593          	addi	a1,a1,852 # ffffffffc0206458 <pages>
    npage = maxpa / PGSIZE;
ffffffffc020110c:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020110e:	e19c                	sd	a5,0(a1)
ffffffffc0201110:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201112:	4701                	li	a4,0
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201114:	4885                	li	a7,1
ffffffffc0201116:	fff80837          	lui	a6,0xfff80
ffffffffc020111a:	a011                	j	ffffffffc020111e <pmm_init+0x96>
        SetPageReserved(pages + i);
ffffffffc020111c:	619c                	ld	a5,0(a1)
ffffffffc020111e:	97b6                	add	a5,a5,a3
ffffffffc0201120:	07a1                	addi	a5,a5,8
ffffffffc0201122:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201126:	611c                	ld	a5,0(a0)
ffffffffc0201128:	0705                	addi	a4,a4,1
ffffffffc020112a:	02868693          	addi	a3,a3,40
ffffffffc020112e:	01078633          	add	a2,a5,a6
ffffffffc0201132:	fec765e3          	bltu	a4,a2,ffffffffc020111c <pmm_init+0x94>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201136:	6190                	ld	a2,0(a1)
ffffffffc0201138:	00279713          	slli	a4,a5,0x2
ffffffffc020113c:	973e                	add	a4,a4,a5
ffffffffc020113e:	fec006b7          	lui	a3,0xfec00
ffffffffc0201142:	070e                	slli	a4,a4,0x3
ffffffffc0201144:	96b2                	add	a3,a3,a2
ffffffffc0201146:	96ba                	add	a3,a3,a4
ffffffffc0201148:	c0200737          	lui	a4,0xc0200
ffffffffc020114c:	08e6ef63          	bltu	a3,a4,ffffffffc02011ea <pmm_init+0x162>
ffffffffc0201150:	6018                	ld	a4,0(s0)
    if (freemem < mem_end) {
ffffffffc0201152:	45c5                	li	a1,17
ffffffffc0201154:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201156:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0201158:	04b6e863          	bltu	a3,a1,ffffffffc02011a8 <pmm_init+0x120>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc020115c:	609c                	ld	a5,0(s1)
ffffffffc020115e:	7b9c                	ld	a5,48(a5)
ffffffffc0201160:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201162:	00001517          	auipc	a0,0x1
ffffffffc0201166:	25650513          	addi	a0,a0,598 # ffffffffc02023b8 <buddy_system_pmm_manager+0x100>
ffffffffc020116a:	f49fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc020116e:	00004597          	auipc	a1,0x4
ffffffffc0201172:	e9258593          	addi	a1,a1,-366 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc0201176:	00005797          	auipc	a5,0x5
ffffffffc020117a:	2eb7bd23          	sd	a1,762(a5) # ffffffffc0206470 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc020117e:	c02007b7          	lui	a5,0xc0200
ffffffffc0201182:	08f5e063          	bltu	a1,a5,ffffffffc0201202 <pmm_init+0x17a>
ffffffffc0201186:	6010                	ld	a2,0(s0)
}
ffffffffc0201188:	6442                	ld	s0,16(sp)
ffffffffc020118a:	60e2                	ld	ra,24(sp)
ffffffffc020118c:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc020118e:	40c58633          	sub	a2,a1,a2
ffffffffc0201192:	00005797          	auipc	a5,0x5
ffffffffc0201196:	2cc7bb23          	sd	a2,726(a5) # ffffffffc0206468 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc020119a:	00001517          	auipc	a0,0x1
ffffffffc020119e:	23e50513          	addi	a0,a0,574 # ffffffffc02023d8 <buddy_system_pmm_manager+0x120>
}
ffffffffc02011a2:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02011a4:	f0ffe06f          	j	ffffffffc02000b2 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02011a8:	6705                	lui	a4,0x1
ffffffffc02011aa:	177d                	addi	a4,a4,-1
ffffffffc02011ac:	96ba                	add	a3,a3,a4
ffffffffc02011ae:	777d                	lui	a4,0xfffff
ffffffffc02011b0:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc02011b2:	00c6d513          	srli	a0,a3,0xc
ffffffffc02011b6:	00f57e63          	bgeu	a0,a5,ffffffffc02011d2 <pmm_init+0x14a>
    pmm_manager->init_memmap(base, n);
ffffffffc02011ba:	609c                	ld	a5,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc02011bc:	982a                	add	a6,a6,a0
ffffffffc02011be:	00281513          	slli	a0,a6,0x2
ffffffffc02011c2:	9542                	add	a0,a0,a6
ffffffffc02011c4:	6b9c                	ld	a5,16(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02011c6:	8d95                	sub	a1,a1,a3
ffffffffc02011c8:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02011ca:	81b1                	srli	a1,a1,0xc
ffffffffc02011cc:	9532                	add	a0,a0,a2
ffffffffc02011ce:	9782                	jalr	a5
}
ffffffffc02011d0:	b771                	j	ffffffffc020115c <pmm_init+0xd4>
        panic("pa2page called with invalid pa");
ffffffffc02011d2:	00001617          	auipc	a2,0x1
ffffffffc02011d6:	1b660613          	addi	a2,a2,438 # ffffffffc0202388 <buddy_system_pmm_manager+0xd0>
ffffffffc02011da:	06b00593          	li	a1,107
ffffffffc02011de:	00001517          	auipc	a0,0x1
ffffffffc02011e2:	1ca50513          	addi	a0,a0,458 # ffffffffc02023a8 <buddy_system_pmm_manager+0xf0>
ffffffffc02011e6:	9c6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02011ea:	00001617          	auipc	a2,0x1
ffffffffc02011ee:	16660613          	addi	a2,a2,358 # ffffffffc0202350 <buddy_system_pmm_manager+0x98>
ffffffffc02011f2:	06f00593          	li	a1,111
ffffffffc02011f6:	00001517          	auipc	a0,0x1
ffffffffc02011fa:	18250513          	addi	a0,a0,386 # ffffffffc0202378 <buddy_system_pmm_manager+0xc0>
ffffffffc02011fe:	9aeff0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201202:	86ae                	mv	a3,a1
ffffffffc0201204:	00001617          	auipc	a2,0x1
ffffffffc0201208:	14c60613          	addi	a2,a2,332 # ffffffffc0202350 <buddy_system_pmm_manager+0x98>
ffffffffc020120c:	08a00593          	li	a1,138
ffffffffc0201210:	00001517          	auipc	a0,0x1
ffffffffc0201214:	16850513          	addi	a0,a0,360 # ffffffffc0202378 <buddy_system_pmm_manager+0xc0>
ffffffffc0201218:	994ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc020121c <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc020121c:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201220:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0201222:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201226:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201228:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020122c:	f022                	sd	s0,32(sp)
ffffffffc020122e:	ec26                	sd	s1,24(sp)
ffffffffc0201230:	e84a                	sd	s2,16(sp)
ffffffffc0201232:	f406                	sd	ra,40(sp)
ffffffffc0201234:	e44e                	sd	s3,8(sp)
ffffffffc0201236:	84aa                	mv	s1,a0
ffffffffc0201238:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc020123a:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc020123e:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0201240:	03067e63          	bgeu	a2,a6,ffffffffc020127c <printnum+0x60>
ffffffffc0201244:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0201246:	00805763          	blez	s0,ffffffffc0201254 <printnum+0x38>
ffffffffc020124a:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc020124c:	85ca                	mv	a1,s2
ffffffffc020124e:	854e                	mv	a0,s3
ffffffffc0201250:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0201252:	fc65                	bnez	s0,ffffffffc020124a <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201254:	1a02                	slli	s4,s4,0x20
ffffffffc0201256:	00001797          	auipc	a5,0x1
ffffffffc020125a:	1c278793          	addi	a5,a5,450 # ffffffffc0202418 <buddy_system_pmm_manager+0x160>
ffffffffc020125e:	020a5a13          	srli	s4,s4,0x20
ffffffffc0201262:	9a3e                	add	s4,s4,a5
}
ffffffffc0201264:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201266:	000a4503          	lbu	a0,0(s4)
}
ffffffffc020126a:	70a2                	ld	ra,40(sp)
ffffffffc020126c:	69a2                	ld	s3,8(sp)
ffffffffc020126e:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201270:	85ca                	mv	a1,s2
ffffffffc0201272:	87a6                	mv	a5,s1
}
ffffffffc0201274:	6942                	ld	s2,16(sp)
ffffffffc0201276:	64e2                	ld	s1,24(sp)
ffffffffc0201278:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020127a:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc020127c:	03065633          	divu	a2,a2,a6
ffffffffc0201280:	8722                	mv	a4,s0
ffffffffc0201282:	f9bff0ef          	jal	ra,ffffffffc020121c <printnum>
ffffffffc0201286:	b7f9                	j	ffffffffc0201254 <printnum+0x38>

ffffffffc0201288 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0201288:	7119                	addi	sp,sp,-128
ffffffffc020128a:	f4a6                	sd	s1,104(sp)
ffffffffc020128c:	f0ca                	sd	s2,96(sp)
ffffffffc020128e:	ecce                	sd	s3,88(sp)
ffffffffc0201290:	e8d2                	sd	s4,80(sp)
ffffffffc0201292:	e4d6                	sd	s5,72(sp)
ffffffffc0201294:	e0da                	sd	s6,64(sp)
ffffffffc0201296:	fc5e                	sd	s7,56(sp)
ffffffffc0201298:	f06a                	sd	s10,32(sp)
ffffffffc020129a:	fc86                	sd	ra,120(sp)
ffffffffc020129c:	f8a2                	sd	s0,112(sp)
ffffffffc020129e:	f862                	sd	s8,48(sp)
ffffffffc02012a0:	f466                	sd	s9,40(sp)
ffffffffc02012a2:	ec6e                	sd	s11,24(sp)
ffffffffc02012a4:	892a                	mv	s2,a0
ffffffffc02012a6:	84ae                	mv	s1,a1
ffffffffc02012a8:	8d32                	mv	s10,a2
ffffffffc02012aa:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02012ac:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02012b0:	5b7d                	li	s6,-1
ffffffffc02012b2:	00001a97          	auipc	s5,0x1
ffffffffc02012b6:	19aa8a93          	addi	s5,s5,410 # ffffffffc020244c <buddy_system_pmm_manager+0x194>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02012ba:	00001b97          	auipc	s7,0x1
ffffffffc02012be:	36eb8b93          	addi	s7,s7,878 # ffffffffc0202628 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02012c2:	000d4503          	lbu	a0,0(s10)
ffffffffc02012c6:	001d0413          	addi	s0,s10,1
ffffffffc02012ca:	01350a63          	beq	a0,s3,ffffffffc02012de <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc02012ce:	c121                	beqz	a0,ffffffffc020130e <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc02012d0:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02012d2:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02012d4:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02012d6:	fff44503          	lbu	a0,-1(s0)
ffffffffc02012da:	ff351ae3          	bne	a0,s3,ffffffffc02012ce <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02012de:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02012e2:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02012e6:	4c81                	li	s9,0
ffffffffc02012e8:	4881                	li	a7,0
        width = precision = -1;
ffffffffc02012ea:	5c7d                	li	s8,-1
ffffffffc02012ec:	5dfd                	li	s11,-1
ffffffffc02012ee:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc02012f2:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02012f4:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02012f8:	0ff5f593          	andi	a1,a1,255
ffffffffc02012fc:	00140d13          	addi	s10,s0,1
ffffffffc0201300:	04b56263          	bltu	a0,a1,ffffffffc0201344 <vprintfmt+0xbc>
ffffffffc0201304:	058a                	slli	a1,a1,0x2
ffffffffc0201306:	95d6                	add	a1,a1,s5
ffffffffc0201308:	4194                	lw	a3,0(a1)
ffffffffc020130a:	96d6                	add	a3,a3,s5
ffffffffc020130c:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc020130e:	70e6                	ld	ra,120(sp)
ffffffffc0201310:	7446                	ld	s0,112(sp)
ffffffffc0201312:	74a6                	ld	s1,104(sp)
ffffffffc0201314:	7906                	ld	s2,96(sp)
ffffffffc0201316:	69e6                	ld	s3,88(sp)
ffffffffc0201318:	6a46                	ld	s4,80(sp)
ffffffffc020131a:	6aa6                	ld	s5,72(sp)
ffffffffc020131c:	6b06                	ld	s6,64(sp)
ffffffffc020131e:	7be2                	ld	s7,56(sp)
ffffffffc0201320:	7c42                	ld	s8,48(sp)
ffffffffc0201322:	7ca2                	ld	s9,40(sp)
ffffffffc0201324:	7d02                	ld	s10,32(sp)
ffffffffc0201326:	6de2                	ld	s11,24(sp)
ffffffffc0201328:	6109                	addi	sp,sp,128
ffffffffc020132a:	8082                	ret
            padc = '0';
ffffffffc020132c:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc020132e:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201332:	846a                	mv	s0,s10
ffffffffc0201334:	00140d13          	addi	s10,s0,1
ffffffffc0201338:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020133c:	0ff5f593          	andi	a1,a1,255
ffffffffc0201340:	fcb572e3          	bgeu	a0,a1,ffffffffc0201304 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0201344:	85a6                	mv	a1,s1
ffffffffc0201346:	02500513          	li	a0,37
ffffffffc020134a:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc020134c:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201350:	8d22                	mv	s10,s0
ffffffffc0201352:	f73788e3          	beq	a5,s3,ffffffffc02012c2 <vprintfmt+0x3a>
ffffffffc0201356:	ffed4783          	lbu	a5,-2(s10)
ffffffffc020135a:	1d7d                	addi	s10,s10,-1
ffffffffc020135c:	ff379de3          	bne	a5,s3,ffffffffc0201356 <vprintfmt+0xce>
ffffffffc0201360:	b78d                	j	ffffffffc02012c2 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0201362:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0201366:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020136a:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc020136c:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0201370:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201374:	02d86463          	bltu	a6,a3,ffffffffc020139c <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0201378:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc020137c:	002c169b          	slliw	a3,s8,0x2
ffffffffc0201380:	0186873b          	addw	a4,a3,s8
ffffffffc0201384:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201388:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc020138a:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc020138e:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201390:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0201394:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201398:	fed870e3          	bgeu	a6,a3,ffffffffc0201378 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc020139c:	f40ddce3          	bgez	s11,ffffffffc02012f4 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc02013a0:	8de2                	mv	s11,s8
ffffffffc02013a2:	5c7d                	li	s8,-1
ffffffffc02013a4:	bf81                	j	ffffffffc02012f4 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc02013a6:	fffdc693          	not	a3,s11
ffffffffc02013aa:	96fd                	srai	a3,a3,0x3f
ffffffffc02013ac:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02013b0:	00144603          	lbu	a2,1(s0)
ffffffffc02013b4:	2d81                	sext.w	s11,s11
ffffffffc02013b6:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02013b8:	bf35                	j	ffffffffc02012f4 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc02013ba:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02013be:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02013c2:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02013c4:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc02013c6:	bfd9                	j	ffffffffc020139c <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc02013c8:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02013ca:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02013ce:	01174463          	blt	a4,a7,ffffffffc02013d6 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc02013d2:	1a088e63          	beqz	a7,ffffffffc020158e <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc02013d6:	000a3603          	ld	a2,0(s4)
ffffffffc02013da:	46c1                	li	a3,16
ffffffffc02013dc:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02013de:	2781                	sext.w	a5,a5
ffffffffc02013e0:	876e                	mv	a4,s11
ffffffffc02013e2:	85a6                	mv	a1,s1
ffffffffc02013e4:	854a                	mv	a0,s2
ffffffffc02013e6:	e37ff0ef          	jal	ra,ffffffffc020121c <printnum>
            break;
ffffffffc02013ea:	bde1                	j	ffffffffc02012c2 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc02013ec:	000a2503          	lw	a0,0(s4)
ffffffffc02013f0:	85a6                	mv	a1,s1
ffffffffc02013f2:	0a21                	addi	s4,s4,8
ffffffffc02013f4:	9902                	jalr	s2
            break;
ffffffffc02013f6:	b5f1                	j	ffffffffc02012c2 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02013f8:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02013fa:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02013fe:	01174463          	blt	a4,a7,ffffffffc0201406 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0201402:	18088163          	beqz	a7,ffffffffc0201584 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0201406:	000a3603          	ld	a2,0(s4)
ffffffffc020140a:	46a9                	li	a3,10
ffffffffc020140c:	8a2e                	mv	s4,a1
ffffffffc020140e:	bfc1                	j	ffffffffc02013de <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201410:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0201414:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201416:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201418:	bdf1                	j	ffffffffc02012f4 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc020141a:	85a6                	mv	a1,s1
ffffffffc020141c:	02500513          	li	a0,37
ffffffffc0201420:	9902                	jalr	s2
            break;
ffffffffc0201422:	b545                	j	ffffffffc02012c2 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201424:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0201428:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020142a:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020142c:	b5e1                	j	ffffffffc02012f4 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc020142e:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201430:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201434:	01174463          	blt	a4,a7,ffffffffc020143c <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0201438:	14088163          	beqz	a7,ffffffffc020157a <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc020143c:	000a3603          	ld	a2,0(s4)
ffffffffc0201440:	46a1                	li	a3,8
ffffffffc0201442:	8a2e                	mv	s4,a1
ffffffffc0201444:	bf69                	j	ffffffffc02013de <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0201446:	03000513          	li	a0,48
ffffffffc020144a:	85a6                	mv	a1,s1
ffffffffc020144c:	e03e                	sd	a5,0(sp)
ffffffffc020144e:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201450:	85a6                	mv	a1,s1
ffffffffc0201452:	07800513          	li	a0,120
ffffffffc0201456:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201458:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc020145a:	6782                	ld	a5,0(sp)
ffffffffc020145c:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020145e:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0201462:	bfb5                	j	ffffffffc02013de <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201464:	000a3403          	ld	s0,0(s4)
ffffffffc0201468:	008a0713          	addi	a4,s4,8
ffffffffc020146c:	e03a                	sd	a4,0(sp)
ffffffffc020146e:	14040263          	beqz	s0,ffffffffc02015b2 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0201472:	0fb05763          	blez	s11,ffffffffc0201560 <vprintfmt+0x2d8>
ffffffffc0201476:	02d00693          	li	a3,45
ffffffffc020147a:	0cd79163          	bne	a5,a3,ffffffffc020153c <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020147e:	00044783          	lbu	a5,0(s0)
ffffffffc0201482:	0007851b          	sext.w	a0,a5
ffffffffc0201486:	cf85                	beqz	a5,ffffffffc02014be <vprintfmt+0x236>
ffffffffc0201488:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020148c:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201490:	000c4563          	bltz	s8,ffffffffc020149a <vprintfmt+0x212>
ffffffffc0201494:	3c7d                	addiw	s8,s8,-1
ffffffffc0201496:	036c0263          	beq	s8,s6,ffffffffc02014ba <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc020149a:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020149c:	0e0c8e63          	beqz	s9,ffffffffc0201598 <vprintfmt+0x310>
ffffffffc02014a0:	3781                	addiw	a5,a5,-32
ffffffffc02014a2:	0ef47b63          	bgeu	s0,a5,ffffffffc0201598 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc02014a6:	03f00513          	li	a0,63
ffffffffc02014aa:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02014ac:	000a4783          	lbu	a5,0(s4)
ffffffffc02014b0:	3dfd                	addiw	s11,s11,-1
ffffffffc02014b2:	0a05                	addi	s4,s4,1
ffffffffc02014b4:	0007851b          	sext.w	a0,a5
ffffffffc02014b8:	ffe1                	bnez	a5,ffffffffc0201490 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc02014ba:	01b05963          	blez	s11,ffffffffc02014cc <vprintfmt+0x244>
ffffffffc02014be:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02014c0:	85a6                	mv	a1,s1
ffffffffc02014c2:	02000513          	li	a0,32
ffffffffc02014c6:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02014c8:	fe0d9be3          	bnez	s11,ffffffffc02014be <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02014cc:	6a02                	ld	s4,0(sp)
ffffffffc02014ce:	bbd5                	j	ffffffffc02012c2 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02014d0:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02014d2:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc02014d6:	01174463          	blt	a4,a7,ffffffffc02014de <vprintfmt+0x256>
    else if (lflag) {
ffffffffc02014da:	08088d63          	beqz	a7,ffffffffc0201574 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc02014de:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc02014e2:	0a044d63          	bltz	s0,ffffffffc020159c <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc02014e6:	8622                	mv	a2,s0
ffffffffc02014e8:	8a66                	mv	s4,s9
ffffffffc02014ea:	46a9                	li	a3,10
ffffffffc02014ec:	bdcd                	j	ffffffffc02013de <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc02014ee:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02014f2:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02014f4:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc02014f6:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02014fa:	8fb5                	xor	a5,a5,a3
ffffffffc02014fc:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201500:	02d74163          	blt	a4,a3,ffffffffc0201522 <vprintfmt+0x29a>
ffffffffc0201504:	00369793          	slli	a5,a3,0x3
ffffffffc0201508:	97de                	add	a5,a5,s7
ffffffffc020150a:	639c                	ld	a5,0(a5)
ffffffffc020150c:	cb99                	beqz	a5,ffffffffc0201522 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc020150e:	86be                	mv	a3,a5
ffffffffc0201510:	00001617          	auipc	a2,0x1
ffffffffc0201514:	f3860613          	addi	a2,a2,-200 # ffffffffc0202448 <buddy_system_pmm_manager+0x190>
ffffffffc0201518:	85a6                	mv	a1,s1
ffffffffc020151a:	854a                	mv	a0,s2
ffffffffc020151c:	0ce000ef          	jal	ra,ffffffffc02015ea <printfmt>
ffffffffc0201520:	b34d                	j	ffffffffc02012c2 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201522:	00001617          	auipc	a2,0x1
ffffffffc0201526:	f1660613          	addi	a2,a2,-234 # ffffffffc0202438 <buddy_system_pmm_manager+0x180>
ffffffffc020152a:	85a6                	mv	a1,s1
ffffffffc020152c:	854a                	mv	a0,s2
ffffffffc020152e:	0bc000ef          	jal	ra,ffffffffc02015ea <printfmt>
ffffffffc0201532:	bb41                	j	ffffffffc02012c2 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201534:	00001417          	auipc	s0,0x1
ffffffffc0201538:	efc40413          	addi	s0,s0,-260 # ffffffffc0202430 <buddy_system_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020153c:	85e2                	mv	a1,s8
ffffffffc020153e:	8522                	mv	a0,s0
ffffffffc0201540:	e43e                	sd	a5,8(sp)
ffffffffc0201542:	1cc000ef          	jal	ra,ffffffffc020170e <strnlen>
ffffffffc0201546:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020154a:	01b05b63          	blez	s11,ffffffffc0201560 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc020154e:	67a2                	ld	a5,8(sp)
ffffffffc0201550:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201554:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201556:	85a6                	mv	a1,s1
ffffffffc0201558:	8552                	mv	a0,s4
ffffffffc020155a:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020155c:	fe0d9ce3          	bnez	s11,ffffffffc0201554 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201560:	00044783          	lbu	a5,0(s0)
ffffffffc0201564:	00140a13          	addi	s4,s0,1
ffffffffc0201568:	0007851b          	sext.w	a0,a5
ffffffffc020156c:	d3a5                	beqz	a5,ffffffffc02014cc <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020156e:	05e00413          	li	s0,94
ffffffffc0201572:	bf39                	j	ffffffffc0201490 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0201574:	000a2403          	lw	s0,0(s4)
ffffffffc0201578:	b7ad                	j	ffffffffc02014e2 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc020157a:	000a6603          	lwu	a2,0(s4)
ffffffffc020157e:	46a1                	li	a3,8
ffffffffc0201580:	8a2e                	mv	s4,a1
ffffffffc0201582:	bdb1                	j	ffffffffc02013de <vprintfmt+0x156>
ffffffffc0201584:	000a6603          	lwu	a2,0(s4)
ffffffffc0201588:	46a9                	li	a3,10
ffffffffc020158a:	8a2e                	mv	s4,a1
ffffffffc020158c:	bd89                	j	ffffffffc02013de <vprintfmt+0x156>
ffffffffc020158e:	000a6603          	lwu	a2,0(s4)
ffffffffc0201592:	46c1                	li	a3,16
ffffffffc0201594:	8a2e                	mv	s4,a1
ffffffffc0201596:	b5a1                	j	ffffffffc02013de <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0201598:	9902                	jalr	s2
ffffffffc020159a:	bf09                	j	ffffffffc02014ac <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc020159c:	85a6                	mv	a1,s1
ffffffffc020159e:	02d00513          	li	a0,45
ffffffffc02015a2:	e03e                	sd	a5,0(sp)
ffffffffc02015a4:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02015a6:	6782                	ld	a5,0(sp)
ffffffffc02015a8:	8a66                	mv	s4,s9
ffffffffc02015aa:	40800633          	neg	a2,s0
ffffffffc02015ae:	46a9                	li	a3,10
ffffffffc02015b0:	b53d                	j	ffffffffc02013de <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc02015b2:	03b05163          	blez	s11,ffffffffc02015d4 <vprintfmt+0x34c>
ffffffffc02015b6:	02d00693          	li	a3,45
ffffffffc02015ba:	f6d79de3          	bne	a5,a3,ffffffffc0201534 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc02015be:	00001417          	auipc	s0,0x1
ffffffffc02015c2:	e7240413          	addi	s0,s0,-398 # ffffffffc0202430 <buddy_system_pmm_manager+0x178>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02015c6:	02800793          	li	a5,40
ffffffffc02015ca:	02800513          	li	a0,40
ffffffffc02015ce:	00140a13          	addi	s4,s0,1
ffffffffc02015d2:	bd6d                	j	ffffffffc020148c <vprintfmt+0x204>
ffffffffc02015d4:	00001a17          	auipc	s4,0x1
ffffffffc02015d8:	e5da0a13          	addi	s4,s4,-419 # ffffffffc0202431 <buddy_system_pmm_manager+0x179>
ffffffffc02015dc:	02800513          	li	a0,40
ffffffffc02015e0:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02015e4:	05e00413          	li	s0,94
ffffffffc02015e8:	b565                	j	ffffffffc0201490 <vprintfmt+0x208>

ffffffffc02015ea <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02015ea:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02015ec:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02015f0:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02015f2:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02015f4:	ec06                	sd	ra,24(sp)
ffffffffc02015f6:	f83a                	sd	a4,48(sp)
ffffffffc02015f8:	fc3e                	sd	a5,56(sp)
ffffffffc02015fa:	e0c2                	sd	a6,64(sp)
ffffffffc02015fc:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02015fe:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201600:	c89ff0ef          	jal	ra,ffffffffc0201288 <vprintfmt>
}
ffffffffc0201604:	60e2                	ld	ra,24(sp)
ffffffffc0201606:	6161                	addi	sp,sp,80
ffffffffc0201608:	8082                	ret

ffffffffc020160a <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc020160a:	715d                	addi	sp,sp,-80
ffffffffc020160c:	e486                	sd	ra,72(sp)
ffffffffc020160e:	e0a6                	sd	s1,64(sp)
ffffffffc0201610:	fc4a                	sd	s2,56(sp)
ffffffffc0201612:	f84e                	sd	s3,48(sp)
ffffffffc0201614:	f452                	sd	s4,40(sp)
ffffffffc0201616:	f056                	sd	s5,32(sp)
ffffffffc0201618:	ec5a                	sd	s6,24(sp)
ffffffffc020161a:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc020161c:	c901                	beqz	a0,ffffffffc020162c <readline+0x22>
ffffffffc020161e:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc0201620:	00001517          	auipc	a0,0x1
ffffffffc0201624:	e2850513          	addi	a0,a0,-472 # ffffffffc0202448 <buddy_system_pmm_manager+0x190>
ffffffffc0201628:	a8bfe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
readline(const char *prompt) {
ffffffffc020162c:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020162e:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201630:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201632:	4aa9                	li	s5,10
ffffffffc0201634:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201636:	00005b97          	auipc	s7,0x5
ffffffffc020163a:	9f2b8b93          	addi	s7,s7,-1550 # ffffffffc0206028 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020163e:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0201642:	ae9fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201646:	00054a63          	bltz	a0,ffffffffc020165a <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020164a:	00a95a63          	bge	s2,a0,ffffffffc020165e <readline+0x54>
ffffffffc020164e:	029a5263          	bge	s4,s1,ffffffffc0201672 <readline+0x68>
        c = getchar();
ffffffffc0201652:	ad9fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201656:	fe055ae3          	bgez	a0,ffffffffc020164a <readline+0x40>
            return NULL;
ffffffffc020165a:	4501                	li	a0,0
ffffffffc020165c:	a091                	j	ffffffffc02016a0 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc020165e:	03351463          	bne	a0,s3,ffffffffc0201686 <readline+0x7c>
ffffffffc0201662:	e8a9                	bnez	s1,ffffffffc02016b4 <readline+0xaa>
        c = getchar();
ffffffffc0201664:	ac7fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201668:	fe0549e3          	bltz	a0,ffffffffc020165a <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020166c:	fea959e3          	bge	s2,a0,ffffffffc020165e <readline+0x54>
ffffffffc0201670:	4481                	li	s1,0
            cputchar(c);
ffffffffc0201672:	e42a                	sd	a0,8(sp)
ffffffffc0201674:	a75fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i ++] = c;
ffffffffc0201678:	6522                	ld	a0,8(sp)
ffffffffc020167a:	009b87b3          	add	a5,s7,s1
ffffffffc020167e:	2485                	addiw	s1,s1,1
ffffffffc0201680:	00a78023          	sb	a0,0(a5)
ffffffffc0201684:	bf7d                	j	ffffffffc0201642 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc0201686:	01550463          	beq	a0,s5,ffffffffc020168e <readline+0x84>
ffffffffc020168a:	fb651ce3          	bne	a0,s6,ffffffffc0201642 <readline+0x38>
            cputchar(c);
ffffffffc020168e:	a5bfe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i] = '\0';
ffffffffc0201692:	00005517          	auipc	a0,0x5
ffffffffc0201696:	99650513          	addi	a0,a0,-1642 # ffffffffc0206028 <buf>
ffffffffc020169a:	94aa                	add	s1,s1,a0
ffffffffc020169c:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02016a0:	60a6                	ld	ra,72(sp)
ffffffffc02016a2:	6486                	ld	s1,64(sp)
ffffffffc02016a4:	7962                	ld	s2,56(sp)
ffffffffc02016a6:	79c2                	ld	s3,48(sp)
ffffffffc02016a8:	7a22                	ld	s4,40(sp)
ffffffffc02016aa:	7a82                	ld	s5,32(sp)
ffffffffc02016ac:	6b62                	ld	s6,24(sp)
ffffffffc02016ae:	6bc2                	ld	s7,16(sp)
ffffffffc02016b0:	6161                	addi	sp,sp,80
ffffffffc02016b2:	8082                	ret
            cputchar(c);
ffffffffc02016b4:	4521                	li	a0,8
ffffffffc02016b6:	a33fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            i --;
ffffffffc02016ba:	34fd                	addiw	s1,s1,-1
ffffffffc02016bc:	b759                	j	ffffffffc0201642 <readline+0x38>

ffffffffc02016be <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc02016be:	4781                	li	a5,0
ffffffffc02016c0:	00005717          	auipc	a4,0x5
ffffffffc02016c4:	94873703          	ld	a4,-1720(a4) # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
ffffffffc02016c8:	88ba                	mv	a7,a4
ffffffffc02016ca:	852a                	mv	a0,a0
ffffffffc02016cc:	85be                	mv	a1,a5
ffffffffc02016ce:	863e                	mv	a2,a5
ffffffffc02016d0:	00000073          	ecall
ffffffffc02016d4:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc02016d6:	8082                	ret

ffffffffc02016d8 <sbi_set_timer>:
    __asm__ volatile (
ffffffffc02016d8:	4781                	li	a5,0
ffffffffc02016da:	00005717          	auipc	a4,0x5
ffffffffc02016de:	da673703          	ld	a4,-602(a4) # ffffffffc0206480 <SBI_SET_TIMER>
ffffffffc02016e2:	88ba                	mv	a7,a4
ffffffffc02016e4:	852a                	mv	a0,a0
ffffffffc02016e6:	85be                	mv	a1,a5
ffffffffc02016e8:	863e                	mv	a2,a5
ffffffffc02016ea:	00000073          	ecall
ffffffffc02016ee:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc02016f0:	8082                	ret

ffffffffc02016f2 <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc02016f2:	4501                	li	a0,0
ffffffffc02016f4:	00005797          	auipc	a5,0x5
ffffffffc02016f8:	90c7b783          	ld	a5,-1780(a5) # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
ffffffffc02016fc:	88be                	mv	a7,a5
ffffffffc02016fe:	852a                	mv	a0,a0
ffffffffc0201700:	85aa                	mv	a1,a0
ffffffffc0201702:	862a                	mv	a2,a0
ffffffffc0201704:	00000073          	ecall
ffffffffc0201708:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc020170a:	2501                	sext.w	a0,a0
ffffffffc020170c:	8082                	ret

ffffffffc020170e <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc020170e:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201710:	e589                	bnez	a1,ffffffffc020171a <strnlen+0xc>
ffffffffc0201712:	a811                	j	ffffffffc0201726 <strnlen+0x18>
        cnt ++;
ffffffffc0201714:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201716:	00f58863          	beq	a1,a5,ffffffffc0201726 <strnlen+0x18>
ffffffffc020171a:	00f50733          	add	a4,a0,a5
ffffffffc020171e:	00074703          	lbu	a4,0(a4)
ffffffffc0201722:	fb6d                	bnez	a4,ffffffffc0201714 <strnlen+0x6>
ffffffffc0201724:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0201726:	852e                	mv	a0,a1
ffffffffc0201728:	8082                	ret

ffffffffc020172a <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020172a:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020172e:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201732:	cb89                	beqz	a5,ffffffffc0201744 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0201734:	0505                	addi	a0,a0,1
ffffffffc0201736:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201738:	fee789e3          	beq	a5,a4,ffffffffc020172a <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020173c:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201740:	9d19                	subw	a0,a0,a4
ffffffffc0201742:	8082                	ret
ffffffffc0201744:	4501                	li	a0,0
ffffffffc0201746:	bfed                	j	ffffffffc0201740 <strcmp+0x16>

ffffffffc0201748 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201748:	00054783          	lbu	a5,0(a0)
ffffffffc020174c:	c799                	beqz	a5,ffffffffc020175a <strchr+0x12>
        if (*s == c) {
ffffffffc020174e:	00f58763          	beq	a1,a5,ffffffffc020175c <strchr+0x14>
    while (*s != '\0') {
ffffffffc0201752:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0201756:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201758:	fbfd                	bnez	a5,ffffffffc020174e <strchr+0x6>
    }
    return NULL;
ffffffffc020175a:	4501                	li	a0,0
}
ffffffffc020175c:	8082                	ret

ffffffffc020175e <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc020175e:	ca01                	beqz	a2,ffffffffc020176e <memset+0x10>
ffffffffc0201760:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201762:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201764:	0785                	addi	a5,a5,1
ffffffffc0201766:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc020176a:	fec79de3          	bne	a5,a2,ffffffffc0201764 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc020176e:	8082                	ret
