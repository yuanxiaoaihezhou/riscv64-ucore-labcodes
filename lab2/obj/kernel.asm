
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
ffffffffc020004a:	752010ef          	jal	ra,ffffffffc020179c <memset>
    cons_init();  // init the console
ffffffffc020004e:	3fc000ef          	jal	ra,ffffffffc020044a <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00001517          	auipc	a0,0x1
ffffffffc0200056:	75e50513          	addi	a0,a0,1886 # ffffffffc02017b0 <etext+0x2>
ffffffffc020005a:	090000ef          	jal	ra,ffffffffc02000ea <cputs>

    print_kerninfo();
ffffffffc020005e:	0dc000ef          	jal	ra,ffffffffc020013a <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200062:	402000ef          	jal	ra,ffffffffc0200464 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc0200066:	060010ef          	jal	ra,ffffffffc02010c6 <pmm_init>

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
ffffffffc02000a6:	220010ef          	jal	ra,ffffffffc02012c6 <vprintfmt>
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
ffffffffc02000dc:	1ea010ef          	jal	ra,ffffffffc02012c6 <vprintfmt>
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
ffffffffc0200140:	69450513          	addi	a0,a0,1684 # ffffffffc02017d0 <etext+0x22>
void print_kerninfo(void) {
ffffffffc0200144:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200146:	f6dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014a:	00000597          	auipc	a1,0x0
ffffffffc020014e:	ee858593          	addi	a1,a1,-280 # ffffffffc0200032 <kern_init>
ffffffffc0200152:	00001517          	auipc	a0,0x1
ffffffffc0200156:	69e50513          	addi	a0,a0,1694 # ffffffffc02017f0 <etext+0x42>
ffffffffc020015a:	f59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020015e:	00001597          	auipc	a1,0x1
ffffffffc0200162:	65058593          	addi	a1,a1,1616 # ffffffffc02017ae <etext>
ffffffffc0200166:	00001517          	auipc	a0,0x1
ffffffffc020016a:	6aa50513          	addi	a0,a0,1706 # ffffffffc0201810 <etext+0x62>
ffffffffc020016e:	f45ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200172:	00006597          	auipc	a1,0x6
ffffffffc0200176:	e9e58593          	addi	a1,a1,-354 # ffffffffc0206010 <free_area>
ffffffffc020017a:	00001517          	auipc	a0,0x1
ffffffffc020017e:	6b650513          	addi	a0,a0,1718 # ffffffffc0201830 <etext+0x82>
ffffffffc0200182:	f31ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200186:	00006597          	auipc	a1,0x6
ffffffffc020018a:	30258593          	addi	a1,a1,770 # ffffffffc0206488 <end>
ffffffffc020018e:	00001517          	auipc	a0,0x1
ffffffffc0200192:	6c250513          	addi	a0,a0,1730 # ffffffffc0201850 <etext+0xa2>
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
ffffffffc02001c0:	6b450513          	addi	a0,a0,1716 # ffffffffc0201870 <etext+0xc2>
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
ffffffffc02001ce:	6d660613          	addi	a2,a2,1750 # ffffffffc02018a0 <etext+0xf2>
ffffffffc02001d2:	04e00593          	li	a1,78
ffffffffc02001d6:	00001517          	auipc	a0,0x1
ffffffffc02001da:	6e250513          	addi	a0,a0,1762 # ffffffffc02018b8 <etext+0x10a>
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
ffffffffc02001ea:	6ea60613          	addi	a2,a2,1770 # ffffffffc02018d0 <etext+0x122>
ffffffffc02001ee:	00001597          	auipc	a1,0x1
ffffffffc02001f2:	70258593          	addi	a1,a1,1794 # ffffffffc02018f0 <etext+0x142>
ffffffffc02001f6:	00001517          	auipc	a0,0x1
ffffffffc02001fa:	70250513          	addi	a0,a0,1794 # ffffffffc02018f8 <etext+0x14a>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001fe:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200200:	eb3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200204:	00001617          	auipc	a2,0x1
ffffffffc0200208:	70460613          	addi	a2,a2,1796 # ffffffffc0201908 <etext+0x15a>
ffffffffc020020c:	00001597          	auipc	a1,0x1
ffffffffc0200210:	72458593          	addi	a1,a1,1828 # ffffffffc0201930 <etext+0x182>
ffffffffc0200214:	00001517          	auipc	a0,0x1
ffffffffc0200218:	6e450513          	addi	a0,a0,1764 # ffffffffc02018f8 <etext+0x14a>
ffffffffc020021c:	e97ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200220:	00001617          	auipc	a2,0x1
ffffffffc0200224:	72060613          	addi	a2,a2,1824 # ffffffffc0201940 <etext+0x192>
ffffffffc0200228:	00001597          	auipc	a1,0x1
ffffffffc020022c:	73858593          	addi	a1,a1,1848 # ffffffffc0201960 <etext+0x1b2>
ffffffffc0200230:	00001517          	auipc	a0,0x1
ffffffffc0200234:	6c850513          	addi	a0,a0,1736 # ffffffffc02018f8 <etext+0x14a>
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
ffffffffc020026e:	70650513          	addi	a0,a0,1798 # ffffffffc0201970 <etext+0x1c2>
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
ffffffffc0200290:	70c50513          	addi	a0,a0,1804 # ffffffffc0201998 <etext+0x1ea>
ffffffffc0200294:	e1fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    if (tf != NULL) {
ffffffffc0200298:	000b8563          	beqz	s7,ffffffffc02002a2 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020029c:	855e                	mv	a0,s7
ffffffffc020029e:	3a4000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc02002a2:	00001c17          	auipc	s8,0x1
ffffffffc02002a6:	766c0c13          	addi	s8,s8,1894 # ffffffffc0201a08 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002aa:	00001917          	auipc	s2,0x1
ffffffffc02002ae:	71690913          	addi	s2,s2,1814 # ffffffffc02019c0 <etext+0x212>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b2:	00001497          	auipc	s1,0x1
ffffffffc02002b6:	71648493          	addi	s1,s1,1814 # ffffffffc02019c8 <etext+0x21a>
        if (argc == MAXARGS - 1) {
ffffffffc02002ba:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002bc:	00001b17          	auipc	s6,0x1
ffffffffc02002c0:	714b0b13          	addi	s6,s6,1812 # ffffffffc02019d0 <etext+0x222>
        argv[argc ++] = buf;
ffffffffc02002c4:	00001a17          	auipc	s4,0x1
ffffffffc02002c8:	62ca0a13          	addi	s4,s4,1580 # ffffffffc02018f0 <etext+0x142>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002cc:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002ce:	854a                	mv	a0,s2
ffffffffc02002d0:	378010ef          	jal	ra,ffffffffc0201648 <readline>
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
ffffffffc02002ea:	722d0d13          	addi	s10,s10,1826 # ffffffffc0201a08 <commands>
        argv[argc ++] = buf;
ffffffffc02002ee:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002f0:	4401                	li	s0,0
ffffffffc02002f2:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002f4:	474010ef          	jal	ra,ffffffffc0201768 <strcmp>
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
ffffffffc0200308:	460010ef          	jal	ra,ffffffffc0201768 <strcmp>
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
ffffffffc0200346:	440010ef          	jal	ra,ffffffffc0201786 <strchr>
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
ffffffffc0200384:	402010ef          	jal	ra,ffffffffc0201786 <strchr>
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
ffffffffc02003a2:	65250513          	addi	a0,a0,1618 # ffffffffc02019f0 <etext+0x242>
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
ffffffffc02003de:	67650513          	addi	a0,a0,1654 # ffffffffc0201a50 <commands+0x48>
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
ffffffffc02003f4:	d1850513          	addi	a0,a0,-744 # ffffffffc0202108 <commands+0x700>
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
ffffffffc0200420:	2f6010ef          	jal	ra,ffffffffc0201716 <sbi_set_timer>
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200426:	00006797          	auipc	a5,0x6
ffffffffc020042a:	0007b523          	sd	zero,10(a5) # ffffffffc0206430 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042e:	00001517          	auipc	a0,0x1
ffffffffc0200432:	64250513          	addi	a0,a0,1602 # ffffffffc0201a70 <commands+0x68>
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
ffffffffc0200446:	2d00106f          	j	ffffffffc0201716 <sbi_set_timer>

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
ffffffffc0200450:	2ac0106f          	j	ffffffffc02016fc <sbi_console_putchar>

ffffffffc0200454 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200454:	2dc0106f          	j	ffffffffc0201730 <sbi_console_getchar>

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
ffffffffc0200482:	61250513          	addi	a0,a0,1554 # ffffffffc0201a90 <commands+0x88>
void print_regs(struct pushregs *gpr) {
ffffffffc0200486:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200488:	c2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020048c:	640c                	ld	a1,8(s0)
ffffffffc020048e:	00001517          	auipc	a0,0x1
ffffffffc0200492:	61a50513          	addi	a0,a0,1562 # ffffffffc0201aa8 <commands+0xa0>
ffffffffc0200496:	c1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00001517          	auipc	a0,0x1
ffffffffc02004a0:	62450513          	addi	a0,a0,1572 # ffffffffc0201ac0 <commands+0xb8>
ffffffffc02004a4:	c0fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00001517          	auipc	a0,0x1
ffffffffc02004ae:	62e50513          	addi	a0,a0,1582 # ffffffffc0201ad8 <commands+0xd0>
ffffffffc02004b2:	c01ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00001517          	auipc	a0,0x1
ffffffffc02004bc:	63850513          	addi	a0,a0,1592 # ffffffffc0201af0 <commands+0xe8>
ffffffffc02004c0:	bf3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00001517          	auipc	a0,0x1
ffffffffc02004ca:	64250513          	addi	a0,a0,1602 # ffffffffc0201b08 <commands+0x100>
ffffffffc02004ce:	be5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00001517          	auipc	a0,0x1
ffffffffc02004d8:	64c50513          	addi	a0,a0,1612 # ffffffffc0201b20 <commands+0x118>
ffffffffc02004dc:	bd7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00001517          	auipc	a0,0x1
ffffffffc02004e6:	65650513          	addi	a0,a0,1622 # ffffffffc0201b38 <commands+0x130>
ffffffffc02004ea:	bc9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00001517          	auipc	a0,0x1
ffffffffc02004f4:	66050513          	addi	a0,a0,1632 # ffffffffc0201b50 <commands+0x148>
ffffffffc02004f8:	bbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00001517          	auipc	a0,0x1
ffffffffc0200502:	66a50513          	addi	a0,a0,1642 # ffffffffc0201b68 <commands+0x160>
ffffffffc0200506:	badff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00001517          	auipc	a0,0x1
ffffffffc0200510:	67450513          	addi	a0,a0,1652 # ffffffffc0201b80 <commands+0x178>
ffffffffc0200514:	b9fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00001517          	auipc	a0,0x1
ffffffffc020051e:	67e50513          	addi	a0,a0,1662 # ffffffffc0201b98 <commands+0x190>
ffffffffc0200522:	b91ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00001517          	auipc	a0,0x1
ffffffffc020052c:	68850513          	addi	a0,a0,1672 # ffffffffc0201bb0 <commands+0x1a8>
ffffffffc0200530:	b83ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00001517          	auipc	a0,0x1
ffffffffc020053a:	69250513          	addi	a0,a0,1682 # ffffffffc0201bc8 <commands+0x1c0>
ffffffffc020053e:	b75ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00001517          	auipc	a0,0x1
ffffffffc0200548:	69c50513          	addi	a0,a0,1692 # ffffffffc0201be0 <commands+0x1d8>
ffffffffc020054c:	b67ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00001517          	auipc	a0,0x1
ffffffffc0200556:	6a650513          	addi	a0,a0,1702 # ffffffffc0201bf8 <commands+0x1f0>
ffffffffc020055a:	b59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00001517          	auipc	a0,0x1
ffffffffc0200564:	6b050513          	addi	a0,a0,1712 # ffffffffc0201c10 <commands+0x208>
ffffffffc0200568:	b4bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00001517          	auipc	a0,0x1
ffffffffc0200572:	6ba50513          	addi	a0,a0,1722 # ffffffffc0201c28 <commands+0x220>
ffffffffc0200576:	b3dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00001517          	auipc	a0,0x1
ffffffffc0200580:	6c450513          	addi	a0,a0,1732 # ffffffffc0201c40 <commands+0x238>
ffffffffc0200584:	b2fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00001517          	auipc	a0,0x1
ffffffffc020058e:	6ce50513          	addi	a0,a0,1742 # ffffffffc0201c58 <commands+0x250>
ffffffffc0200592:	b21ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00001517          	auipc	a0,0x1
ffffffffc020059c:	6d850513          	addi	a0,a0,1752 # ffffffffc0201c70 <commands+0x268>
ffffffffc02005a0:	b13ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00001517          	auipc	a0,0x1
ffffffffc02005aa:	6e250513          	addi	a0,a0,1762 # ffffffffc0201c88 <commands+0x280>
ffffffffc02005ae:	b05ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00001517          	auipc	a0,0x1
ffffffffc02005b8:	6ec50513          	addi	a0,a0,1772 # ffffffffc0201ca0 <commands+0x298>
ffffffffc02005bc:	af7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00001517          	auipc	a0,0x1
ffffffffc02005c6:	6f650513          	addi	a0,a0,1782 # ffffffffc0201cb8 <commands+0x2b0>
ffffffffc02005ca:	ae9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00001517          	auipc	a0,0x1
ffffffffc02005d4:	70050513          	addi	a0,a0,1792 # ffffffffc0201cd0 <commands+0x2c8>
ffffffffc02005d8:	adbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00001517          	auipc	a0,0x1
ffffffffc02005e2:	70a50513          	addi	a0,a0,1802 # ffffffffc0201ce8 <commands+0x2e0>
ffffffffc02005e6:	acdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00001517          	auipc	a0,0x1
ffffffffc02005f0:	71450513          	addi	a0,a0,1812 # ffffffffc0201d00 <commands+0x2f8>
ffffffffc02005f4:	abfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00001517          	auipc	a0,0x1
ffffffffc02005fe:	71e50513          	addi	a0,a0,1822 # ffffffffc0201d18 <commands+0x310>
ffffffffc0200602:	ab1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00001517          	auipc	a0,0x1
ffffffffc020060c:	72850513          	addi	a0,a0,1832 # ffffffffc0201d30 <commands+0x328>
ffffffffc0200610:	aa3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00001517          	auipc	a0,0x1
ffffffffc020061a:	73250513          	addi	a0,a0,1842 # ffffffffc0201d48 <commands+0x340>
ffffffffc020061e:	a95ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00001517          	auipc	a0,0x1
ffffffffc0200628:	73c50513          	addi	a0,a0,1852 # ffffffffc0201d60 <commands+0x358>
ffffffffc020062c:	a87ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	00001517          	auipc	a0,0x1
ffffffffc020063a:	74250513          	addi	a0,a0,1858 # ffffffffc0201d78 <commands+0x370>
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
ffffffffc020064e:	74650513          	addi	a0,a0,1862 # ffffffffc0201d90 <commands+0x388>
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
ffffffffc0200666:	74650513          	addi	a0,a0,1862 # ffffffffc0201da8 <commands+0x3a0>
ffffffffc020066a:	a49ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00001517          	auipc	a0,0x1
ffffffffc0200676:	74e50513          	addi	a0,a0,1870 # ffffffffc0201dc0 <commands+0x3b8>
ffffffffc020067a:	a39ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00001517          	auipc	a0,0x1
ffffffffc0200686:	75650513          	addi	a0,a0,1878 # ffffffffc0201dd8 <commands+0x3d0>
ffffffffc020068a:	a29ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020068e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	00001517          	auipc	a0,0x1
ffffffffc020069a:	75a50513          	addi	a0,a0,1882 # ffffffffc0201df0 <commands+0x3e8>
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
ffffffffc02006b0:	00002717          	auipc	a4,0x2
ffffffffc02006b4:	82070713          	addi	a4,a4,-2016 # ffffffffc0201ed0 <commands+0x4c8>
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
ffffffffc02006c6:	7a650513          	addi	a0,a0,1958 # ffffffffc0201e68 <commands+0x460>
ffffffffc02006ca:	b2e5                	j	ffffffffc02000b2 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006cc:	00001517          	auipc	a0,0x1
ffffffffc02006d0:	77c50513          	addi	a0,a0,1916 # ffffffffc0201e48 <commands+0x440>
ffffffffc02006d4:	baf9                	j	ffffffffc02000b2 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d6:	00001517          	auipc	a0,0x1
ffffffffc02006da:	73250513          	addi	a0,a0,1842 # ffffffffc0201e08 <commands+0x400>
ffffffffc02006de:	bad1                	j	ffffffffc02000b2 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006e0:	00001517          	auipc	a0,0x1
ffffffffc02006e4:	7a850513          	addi	a0,a0,1960 # ffffffffc0201e88 <commands+0x480>
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
ffffffffc0200714:	7a050513          	addi	a0,a0,1952 # ffffffffc0201eb0 <commands+0x4a8>
ffffffffc0200718:	ba69                	j	ffffffffc02000b2 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc020071a:	00001517          	auipc	a0,0x1
ffffffffc020071e:	70e50513          	addi	a0,a0,1806 # ffffffffc0201e28 <commands+0x420>
ffffffffc0200722:	ba41                	j	ffffffffc02000b2 <cprintf>
            print_trapframe(tf);
ffffffffc0200724:	bf39                	j	ffffffffc0200642 <print_trapframe>
}
ffffffffc0200726:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200728:	06400593          	li	a1,100
ffffffffc020072c:	00001517          	auipc	a0,0x1
ffffffffc0200730:	77450513          	addi	a0,a0,1908 # ffffffffc0201ea0 <commands+0x498>
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
ffffffffc020085a:	6aa98993          	addi	s3,s3,1706 # ffffffffc0201f00 <commands+0x4f8>
            if (count > 1) {
ffffffffc020085e:	4b85                	li	s7,1
            cprintf(" ");
ffffffffc0200860:	00001b17          	auipc	s6,0x1
ffffffffc0200864:	6b0b0b13          	addi	s6,s6,1712 # ffffffffc0201f10 <commands+0x508>
                cprintf("(%d)", count);
ffffffffc0200868:	00001a97          	auipc	s5,0x1
ffffffffc020086c:	6a0a8a93          	addi	s5,s5,1696 # ffffffffc0201f08 <commands+0x500>
            cprintf("\n");
ffffffffc0200870:	00002c17          	auipc	s8,0x2
ffffffffc0200874:	898c0c13          	addi	s8,s8,-1896 # ffffffffc0202108 <commands+0x700>
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
ffffffffc02008fa:	16058263          	beqz	a1,ffffffffc0200a5e <buddy_system_init_memmap+0x170>
    if (is_power_of_two(n)) {
ffffffffc02008fe:	0005869b          	sext.w	a3,a1
    return (n & (n - 1)) == 0;
ffffffffc0200902:	fff5879b          	addiw	a5,a1,-1
ffffffffc0200906:	8ff5                	and	a5,a5,a3
    if (is_power_of_two(n)) {
ffffffffc0200908:	2781                	sext.w	a5,a5
ffffffffc020090a:	842a                	mv	s0,a0
ffffffffc020090c:	10078a63          	beqz	a5,ffffffffc0200a20 <buddy_system_init_memmap+0x132>
    while (n >>= 1) {
ffffffffc0200910:	0015d793          	srli	a5,a1,0x1
ffffffffc0200914:	10078f63          	beqz	a5,ffffffffc0200a32 <buddy_system_init_memmap+0x144>
    unsigned int order = 0;
ffffffffc0200918:	4701                	li	a4,0
    while (n >>= 1) {
ffffffffc020091a:	8385                	srli	a5,a5,0x1
        order++;
ffffffffc020091c:	2705                	addiw	a4,a4,1
    while (n >>= 1) {
ffffffffc020091e:	fff5                	bnez	a5,ffffffffc020091a <buddy_system_init_memmap+0x2c>
    return 1 << log2(n);
ffffffffc0200920:	4605                	li	a2,1
ffffffffc0200922:	00e6163b          	sllw	a2,a2,a4
    tree_size = 2 * total_pages - 1; // 总结点数
ffffffffc0200926:	4689                	li	a3,2
    for(; page != base + total_pages; page++) {
ffffffffc0200928:	00261793          	slli	a5,a2,0x2
    tree_size = 2 * total_pages - 1; // 总结点数
ffffffffc020092c:	00e6973b          	sllw	a4,a3,a4
    for(; page != base + total_pages; page++) {
ffffffffc0200930:	97b2                	add	a5,a5,a2
    tree_size = 2 * total_pages - 1; // 总结点数
ffffffffc0200932:	377d                	addiw	a4,a4,-1
    nr_free += total_pages;
ffffffffc0200934:	86b2                	mv	a3,a2
    for(; page != base + total_pages; page++) {
ffffffffc0200936:	078e                	slli	a5,a5,0x3
    nr_free += total_pages;
ffffffffc0200938:	00005517          	auipc	a0,0x5
ffffffffc020093c:	6d850513          	addi	a0,a0,1752 # ffffffffc0206010 <free_area>
ffffffffc0200940:	490c                	lw	a1,16(a0)
    total_pages = floor_to_power_of_two(n); // 向下取整到最接近2的幂, 多余的页我们这里为了方便舍弃。
ffffffffc0200942:	00006497          	auipc	s1,0x6
ffffffffc0200946:	b0648493          	addi	s1,s1,-1274 # ffffffffc0206448 <total_pages>
    tree_size = 2 * total_pages - 1; // 总结点数
ffffffffc020094a:	00006917          	auipc	s2,0x6
ffffffffc020094e:	b0290913          	addi	s2,s2,-1278 # ffffffffc020644c <tree_size>
    nr_free += total_pages;
ffffffffc0200952:	9db5                	addw	a1,a1,a3
    tree_size = 2 * total_pages - 1; // 总结点数
ffffffffc0200954:	00e92023          	sw	a4,0(s2)
    total_pages = floor_to_power_of_two(n); // 向下取整到最接近2的幂, 多余的页我们这里为了方便舍弃。
ffffffffc0200958:	c090                	sw	a2,0(s1)
    nr_free += total_pages;
ffffffffc020095a:	c90c                	sw	a1,16(a0)
    base_page = base;
ffffffffc020095c:	00006717          	auipc	a4,0x6
ffffffffc0200960:	ac873e23          	sd	s0,-1316(a4) # ffffffffc0206438 <base_page>
    for(; page != base + total_pages; page++) {
ffffffffc0200964:	97a2                	add	a5,a5,s0
ffffffffc0200966:	02f40c63          	beq	s0,a5,ffffffffc020099e <buddy_system_init_memmap+0xb0>
ffffffffc020096a:	87a2                	mv	a5,s0
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020096c:	4609                	li	a2,2
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020096e:	6798                	ld	a4,8(a5)
        assert(PageReserved(page));
ffffffffc0200970:	8b05                	andi	a4,a4,1
ffffffffc0200972:	c771                	beqz	a4,ffffffffc0200a3e <buddy_system_init_memmap+0x150>
        page->flags = page->property = 0;
ffffffffc0200974:	0007a823          	sw	zero,16(a5)
ffffffffc0200978:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc020097c:	0007a023          	sw	zero,0(a5)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200980:	00878713          	addi	a4,a5,8
ffffffffc0200984:	40c7302f          	amoor.d	zero,a2,(a4)
    for(; page != base + total_pages; page++) {
ffffffffc0200988:	4094                	lw	a3,0(s1)
ffffffffc020098a:	02878793          	addi	a5,a5,40
ffffffffc020098e:	00269713          	slli	a4,a3,0x2
ffffffffc0200992:	9736                	add	a4,a4,a3
ffffffffc0200994:	070e                	slli	a4,a4,0x3
ffffffffc0200996:	9722                	add	a4,a4,s0
ffffffffc0200998:	fce79be3          	bne	a5,a4,ffffffffc020096e <buddy_system_init_memmap+0x80>
    base->property = total_pages;
ffffffffc020099c:	2681                	sext.w	a3,a3
ffffffffc020099e:	c814                	sw	a3,16(s0)
    buddy_tree = (unsigned int *)(base + total_pages);
ffffffffc02009a0:	00006997          	auipc	s3,0x6
ffffffffc02009a4:	aa098993          	addi	s3,s3,-1376 # ffffffffc0206440 <buddy_tree>
    cprintf("\n-----------------Buddy System Initialized!------------------\n\n");
ffffffffc02009a8:	00001517          	auipc	a0,0x1
ffffffffc02009ac:	5c850513          	addi	a0,a0,1480 # ffffffffc0201f70 <commands+0x568>
    buddy_tree = (unsigned int *)(base + total_pages);
ffffffffc02009b0:	00f9b023          	sd	a5,0(s3)
    cprintf("\n-----------------Buddy System Initialized!------------------\n\n");
ffffffffc02009b4:	efeff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Base page address: %p, Total pages: %d\n", base, total_pages);
ffffffffc02009b8:	4090                	lw	a2,0(s1)
ffffffffc02009ba:	85a2                	mv	a1,s0
ffffffffc02009bc:	00001517          	auipc	a0,0x1
ffffffffc02009c0:	5f450513          	addi	a0,a0,1524 # ffffffffc0201fb0 <commands+0x5a8>
ffffffffc02009c4:	eeeff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Buddy tree address: %p, Tree size: %d\n", buddy_tree, tree_size);
ffffffffc02009c8:	00092603          	lw	a2,0(s2)
ffffffffc02009cc:	0009b583          	ld	a1,0(s3)
ffffffffc02009d0:	00001517          	auipc	a0,0x1
ffffffffc02009d4:	60850513          	addi	a0,a0,1544 # ffffffffc0201fd8 <commands+0x5d0>
ffffffffc02009d8:	edaff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    buddy_tree[0] = total_pages;
ffffffffc02009dc:	0009b683          	ld	a3,0(s3)
    unsigned int node_size = total_pages;
ffffffffc02009e0:	4090                	lw	a2,0(s1)
    for(int i = 1; i < tree_size; i++) {
ffffffffc02009e2:	4785                	li	a5,1
ffffffffc02009e4:	00468713          	addi	a4,a3,4
    buddy_tree[0] = total_pages;
ffffffffc02009e8:	c290                	sw	a2,0(a3)
    for(int i = 1; i < tree_size; i++) {
ffffffffc02009ea:	00092683          	lw	a3,0(s2)
ffffffffc02009ee:	02d7d263          	bge	a5,a3,ffffffffc0200a12 <buddy_system_init_memmap+0x124>
        if (is_power_of_two(i+1)) { // i是该层最后一个节点
ffffffffc02009f2:	0017869b          	addiw	a3,a5,1
    return (n & (n - 1)) == 0;
ffffffffc02009f6:	8ff5                	and	a5,a5,a3
        if (is_power_of_two(i+1)) { // i是该层最后一个节点
ffffffffc02009f8:	0007859b          	sext.w	a1,a5
ffffffffc02009fc:	0006879b          	sext.w	a5,a3
ffffffffc0200a00:	e199                	bnez	a1,ffffffffc0200a06 <buddy_system_init_memmap+0x118>
            node_size /= 2;
ffffffffc0200a02:	0016561b          	srliw	a2,a2,0x1
        buddy_tree[i] = node_size;
ffffffffc0200a06:	c310                	sw	a2,0(a4)
    for(int i = 1; i < tree_size; i++) {
ffffffffc0200a08:	00092683          	lw	a3,0(s2)
ffffffffc0200a0c:	0711                	addi	a4,a4,4
ffffffffc0200a0e:	fed7c2e3          	blt	a5,a3,ffffffffc02009f2 <buddy_system_init_memmap+0x104>
}
ffffffffc0200a12:	70a2                	ld	ra,40(sp)
ffffffffc0200a14:	7402                	ld	s0,32(sp)
ffffffffc0200a16:	64e2                	ld	s1,24(sp)
ffffffffc0200a18:	6942                	ld	s2,16(sp)
ffffffffc0200a1a:	69a2                	ld	s3,8(sp)
ffffffffc0200a1c:	6145                	addi	sp,sp,48
ffffffffc0200a1e:	8082                	ret
    for(; page != base + total_pages; page++) {
ffffffffc0200a20:	00269793          	slli	a5,a3,0x2
    tree_size = 2 * total_pages - 1; // 总结点数
ffffffffc0200a24:	0016971b          	slliw	a4,a3,0x1
    for(; page != base + total_pages; page++) {
ffffffffc0200a28:	97b6                	add	a5,a5,a3
    total_pages = floor_to_power_of_two(n); // 向下取整到最接近2的幂, 多余的页我们这里为了方便舍弃。
ffffffffc0200a2a:	8636                	mv	a2,a3
    tree_size = 2 * total_pages - 1; // 总结点数
ffffffffc0200a2c:	377d                	addiw	a4,a4,-1
    for(; page != base + total_pages; page++) {
ffffffffc0200a2e:	078e                	slli	a5,a5,0x3
ffffffffc0200a30:	b721                	j	ffffffffc0200938 <buddy_system_init_memmap+0x4a>
    while (n >>= 1) {
ffffffffc0200a32:	02800793          	li	a5,40
ffffffffc0200a36:	4685                	li	a3,1
ffffffffc0200a38:	4705                	li	a4,1
ffffffffc0200a3a:	4605                	li	a2,1
    return 1 << log2(n);
ffffffffc0200a3c:	bdf5                	j	ffffffffc0200938 <buddy_system_init_memmap+0x4a>
        assert(PageReserved(page));
ffffffffc0200a3e:	00001697          	auipc	a3,0x1
ffffffffc0200a42:	51a68693          	addi	a3,a3,1306 # ffffffffc0201f58 <commands+0x550>
ffffffffc0200a46:	00001617          	auipc	a2,0x1
ffffffffc0200a4a:	4da60613          	addi	a2,a2,1242 # ffffffffc0201f20 <commands+0x518>
ffffffffc0200a4e:	04200593          	li	a1,66
ffffffffc0200a52:	00001517          	auipc	a0,0x1
ffffffffc0200a56:	4e650513          	addi	a0,a0,1254 # ffffffffc0201f38 <commands+0x530>
ffffffffc0200a5a:	953ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc0200a5e:	00001697          	auipc	a3,0x1
ffffffffc0200a62:	4ba68693          	addi	a3,a3,1210 # ffffffffc0201f18 <commands+0x510>
ffffffffc0200a66:	00001617          	auipc	a2,0x1
ffffffffc0200a6a:	4ba60613          	addi	a2,a2,1210 # ffffffffc0201f20 <commands+0x518>
ffffffffc0200a6e:	03800593          	li	a1,56
ffffffffc0200a72:	00001517          	auipc	a0,0x1
ffffffffc0200a76:	4c650513          	addi	a0,a0,1222 # ffffffffc0201f38 <commands+0x530>
ffffffffc0200a7a:	933ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200a7e <buddy_system_free_pages>:
    if (is_power_of_two(n)) {
ffffffffc0200a7e:	0005869b          	sext.w	a3,a1
    return (n & (n - 1)) == 0;
ffffffffc0200a82:	fff5879b          	addiw	a5,a1,-1
static void buddy_system_free_pages(struct Page *free_page, size_t n) {
ffffffffc0200a86:	1141                	addi	sp,sp,-16
    return (n & (n - 1)) == 0;
ffffffffc0200a88:	8ff5                	and	a5,a5,a3
static void buddy_system_free_pages(struct Page *free_page, size_t n) {
ffffffffc0200a8a:	e022                	sd	s0,0(sp)
ffffffffc0200a8c:	e406                	sd	ra,8(sp)
    if (is_power_of_two(n)) {
ffffffffc0200a8e:	2781                	sext.w	a5,a5
static void buddy_system_free_pages(struct Page *free_page, size_t n) {
ffffffffc0200a90:	862e                	mv	a2,a1
ffffffffc0200a92:	842a                	mv	s0,a0
    if (is_power_of_two(n)) {
ffffffffc0200a94:	12078763          	beqz	a5,ffffffffc0200bc2 <buddy_system_free_pages+0x144>
    while (n >>= 1) {
ffffffffc0200a98:	0015d793          	srli	a5,a1,0x1
ffffffffc0200a9c:	12078a63          	beqz	a5,ffffffffc0200bd0 <buddy_system_free_pages+0x152>
    unsigned int order = 0;
ffffffffc0200aa0:	4701                	li	a4,0
    while (n >>= 1) {
ffffffffc0200aa2:	8385                	srli	a5,a5,0x1
ffffffffc0200aa4:	0007069b          	sext.w	a3,a4
        order++;
ffffffffc0200aa8:	2705                	addiw	a4,a4,1
    while (n >>= 1) {
ffffffffc0200aaa:	ffe5                	bnez	a5,ffffffffc0200aa2 <buddy_system_free_pages+0x24>
    return 1 << (log2(n) + 1);
ffffffffc0200aac:	2689                	addiw	a3,a3,2
ffffffffc0200aae:	4785                	li	a5,1
ffffffffc0200ab0:	00d7983b          	sllw	a6,a5,a3
    unsigned int size = ceil_to_power_of_two(n);
ffffffffc0200ab4:	86c2                	mv	a3,a6
    assert(size > 0);
ffffffffc0200ab6:	14068063          	beqz	a3,ffffffffc0200bf6 <buddy_system_free_pages+0x178>
    for (; page != free_page + size; page++) {
ffffffffc0200aba:	02081793          	slli	a5,a6,0x20
ffffffffc0200abe:	9381                	srli	a5,a5,0x20
ffffffffc0200ac0:	00279813          	slli	a6,a5,0x2
ffffffffc0200ac4:	983e                	add	a6,a6,a5
ffffffffc0200ac6:	080e                	slli	a6,a6,0x3
ffffffffc0200ac8:	9822                	add	a6,a6,s0
ffffffffc0200aca:	87a2                	mv	a5,s0
ffffffffc0200acc:	03040163          	beq	s0,a6,ffffffffc0200aee <buddy_system_free_pages+0x70>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200ad0:	6798                	ld	a4,8(a5)
        assert(!PageReserved(page) && !PageProperty(page));
ffffffffc0200ad2:	8b05                	andi	a4,a4,1
ffffffffc0200ad4:	10071163          	bnez	a4,ffffffffc0200bd6 <buddy_system_free_pages+0x158>
ffffffffc0200ad8:	6798                	ld	a4,8(a5)
ffffffffc0200ada:	8b09                	andi	a4,a4,2
ffffffffc0200adc:	ef6d                	bnez	a4,ffffffffc0200bd6 <buddy_system_free_pages+0x158>
        page->flags = 0;
ffffffffc0200ade:	0007b423          	sd	zero,8(a5)
ffffffffc0200ae2:	0007a023          	sw	zero,0(a5)
    for (; page != free_page + size; page++) {
ffffffffc0200ae6:	02878793          	addi	a5,a5,40
ffffffffc0200aea:	ff0793e3          	bne	a5,a6,ffffffffc0200ad0 <buddy_system_free_pages+0x52>
    nr_free += size;
ffffffffc0200aee:	00005717          	auipc	a4,0x5
ffffffffc0200af2:	52270713          	addi	a4,a4,1314 # ffffffffc0206010 <free_area>
ffffffffc0200af6:	4b1c                	lw	a5,16(a4)
    cprintf("Freed page address: %p, Requested size: %d, Freed size: %d\n", free_page, n, size);
ffffffffc0200af8:	85a2                	mv	a1,s0
ffffffffc0200afa:	00001517          	auipc	a0,0x1
ffffffffc0200afe:	50650513          	addi	a0,a0,1286 # ffffffffc0202000 <commands+0x5f8>
    nr_free += size;
ffffffffc0200b02:	9fb5                	addw	a5,a5,a3
ffffffffc0200b04:	cb1c                	sw	a5,16(a4)
    cprintf("Freed page address: %p, Requested size: %d, Freed size: %d\n", free_page, n, size);
ffffffffc0200b06:	dacff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    unsigned int offset = free_page - base_page;
ffffffffc0200b0a:	00006797          	auipc	a5,0x6
ffffffffc0200b0e:	92e7b783          	ld	a5,-1746(a5) # ffffffffc0206438 <base_page>
ffffffffc0200b12:	40f407b3          	sub	a5,s0,a5
ffffffffc0200b16:	878d                	srai	a5,a5,0x3
ffffffffc0200b18:	00002717          	auipc	a4,0x2
ffffffffc0200b1c:	b8873703          	ld	a4,-1144(a4) # ffffffffc02026a0 <error_string+0x38>
ffffffffc0200b20:	02e78733          	mul	a4,a5,a4
    unsigned int index = offset + total_pages - 1;
ffffffffc0200b24:	00006797          	auipc	a5,0x6
ffffffffc0200b28:	9247a783          	lw	a5,-1756(a5) # ffffffffc0206448 <total_pages>
ffffffffc0200b2c:	37fd                	addiw	a5,a5,-1
    while (buddy_tree[index]) {
ffffffffc0200b2e:	00006517          	auipc	a0,0x6
ffffffffc0200b32:	91253503          	ld	a0,-1774(a0) # ffffffffc0206440 <buddy_tree>
    unsigned int node_size = 1;
ffffffffc0200b36:	4585                	li	a1,1
    unsigned int index = offset + total_pages - 1;
ffffffffc0200b38:	9fb9                	addw	a5,a5,a4
    while (buddy_tree[index]) {
ffffffffc0200b3a:	02079693          	slli	a3,a5,0x20
ffffffffc0200b3e:	01e6d713          	srli	a4,a3,0x1e
ffffffffc0200b42:	972a                	add	a4,a4,a0
ffffffffc0200b44:	4314                	lw	a3,0(a4)
ffffffffc0200b46:	c285                	beqz	a3,ffffffffc0200b66 <buddy_system_free_pages+0xe8>
        node_size *= 2;
ffffffffc0200b48:	4589                	li	a1,2
        if (index == 0) break;
ffffffffc0200b4a:	e789                	bnez	a5,ffffffffc0200b54 <buddy_system_free_pages+0xd6>
ffffffffc0200b4c:	a8ad                	j	ffffffffc0200bc6 <buddy_system_free_pages+0x148>
        node_size *= 2;
ffffffffc0200b4e:	0015959b          	slliw	a1,a1,0x1
        if (index == 0) break;
ffffffffc0200b52:	cbb5                	beqz	a5,ffffffffc0200bc6 <buddy_system_free_pages+0x148>
        index = parent(index);
ffffffffc0200b54:	37fd                	addiw	a5,a5,-1
    while (buddy_tree[index]) {
ffffffffc0200b56:	0017d71b          	srliw	a4,a5,0x1
ffffffffc0200b5a:	070a                	slli	a4,a4,0x2
ffffffffc0200b5c:	972a                	add	a4,a4,a0
ffffffffc0200b5e:	4314                	lw	a3,0(a4)
        index = parent(index);
ffffffffc0200b60:	0017d79b          	srliw	a5,a5,0x1
    while (buddy_tree[index]) {
ffffffffc0200b64:	f6ed                	bnez	a3,ffffffffc0200b4e <buddy_system_free_pages+0xd0>
    buddy_tree[index] = node_size;
ffffffffc0200b66:	c30c                	sw	a1,0(a4)
    while (index) {
ffffffffc0200b68:	cba9                	beqz	a5,ffffffffc0200bba <buddy_system_free_pages+0x13c>
        index = parent(index);
ffffffffc0200b6a:	37fd                	addiw	a5,a5,-1
ffffffffc0200b6c:	0017d69b          	srliw	a3,a5,0x1
        right_size = buddy_tree[right_child(index)];
ffffffffc0200b70:	0016871b          	addiw	a4,a3,1
        left_size = buddy_tree[left_child(index)];
ffffffffc0200b74:	ffe7f613          	andi	a2,a5,-2
        right_size = buddy_tree[right_child(index)];
ffffffffc0200b78:	0017171b          	slliw	a4,a4,0x1
        left_size = buddy_tree[left_child(index)];
ffffffffc0200b7c:	2605                	addiw	a2,a2,1
        right_size = buddy_tree[right_child(index)];
ffffffffc0200b7e:	1702                	slli	a4,a4,0x20
ffffffffc0200b80:	9301                	srli	a4,a4,0x20
        left_size = buddy_tree[left_child(index)];
ffffffffc0200b82:	02061413          	slli	s0,a2,0x20
ffffffffc0200b86:	01e45613          	srli	a2,s0,0x1e
        right_size = buddy_tree[right_child(index)];
ffffffffc0200b8a:	070a                	slli	a4,a4,0x2
        left_size = buddy_tree[left_child(index)];
ffffffffc0200b8c:	962a                	add	a2,a2,a0
        right_size = buddy_tree[right_child(index)];
ffffffffc0200b8e:	972a                	add	a4,a4,a0
        left_size = buddy_tree[left_child(index)];
ffffffffc0200b90:	4210                	lw	a2,0(a2)
        right_size = buddy_tree[right_child(index)];
ffffffffc0200b92:	4318                	lw	a4,0(a4)
            buddy_tree[index] = node_size;
ffffffffc0200b94:	1682                	slli	a3,a3,0x20
        node_size *= 2;
ffffffffc0200b96:	0015959b          	slliw	a1,a1,0x1
            buddy_tree[index] = node_size;
ffffffffc0200b9a:	82f9                	srli	a3,a3,0x1e
        if (left_size + right_size == node_size) {
ffffffffc0200b9c:	00e608bb          	addw	a7,a2,a4
        node_size *= 2;
ffffffffc0200ba0:	882e                	mv	a6,a1
        index = parent(index);
ffffffffc0200ba2:	0017d79b          	srliw	a5,a5,0x1
            buddy_tree[index] = node_size;
ffffffffc0200ba6:	96aa                	add	a3,a3,a0
        if (left_size + right_size == node_size) {
ffffffffc0200ba8:	00b88663          	beq	a7,a1,ffffffffc0200bb4 <buddy_system_free_pages+0x136>
            buddy_tree[index] = (left_size > right_size) ? left_size : right_size;
ffffffffc0200bac:	8832                	mv	a6,a2
ffffffffc0200bae:	00e67363          	bgeu	a2,a4,ffffffffc0200bb4 <buddy_system_free_pages+0x136>
ffffffffc0200bb2:	883a                	mv	a6,a4
ffffffffc0200bb4:	0106a023          	sw	a6,0(a3)
    while (index) {
ffffffffc0200bb8:	fbcd                	bnez	a5,ffffffffc0200b6a <buddy_system_free_pages+0xec>
}
ffffffffc0200bba:	60a2                	ld	ra,8(sp)
ffffffffc0200bbc:	6402                	ld	s0,0(sp)
ffffffffc0200bbe:	0141                	addi	sp,sp,16
ffffffffc0200bc0:	8082                	ret
ffffffffc0200bc2:	882e                	mv	a6,a1
ffffffffc0200bc4:	bdcd                	j	ffffffffc0200ab6 <buddy_system_free_pages+0x38>
ffffffffc0200bc6:	60a2                	ld	ra,8(sp)
ffffffffc0200bc8:	6402                	ld	s0,0(sp)
    buddy_tree[index] = node_size;
ffffffffc0200bca:	c30c                	sw	a1,0(a4)
}
ffffffffc0200bcc:	0141                	addi	sp,sp,16
ffffffffc0200bce:	8082                	ret
    while (n >>= 1) {
ffffffffc0200bd0:	4689                	li	a3,2
ffffffffc0200bd2:	4809                	li	a6,2
ffffffffc0200bd4:	b5dd                	j	ffffffffc0200aba <buddy_system_free_pages+0x3c>
        assert(!PageReserved(page) && !PageProperty(page));
ffffffffc0200bd6:	00001697          	auipc	a3,0x1
ffffffffc0200bda:	47a68693          	addi	a3,a3,1146 # ffffffffc0202050 <commands+0x648>
ffffffffc0200bde:	00001617          	auipc	a2,0x1
ffffffffc0200be2:	34260613          	addi	a2,a2,834 # ffffffffc0201f20 <commands+0x518>
ffffffffc0200be6:	08e00593          	li	a1,142
ffffffffc0200bea:	00001517          	auipc	a0,0x1
ffffffffc0200bee:	34e50513          	addi	a0,a0,846 # ffffffffc0201f38 <commands+0x530>
ffffffffc0200bf2:	fbaff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(size > 0);
ffffffffc0200bf6:	00001697          	auipc	a3,0x1
ffffffffc0200bfa:	44a68693          	addi	a3,a3,1098 # ffffffffc0202040 <commands+0x638>
ffffffffc0200bfe:	00001617          	auipc	a2,0x1
ffffffffc0200c02:	32260613          	addi	a2,a2,802 # ffffffffc0201f20 <commands+0x518>
ffffffffc0200c06:	08900593          	li	a1,137
ffffffffc0200c0a:	00001517          	auipc	a0,0x1
ffffffffc0200c0e:	32e50513          	addi	a0,a0,814 # ffffffffc0201f38 <commands+0x530>
ffffffffc0200c12:	f9aff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200c16 <is_initial_state.isra.0>:
    for (int i = 0; i < tree_size; i++) {
ffffffffc0200c16:	00006897          	auipc	a7,0x6
ffffffffc0200c1a:	8368a883          	lw	a7,-1994(a7) # ffffffffc020644c <tree_size>
    int node_size = total_pages;
ffffffffc0200c1e:	00006597          	auipc	a1,0x6
ffffffffc0200c22:	82a5a583          	lw	a1,-2006(a1) # ffffffffc0206448 <total_pages>
    for (int i = 0; i < tree_size; i++) {
ffffffffc0200c26:	07105263          	blez	a7,ffffffffc0200c8a <is_initial_state.isra.0+0x74>
ffffffffc0200c2a:	00006617          	auipc	a2,0x6
ffffffffc0200c2e:	81663603          	ld	a2,-2026(a2) # ffffffffc0206440 <buddy_tree>
ffffffffc0200c32:	4781                	li	a5,0
        if (buddy_tree[i] != node_size) {
ffffffffc0200c34:	4208                	lw	a0,0(a2)
    return (n & (n - 1)) == 0;
ffffffffc0200c36:	0027871b          	addiw	a4,a5,2
    for (int i = 0; i < tree_size; i++) {
ffffffffc0200c3a:	2785                	addiw	a5,a5,1
            node_size /= 2;
ffffffffc0200c3c:	01f5d69b          	srliw	a3,a1,0x1f
    return (n & (n - 1)) == 0;
ffffffffc0200c40:	8f7d                	and	a4,a4,a5
ffffffffc0200c42:	0005881b          	sext.w	a6,a1
            node_size /= 2;
ffffffffc0200c46:	9ead                	addw	a3,a3,a1
        if (i != 0 && is_power_of_two(i + 1)) {
ffffffffc0200c48:	2701                	sext.w	a4,a4
        if (buddy_tree[i] != node_size) {
ffffffffc0200c4a:	03051563          	bne	a0,a6,ffffffffc0200c74 <is_initial_state.isra.0+0x5e>
    for (int i = 0; i < tree_size; i++) {
ffffffffc0200c4e:	03178e63          	beq	a5,a7,ffffffffc0200c8a <is_initial_state.isra.0+0x74>
        if (i != 0 && is_power_of_two(i + 1)) {
ffffffffc0200c52:	e709                	bnez	a4,ffffffffc0200c5c <is_initial_state.isra.0+0x46>
            node_size /= 2;
ffffffffc0200c54:	4016d59b          	sraiw	a1,a3,0x1
ffffffffc0200c58:	0005881b          	sext.w	a6,a1
        if (buddy_tree[i] != node_size) {
ffffffffc0200c5c:	4248                	lw	a0,4(a2)
    return (n & (n - 1)) == 0;
ffffffffc0200c5e:	0027871b          	addiw	a4,a5,2
    for (int i = 0; i < tree_size; i++) {
ffffffffc0200c62:	2785                	addiw	a5,a5,1
            node_size /= 2;
ffffffffc0200c64:	01f5d69b          	srliw	a3,a1,0x1f
    return (n & (n - 1)) == 0;
ffffffffc0200c68:	8f7d                	and	a4,a4,a5
ffffffffc0200c6a:	0611                	addi	a2,a2,4
            node_size /= 2;
ffffffffc0200c6c:	9ead                	addw	a3,a3,a1
        if (i != 0 && is_power_of_two(i + 1)) {
ffffffffc0200c6e:	2701                	sext.w	a4,a4
        if (buddy_tree[i] != node_size) {
ffffffffc0200c70:	fd050fe3          	beq	a0,a6,ffffffffc0200c4e <is_initial_state.isra.0+0x38>
static int is_initial_state(void) {
ffffffffc0200c74:	1141                	addi	sp,sp,-16
            cprintf("Buddy tree is not in initial state.\n");
ffffffffc0200c76:	00001517          	auipc	a0,0x1
ffffffffc0200c7a:	40a50513          	addi	a0,a0,1034 # ffffffffc0202080 <commands+0x678>
static int is_initial_state(void) {
ffffffffc0200c7e:	e406                	sd	ra,8(sp)
            cprintf("Buddy tree is not in initial state.\n");
ffffffffc0200c80:	c32ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
}
ffffffffc0200c84:	60a2                	ld	ra,8(sp)
ffffffffc0200c86:	0141                	addi	sp,sp,16
            simplified_print_tree();
ffffffffc0200c88:	be59                	j	ffffffffc020081e <simplified_print_tree>
    cprintf("Buddy tree is in initial state.\n");
ffffffffc0200c8a:	00001517          	auipc	a0,0x1
ffffffffc0200c8e:	41e50513          	addi	a0,a0,1054 # ffffffffc02020a8 <commands+0x6a0>
ffffffffc0200c92:	c20ff06f          	j	ffffffffc02000b2 <cprintf>

ffffffffc0200c96 <buddy_check>:

// 检查buddy_tree的功能
static void buddy_check(void) {
ffffffffc0200c96:	7179                	addi	sp,sp,-48
    cprintf("\n-----------------Buddy Check Begins!------------------\n\n");
ffffffffc0200c98:	00001517          	auipc	a0,0x1
ffffffffc0200c9c:	43850513          	addi	a0,a0,1080 # ffffffffc02020d0 <commands+0x6c8>
static void buddy_check(void) {
ffffffffc0200ca0:	f406                	sd	ra,40(sp)
ffffffffc0200ca2:	f022                	sd	s0,32(sp)
ffffffffc0200ca4:	ec26                	sd	s1,24(sp)
ffffffffc0200ca6:	e84a                	sd	s2,16(sp)
ffffffffc0200ca8:	e44e                	sd	s3,8(sp)
    cprintf("\n-----------------Buddy Check Begins!------------------\n\n");
ffffffffc0200caa:	c08ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    simplified_print_tree();
ffffffffc0200cae:	b71ff0ef          	jal	ra,ffffffffc020081e <simplified_print_tree>

    cprintf("\n---------------------First Check!---------------------\n\n");
ffffffffc0200cb2:	00001517          	auipc	a0,0x1
ffffffffc0200cb6:	45e50513          	addi	a0,a0,1118 # ffffffffc0202110 <commands+0x708>
ffffffffc0200cba:	bf8ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200cbe:	4505                	li	a0,1
ffffffffc0200cc0:	388000ef          	jal	ra,ffffffffc0201048 <alloc_pages>
ffffffffc0200cc4:	10050063          	beqz	a0,ffffffffc0200dc4 <buddy_check+0x12e>
ffffffffc0200cc8:	842a                	mv	s0,a0
    simplified_print_tree();
ffffffffc0200cca:	b55ff0ef          	jal	ra,ffffffffc020081e <simplified_print_tree>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200cce:	4505                	li	a0,1
ffffffffc0200cd0:	378000ef          	jal	ra,ffffffffc0201048 <alloc_pages>
ffffffffc0200cd4:	892a                	mv	s2,a0
ffffffffc0200cd6:	1c050763          	beqz	a0,ffffffffc0200ea4 <buddy_check+0x20e>
    simplified_print_tree();
ffffffffc0200cda:	b45ff0ef          	jal	ra,ffffffffc020081e <simplified_print_tree>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200cde:	4505                	li	a0,1
ffffffffc0200ce0:	368000ef          	jal	ra,ffffffffc0201048 <alloc_pages>
ffffffffc0200ce4:	84aa                	mv	s1,a0
ffffffffc0200ce6:	18050f63          	beqz	a0,ffffffffc0200e84 <buddy_check+0x1ee>
    simplified_print_tree();
ffffffffc0200cea:	b35ff0ef          	jal	ra,ffffffffc020081e <simplified_print_tree>
    free_page(p0);
ffffffffc0200cee:	8522                	mv	a0,s0
ffffffffc0200cf0:	4585                	li	a1,1
ffffffffc0200cf2:	394000ef          	jal	ra,ffffffffc0201086 <free_pages>
    simplified_print_tree();
ffffffffc0200cf6:	b29ff0ef          	jal	ra,ffffffffc020081e <simplified_print_tree>
    free_page(p1);
ffffffffc0200cfa:	4585                	li	a1,1
ffffffffc0200cfc:	854a                	mv	a0,s2
ffffffffc0200cfe:	388000ef          	jal	ra,ffffffffc0201086 <free_pages>
    simplified_print_tree();
ffffffffc0200d02:	b1dff0ef          	jal	ra,ffffffffc020081e <simplified_print_tree>
    free_page(p2);
ffffffffc0200d06:	4585                	li	a1,1
ffffffffc0200d08:	8526                	mv	a0,s1
ffffffffc0200d0a:	37c000ef          	jal	ra,ffffffffc0201086 <free_pages>
    is_initial_state();
ffffffffc0200d0e:	f09ff0ef          	jal	ra,ffffffffc0200c16 <is_initial_state.isra.0>

    cprintf("\n---------------------Second Check!---------------------\n\n");
ffffffffc0200d12:	00001517          	auipc	a0,0x1
ffffffffc0200d16:	49e50513          	addi	a0,a0,1182 # ffffffffc02021b0 <commands+0x7a8>
ffffffffc0200d1a:	b98ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    struct Page *A, *B, *C, *D, *E;
    A = B = C = D = E = NULL;
    assert((A = alloc_pages(100)) != NULL);
ffffffffc0200d1e:	06400513          	li	a0,100
ffffffffc0200d22:	326000ef          	jal	ra,ffffffffc0201048 <alloc_pages>
ffffffffc0200d26:	842a                	mv	s0,a0
ffffffffc0200d28:	12050e63          	beqz	a0,ffffffffc0200e64 <buddy_check+0x1ce>
    simplified_print_tree();
ffffffffc0200d2c:	af3ff0ef          	jal	ra,ffffffffc020081e <simplified_print_tree>
    assert((B = alloc_pages(240)) != NULL);
ffffffffc0200d30:	0f000513          	li	a0,240
ffffffffc0200d34:	314000ef          	jal	ra,ffffffffc0201048 <alloc_pages>
ffffffffc0200d38:	84aa                	mv	s1,a0
ffffffffc0200d3a:	10050563          	beqz	a0,ffffffffc0200e44 <buddy_check+0x1ae>
    simplified_print_tree();
ffffffffc0200d3e:	ae1ff0ef          	jal	ra,ffffffffc020081e <simplified_print_tree>
    assert((C = alloc_pages(64)) != NULL);
ffffffffc0200d42:	04000513          	li	a0,64
ffffffffc0200d46:	302000ef          	jal	ra,ffffffffc0201048 <alloc_pages>
ffffffffc0200d4a:	892a                	mv	s2,a0
ffffffffc0200d4c:	0c050c63          	beqz	a0,ffffffffc0200e24 <buddy_check+0x18e>
    simplified_print_tree();
ffffffffc0200d50:	acfff0ef          	jal	ra,ffffffffc020081e <simplified_print_tree>
    assert((D = alloc_pages(253)) != NULL);
ffffffffc0200d54:	0fd00513          	li	a0,253
ffffffffc0200d58:	2f0000ef          	jal	ra,ffffffffc0201048 <alloc_pages>
ffffffffc0200d5c:	89aa                	mv	s3,a0
ffffffffc0200d5e:	c15d                	beqz	a0,ffffffffc0200e04 <buddy_check+0x16e>
    simplified_print_tree();
ffffffffc0200d60:	abfff0ef          	jal	ra,ffffffffc020081e <simplified_print_tree>
    free_pages(B, 240);
ffffffffc0200d64:	0f000593          	li	a1,240
ffffffffc0200d68:	8526                	mv	a0,s1
ffffffffc0200d6a:	31c000ef          	jal	ra,ffffffffc0201086 <free_pages>
    simplified_print_tree();
ffffffffc0200d6e:	ab1ff0ef          	jal	ra,ffffffffc020081e <simplified_print_tree>
    free_pages(A, 100);
ffffffffc0200d72:	8522                	mv	a0,s0
ffffffffc0200d74:	06400593          	li	a1,100
ffffffffc0200d78:	30e000ef          	jal	ra,ffffffffc0201086 <free_pages>
    simplified_print_tree();
ffffffffc0200d7c:	aa3ff0ef          	jal	ra,ffffffffc020081e <simplified_print_tree>
    assert((E = alloc_pages(75)) != NULL);
ffffffffc0200d80:	04b00513          	li	a0,75
ffffffffc0200d84:	2c4000ef          	jal	ra,ffffffffc0201048 <alloc_pages>
ffffffffc0200d88:	842a                	mv	s0,a0
ffffffffc0200d8a:	cd29                	beqz	a0,ffffffffc0200de4 <buddy_check+0x14e>
    simplified_print_tree();
ffffffffc0200d8c:	a93ff0ef          	jal	ra,ffffffffc020081e <simplified_print_tree>
    free_pages(C, 64);
ffffffffc0200d90:	854a                	mv	a0,s2
ffffffffc0200d92:	04000593          	li	a1,64
ffffffffc0200d96:	2f0000ef          	jal	ra,ffffffffc0201086 <free_pages>
    simplified_print_tree();
ffffffffc0200d9a:	a85ff0ef          	jal	ra,ffffffffc020081e <simplified_print_tree>
    free_pages(E, 75);
ffffffffc0200d9e:	8522                	mv	a0,s0
ffffffffc0200da0:	04b00593          	li	a1,75
ffffffffc0200da4:	2e2000ef          	jal	ra,ffffffffc0201086 <free_pages>
    simplified_print_tree();
ffffffffc0200da8:	a77ff0ef          	jal	ra,ffffffffc020081e <simplified_print_tree>
    free_pages(D, 253);
ffffffffc0200dac:	854e                	mv	a0,s3
ffffffffc0200dae:	0fd00593          	li	a1,253
ffffffffc0200db2:	2d4000ef          	jal	ra,ffffffffc0201086 <free_pages>
    is_initial_state();
}
ffffffffc0200db6:	7402                	ld	s0,32(sp)
ffffffffc0200db8:	70a2                	ld	ra,40(sp)
ffffffffc0200dba:	64e2                	ld	s1,24(sp)
ffffffffc0200dbc:	6942                	ld	s2,16(sp)
ffffffffc0200dbe:	69a2                	ld	s3,8(sp)
ffffffffc0200dc0:	6145                	addi	sp,sp,48
    is_initial_state();
ffffffffc0200dc2:	bd91                	j	ffffffffc0200c16 <is_initial_state.isra.0>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200dc4:	00001697          	auipc	a3,0x1
ffffffffc0200dc8:	38c68693          	addi	a3,a3,908 # ffffffffc0202150 <commands+0x748>
ffffffffc0200dcc:	00001617          	auipc	a2,0x1
ffffffffc0200dd0:	15460613          	addi	a2,a2,340 # ffffffffc0201f20 <commands+0x518>
ffffffffc0200dd4:	0ec00593          	li	a1,236
ffffffffc0200dd8:	00001517          	auipc	a0,0x1
ffffffffc0200ddc:	16050513          	addi	a0,a0,352 # ffffffffc0201f38 <commands+0x530>
ffffffffc0200de0:	dccff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((E = alloc_pages(75)) != NULL);
ffffffffc0200de4:	00001697          	auipc	a3,0x1
ffffffffc0200de8:	48c68693          	addi	a3,a3,1164 # ffffffffc0202270 <commands+0x868>
ffffffffc0200dec:	00001617          	auipc	a2,0x1
ffffffffc0200df0:	13460613          	addi	a2,a2,308 # ffffffffc0201f20 <commands+0x518>
ffffffffc0200df4:	10800593          	li	a1,264
ffffffffc0200df8:	00001517          	auipc	a0,0x1
ffffffffc0200dfc:	14050513          	addi	a0,a0,320 # ffffffffc0201f38 <commands+0x530>
ffffffffc0200e00:	dacff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((D = alloc_pages(253)) != NULL);
ffffffffc0200e04:	00001697          	auipc	a3,0x1
ffffffffc0200e08:	44c68693          	addi	a3,a3,1100 # ffffffffc0202250 <commands+0x848>
ffffffffc0200e0c:	00001617          	auipc	a2,0x1
ffffffffc0200e10:	11460613          	addi	a2,a2,276 # ffffffffc0201f20 <commands+0x518>
ffffffffc0200e14:	10200593          	li	a1,258
ffffffffc0200e18:	00001517          	auipc	a0,0x1
ffffffffc0200e1c:	12050513          	addi	a0,a0,288 # ffffffffc0201f38 <commands+0x530>
ffffffffc0200e20:	d8cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((C = alloc_pages(64)) != NULL);
ffffffffc0200e24:	00001697          	auipc	a3,0x1
ffffffffc0200e28:	40c68693          	addi	a3,a3,1036 # ffffffffc0202230 <commands+0x828>
ffffffffc0200e2c:	00001617          	auipc	a2,0x1
ffffffffc0200e30:	0f460613          	addi	a2,a2,244 # ffffffffc0201f20 <commands+0x518>
ffffffffc0200e34:	10000593          	li	a1,256
ffffffffc0200e38:	00001517          	auipc	a0,0x1
ffffffffc0200e3c:	10050513          	addi	a0,a0,256 # ffffffffc0201f38 <commands+0x530>
ffffffffc0200e40:	d6cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((B = alloc_pages(240)) != NULL);
ffffffffc0200e44:	00001697          	auipc	a3,0x1
ffffffffc0200e48:	3cc68693          	addi	a3,a3,972 # ffffffffc0202210 <commands+0x808>
ffffffffc0200e4c:	00001617          	auipc	a2,0x1
ffffffffc0200e50:	0d460613          	addi	a2,a2,212 # ffffffffc0201f20 <commands+0x518>
ffffffffc0200e54:	0fe00593          	li	a1,254
ffffffffc0200e58:	00001517          	auipc	a0,0x1
ffffffffc0200e5c:	0e050513          	addi	a0,a0,224 # ffffffffc0201f38 <commands+0x530>
ffffffffc0200e60:	d4cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((A = alloc_pages(100)) != NULL);
ffffffffc0200e64:	00001697          	auipc	a3,0x1
ffffffffc0200e68:	38c68693          	addi	a3,a3,908 # ffffffffc02021f0 <commands+0x7e8>
ffffffffc0200e6c:	00001617          	auipc	a2,0x1
ffffffffc0200e70:	0b460613          	addi	a2,a2,180 # ffffffffc0201f20 <commands+0x518>
ffffffffc0200e74:	0fc00593          	li	a1,252
ffffffffc0200e78:	00001517          	auipc	a0,0x1
ffffffffc0200e7c:	0c050513          	addi	a0,a0,192 # ffffffffc0201f38 <commands+0x530>
ffffffffc0200e80:	d2cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200e84:	00001697          	auipc	a3,0x1
ffffffffc0200e88:	30c68693          	addi	a3,a3,780 # ffffffffc0202190 <commands+0x788>
ffffffffc0200e8c:	00001617          	auipc	a2,0x1
ffffffffc0200e90:	09460613          	addi	a2,a2,148 # ffffffffc0201f20 <commands+0x518>
ffffffffc0200e94:	0f000593          	li	a1,240
ffffffffc0200e98:	00001517          	auipc	a0,0x1
ffffffffc0200e9c:	0a050513          	addi	a0,a0,160 # ffffffffc0201f38 <commands+0x530>
ffffffffc0200ea0:	d0cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200ea4:	00001697          	auipc	a3,0x1
ffffffffc0200ea8:	2cc68693          	addi	a3,a3,716 # ffffffffc0202170 <commands+0x768>
ffffffffc0200eac:	00001617          	auipc	a2,0x1
ffffffffc0200eb0:	07460613          	addi	a2,a2,116 # ffffffffc0201f20 <commands+0x518>
ffffffffc0200eb4:	0ee00593          	li	a1,238
ffffffffc0200eb8:	00001517          	auipc	a0,0x1
ffffffffc0200ebc:	08050513          	addi	a0,a0,128 # ffffffffc0201f38 <commands+0x530>
ffffffffc0200ec0:	cecff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200ec4 <buddy_system_alloc_pages>:
static struct Page *buddy_system_alloc_pages(size_t n) {
ffffffffc0200ec4:	1141                	addi	sp,sp,-16
ffffffffc0200ec6:	e406                	sd	ra,8(sp)
ffffffffc0200ec8:	e022                	sd	s0,0(sp)
    assert(n > 0);
ffffffffc0200eca:	14050f63          	beqz	a0,ffffffffc0201028 <buddy_system_alloc_pages+0x164>
    if (is_power_of_two(n)) {
ffffffffc0200ece:	0005069b          	sext.w	a3,a0
    return (n & (n - 1)) == 0;
ffffffffc0200ed2:	fff5079b          	addiw	a5,a0,-1
ffffffffc0200ed6:	8ff5                	and	a5,a5,a3
    if (is_power_of_two(n)) {
ffffffffc0200ed8:	2781                	sext.w	a5,a5
ffffffffc0200eda:	862a                	mv	a2,a0
    return (n & (n - 1)) == 0;
ffffffffc0200edc:	8e2a                	mv	t3,a0
    if (is_power_of_two(n)) {
ffffffffc0200ede:	c385                	beqz	a5,ffffffffc0200efe <buddy_system_alloc_pages+0x3a>
    while (n >>= 1) {
ffffffffc0200ee0:	00155793          	srli	a5,a0,0x1
ffffffffc0200ee4:	12078f63          	beqz	a5,ffffffffc0201022 <buddy_system_alloc_pages+0x15e>
    unsigned int order = 0;
ffffffffc0200ee8:	4701                	li	a4,0
    while (n >>= 1) {
ffffffffc0200eea:	8385                	srli	a5,a5,0x1
ffffffffc0200eec:	00070e1b          	sext.w	t3,a4
        order++;
ffffffffc0200ef0:	2705                	addiw	a4,a4,1
    while (n >>= 1) {
ffffffffc0200ef2:	ffe5                	bnez	a5,ffffffffc0200eea <buddy_system_alloc_pages+0x26>
    return 1 << (log2(n) + 1);
ffffffffc0200ef4:	2e09                	addiw	t3,t3,2
ffffffffc0200ef6:	4785                	li	a5,1
ffffffffc0200ef8:	01c79e3b          	sllw	t3,a5,t3
    unsigned int size = ceil_to_power_of_two(n);;
ffffffffc0200efc:	86f2                	mv	a3,t3
    if (buddy_tree[index] < size) {
ffffffffc0200efe:	00005817          	auipc	a6,0x5
ffffffffc0200f02:	54283803          	ld	a6,1346(a6) # ffffffffc0206440 <buddy_tree>
ffffffffc0200f06:	00082783          	lw	a5,0(a6)
ffffffffc0200f0a:	10d7e063          	bltu	a5,a3,ffffffffc020100a <buddy_system_alloc_pages+0x146>
    for (node_size = total_pages; node_size != size; node_size /= 2) {
ffffffffc0200f0e:	00005517          	auipc	a0,0x5
ffffffffc0200f12:	53a50513          	addi	a0,a0,1338 # ffffffffc0206448 <total_pages>
ffffffffc0200f16:	410c                	lw	a1,0(a0)
ffffffffc0200f18:	0ed58f63          	beq	a1,a3,ffffffffc0201016 <buddy_system_alloc_pages+0x152>
    unsigned int index = 0;
ffffffffc0200f1c:	4781                	li	a5,0
        if (buddy_tree[left_child(index)] >= size) {
ffffffffc0200f1e:	0017989b          	slliw	a7,a5,0x1
ffffffffc0200f22:	0018879b          	addiw	a5,a7,1
ffffffffc0200f26:	02079413          	slli	s0,a5,0x20
ffffffffc0200f2a:	01e45713          	srli	a4,s0,0x1e
ffffffffc0200f2e:	9742                	add	a4,a4,a6
ffffffffc0200f30:	4318                	lw	a4,0(a4)
ffffffffc0200f32:	00d77463          	bgeu	a4,a3,ffffffffc0200f3a <buddy_system_alloc_pages+0x76>
            index = right_child(index);
ffffffffc0200f36:	0028879b          	addiw	a5,a7,2
    for (node_size = total_pages; node_size != size; node_size /= 2) {
ffffffffc0200f3a:	0015d59b          	srliw	a1,a1,0x1
ffffffffc0200f3e:	fed590e3          	bne	a1,a3,ffffffffc0200f1e <buddy_system_alloc_pages+0x5a>
    offset = (index + 1) * node_size - total_pages;
ffffffffc0200f42:	0017841b          	addiw	s0,a5,1
ffffffffc0200f46:	02d4043b          	mulw	s0,s0,a3
    buddy_tree[index] = 0;
ffffffffc0200f4a:	02079593          	slli	a1,a5,0x20
ffffffffc0200f4e:	01e5d713          	srli	a4,a1,0x1e
ffffffffc0200f52:	9742                	add	a4,a4,a6
ffffffffc0200f54:	00072023          	sw	zero,0(a4)
    offset = (index + 1) * node_size - total_pages;
ffffffffc0200f58:	4118                	lw	a4,0(a0)
ffffffffc0200f5a:	9c19                	subw	s0,s0,a4
    while (index) {
ffffffffc0200f5c:	c3b9                	beqz	a5,ffffffffc0200fa2 <buddy_system_alloc_pages+0xde>
        index = parent(index);
ffffffffc0200f5e:	37fd                	addiw	a5,a5,-1
        buddy_tree[index] = (buddy_tree[left_child(index)] > buddy_tree[right_child(index)]) ?
ffffffffc0200f60:	ffe7f713          	andi	a4,a5,-2
ffffffffc0200f64:	ffe7f593          	andi	a1,a5,-2
ffffffffc0200f68:	2709                	addiw	a4,a4,2
ffffffffc0200f6a:	2585                	addiw	a1,a1,1
ffffffffc0200f6c:	1702                	slli	a4,a4,0x20
ffffffffc0200f6e:	02059513          	slli	a0,a1,0x20
ffffffffc0200f72:	9301                	srli	a4,a4,0x20
ffffffffc0200f74:	01e55593          	srli	a1,a0,0x1e
ffffffffc0200f78:	070a                	slli	a4,a4,0x2
ffffffffc0200f7a:	9742                	add	a4,a4,a6
ffffffffc0200f7c:	95c2                	add	a1,a1,a6
                            buddy_tree[left_child(index)] : buddy_tree[right_child(index)];
ffffffffc0200f7e:	0005a883          	lw	a7,0(a1)
ffffffffc0200f82:	430c                	lw	a1,0(a4)
        buddy_tree[index] = (buddy_tree[left_child(index)] > buddy_tree[right_child(index)]) ?
ffffffffc0200f84:	0017d71b          	srliw	a4,a5,0x1
ffffffffc0200f88:	070a                	slli	a4,a4,0x2
                            buddy_tree[left_child(index)] : buddy_tree[right_child(index)];
ffffffffc0200f8a:	0005831b          	sext.w	t1,a1
ffffffffc0200f8e:	0008851b          	sext.w	a0,a7
        index = parent(index);
ffffffffc0200f92:	0017d79b          	srliw	a5,a5,0x1
        buddy_tree[index] = (buddy_tree[left_child(index)] > buddy_tree[right_child(index)]) ?
ffffffffc0200f96:	9742                	add	a4,a4,a6
                            buddy_tree[left_child(index)] : buddy_tree[right_child(index)];
ffffffffc0200f98:	00a37363          	bgeu	t1,a0,ffffffffc0200f9e <buddy_system_alloc_pages+0xda>
ffffffffc0200f9c:	85c6                	mv	a1,a7
        buddy_tree[index] = (buddy_tree[left_child(index)] > buddy_tree[right_child(index)]) ?
ffffffffc0200f9e:	c30c                	sw	a1,0(a4)
    while (index) {
ffffffffc0200fa0:	ffdd                	bnez	a5,ffffffffc0200f5e <buddy_system_alloc_pages+0x9a>
    page = base_page + offset;
ffffffffc0200fa2:	02041793          	slli	a5,s0,0x20
ffffffffc0200fa6:	9381                	srli	a5,a5,0x20
    for (struct Page *p = page; p < page + size; p++) {
ffffffffc0200fa8:	1e02                	slli	t3,t3,0x20
ffffffffc0200faa:	020e5e13          	srli	t3,t3,0x20
    page = base_page + offset;
ffffffffc0200fae:	00279413          	slli	s0,a5,0x2
ffffffffc0200fb2:	97a2                	add	a5,a5,s0
    for (struct Page *p = page; p < page + size; p++) {
ffffffffc0200fb4:	002e1713          	slli	a4,t3,0x2
    page = base_page + offset;
ffffffffc0200fb8:	078e                	slli	a5,a5,0x3
    for (struct Page *p = page; p < page + size; p++) {
ffffffffc0200fba:	9772                	add	a4,a4,t3
    page = base_page + offset;
ffffffffc0200fbc:	00005417          	auipc	s0,0x5
ffffffffc0200fc0:	47c43403          	ld	s0,1148(s0) # ffffffffc0206438 <base_page>
ffffffffc0200fc4:	943e                	add	s0,s0,a5
    for (struct Page *p = page; p < page + size; p++) {
ffffffffc0200fc6:	070e                	slli	a4,a4,0x3
    page->property = size;
ffffffffc0200fc8:	c814                	sw	a3,16(s0)
    for (struct Page *p = page; p < page + size; p++) {
ffffffffc0200fca:	9722                	add	a4,a4,s0
ffffffffc0200fcc:	87a2                	mv	a5,s0
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200fce:	55f5                	li	a1,-3
ffffffffc0200fd0:	00e47a63          	bgeu	s0,a4,ffffffffc0200fe4 <buddy_system_alloc_pages+0x120>
ffffffffc0200fd4:	00878513          	addi	a0,a5,8
ffffffffc0200fd8:	60b5302f          	amoand.d	zero,a1,(a0)
ffffffffc0200fdc:	02878793          	addi	a5,a5,40
ffffffffc0200fe0:	fee7eae3          	bltu	a5,a4,ffffffffc0200fd4 <buddy_system_alloc_pages+0x110>
    nr_free -= size;
ffffffffc0200fe4:	00005717          	auipc	a4,0x5
ffffffffc0200fe8:	02c70713          	addi	a4,a4,44 # ffffffffc0206010 <free_area>
ffffffffc0200fec:	4b1c                	lw	a5,16(a4)
    cprintf("Allocated page address: %p, Requested size: %d, Allocated size: %d\n", page, n, size);
ffffffffc0200fee:	85a2                	mv	a1,s0
ffffffffc0200ff0:	00001517          	auipc	a0,0x1
ffffffffc0200ff4:	2a050513          	addi	a0,a0,672 # ffffffffc0202290 <commands+0x888>
    nr_free -= size;
ffffffffc0200ff8:	9f95                	subw	a5,a5,a3
ffffffffc0200ffa:	cb1c                	sw	a5,16(a4)
    cprintf("Allocated page address: %p, Requested size: %d, Allocated size: %d\n", page, n, size);
ffffffffc0200ffc:	8b6ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
}
ffffffffc0201000:	60a2                	ld	ra,8(sp)
ffffffffc0201002:	8522                	mv	a0,s0
ffffffffc0201004:	6402                	ld	s0,0(sp)
ffffffffc0201006:	0141                	addi	sp,sp,16
ffffffffc0201008:	8082                	ret
        return NULL;
ffffffffc020100a:	4401                	li	s0,0
}
ffffffffc020100c:	60a2                	ld	ra,8(sp)
ffffffffc020100e:	8522                	mv	a0,s0
ffffffffc0201010:	6402                	ld	s0,0(sp)
ffffffffc0201012:	0141                	addi	sp,sp,16
ffffffffc0201014:	8082                	ret
    buddy_tree[index] = 0;
ffffffffc0201016:	00082023          	sw	zero,0(a6)
    offset = (index + 1) * node_size - total_pages;
ffffffffc020101a:	411c                	lw	a5,0(a0)
ffffffffc020101c:	40f6843b          	subw	s0,a3,a5
    while (index) {
ffffffffc0201020:	b749                	j	ffffffffc0200fa2 <buddy_system_alloc_pages+0xde>
    while (n >>= 1) {
ffffffffc0201022:	4689                	li	a3,2
ffffffffc0201024:	4e09                	li	t3,2
    return order;
ffffffffc0201026:	bde1                	j	ffffffffc0200efe <buddy_system_alloc_pages+0x3a>
    assert(n > 0);
ffffffffc0201028:	00001697          	auipc	a3,0x1
ffffffffc020102c:	ef068693          	addi	a3,a3,-272 # ffffffffc0201f18 <commands+0x510>
ffffffffc0201030:	00001617          	auipc	a2,0x1
ffffffffc0201034:	ef060613          	addi	a2,a2,-272 # ffffffffc0201f20 <commands+0x518>
ffffffffc0201038:	05c00593          	li	a1,92
ffffffffc020103c:	00001517          	auipc	a0,0x1
ffffffffc0201040:	efc50513          	addi	a0,a0,-260 # ffffffffc0201f38 <commands+0x530>
ffffffffc0201044:	b68ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0201048 <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201048:	100027f3          	csrr	a5,sstatus
ffffffffc020104c:	8b89                	andi	a5,a5,2
ffffffffc020104e:	e799                	bnez	a5,ffffffffc020105c <alloc_pages+0x14>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0201050:	00005797          	auipc	a5,0x5
ffffffffc0201054:	4107b783          	ld	a5,1040(a5) # ffffffffc0206460 <pmm_manager>
ffffffffc0201058:	6f9c                	ld	a5,24(a5)
ffffffffc020105a:	8782                	jr	a5
struct Page *alloc_pages(size_t n) {
ffffffffc020105c:	1141                	addi	sp,sp,-16
ffffffffc020105e:	e406                	sd	ra,8(sp)
ffffffffc0201060:	e022                	sd	s0,0(sp)
ffffffffc0201062:	842a                	mv	s0,a0
        intr_disable();
ffffffffc0201064:	bfaff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201068:	00005797          	auipc	a5,0x5
ffffffffc020106c:	3f87b783          	ld	a5,1016(a5) # ffffffffc0206460 <pmm_manager>
ffffffffc0201070:	6f9c                	ld	a5,24(a5)
ffffffffc0201072:	8522                	mv	a0,s0
ffffffffc0201074:	9782                	jalr	a5
ffffffffc0201076:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc0201078:	be0ff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc020107c:	60a2                	ld	ra,8(sp)
ffffffffc020107e:	8522                	mv	a0,s0
ffffffffc0201080:	6402                	ld	s0,0(sp)
ffffffffc0201082:	0141                	addi	sp,sp,16
ffffffffc0201084:	8082                	ret

ffffffffc0201086 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201086:	100027f3          	csrr	a5,sstatus
ffffffffc020108a:	8b89                	andi	a5,a5,2
ffffffffc020108c:	e799                	bnez	a5,ffffffffc020109a <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc020108e:	00005797          	auipc	a5,0x5
ffffffffc0201092:	3d27b783          	ld	a5,978(a5) # ffffffffc0206460 <pmm_manager>
ffffffffc0201096:	739c                	ld	a5,32(a5)
ffffffffc0201098:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc020109a:	1101                	addi	sp,sp,-32
ffffffffc020109c:	ec06                	sd	ra,24(sp)
ffffffffc020109e:	e822                	sd	s0,16(sp)
ffffffffc02010a0:	e426                	sd	s1,8(sp)
ffffffffc02010a2:	842a                	mv	s0,a0
ffffffffc02010a4:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc02010a6:	bb8ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02010aa:	00005797          	auipc	a5,0x5
ffffffffc02010ae:	3b67b783          	ld	a5,950(a5) # ffffffffc0206460 <pmm_manager>
ffffffffc02010b2:	739c                	ld	a5,32(a5)
ffffffffc02010b4:	85a6                	mv	a1,s1
ffffffffc02010b6:	8522                	mv	a0,s0
ffffffffc02010b8:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc02010ba:	6442                	ld	s0,16(sp)
ffffffffc02010bc:	60e2                	ld	ra,24(sp)
ffffffffc02010be:	64a2                	ld	s1,8(sp)
ffffffffc02010c0:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02010c2:	b96ff06f          	j	ffffffffc0200458 <intr_enable>

ffffffffc02010c6 <pmm_init>:
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc02010c6:	00001797          	auipc	a5,0x1
ffffffffc02010ca:	23278793          	addi	a5,a5,562 # ffffffffc02022f8 <buddy_system_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02010ce:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc02010d0:	1101                	addi	sp,sp,-32
ffffffffc02010d2:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02010d4:	00001517          	auipc	a0,0x1
ffffffffc02010d8:	25c50513          	addi	a0,a0,604 # ffffffffc0202330 <buddy_system_pmm_manager+0x38>
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc02010dc:	00005497          	auipc	s1,0x5
ffffffffc02010e0:	38448493          	addi	s1,s1,900 # ffffffffc0206460 <pmm_manager>
void pmm_init(void) {
ffffffffc02010e4:	ec06                	sd	ra,24(sp)
ffffffffc02010e6:	e822                	sd	s0,16(sp)
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc02010e8:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02010ea:	fc9fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pmm_manager->init();
ffffffffc02010ee:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02010f0:	00005417          	auipc	s0,0x5
ffffffffc02010f4:	38840413          	addi	s0,s0,904 # ffffffffc0206478 <va_pa_offset>
    pmm_manager->init();
ffffffffc02010f8:	679c                	ld	a5,8(a5)
ffffffffc02010fa:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02010fc:	57f5                	li	a5,-3
ffffffffc02010fe:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0201100:	00001517          	auipc	a0,0x1
ffffffffc0201104:	24850513          	addi	a0,a0,584 # ffffffffc0202348 <buddy_system_pmm_manager+0x50>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201108:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc020110a:	fa9fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc020110e:	46c5                	li	a3,17
ffffffffc0201110:	06ee                	slli	a3,a3,0x1b
ffffffffc0201112:	40100613          	li	a2,1025
ffffffffc0201116:	16fd                	addi	a3,a3,-1
ffffffffc0201118:	07e005b7          	lui	a1,0x7e00
ffffffffc020111c:	0656                	slli	a2,a2,0x15
ffffffffc020111e:	00001517          	auipc	a0,0x1
ffffffffc0201122:	24250513          	addi	a0,a0,578 # ffffffffc0202360 <buddy_system_pmm_manager+0x68>
ffffffffc0201126:	f8dfe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020112a:	777d                	lui	a4,0xfffff
ffffffffc020112c:	00006797          	auipc	a5,0x6
ffffffffc0201130:	35b78793          	addi	a5,a5,859 # ffffffffc0207487 <end+0xfff>
ffffffffc0201134:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0201136:	00005517          	auipc	a0,0x5
ffffffffc020113a:	31a50513          	addi	a0,a0,794 # ffffffffc0206450 <npage>
ffffffffc020113e:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201142:	00005597          	auipc	a1,0x5
ffffffffc0201146:	31658593          	addi	a1,a1,790 # ffffffffc0206458 <pages>
    npage = maxpa / PGSIZE;
ffffffffc020114a:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020114c:	e19c                	sd	a5,0(a1)
ffffffffc020114e:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201150:	4701                	li	a4,0
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201152:	4885                	li	a7,1
ffffffffc0201154:	fff80837          	lui	a6,0xfff80
ffffffffc0201158:	a011                	j	ffffffffc020115c <pmm_init+0x96>
        SetPageReserved(pages + i);
ffffffffc020115a:	619c                	ld	a5,0(a1)
ffffffffc020115c:	97b6                	add	a5,a5,a3
ffffffffc020115e:	07a1                	addi	a5,a5,8
ffffffffc0201160:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201164:	611c                	ld	a5,0(a0)
ffffffffc0201166:	0705                	addi	a4,a4,1
ffffffffc0201168:	02868693          	addi	a3,a3,40
ffffffffc020116c:	01078633          	add	a2,a5,a6
ffffffffc0201170:	fec765e3          	bltu	a4,a2,ffffffffc020115a <pmm_init+0x94>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201174:	6190                	ld	a2,0(a1)
ffffffffc0201176:	00279713          	slli	a4,a5,0x2
ffffffffc020117a:	973e                	add	a4,a4,a5
ffffffffc020117c:	fec006b7          	lui	a3,0xfec00
ffffffffc0201180:	070e                	slli	a4,a4,0x3
ffffffffc0201182:	96b2                	add	a3,a3,a2
ffffffffc0201184:	96ba                	add	a3,a3,a4
ffffffffc0201186:	c0200737          	lui	a4,0xc0200
ffffffffc020118a:	08e6ef63          	bltu	a3,a4,ffffffffc0201228 <pmm_init+0x162>
ffffffffc020118e:	6018                	ld	a4,0(s0)
    if (freemem < mem_end) {
ffffffffc0201190:	45c5                	li	a1,17
ffffffffc0201192:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201194:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0201196:	04b6e863          	bltu	a3,a1,ffffffffc02011e6 <pmm_init+0x120>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc020119a:	609c                	ld	a5,0(s1)
ffffffffc020119c:	7b9c                	ld	a5,48(a5)
ffffffffc020119e:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02011a0:	00001517          	auipc	a0,0x1
ffffffffc02011a4:	25850513          	addi	a0,a0,600 # ffffffffc02023f8 <buddy_system_pmm_manager+0x100>
ffffffffc02011a8:	f0bfe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc02011ac:	00004597          	auipc	a1,0x4
ffffffffc02011b0:	e5458593          	addi	a1,a1,-428 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc02011b4:	00005797          	auipc	a5,0x5
ffffffffc02011b8:	2ab7be23          	sd	a1,700(a5) # ffffffffc0206470 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc02011bc:	c02007b7          	lui	a5,0xc0200
ffffffffc02011c0:	08f5e063          	bltu	a1,a5,ffffffffc0201240 <pmm_init+0x17a>
ffffffffc02011c4:	6010                	ld	a2,0(s0)
}
ffffffffc02011c6:	6442                	ld	s0,16(sp)
ffffffffc02011c8:	60e2                	ld	ra,24(sp)
ffffffffc02011ca:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc02011cc:	40c58633          	sub	a2,a1,a2
ffffffffc02011d0:	00005797          	auipc	a5,0x5
ffffffffc02011d4:	28c7bc23          	sd	a2,664(a5) # ffffffffc0206468 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02011d8:	00001517          	auipc	a0,0x1
ffffffffc02011dc:	24050513          	addi	a0,a0,576 # ffffffffc0202418 <buddy_system_pmm_manager+0x120>
}
ffffffffc02011e0:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02011e2:	ed1fe06f          	j	ffffffffc02000b2 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02011e6:	6705                	lui	a4,0x1
ffffffffc02011e8:	177d                	addi	a4,a4,-1
ffffffffc02011ea:	96ba                	add	a3,a3,a4
ffffffffc02011ec:	777d                	lui	a4,0xfffff
ffffffffc02011ee:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc02011f0:	00c6d513          	srli	a0,a3,0xc
ffffffffc02011f4:	00f57e63          	bgeu	a0,a5,ffffffffc0201210 <pmm_init+0x14a>
    pmm_manager->init_memmap(base, n);
ffffffffc02011f8:	609c                	ld	a5,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc02011fa:	982a                	add	a6,a6,a0
ffffffffc02011fc:	00281513          	slli	a0,a6,0x2
ffffffffc0201200:	9542                	add	a0,a0,a6
ffffffffc0201202:	6b9c                	ld	a5,16(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0201204:	8d95                	sub	a1,a1,a3
ffffffffc0201206:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0201208:	81b1                	srli	a1,a1,0xc
ffffffffc020120a:	9532                	add	a0,a0,a2
ffffffffc020120c:	9782                	jalr	a5
}
ffffffffc020120e:	b771                	j	ffffffffc020119a <pmm_init+0xd4>
        panic("pa2page called with invalid pa");
ffffffffc0201210:	00001617          	auipc	a2,0x1
ffffffffc0201214:	1b860613          	addi	a2,a2,440 # ffffffffc02023c8 <buddy_system_pmm_manager+0xd0>
ffffffffc0201218:	06b00593          	li	a1,107
ffffffffc020121c:	00001517          	auipc	a0,0x1
ffffffffc0201220:	1cc50513          	addi	a0,a0,460 # ffffffffc02023e8 <buddy_system_pmm_manager+0xf0>
ffffffffc0201224:	988ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201228:	00001617          	auipc	a2,0x1
ffffffffc020122c:	16860613          	addi	a2,a2,360 # ffffffffc0202390 <buddy_system_pmm_manager+0x98>
ffffffffc0201230:	06f00593          	li	a1,111
ffffffffc0201234:	00001517          	auipc	a0,0x1
ffffffffc0201238:	18450513          	addi	a0,a0,388 # ffffffffc02023b8 <buddy_system_pmm_manager+0xc0>
ffffffffc020123c:	970ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201240:	86ae                	mv	a3,a1
ffffffffc0201242:	00001617          	auipc	a2,0x1
ffffffffc0201246:	14e60613          	addi	a2,a2,334 # ffffffffc0202390 <buddy_system_pmm_manager+0x98>
ffffffffc020124a:	08a00593          	li	a1,138
ffffffffc020124e:	00001517          	auipc	a0,0x1
ffffffffc0201252:	16a50513          	addi	a0,a0,362 # ffffffffc02023b8 <buddy_system_pmm_manager+0xc0>
ffffffffc0201256:	956ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc020125a <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc020125a:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020125e:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0201260:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201264:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201266:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020126a:	f022                	sd	s0,32(sp)
ffffffffc020126c:	ec26                	sd	s1,24(sp)
ffffffffc020126e:	e84a                	sd	s2,16(sp)
ffffffffc0201270:	f406                	sd	ra,40(sp)
ffffffffc0201272:	e44e                	sd	s3,8(sp)
ffffffffc0201274:	84aa                	mv	s1,a0
ffffffffc0201276:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0201278:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc020127c:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc020127e:	03067e63          	bgeu	a2,a6,ffffffffc02012ba <printnum+0x60>
ffffffffc0201282:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0201284:	00805763          	blez	s0,ffffffffc0201292 <printnum+0x38>
ffffffffc0201288:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc020128a:	85ca                	mv	a1,s2
ffffffffc020128c:	854e                	mv	a0,s3
ffffffffc020128e:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0201290:	fc65                	bnez	s0,ffffffffc0201288 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201292:	1a02                	slli	s4,s4,0x20
ffffffffc0201294:	00001797          	auipc	a5,0x1
ffffffffc0201298:	1c478793          	addi	a5,a5,452 # ffffffffc0202458 <buddy_system_pmm_manager+0x160>
ffffffffc020129c:	020a5a13          	srli	s4,s4,0x20
ffffffffc02012a0:	9a3e                	add	s4,s4,a5
}
ffffffffc02012a2:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02012a4:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02012a8:	70a2                	ld	ra,40(sp)
ffffffffc02012aa:	69a2                	ld	s3,8(sp)
ffffffffc02012ac:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02012ae:	85ca                	mv	a1,s2
ffffffffc02012b0:	87a6                	mv	a5,s1
}
ffffffffc02012b2:	6942                	ld	s2,16(sp)
ffffffffc02012b4:	64e2                	ld	s1,24(sp)
ffffffffc02012b6:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02012b8:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02012ba:	03065633          	divu	a2,a2,a6
ffffffffc02012be:	8722                	mv	a4,s0
ffffffffc02012c0:	f9bff0ef          	jal	ra,ffffffffc020125a <printnum>
ffffffffc02012c4:	b7f9                	j	ffffffffc0201292 <printnum+0x38>

ffffffffc02012c6 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02012c6:	7119                	addi	sp,sp,-128
ffffffffc02012c8:	f4a6                	sd	s1,104(sp)
ffffffffc02012ca:	f0ca                	sd	s2,96(sp)
ffffffffc02012cc:	ecce                	sd	s3,88(sp)
ffffffffc02012ce:	e8d2                	sd	s4,80(sp)
ffffffffc02012d0:	e4d6                	sd	s5,72(sp)
ffffffffc02012d2:	e0da                	sd	s6,64(sp)
ffffffffc02012d4:	fc5e                	sd	s7,56(sp)
ffffffffc02012d6:	f06a                	sd	s10,32(sp)
ffffffffc02012d8:	fc86                	sd	ra,120(sp)
ffffffffc02012da:	f8a2                	sd	s0,112(sp)
ffffffffc02012dc:	f862                	sd	s8,48(sp)
ffffffffc02012de:	f466                	sd	s9,40(sp)
ffffffffc02012e0:	ec6e                	sd	s11,24(sp)
ffffffffc02012e2:	892a                	mv	s2,a0
ffffffffc02012e4:	84ae                	mv	s1,a1
ffffffffc02012e6:	8d32                	mv	s10,a2
ffffffffc02012e8:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02012ea:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02012ee:	5b7d                	li	s6,-1
ffffffffc02012f0:	00001a97          	auipc	s5,0x1
ffffffffc02012f4:	19ca8a93          	addi	s5,s5,412 # ffffffffc020248c <buddy_system_pmm_manager+0x194>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02012f8:	00001b97          	auipc	s7,0x1
ffffffffc02012fc:	370b8b93          	addi	s7,s7,880 # ffffffffc0202668 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201300:	000d4503          	lbu	a0,0(s10)
ffffffffc0201304:	001d0413          	addi	s0,s10,1
ffffffffc0201308:	01350a63          	beq	a0,s3,ffffffffc020131c <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc020130c:	c121                	beqz	a0,ffffffffc020134c <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc020130e:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201310:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0201312:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201314:	fff44503          	lbu	a0,-1(s0)
ffffffffc0201318:	ff351ae3          	bne	a0,s3,ffffffffc020130c <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020131c:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0201320:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0201324:	4c81                	li	s9,0
ffffffffc0201326:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0201328:	5c7d                	li	s8,-1
ffffffffc020132a:	5dfd                	li	s11,-1
ffffffffc020132c:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0201330:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201332:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201336:	0ff5f593          	andi	a1,a1,255
ffffffffc020133a:	00140d13          	addi	s10,s0,1
ffffffffc020133e:	04b56263          	bltu	a0,a1,ffffffffc0201382 <vprintfmt+0xbc>
ffffffffc0201342:	058a                	slli	a1,a1,0x2
ffffffffc0201344:	95d6                	add	a1,a1,s5
ffffffffc0201346:	4194                	lw	a3,0(a1)
ffffffffc0201348:	96d6                	add	a3,a3,s5
ffffffffc020134a:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc020134c:	70e6                	ld	ra,120(sp)
ffffffffc020134e:	7446                	ld	s0,112(sp)
ffffffffc0201350:	74a6                	ld	s1,104(sp)
ffffffffc0201352:	7906                	ld	s2,96(sp)
ffffffffc0201354:	69e6                	ld	s3,88(sp)
ffffffffc0201356:	6a46                	ld	s4,80(sp)
ffffffffc0201358:	6aa6                	ld	s5,72(sp)
ffffffffc020135a:	6b06                	ld	s6,64(sp)
ffffffffc020135c:	7be2                	ld	s7,56(sp)
ffffffffc020135e:	7c42                	ld	s8,48(sp)
ffffffffc0201360:	7ca2                	ld	s9,40(sp)
ffffffffc0201362:	7d02                	ld	s10,32(sp)
ffffffffc0201364:	6de2                	ld	s11,24(sp)
ffffffffc0201366:	6109                	addi	sp,sp,128
ffffffffc0201368:	8082                	ret
            padc = '0';
ffffffffc020136a:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc020136c:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201370:	846a                	mv	s0,s10
ffffffffc0201372:	00140d13          	addi	s10,s0,1
ffffffffc0201376:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020137a:	0ff5f593          	andi	a1,a1,255
ffffffffc020137e:	fcb572e3          	bgeu	a0,a1,ffffffffc0201342 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0201382:	85a6                	mv	a1,s1
ffffffffc0201384:	02500513          	li	a0,37
ffffffffc0201388:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc020138a:	fff44783          	lbu	a5,-1(s0)
ffffffffc020138e:	8d22                	mv	s10,s0
ffffffffc0201390:	f73788e3          	beq	a5,s3,ffffffffc0201300 <vprintfmt+0x3a>
ffffffffc0201394:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0201398:	1d7d                	addi	s10,s10,-1
ffffffffc020139a:	ff379de3          	bne	a5,s3,ffffffffc0201394 <vprintfmt+0xce>
ffffffffc020139e:	b78d                	j	ffffffffc0201300 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc02013a0:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc02013a4:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02013a8:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02013aa:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02013ae:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02013b2:	02d86463          	bltu	a6,a3,ffffffffc02013da <vprintfmt+0x114>
                ch = *fmt;
ffffffffc02013b6:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02013ba:	002c169b          	slliw	a3,s8,0x2
ffffffffc02013be:	0186873b          	addw	a4,a3,s8
ffffffffc02013c2:	0017171b          	slliw	a4,a4,0x1
ffffffffc02013c6:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc02013c8:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc02013cc:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02013ce:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc02013d2:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02013d6:	fed870e3          	bgeu	a6,a3,ffffffffc02013b6 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc02013da:	f40ddce3          	bgez	s11,ffffffffc0201332 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc02013de:	8de2                	mv	s11,s8
ffffffffc02013e0:	5c7d                	li	s8,-1
ffffffffc02013e2:	bf81                	j	ffffffffc0201332 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc02013e4:	fffdc693          	not	a3,s11
ffffffffc02013e8:	96fd                	srai	a3,a3,0x3f
ffffffffc02013ea:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02013ee:	00144603          	lbu	a2,1(s0)
ffffffffc02013f2:	2d81                	sext.w	s11,s11
ffffffffc02013f4:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02013f6:	bf35                	j	ffffffffc0201332 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc02013f8:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02013fc:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0201400:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201402:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0201404:	bfd9                	j	ffffffffc02013da <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0201406:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201408:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020140c:	01174463          	blt	a4,a7,ffffffffc0201414 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0201410:	1a088e63          	beqz	a7,ffffffffc02015cc <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0201414:	000a3603          	ld	a2,0(s4)
ffffffffc0201418:	46c1                	li	a3,16
ffffffffc020141a:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc020141c:	2781                	sext.w	a5,a5
ffffffffc020141e:	876e                	mv	a4,s11
ffffffffc0201420:	85a6                	mv	a1,s1
ffffffffc0201422:	854a                	mv	a0,s2
ffffffffc0201424:	e37ff0ef          	jal	ra,ffffffffc020125a <printnum>
            break;
ffffffffc0201428:	bde1                	j	ffffffffc0201300 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc020142a:	000a2503          	lw	a0,0(s4)
ffffffffc020142e:	85a6                	mv	a1,s1
ffffffffc0201430:	0a21                	addi	s4,s4,8
ffffffffc0201432:	9902                	jalr	s2
            break;
ffffffffc0201434:	b5f1                	j	ffffffffc0201300 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201436:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201438:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020143c:	01174463          	blt	a4,a7,ffffffffc0201444 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0201440:	18088163          	beqz	a7,ffffffffc02015c2 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0201444:	000a3603          	ld	a2,0(s4)
ffffffffc0201448:	46a9                	li	a3,10
ffffffffc020144a:	8a2e                	mv	s4,a1
ffffffffc020144c:	bfc1                	j	ffffffffc020141c <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020144e:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0201452:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201454:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201456:	bdf1                	j	ffffffffc0201332 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0201458:	85a6                	mv	a1,s1
ffffffffc020145a:	02500513          	li	a0,37
ffffffffc020145e:	9902                	jalr	s2
            break;
ffffffffc0201460:	b545                	j	ffffffffc0201300 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201462:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0201466:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201468:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020146a:	b5e1                	j	ffffffffc0201332 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc020146c:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020146e:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201472:	01174463          	blt	a4,a7,ffffffffc020147a <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0201476:	14088163          	beqz	a7,ffffffffc02015b8 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc020147a:	000a3603          	ld	a2,0(s4)
ffffffffc020147e:	46a1                	li	a3,8
ffffffffc0201480:	8a2e                	mv	s4,a1
ffffffffc0201482:	bf69                	j	ffffffffc020141c <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0201484:	03000513          	li	a0,48
ffffffffc0201488:	85a6                	mv	a1,s1
ffffffffc020148a:	e03e                	sd	a5,0(sp)
ffffffffc020148c:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc020148e:	85a6                	mv	a1,s1
ffffffffc0201490:	07800513          	li	a0,120
ffffffffc0201494:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201496:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0201498:	6782                	ld	a5,0(sp)
ffffffffc020149a:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020149c:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc02014a0:	bfb5                	j	ffffffffc020141c <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02014a2:	000a3403          	ld	s0,0(s4)
ffffffffc02014a6:	008a0713          	addi	a4,s4,8
ffffffffc02014aa:	e03a                	sd	a4,0(sp)
ffffffffc02014ac:	14040263          	beqz	s0,ffffffffc02015f0 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc02014b0:	0fb05763          	blez	s11,ffffffffc020159e <vprintfmt+0x2d8>
ffffffffc02014b4:	02d00693          	li	a3,45
ffffffffc02014b8:	0cd79163          	bne	a5,a3,ffffffffc020157a <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02014bc:	00044783          	lbu	a5,0(s0)
ffffffffc02014c0:	0007851b          	sext.w	a0,a5
ffffffffc02014c4:	cf85                	beqz	a5,ffffffffc02014fc <vprintfmt+0x236>
ffffffffc02014c6:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02014ca:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02014ce:	000c4563          	bltz	s8,ffffffffc02014d8 <vprintfmt+0x212>
ffffffffc02014d2:	3c7d                	addiw	s8,s8,-1
ffffffffc02014d4:	036c0263          	beq	s8,s6,ffffffffc02014f8 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc02014d8:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02014da:	0e0c8e63          	beqz	s9,ffffffffc02015d6 <vprintfmt+0x310>
ffffffffc02014de:	3781                	addiw	a5,a5,-32
ffffffffc02014e0:	0ef47b63          	bgeu	s0,a5,ffffffffc02015d6 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc02014e4:	03f00513          	li	a0,63
ffffffffc02014e8:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02014ea:	000a4783          	lbu	a5,0(s4)
ffffffffc02014ee:	3dfd                	addiw	s11,s11,-1
ffffffffc02014f0:	0a05                	addi	s4,s4,1
ffffffffc02014f2:	0007851b          	sext.w	a0,a5
ffffffffc02014f6:	ffe1                	bnez	a5,ffffffffc02014ce <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc02014f8:	01b05963          	blez	s11,ffffffffc020150a <vprintfmt+0x244>
ffffffffc02014fc:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02014fe:	85a6                	mv	a1,s1
ffffffffc0201500:	02000513          	li	a0,32
ffffffffc0201504:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201506:	fe0d9be3          	bnez	s11,ffffffffc02014fc <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020150a:	6a02                	ld	s4,0(sp)
ffffffffc020150c:	bbd5                	j	ffffffffc0201300 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020150e:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201510:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0201514:	01174463          	blt	a4,a7,ffffffffc020151c <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0201518:	08088d63          	beqz	a7,ffffffffc02015b2 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc020151c:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0201520:	0a044d63          	bltz	s0,ffffffffc02015da <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0201524:	8622                	mv	a2,s0
ffffffffc0201526:	8a66                	mv	s4,s9
ffffffffc0201528:	46a9                	li	a3,10
ffffffffc020152a:	bdcd                	j	ffffffffc020141c <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc020152c:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201530:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0201532:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0201534:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201538:	8fb5                	xor	a5,a5,a3
ffffffffc020153a:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020153e:	02d74163          	blt	a4,a3,ffffffffc0201560 <vprintfmt+0x29a>
ffffffffc0201542:	00369793          	slli	a5,a3,0x3
ffffffffc0201546:	97de                	add	a5,a5,s7
ffffffffc0201548:	639c                	ld	a5,0(a5)
ffffffffc020154a:	cb99                	beqz	a5,ffffffffc0201560 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc020154c:	86be                	mv	a3,a5
ffffffffc020154e:	00001617          	auipc	a2,0x1
ffffffffc0201552:	f3a60613          	addi	a2,a2,-198 # ffffffffc0202488 <buddy_system_pmm_manager+0x190>
ffffffffc0201556:	85a6                	mv	a1,s1
ffffffffc0201558:	854a                	mv	a0,s2
ffffffffc020155a:	0ce000ef          	jal	ra,ffffffffc0201628 <printfmt>
ffffffffc020155e:	b34d                	j	ffffffffc0201300 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201560:	00001617          	auipc	a2,0x1
ffffffffc0201564:	f1860613          	addi	a2,a2,-232 # ffffffffc0202478 <buddy_system_pmm_manager+0x180>
ffffffffc0201568:	85a6                	mv	a1,s1
ffffffffc020156a:	854a                	mv	a0,s2
ffffffffc020156c:	0bc000ef          	jal	ra,ffffffffc0201628 <printfmt>
ffffffffc0201570:	bb41                	j	ffffffffc0201300 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201572:	00001417          	auipc	s0,0x1
ffffffffc0201576:	efe40413          	addi	s0,s0,-258 # ffffffffc0202470 <buddy_system_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020157a:	85e2                	mv	a1,s8
ffffffffc020157c:	8522                	mv	a0,s0
ffffffffc020157e:	e43e                	sd	a5,8(sp)
ffffffffc0201580:	1cc000ef          	jal	ra,ffffffffc020174c <strnlen>
ffffffffc0201584:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0201588:	01b05b63          	blez	s11,ffffffffc020159e <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc020158c:	67a2                	ld	a5,8(sp)
ffffffffc020158e:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201592:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201594:	85a6                	mv	a1,s1
ffffffffc0201596:	8552                	mv	a0,s4
ffffffffc0201598:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020159a:	fe0d9ce3          	bnez	s11,ffffffffc0201592 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020159e:	00044783          	lbu	a5,0(s0)
ffffffffc02015a2:	00140a13          	addi	s4,s0,1
ffffffffc02015a6:	0007851b          	sext.w	a0,a5
ffffffffc02015aa:	d3a5                	beqz	a5,ffffffffc020150a <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02015ac:	05e00413          	li	s0,94
ffffffffc02015b0:	bf39                	j	ffffffffc02014ce <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc02015b2:	000a2403          	lw	s0,0(s4)
ffffffffc02015b6:	b7ad                	j	ffffffffc0201520 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc02015b8:	000a6603          	lwu	a2,0(s4)
ffffffffc02015bc:	46a1                	li	a3,8
ffffffffc02015be:	8a2e                	mv	s4,a1
ffffffffc02015c0:	bdb1                	j	ffffffffc020141c <vprintfmt+0x156>
ffffffffc02015c2:	000a6603          	lwu	a2,0(s4)
ffffffffc02015c6:	46a9                	li	a3,10
ffffffffc02015c8:	8a2e                	mv	s4,a1
ffffffffc02015ca:	bd89                	j	ffffffffc020141c <vprintfmt+0x156>
ffffffffc02015cc:	000a6603          	lwu	a2,0(s4)
ffffffffc02015d0:	46c1                	li	a3,16
ffffffffc02015d2:	8a2e                	mv	s4,a1
ffffffffc02015d4:	b5a1                	j	ffffffffc020141c <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc02015d6:	9902                	jalr	s2
ffffffffc02015d8:	bf09                	j	ffffffffc02014ea <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc02015da:	85a6                	mv	a1,s1
ffffffffc02015dc:	02d00513          	li	a0,45
ffffffffc02015e0:	e03e                	sd	a5,0(sp)
ffffffffc02015e2:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02015e4:	6782                	ld	a5,0(sp)
ffffffffc02015e6:	8a66                	mv	s4,s9
ffffffffc02015e8:	40800633          	neg	a2,s0
ffffffffc02015ec:	46a9                	li	a3,10
ffffffffc02015ee:	b53d                	j	ffffffffc020141c <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc02015f0:	03b05163          	blez	s11,ffffffffc0201612 <vprintfmt+0x34c>
ffffffffc02015f4:	02d00693          	li	a3,45
ffffffffc02015f8:	f6d79de3          	bne	a5,a3,ffffffffc0201572 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc02015fc:	00001417          	auipc	s0,0x1
ffffffffc0201600:	e7440413          	addi	s0,s0,-396 # ffffffffc0202470 <buddy_system_pmm_manager+0x178>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201604:	02800793          	li	a5,40
ffffffffc0201608:	02800513          	li	a0,40
ffffffffc020160c:	00140a13          	addi	s4,s0,1
ffffffffc0201610:	bd6d                	j	ffffffffc02014ca <vprintfmt+0x204>
ffffffffc0201612:	00001a17          	auipc	s4,0x1
ffffffffc0201616:	e5fa0a13          	addi	s4,s4,-417 # ffffffffc0202471 <buddy_system_pmm_manager+0x179>
ffffffffc020161a:	02800513          	li	a0,40
ffffffffc020161e:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201622:	05e00413          	li	s0,94
ffffffffc0201626:	b565                	j	ffffffffc02014ce <vprintfmt+0x208>

ffffffffc0201628 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201628:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc020162a:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020162e:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201630:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201632:	ec06                	sd	ra,24(sp)
ffffffffc0201634:	f83a                	sd	a4,48(sp)
ffffffffc0201636:	fc3e                	sd	a5,56(sp)
ffffffffc0201638:	e0c2                	sd	a6,64(sp)
ffffffffc020163a:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc020163c:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020163e:	c89ff0ef          	jal	ra,ffffffffc02012c6 <vprintfmt>
}
ffffffffc0201642:	60e2                	ld	ra,24(sp)
ffffffffc0201644:	6161                	addi	sp,sp,80
ffffffffc0201646:	8082                	ret

ffffffffc0201648 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201648:	715d                	addi	sp,sp,-80
ffffffffc020164a:	e486                	sd	ra,72(sp)
ffffffffc020164c:	e0a6                	sd	s1,64(sp)
ffffffffc020164e:	fc4a                	sd	s2,56(sp)
ffffffffc0201650:	f84e                	sd	s3,48(sp)
ffffffffc0201652:	f452                	sd	s4,40(sp)
ffffffffc0201654:	f056                	sd	s5,32(sp)
ffffffffc0201656:	ec5a                	sd	s6,24(sp)
ffffffffc0201658:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc020165a:	c901                	beqz	a0,ffffffffc020166a <readline+0x22>
ffffffffc020165c:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc020165e:	00001517          	auipc	a0,0x1
ffffffffc0201662:	e2a50513          	addi	a0,a0,-470 # ffffffffc0202488 <buddy_system_pmm_manager+0x190>
ffffffffc0201666:	a4dfe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
readline(const char *prompt) {
ffffffffc020166a:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020166c:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc020166e:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201670:	4aa9                	li	s5,10
ffffffffc0201672:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201674:	00005b97          	auipc	s7,0x5
ffffffffc0201678:	9b4b8b93          	addi	s7,s7,-1612 # ffffffffc0206028 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020167c:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0201680:	aabfe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201684:	00054a63          	bltz	a0,ffffffffc0201698 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201688:	00a95a63          	bge	s2,a0,ffffffffc020169c <readline+0x54>
ffffffffc020168c:	029a5263          	bge	s4,s1,ffffffffc02016b0 <readline+0x68>
        c = getchar();
ffffffffc0201690:	a9bfe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201694:	fe055ae3          	bgez	a0,ffffffffc0201688 <readline+0x40>
            return NULL;
ffffffffc0201698:	4501                	li	a0,0
ffffffffc020169a:	a091                	j	ffffffffc02016de <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc020169c:	03351463          	bne	a0,s3,ffffffffc02016c4 <readline+0x7c>
ffffffffc02016a0:	e8a9                	bnez	s1,ffffffffc02016f2 <readline+0xaa>
        c = getchar();
ffffffffc02016a2:	a89fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc02016a6:	fe0549e3          	bltz	a0,ffffffffc0201698 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02016aa:	fea959e3          	bge	s2,a0,ffffffffc020169c <readline+0x54>
ffffffffc02016ae:	4481                	li	s1,0
            cputchar(c);
ffffffffc02016b0:	e42a                	sd	a0,8(sp)
ffffffffc02016b2:	a37fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i ++] = c;
ffffffffc02016b6:	6522                	ld	a0,8(sp)
ffffffffc02016b8:	009b87b3          	add	a5,s7,s1
ffffffffc02016bc:	2485                	addiw	s1,s1,1
ffffffffc02016be:	00a78023          	sb	a0,0(a5)
ffffffffc02016c2:	bf7d                	j	ffffffffc0201680 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc02016c4:	01550463          	beq	a0,s5,ffffffffc02016cc <readline+0x84>
ffffffffc02016c8:	fb651ce3          	bne	a0,s6,ffffffffc0201680 <readline+0x38>
            cputchar(c);
ffffffffc02016cc:	a1dfe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i] = '\0';
ffffffffc02016d0:	00005517          	auipc	a0,0x5
ffffffffc02016d4:	95850513          	addi	a0,a0,-1704 # ffffffffc0206028 <buf>
ffffffffc02016d8:	94aa                	add	s1,s1,a0
ffffffffc02016da:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02016de:	60a6                	ld	ra,72(sp)
ffffffffc02016e0:	6486                	ld	s1,64(sp)
ffffffffc02016e2:	7962                	ld	s2,56(sp)
ffffffffc02016e4:	79c2                	ld	s3,48(sp)
ffffffffc02016e6:	7a22                	ld	s4,40(sp)
ffffffffc02016e8:	7a82                	ld	s5,32(sp)
ffffffffc02016ea:	6b62                	ld	s6,24(sp)
ffffffffc02016ec:	6bc2                	ld	s7,16(sp)
ffffffffc02016ee:	6161                	addi	sp,sp,80
ffffffffc02016f0:	8082                	ret
            cputchar(c);
ffffffffc02016f2:	4521                	li	a0,8
ffffffffc02016f4:	9f5fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            i --;
ffffffffc02016f8:	34fd                	addiw	s1,s1,-1
ffffffffc02016fa:	b759                	j	ffffffffc0201680 <readline+0x38>

ffffffffc02016fc <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc02016fc:	4781                	li	a5,0
ffffffffc02016fe:	00005717          	auipc	a4,0x5
ffffffffc0201702:	90a73703          	ld	a4,-1782(a4) # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
ffffffffc0201706:	88ba                	mv	a7,a4
ffffffffc0201708:	852a                	mv	a0,a0
ffffffffc020170a:	85be                	mv	a1,a5
ffffffffc020170c:	863e                	mv	a2,a5
ffffffffc020170e:	00000073          	ecall
ffffffffc0201712:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc0201714:	8082                	ret

ffffffffc0201716 <sbi_set_timer>:
    __asm__ volatile (
ffffffffc0201716:	4781                	li	a5,0
ffffffffc0201718:	00005717          	auipc	a4,0x5
ffffffffc020171c:	d6873703          	ld	a4,-664(a4) # ffffffffc0206480 <SBI_SET_TIMER>
ffffffffc0201720:	88ba                	mv	a7,a4
ffffffffc0201722:	852a                	mv	a0,a0
ffffffffc0201724:	85be                	mv	a1,a5
ffffffffc0201726:	863e                	mv	a2,a5
ffffffffc0201728:	00000073          	ecall
ffffffffc020172c:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc020172e:	8082                	ret

ffffffffc0201730 <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc0201730:	4501                	li	a0,0
ffffffffc0201732:	00005797          	auipc	a5,0x5
ffffffffc0201736:	8ce7b783          	ld	a5,-1842(a5) # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
ffffffffc020173a:	88be                	mv	a7,a5
ffffffffc020173c:	852a                	mv	a0,a0
ffffffffc020173e:	85aa                	mv	a1,a0
ffffffffc0201740:	862a                	mv	a2,a0
ffffffffc0201742:	00000073          	ecall
ffffffffc0201746:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201748:	2501                	sext.w	a0,a0
ffffffffc020174a:	8082                	ret

ffffffffc020174c <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc020174c:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc020174e:	e589                	bnez	a1,ffffffffc0201758 <strnlen+0xc>
ffffffffc0201750:	a811                	j	ffffffffc0201764 <strnlen+0x18>
        cnt ++;
ffffffffc0201752:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201754:	00f58863          	beq	a1,a5,ffffffffc0201764 <strnlen+0x18>
ffffffffc0201758:	00f50733          	add	a4,a0,a5
ffffffffc020175c:	00074703          	lbu	a4,0(a4)
ffffffffc0201760:	fb6d                	bnez	a4,ffffffffc0201752 <strnlen+0x6>
ffffffffc0201762:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0201764:	852e                	mv	a0,a1
ffffffffc0201766:	8082                	ret

ffffffffc0201768 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201768:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020176c:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201770:	cb89                	beqz	a5,ffffffffc0201782 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0201772:	0505                	addi	a0,a0,1
ffffffffc0201774:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201776:	fee789e3          	beq	a5,a4,ffffffffc0201768 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020177a:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc020177e:	9d19                	subw	a0,a0,a4
ffffffffc0201780:	8082                	ret
ffffffffc0201782:	4501                	li	a0,0
ffffffffc0201784:	bfed                	j	ffffffffc020177e <strcmp+0x16>

ffffffffc0201786 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201786:	00054783          	lbu	a5,0(a0)
ffffffffc020178a:	c799                	beqz	a5,ffffffffc0201798 <strchr+0x12>
        if (*s == c) {
ffffffffc020178c:	00f58763          	beq	a1,a5,ffffffffc020179a <strchr+0x14>
    while (*s != '\0') {
ffffffffc0201790:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0201794:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201796:	fbfd                	bnez	a5,ffffffffc020178c <strchr+0x6>
    }
    return NULL;
ffffffffc0201798:	4501                	li	a0,0
}
ffffffffc020179a:	8082                	ret

ffffffffc020179c <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc020179c:	ca01                	beqz	a2,ffffffffc02017ac <memset+0x10>
ffffffffc020179e:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02017a0:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02017a2:	0785                	addi	a5,a5,1
ffffffffc02017a4:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02017a8:	fec79de3          	bne	a5,a2,ffffffffc02017a2 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02017ac:	8082                	ret
