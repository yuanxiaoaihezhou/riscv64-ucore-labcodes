
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c020b2b7          	lui	t0,0xc020b
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
ffffffffc0200024:	c020b137          	lui	sp,0xc020b

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

int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	000a7517          	auipc	a0,0xa7
ffffffffc0200036:	25e50513          	addi	a0,a0,606 # ffffffffc02a7290 <buf>
ffffffffc020003a:	000b2617          	auipc	a2,0xb2
ffffffffc020003e:	7b260613          	addi	a2,a2,1970 # ffffffffc02b27ec <end>
kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	36e060ef          	jal	ra,ffffffffc02063b8 <memset>
    cons_init();                // init the console
ffffffffc020004e:	52a000ef          	jal	ra,ffffffffc0200578 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200052:	00006597          	auipc	a1,0x6
ffffffffc0200056:	39658593          	addi	a1,a1,918 # ffffffffc02063e8 <etext+0x6>
ffffffffc020005a:	00006517          	auipc	a0,0x6
ffffffffc020005e:	3ae50513          	addi	a0,a0,942 # ffffffffc0206408 <etext+0x26>
ffffffffc0200062:	11e000ef          	jal	ra,ffffffffc0200180 <cprintf>

    print_kerninfo();
ffffffffc0200066:	1a2000ef          	jal	ra,ffffffffc0200208 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006a:	67a020ef          	jal	ra,ffffffffc02026e4 <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc020006e:	5ba000ef          	jal	ra,ffffffffc0200628 <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200072:	5b8000ef          	jal	ra,ffffffffc020062a <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc0200076:	300040ef          	jal	ra,ffffffffc0204376 <vmm_init>
    proc_init();                // init process table
ffffffffc020007a:	2b7050ef          	jal	ra,ffffffffc0205b30 <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc020007e:	56c000ef          	jal	ra,ffffffffc02005ea <ide_init>
    swap_init();                // init swap
ffffffffc0200082:	2d8030ef          	jal	ra,ffffffffc020335a <swap_init>

    clock_init();               // init clock interrupt
ffffffffc0200086:	4a0000ef          	jal	ra,ffffffffc0200526 <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008a:	592000ef          	jal	ra,ffffffffc020061c <intr_enable>
    
    cpu_idle();                 // run idle process
ffffffffc020008e:	43b050ef          	jal	ra,ffffffffc0205cc8 <cpu_idle>

ffffffffc0200092 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0200092:	715d                	addi	sp,sp,-80
ffffffffc0200094:	e486                	sd	ra,72(sp)
ffffffffc0200096:	e0a6                	sd	s1,64(sp)
ffffffffc0200098:	fc4a                	sd	s2,56(sp)
ffffffffc020009a:	f84e                	sd	s3,48(sp)
ffffffffc020009c:	f452                	sd	s4,40(sp)
ffffffffc020009e:	f056                	sd	s5,32(sp)
ffffffffc02000a0:	ec5a                	sd	s6,24(sp)
ffffffffc02000a2:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc02000a4:	c901                	beqz	a0,ffffffffc02000b4 <readline+0x22>
ffffffffc02000a6:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc02000a8:	00006517          	auipc	a0,0x6
ffffffffc02000ac:	36850513          	addi	a0,a0,872 # ffffffffc0206410 <etext+0x2e>
ffffffffc02000b0:	0d0000ef          	jal	ra,ffffffffc0200180 <cprintf>
readline(const char *prompt) {
ffffffffc02000b4:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000b6:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02000b8:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02000ba:	4aa9                	li	s5,10
ffffffffc02000bc:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02000be:	000a7b97          	auipc	s7,0xa7
ffffffffc02000c2:	1d2b8b93          	addi	s7,s7,466 # ffffffffc02a7290 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000c6:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02000ca:	12e000ef          	jal	ra,ffffffffc02001f8 <getchar>
        if (c < 0) {
ffffffffc02000ce:	00054a63          	bltz	a0,ffffffffc02000e2 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000d2:	00a95a63          	bge	s2,a0,ffffffffc02000e6 <readline+0x54>
ffffffffc02000d6:	029a5263          	bge	s4,s1,ffffffffc02000fa <readline+0x68>
        c = getchar();
ffffffffc02000da:	11e000ef          	jal	ra,ffffffffc02001f8 <getchar>
        if (c < 0) {
ffffffffc02000de:	fe055ae3          	bgez	a0,ffffffffc02000d2 <readline+0x40>
            return NULL;
ffffffffc02000e2:	4501                	li	a0,0
ffffffffc02000e4:	a091                	j	ffffffffc0200128 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02000e6:	03351463          	bne	a0,s3,ffffffffc020010e <readline+0x7c>
ffffffffc02000ea:	e8a9                	bnez	s1,ffffffffc020013c <readline+0xaa>
        c = getchar();
ffffffffc02000ec:	10c000ef          	jal	ra,ffffffffc02001f8 <getchar>
        if (c < 0) {
ffffffffc02000f0:	fe0549e3          	bltz	a0,ffffffffc02000e2 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000f4:	fea959e3          	bge	s2,a0,ffffffffc02000e6 <readline+0x54>
ffffffffc02000f8:	4481                	li	s1,0
            cputchar(c);
ffffffffc02000fa:	e42a                	sd	a0,8(sp)
ffffffffc02000fc:	0ba000ef          	jal	ra,ffffffffc02001b6 <cputchar>
            buf[i ++] = c;
ffffffffc0200100:	6522                	ld	a0,8(sp)
ffffffffc0200102:	009b87b3          	add	a5,s7,s1
ffffffffc0200106:	2485                	addiw	s1,s1,1
ffffffffc0200108:	00a78023          	sb	a0,0(a5)
ffffffffc020010c:	bf7d                	j	ffffffffc02000ca <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc020010e:	01550463          	beq	a0,s5,ffffffffc0200116 <readline+0x84>
ffffffffc0200112:	fb651ce3          	bne	a0,s6,ffffffffc02000ca <readline+0x38>
            cputchar(c);
ffffffffc0200116:	0a0000ef          	jal	ra,ffffffffc02001b6 <cputchar>
            buf[i] = '\0';
ffffffffc020011a:	000a7517          	auipc	a0,0xa7
ffffffffc020011e:	17650513          	addi	a0,a0,374 # ffffffffc02a7290 <buf>
ffffffffc0200122:	94aa                	add	s1,s1,a0
ffffffffc0200124:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0200128:	60a6                	ld	ra,72(sp)
ffffffffc020012a:	6486                	ld	s1,64(sp)
ffffffffc020012c:	7962                	ld	s2,56(sp)
ffffffffc020012e:	79c2                	ld	s3,48(sp)
ffffffffc0200130:	7a22                	ld	s4,40(sp)
ffffffffc0200132:	7a82                	ld	s5,32(sp)
ffffffffc0200134:	6b62                	ld	s6,24(sp)
ffffffffc0200136:	6bc2                	ld	s7,16(sp)
ffffffffc0200138:	6161                	addi	sp,sp,80
ffffffffc020013a:	8082                	ret
            cputchar(c);
ffffffffc020013c:	4521                	li	a0,8
ffffffffc020013e:	078000ef          	jal	ra,ffffffffc02001b6 <cputchar>
            i --;
ffffffffc0200142:	34fd                	addiw	s1,s1,-1
ffffffffc0200144:	b759                	j	ffffffffc02000ca <readline+0x38>

ffffffffc0200146 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200146:	1141                	addi	sp,sp,-16
ffffffffc0200148:	e022                	sd	s0,0(sp)
ffffffffc020014a:	e406                	sd	ra,8(sp)
ffffffffc020014c:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020014e:	42c000ef          	jal	ra,ffffffffc020057a <cons_putc>
    (*cnt) ++;
ffffffffc0200152:	401c                	lw	a5,0(s0)
}
ffffffffc0200154:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200156:	2785                	addiw	a5,a5,1
ffffffffc0200158:	c01c                	sw	a5,0(s0)
}
ffffffffc020015a:	6402                	ld	s0,0(sp)
ffffffffc020015c:	0141                	addi	sp,sp,16
ffffffffc020015e:	8082                	ret

ffffffffc0200160 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200160:	1101                	addi	sp,sp,-32
ffffffffc0200162:	862a                	mv	a2,a0
ffffffffc0200164:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200166:	00000517          	auipc	a0,0x0
ffffffffc020016a:	fe050513          	addi	a0,a0,-32 # ffffffffc0200146 <cputch>
ffffffffc020016e:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200170:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc0200172:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200174:	647050ef          	jal	ra,ffffffffc0205fba <vprintfmt>
    return cnt;
}
ffffffffc0200178:	60e2                	ld	ra,24(sp)
ffffffffc020017a:	4532                	lw	a0,12(sp)
ffffffffc020017c:	6105                	addi	sp,sp,32
ffffffffc020017e:	8082                	ret

ffffffffc0200180 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc0200180:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc0200182:	02810313          	addi	t1,sp,40 # ffffffffc020b028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc0200186:	8e2a                	mv	t3,a0
ffffffffc0200188:	f42e                	sd	a1,40(sp)
ffffffffc020018a:	f832                	sd	a2,48(sp)
ffffffffc020018c:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc020018e:	00000517          	auipc	a0,0x0
ffffffffc0200192:	fb850513          	addi	a0,a0,-72 # ffffffffc0200146 <cputch>
ffffffffc0200196:	004c                	addi	a1,sp,4
ffffffffc0200198:	869a                	mv	a3,t1
ffffffffc020019a:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc020019c:	ec06                	sd	ra,24(sp)
ffffffffc020019e:	e0ba                	sd	a4,64(sp)
ffffffffc02001a0:	e4be                	sd	a5,72(sp)
ffffffffc02001a2:	e8c2                	sd	a6,80(sp)
ffffffffc02001a4:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02001a6:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02001a8:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02001aa:	611050ef          	jal	ra,ffffffffc0205fba <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02001ae:	60e2                	ld	ra,24(sp)
ffffffffc02001b0:	4512                	lw	a0,4(sp)
ffffffffc02001b2:	6125                	addi	sp,sp,96
ffffffffc02001b4:	8082                	ret

ffffffffc02001b6 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02001b6:	a6d1                	j	ffffffffc020057a <cons_putc>

ffffffffc02001b8 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02001b8:	1101                	addi	sp,sp,-32
ffffffffc02001ba:	e822                	sd	s0,16(sp)
ffffffffc02001bc:	ec06                	sd	ra,24(sp)
ffffffffc02001be:	e426                	sd	s1,8(sp)
ffffffffc02001c0:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02001c2:	00054503          	lbu	a0,0(a0)
ffffffffc02001c6:	c51d                	beqz	a0,ffffffffc02001f4 <cputs+0x3c>
ffffffffc02001c8:	0405                	addi	s0,s0,1
ffffffffc02001ca:	4485                	li	s1,1
ffffffffc02001cc:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc02001ce:	3ac000ef          	jal	ra,ffffffffc020057a <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc02001d2:	00044503          	lbu	a0,0(s0)
ffffffffc02001d6:	008487bb          	addw	a5,s1,s0
ffffffffc02001da:	0405                	addi	s0,s0,1
ffffffffc02001dc:	f96d                	bnez	a0,ffffffffc02001ce <cputs+0x16>
    (*cnt) ++;
ffffffffc02001de:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc02001e2:	4529                	li	a0,10
ffffffffc02001e4:	396000ef          	jal	ra,ffffffffc020057a <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc02001e8:	60e2                	ld	ra,24(sp)
ffffffffc02001ea:	8522                	mv	a0,s0
ffffffffc02001ec:	6442                	ld	s0,16(sp)
ffffffffc02001ee:	64a2                	ld	s1,8(sp)
ffffffffc02001f0:	6105                	addi	sp,sp,32
ffffffffc02001f2:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc02001f4:	4405                	li	s0,1
ffffffffc02001f6:	b7f5                	j	ffffffffc02001e2 <cputs+0x2a>

ffffffffc02001f8 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc02001f8:	1141                	addi	sp,sp,-16
ffffffffc02001fa:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02001fc:	3b2000ef          	jal	ra,ffffffffc02005ae <cons_getc>
ffffffffc0200200:	dd75                	beqz	a0,ffffffffc02001fc <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200202:	60a2                	ld	ra,8(sp)
ffffffffc0200204:	0141                	addi	sp,sp,16
ffffffffc0200206:	8082                	ret

ffffffffc0200208 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200208:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc020020a:	00006517          	auipc	a0,0x6
ffffffffc020020e:	20e50513          	addi	a0,a0,526 # ffffffffc0206418 <etext+0x36>
void print_kerninfo(void) {
ffffffffc0200212:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200214:	f6dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200218:	00000597          	auipc	a1,0x0
ffffffffc020021c:	e1a58593          	addi	a1,a1,-486 # ffffffffc0200032 <kern_init>
ffffffffc0200220:	00006517          	auipc	a0,0x6
ffffffffc0200224:	21850513          	addi	a0,a0,536 # ffffffffc0206438 <etext+0x56>
ffffffffc0200228:	f59ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc020022c:	00006597          	auipc	a1,0x6
ffffffffc0200230:	1b658593          	addi	a1,a1,438 # ffffffffc02063e2 <etext>
ffffffffc0200234:	00006517          	auipc	a0,0x6
ffffffffc0200238:	22450513          	addi	a0,a0,548 # ffffffffc0206458 <etext+0x76>
ffffffffc020023c:	f45ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200240:	000a7597          	auipc	a1,0xa7
ffffffffc0200244:	05058593          	addi	a1,a1,80 # ffffffffc02a7290 <buf>
ffffffffc0200248:	00006517          	auipc	a0,0x6
ffffffffc020024c:	23050513          	addi	a0,a0,560 # ffffffffc0206478 <etext+0x96>
ffffffffc0200250:	f31ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200254:	000b2597          	auipc	a1,0xb2
ffffffffc0200258:	59858593          	addi	a1,a1,1432 # ffffffffc02b27ec <end>
ffffffffc020025c:	00006517          	auipc	a0,0x6
ffffffffc0200260:	23c50513          	addi	a0,a0,572 # ffffffffc0206498 <etext+0xb6>
ffffffffc0200264:	f1dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200268:	000b3597          	auipc	a1,0xb3
ffffffffc020026c:	98358593          	addi	a1,a1,-1661 # ffffffffc02b2beb <end+0x3ff>
ffffffffc0200270:	00000797          	auipc	a5,0x0
ffffffffc0200274:	dc278793          	addi	a5,a5,-574 # ffffffffc0200032 <kern_init>
ffffffffc0200278:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020027c:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc0200280:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200282:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200286:	95be                	add	a1,a1,a5
ffffffffc0200288:	85a9                	srai	a1,a1,0xa
ffffffffc020028a:	00006517          	auipc	a0,0x6
ffffffffc020028e:	22e50513          	addi	a0,a0,558 # ffffffffc02064b8 <etext+0xd6>
}
ffffffffc0200292:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200294:	b5f5                	j	ffffffffc0200180 <cprintf>

ffffffffc0200296 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200296:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc0200298:	00006617          	auipc	a2,0x6
ffffffffc020029c:	25060613          	addi	a2,a2,592 # ffffffffc02064e8 <etext+0x106>
ffffffffc02002a0:	04d00593          	li	a1,77
ffffffffc02002a4:	00006517          	auipc	a0,0x6
ffffffffc02002a8:	25c50513          	addi	a0,a0,604 # ffffffffc0206500 <etext+0x11e>
void print_stackframe(void) {
ffffffffc02002ac:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02002ae:	1cc000ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02002b2 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002b2:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002b4:	00006617          	auipc	a2,0x6
ffffffffc02002b8:	26460613          	addi	a2,a2,612 # ffffffffc0206518 <etext+0x136>
ffffffffc02002bc:	00006597          	auipc	a1,0x6
ffffffffc02002c0:	27c58593          	addi	a1,a1,636 # ffffffffc0206538 <etext+0x156>
ffffffffc02002c4:	00006517          	auipc	a0,0x6
ffffffffc02002c8:	27c50513          	addi	a0,a0,636 # ffffffffc0206540 <etext+0x15e>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002cc:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002ce:	eb3ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc02002d2:	00006617          	auipc	a2,0x6
ffffffffc02002d6:	27e60613          	addi	a2,a2,638 # ffffffffc0206550 <etext+0x16e>
ffffffffc02002da:	00006597          	auipc	a1,0x6
ffffffffc02002de:	29e58593          	addi	a1,a1,670 # ffffffffc0206578 <etext+0x196>
ffffffffc02002e2:	00006517          	auipc	a0,0x6
ffffffffc02002e6:	25e50513          	addi	a0,a0,606 # ffffffffc0206540 <etext+0x15e>
ffffffffc02002ea:	e97ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc02002ee:	00006617          	auipc	a2,0x6
ffffffffc02002f2:	29a60613          	addi	a2,a2,666 # ffffffffc0206588 <etext+0x1a6>
ffffffffc02002f6:	00006597          	auipc	a1,0x6
ffffffffc02002fa:	2b258593          	addi	a1,a1,690 # ffffffffc02065a8 <etext+0x1c6>
ffffffffc02002fe:	00006517          	auipc	a0,0x6
ffffffffc0200302:	24250513          	addi	a0,a0,578 # ffffffffc0206540 <etext+0x15e>
ffffffffc0200306:	e7bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    }
    return 0;
}
ffffffffc020030a:	60a2                	ld	ra,8(sp)
ffffffffc020030c:	4501                	li	a0,0
ffffffffc020030e:	0141                	addi	sp,sp,16
ffffffffc0200310:	8082                	ret

ffffffffc0200312 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200312:	1141                	addi	sp,sp,-16
ffffffffc0200314:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200316:	ef3ff0ef          	jal	ra,ffffffffc0200208 <print_kerninfo>
    return 0;
}
ffffffffc020031a:	60a2                	ld	ra,8(sp)
ffffffffc020031c:	4501                	li	a0,0
ffffffffc020031e:	0141                	addi	sp,sp,16
ffffffffc0200320:	8082                	ret

ffffffffc0200322 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200322:	1141                	addi	sp,sp,-16
ffffffffc0200324:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200326:	f71ff0ef          	jal	ra,ffffffffc0200296 <print_stackframe>
    return 0;
}
ffffffffc020032a:	60a2                	ld	ra,8(sp)
ffffffffc020032c:	4501                	li	a0,0
ffffffffc020032e:	0141                	addi	sp,sp,16
ffffffffc0200330:	8082                	ret

ffffffffc0200332 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200332:	7115                	addi	sp,sp,-224
ffffffffc0200334:	ed5e                	sd	s7,152(sp)
ffffffffc0200336:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200338:	00006517          	auipc	a0,0x6
ffffffffc020033c:	28050513          	addi	a0,a0,640 # ffffffffc02065b8 <etext+0x1d6>
kmonitor(struct trapframe *tf) {
ffffffffc0200340:	ed86                	sd	ra,216(sp)
ffffffffc0200342:	e9a2                	sd	s0,208(sp)
ffffffffc0200344:	e5a6                	sd	s1,200(sp)
ffffffffc0200346:	e1ca                	sd	s2,192(sp)
ffffffffc0200348:	fd4e                	sd	s3,184(sp)
ffffffffc020034a:	f952                	sd	s4,176(sp)
ffffffffc020034c:	f556                	sd	s5,168(sp)
ffffffffc020034e:	f15a                	sd	s6,160(sp)
ffffffffc0200350:	e962                	sd	s8,144(sp)
ffffffffc0200352:	e566                	sd	s9,136(sp)
ffffffffc0200354:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200356:	e2bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020035a:	00006517          	auipc	a0,0x6
ffffffffc020035e:	28650513          	addi	a0,a0,646 # ffffffffc02065e0 <etext+0x1fe>
ffffffffc0200362:	e1fff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    if (tf != NULL) {
ffffffffc0200366:	000b8563          	beqz	s7,ffffffffc0200370 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020036a:	855e                	mv	a0,s7
ffffffffc020036c:	4a4000ef          	jal	ra,ffffffffc0200810 <print_trapframe>
ffffffffc0200370:	00006c17          	auipc	s8,0x6
ffffffffc0200374:	2e0c0c13          	addi	s8,s8,736 # ffffffffc0206650 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200378:	00006917          	auipc	s2,0x6
ffffffffc020037c:	29090913          	addi	s2,s2,656 # ffffffffc0206608 <etext+0x226>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200380:	00006497          	auipc	s1,0x6
ffffffffc0200384:	29048493          	addi	s1,s1,656 # ffffffffc0206610 <etext+0x22e>
        if (argc == MAXARGS - 1) {
ffffffffc0200388:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020038a:	00006b17          	auipc	s6,0x6
ffffffffc020038e:	28eb0b13          	addi	s6,s6,654 # ffffffffc0206618 <etext+0x236>
        argv[argc ++] = buf;
ffffffffc0200392:	00006a17          	auipc	s4,0x6
ffffffffc0200396:	1a6a0a13          	addi	s4,s4,422 # ffffffffc0206538 <etext+0x156>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020039a:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc020039c:	854a                	mv	a0,s2
ffffffffc020039e:	cf5ff0ef          	jal	ra,ffffffffc0200092 <readline>
ffffffffc02003a2:	842a                	mv	s0,a0
ffffffffc02003a4:	dd65                	beqz	a0,ffffffffc020039c <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003a6:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02003aa:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003ac:	e1bd                	bnez	a1,ffffffffc0200412 <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc02003ae:	fe0c87e3          	beqz	s9,ffffffffc020039c <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003b2:	6582                	ld	a1,0(sp)
ffffffffc02003b4:	00006d17          	auipc	s10,0x6
ffffffffc02003b8:	29cd0d13          	addi	s10,s10,668 # ffffffffc0206650 <commands>
        argv[argc ++] = buf;
ffffffffc02003bc:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003be:	4401                	li	s0,0
ffffffffc02003c0:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003c2:	7c3050ef          	jal	ra,ffffffffc0206384 <strcmp>
ffffffffc02003c6:	c919                	beqz	a0,ffffffffc02003dc <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003c8:	2405                	addiw	s0,s0,1
ffffffffc02003ca:	0b540063          	beq	s0,s5,ffffffffc020046a <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003ce:	000d3503          	ld	a0,0(s10)
ffffffffc02003d2:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003d4:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003d6:	7af050ef          	jal	ra,ffffffffc0206384 <strcmp>
ffffffffc02003da:	f57d                	bnez	a0,ffffffffc02003c8 <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02003dc:	00141793          	slli	a5,s0,0x1
ffffffffc02003e0:	97a2                	add	a5,a5,s0
ffffffffc02003e2:	078e                	slli	a5,a5,0x3
ffffffffc02003e4:	97e2                	add	a5,a5,s8
ffffffffc02003e6:	6b9c                	ld	a5,16(a5)
ffffffffc02003e8:	865e                	mv	a2,s7
ffffffffc02003ea:	002c                	addi	a1,sp,8
ffffffffc02003ec:	fffc851b          	addiw	a0,s9,-1
ffffffffc02003f0:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc02003f2:	fa0555e3          	bgez	a0,ffffffffc020039c <kmonitor+0x6a>
}
ffffffffc02003f6:	60ee                	ld	ra,216(sp)
ffffffffc02003f8:	644e                	ld	s0,208(sp)
ffffffffc02003fa:	64ae                	ld	s1,200(sp)
ffffffffc02003fc:	690e                	ld	s2,192(sp)
ffffffffc02003fe:	79ea                	ld	s3,184(sp)
ffffffffc0200400:	7a4a                	ld	s4,176(sp)
ffffffffc0200402:	7aaa                	ld	s5,168(sp)
ffffffffc0200404:	7b0a                	ld	s6,160(sp)
ffffffffc0200406:	6bea                	ld	s7,152(sp)
ffffffffc0200408:	6c4a                	ld	s8,144(sp)
ffffffffc020040a:	6caa                	ld	s9,136(sp)
ffffffffc020040c:	6d0a                	ld	s10,128(sp)
ffffffffc020040e:	612d                	addi	sp,sp,224
ffffffffc0200410:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200412:	8526                	mv	a0,s1
ffffffffc0200414:	78f050ef          	jal	ra,ffffffffc02063a2 <strchr>
ffffffffc0200418:	c901                	beqz	a0,ffffffffc0200428 <kmonitor+0xf6>
ffffffffc020041a:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc020041e:	00040023          	sb	zero,0(s0)
ffffffffc0200422:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200424:	d5c9                	beqz	a1,ffffffffc02003ae <kmonitor+0x7c>
ffffffffc0200426:	b7f5                	j	ffffffffc0200412 <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc0200428:	00044783          	lbu	a5,0(s0)
ffffffffc020042c:	d3c9                	beqz	a5,ffffffffc02003ae <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc020042e:	033c8963          	beq	s9,s3,ffffffffc0200460 <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc0200432:	003c9793          	slli	a5,s9,0x3
ffffffffc0200436:	0118                	addi	a4,sp,128
ffffffffc0200438:	97ba                	add	a5,a5,a4
ffffffffc020043a:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020043e:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200442:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200444:	e591                	bnez	a1,ffffffffc0200450 <kmonitor+0x11e>
ffffffffc0200446:	b7b5                	j	ffffffffc02003b2 <kmonitor+0x80>
ffffffffc0200448:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc020044c:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020044e:	d1a5                	beqz	a1,ffffffffc02003ae <kmonitor+0x7c>
ffffffffc0200450:	8526                	mv	a0,s1
ffffffffc0200452:	751050ef          	jal	ra,ffffffffc02063a2 <strchr>
ffffffffc0200456:	d96d                	beqz	a0,ffffffffc0200448 <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200458:	00044583          	lbu	a1,0(s0)
ffffffffc020045c:	d9a9                	beqz	a1,ffffffffc02003ae <kmonitor+0x7c>
ffffffffc020045e:	bf55                	j	ffffffffc0200412 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200460:	45c1                	li	a1,16
ffffffffc0200462:	855a                	mv	a0,s6
ffffffffc0200464:	d1dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0200468:	b7e9                	j	ffffffffc0200432 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020046a:	6582                	ld	a1,0(sp)
ffffffffc020046c:	00006517          	auipc	a0,0x6
ffffffffc0200470:	1cc50513          	addi	a0,a0,460 # ffffffffc0206638 <etext+0x256>
ffffffffc0200474:	d0dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    return 0;
ffffffffc0200478:	b715                	j	ffffffffc020039c <kmonitor+0x6a>

ffffffffc020047a <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc020047a:	000b2317          	auipc	t1,0xb2
ffffffffc020047e:	2de30313          	addi	t1,t1,734 # ffffffffc02b2758 <is_panic>
ffffffffc0200482:	00033e03          	ld	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200486:	715d                	addi	sp,sp,-80
ffffffffc0200488:	ec06                	sd	ra,24(sp)
ffffffffc020048a:	e822                	sd	s0,16(sp)
ffffffffc020048c:	f436                	sd	a3,40(sp)
ffffffffc020048e:	f83a                	sd	a4,48(sp)
ffffffffc0200490:	fc3e                	sd	a5,56(sp)
ffffffffc0200492:	e0c2                	sd	a6,64(sp)
ffffffffc0200494:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200496:	020e1a63          	bnez	t3,ffffffffc02004ca <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc020049a:	4785                	li	a5,1
ffffffffc020049c:	00f33023          	sd	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc02004a0:	8432                	mv	s0,a2
ffffffffc02004a2:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004a4:	862e                	mv	a2,a1
ffffffffc02004a6:	85aa                	mv	a1,a0
ffffffffc02004a8:	00006517          	auipc	a0,0x6
ffffffffc02004ac:	1f050513          	addi	a0,a0,496 # ffffffffc0206698 <commands+0x48>
    va_start(ap, fmt);
ffffffffc02004b0:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004b2:	ccfff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02004b6:	65a2                	ld	a1,8(sp)
ffffffffc02004b8:	8522                	mv	a0,s0
ffffffffc02004ba:	ca7ff0ef          	jal	ra,ffffffffc0200160 <vcprintf>
    cprintf("\n");
ffffffffc02004be:	00007517          	auipc	a0,0x7
ffffffffc02004c2:	1b250513          	addi	a0,a0,434 # ffffffffc0207670 <default_pmm_manager+0x538>
ffffffffc02004c6:	cbbff0ef          	jal	ra,ffffffffc0200180 <cprintf>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc02004ca:	4501                	li	a0,0
ffffffffc02004cc:	4581                	li	a1,0
ffffffffc02004ce:	4601                	li	a2,0
ffffffffc02004d0:	48a1                	li	a7,8
ffffffffc02004d2:	00000073          	ecall
    va_end(ap);

panic_dead:
    // No debug monitor here
    sbi_shutdown();
    intr_disable();
ffffffffc02004d6:	14c000ef          	jal	ra,ffffffffc0200622 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02004da:	4501                	li	a0,0
ffffffffc02004dc:	e57ff0ef          	jal	ra,ffffffffc0200332 <kmonitor>
    while (1) {
ffffffffc02004e0:	bfed                	j	ffffffffc02004da <__panic+0x60>

ffffffffc02004e2 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc02004e2:	715d                	addi	sp,sp,-80
ffffffffc02004e4:	832e                	mv	t1,a1
ffffffffc02004e6:	e822                	sd	s0,16(sp)
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02004e8:	85aa                	mv	a1,a0
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc02004ea:	8432                	mv	s0,a2
ffffffffc02004ec:	fc3e                	sd	a5,56(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02004ee:	861a                	mv	a2,t1
    va_start(ap, fmt);
ffffffffc02004f0:	103c                	addi	a5,sp,40
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02004f2:	00006517          	auipc	a0,0x6
ffffffffc02004f6:	1c650513          	addi	a0,a0,454 # ffffffffc02066b8 <commands+0x68>
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc02004fa:	ec06                	sd	ra,24(sp)
ffffffffc02004fc:	f436                	sd	a3,40(sp)
ffffffffc02004fe:	f83a                	sd	a4,48(sp)
ffffffffc0200500:	e0c2                	sd	a6,64(sp)
ffffffffc0200502:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0200504:	e43e                	sd	a5,8(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc0200506:	c7bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    vcprintf(fmt, ap);
ffffffffc020050a:	65a2                	ld	a1,8(sp)
ffffffffc020050c:	8522                	mv	a0,s0
ffffffffc020050e:	c53ff0ef          	jal	ra,ffffffffc0200160 <vcprintf>
    cprintf("\n");
ffffffffc0200512:	00007517          	auipc	a0,0x7
ffffffffc0200516:	15e50513          	addi	a0,a0,350 # ffffffffc0207670 <default_pmm_manager+0x538>
ffffffffc020051a:	c67ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    va_end(ap);
}
ffffffffc020051e:	60e2                	ld	ra,24(sp)
ffffffffc0200520:	6442                	ld	s0,16(sp)
ffffffffc0200522:	6161                	addi	sp,sp,80
ffffffffc0200524:	8082                	ret

ffffffffc0200526 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc0200526:	67e1                	lui	a5,0x18
ffffffffc0200528:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_exit_out_size+0xd580>
ffffffffc020052c:	000b2717          	auipc	a4,0xb2
ffffffffc0200530:	22f73e23          	sd	a5,572(a4) # ffffffffc02b2768 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200534:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc0200538:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020053a:	953e                	add	a0,a0,a5
ffffffffc020053c:	4601                	li	a2,0
ffffffffc020053e:	4881                	li	a7,0
ffffffffc0200540:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc0200544:	02000793          	li	a5,32
ffffffffc0200548:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc020054c:	00006517          	auipc	a0,0x6
ffffffffc0200550:	18c50513          	addi	a0,a0,396 # ffffffffc02066d8 <commands+0x88>
    ticks = 0;
ffffffffc0200554:	000b2797          	auipc	a5,0xb2
ffffffffc0200558:	2007b623          	sd	zero,524(a5) # ffffffffc02b2760 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020055c:	b115                	j	ffffffffc0200180 <cprintf>

ffffffffc020055e <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020055e:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200562:	000b2797          	auipc	a5,0xb2
ffffffffc0200566:	2067b783          	ld	a5,518(a5) # ffffffffc02b2768 <timebase>
ffffffffc020056a:	953e                	add	a0,a0,a5
ffffffffc020056c:	4581                	li	a1,0
ffffffffc020056e:	4601                	li	a2,0
ffffffffc0200570:	4881                	li	a7,0
ffffffffc0200572:	00000073          	ecall
ffffffffc0200576:	8082                	ret

ffffffffc0200578 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200578:	8082                	ret

ffffffffc020057a <cons_putc>:
#include <sched.h>
#include <riscv.h>
#include <assert.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020057a:	100027f3          	csrr	a5,sstatus
ffffffffc020057e:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200580:	0ff57513          	zext.b	a0,a0
ffffffffc0200584:	e799                	bnez	a5,ffffffffc0200592 <cons_putc+0x18>
ffffffffc0200586:	4581                	li	a1,0
ffffffffc0200588:	4601                	li	a2,0
ffffffffc020058a:	4885                	li	a7,1
ffffffffc020058c:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc0200590:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc0200592:	1101                	addi	sp,sp,-32
ffffffffc0200594:	ec06                	sd	ra,24(sp)
ffffffffc0200596:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200598:	08a000ef          	jal	ra,ffffffffc0200622 <intr_disable>
ffffffffc020059c:	6522                	ld	a0,8(sp)
ffffffffc020059e:	4581                	li	a1,0
ffffffffc02005a0:	4601                	li	a2,0
ffffffffc02005a2:	4885                	li	a7,1
ffffffffc02005a4:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc02005a8:	60e2                	ld	ra,24(sp)
ffffffffc02005aa:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02005ac:	a885                	j	ffffffffc020061c <intr_enable>

ffffffffc02005ae <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02005ae:	100027f3          	csrr	a5,sstatus
ffffffffc02005b2:	8b89                	andi	a5,a5,2
ffffffffc02005b4:	eb89                	bnez	a5,ffffffffc02005c6 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc02005b6:	4501                	li	a0,0
ffffffffc02005b8:	4581                	li	a1,0
ffffffffc02005ba:	4601                	li	a2,0
ffffffffc02005bc:	4889                	li	a7,2
ffffffffc02005be:	00000073          	ecall
ffffffffc02005c2:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc02005c4:	8082                	ret
int cons_getc(void) {
ffffffffc02005c6:	1101                	addi	sp,sp,-32
ffffffffc02005c8:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02005ca:	058000ef          	jal	ra,ffffffffc0200622 <intr_disable>
ffffffffc02005ce:	4501                	li	a0,0
ffffffffc02005d0:	4581                	li	a1,0
ffffffffc02005d2:	4601                	li	a2,0
ffffffffc02005d4:	4889                	li	a7,2
ffffffffc02005d6:	00000073          	ecall
ffffffffc02005da:	2501                	sext.w	a0,a0
ffffffffc02005dc:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02005de:	03e000ef          	jal	ra,ffffffffc020061c <intr_enable>
}
ffffffffc02005e2:	60e2                	ld	ra,24(sp)
ffffffffc02005e4:	6522                	ld	a0,8(sp)
ffffffffc02005e6:	6105                	addi	sp,sp,32
ffffffffc02005e8:	8082                	ret

ffffffffc02005ea <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc02005ea:	8082                	ret

ffffffffc02005ec <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc02005ec:	00253513          	sltiu	a0,a0,2
ffffffffc02005f0:	8082                	ret

ffffffffc02005f2 <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc02005f2:	03800513          	li	a0,56
ffffffffc02005f6:	8082                	ret

ffffffffc02005f8 <ide_write_secs>:
    return 0;
}

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    int iobase = secno * SECTSIZE;
ffffffffc02005f8:	0095979b          	slliw	a5,a1,0x9
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02005fc:	000a7517          	auipc	a0,0xa7
ffffffffc0200600:	09450513          	addi	a0,a0,148 # ffffffffc02a7690 <ide>
                   size_t nsecs) {
ffffffffc0200604:	1141                	addi	sp,sp,-16
ffffffffc0200606:	85b2                	mv	a1,a2
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200608:	953e                	add	a0,a0,a5
ffffffffc020060a:	00969613          	slli	a2,a3,0x9
                   size_t nsecs) {
ffffffffc020060e:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200610:	5bb050ef          	jal	ra,ffffffffc02063ca <memcpy>
    return 0;
}
ffffffffc0200614:	60a2                	ld	ra,8(sp)
ffffffffc0200616:	4501                	li	a0,0
ffffffffc0200618:	0141                	addi	sp,sp,16
ffffffffc020061a:	8082                	ret

ffffffffc020061c <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc020061c:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200620:	8082                	ret

ffffffffc0200622 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200622:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200626:	8082                	ret

ffffffffc0200628 <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc0200628:	8082                	ret

ffffffffc020062a <idt_init>:
void
idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020062a:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc020062e:	00000797          	auipc	a5,0x0
ffffffffc0200632:	65a78793          	addi	a5,a5,1626 # ffffffffc0200c88 <__alltraps>
ffffffffc0200636:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc020063a:	000407b7          	lui	a5,0x40
ffffffffc020063e:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200642:	8082                	ret

ffffffffc0200644 <print_regs>:
    cprintf("  tval 0x%08x\n", tf->tval);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs* gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200644:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs* gpr) {
ffffffffc0200646:	1141                	addi	sp,sp,-16
ffffffffc0200648:	e022                	sd	s0,0(sp)
ffffffffc020064a:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020064c:	00006517          	auipc	a0,0x6
ffffffffc0200650:	0ac50513          	addi	a0,a0,172 # ffffffffc02066f8 <commands+0xa8>
void print_regs(struct pushregs* gpr) {
ffffffffc0200654:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200656:	b2bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020065a:	640c                	ld	a1,8(s0)
ffffffffc020065c:	00006517          	auipc	a0,0x6
ffffffffc0200660:	0b450513          	addi	a0,a0,180 # ffffffffc0206710 <commands+0xc0>
ffffffffc0200664:	b1dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200668:	680c                	ld	a1,16(s0)
ffffffffc020066a:	00006517          	auipc	a0,0x6
ffffffffc020066e:	0be50513          	addi	a0,a0,190 # ffffffffc0206728 <commands+0xd8>
ffffffffc0200672:	b0fff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200676:	6c0c                	ld	a1,24(s0)
ffffffffc0200678:	00006517          	auipc	a0,0x6
ffffffffc020067c:	0c850513          	addi	a0,a0,200 # ffffffffc0206740 <commands+0xf0>
ffffffffc0200680:	b01ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc0200684:	700c                	ld	a1,32(s0)
ffffffffc0200686:	00006517          	auipc	a0,0x6
ffffffffc020068a:	0d250513          	addi	a0,a0,210 # ffffffffc0206758 <commands+0x108>
ffffffffc020068e:	af3ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc0200692:	740c                	ld	a1,40(s0)
ffffffffc0200694:	00006517          	auipc	a0,0x6
ffffffffc0200698:	0dc50513          	addi	a0,a0,220 # ffffffffc0206770 <commands+0x120>
ffffffffc020069c:	ae5ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006a0:	780c                	ld	a1,48(s0)
ffffffffc02006a2:	00006517          	auipc	a0,0x6
ffffffffc02006a6:	0e650513          	addi	a0,a0,230 # ffffffffc0206788 <commands+0x138>
ffffffffc02006aa:	ad7ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006ae:	7c0c                	ld	a1,56(s0)
ffffffffc02006b0:	00006517          	auipc	a0,0x6
ffffffffc02006b4:	0f050513          	addi	a0,a0,240 # ffffffffc02067a0 <commands+0x150>
ffffffffc02006b8:	ac9ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006bc:	602c                	ld	a1,64(s0)
ffffffffc02006be:	00006517          	auipc	a0,0x6
ffffffffc02006c2:	0fa50513          	addi	a0,a0,250 # ffffffffc02067b8 <commands+0x168>
ffffffffc02006c6:	abbff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006ca:	642c                	ld	a1,72(s0)
ffffffffc02006cc:	00006517          	auipc	a0,0x6
ffffffffc02006d0:	10450513          	addi	a0,a0,260 # ffffffffc02067d0 <commands+0x180>
ffffffffc02006d4:	aadff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02006d8:	682c                	ld	a1,80(s0)
ffffffffc02006da:	00006517          	auipc	a0,0x6
ffffffffc02006de:	10e50513          	addi	a0,a0,270 # ffffffffc02067e8 <commands+0x198>
ffffffffc02006e2:	a9fff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc02006e6:	6c2c                	ld	a1,88(s0)
ffffffffc02006e8:	00006517          	auipc	a0,0x6
ffffffffc02006ec:	11850513          	addi	a0,a0,280 # ffffffffc0206800 <commands+0x1b0>
ffffffffc02006f0:	a91ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc02006f4:	702c                	ld	a1,96(s0)
ffffffffc02006f6:	00006517          	auipc	a0,0x6
ffffffffc02006fa:	12250513          	addi	a0,a0,290 # ffffffffc0206818 <commands+0x1c8>
ffffffffc02006fe:	a83ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200702:	742c                	ld	a1,104(s0)
ffffffffc0200704:	00006517          	auipc	a0,0x6
ffffffffc0200708:	12c50513          	addi	a0,a0,300 # ffffffffc0206830 <commands+0x1e0>
ffffffffc020070c:	a75ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200710:	782c                	ld	a1,112(s0)
ffffffffc0200712:	00006517          	auipc	a0,0x6
ffffffffc0200716:	13650513          	addi	a0,a0,310 # ffffffffc0206848 <commands+0x1f8>
ffffffffc020071a:	a67ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020071e:	7c2c                	ld	a1,120(s0)
ffffffffc0200720:	00006517          	auipc	a0,0x6
ffffffffc0200724:	14050513          	addi	a0,a0,320 # ffffffffc0206860 <commands+0x210>
ffffffffc0200728:	a59ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020072c:	604c                	ld	a1,128(s0)
ffffffffc020072e:	00006517          	auipc	a0,0x6
ffffffffc0200732:	14a50513          	addi	a0,a0,330 # ffffffffc0206878 <commands+0x228>
ffffffffc0200736:	a4bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020073a:	644c                	ld	a1,136(s0)
ffffffffc020073c:	00006517          	auipc	a0,0x6
ffffffffc0200740:	15450513          	addi	a0,a0,340 # ffffffffc0206890 <commands+0x240>
ffffffffc0200744:	a3dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200748:	684c                	ld	a1,144(s0)
ffffffffc020074a:	00006517          	auipc	a0,0x6
ffffffffc020074e:	15e50513          	addi	a0,a0,350 # ffffffffc02068a8 <commands+0x258>
ffffffffc0200752:	a2fff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200756:	6c4c                	ld	a1,152(s0)
ffffffffc0200758:	00006517          	auipc	a0,0x6
ffffffffc020075c:	16850513          	addi	a0,a0,360 # ffffffffc02068c0 <commands+0x270>
ffffffffc0200760:	a21ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200764:	704c                	ld	a1,160(s0)
ffffffffc0200766:	00006517          	auipc	a0,0x6
ffffffffc020076a:	17250513          	addi	a0,a0,370 # ffffffffc02068d8 <commands+0x288>
ffffffffc020076e:	a13ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200772:	744c                	ld	a1,168(s0)
ffffffffc0200774:	00006517          	auipc	a0,0x6
ffffffffc0200778:	17c50513          	addi	a0,a0,380 # ffffffffc02068f0 <commands+0x2a0>
ffffffffc020077c:	a05ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc0200780:	784c                	ld	a1,176(s0)
ffffffffc0200782:	00006517          	auipc	a0,0x6
ffffffffc0200786:	18650513          	addi	a0,a0,390 # ffffffffc0206908 <commands+0x2b8>
ffffffffc020078a:	9f7ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc020078e:	7c4c                	ld	a1,184(s0)
ffffffffc0200790:	00006517          	auipc	a0,0x6
ffffffffc0200794:	19050513          	addi	a0,a0,400 # ffffffffc0206920 <commands+0x2d0>
ffffffffc0200798:	9e9ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc020079c:	606c                	ld	a1,192(s0)
ffffffffc020079e:	00006517          	auipc	a0,0x6
ffffffffc02007a2:	19a50513          	addi	a0,a0,410 # ffffffffc0206938 <commands+0x2e8>
ffffffffc02007a6:	9dbff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007aa:	646c                	ld	a1,200(s0)
ffffffffc02007ac:	00006517          	auipc	a0,0x6
ffffffffc02007b0:	1a450513          	addi	a0,a0,420 # ffffffffc0206950 <commands+0x300>
ffffffffc02007b4:	9cdff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007b8:	686c                	ld	a1,208(s0)
ffffffffc02007ba:	00006517          	auipc	a0,0x6
ffffffffc02007be:	1ae50513          	addi	a0,a0,430 # ffffffffc0206968 <commands+0x318>
ffffffffc02007c2:	9bfff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007c6:	6c6c                	ld	a1,216(s0)
ffffffffc02007c8:	00006517          	auipc	a0,0x6
ffffffffc02007cc:	1b850513          	addi	a0,a0,440 # ffffffffc0206980 <commands+0x330>
ffffffffc02007d0:	9b1ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02007d4:	706c                	ld	a1,224(s0)
ffffffffc02007d6:	00006517          	auipc	a0,0x6
ffffffffc02007da:	1c250513          	addi	a0,a0,450 # ffffffffc0206998 <commands+0x348>
ffffffffc02007de:	9a3ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc02007e2:	746c                	ld	a1,232(s0)
ffffffffc02007e4:	00006517          	auipc	a0,0x6
ffffffffc02007e8:	1cc50513          	addi	a0,a0,460 # ffffffffc02069b0 <commands+0x360>
ffffffffc02007ec:	995ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc02007f0:	786c                	ld	a1,240(s0)
ffffffffc02007f2:	00006517          	auipc	a0,0x6
ffffffffc02007f6:	1d650513          	addi	a0,a0,470 # ffffffffc02069c8 <commands+0x378>
ffffffffc02007fa:	987ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc02007fe:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200800:	6402                	ld	s0,0(sp)
ffffffffc0200802:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200804:	00006517          	auipc	a0,0x6
ffffffffc0200808:	1dc50513          	addi	a0,a0,476 # ffffffffc02069e0 <commands+0x390>
}
ffffffffc020080c:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020080e:	ba8d                	j	ffffffffc0200180 <cprintf>

ffffffffc0200810 <print_trapframe>:
print_trapframe(struct trapframe *tf) {
ffffffffc0200810:	1141                	addi	sp,sp,-16
ffffffffc0200812:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200814:	85aa                	mv	a1,a0
print_trapframe(struct trapframe *tf) {
ffffffffc0200816:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200818:	00006517          	auipc	a0,0x6
ffffffffc020081c:	1e050513          	addi	a0,a0,480 # ffffffffc02069f8 <commands+0x3a8>
print_trapframe(struct trapframe *tf) {
ffffffffc0200820:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200822:	95fff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200826:	8522                	mv	a0,s0
ffffffffc0200828:	e1dff0ef          	jal	ra,ffffffffc0200644 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020082c:	10043583          	ld	a1,256(s0)
ffffffffc0200830:	00006517          	auipc	a0,0x6
ffffffffc0200834:	1e050513          	addi	a0,a0,480 # ffffffffc0206a10 <commands+0x3c0>
ffffffffc0200838:	949ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020083c:	10843583          	ld	a1,264(s0)
ffffffffc0200840:	00006517          	auipc	a0,0x6
ffffffffc0200844:	1e850513          	addi	a0,a0,488 # ffffffffc0206a28 <commands+0x3d8>
ffffffffc0200848:	939ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc020084c:	11043583          	ld	a1,272(s0)
ffffffffc0200850:	00006517          	auipc	a0,0x6
ffffffffc0200854:	1f050513          	addi	a0,a0,496 # ffffffffc0206a40 <commands+0x3f0>
ffffffffc0200858:	929ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020085c:	11843583          	ld	a1,280(s0)
}
ffffffffc0200860:	6402                	ld	s0,0(sp)
ffffffffc0200862:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200864:	00006517          	auipc	a0,0x6
ffffffffc0200868:	1ec50513          	addi	a0,a0,492 # ffffffffc0206a50 <commands+0x400>
}
ffffffffc020086c:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020086e:	913ff06f          	j	ffffffffc0200180 <cprintf>

ffffffffc0200872 <pgfault_handler>:
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int
pgfault_handler(struct trapframe *tf) {
ffffffffc0200872:	1101                	addi	sp,sp,-32
ffffffffc0200874:	e426                	sd	s1,8(sp)
    extern struct mm_struct *check_mm_struct;
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc0200876:	000b2497          	auipc	s1,0xb2
ffffffffc020087a:	f4a48493          	addi	s1,s1,-182 # ffffffffc02b27c0 <check_mm_struct>
ffffffffc020087e:	609c                	ld	a5,0(s1)
pgfault_handler(struct trapframe *tf) {
ffffffffc0200880:	e822                	sd	s0,16(sp)
ffffffffc0200882:	ec06                	sd	ra,24(sp)
ffffffffc0200884:	842a                	mv	s0,a0
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc0200886:	cbad                	beqz	a5,ffffffffc02008f8 <pgfault_handler+0x86>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200888:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc020088c:	11053583          	ld	a1,272(a0)
ffffffffc0200890:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200894:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200898:	c7b1                	beqz	a5,ffffffffc02008e4 <pgfault_handler+0x72>
ffffffffc020089a:	11843703          	ld	a4,280(s0)
ffffffffc020089e:	47bd                	li	a5,15
ffffffffc02008a0:	05700693          	li	a3,87
ffffffffc02008a4:	00f70463          	beq	a4,a5,ffffffffc02008ac <pgfault_handler+0x3a>
ffffffffc02008a8:	05200693          	li	a3,82
ffffffffc02008ac:	00006517          	auipc	a0,0x6
ffffffffc02008b0:	1bc50513          	addi	a0,a0,444 # ffffffffc0206a68 <commands+0x418>
ffffffffc02008b4:	8cdff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            print_pgfault(tf);
        }
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
ffffffffc02008b8:	6088                	ld	a0,0(s1)
ffffffffc02008ba:	cd1d                	beqz	a0,ffffffffc02008f8 <pgfault_handler+0x86>
        assert(current == idleproc);
ffffffffc02008bc:	000b2717          	auipc	a4,0xb2
ffffffffc02008c0:	f1473703          	ld	a4,-236(a4) # ffffffffc02b27d0 <current>
ffffffffc02008c4:	000b2797          	auipc	a5,0xb2
ffffffffc02008c8:	f147b783          	ld	a5,-236(a5) # ffffffffc02b27d8 <idleproc>
ffffffffc02008cc:	04f71663          	bne	a4,a5,ffffffffc0200918 <pgfault_handler+0xa6>
            print_pgfault(tf);
            panic("unhandled page fault.\n");
        }
        mm = current->mm;
    }
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc02008d0:	11043603          	ld	a2,272(s0)
ffffffffc02008d4:	11843583          	ld	a1,280(s0)
}
ffffffffc02008d8:	6442                	ld	s0,16(sp)
ffffffffc02008da:	60e2                	ld	ra,24(sp)
ffffffffc02008dc:	64a2                	ld	s1,8(sp)
ffffffffc02008de:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc02008e0:	7d70306f          	j	ffffffffc02048b6 <do_pgfault>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008e4:	11843703          	ld	a4,280(s0)
ffffffffc02008e8:	47bd                	li	a5,15
ffffffffc02008ea:	05500613          	li	a2,85
ffffffffc02008ee:	05700693          	li	a3,87
ffffffffc02008f2:	faf71be3          	bne	a4,a5,ffffffffc02008a8 <pgfault_handler+0x36>
ffffffffc02008f6:	bf5d                	j	ffffffffc02008ac <pgfault_handler+0x3a>
        if (current == NULL) {
ffffffffc02008f8:	000b2797          	auipc	a5,0xb2
ffffffffc02008fc:	ed87b783          	ld	a5,-296(a5) # ffffffffc02b27d0 <current>
ffffffffc0200900:	cf85                	beqz	a5,ffffffffc0200938 <pgfault_handler+0xc6>
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200902:	11043603          	ld	a2,272(s0)
ffffffffc0200906:	11843583          	ld	a1,280(s0)
}
ffffffffc020090a:	6442                	ld	s0,16(sp)
ffffffffc020090c:	60e2                	ld	ra,24(sp)
ffffffffc020090e:	64a2                	ld	s1,8(sp)
        mm = current->mm;
ffffffffc0200910:	7788                	ld	a0,40(a5)
}
ffffffffc0200912:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200914:	7a30306f          	j	ffffffffc02048b6 <do_pgfault>
        assert(current == idleproc);
ffffffffc0200918:	00006697          	auipc	a3,0x6
ffffffffc020091c:	17068693          	addi	a3,a3,368 # ffffffffc0206a88 <commands+0x438>
ffffffffc0200920:	00006617          	auipc	a2,0x6
ffffffffc0200924:	18060613          	addi	a2,a2,384 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0200928:	06b00593          	li	a1,107
ffffffffc020092c:	00006517          	auipc	a0,0x6
ffffffffc0200930:	18c50513          	addi	a0,a0,396 # ffffffffc0206ab8 <commands+0x468>
ffffffffc0200934:	b47ff0ef          	jal	ra,ffffffffc020047a <__panic>
            print_trapframe(tf);
ffffffffc0200938:	8522                	mv	a0,s0
ffffffffc020093a:	ed7ff0ef          	jal	ra,ffffffffc0200810 <print_trapframe>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc020093e:	10043783          	ld	a5,256(s0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200942:	11043583          	ld	a1,272(s0)
ffffffffc0200946:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc020094a:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc020094e:	e399                	bnez	a5,ffffffffc0200954 <pgfault_handler+0xe2>
ffffffffc0200950:	05500613          	li	a2,85
ffffffffc0200954:	11843703          	ld	a4,280(s0)
ffffffffc0200958:	47bd                	li	a5,15
ffffffffc020095a:	02f70663          	beq	a4,a5,ffffffffc0200986 <pgfault_handler+0x114>
ffffffffc020095e:	05200693          	li	a3,82
ffffffffc0200962:	00006517          	auipc	a0,0x6
ffffffffc0200966:	10650513          	addi	a0,a0,262 # ffffffffc0206a68 <commands+0x418>
ffffffffc020096a:	817ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            panic("unhandled page fault.\n");
ffffffffc020096e:	00006617          	auipc	a2,0x6
ffffffffc0200972:	16260613          	addi	a2,a2,354 # ffffffffc0206ad0 <commands+0x480>
ffffffffc0200976:	07200593          	li	a1,114
ffffffffc020097a:	00006517          	auipc	a0,0x6
ffffffffc020097e:	13e50513          	addi	a0,a0,318 # ffffffffc0206ab8 <commands+0x468>
ffffffffc0200982:	af9ff0ef          	jal	ra,ffffffffc020047a <__panic>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200986:	05700693          	li	a3,87
ffffffffc020098a:	bfe1                	j	ffffffffc0200962 <pgfault_handler+0xf0>

ffffffffc020098c <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc020098c:	11853783          	ld	a5,280(a0)
ffffffffc0200990:	472d                	li	a4,11
ffffffffc0200992:	0786                	slli	a5,a5,0x1
ffffffffc0200994:	8385                	srli	a5,a5,0x1
ffffffffc0200996:	08f76363          	bltu	a4,a5,ffffffffc0200a1c <interrupt_handler+0x90>
ffffffffc020099a:	00006717          	auipc	a4,0x6
ffffffffc020099e:	1ee70713          	addi	a4,a4,494 # ffffffffc0206b88 <commands+0x538>
ffffffffc02009a2:	078a                	slli	a5,a5,0x2
ffffffffc02009a4:	97ba                	add	a5,a5,a4
ffffffffc02009a6:	439c                	lw	a5,0(a5)
ffffffffc02009a8:	97ba                	add	a5,a5,a4
ffffffffc02009aa:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02009ac:	00006517          	auipc	a0,0x6
ffffffffc02009b0:	19c50513          	addi	a0,a0,412 # ffffffffc0206b48 <commands+0x4f8>
ffffffffc02009b4:	fccff06f          	j	ffffffffc0200180 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02009b8:	00006517          	auipc	a0,0x6
ffffffffc02009bc:	17050513          	addi	a0,a0,368 # ffffffffc0206b28 <commands+0x4d8>
ffffffffc02009c0:	fc0ff06f          	j	ffffffffc0200180 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02009c4:	00006517          	auipc	a0,0x6
ffffffffc02009c8:	12450513          	addi	a0,a0,292 # ffffffffc0206ae8 <commands+0x498>
ffffffffc02009cc:	fb4ff06f          	j	ffffffffc0200180 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02009d0:	00006517          	auipc	a0,0x6
ffffffffc02009d4:	13850513          	addi	a0,a0,312 # ffffffffc0206b08 <commands+0x4b8>
ffffffffc02009d8:	fa8ff06f          	j	ffffffffc0200180 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02009dc:	1141                	addi	sp,sp,-16
ffffffffc02009de:	e406                	sd	ra,8(sp)
            // "All bits besides SSIP and USIP in the sip register are
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc02009e0:	b7fff0ef          	jal	ra,ffffffffc020055e <clock_set_next_event>
            if (++ticks % TICK_NUM == 0 && current) {
ffffffffc02009e4:	000b2697          	auipc	a3,0xb2
ffffffffc02009e8:	d7c68693          	addi	a3,a3,-644 # ffffffffc02b2760 <ticks>
ffffffffc02009ec:	629c                	ld	a5,0(a3)
ffffffffc02009ee:	06400713          	li	a4,100
ffffffffc02009f2:	0785                	addi	a5,a5,1
ffffffffc02009f4:	02e7f733          	remu	a4,a5,a4
ffffffffc02009f8:	e29c                	sd	a5,0(a3)
ffffffffc02009fa:	eb01                	bnez	a4,ffffffffc0200a0a <interrupt_handler+0x7e>
ffffffffc02009fc:	000b2797          	auipc	a5,0xb2
ffffffffc0200a00:	dd47b783          	ld	a5,-556(a5) # ffffffffc02b27d0 <current>
ffffffffc0200a04:	c399                	beqz	a5,ffffffffc0200a0a <interrupt_handler+0x7e>
                // print_ticks();
                current->need_resched = 1;
ffffffffc0200a06:	4705                	li	a4,1
ffffffffc0200a08:	ef98                	sd	a4,24(a5)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a0a:	60a2                	ld	ra,8(sp)
ffffffffc0200a0c:	0141                	addi	sp,sp,16
ffffffffc0200a0e:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200a10:	00006517          	auipc	a0,0x6
ffffffffc0200a14:	15850513          	addi	a0,a0,344 # ffffffffc0206b68 <commands+0x518>
ffffffffc0200a18:	f68ff06f          	j	ffffffffc0200180 <cprintf>
            print_trapframe(tf);
ffffffffc0200a1c:	bbd5                	j	ffffffffc0200810 <print_trapframe>

ffffffffc0200a1e <exception_handler>:
void kernel_execve_ret(struct trapframe *tf,uintptr_t kstacktop);
void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200a1e:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc0200a22:	1101                	addi	sp,sp,-32
ffffffffc0200a24:	e822                	sd	s0,16(sp)
ffffffffc0200a26:	ec06                	sd	ra,24(sp)
ffffffffc0200a28:	e426                	sd	s1,8(sp)
ffffffffc0200a2a:	473d                	li	a4,15
ffffffffc0200a2c:	842a                	mv	s0,a0
ffffffffc0200a2e:	18f76563          	bltu	a4,a5,ffffffffc0200bb8 <exception_handler+0x19a>
ffffffffc0200a32:	00006717          	auipc	a4,0x6
ffffffffc0200a36:	31e70713          	addi	a4,a4,798 # ffffffffc0206d50 <commands+0x700>
ffffffffc0200a3a:	078a                	slli	a5,a5,0x2
ffffffffc0200a3c:	97ba                	add	a5,a5,a4
ffffffffc0200a3e:	439c                	lw	a5,0(a5)
ffffffffc0200a40:	97ba                	add	a5,a5,a4
ffffffffc0200a42:	8782                	jr	a5
            //cprintf("Environment call from U-mode\n");
            tf->epc += 4;
            syscall();
            break;
        case CAUSE_SUPERVISOR_ECALL:
            cprintf("Environment call from S-mode\n");
ffffffffc0200a44:	00006517          	auipc	a0,0x6
ffffffffc0200a48:	26450513          	addi	a0,a0,612 # ffffffffc0206ca8 <commands+0x658>
ffffffffc0200a4c:	f34ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            tf->epc += 4;
ffffffffc0200a50:	10843783          	ld	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a54:	60e2                	ld	ra,24(sp)
ffffffffc0200a56:	64a2                	ld	s1,8(sp)
            tf->epc += 4;
ffffffffc0200a58:	0791                	addi	a5,a5,4
ffffffffc0200a5a:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200a5e:	6442                	ld	s0,16(sp)
ffffffffc0200a60:	6105                	addi	sp,sp,32
            syscall();
ffffffffc0200a62:	4560506f          	j	ffffffffc0205eb8 <syscall>
            cprintf("Environment call from H-mode\n");
ffffffffc0200a66:	00006517          	auipc	a0,0x6
ffffffffc0200a6a:	26250513          	addi	a0,a0,610 # ffffffffc0206cc8 <commands+0x678>
}
ffffffffc0200a6e:	6442                	ld	s0,16(sp)
ffffffffc0200a70:	60e2                	ld	ra,24(sp)
ffffffffc0200a72:	64a2                	ld	s1,8(sp)
ffffffffc0200a74:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200a76:	f0aff06f          	j	ffffffffc0200180 <cprintf>
            cprintf("Environment call from M-mode\n");
ffffffffc0200a7a:	00006517          	auipc	a0,0x6
ffffffffc0200a7e:	26e50513          	addi	a0,a0,622 # ffffffffc0206ce8 <commands+0x698>
ffffffffc0200a82:	b7f5                	j	ffffffffc0200a6e <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200a84:	00006517          	auipc	a0,0x6
ffffffffc0200a88:	28450513          	addi	a0,a0,644 # ffffffffc0206d08 <commands+0x6b8>
ffffffffc0200a8c:	b7cd                	j	ffffffffc0200a6e <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200a8e:	00006517          	auipc	a0,0x6
ffffffffc0200a92:	29250513          	addi	a0,a0,658 # ffffffffc0206d20 <commands+0x6d0>
ffffffffc0200a96:	eeaff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200a9a:	8522                	mv	a0,s0
ffffffffc0200a9c:	dd7ff0ef          	jal	ra,ffffffffc0200872 <pgfault_handler>
ffffffffc0200aa0:	84aa                	mv	s1,a0
ffffffffc0200aa2:	12051d63          	bnez	a0,ffffffffc0200bdc <exception_handler+0x1be>
}
ffffffffc0200aa6:	60e2                	ld	ra,24(sp)
ffffffffc0200aa8:	6442                	ld	s0,16(sp)
ffffffffc0200aaa:	64a2                	ld	s1,8(sp)
ffffffffc0200aac:	6105                	addi	sp,sp,32
ffffffffc0200aae:	8082                	ret
            cprintf("Store/AMO page fault\n");
ffffffffc0200ab0:	00006517          	auipc	a0,0x6
ffffffffc0200ab4:	28850513          	addi	a0,a0,648 # ffffffffc0206d38 <commands+0x6e8>
ffffffffc0200ab8:	ec8ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200abc:	8522                	mv	a0,s0
ffffffffc0200abe:	db5ff0ef          	jal	ra,ffffffffc0200872 <pgfault_handler>
ffffffffc0200ac2:	84aa                	mv	s1,a0
ffffffffc0200ac4:	d16d                	beqz	a0,ffffffffc0200aa6 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200ac6:	8522                	mv	a0,s0
ffffffffc0200ac8:	d49ff0ef          	jal	ra,ffffffffc0200810 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200acc:	86a6                	mv	a3,s1
ffffffffc0200ace:	00006617          	auipc	a2,0x6
ffffffffc0200ad2:	18a60613          	addi	a2,a2,394 # ffffffffc0206c58 <commands+0x608>
ffffffffc0200ad6:	0f800593          	li	a1,248
ffffffffc0200ada:	00006517          	auipc	a0,0x6
ffffffffc0200ade:	fde50513          	addi	a0,a0,-34 # ffffffffc0206ab8 <commands+0x468>
ffffffffc0200ae2:	999ff0ef          	jal	ra,ffffffffc020047a <__panic>
            cprintf("Instruction address misaligned\n");
ffffffffc0200ae6:	00006517          	auipc	a0,0x6
ffffffffc0200aea:	0d250513          	addi	a0,a0,210 # ffffffffc0206bb8 <commands+0x568>
ffffffffc0200aee:	b741                	j	ffffffffc0200a6e <exception_handler+0x50>
            cprintf("Instruction access fault\n");
ffffffffc0200af0:	00006517          	auipc	a0,0x6
ffffffffc0200af4:	0e850513          	addi	a0,a0,232 # ffffffffc0206bd8 <commands+0x588>
ffffffffc0200af8:	bf9d                	j	ffffffffc0200a6e <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200afa:	00006517          	auipc	a0,0x6
ffffffffc0200afe:	0fe50513          	addi	a0,a0,254 # ffffffffc0206bf8 <commands+0x5a8>
ffffffffc0200b02:	b7b5                	j	ffffffffc0200a6e <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc0200b04:	00006517          	auipc	a0,0x6
ffffffffc0200b08:	10c50513          	addi	a0,a0,268 # ffffffffc0206c10 <commands+0x5c0>
ffffffffc0200b0c:	e74ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            if(tf->gpr.a7 == 10){
ffffffffc0200b10:	6458                	ld	a4,136(s0)
ffffffffc0200b12:	47a9                	li	a5,10
ffffffffc0200b14:	f8f719e3          	bne	a4,a5,ffffffffc0200aa6 <exception_handler+0x88>
                tf->epc += 4;
ffffffffc0200b18:	10843783          	ld	a5,264(s0)
ffffffffc0200b1c:	0791                	addi	a5,a5,4
ffffffffc0200b1e:	10f43423          	sd	a5,264(s0)
                syscall();
ffffffffc0200b22:	396050ef          	jal	ra,ffffffffc0205eb8 <syscall>
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b26:	000b2797          	auipc	a5,0xb2
ffffffffc0200b2a:	caa7b783          	ld	a5,-854(a5) # ffffffffc02b27d0 <current>
ffffffffc0200b2e:	6b9c                	ld	a5,16(a5)
ffffffffc0200b30:	8522                	mv	a0,s0
}
ffffffffc0200b32:	6442                	ld	s0,16(sp)
ffffffffc0200b34:	60e2                	ld	ra,24(sp)
ffffffffc0200b36:	64a2                	ld	s1,8(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b38:	6589                	lui	a1,0x2
ffffffffc0200b3a:	95be                	add	a1,a1,a5
}
ffffffffc0200b3c:	6105                	addi	sp,sp,32
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b3e:	ac21                	j	ffffffffc0200d56 <kernel_execve_ret>
            cprintf("Load address misaligned\n");
ffffffffc0200b40:	00006517          	auipc	a0,0x6
ffffffffc0200b44:	0e050513          	addi	a0,a0,224 # ffffffffc0206c20 <commands+0x5d0>
ffffffffc0200b48:	b71d                	j	ffffffffc0200a6e <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200b4a:	00006517          	auipc	a0,0x6
ffffffffc0200b4e:	0f650513          	addi	a0,a0,246 # ffffffffc0206c40 <commands+0x5f0>
ffffffffc0200b52:	e2eff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200b56:	8522                	mv	a0,s0
ffffffffc0200b58:	d1bff0ef          	jal	ra,ffffffffc0200872 <pgfault_handler>
ffffffffc0200b5c:	84aa                	mv	s1,a0
ffffffffc0200b5e:	d521                	beqz	a0,ffffffffc0200aa6 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200b60:	8522                	mv	a0,s0
ffffffffc0200b62:	cafff0ef          	jal	ra,ffffffffc0200810 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200b66:	86a6                	mv	a3,s1
ffffffffc0200b68:	00006617          	auipc	a2,0x6
ffffffffc0200b6c:	0f060613          	addi	a2,a2,240 # ffffffffc0206c58 <commands+0x608>
ffffffffc0200b70:	0cd00593          	li	a1,205
ffffffffc0200b74:	00006517          	auipc	a0,0x6
ffffffffc0200b78:	f4450513          	addi	a0,a0,-188 # ffffffffc0206ab8 <commands+0x468>
ffffffffc0200b7c:	8ffff0ef          	jal	ra,ffffffffc020047a <__panic>
            cprintf("Store/AMO access fault\n");
ffffffffc0200b80:	00006517          	auipc	a0,0x6
ffffffffc0200b84:	11050513          	addi	a0,a0,272 # ffffffffc0206c90 <commands+0x640>
ffffffffc0200b88:	df8ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200b8c:	8522                	mv	a0,s0
ffffffffc0200b8e:	ce5ff0ef          	jal	ra,ffffffffc0200872 <pgfault_handler>
ffffffffc0200b92:	84aa                	mv	s1,a0
ffffffffc0200b94:	f00509e3          	beqz	a0,ffffffffc0200aa6 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200b98:	8522                	mv	a0,s0
ffffffffc0200b9a:	c77ff0ef          	jal	ra,ffffffffc0200810 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200b9e:	86a6                	mv	a3,s1
ffffffffc0200ba0:	00006617          	auipc	a2,0x6
ffffffffc0200ba4:	0b860613          	addi	a2,a2,184 # ffffffffc0206c58 <commands+0x608>
ffffffffc0200ba8:	0d700593          	li	a1,215
ffffffffc0200bac:	00006517          	auipc	a0,0x6
ffffffffc0200bb0:	f0c50513          	addi	a0,a0,-244 # ffffffffc0206ab8 <commands+0x468>
ffffffffc0200bb4:	8c7ff0ef          	jal	ra,ffffffffc020047a <__panic>
            print_trapframe(tf);
ffffffffc0200bb8:	8522                	mv	a0,s0
}
ffffffffc0200bba:	6442                	ld	s0,16(sp)
ffffffffc0200bbc:	60e2                	ld	ra,24(sp)
ffffffffc0200bbe:	64a2                	ld	s1,8(sp)
ffffffffc0200bc0:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200bc2:	b1b9                	j	ffffffffc0200810 <print_trapframe>
            panic("AMO address misaligned\n");
ffffffffc0200bc4:	00006617          	auipc	a2,0x6
ffffffffc0200bc8:	0b460613          	addi	a2,a2,180 # ffffffffc0206c78 <commands+0x628>
ffffffffc0200bcc:	0d100593          	li	a1,209
ffffffffc0200bd0:	00006517          	auipc	a0,0x6
ffffffffc0200bd4:	ee850513          	addi	a0,a0,-280 # ffffffffc0206ab8 <commands+0x468>
ffffffffc0200bd8:	8a3ff0ef          	jal	ra,ffffffffc020047a <__panic>
                print_trapframe(tf);
ffffffffc0200bdc:	8522                	mv	a0,s0
ffffffffc0200bde:	c33ff0ef          	jal	ra,ffffffffc0200810 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200be2:	86a6                	mv	a3,s1
ffffffffc0200be4:	00006617          	auipc	a2,0x6
ffffffffc0200be8:	07460613          	addi	a2,a2,116 # ffffffffc0206c58 <commands+0x608>
ffffffffc0200bec:	0f100593          	li	a1,241
ffffffffc0200bf0:	00006517          	auipc	a0,0x6
ffffffffc0200bf4:	ec850513          	addi	a0,a0,-312 # ffffffffc0206ab8 <commands+0x468>
ffffffffc0200bf8:	883ff0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0200bfc <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
ffffffffc0200bfc:	1101                	addi	sp,sp,-32
ffffffffc0200bfe:	e822                	sd	s0,16(sp)
    // dispatch based on what type of trap occurred
//    cputs("some trap");
    if (current == NULL) {
ffffffffc0200c00:	000b2417          	auipc	s0,0xb2
ffffffffc0200c04:	bd040413          	addi	s0,s0,-1072 # ffffffffc02b27d0 <current>
ffffffffc0200c08:	6018                	ld	a4,0(s0)
trap(struct trapframe *tf) {
ffffffffc0200c0a:	ec06                	sd	ra,24(sp)
ffffffffc0200c0c:	e426                	sd	s1,8(sp)
ffffffffc0200c0e:	e04a                	sd	s2,0(sp)
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c10:	11853683          	ld	a3,280(a0)
    if (current == NULL) {
ffffffffc0200c14:	cf1d                	beqz	a4,ffffffffc0200c52 <trap+0x56>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c16:	10053483          	ld	s1,256(a0)
        trap_dispatch(tf);
    } else {
        struct trapframe *otf = current->tf;
ffffffffc0200c1a:	0a073903          	ld	s2,160(a4)
        current->tf = tf;
ffffffffc0200c1e:	f348                	sd	a0,160(a4)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c20:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c24:	0206c463          	bltz	a3,ffffffffc0200c4c <trap+0x50>
        exception_handler(tf);
ffffffffc0200c28:	df7ff0ef          	jal	ra,ffffffffc0200a1e <exception_handler>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200c2c:	601c                	ld	a5,0(s0)
ffffffffc0200c2e:	0b27b023          	sd	s2,160(a5)
        if (!in_kernel) {
ffffffffc0200c32:	e499                	bnez	s1,ffffffffc0200c40 <trap+0x44>
            if (current->flags & PF_EXITING) {
ffffffffc0200c34:	0b07a703          	lw	a4,176(a5)
ffffffffc0200c38:	8b05                	andi	a4,a4,1
ffffffffc0200c3a:	e329                	bnez	a4,ffffffffc0200c7c <trap+0x80>
                do_exit(-E_KILLED);
            }
            if (current->need_resched) {
ffffffffc0200c3c:	6f9c                	ld	a5,24(a5)
ffffffffc0200c3e:	eb85                	bnez	a5,ffffffffc0200c6e <trap+0x72>
                schedule();
            }
        }
    }
}
ffffffffc0200c40:	60e2                	ld	ra,24(sp)
ffffffffc0200c42:	6442                	ld	s0,16(sp)
ffffffffc0200c44:	64a2                	ld	s1,8(sp)
ffffffffc0200c46:	6902                	ld	s2,0(sp)
ffffffffc0200c48:	6105                	addi	sp,sp,32
ffffffffc0200c4a:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200c4c:	d41ff0ef          	jal	ra,ffffffffc020098c <interrupt_handler>
ffffffffc0200c50:	bff1                	j	ffffffffc0200c2c <trap+0x30>
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c52:	0006c863          	bltz	a3,ffffffffc0200c62 <trap+0x66>
}
ffffffffc0200c56:	6442                	ld	s0,16(sp)
ffffffffc0200c58:	60e2                	ld	ra,24(sp)
ffffffffc0200c5a:	64a2                	ld	s1,8(sp)
ffffffffc0200c5c:	6902                	ld	s2,0(sp)
ffffffffc0200c5e:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc0200c60:	bb7d                	j	ffffffffc0200a1e <exception_handler>
}
ffffffffc0200c62:	6442                	ld	s0,16(sp)
ffffffffc0200c64:	60e2                	ld	ra,24(sp)
ffffffffc0200c66:	64a2                	ld	s1,8(sp)
ffffffffc0200c68:	6902                	ld	s2,0(sp)
ffffffffc0200c6a:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0200c6c:	b305                	j	ffffffffc020098c <interrupt_handler>
}
ffffffffc0200c6e:	6442                	ld	s0,16(sp)
ffffffffc0200c70:	60e2                	ld	ra,24(sp)
ffffffffc0200c72:	64a2                	ld	s1,8(sp)
ffffffffc0200c74:	6902                	ld	s2,0(sp)
ffffffffc0200c76:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200c78:	1540506f          	j	ffffffffc0205dcc <schedule>
                do_exit(-E_KILLED);
ffffffffc0200c7c:	555d                	li	a0,-9
ffffffffc0200c7e:	494040ef          	jal	ra,ffffffffc0205112 <do_exit>
            if (current->need_resched) {
ffffffffc0200c82:	601c                	ld	a5,0(s0)
ffffffffc0200c84:	bf65                	j	ffffffffc0200c3c <trap+0x40>
	...

ffffffffc0200c88 <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200c88:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200c8c:	00011463          	bnez	sp,ffffffffc0200c94 <__alltraps+0xc>
ffffffffc0200c90:	14002173          	csrr	sp,sscratch
ffffffffc0200c94:	712d                	addi	sp,sp,-288
ffffffffc0200c96:	e002                	sd	zero,0(sp)
ffffffffc0200c98:	e406                	sd	ra,8(sp)
ffffffffc0200c9a:	ec0e                	sd	gp,24(sp)
ffffffffc0200c9c:	f012                	sd	tp,32(sp)
ffffffffc0200c9e:	f416                	sd	t0,40(sp)
ffffffffc0200ca0:	f81a                	sd	t1,48(sp)
ffffffffc0200ca2:	fc1e                	sd	t2,56(sp)
ffffffffc0200ca4:	e0a2                	sd	s0,64(sp)
ffffffffc0200ca6:	e4a6                	sd	s1,72(sp)
ffffffffc0200ca8:	e8aa                	sd	a0,80(sp)
ffffffffc0200caa:	ecae                	sd	a1,88(sp)
ffffffffc0200cac:	f0b2                	sd	a2,96(sp)
ffffffffc0200cae:	f4b6                	sd	a3,104(sp)
ffffffffc0200cb0:	f8ba                	sd	a4,112(sp)
ffffffffc0200cb2:	fcbe                	sd	a5,120(sp)
ffffffffc0200cb4:	e142                	sd	a6,128(sp)
ffffffffc0200cb6:	e546                	sd	a7,136(sp)
ffffffffc0200cb8:	e94a                	sd	s2,144(sp)
ffffffffc0200cba:	ed4e                	sd	s3,152(sp)
ffffffffc0200cbc:	f152                	sd	s4,160(sp)
ffffffffc0200cbe:	f556                	sd	s5,168(sp)
ffffffffc0200cc0:	f95a                	sd	s6,176(sp)
ffffffffc0200cc2:	fd5e                	sd	s7,184(sp)
ffffffffc0200cc4:	e1e2                	sd	s8,192(sp)
ffffffffc0200cc6:	e5e6                	sd	s9,200(sp)
ffffffffc0200cc8:	e9ea                	sd	s10,208(sp)
ffffffffc0200cca:	edee                	sd	s11,216(sp)
ffffffffc0200ccc:	f1f2                	sd	t3,224(sp)
ffffffffc0200cce:	f5f6                	sd	t4,232(sp)
ffffffffc0200cd0:	f9fa                	sd	t5,240(sp)
ffffffffc0200cd2:	fdfe                	sd	t6,248(sp)
ffffffffc0200cd4:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200cd8:	100024f3          	csrr	s1,sstatus
ffffffffc0200cdc:	14102973          	csrr	s2,sepc
ffffffffc0200ce0:	143029f3          	csrr	s3,stval
ffffffffc0200ce4:	14202a73          	csrr	s4,scause
ffffffffc0200ce8:	e822                	sd	s0,16(sp)
ffffffffc0200cea:	e226                	sd	s1,256(sp)
ffffffffc0200cec:	e64a                	sd	s2,264(sp)
ffffffffc0200cee:	ea4e                	sd	s3,272(sp)
ffffffffc0200cf0:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200cf2:	850a                	mv	a0,sp
    jal trap
ffffffffc0200cf4:	f09ff0ef          	jal	ra,ffffffffc0200bfc <trap>

ffffffffc0200cf8 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200cf8:	6492                	ld	s1,256(sp)
ffffffffc0200cfa:	6932                	ld	s2,264(sp)
ffffffffc0200cfc:	1004f413          	andi	s0,s1,256
ffffffffc0200d00:	e401                	bnez	s0,ffffffffc0200d08 <__trapret+0x10>
ffffffffc0200d02:	1200                	addi	s0,sp,288
ffffffffc0200d04:	14041073          	csrw	sscratch,s0
ffffffffc0200d08:	10049073          	csrw	sstatus,s1
ffffffffc0200d0c:	14191073          	csrw	sepc,s2
ffffffffc0200d10:	60a2                	ld	ra,8(sp)
ffffffffc0200d12:	61e2                	ld	gp,24(sp)
ffffffffc0200d14:	7202                	ld	tp,32(sp)
ffffffffc0200d16:	72a2                	ld	t0,40(sp)
ffffffffc0200d18:	7342                	ld	t1,48(sp)
ffffffffc0200d1a:	73e2                	ld	t2,56(sp)
ffffffffc0200d1c:	6406                	ld	s0,64(sp)
ffffffffc0200d1e:	64a6                	ld	s1,72(sp)
ffffffffc0200d20:	6546                	ld	a0,80(sp)
ffffffffc0200d22:	65e6                	ld	a1,88(sp)
ffffffffc0200d24:	7606                	ld	a2,96(sp)
ffffffffc0200d26:	76a6                	ld	a3,104(sp)
ffffffffc0200d28:	7746                	ld	a4,112(sp)
ffffffffc0200d2a:	77e6                	ld	a5,120(sp)
ffffffffc0200d2c:	680a                	ld	a6,128(sp)
ffffffffc0200d2e:	68aa                	ld	a7,136(sp)
ffffffffc0200d30:	694a                	ld	s2,144(sp)
ffffffffc0200d32:	69ea                	ld	s3,152(sp)
ffffffffc0200d34:	7a0a                	ld	s4,160(sp)
ffffffffc0200d36:	7aaa                	ld	s5,168(sp)
ffffffffc0200d38:	7b4a                	ld	s6,176(sp)
ffffffffc0200d3a:	7bea                	ld	s7,184(sp)
ffffffffc0200d3c:	6c0e                	ld	s8,192(sp)
ffffffffc0200d3e:	6cae                	ld	s9,200(sp)
ffffffffc0200d40:	6d4e                	ld	s10,208(sp)
ffffffffc0200d42:	6dee                	ld	s11,216(sp)
ffffffffc0200d44:	7e0e                	ld	t3,224(sp)
ffffffffc0200d46:	7eae                	ld	t4,232(sp)
ffffffffc0200d48:	7f4e                	ld	t5,240(sp)
ffffffffc0200d4a:	7fee                	ld	t6,248(sp)
ffffffffc0200d4c:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200d4e:	10200073          	sret

ffffffffc0200d52 <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200d52:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200d54:	b755                	j	ffffffffc0200cf8 <__trapret>

ffffffffc0200d56 <kernel_execve_ret>:

    .global kernel_execve_ret
kernel_execve_ret:
    // adjust sp to beneath kstacktop of current process
    addi a1, a1, -36*REGBYTES
ffffffffc0200d56:	ee058593          	addi	a1,a1,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7cc8>

    // copy from previous trapframe to new trapframe
    LOAD s1, 35*REGBYTES(a0)
ffffffffc0200d5a:	11853483          	ld	s1,280(a0)
    STORE s1, 35*REGBYTES(a1)
ffffffffc0200d5e:	1095bc23          	sd	s1,280(a1)
    LOAD s1, 34*REGBYTES(a0)
ffffffffc0200d62:	11053483          	ld	s1,272(a0)
    STORE s1, 34*REGBYTES(a1)
ffffffffc0200d66:	1095b823          	sd	s1,272(a1)
    LOAD s1, 33*REGBYTES(a0)
ffffffffc0200d6a:	10853483          	ld	s1,264(a0)
    STORE s1, 33*REGBYTES(a1)
ffffffffc0200d6e:	1095b423          	sd	s1,264(a1)
    LOAD s1, 32*REGBYTES(a0)
ffffffffc0200d72:	10053483          	ld	s1,256(a0)
    STORE s1, 32*REGBYTES(a1)
ffffffffc0200d76:	1095b023          	sd	s1,256(a1)
    LOAD s1, 31*REGBYTES(a0)
ffffffffc0200d7a:	7d64                	ld	s1,248(a0)
    STORE s1, 31*REGBYTES(a1)
ffffffffc0200d7c:	fde4                	sd	s1,248(a1)
    LOAD s1, 30*REGBYTES(a0)
ffffffffc0200d7e:	7964                	ld	s1,240(a0)
    STORE s1, 30*REGBYTES(a1)
ffffffffc0200d80:	f9e4                	sd	s1,240(a1)
    LOAD s1, 29*REGBYTES(a0)
ffffffffc0200d82:	7564                	ld	s1,232(a0)
    STORE s1, 29*REGBYTES(a1)
ffffffffc0200d84:	f5e4                	sd	s1,232(a1)
    LOAD s1, 28*REGBYTES(a0)
ffffffffc0200d86:	7164                	ld	s1,224(a0)
    STORE s1, 28*REGBYTES(a1)
ffffffffc0200d88:	f1e4                	sd	s1,224(a1)
    LOAD s1, 27*REGBYTES(a0)
ffffffffc0200d8a:	6d64                	ld	s1,216(a0)
    STORE s1, 27*REGBYTES(a1)
ffffffffc0200d8c:	ede4                	sd	s1,216(a1)
    LOAD s1, 26*REGBYTES(a0)
ffffffffc0200d8e:	6964                	ld	s1,208(a0)
    STORE s1, 26*REGBYTES(a1)
ffffffffc0200d90:	e9e4                	sd	s1,208(a1)
    LOAD s1, 25*REGBYTES(a0)
ffffffffc0200d92:	6564                	ld	s1,200(a0)
    STORE s1, 25*REGBYTES(a1)
ffffffffc0200d94:	e5e4                	sd	s1,200(a1)
    LOAD s1, 24*REGBYTES(a0)
ffffffffc0200d96:	6164                	ld	s1,192(a0)
    STORE s1, 24*REGBYTES(a1)
ffffffffc0200d98:	e1e4                	sd	s1,192(a1)
    LOAD s1, 23*REGBYTES(a0)
ffffffffc0200d9a:	7d44                	ld	s1,184(a0)
    STORE s1, 23*REGBYTES(a1)
ffffffffc0200d9c:	fdc4                	sd	s1,184(a1)
    LOAD s1, 22*REGBYTES(a0)
ffffffffc0200d9e:	7944                	ld	s1,176(a0)
    STORE s1, 22*REGBYTES(a1)
ffffffffc0200da0:	f9c4                	sd	s1,176(a1)
    LOAD s1, 21*REGBYTES(a0)
ffffffffc0200da2:	7544                	ld	s1,168(a0)
    STORE s1, 21*REGBYTES(a1)
ffffffffc0200da4:	f5c4                	sd	s1,168(a1)
    LOAD s1, 20*REGBYTES(a0)
ffffffffc0200da6:	7144                	ld	s1,160(a0)
    STORE s1, 20*REGBYTES(a1)
ffffffffc0200da8:	f1c4                	sd	s1,160(a1)
    LOAD s1, 19*REGBYTES(a0)
ffffffffc0200daa:	6d44                	ld	s1,152(a0)
    STORE s1, 19*REGBYTES(a1)
ffffffffc0200dac:	edc4                	sd	s1,152(a1)
    LOAD s1, 18*REGBYTES(a0)
ffffffffc0200dae:	6944                	ld	s1,144(a0)
    STORE s1, 18*REGBYTES(a1)
ffffffffc0200db0:	e9c4                	sd	s1,144(a1)
    LOAD s1, 17*REGBYTES(a0)
ffffffffc0200db2:	6544                	ld	s1,136(a0)
    STORE s1, 17*REGBYTES(a1)
ffffffffc0200db4:	e5c4                	sd	s1,136(a1)
    LOAD s1, 16*REGBYTES(a0)
ffffffffc0200db6:	6144                	ld	s1,128(a0)
    STORE s1, 16*REGBYTES(a1)
ffffffffc0200db8:	e1c4                	sd	s1,128(a1)
    LOAD s1, 15*REGBYTES(a0)
ffffffffc0200dba:	7d24                	ld	s1,120(a0)
    STORE s1, 15*REGBYTES(a1)
ffffffffc0200dbc:	fda4                	sd	s1,120(a1)
    LOAD s1, 14*REGBYTES(a0)
ffffffffc0200dbe:	7924                	ld	s1,112(a0)
    STORE s1, 14*REGBYTES(a1)
ffffffffc0200dc0:	f9a4                	sd	s1,112(a1)
    LOAD s1, 13*REGBYTES(a0)
ffffffffc0200dc2:	7524                	ld	s1,104(a0)
    STORE s1, 13*REGBYTES(a1)
ffffffffc0200dc4:	f5a4                	sd	s1,104(a1)
    LOAD s1, 12*REGBYTES(a0)
ffffffffc0200dc6:	7124                	ld	s1,96(a0)
    STORE s1, 12*REGBYTES(a1)
ffffffffc0200dc8:	f1a4                	sd	s1,96(a1)
    LOAD s1, 11*REGBYTES(a0)
ffffffffc0200dca:	6d24                	ld	s1,88(a0)
    STORE s1, 11*REGBYTES(a1)
ffffffffc0200dcc:	eda4                	sd	s1,88(a1)
    LOAD s1, 10*REGBYTES(a0)
ffffffffc0200dce:	6924                	ld	s1,80(a0)
    STORE s1, 10*REGBYTES(a1)
ffffffffc0200dd0:	e9a4                	sd	s1,80(a1)
    LOAD s1, 9*REGBYTES(a0)
ffffffffc0200dd2:	6524                	ld	s1,72(a0)
    STORE s1, 9*REGBYTES(a1)
ffffffffc0200dd4:	e5a4                	sd	s1,72(a1)
    LOAD s1, 8*REGBYTES(a0)
ffffffffc0200dd6:	6124                	ld	s1,64(a0)
    STORE s1, 8*REGBYTES(a1)
ffffffffc0200dd8:	e1a4                	sd	s1,64(a1)
    LOAD s1, 7*REGBYTES(a0)
ffffffffc0200dda:	7d04                	ld	s1,56(a0)
    STORE s1, 7*REGBYTES(a1)
ffffffffc0200ddc:	fd84                	sd	s1,56(a1)
    LOAD s1, 6*REGBYTES(a0)
ffffffffc0200dde:	7904                	ld	s1,48(a0)
    STORE s1, 6*REGBYTES(a1)
ffffffffc0200de0:	f984                	sd	s1,48(a1)
    LOAD s1, 5*REGBYTES(a0)
ffffffffc0200de2:	7504                	ld	s1,40(a0)
    STORE s1, 5*REGBYTES(a1)
ffffffffc0200de4:	f584                	sd	s1,40(a1)
    LOAD s1, 4*REGBYTES(a0)
ffffffffc0200de6:	7104                	ld	s1,32(a0)
    STORE s1, 4*REGBYTES(a1)
ffffffffc0200de8:	f184                	sd	s1,32(a1)
    LOAD s1, 3*REGBYTES(a0)
ffffffffc0200dea:	6d04                	ld	s1,24(a0)
    STORE s1, 3*REGBYTES(a1)
ffffffffc0200dec:	ed84                	sd	s1,24(a1)
    LOAD s1, 2*REGBYTES(a0)
ffffffffc0200dee:	6904                	ld	s1,16(a0)
    STORE s1, 2*REGBYTES(a1)
ffffffffc0200df0:	e984                	sd	s1,16(a1)
    LOAD s1, 1*REGBYTES(a0)
ffffffffc0200df2:	6504                	ld	s1,8(a0)
    STORE s1, 1*REGBYTES(a1)
ffffffffc0200df4:	e584                	sd	s1,8(a1)
    LOAD s1, 0*REGBYTES(a0)
ffffffffc0200df6:	6104                	ld	s1,0(a0)
    STORE s1, 0*REGBYTES(a1)
ffffffffc0200df8:	e184                	sd	s1,0(a1)

    // acutually adjust sp
    move sp, a1
ffffffffc0200dfa:	812e                	mv	sp,a1
ffffffffc0200dfc:	bdf5                	j	ffffffffc0200cf8 <__trapret>

ffffffffc0200dfe <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200dfe:	000ae797          	auipc	a5,0xae
ffffffffc0200e02:	89278793          	addi	a5,a5,-1902 # ffffffffc02ae690 <free_area>
ffffffffc0200e06:	e79c                	sd	a5,8(a5)
ffffffffc0200e08:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200e0a:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200e0e:	8082                	ret

ffffffffc0200e10 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200e10:	000ae517          	auipc	a0,0xae
ffffffffc0200e14:	89056503          	lwu	a0,-1904(a0) # ffffffffc02ae6a0 <free_area+0x10>
ffffffffc0200e18:	8082                	ret

ffffffffc0200e1a <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200e1a:	715d                	addi	sp,sp,-80
ffffffffc0200e1c:	e0a2                	sd	s0,64(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200e1e:	000ae417          	auipc	s0,0xae
ffffffffc0200e22:	87240413          	addi	s0,s0,-1934 # ffffffffc02ae690 <free_area>
ffffffffc0200e26:	641c                	ld	a5,8(s0)
ffffffffc0200e28:	e486                	sd	ra,72(sp)
ffffffffc0200e2a:	fc26                	sd	s1,56(sp)
ffffffffc0200e2c:	f84a                	sd	s2,48(sp)
ffffffffc0200e2e:	f44e                	sd	s3,40(sp)
ffffffffc0200e30:	f052                	sd	s4,32(sp)
ffffffffc0200e32:	ec56                	sd	s5,24(sp)
ffffffffc0200e34:	e85a                	sd	s6,16(sp)
ffffffffc0200e36:	e45e                	sd	s7,8(sp)
ffffffffc0200e38:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e3a:	2a878d63          	beq	a5,s0,ffffffffc02010f4 <default_check+0x2da>
    int count = 0, total = 0;
ffffffffc0200e3e:	4481                	li	s1,0
ffffffffc0200e40:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200e42:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200e46:	8b09                	andi	a4,a4,2
ffffffffc0200e48:	2a070a63          	beqz	a4,ffffffffc02010fc <default_check+0x2e2>
        count ++, total += p->property;
ffffffffc0200e4c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200e50:	679c                	ld	a5,8(a5)
ffffffffc0200e52:	2905                	addiw	s2,s2,1
ffffffffc0200e54:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e56:	fe8796e3          	bne	a5,s0,ffffffffc0200e42 <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0200e5a:	89a6                	mv	s3,s1
ffffffffc0200e5c:	733000ef          	jal	ra,ffffffffc0201d8e <nr_free_pages>
ffffffffc0200e60:	6f351e63          	bne	a0,s3,ffffffffc020155c <default_check+0x742>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200e64:	4505                	li	a0,1
ffffffffc0200e66:	657000ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
ffffffffc0200e6a:	8aaa                	mv	s5,a0
ffffffffc0200e6c:	42050863          	beqz	a0,ffffffffc020129c <default_check+0x482>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200e70:	4505                	li	a0,1
ffffffffc0200e72:	64b000ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
ffffffffc0200e76:	89aa                	mv	s3,a0
ffffffffc0200e78:	70050263          	beqz	a0,ffffffffc020157c <default_check+0x762>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200e7c:	4505                	li	a0,1
ffffffffc0200e7e:	63f000ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
ffffffffc0200e82:	8a2a                	mv	s4,a0
ffffffffc0200e84:	48050c63          	beqz	a0,ffffffffc020131c <default_check+0x502>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200e88:	293a8a63          	beq	s5,s3,ffffffffc020111c <default_check+0x302>
ffffffffc0200e8c:	28aa8863          	beq	s5,a0,ffffffffc020111c <default_check+0x302>
ffffffffc0200e90:	28a98663          	beq	s3,a0,ffffffffc020111c <default_check+0x302>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200e94:	000aa783          	lw	a5,0(s5)
ffffffffc0200e98:	2a079263          	bnez	a5,ffffffffc020113c <default_check+0x322>
ffffffffc0200e9c:	0009a783          	lw	a5,0(s3)
ffffffffc0200ea0:	28079e63          	bnez	a5,ffffffffc020113c <default_check+0x322>
ffffffffc0200ea4:	411c                	lw	a5,0(a0)
ffffffffc0200ea6:	28079b63          	bnez	a5,ffffffffc020113c <default_check+0x322>
extern size_t npage;
extern uint_t va_pa_offset;

static inline ppn_t
page2ppn(struct Page *page) {
    return page - pages + nbase;
ffffffffc0200eaa:	000b2797          	auipc	a5,0xb2
ffffffffc0200eae:	8e67b783          	ld	a5,-1818(a5) # ffffffffc02b2790 <pages>
ffffffffc0200eb2:	40fa8733          	sub	a4,s5,a5
ffffffffc0200eb6:	00008617          	auipc	a2,0x8
ffffffffc0200eba:	ba263603          	ld	a2,-1118(a2) # ffffffffc0208a58 <nbase>
ffffffffc0200ebe:	8719                	srai	a4,a4,0x6
ffffffffc0200ec0:	9732                	add	a4,a4,a2
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200ec2:	000b2697          	auipc	a3,0xb2
ffffffffc0200ec6:	8c66b683          	ld	a3,-1850(a3) # ffffffffc02b2788 <npage>
ffffffffc0200eca:	06b2                	slli	a3,a3,0xc
}

static inline uintptr_t
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200ecc:	0732                	slli	a4,a4,0xc
ffffffffc0200ece:	28d77763          	bgeu	a4,a3,ffffffffc020115c <default_check+0x342>
    return page - pages + nbase;
ffffffffc0200ed2:	40f98733          	sub	a4,s3,a5
ffffffffc0200ed6:	8719                	srai	a4,a4,0x6
ffffffffc0200ed8:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200eda:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200edc:	4cd77063          	bgeu	a4,a3,ffffffffc020139c <default_check+0x582>
    return page - pages + nbase;
ffffffffc0200ee0:	40f507b3          	sub	a5,a0,a5
ffffffffc0200ee4:	8799                	srai	a5,a5,0x6
ffffffffc0200ee6:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200ee8:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200eea:	30d7f963          	bgeu	a5,a3,ffffffffc02011fc <default_check+0x3e2>
    assert(alloc_page() == NULL);
ffffffffc0200eee:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200ef0:	00043c03          	ld	s8,0(s0)
ffffffffc0200ef4:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0200ef8:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0200efc:	e400                	sd	s0,8(s0)
ffffffffc0200efe:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0200f00:	000ad797          	auipc	a5,0xad
ffffffffc0200f04:	7a07a023          	sw	zero,1952(a5) # ffffffffc02ae6a0 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200f08:	5b5000ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
ffffffffc0200f0c:	2c051863          	bnez	a0,ffffffffc02011dc <default_check+0x3c2>
    free_page(p0);
ffffffffc0200f10:	4585                	li	a1,1
ffffffffc0200f12:	8556                	mv	a0,s5
ffffffffc0200f14:	63b000ef          	jal	ra,ffffffffc0201d4e <free_pages>
    free_page(p1);
ffffffffc0200f18:	4585                	li	a1,1
ffffffffc0200f1a:	854e                	mv	a0,s3
ffffffffc0200f1c:	633000ef          	jal	ra,ffffffffc0201d4e <free_pages>
    free_page(p2);
ffffffffc0200f20:	4585                	li	a1,1
ffffffffc0200f22:	8552                	mv	a0,s4
ffffffffc0200f24:	62b000ef          	jal	ra,ffffffffc0201d4e <free_pages>
    assert(nr_free == 3);
ffffffffc0200f28:	4818                	lw	a4,16(s0)
ffffffffc0200f2a:	478d                	li	a5,3
ffffffffc0200f2c:	28f71863          	bne	a4,a5,ffffffffc02011bc <default_check+0x3a2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f30:	4505                	li	a0,1
ffffffffc0200f32:	58b000ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
ffffffffc0200f36:	89aa                	mv	s3,a0
ffffffffc0200f38:	26050263          	beqz	a0,ffffffffc020119c <default_check+0x382>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200f3c:	4505                	li	a0,1
ffffffffc0200f3e:	57f000ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
ffffffffc0200f42:	8aaa                	mv	s5,a0
ffffffffc0200f44:	3a050c63          	beqz	a0,ffffffffc02012fc <default_check+0x4e2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200f48:	4505                	li	a0,1
ffffffffc0200f4a:	573000ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
ffffffffc0200f4e:	8a2a                	mv	s4,a0
ffffffffc0200f50:	38050663          	beqz	a0,ffffffffc02012dc <default_check+0x4c2>
    assert(alloc_page() == NULL);
ffffffffc0200f54:	4505                	li	a0,1
ffffffffc0200f56:	567000ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
ffffffffc0200f5a:	36051163          	bnez	a0,ffffffffc02012bc <default_check+0x4a2>
    free_page(p0);
ffffffffc0200f5e:	4585                	li	a1,1
ffffffffc0200f60:	854e                	mv	a0,s3
ffffffffc0200f62:	5ed000ef          	jal	ra,ffffffffc0201d4e <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200f66:	641c                	ld	a5,8(s0)
ffffffffc0200f68:	20878a63          	beq	a5,s0,ffffffffc020117c <default_check+0x362>
    assert((p = alloc_page()) == p0);
ffffffffc0200f6c:	4505                	li	a0,1
ffffffffc0200f6e:	54f000ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
ffffffffc0200f72:	30a99563          	bne	s3,a0,ffffffffc020127c <default_check+0x462>
    assert(alloc_page() == NULL);
ffffffffc0200f76:	4505                	li	a0,1
ffffffffc0200f78:	545000ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
ffffffffc0200f7c:	2e051063          	bnez	a0,ffffffffc020125c <default_check+0x442>
    assert(nr_free == 0);
ffffffffc0200f80:	481c                	lw	a5,16(s0)
ffffffffc0200f82:	2a079d63          	bnez	a5,ffffffffc020123c <default_check+0x422>
    free_page(p);
ffffffffc0200f86:	854e                	mv	a0,s3
ffffffffc0200f88:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200f8a:	01843023          	sd	s8,0(s0)
ffffffffc0200f8e:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0200f92:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0200f96:	5b9000ef          	jal	ra,ffffffffc0201d4e <free_pages>
    free_page(p1);
ffffffffc0200f9a:	4585                	li	a1,1
ffffffffc0200f9c:	8556                	mv	a0,s5
ffffffffc0200f9e:	5b1000ef          	jal	ra,ffffffffc0201d4e <free_pages>
    free_page(p2);
ffffffffc0200fa2:	4585                	li	a1,1
ffffffffc0200fa4:	8552                	mv	a0,s4
ffffffffc0200fa6:	5a9000ef          	jal	ra,ffffffffc0201d4e <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200faa:	4515                	li	a0,5
ffffffffc0200fac:	511000ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
ffffffffc0200fb0:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200fb2:	26050563          	beqz	a0,ffffffffc020121c <default_check+0x402>
ffffffffc0200fb6:	651c                	ld	a5,8(a0)
ffffffffc0200fb8:	8385                	srli	a5,a5,0x1
ffffffffc0200fba:	8b85                	andi	a5,a5,1
    assert(!PageProperty(p0));
ffffffffc0200fbc:	54079063          	bnez	a5,ffffffffc02014fc <default_check+0x6e2>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200fc0:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200fc2:	00043b03          	ld	s6,0(s0)
ffffffffc0200fc6:	00843a83          	ld	s5,8(s0)
ffffffffc0200fca:	e000                	sd	s0,0(s0)
ffffffffc0200fcc:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0200fce:	4ef000ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
ffffffffc0200fd2:	50051563          	bnez	a0,ffffffffc02014dc <default_check+0x6c2>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0200fd6:	08098a13          	addi	s4,s3,128
ffffffffc0200fda:	8552                	mv	a0,s4
ffffffffc0200fdc:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0200fde:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc0200fe2:	000ad797          	auipc	a5,0xad
ffffffffc0200fe6:	6a07af23          	sw	zero,1726(a5) # ffffffffc02ae6a0 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0200fea:	565000ef          	jal	ra,ffffffffc0201d4e <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200fee:	4511                	li	a0,4
ffffffffc0200ff0:	4cd000ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
ffffffffc0200ff4:	4c051463          	bnez	a0,ffffffffc02014bc <default_check+0x6a2>
ffffffffc0200ff8:	0889b783          	ld	a5,136(s3)
ffffffffc0200ffc:	8385                	srli	a5,a5,0x1
ffffffffc0200ffe:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201000:	48078e63          	beqz	a5,ffffffffc020149c <default_check+0x682>
ffffffffc0201004:	0909a703          	lw	a4,144(s3)
ffffffffc0201008:	478d                	li	a5,3
ffffffffc020100a:	48f71963          	bne	a4,a5,ffffffffc020149c <default_check+0x682>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc020100e:	450d                	li	a0,3
ffffffffc0201010:	4ad000ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
ffffffffc0201014:	8c2a                	mv	s8,a0
ffffffffc0201016:	46050363          	beqz	a0,ffffffffc020147c <default_check+0x662>
    assert(alloc_page() == NULL);
ffffffffc020101a:	4505                	li	a0,1
ffffffffc020101c:	4a1000ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
ffffffffc0201020:	42051e63          	bnez	a0,ffffffffc020145c <default_check+0x642>
    assert(p0 + 2 == p1);
ffffffffc0201024:	418a1c63          	bne	s4,s8,ffffffffc020143c <default_check+0x622>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0201028:	4585                	li	a1,1
ffffffffc020102a:	854e                	mv	a0,s3
ffffffffc020102c:	523000ef          	jal	ra,ffffffffc0201d4e <free_pages>
    free_pages(p1, 3);
ffffffffc0201030:	458d                	li	a1,3
ffffffffc0201032:	8552                	mv	a0,s4
ffffffffc0201034:	51b000ef          	jal	ra,ffffffffc0201d4e <free_pages>
ffffffffc0201038:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc020103c:	04098c13          	addi	s8,s3,64
ffffffffc0201040:	8385                	srli	a5,a5,0x1
ffffffffc0201042:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201044:	3c078c63          	beqz	a5,ffffffffc020141c <default_check+0x602>
ffffffffc0201048:	0109a703          	lw	a4,16(s3)
ffffffffc020104c:	4785                	li	a5,1
ffffffffc020104e:	3cf71763          	bne	a4,a5,ffffffffc020141c <default_check+0x602>
ffffffffc0201052:	008a3783          	ld	a5,8(s4)
ffffffffc0201056:	8385                	srli	a5,a5,0x1
ffffffffc0201058:	8b85                	andi	a5,a5,1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc020105a:	3a078163          	beqz	a5,ffffffffc02013fc <default_check+0x5e2>
ffffffffc020105e:	010a2703          	lw	a4,16(s4)
ffffffffc0201062:	478d                	li	a5,3
ffffffffc0201064:	38f71c63          	bne	a4,a5,ffffffffc02013fc <default_check+0x5e2>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201068:	4505                	li	a0,1
ffffffffc020106a:	453000ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
ffffffffc020106e:	36a99763          	bne	s3,a0,ffffffffc02013dc <default_check+0x5c2>
    free_page(p0);
ffffffffc0201072:	4585                	li	a1,1
ffffffffc0201074:	4db000ef          	jal	ra,ffffffffc0201d4e <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201078:	4509                	li	a0,2
ffffffffc020107a:	443000ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
ffffffffc020107e:	32aa1f63          	bne	s4,a0,ffffffffc02013bc <default_check+0x5a2>

    free_pages(p0, 2);
ffffffffc0201082:	4589                	li	a1,2
ffffffffc0201084:	4cb000ef          	jal	ra,ffffffffc0201d4e <free_pages>
    free_page(p2);
ffffffffc0201088:	4585                	li	a1,1
ffffffffc020108a:	8562                	mv	a0,s8
ffffffffc020108c:	4c3000ef          	jal	ra,ffffffffc0201d4e <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201090:	4515                	li	a0,5
ffffffffc0201092:	42b000ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
ffffffffc0201096:	89aa                	mv	s3,a0
ffffffffc0201098:	48050263          	beqz	a0,ffffffffc020151c <default_check+0x702>
    assert(alloc_page() == NULL);
ffffffffc020109c:	4505                	li	a0,1
ffffffffc020109e:	41f000ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
ffffffffc02010a2:	2c051d63          	bnez	a0,ffffffffc020137c <default_check+0x562>

    assert(nr_free == 0);
ffffffffc02010a6:	481c                	lw	a5,16(s0)
ffffffffc02010a8:	2a079a63          	bnez	a5,ffffffffc020135c <default_check+0x542>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc02010ac:	4595                	li	a1,5
ffffffffc02010ae:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc02010b0:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc02010b4:	01643023          	sd	s6,0(s0)
ffffffffc02010b8:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc02010bc:	493000ef          	jal	ra,ffffffffc0201d4e <free_pages>
    return listelm->next;
ffffffffc02010c0:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc02010c2:	00878963          	beq	a5,s0,ffffffffc02010d4 <default_check+0x2ba>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc02010c6:	ff87a703          	lw	a4,-8(a5)
ffffffffc02010ca:	679c                	ld	a5,8(a5)
ffffffffc02010cc:	397d                	addiw	s2,s2,-1
ffffffffc02010ce:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc02010d0:	fe879be3          	bne	a5,s0,ffffffffc02010c6 <default_check+0x2ac>
    }
    assert(count == 0);
ffffffffc02010d4:	26091463          	bnez	s2,ffffffffc020133c <default_check+0x522>
    assert(total == 0);
ffffffffc02010d8:	46049263          	bnez	s1,ffffffffc020153c <default_check+0x722>
}
ffffffffc02010dc:	60a6                	ld	ra,72(sp)
ffffffffc02010de:	6406                	ld	s0,64(sp)
ffffffffc02010e0:	74e2                	ld	s1,56(sp)
ffffffffc02010e2:	7942                	ld	s2,48(sp)
ffffffffc02010e4:	79a2                	ld	s3,40(sp)
ffffffffc02010e6:	7a02                	ld	s4,32(sp)
ffffffffc02010e8:	6ae2                	ld	s5,24(sp)
ffffffffc02010ea:	6b42                	ld	s6,16(sp)
ffffffffc02010ec:	6ba2                	ld	s7,8(sp)
ffffffffc02010ee:	6c02                	ld	s8,0(sp)
ffffffffc02010f0:	6161                	addi	sp,sp,80
ffffffffc02010f2:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc02010f4:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc02010f6:	4481                	li	s1,0
ffffffffc02010f8:	4901                	li	s2,0
ffffffffc02010fa:	b38d                	j	ffffffffc0200e5c <default_check+0x42>
        assert(PageProperty(p));
ffffffffc02010fc:	00006697          	auipc	a3,0x6
ffffffffc0201100:	c9468693          	addi	a3,a3,-876 # ffffffffc0206d90 <commands+0x740>
ffffffffc0201104:	00006617          	auipc	a2,0x6
ffffffffc0201108:	99c60613          	addi	a2,a2,-1636 # ffffffffc0206aa0 <commands+0x450>
ffffffffc020110c:	0f000593          	li	a1,240
ffffffffc0201110:	00006517          	auipc	a0,0x6
ffffffffc0201114:	c9050513          	addi	a0,a0,-880 # ffffffffc0206da0 <commands+0x750>
ffffffffc0201118:	b62ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc020111c:	00006697          	auipc	a3,0x6
ffffffffc0201120:	d1c68693          	addi	a3,a3,-740 # ffffffffc0206e38 <commands+0x7e8>
ffffffffc0201124:	00006617          	auipc	a2,0x6
ffffffffc0201128:	97c60613          	addi	a2,a2,-1668 # ffffffffc0206aa0 <commands+0x450>
ffffffffc020112c:	0bd00593          	li	a1,189
ffffffffc0201130:	00006517          	auipc	a0,0x6
ffffffffc0201134:	c7050513          	addi	a0,a0,-912 # ffffffffc0206da0 <commands+0x750>
ffffffffc0201138:	b42ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc020113c:	00006697          	auipc	a3,0x6
ffffffffc0201140:	d2468693          	addi	a3,a3,-732 # ffffffffc0206e60 <commands+0x810>
ffffffffc0201144:	00006617          	auipc	a2,0x6
ffffffffc0201148:	95c60613          	addi	a2,a2,-1700 # ffffffffc0206aa0 <commands+0x450>
ffffffffc020114c:	0be00593          	li	a1,190
ffffffffc0201150:	00006517          	auipc	a0,0x6
ffffffffc0201154:	c5050513          	addi	a0,a0,-944 # ffffffffc0206da0 <commands+0x750>
ffffffffc0201158:	b22ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc020115c:	00006697          	auipc	a3,0x6
ffffffffc0201160:	d4468693          	addi	a3,a3,-700 # ffffffffc0206ea0 <commands+0x850>
ffffffffc0201164:	00006617          	auipc	a2,0x6
ffffffffc0201168:	93c60613          	addi	a2,a2,-1732 # ffffffffc0206aa0 <commands+0x450>
ffffffffc020116c:	0c000593          	li	a1,192
ffffffffc0201170:	00006517          	auipc	a0,0x6
ffffffffc0201174:	c3050513          	addi	a0,a0,-976 # ffffffffc0206da0 <commands+0x750>
ffffffffc0201178:	b02ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(!list_empty(&free_list));
ffffffffc020117c:	00006697          	auipc	a3,0x6
ffffffffc0201180:	dac68693          	addi	a3,a3,-596 # ffffffffc0206f28 <commands+0x8d8>
ffffffffc0201184:	00006617          	auipc	a2,0x6
ffffffffc0201188:	91c60613          	addi	a2,a2,-1764 # ffffffffc0206aa0 <commands+0x450>
ffffffffc020118c:	0d900593          	li	a1,217
ffffffffc0201190:	00006517          	auipc	a0,0x6
ffffffffc0201194:	c1050513          	addi	a0,a0,-1008 # ffffffffc0206da0 <commands+0x750>
ffffffffc0201198:	ae2ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020119c:	00006697          	auipc	a3,0x6
ffffffffc02011a0:	c3c68693          	addi	a3,a3,-964 # ffffffffc0206dd8 <commands+0x788>
ffffffffc02011a4:	00006617          	auipc	a2,0x6
ffffffffc02011a8:	8fc60613          	addi	a2,a2,-1796 # ffffffffc0206aa0 <commands+0x450>
ffffffffc02011ac:	0d200593          	li	a1,210
ffffffffc02011b0:	00006517          	auipc	a0,0x6
ffffffffc02011b4:	bf050513          	addi	a0,a0,-1040 # ffffffffc0206da0 <commands+0x750>
ffffffffc02011b8:	ac2ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(nr_free == 3);
ffffffffc02011bc:	00006697          	auipc	a3,0x6
ffffffffc02011c0:	d5c68693          	addi	a3,a3,-676 # ffffffffc0206f18 <commands+0x8c8>
ffffffffc02011c4:	00006617          	auipc	a2,0x6
ffffffffc02011c8:	8dc60613          	addi	a2,a2,-1828 # ffffffffc0206aa0 <commands+0x450>
ffffffffc02011cc:	0d000593          	li	a1,208
ffffffffc02011d0:	00006517          	auipc	a0,0x6
ffffffffc02011d4:	bd050513          	addi	a0,a0,-1072 # ffffffffc0206da0 <commands+0x750>
ffffffffc02011d8:	aa2ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(alloc_page() == NULL);
ffffffffc02011dc:	00006697          	auipc	a3,0x6
ffffffffc02011e0:	d2468693          	addi	a3,a3,-732 # ffffffffc0206f00 <commands+0x8b0>
ffffffffc02011e4:	00006617          	auipc	a2,0x6
ffffffffc02011e8:	8bc60613          	addi	a2,a2,-1860 # ffffffffc0206aa0 <commands+0x450>
ffffffffc02011ec:	0cb00593          	li	a1,203
ffffffffc02011f0:	00006517          	auipc	a0,0x6
ffffffffc02011f4:	bb050513          	addi	a0,a0,-1104 # ffffffffc0206da0 <commands+0x750>
ffffffffc02011f8:	a82ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02011fc:	00006697          	auipc	a3,0x6
ffffffffc0201200:	ce468693          	addi	a3,a3,-796 # ffffffffc0206ee0 <commands+0x890>
ffffffffc0201204:	00006617          	auipc	a2,0x6
ffffffffc0201208:	89c60613          	addi	a2,a2,-1892 # ffffffffc0206aa0 <commands+0x450>
ffffffffc020120c:	0c200593          	li	a1,194
ffffffffc0201210:	00006517          	auipc	a0,0x6
ffffffffc0201214:	b9050513          	addi	a0,a0,-1136 # ffffffffc0206da0 <commands+0x750>
ffffffffc0201218:	a62ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(p0 != NULL);
ffffffffc020121c:	00006697          	auipc	a3,0x6
ffffffffc0201220:	d5468693          	addi	a3,a3,-684 # ffffffffc0206f70 <commands+0x920>
ffffffffc0201224:	00006617          	auipc	a2,0x6
ffffffffc0201228:	87c60613          	addi	a2,a2,-1924 # ffffffffc0206aa0 <commands+0x450>
ffffffffc020122c:	0f800593          	li	a1,248
ffffffffc0201230:	00006517          	auipc	a0,0x6
ffffffffc0201234:	b7050513          	addi	a0,a0,-1168 # ffffffffc0206da0 <commands+0x750>
ffffffffc0201238:	a42ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(nr_free == 0);
ffffffffc020123c:	00006697          	auipc	a3,0x6
ffffffffc0201240:	d2468693          	addi	a3,a3,-732 # ffffffffc0206f60 <commands+0x910>
ffffffffc0201244:	00006617          	auipc	a2,0x6
ffffffffc0201248:	85c60613          	addi	a2,a2,-1956 # ffffffffc0206aa0 <commands+0x450>
ffffffffc020124c:	0df00593          	li	a1,223
ffffffffc0201250:	00006517          	auipc	a0,0x6
ffffffffc0201254:	b5050513          	addi	a0,a0,-1200 # ffffffffc0206da0 <commands+0x750>
ffffffffc0201258:	a22ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(alloc_page() == NULL);
ffffffffc020125c:	00006697          	auipc	a3,0x6
ffffffffc0201260:	ca468693          	addi	a3,a3,-860 # ffffffffc0206f00 <commands+0x8b0>
ffffffffc0201264:	00006617          	auipc	a2,0x6
ffffffffc0201268:	83c60613          	addi	a2,a2,-1988 # ffffffffc0206aa0 <commands+0x450>
ffffffffc020126c:	0dd00593          	li	a1,221
ffffffffc0201270:	00006517          	auipc	a0,0x6
ffffffffc0201274:	b3050513          	addi	a0,a0,-1232 # ffffffffc0206da0 <commands+0x750>
ffffffffc0201278:	a02ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc020127c:	00006697          	auipc	a3,0x6
ffffffffc0201280:	cc468693          	addi	a3,a3,-828 # ffffffffc0206f40 <commands+0x8f0>
ffffffffc0201284:	00006617          	auipc	a2,0x6
ffffffffc0201288:	81c60613          	addi	a2,a2,-2020 # ffffffffc0206aa0 <commands+0x450>
ffffffffc020128c:	0dc00593          	li	a1,220
ffffffffc0201290:	00006517          	auipc	a0,0x6
ffffffffc0201294:	b1050513          	addi	a0,a0,-1264 # ffffffffc0206da0 <commands+0x750>
ffffffffc0201298:	9e2ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020129c:	00006697          	auipc	a3,0x6
ffffffffc02012a0:	b3c68693          	addi	a3,a3,-1220 # ffffffffc0206dd8 <commands+0x788>
ffffffffc02012a4:	00005617          	auipc	a2,0x5
ffffffffc02012a8:	7fc60613          	addi	a2,a2,2044 # ffffffffc0206aa0 <commands+0x450>
ffffffffc02012ac:	0b900593          	li	a1,185
ffffffffc02012b0:	00006517          	auipc	a0,0x6
ffffffffc02012b4:	af050513          	addi	a0,a0,-1296 # ffffffffc0206da0 <commands+0x750>
ffffffffc02012b8:	9c2ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(alloc_page() == NULL);
ffffffffc02012bc:	00006697          	auipc	a3,0x6
ffffffffc02012c0:	c4468693          	addi	a3,a3,-956 # ffffffffc0206f00 <commands+0x8b0>
ffffffffc02012c4:	00005617          	auipc	a2,0x5
ffffffffc02012c8:	7dc60613          	addi	a2,a2,2012 # ffffffffc0206aa0 <commands+0x450>
ffffffffc02012cc:	0d600593          	li	a1,214
ffffffffc02012d0:	00006517          	auipc	a0,0x6
ffffffffc02012d4:	ad050513          	addi	a0,a0,-1328 # ffffffffc0206da0 <commands+0x750>
ffffffffc02012d8:	9a2ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02012dc:	00006697          	auipc	a3,0x6
ffffffffc02012e0:	b3c68693          	addi	a3,a3,-1220 # ffffffffc0206e18 <commands+0x7c8>
ffffffffc02012e4:	00005617          	auipc	a2,0x5
ffffffffc02012e8:	7bc60613          	addi	a2,a2,1980 # ffffffffc0206aa0 <commands+0x450>
ffffffffc02012ec:	0d400593          	li	a1,212
ffffffffc02012f0:	00006517          	auipc	a0,0x6
ffffffffc02012f4:	ab050513          	addi	a0,a0,-1360 # ffffffffc0206da0 <commands+0x750>
ffffffffc02012f8:	982ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02012fc:	00006697          	auipc	a3,0x6
ffffffffc0201300:	afc68693          	addi	a3,a3,-1284 # ffffffffc0206df8 <commands+0x7a8>
ffffffffc0201304:	00005617          	auipc	a2,0x5
ffffffffc0201308:	79c60613          	addi	a2,a2,1948 # ffffffffc0206aa0 <commands+0x450>
ffffffffc020130c:	0d300593          	li	a1,211
ffffffffc0201310:	00006517          	auipc	a0,0x6
ffffffffc0201314:	a9050513          	addi	a0,a0,-1392 # ffffffffc0206da0 <commands+0x750>
ffffffffc0201318:	962ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020131c:	00006697          	auipc	a3,0x6
ffffffffc0201320:	afc68693          	addi	a3,a3,-1284 # ffffffffc0206e18 <commands+0x7c8>
ffffffffc0201324:	00005617          	auipc	a2,0x5
ffffffffc0201328:	77c60613          	addi	a2,a2,1916 # ffffffffc0206aa0 <commands+0x450>
ffffffffc020132c:	0bb00593          	li	a1,187
ffffffffc0201330:	00006517          	auipc	a0,0x6
ffffffffc0201334:	a7050513          	addi	a0,a0,-1424 # ffffffffc0206da0 <commands+0x750>
ffffffffc0201338:	942ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(count == 0);
ffffffffc020133c:	00006697          	auipc	a3,0x6
ffffffffc0201340:	d8468693          	addi	a3,a3,-636 # ffffffffc02070c0 <commands+0xa70>
ffffffffc0201344:	00005617          	auipc	a2,0x5
ffffffffc0201348:	75c60613          	addi	a2,a2,1884 # ffffffffc0206aa0 <commands+0x450>
ffffffffc020134c:	12500593          	li	a1,293
ffffffffc0201350:	00006517          	auipc	a0,0x6
ffffffffc0201354:	a5050513          	addi	a0,a0,-1456 # ffffffffc0206da0 <commands+0x750>
ffffffffc0201358:	922ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(nr_free == 0);
ffffffffc020135c:	00006697          	auipc	a3,0x6
ffffffffc0201360:	c0468693          	addi	a3,a3,-1020 # ffffffffc0206f60 <commands+0x910>
ffffffffc0201364:	00005617          	auipc	a2,0x5
ffffffffc0201368:	73c60613          	addi	a2,a2,1852 # ffffffffc0206aa0 <commands+0x450>
ffffffffc020136c:	11a00593          	li	a1,282
ffffffffc0201370:	00006517          	auipc	a0,0x6
ffffffffc0201374:	a3050513          	addi	a0,a0,-1488 # ffffffffc0206da0 <commands+0x750>
ffffffffc0201378:	902ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(alloc_page() == NULL);
ffffffffc020137c:	00006697          	auipc	a3,0x6
ffffffffc0201380:	b8468693          	addi	a3,a3,-1148 # ffffffffc0206f00 <commands+0x8b0>
ffffffffc0201384:	00005617          	auipc	a2,0x5
ffffffffc0201388:	71c60613          	addi	a2,a2,1820 # ffffffffc0206aa0 <commands+0x450>
ffffffffc020138c:	11800593          	li	a1,280
ffffffffc0201390:	00006517          	auipc	a0,0x6
ffffffffc0201394:	a1050513          	addi	a0,a0,-1520 # ffffffffc0206da0 <commands+0x750>
ffffffffc0201398:	8e2ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc020139c:	00006697          	auipc	a3,0x6
ffffffffc02013a0:	b2468693          	addi	a3,a3,-1244 # ffffffffc0206ec0 <commands+0x870>
ffffffffc02013a4:	00005617          	auipc	a2,0x5
ffffffffc02013a8:	6fc60613          	addi	a2,a2,1788 # ffffffffc0206aa0 <commands+0x450>
ffffffffc02013ac:	0c100593          	li	a1,193
ffffffffc02013b0:	00006517          	auipc	a0,0x6
ffffffffc02013b4:	9f050513          	addi	a0,a0,-1552 # ffffffffc0206da0 <commands+0x750>
ffffffffc02013b8:	8c2ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02013bc:	00006697          	auipc	a3,0x6
ffffffffc02013c0:	cc468693          	addi	a3,a3,-828 # ffffffffc0207080 <commands+0xa30>
ffffffffc02013c4:	00005617          	auipc	a2,0x5
ffffffffc02013c8:	6dc60613          	addi	a2,a2,1756 # ffffffffc0206aa0 <commands+0x450>
ffffffffc02013cc:	11200593          	li	a1,274
ffffffffc02013d0:	00006517          	auipc	a0,0x6
ffffffffc02013d4:	9d050513          	addi	a0,a0,-1584 # ffffffffc0206da0 <commands+0x750>
ffffffffc02013d8:	8a2ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02013dc:	00006697          	auipc	a3,0x6
ffffffffc02013e0:	c8468693          	addi	a3,a3,-892 # ffffffffc0207060 <commands+0xa10>
ffffffffc02013e4:	00005617          	auipc	a2,0x5
ffffffffc02013e8:	6bc60613          	addi	a2,a2,1724 # ffffffffc0206aa0 <commands+0x450>
ffffffffc02013ec:	11000593          	li	a1,272
ffffffffc02013f0:	00006517          	auipc	a0,0x6
ffffffffc02013f4:	9b050513          	addi	a0,a0,-1616 # ffffffffc0206da0 <commands+0x750>
ffffffffc02013f8:	882ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02013fc:	00006697          	auipc	a3,0x6
ffffffffc0201400:	c3c68693          	addi	a3,a3,-964 # ffffffffc0207038 <commands+0x9e8>
ffffffffc0201404:	00005617          	auipc	a2,0x5
ffffffffc0201408:	69c60613          	addi	a2,a2,1692 # ffffffffc0206aa0 <commands+0x450>
ffffffffc020140c:	10e00593          	li	a1,270
ffffffffc0201410:	00006517          	auipc	a0,0x6
ffffffffc0201414:	99050513          	addi	a0,a0,-1648 # ffffffffc0206da0 <commands+0x750>
ffffffffc0201418:	862ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc020141c:	00006697          	auipc	a3,0x6
ffffffffc0201420:	bf468693          	addi	a3,a3,-1036 # ffffffffc0207010 <commands+0x9c0>
ffffffffc0201424:	00005617          	auipc	a2,0x5
ffffffffc0201428:	67c60613          	addi	a2,a2,1660 # ffffffffc0206aa0 <commands+0x450>
ffffffffc020142c:	10d00593          	li	a1,269
ffffffffc0201430:	00006517          	auipc	a0,0x6
ffffffffc0201434:	97050513          	addi	a0,a0,-1680 # ffffffffc0206da0 <commands+0x750>
ffffffffc0201438:	842ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(p0 + 2 == p1);
ffffffffc020143c:	00006697          	auipc	a3,0x6
ffffffffc0201440:	bc468693          	addi	a3,a3,-1084 # ffffffffc0207000 <commands+0x9b0>
ffffffffc0201444:	00005617          	auipc	a2,0x5
ffffffffc0201448:	65c60613          	addi	a2,a2,1628 # ffffffffc0206aa0 <commands+0x450>
ffffffffc020144c:	10800593          	li	a1,264
ffffffffc0201450:	00006517          	auipc	a0,0x6
ffffffffc0201454:	95050513          	addi	a0,a0,-1712 # ffffffffc0206da0 <commands+0x750>
ffffffffc0201458:	822ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(alloc_page() == NULL);
ffffffffc020145c:	00006697          	auipc	a3,0x6
ffffffffc0201460:	aa468693          	addi	a3,a3,-1372 # ffffffffc0206f00 <commands+0x8b0>
ffffffffc0201464:	00005617          	auipc	a2,0x5
ffffffffc0201468:	63c60613          	addi	a2,a2,1596 # ffffffffc0206aa0 <commands+0x450>
ffffffffc020146c:	10700593          	li	a1,263
ffffffffc0201470:	00006517          	auipc	a0,0x6
ffffffffc0201474:	93050513          	addi	a0,a0,-1744 # ffffffffc0206da0 <commands+0x750>
ffffffffc0201478:	802ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc020147c:	00006697          	auipc	a3,0x6
ffffffffc0201480:	b6468693          	addi	a3,a3,-1180 # ffffffffc0206fe0 <commands+0x990>
ffffffffc0201484:	00005617          	auipc	a2,0x5
ffffffffc0201488:	61c60613          	addi	a2,a2,1564 # ffffffffc0206aa0 <commands+0x450>
ffffffffc020148c:	10600593          	li	a1,262
ffffffffc0201490:	00006517          	auipc	a0,0x6
ffffffffc0201494:	91050513          	addi	a0,a0,-1776 # ffffffffc0206da0 <commands+0x750>
ffffffffc0201498:	fe3fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc020149c:	00006697          	auipc	a3,0x6
ffffffffc02014a0:	b1468693          	addi	a3,a3,-1260 # ffffffffc0206fb0 <commands+0x960>
ffffffffc02014a4:	00005617          	auipc	a2,0x5
ffffffffc02014a8:	5fc60613          	addi	a2,a2,1532 # ffffffffc0206aa0 <commands+0x450>
ffffffffc02014ac:	10500593          	li	a1,261
ffffffffc02014b0:	00006517          	auipc	a0,0x6
ffffffffc02014b4:	8f050513          	addi	a0,a0,-1808 # ffffffffc0206da0 <commands+0x750>
ffffffffc02014b8:	fc3fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02014bc:	00006697          	auipc	a3,0x6
ffffffffc02014c0:	adc68693          	addi	a3,a3,-1316 # ffffffffc0206f98 <commands+0x948>
ffffffffc02014c4:	00005617          	auipc	a2,0x5
ffffffffc02014c8:	5dc60613          	addi	a2,a2,1500 # ffffffffc0206aa0 <commands+0x450>
ffffffffc02014cc:	10400593          	li	a1,260
ffffffffc02014d0:	00006517          	auipc	a0,0x6
ffffffffc02014d4:	8d050513          	addi	a0,a0,-1840 # ffffffffc0206da0 <commands+0x750>
ffffffffc02014d8:	fa3fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(alloc_page() == NULL);
ffffffffc02014dc:	00006697          	auipc	a3,0x6
ffffffffc02014e0:	a2468693          	addi	a3,a3,-1500 # ffffffffc0206f00 <commands+0x8b0>
ffffffffc02014e4:	00005617          	auipc	a2,0x5
ffffffffc02014e8:	5bc60613          	addi	a2,a2,1468 # ffffffffc0206aa0 <commands+0x450>
ffffffffc02014ec:	0fe00593          	li	a1,254
ffffffffc02014f0:	00006517          	auipc	a0,0x6
ffffffffc02014f4:	8b050513          	addi	a0,a0,-1872 # ffffffffc0206da0 <commands+0x750>
ffffffffc02014f8:	f83fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(!PageProperty(p0));
ffffffffc02014fc:	00006697          	auipc	a3,0x6
ffffffffc0201500:	a8468693          	addi	a3,a3,-1404 # ffffffffc0206f80 <commands+0x930>
ffffffffc0201504:	00005617          	auipc	a2,0x5
ffffffffc0201508:	59c60613          	addi	a2,a2,1436 # ffffffffc0206aa0 <commands+0x450>
ffffffffc020150c:	0f900593          	li	a1,249
ffffffffc0201510:	00006517          	auipc	a0,0x6
ffffffffc0201514:	89050513          	addi	a0,a0,-1904 # ffffffffc0206da0 <commands+0x750>
ffffffffc0201518:	f63fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc020151c:	00006697          	auipc	a3,0x6
ffffffffc0201520:	b8468693          	addi	a3,a3,-1148 # ffffffffc02070a0 <commands+0xa50>
ffffffffc0201524:	00005617          	auipc	a2,0x5
ffffffffc0201528:	57c60613          	addi	a2,a2,1404 # ffffffffc0206aa0 <commands+0x450>
ffffffffc020152c:	11700593          	li	a1,279
ffffffffc0201530:	00006517          	auipc	a0,0x6
ffffffffc0201534:	87050513          	addi	a0,a0,-1936 # ffffffffc0206da0 <commands+0x750>
ffffffffc0201538:	f43fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(total == 0);
ffffffffc020153c:	00006697          	auipc	a3,0x6
ffffffffc0201540:	b9468693          	addi	a3,a3,-1132 # ffffffffc02070d0 <commands+0xa80>
ffffffffc0201544:	00005617          	auipc	a2,0x5
ffffffffc0201548:	55c60613          	addi	a2,a2,1372 # ffffffffc0206aa0 <commands+0x450>
ffffffffc020154c:	12600593          	li	a1,294
ffffffffc0201550:	00006517          	auipc	a0,0x6
ffffffffc0201554:	85050513          	addi	a0,a0,-1968 # ffffffffc0206da0 <commands+0x750>
ffffffffc0201558:	f23fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(total == nr_free_pages());
ffffffffc020155c:	00006697          	auipc	a3,0x6
ffffffffc0201560:	85c68693          	addi	a3,a3,-1956 # ffffffffc0206db8 <commands+0x768>
ffffffffc0201564:	00005617          	auipc	a2,0x5
ffffffffc0201568:	53c60613          	addi	a2,a2,1340 # ffffffffc0206aa0 <commands+0x450>
ffffffffc020156c:	0f300593          	li	a1,243
ffffffffc0201570:	00006517          	auipc	a0,0x6
ffffffffc0201574:	83050513          	addi	a0,a0,-2000 # ffffffffc0206da0 <commands+0x750>
ffffffffc0201578:	f03fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020157c:	00006697          	auipc	a3,0x6
ffffffffc0201580:	87c68693          	addi	a3,a3,-1924 # ffffffffc0206df8 <commands+0x7a8>
ffffffffc0201584:	00005617          	auipc	a2,0x5
ffffffffc0201588:	51c60613          	addi	a2,a2,1308 # ffffffffc0206aa0 <commands+0x450>
ffffffffc020158c:	0ba00593          	li	a1,186
ffffffffc0201590:	00006517          	auipc	a0,0x6
ffffffffc0201594:	81050513          	addi	a0,a0,-2032 # ffffffffc0206da0 <commands+0x750>
ffffffffc0201598:	ee3fe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc020159c <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc020159c:	1141                	addi	sp,sp,-16
ffffffffc020159e:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02015a0:	14058463          	beqz	a1,ffffffffc02016e8 <default_free_pages+0x14c>
    for (; p != base + n; p ++) {
ffffffffc02015a4:	00659693          	slli	a3,a1,0x6
ffffffffc02015a8:	96aa                	add	a3,a3,a0
ffffffffc02015aa:	87aa                	mv	a5,a0
ffffffffc02015ac:	02d50263          	beq	a0,a3,ffffffffc02015d0 <default_free_pages+0x34>
ffffffffc02015b0:	6798                	ld	a4,8(a5)
ffffffffc02015b2:	8b05                	andi	a4,a4,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02015b4:	10071a63          	bnez	a4,ffffffffc02016c8 <default_free_pages+0x12c>
ffffffffc02015b8:	6798                	ld	a4,8(a5)
ffffffffc02015ba:	8b09                	andi	a4,a4,2
ffffffffc02015bc:	10071663          	bnez	a4,ffffffffc02016c8 <default_free_pages+0x12c>
        p->flags = 0;
ffffffffc02015c0:	0007b423          	sd	zero,8(a5)
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
    page->ref = val;
ffffffffc02015c4:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02015c8:	04078793          	addi	a5,a5,64
ffffffffc02015cc:	fed792e3          	bne	a5,a3,ffffffffc02015b0 <default_free_pages+0x14>
    base->property = n;
ffffffffc02015d0:	2581                	sext.w	a1,a1
ffffffffc02015d2:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc02015d4:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02015d8:	4789                	li	a5,2
ffffffffc02015da:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02015de:	000ad697          	auipc	a3,0xad
ffffffffc02015e2:	0b268693          	addi	a3,a3,178 # ffffffffc02ae690 <free_area>
ffffffffc02015e6:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02015e8:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc02015ea:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc02015ee:	9db9                	addw	a1,a1,a4
ffffffffc02015f0:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc02015f2:	0ad78463          	beq	a5,a3,ffffffffc020169a <default_free_pages+0xfe>
            struct Page* page = le2page(le, page_link);
ffffffffc02015f6:	fe878713          	addi	a4,a5,-24
ffffffffc02015fa:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02015fe:	4581                	li	a1,0
            if (base < page) {
ffffffffc0201600:	00e56a63          	bltu	a0,a4,ffffffffc0201614 <default_free_pages+0x78>
    return listelm->next;
ffffffffc0201604:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201606:	04d70c63          	beq	a4,a3,ffffffffc020165e <default_free_pages+0xc2>
    for (; p != base + n; p ++) {
ffffffffc020160a:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020160c:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201610:	fee57ae3          	bgeu	a0,a4,ffffffffc0201604 <default_free_pages+0x68>
ffffffffc0201614:	c199                	beqz	a1,ffffffffc020161a <default_free_pages+0x7e>
ffffffffc0201616:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020161a:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc020161c:	e390                	sd	a2,0(a5)
ffffffffc020161e:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201620:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201622:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc0201624:	00d70d63          	beq	a4,a3,ffffffffc020163e <default_free_pages+0xa2>
        if (p + p->property == base) {
ffffffffc0201628:	ff872583          	lw	a1,-8(a4)
        p = le2page(le, page_link);
ffffffffc020162c:	fe870613          	addi	a2,a4,-24
        if (p + p->property == base) {
ffffffffc0201630:	02059813          	slli	a6,a1,0x20
ffffffffc0201634:	01a85793          	srli	a5,a6,0x1a
ffffffffc0201638:	97b2                	add	a5,a5,a2
ffffffffc020163a:	02f50c63          	beq	a0,a5,ffffffffc0201672 <default_free_pages+0xd6>
    return listelm->next;
ffffffffc020163e:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc0201640:	00d78c63          	beq	a5,a3,ffffffffc0201658 <default_free_pages+0xbc>
        if (base + base->property == p) {
ffffffffc0201644:	4910                	lw	a2,16(a0)
        p = le2page(le, page_link);
ffffffffc0201646:	fe878693          	addi	a3,a5,-24
        if (base + base->property == p) {
ffffffffc020164a:	02061593          	slli	a1,a2,0x20
ffffffffc020164e:	01a5d713          	srli	a4,a1,0x1a
ffffffffc0201652:	972a                	add	a4,a4,a0
ffffffffc0201654:	04e68a63          	beq	a3,a4,ffffffffc02016a8 <default_free_pages+0x10c>
}
ffffffffc0201658:	60a2                	ld	ra,8(sp)
ffffffffc020165a:	0141                	addi	sp,sp,16
ffffffffc020165c:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020165e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201660:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0201662:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201664:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201666:	02d70763          	beq	a4,a3,ffffffffc0201694 <default_free_pages+0xf8>
    prev->next = next->prev = elm;
ffffffffc020166a:	8832                	mv	a6,a2
ffffffffc020166c:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc020166e:	87ba                	mv	a5,a4
ffffffffc0201670:	bf71                	j	ffffffffc020160c <default_free_pages+0x70>
            p->property += base->property;
ffffffffc0201672:	491c                	lw	a5,16(a0)
ffffffffc0201674:	9dbd                	addw	a1,a1,a5
ffffffffc0201676:	feb72c23          	sw	a1,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020167a:	57f5                	li	a5,-3
ffffffffc020167c:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201680:	01853803          	ld	a6,24(a0)
ffffffffc0201684:	710c                	ld	a1,32(a0)
            base = p;
ffffffffc0201686:	8532                	mv	a0,a2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0201688:	00b83423          	sd	a1,8(a6)
    return listelm->next;
ffffffffc020168c:	671c                	ld	a5,8(a4)
    next->prev = prev;
ffffffffc020168e:	0105b023          	sd	a6,0(a1)
ffffffffc0201692:	b77d                	j	ffffffffc0201640 <default_free_pages+0xa4>
ffffffffc0201694:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201696:	873e                	mv	a4,a5
ffffffffc0201698:	bf41                	j	ffffffffc0201628 <default_free_pages+0x8c>
}
ffffffffc020169a:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020169c:	e390                	sd	a2,0(a5)
ffffffffc020169e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02016a0:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02016a2:	ed1c                	sd	a5,24(a0)
ffffffffc02016a4:	0141                	addi	sp,sp,16
ffffffffc02016a6:	8082                	ret
            base->property += p->property;
ffffffffc02016a8:	ff87a703          	lw	a4,-8(a5)
ffffffffc02016ac:	ff078693          	addi	a3,a5,-16
ffffffffc02016b0:	9e39                	addw	a2,a2,a4
ffffffffc02016b2:	c910                	sw	a2,16(a0)
ffffffffc02016b4:	5775                	li	a4,-3
ffffffffc02016b6:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02016ba:	6398                	ld	a4,0(a5)
ffffffffc02016bc:	679c                	ld	a5,8(a5)
}
ffffffffc02016be:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02016c0:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02016c2:	e398                	sd	a4,0(a5)
ffffffffc02016c4:	0141                	addi	sp,sp,16
ffffffffc02016c6:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02016c8:	00006697          	auipc	a3,0x6
ffffffffc02016cc:	a2068693          	addi	a3,a3,-1504 # ffffffffc02070e8 <commands+0xa98>
ffffffffc02016d0:	00005617          	auipc	a2,0x5
ffffffffc02016d4:	3d060613          	addi	a2,a2,976 # ffffffffc0206aa0 <commands+0x450>
ffffffffc02016d8:	08300593          	li	a1,131
ffffffffc02016dc:	00005517          	auipc	a0,0x5
ffffffffc02016e0:	6c450513          	addi	a0,a0,1732 # ffffffffc0206da0 <commands+0x750>
ffffffffc02016e4:	d97fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(n > 0);
ffffffffc02016e8:	00006697          	auipc	a3,0x6
ffffffffc02016ec:	9f868693          	addi	a3,a3,-1544 # ffffffffc02070e0 <commands+0xa90>
ffffffffc02016f0:	00005617          	auipc	a2,0x5
ffffffffc02016f4:	3b060613          	addi	a2,a2,944 # ffffffffc0206aa0 <commands+0x450>
ffffffffc02016f8:	08000593          	li	a1,128
ffffffffc02016fc:	00005517          	auipc	a0,0x5
ffffffffc0201700:	6a450513          	addi	a0,a0,1700 # ffffffffc0206da0 <commands+0x750>
ffffffffc0201704:	d77fe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0201708 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0201708:	c941                	beqz	a0,ffffffffc0201798 <default_alloc_pages+0x90>
    if (n > nr_free) {
ffffffffc020170a:	000ad597          	auipc	a1,0xad
ffffffffc020170e:	f8658593          	addi	a1,a1,-122 # ffffffffc02ae690 <free_area>
ffffffffc0201712:	0105a803          	lw	a6,16(a1)
ffffffffc0201716:	872a                	mv	a4,a0
ffffffffc0201718:	02081793          	slli	a5,a6,0x20
ffffffffc020171c:	9381                	srli	a5,a5,0x20
ffffffffc020171e:	00a7ee63          	bltu	a5,a0,ffffffffc020173a <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0201722:	87ae                	mv	a5,a1
ffffffffc0201724:	a801                	j	ffffffffc0201734 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0201726:	ff87a683          	lw	a3,-8(a5)
ffffffffc020172a:	02069613          	slli	a2,a3,0x20
ffffffffc020172e:	9201                	srli	a2,a2,0x20
ffffffffc0201730:	00e67763          	bgeu	a2,a4,ffffffffc020173e <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0201734:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201736:	feb798e3          	bne	a5,a1,ffffffffc0201726 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc020173a:	4501                	li	a0,0
}
ffffffffc020173c:	8082                	ret
    return listelm->prev;
ffffffffc020173e:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201742:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc0201746:	fe878513          	addi	a0,a5,-24
            p->property = page->property - n;
ffffffffc020174a:	00070e1b          	sext.w	t3,a4
    prev->next = next;
ffffffffc020174e:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0201752:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0201756:	02c77863          	bgeu	a4,a2,ffffffffc0201786 <default_alloc_pages+0x7e>
            struct Page *p = page + n;
ffffffffc020175a:	071a                	slli	a4,a4,0x6
ffffffffc020175c:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc020175e:	41c686bb          	subw	a3,a3,t3
ffffffffc0201762:	cb14                	sw	a3,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201764:	00870613          	addi	a2,a4,8
ffffffffc0201768:	4689                	li	a3,2
ffffffffc020176a:	40d6302f          	amoor.d	zero,a3,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc020176e:	0088b683          	ld	a3,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0201772:	01870613          	addi	a2,a4,24
        nr_free -= n;
ffffffffc0201776:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc020177a:	e290                	sd	a2,0(a3)
ffffffffc020177c:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0201780:	f314                	sd	a3,32(a4)
    elm->prev = prev;
ffffffffc0201782:	01173c23          	sd	a7,24(a4)
ffffffffc0201786:	41c8083b          	subw	a6,a6,t3
ffffffffc020178a:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020178e:	5775                	li	a4,-3
ffffffffc0201790:	17c1                	addi	a5,a5,-16
ffffffffc0201792:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc0201796:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0201798:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc020179a:	00006697          	auipc	a3,0x6
ffffffffc020179e:	94668693          	addi	a3,a3,-1722 # ffffffffc02070e0 <commands+0xa90>
ffffffffc02017a2:	00005617          	auipc	a2,0x5
ffffffffc02017a6:	2fe60613          	addi	a2,a2,766 # ffffffffc0206aa0 <commands+0x450>
ffffffffc02017aa:	06200593          	li	a1,98
ffffffffc02017ae:	00005517          	auipc	a0,0x5
ffffffffc02017b2:	5f250513          	addi	a0,a0,1522 # ffffffffc0206da0 <commands+0x750>
default_alloc_pages(size_t n) {
ffffffffc02017b6:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02017b8:	cc3fe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02017bc <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc02017bc:	1141                	addi	sp,sp,-16
ffffffffc02017be:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02017c0:	c5f1                	beqz	a1,ffffffffc020188c <default_init_memmap+0xd0>
    for (; p != base + n; p ++) {
ffffffffc02017c2:	00659693          	slli	a3,a1,0x6
ffffffffc02017c6:	96aa                	add	a3,a3,a0
ffffffffc02017c8:	87aa                	mv	a5,a0
ffffffffc02017ca:	00d50f63          	beq	a0,a3,ffffffffc02017e8 <default_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02017ce:	6798                	ld	a4,8(a5)
ffffffffc02017d0:	8b05                	andi	a4,a4,1
        assert(PageReserved(p));
ffffffffc02017d2:	cf49                	beqz	a4,ffffffffc020186c <default_init_memmap+0xb0>
        p->flags = p->property = 0;
ffffffffc02017d4:	0007a823          	sw	zero,16(a5)
ffffffffc02017d8:	0007b423          	sd	zero,8(a5)
ffffffffc02017dc:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02017e0:	04078793          	addi	a5,a5,64
ffffffffc02017e4:	fed795e3          	bne	a5,a3,ffffffffc02017ce <default_init_memmap+0x12>
    base->property = n;
ffffffffc02017e8:	2581                	sext.w	a1,a1
ffffffffc02017ea:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02017ec:	4789                	li	a5,2
ffffffffc02017ee:	00850713          	addi	a4,a0,8
ffffffffc02017f2:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02017f6:	000ad697          	auipc	a3,0xad
ffffffffc02017fa:	e9a68693          	addi	a3,a3,-358 # ffffffffc02ae690 <free_area>
ffffffffc02017fe:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201800:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0201802:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0201806:	9db9                	addw	a1,a1,a4
ffffffffc0201808:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc020180a:	04d78a63          	beq	a5,a3,ffffffffc020185e <default_init_memmap+0xa2>
            struct Page* page = le2page(le, page_link);
ffffffffc020180e:	fe878713          	addi	a4,a5,-24
ffffffffc0201812:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201816:	4581                	li	a1,0
            if (base < page) {
ffffffffc0201818:	00e56a63          	bltu	a0,a4,ffffffffc020182c <default_init_memmap+0x70>
    return listelm->next;
ffffffffc020181c:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020181e:	02d70263          	beq	a4,a3,ffffffffc0201842 <default_init_memmap+0x86>
    for (; p != base + n; p ++) {
ffffffffc0201822:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201824:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201828:	fee57ae3          	bgeu	a0,a4,ffffffffc020181c <default_init_memmap+0x60>
ffffffffc020182c:	c199                	beqz	a1,ffffffffc0201832 <default_init_memmap+0x76>
ffffffffc020182e:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201832:	6398                	ld	a4,0(a5)
}
ffffffffc0201834:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201836:	e390                	sd	a2,0(a5)
ffffffffc0201838:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020183a:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020183c:	ed18                	sd	a4,24(a0)
ffffffffc020183e:	0141                	addi	sp,sp,16
ffffffffc0201840:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201842:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201844:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0201846:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201848:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc020184a:	00d70663          	beq	a4,a3,ffffffffc0201856 <default_init_memmap+0x9a>
    prev->next = next->prev = elm;
ffffffffc020184e:	8832                	mv	a6,a2
ffffffffc0201850:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0201852:	87ba                	mv	a5,a4
ffffffffc0201854:	bfc1                	j	ffffffffc0201824 <default_init_memmap+0x68>
}
ffffffffc0201856:	60a2                	ld	ra,8(sp)
ffffffffc0201858:	e290                	sd	a2,0(a3)
ffffffffc020185a:	0141                	addi	sp,sp,16
ffffffffc020185c:	8082                	ret
ffffffffc020185e:	60a2                	ld	ra,8(sp)
ffffffffc0201860:	e390                	sd	a2,0(a5)
ffffffffc0201862:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201864:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201866:	ed1c                	sd	a5,24(a0)
ffffffffc0201868:	0141                	addi	sp,sp,16
ffffffffc020186a:	8082                	ret
        assert(PageReserved(p));
ffffffffc020186c:	00006697          	auipc	a3,0x6
ffffffffc0201870:	8a468693          	addi	a3,a3,-1884 # ffffffffc0207110 <commands+0xac0>
ffffffffc0201874:	00005617          	auipc	a2,0x5
ffffffffc0201878:	22c60613          	addi	a2,a2,556 # ffffffffc0206aa0 <commands+0x450>
ffffffffc020187c:	04900593          	li	a1,73
ffffffffc0201880:	00005517          	auipc	a0,0x5
ffffffffc0201884:	52050513          	addi	a0,a0,1312 # ffffffffc0206da0 <commands+0x750>
ffffffffc0201888:	bf3fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(n > 0);
ffffffffc020188c:	00006697          	auipc	a3,0x6
ffffffffc0201890:	85468693          	addi	a3,a3,-1964 # ffffffffc02070e0 <commands+0xa90>
ffffffffc0201894:	00005617          	auipc	a2,0x5
ffffffffc0201898:	20c60613          	addi	a2,a2,524 # ffffffffc0206aa0 <commands+0x450>
ffffffffc020189c:	04600593          	li	a1,70
ffffffffc02018a0:	00005517          	auipc	a0,0x5
ffffffffc02018a4:	50050513          	addi	a0,a0,1280 # ffffffffc0206da0 <commands+0x750>
ffffffffc02018a8:	bd3fe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02018ac <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc02018ac:	c94d                	beqz	a0,ffffffffc020195e <slob_free+0xb2>
{
ffffffffc02018ae:	1141                	addi	sp,sp,-16
ffffffffc02018b0:	e022                	sd	s0,0(sp)
ffffffffc02018b2:	e406                	sd	ra,8(sp)
ffffffffc02018b4:	842a                	mv	s0,a0
		return;

	if (size)
ffffffffc02018b6:	e9c1                	bnez	a1,ffffffffc0201946 <slob_free+0x9a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02018b8:	100027f3          	csrr	a5,sstatus
ffffffffc02018bc:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02018be:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02018c0:	ebd9                	bnez	a5,ffffffffc0201956 <slob_free+0xaa>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02018c2:	000a6617          	auipc	a2,0xa6
ffffffffc02018c6:	9be60613          	addi	a2,a2,-1602 # ffffffffc02a7280 <slobfree>
ffffffffc02018ca:	621c                	ld	a5,0(a2)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02018cc:	873e                	mv	a4,a5
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02018ce:	679c                	ld	a5,8(a5)
ffffffffc02018d0:	02877a63          	bgeu	a4,s0,ffffffffc0201904 <slob_free+0x58>
ffffffffc02018d4:	00f46463          	bltu	s0,a5,ffffffffc02018dc <slob_free+0x30>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02018d8:	fef76ae3          	bltu	a4,a5,ffffffffc02018cc <slob_free+0x20>
			break;

	if (b + b->units == cur->next) {
ffffffffc02018dc:	400c                	lw	a1,0(s0)
ffffffffc02018de:	00459693          	slli	a3,a1,0x4
ffffffffc02018e2:	96a2                	add	a3,a3,s0
ffffffffc02018e4:	02d78a63          	beq	a5,a3,ffffffffc0201918 <slob_free+0x6c>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc02018e8:	4314                	lw	a3,0(a4)
		b->next = cur->next;
ffffffffc02018ea:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b) {
ffffffffc02018ec:	00469793          	slli	a5,a3,0x4
ffffffffc02018f0:	97ba                	add	a5,a5,a4
ffffffffc02018f2:	02f40e63          	beq	s0,a5,ffffffffc020192e <slob_free+0x82>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc02018f6:	e700                	sd	s0,8(a4)

	slobfree = cur;
ffffffffc02018f8:	e218                	sd	a4,0(a2)
    if (flag) {
ffffffffc02018fa:	e129                	bnez	a0,ffffffffc020193c <slob_free+0x90>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc02018fc:	60a2                	ld	ra,8(sp)
ffffffffc02018fe:	6402                	ld	s0,0(sp)
ffffffffc0201900:	0141                	addi	sp,sp,16
ffffffffc0201902:	8082                	ret
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201904:	fcf764e3          	bltu	a4,a5,ffffffffc02018cc <slob_free+0x20>
ffffffffc0201908:	fcf472e3          	bgeu	s0,a5,ffffffffc02018cc <slob_free+0x20>
	if (b + b->units == cur->next) {
ffffffffc020190c:	400c                	lw	a1,0(s0)
ffffffffc020190e:	00459693          	slli	a3,a1,0x4
ffffffffc0201912:	96a2                	add	a3,a3,s0
ffffffffc0201914:	fcd79ae3          	bne	a5,a3,ffffffffc02018e8 <slob_free+0x3c>
		b->units += cur->next->units;
ffffffffc0201918:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc020191a:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc020191c:	9db5                	addw	a1,a1,a3
ffffffffc020191e:	c00c                	sw	a1,0(s0)
	if (cur + cur->units == b) {
ffffffffc0201920:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201922:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b) {
ffffffffc0201924:	00469793          	slli	a5,a3,0x4
ffffffffc0201928:	97ba                	add	a5,a5,a4
ffffffffc020192a:	fcf416e3          	bne	s0,a5,ffffffffc02018f6 <slob_free+0x4a>
		cur->units += b->units;
ffffffffc020192e:	401c                	lw	a5,0(s0)
		cur->next = b->next;
ffffffffc0201930:	640c                	ld	a1,8(s0)
	slobfree = cur;
ffffffffc0201932:	e218                	sd	a4,0(a2)
		cur->units += b->units;
ffffffffc0201934:	9ebd                	addw	a3,a3,a5
ffffffffc0201936:	c314                	sw	a3,0(a4)
		cur->next = b->next;
ffffffffc0201938:	e70c                	sd	a1,8(a4)
ffffffffc020193a:	d169                	beqz	a0,ffffffffc02018fc <slob_free+0x50>
}
ffffffffc020193c:	6402                	ld	s0,0(sp)
ffffffffc020193e:	60a2                	ld	ra,8(sp)
ffffffffc0201940:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0201942:	cdbfe06f          	j	ffffffffc020061c <intr_enable>
		b->units = SLOB_UNITS(size);
ffffffffc0201946:	25bd                	addiw	a1,a1,15
ffffffffc0201948:	8191                	srli	a1,a1,0x4
ffffffffc020194a:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020194c:	100027f3          	csrr	a5,sstatus
ffffffffc0201950:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201952:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201954:	d7bd                	beqz	a5,ffffffffc02018c2 <slob_free+0x16>
        intr_disable();
ffffffffc0201956:	ccdfe0ef          	jal	ra,ffffffffc0200622 <intr_disable>
        return 1;
ffffffffc020195a:	4505                	li	a0,1
ffffffffc020195c:	b79d                	j	ffffffffc02018c2 <slob_free+0x16>
ffffffffc020195e:	8082                	ret

ffffffffc0201960 <__slob_get_free_pages.constprop.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201960:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201962:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201964:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201968:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc020196a:	352000ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
  if(!page)
ffffffffc020196e:	c91d                	beqz	a0,ffffffffc02019a4 <__slob_get_free_pages.constprop.0+0x44>
    return page - pages + nbase;
ffffffffc0201970:	000b1697          	auipc	a3,0xb1
ffffffffc0201974:	e206b683          	ld	a3,-480(a3) # ffffffffc02b2790 <pages>
ffffffffc0201978:	8d15                	sub	a0,a0,a3
ffffffffc020197a:	8519                	srai	a0,a0,0x6
ffffffffc020197c:	00007697          	auipc	a3,0x7
ffffffffc0201980:	0dc6b683          	ld	a3,220(a3) # ffffffffc0208a58 <nbase>
ffffffffc0201984:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc0201986:	00c51793          	slli	a5,a0,0xc
ffffffffc020198a:	83b1                	srli	a5,a5,0xc
ffffffffc020198c:	000b1717          	auipc	a4,0xb1
ffffffffc0201990:	dfc73703          	ld	a4,-516(a4) # ffffffffc02b2788 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc0201994:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc0201996:	00e7fa63          	bgeu	a5,a4,ffffffffc02019aa <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc020199a:	000b1697          	auipc	a3,0xb1
ffffffffc020199e:	e066b683          	ld	a3,-506(a3) # ffffffffc02b27a0 <va_pa_offset>
ffffffffc02019a2:	9536                	add	a0,a0,a3
}
ffffffffc02019a4:	60a2                	ld	ra,8(sp)
ffffffffc02019a6:	0141                	addi	sp,sp,16
ffffffffc02019a8:	8082                	ret
ffffffffc02019aa:	86aa                	mv	a3,a0
ffffffffc02019ac:	00005617          	auipc	a2,0x5
ffffffffc02019b0:	7c460613          	addi	a2,a2,1988 # ffffffffc0207170 <default_pmm_manager+0x38>
ffffffffc02019b4:	06900593          	li	a1,105
ffffffffc02019b8:	00005517          	auipc	a0,0x5
ffffffffc02019bc:	7e050513          	addi	a0,a0,2016 # ffffffffc0207198 <default_pmm_manager+0x60>
ffffffffc02019c0:	abbfe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02019c4 <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc02019c4:	1101                	addi	sp,sp,-32
ffffffffc02019c6:	ec06                	sd	ra,24(sp)
ffffffffc02019c8:	e822                	sd	s0,16(sp)
ffffffffc02019ca:	e426                	sd	s1,8(sp)
ffffffffc02019cc:	e04a                	sd	s2,0(sp)
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc02019ce:	01050713          	addi	a4,a0,16
ffffffffc02019d2:	6785                	lui	a5,0x1
ffffffffc02019d4:	0cf77363          	bgeu	a4,a5,ffffffffc0201a9a <slob_alloc.constprop.0+0xd6>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc02019d8:	00f50493          	addi	s1,a0,15
ffffffffc02019dc:	8091                	srli	s1,s1,0x4
ffffffffc02019de:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02019e0:	10002673          	csrr	a2,sstatus
ffffffffc02019e4:	8a09                	andi	a2,a2,2
ffffffffc02019e6:	e25d                	bnez	a2,ffffffffc0201a8c <slob_alloc.constprop.0+0xc8>
	prev = slobfree;
ffffffffc02019e8:	000a6917          	auipc	s2,0xa6
ffffffffc02019ec:	89890913          	addi	s2,s2,-1896 # ffffffffc02a7280 <slobfree>
ffffffffc02019f0:	00093683          	ld	a3,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc02019f4:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc02019f6:	4398                	lw	a4,0(a5)
ffffffffc02019f8:	08975e63          	bge	a4,s1,ffffffffc0201a94 <slob_alloc.constprop.0+0xd0>
		if (cur == slobfree) {
ffffffffc02019fc:	00f68b63          	beq	a3,a5,ffffffffc0201a12 <slob_alloc.constprop.0+0x4e>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201a00:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201a02:	4018                	lw	a4,0(s0)
ffffffffc0201a04:	02975a63          	bge	a4,s1,ffffffffc0201a38 <slob_alloc.constprop.0+0x74>
		if (cur == slobfree) {
ffffffffc0201a08:	00093683          	ld	a3,0(s2)
ffffffffc0201a0c:	87a2                	mv	a5,s0
ffffffffc0201a0e:	fef699e3          	bne	a3,a5,ffffffffc0201a00 <slob_alloc.constprop.0+0x3c>
    if (flag) {
ffffffffc0201a12:	ee31                	bnez	a2,ffffffffc0201a6e <slob_alloc.constprop.0+0xaa>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201a14:	4501                	li	a0,0
ffffffffc0201a16:	f4bff0ef          	jal	ra,ffffffffc0201960 <__slob_get_free_pages.constprop.0>
ffffffffc0201a1a:	842a                	mv	s0,a0
			if (!cur)
ffffffffc0201a1c:	cd05                	beqz	a0,ffffffffc0201a54 <slob_alloc.constprop.0+0x90>
			slob_free(cur, PAGE_SIZE);
ffffffffc0201a1e:	6585                	lui	a1,0x1
ffffffffc0201a20:	e8dff0ef          	jal	ra,ffffffffc02018ac <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201a24:	10002673          	csrr	a2,sstatus
ffffffffc0201a28:	8a09                	andi	a2,a2,2
ffffffffc0201a2a:	ee05                	bnez	a2,ffffffffc0201a62 <slob_alloc.constprop.0+0x9e>
			cur = slobfree;
ffffffffc0201a2c:	00093783          	ld	a5,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201a30:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201a32:	4018                	lw	a4,0(s0)
ffffffffc0201a34:	fc974ae3          	blt	a4,s1,ffffffffc0201a08 <slob_alloc.constprop.0+0x44>
			if (cur->units == units) /* exact fit? */
ffffffffc0201a38:	04e48763          	beq	s1,a4,ffffffffc0201a86 <slob_alloc.constprop.0+0xc2>
				prev->next = cur + units;
ffffffffc0201a3c:	00449693          	slli	a3,s1,0x4
ffffffffc0201a40:	96a2                	add	a3,a3,s0
ffffffffc0201a42:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0201a44:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc0201a46:	9f05                	subw	a4,a4,s1
ffffffffc0201a48:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0201a4a:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0201a4c:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc0201a4e:	00f93023          	sd	a5,0(s2)
    if (flag) {
ffffffffc0201a52:	e20d                	bnez	a2,ffffffffc0201a74 <slob_alloc.constprop.0+0xb0>
}
ffffffffc0201a54:	60e2                	ld	ra,24(sp)
ffffffffc0201a56:	8522                	mv	a0,s0
ffffffffc0201a58:	6442                	ld	s0,16(sp)
ffffffffc0201a5a:	64a2                	ld	s1,8(sp)
ffffffffc0201a5c:	6902                	ld	s2,0(sp)
ffffffffc0201a5e:	6105                	addi	sp,sp,32
ffffffffc0201a60:	8082                	ret
        intr_disable();
ffffffffc0201a62:	bc1fe0ef          	jal	ra,ffffffffc0200622 <intr_disable>
			cur = slobfree;
ffffffffc0201a66:	00093783          	ld	a5,0(s2)
        return 1;
ffffffffc0201a6a:	4605                	li	a2,1
ffffffffc0201a6c:	b7d1                	j	ffffffffc0201a30 <slob_alloc.constprop.0+0x6c>
        intr_enable();
ffffffffc0201a6e:	baffe0ef          	jal	ra,ffffffffc020061c <intr_enable>
ffffffffc0201a72:	b74d                	j	ffffffffc0201a14 <slob_alloc.constprop.0+0x50>
ffffffffc0201a74:	ba9fe0ef          	jal	ra,ffffffffc020061c <intr_enable>
}
ffffffffc0201a78:	60e2                	ld	ra,24(sp)
ffffffffc0201a7a:	8522                	mv	a0,s0
ffffffffc0201a7c:	6442                	ld	s0,16(sp)
ffffffffc0201a7e:	64a2                	ld	s1,8(sp)
ffffffffc0201a80:	6902                	ld	s2,0(sp)
ffffffffc0201a82:	6105                	addi	sp,sp,32
ffffffffc0201a84:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0201a86:	6418                	ld	a4,8(s0)
ffffffffc0201a88:	e798                	sd	a4,8(a5)
ffffffffc0201a8a:	b7d1                	j	ffffffffc0201a4e <slob_alloc.constprop.0+0x8a>
        intr_disable();
ffffffffc0201a8c:	b97fe0ef          	jal	ra,ffffffffc0200622 <intr_disable>
        return 1;
ffffffffc0201a90:	4605                	li	a2,1
ffffffffc0201a92:	bf99                	j	ffffffffc02019e8 <slob_alloc.constprop.0+0x24>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201a94:	843e                	mv	s0,a5
ffffffffc0201a96:	87b6                	mv	a5,a3
ffffffffc0201a98:	b745                	j	ffffffffc0201a38 <slob_alloc.constprop.0+0x74>
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201a9a:	00005697          	auipc	a3,0x5
ffffffffc0201a9e:	70e68693          	addi	a3,a3,1806 # ffffffffc02071a8 <default_pmm_manager+0x70>
ffffffffc0201aa2:	00005617          	auipc	a2,0x5
ffffffffc0201aa6:	ffe60613          	addi	a2,a2,-2 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0201aaa:	06400593          	li	a1,100
ffffffffc0201aae:	00005517          	auipc	a0,0x5
ffffffffc0201ab2:	71a50513          	addi	a0,a0,1818 # ffffffffc02071c8 <default_pmm_manager+0x90>
ffffffffc0201ab6:	9c5fe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0201aba <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc0201aba:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc0201abc:	00005517          	auipc	a0,0x5
ffffffffc0201ac0:	72450513          	addi	a0,a0,1828 # ffffffffc02071e0 <default_pmm_manager+0xa8>
kmalloc_init(void) {
ffffffffc0201ac4:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc0201ac6:	ebafe0ef          	jal	ra,ffffffffc0200180 <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201aca:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201acc:	00005517          	auipc	a0,0x5
ffffffffc0201ad0:	72c50513          	addi	a0,a0,1836 # ffffffffc02071f8 <default_pmm_manager+0xc0>
}
ffffffffc0201ad4:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201ad6:	eaafe06f          	j	ffffffffc0200180 <cprintf>

ffffffffc0201ada <kallocated>:
}

size_t
kallocated(void) {
   return slob_allocated();
}
ffffffffc0201ada:	4501                	li	a0,0
ffffffffc0201adc:	8082                	ret

ffffffffc0201ade <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201ade:	1101                	addi	sp,sp,-32
ffffffffc0201ae0:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201ae2:	6905                	lui	s2,0x1
{
ffffffffc0201ae4:	e822                	sd	s0,16(sp)
ffffffffc0201ae6:	ec06                	sd	ra,24(sp)
ffffffffc0201ae8:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201aea:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x8bb9>
{
ffffffffc0201aee:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201af0:	04a7f963          	bgeu	a5,a0,ffffffffc0201b42 <kmalloc+0x64>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201af4:	4561                	li	a0,24
ffffffffc0201af6:	ecfff0ef          	jal	ra,ffffffffc02019c4 <slob_alloc.constprop.0>
ffffffffc0201afa:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0201afc:	c929                	beqz	a0,ffffffffc0201b4e <kmalloc+0x70>
	bb->order = find_order(size);
ffffffffc0201afe:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0201b02:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201b04:	00f95763          	bge	s2,a5,ffffffffc0201b12 <kmalloc+0x34>
ffffffffc0201b08:	6705                	lui	a4,0x1
ffffffffc0201b0a:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0201b0c:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201b0e:	fef74ee3          	blt	a4,a5,ffffffffc0201b0a <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0201b12:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201b14:	e4dff0ef          	jal	ra,ffffffffc0201960 <__slob_get_free_pages.constprop.0>
ffffffffc0201b18:	e488                	sd	a0,8(s1)
ffffffffc0201b1a:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc0201b1c:	c525                	beqz	a0,ffffffffc0201b84 <kmalloc+0xa6>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201b1e:	100027f3          	csrr	a5,sstatus
ffffffffc0201b22:	8b89                	andi	a5,a5,2
ffffffffc0201b24:	ef8d                	bnez	a5,ffffffffc0201b5e <kmalloc+0x80>
		bb->next = bigblocks;
ffffffffc0201b26:	000b1797          	auipc	a5,0xb1
ffffffffc0201b2a:	c4a78793          	addi	a5,a5,-950 # ffffffffc02b2770 <bigblocks>
ffffffffc0201b2e:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201b30:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201b32:	e898                	sd	a4,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc0201b34:	60e2                	ld	ra,24(sp)
ffffffffc0201b36:	8522                	mv	a0,s0
ffffffffc0201b38:	6442                	ld	s0,16(sp)
ffffffffc0201b3a:	64a2                	ld	s1,8(sp)
ffffffffc0201b3c:	6902                	ld	s2,0(sp)
ffffffffc0201b3e:	6105                	addi	sp,sp,32
ffffffffc0201b40:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201b42:	0541                	addi	a0,a0,16
ffffffffc0201b44:	e81ff0ef          	jal	ra,ffffffffc02019c4 <slob_alloc.constprop.0>
		return m ? (void *)(m + 1) : 0;
ffffffffc0201b48:	01050413          	addi	s0,a0,16
ffffffffc0201b4c:	f565                	bnez	a0,ffffffffc0201b34 <kmalloc+0x56>
ffffffffc0201b4e:	4401                	li	s0,0
}
ffffffffc0201b50:	60e2                	ld	ra,24(sp)
ffffffffc0201b52:	8522                	mv	a0,s0
ffffffffc0201b54:	6442                	ld	s0,16(sp)
ffffffffc0201b56:	64a2                	ld	s1,8(sp)
ffffffffc0201b58:	6902                	ld	s2,0(sp)
ffffffffc0201b5a:	6105                	addi	sp,sp,32
ffffffffc0201b5c:	8082                	ret
        intr_disable();
ffffffffc0201b5e:	ac5fe0ef          	jal	ra,ffffffffc0200622 <intr_disable>
		bb->next = bigblocks;
ffffffffc0201b62:	000b1797          	auipc	a5,0xb1
ffffffffc0201b66:	c0e78793          	addi	a5,a5,-1010 # ffffffffc02b2770 <bigblocks>
ffffffffc0201b6a:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201b6c:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201b6e:	e898                	sd	a4,16(s1)
        intr_enable();
ffffffffc0201b70:	aadfe0ef          	jal	ra,ffffffffc020061c <intr_enable>
		return bb->pages;
ffffffffc0201b74:	6480                	ld	s0,8(s1)
}
ffffffffc0201b76:	60e2                	ld	ra,24(sp)
ffffffffc0201b78:	64a2                	ld	s1,8(sp)
ffffffffc0201b7a:	8522                	mv	a0,s0
ffffffffc0201b7c:	6442                	ld	s0,16(sp)
ffffffffc0201b7e:	6902                	ld	s2,0(sp)
ffffffffc0201b80:	6105                	addi	sp,sp,32
ffffffffc0201b82:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201b84:	45e1                	li	a1,24
ffffffffc0201b86:	8526                	mv	a0,s1
ffffffffc0201b88:	d25ff0ef          	jal	ra,ffffffffc02018ac <slob_free>
  return __kmalloc(size, 0);
ffffffffc0201b8c:	b765                	j	ffffffffc0201b34 <kmalloc+0x56>

ffffffffc0201b8e <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201b8e:	c169                	beqz	a0,ffffffffc0201c50 <kfree+0xc2>
{
ffffffffc0201b90:	1101                	addi	sp,sp,-32
ffffffffc0201b92:	e822                	sd	s0,16(sp)
ffffffffc0201b94:	ec06                	sd	ra,24(sp)
ffffffffc0201b96:	e426                	sd	s1,8(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc0201b98:	03451793          	slli	a5,a0,0x34
ffffffffc0201b9c:	842a                	mv	s0,a0
ffffffffc0201b9e:	e3d9                	bnez	a5,ffffffffc0201c24 <kfree+0x96>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201ba0:	100027f3          	csrr	a5,sstatus
ffffffffc0201ba4:	8b89                	andi	a5,a5,2
ffffffffc0201ba6:	e7d9                	bnez	a5,ffffffffc0201c34 <kfree+0xa6>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201ba8:	000b1797          	auipc	a5,0xb1
ffffffffc0201bac:	bc87b783          	ld	a5,-1080(a5) # ffffffffc02b2770 <bigblocks>
    return 0;
ffffffffc0201bb0:	4601                	li	a2,0
ffffffffc0201bb2:	cbad                	beqz	a5,ffffffffc0201c24 <kfree+0x96>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc0201bb4:	000b1697          	auipc	a3,0xb1
ffffffffc0201bb8:	bbc68693          	addi	a3,a3,-1092 # ffffffffc02b2770 <bigblocks>
ffffffffc0201bbc:	a021                	j	ffffffffc0201bc4 <kfree+0x36>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201bbe:	01048693          	addi	a3,s1,16
ffffffffc0201bc2:	c3a5                	beqz	a5,ffffffffc0201c22 <kfree+0x94>
			if (bb->pages == block) {
ffffffffc0201bc4:	6798                	ld	a4,8(a5)
ffffffffc0201bc6:	84be                	mv	s1,a5
				*last = bb->next;
ffffffffc0201bc8:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block) {
ffffffffc0201bca:	fe871ae3          	bne	a4,s0,ffffffffc0201bbe <kfree+0x30>
				*last = bb->next;
ffffffffc0201bce:	e29c                	sd	a5,0(a3)
    if (flag) {
ffffffffc0201bd0:	ee2d                	bnez	a2,ffffffffc0201c4a <kfree+0xbc>
    return pa2page(PADDR(kva));
ffffffffc0201bd2:	c02007b7          	lui	a5,0xc0200
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0201bd6:	4098                	lw	a4,0(s1)
ffffffffc0201bd8:	08f46963          	bltu	s0,a5,ffffffffc0201c6a <kfree+0xdc>
ffffffffc0201bdc:	000b1697          	auipc	a3,0xb1
ffffffffc0201be0:	bc46b683          	ld	a3,-1084(a3) # ffffffffc02b27a0 <va_pa_offset>
ffffffffc0201be4:	8c15                	sub	s0,s0,a3
    if (PPN(pa) >= npage) {
ffffffffc0201be6:	8031                	srli	s0,s0,0xc
ffffffffc0201be8:	000b1797          	auipc	a5,0xb1
ffffffffc0201bec:	ba07b783          	ld	a5,-1120(a5) # ffffffffc02b2788 <npage>
ffffffffc0201bf0:	06f47163          	bgeu	s0,a5,ffffffffc0201c52 <kfree+0xc4>
    return &pages[PPN(pa) - nbase];
ffffffffc0201bf4:	00007517          	auipc	a0,0x7
ffffffffc0201bf8:	e6453503          	ld	a0,-412(a0) # ffffffffc0208a58 <nbase>
ffffffffc0201bfc:	8c09                	sub	s0,s0,a0
ffffffffc0201bfe:	041a                	slli	s0,s0,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc0201c00:	000b1517          	auipc	a0,0xb1
ffffffffc0201c04:	b9053503          	ld	a0,-1136(a0) # ffffffffc02b2790 <pages>
ffffffffc0201c08:	4585                	li	a1,1
ffffffffc0201c0a:	9522                	add	a0,a0,s0
ffffffffc0201c0c:	00e595bb          	sllw	a1,a1,a4
ffffffffc0201c10:	13e000ef          	jal	ra,ffffffffc0201d4e <free_pages>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201c14:	6442                	ld	s0,16(sp)
ffffffffc0201c16:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201c18:	8526                	mv	a0,s1
}
ffffffffc0201c1a:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201c1c:	45e1                	li	a1,24
}
ffffffffc0201c1e:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201c20:	b171                	j	ffffffffc02018ac <slob_free>
ffffffffc0201c22:	e20d                	bnez	a2,ffffffffc0201c44 <kfree+0xb6>
ffffffffc0201c24:	ff040513          	addi	a0,s0,-16
}
ffffffffc0201c28:	6442                	ld	s0,16(sp)
ffffffffc0201c2a:	60e2                	ld	ra,24(sp)
ffffffffc0201c2c:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201c2e:	4581                	li	a1,0
}
ffffffffc0201c30:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201c32:	b9ad                	j	ffffffffc02018ac <slob_free>
        intr_disable();
ffffffffc0201c34:	9effe0ef          	jal	ra,ffffffffc0200622 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201c38:	000b1797          	auipc	a5,0xb1
ffffffffc0201c3c:	b387b783          	ld	a5,-1224(a5) # ffffffffc02b2770 <bigblocks>
        return 1;
ffffffffc0201c40:	4605                	li	a2,1
ffffffffc0201c42:	fbad                	bnez	a5,ffffffffc0201bb4 <kfree+0x26>
        intr_enable();
ffffffffc0201c44:	9d9fe0ef          	jal	ra,ffffffffc020061c <intr_enable>
ffffffffc0201c48:	bff1                	j	ffffffffc0201c24 <kfree+0x96>
ffffffffc0201c4a:	9d3fe0ef          	jal	ra,ffffffffc020061c <intr_enable>
ffffffffc0201c4e:	b751                	j	ffffffffc0201bd2 <kfree+0x44>
ffffffffc0201c50:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc0201c52:	00005617          	auipc	a2,0x5
ffffffffc0201c56:	5ee60613          	addi	a2,a2,1518 # ffffffffc0207240 <default_pmm_manager+0x108>
ffffffffc0201c5a:	06200593          	li	a1,98
ffffffffc0201c5e:	00005517          	auipc	a0,0x5
ffffffffc0201c62:	53a50513          	addi	a0,a0,1338 # ffffffffc0207198 <default_pmm_manager+0x60>
ffffffffc0201c66:	815fe0ef          	jal	ra,ffffffffc020047a <__panic>
    return pa2page(PADDR(kva));
ffffffffc0201c6a:	86a2                	mv	a3,s0
ffffffffc0201c6c:	00005617          	auipc	a2,0x5
ffffffffc0201c70:	5ac60613          	addi	a2,a2,1452 # ffffffffc0207218 <default_pmm_manager+0xe0>
ffffffffc0201c74:	06e00593          	li	a1,110
ffffffffc0201c78:	00005517          	auipc	a0,0x5
ffffffffc0201c7c:	52050513          	addi	a0,a0,1312 # ffffffffc0207198 <default_pmm_manager+0x60>
ffffffffc0201c80:	ffafe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0201c84 <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc0201c84:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201c86:	00005617          	auipc	a2,0x5
ffffffffc0201c8a:	5ba60613          	addi	a2,a2,1466 # ffffffffc0207240 <default_pmm_manager+0x108>
ffffffffc0201c8e:	06200593          	li	a1,98
ffffffffc0201c92:	00005517          	auipc	a0,0x5
ffffffffc0201c96:	50650513          	addi	a0,a0,1286 # ffffffffc0207198 <default_pmm_manager+0x60>
pa2page(uintptr_t pa) {
ffffffffc0201c9a:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201c9c:	fdefe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0201ca0 <pte2page.part.0>:
pte2page(pte_t pte) {
ffffffffc0201ca0:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc0201ca2:	00005617          	auipc	a2,0x5
ffffffffc0201ca6:	5be60613          	addi	a2,a2,1470 # ffffffffc0207260 <default_pmm_manager+0x128>
ffffffffc0201caa:	07400593          	li	a1,116
ffffffffc0201cae:	00005517          	auipc	a0,0x5
ffffffffc0201cb2:	4ea50513          	addi	a0,a0,1258 # ffffffffc0207198 <default_pmm_manager+0x60>
pte2page(pte_t pte) {
ffffffffc0201cb6:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc0201cb8:	fc2fe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0201cbc <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0201cbc:	7139                	addi	sp,sp,-64
ffffffffc0201cbe:	f426                	sd	s1,40(sp)
ffffffffc0201cc0:	f04a                	sd	s2,32(sp)
ffffffffc0201cc2:	ec4e                	sd	s3,24(sp)
ffffffffc0201cc4:	e852                	sd	s4,16(sp)
ffffffffc0201cc6:	e456                	sd	s5,8(sp)
ffffffffc0201cc8:	e05a                	sd	s6,0(sp)
ffffffffc0201cca:	fc06                	sd	ra,56(sp)
ffffffffc0201ccc:	f822                	sd	s0,48(sp)
ffffffffc0201cce:	84aa                	mv	s1,a0
ffffffffc0201cd0:	000b1917          	auipc	s2,0xb1
ffffffffc0201cd4:	ac890913          	addi	s2,s2,-1336 # ffffffffc02b2798 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201cd8:	4a05                	li	s4,1
ffffffffc0201cda:	000b1a97          	auipc	s5,0xb1
ffffffffc0201cde:	adea8a93          	addi	s5,s5,-1314 # ffffffffc02b27b8 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0201ce2:	0005099b          	sext.w	s3,a0
ffffffffc0201ce6:	000b1b17          	auipc	s6,0xb1
ffffffffc0201cea:	adab0b13          	addi	s6,s6,-1318 # ffffffffc02b27c0 <check_mm_struct>
ffffffffc0201cee:	a01d                	j	ffffffffc0201d14 <alloc_pages+0x58>
            page = pmm_manager->alloc_pages(n);
ffffffffc0201cf0:	00093783          	ld	a5,0(s2)
ffffffffc0201cf4:	6f9c                	ld	a5,24(a5)
ffffffffc0201cf6:	9782                	jalr	a5
ffffffffc0201cf8:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc0201cfa:	4601                	li	a2,0
ffffffffc0201cfc:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201cfe:	ec0d                	bnez	s0,ffffffffc0201d38 <alloc_pages+0x7c>
ffffffffc0201d00:	029a6c63          	bltu	s4,s1,ffffffffc0201d38 <alloc_pages+0x7c>
ffffffffc0201d04:	000aa783          	lw	a5,0(s5)
ffffffffc0201d08:	2781                	sext.w	a5,a5
ffffffffc0201d0a:	c79d                	beqz	a5,ffffffffc0201d38 <alloc_pages+0x7c>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201d0c:	000b3503          	ld	a0,0(s6)
ffffffffc0201d10:	5a9010ef          	jal	ra,ffffffffc0203ab8 <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201d14:	100027f3          	csrr	a5,sstatus
ffffffffc0201d18:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0201d1a:	8526                	mv	a0,s1
ffffffffc0201d1c:	dbf1                	beqz	a5,ffffffffc0201cf0 <alloc_pages+0x34>
        intr_disable();
ffffffffc0201d1e:	905fe0ef          	jal	ra,ffffffffc0200622 <intr_disable>
ffffffffc0201d22:	00093783          	ld	a5,0(s2)
ffffffffc0201d26:	8526                	mv	a0,s1
ffffffffc0201d28:	6f9c                	ld	a5,24(a5)
ffffffffc0201d2a:	9782                	jalr	a5
ffffffffc0201d2c:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201d2e:	8effe0ef          	jal	ra,ffffffffc020061c <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201d32:	4601                	li	a2,0
ffffffffc0201d34:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201d36:	d469                	beqz	s0,ffffffffc0201d00 <alloc_pages+0x44>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0201d38:	70e2                	ld	ra,56(sp)
ffffffffc0201d3a:	8522                	mv	a0,s0
ffffffffc0201d3c:	7442                	ld	s0,48(sp)
ffffffffc0201d3e:	74a2                	ld	s1,40(sp)
ffffffffc0201d40:	7902                	ld	s2,32(sp)
ffffffffc0201d42:	69e2                	ld	s3,24(sp)
ffffffffc0201d44:	6a42                	ld	s4,16(sp)
ffffffffc0201d46:	6aa2                	ld	s5,8(sp)
ffffffffc0201d48:	6b02                	ld	s6,0(sp)
ffffffffc0201d4a:	6121                	addi	sp,sp,64
ffffffffc0201d4c:	8082                	ret

ffffffffc0201d4e <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201d4e:	100027f3          	csrr	a5,sstatus
ffffffffc0201d52:	8b89                	andi	a5,a5,2
ffffffffc0201d54:	e799                	bnez	a5,ffffffffc0201d62 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201d56:	000b1797          	auipc	a5,0xb1
ffffffffc0201d5a:	a427b783          	ld	a5,-1470(a5) # ffffffffc02b2798 <pmm_manager>
ffffffffc0201d5e:	739c                	ld	a5,32(a5)
ffffffffc0201d60:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0201d62:	1101                	addi	sp,sp,-32
ffffffffc0201d64:	ec06                	sd	ra,24(sp)
ffffffffc0201d66:	e822                	sd	s0,16(sp)
ffffffffc0201d68:	e426                	sd	s1,8(sp)
ffffffffc0201d6a:	842a                	mv	s0,a0
ffffffffc0201d6c:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201d6e:	8b5fe0ef          	jal	ra,ffffffffc0200622 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201d72:	000b1797          	auipc	a5,0xb1
ffffffffc0201d76:	a267b783          	ld	a5,-1498(a5) # ffffffffc02b2798 <pmm_manager>
ffffffffc0201d7a:	739c                	ld	a5,32(a5)
ffffffffc0201d7c:	85a6                	mv	a1,s1
ffffffffc0201d7e:	8522                	mv	a0,s0
ffffffffc0201d80:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201d82:	6442                	ld	s0,16(sp)
ffffffffc0201d84:	60e2                	ld	ra,24(sp)
ffffffffc0201d86:	64a2                	ld	s1,8(sp)
ffffffffc0201d88:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201d8a:	893fe06f          	j	ffffffffc020061c <intr_enable>

ffffffffc0201d8e <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201d8e:	100027f3          	csrr	a5,sstatus
ffffffffc0201d92:	8b89                	andi	a5,a5,2
ffffffffc0201d94:	e799                	bnez	a5,ffffffffc0201da2 <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201d96:	000b1797          	auipc	a5,0xb1
ffffffffc0201d9a:	a027b783          	ld	a5,-1534(a5) # ffffffffc02b2798 <pmm_manager>
ffffffffc0201d9e:	779c                	ld	a5,40(a5)
ffffffffc0201da0:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc0201da2:	1141                	addi	sp,sp,-16
ffffffffc0201da4:	e406                	sd	ra,8(sp)
ffffffffc0201da6:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201da8:	87bfe0ef          	jal	ra,ffffffffc0200622 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201dac:	000b1797          	auipc	a5,0xb1
ffffffffc0201db0:	9ec7b783          	ld	a5,-1556(a5) # ffffffffc02b2798 <pmm_manager>
ffffffffc0201db4:	779c                	ld	a5,40(a5)
ffffffffc0201db6:	9782                	jalr	a5
ffffffffc0201db8:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201dba:	863fe0ef          	jal	ra,ffffffffc020061c <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201dbe:	60a2                	ld	ra,8(sp)
ffffffffc0201dc0:	8522                	mv	a0,s0
ffffffffc0201dc2:	6402                	ld	s0,0(sp)
ffffffffc0201dc4:	0141                	addi	sp,sp,16
ffffffffc0201dc6:	8082                	ret

ffffffffc0201dc8 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201dc8:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0201dcc:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201dd0:	7139                	addi	sp,sp,-64
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201dd2:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201dd4:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201dd6:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201dda:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201ddc:	f04a                	sd	s2,32(sp)
ffffffffc0201dde:	ec4e                	sd	s3,24(sp)
ffffffffc0201de0:	e852                	sd	s4,16(sp)
ffffffffc0201de2:	fc06                	sd	ra,56(sp)
ffffffffc0201de4:	f822                	sd	s0,48(sp)
ffffffffc0201de6:	e456                	sd	s5,8(sp)
ffffffffc0201de8:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201dea:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201dee:	892e                	mv	s2,a1
ffffffffc0201df0:	89b2                	mv	s3,a2
ffffffffc0201df2:	000b1a17          	auipc	s4,0xb1
ffffffffc0201df6:	996a0a13          	addi	s4,s4,-1642 # ffffffffc02b2788 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201dfa:	e7b5                	bnez	a5,ffffffffc0201e66 <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201dfc:	12060b63          	beqz	a2,ffffffffc0201f32 <get_pte+0x16a>
ffffffffc0201e00:	4505                	li	a0,1
ffffffffc0201e02:	ebbff0ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
ffffffffc0201e06:	842a                	mv	s0,a0
ffffffffc0201e08:	12050563          	beqz	a0,ffffffffc0201f32 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0201e0c:	000b1b17          	auipc	s6,0xb1
ffffffffc0201e10:	984b0b13          	addi	s6,s6,-1660 # ffffffffc02b2790 <pages>
ffffffffc0201e14:	000b3503          	ld	a0,0(s6)
ffffffffc0201e18:	00080ab7          	lui	s5,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201e1c:	000b1a17          	auipc	s4,0xb1
ffffffffc0201e20:	96ca0a13          	addi	s4,s4,-1684 # ffffffffc02b2788 <npage>
ffffffffc0201e24:	40a40533          	sub	a0,s0,a0
ffffffffc0201e28:	8519                	srai	a0,a0,0x6
ffffffffc0201e2a:	9556                	add	a0,a0,s5
ffffffffc0201e2c:	000a3703          	ld	a4,0(s4)
ffffffffc0201e30:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0201e34:	4685                	li	a3,1
ffffffffc0201e36:	c014                	sw	a3,0(s0)
ffffffffc0201e38:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201e3a:	0532                	slli	a0,a0,0xc
ffffffffc0201e3c:	14e7f263          	bgeu	a5,a4,ffffffffc0201f80 <get_pte+0x1b8>
ffffffffc0201e40:	000b1797          	auipc	a5,0xb1
ffffffffc0201e44:	9607b783          	ld	a5,-1696(a5) # ffffffffc02b27a0 <va_pa_offset>
ffffffffc0201e48:	6605                	lui	a2,0x1
ffffffffc0201e4a:	4581                	li	a1,0
ffffffffc0201e4c:	953e                	add	a0,a0,a5
ffffffffc0201e4e:	56a040ef          	jal	ra,ffffffffc02063b8 <memset>
    return page - pages + nbase;
ffffffffc0201e52:	000b3683          	ld	a3,0(s6)
ffffffffc0201e56:	40d406b3          	sub	a3,s0,a3
ffffffffc0201e5a:	8699                	srai	a3,a3,0x6
ffffffffc0201e5c:	96d6                	add	a3,a3,s5
  asm volatile("sfence.vma");
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201e5e:	06aa                	slli	a3,a3,0xa
ffffffffc0201e60:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201e64:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201e66:	77fd                	lui	a5,0xfffff
ffffffffc0201e68:	068a                	slli	a3,a3,0x2
ffffffffc0201e6a:	000a3703          	ld	a4,0(s4)
ffffffffc0201e6e:	8efd                	and	a3,a3,a5
ffffffffc0201e70:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201e74:	0ce7f163          	bgeu	a5,a4,ffffffffc0201f36 <get_pte+0x16e>
ffffffffc0201e78:	000b1a97          	auipc	s5,0xb1
ffffffffc0201e7c:	928a8a93          	addi	s5,s5,-1752 # ffffffffc02b27a0 <va_pa_offset>
ffffffffc0201e80:	000ab403          	ld	s0,0(s5)
ffffffffc0201e84:	01595793          	srli	a5,s2,0x15
ffffffffc0201e88:	1ff7f793          	andi	a5,a5,511
ffffffffc0201e8c:	96a2                	add	a3,a3,s0
ffffffffc0201e8e:	00379413          	slli	s0,a5,0x3
ffffffffc0201e92:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc0201e94:	6014                	ld	a3,0(s0)
ffffffffc0201e96:	0016f793          	andi	a5,a3,1
ffffffffc0201e9a:	e3ad                	bnez	a5,ffffffffc0201efc <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201e9c:	08098b63          	beqz	s3,ffffffffc0201f32 <get_pte+0x16a>
ffffffffc0201ea0:	4505                	li	a0,1
ffffffffc0201ea2:	e1bff0ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
ffffffffc0201ea6:	84aa                	mv	s1,a0
ffffffffc0201ea8:	c549                	beqz	a0,ffffffffc0201f32 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0201eaa:	000b1b17          	auipc	s6,0xb1
ffffffffc0201eae:	8e6b0b13          	addi	s6,s6,-1818 # ffffffffc02b2790 <pages>
ffffffffc0201eb2:	000b3503          	ld	a0,0(s6)
ffffffffc0201eb6:	000809b7          	lui	s3,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201eba:	000a3703          	ld	a4,0(s4)
ffffffffc0201ebe:	40a48533          	sub	a0,s1,a0
ffffffffc0201ec2:	8519                	srai	a0,a0,0x6
ffffffffc0201ec4:	954e                	add	a0,a0,s3
ffffffffc0201ec6:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0201eca:	4685                	li	a3,1
ffffffffc0201ecc:	c094                	sw	a3,0(s1)
ffffffffc0201ece:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201ed0:	0532                	slli	a0,a0,0xc
ffffffffc0201ed2:	08e7fa63          	bgeu	a5,a4,ffffffffc0201f66 <get_pte+0x19e>
ffffffffc0201ed6:	000ab783          	ld	a5,0(s5)
ffffffffc0201eda:	6605                	lui	a2,0x1
ffffffffc0201edc:	4581                	li	a1,0
ffffffffc0201ede:	953e                	add	a0,a0,a5
ffffffffc0201ee0:	4d8040ef          	jal	ra,ffffffffc02063b8 <memset>
    return page - pages + nbase;
ffffffffc0201ee4:	000b3683          	ld	a3,0(s6)
ffffffffc0201ee8:	40d486b3          	sub	a3,s1,a3
ffffffffc0201eec:	8699                	srai	a3,a3,0x6
ffffffffc0201eee:	96ce                	add	a3,a3,s3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201ef0:	06aa                	slli	a3,a3,0xa
ffffffffc0201ef2:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201ef6:	e014                	sd	a3,0(s0)
        }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201ef8:	000a3703          	ld	a4,0(s4)
ffffffffc0201efc:	068a                	slli	a3,a3,0x2
ffffffffc0201efe:	757d                	lui	a0,0xfffff
ffffffffc0201f00:	8ee9                	and	a3,a3,a0
ffffffffc0201f02:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201f06:	04e7f463          	bgeu	a5,a4,ffffffffc0201f4e <get_pte+0x186>
ffffffffc0201f0a:	000ab503          	ld	a0,0(s5)
ffffffffc0201f0e:	00c95913          	srli	s2,s2,0xc
ffffffffc0201f12:	1ff97913          	andi	s2,s2,511
ffffffffc0201f16:	96aa                	add	a3,a3,a0
ffffffffc0201f18:	00391513          	slli	a0,s2,0x3
ffffffffc0201f1c:	9536                	add	a0,a0,a3
}
ffffffffc0201f1e:	70e2                	ld	ra,56(sp)
ffffffffc0201f20:	7442                	ld	s0,48(sp)
ffffffffc0201f22:	74a2                	ld	s1,40(sp)
ffffffffc0201f24:	7902                	ld	s2,32(sp)
ffffffffc0201f26:	69e2                	ld	s3,24(sp)
ffffffffc0201f28:	6a42                	ld	s4,16(sp)
ffffffffc0201f2a:	6aa2                	ld	s5,8(sp)
ffffffffc0201f2c:	6b02                	ld	s6,0(sp)
ffffffffc0201f2e:	6121                	addi	sp,sp,64
ffffffffc0201f30:	8082                	ret
            return NULL;
ffffffffc0201f32:	4501                	li	a0,0
ffffffffc0201f34:	b7ed                	j	ffffffffc0201f1e <get_pte+0x156>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201f36:	00005617          	auipc	a2,0x5
ffffffffc0201f3a:	23a60613          	addi	a2,a2,570 # ffffffffc0207170 <default_pmm_manager+0x38>
ffffffffc0201f3e:	0e300593          	li	a1,227
ffffffffc0201f42:	00005517          	auipc	a0,0x5
ffffffffc0201f46:	34650513          	addi	a0,a0,838 # ffffffffc0207288 <default_pmm_manager+0x150>
ffffffffc0201f4a:	d30fe0ef          	jal	ra,ffffffffc020047a <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201f4e:	00005617          	auipc	a2,0x5
ffffffffc0201f52:	22260613          	addi	a2,a2,546 # ffffffffc0207170 <default_pmm_manager+0x38>
ffffffffc0201f56:	0ee00593          	li	a1,238
ffffffffc0201f5a:	00005517          	auipc	a0,0x5
ffffffffc0201f5e:	32e50513          	addi	a0,a0,814 # ffffffffc0207288 <default_pmm_manager+0x150>
ffffffffc0201f62:	d18fe0ef          	jal	ra,ffffffffc020047a <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201f66:	86aa                	mv	a3,a0
ffffffffc0201f68:	00005617          	auipc	a2,0x5
ffffffffc0201f6c:	20860613          	addi	a2,a2,520 # ffffffffc0207170 <default_pmm_manager+0x38>
ffffffffc0201f70:	0eb00593          	li	a1,235
ffffffffc0201f74:	00005517          	auipc	a0,0x5
ffffffffc0201f78:	31450513          	addi	a0,a0,788 # ffffffffc0207288 <default_pmm_manager+0x150>
ffffffffc0201f7c:	cfefe0ef          	jal	ra,ffffffffc020047a <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201f80:	86aa                	mv	a3,a0
ffffffffc0201f82:	00005617          	auipc	a2,0x5
ffffffffc0201f86:	1ee60613          	addi	a2,a2,494 # ffffffffc0207170 <default_pmm_manager+0x38>
ffffffffc0201f8a:	0df00593          	li	a1,223
ffffffffc0201f8e:	00005517          	auipc	a0,0x5
ffffffffc0201f92:	2fa50513          	addi	a0,a0,762 # ffffffffc0207288 <default_pmm_manager+0x150>
ffffffffc0201f96:	ce4fe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0201f9a <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201f9a:	1141                	addi	sp,sp,-16
ffffffffc0201f9c:	e022                	sd	s0,0(sp)
ffffffffc0201f9e:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201fa0:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201fa2:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201fa4:	e25ff0ef          	jal	ra,ffffffffc0201dc8 <get_pte>
    if (ptep_store != NULL) {
ffffffffc0201fa8:	c011                	beqz	s0,ffffffffc0201fac <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0201faa:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201fac:	c511                	beqz	a0,ffffffffc0201fb8 <get_page+0x1e>
ffffffffc0201fae:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0201fb0:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201fb2:	0017f713          	andi	a4,a5,1
ffffffffc0201fb6:	e709                	bnez	a4,ffffffffc0201fc0 <get_page+0x26>
}
ffffffffc0201fb8:	60a2                	ld	ra,8(sp)
ffffffffc0201fba:	6402                	ld	s0,0(sp)
ffffffffc0201fbc:	0141                	addi	sp,sp,16
ffffffffc0201fbe:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0201fc0:	078a                	slli	a5,a5,0x2
ffffffffc0201fc2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201fc4:	000b0717          	auipc	a4,0xb0
ffffffffc0201fc8:	7c473703          	ld	a4,1988(a4) # ffffffffc02b2788 <npage>
ffffffffc0201fcc:	00e7ff63          	bgeu	a5,a4,ffffffffc0201fea <get_page+0x50>
ffffffffc0201fd0:	60a2                	ld	ra,8(sp)
ffffffffc0201fd2:	6402                	ld	s0,0(sp)
    return &pages[PPN(pa) - nbase];
ffffffffc0201fd4:	fff80537          	lui	a0,0xfff80
ffffffffc0201fd8:	97aa                	add	a5,a5,a0
ffffffffc0201fda:	079a                	slli	a5,a5,0x6
ffffffffc0201fdc:	000b0517          	auipc	a0,0xb0
ffffffffc0201fe0:	7b453503          	ld	a0,1972(a0) # ffffffffc02b2790 <pages>
ffffffffc0201fe4:	953e                	add	a0,a0,a5
ffffffffc0201fe6:	0141                	addi	sp,sp,16
ffffffffc0201fe8:	8082                	ret
ffffffffc0201fea:	c9bff0ef          	jal	ra,ffffffffc0201c84 <pa2page.part.0>

ffffffffc0201fee <unmap_range>:
        *ptep = 0;                  //(5) clear second page table entry
        tlb_invalidate(pgdir, la);  //(6) flush tlb
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0201fee:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0201ff0:	00c5e7b3          	or	a5,a1,a2
void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0201ff4:	f486                	sd	ra,104(sp)
ffffffffc0201ff6:	f0a2                	sd	s0,96(sp)
ffffffffc0201ff8:	eca6                	sd	s1,88(sp)
ffffffffc0201ffa:	e8ca                	sd	s2,80(sp)
ffffffffc0201ffc:	e4ce                	sd	s3,72(sp)
ffffffffc0201ffe:	e0d2                	sd	s4,64(sp)
ffffffffc0202000:	fc56                	sd	s5,56(sp)
ffffffffc0202002:	f85a                	sd	s6,48(sp)
ffffffffc0202004:	f45e                	sd	s7,40(sp)
ffffffffc0202006:	f062                	sd	s8,32(sp)
ffffffffc0202008:	ec66                	sd	s9,24(sp)
ffffffffc020200a:	e86a                	sd	s10,16(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020200c:	17d2                	slli	a5,a5,0x34
ffffffffc020200e:	e3ed                	bnez	a5,ffffffffc02020f0 <unmap_range+0x102>
    assert(USER_ACCESS(start, end));
ffffffffc0202010:	002007b7          	lui	a5,0x200
ffffffffc0202014:	842e                	mv	s0,a1
ffffffffc0202016:	0ef5ed63          	bltu	a1,a5,ffffffffc0202110 <unmap_range+0x122>
ffffffffc020201a:	8932                	mv	s2,a2
ffffffffc020201c:	0ec5fa63          	bgeu	a1,a2,ffffffffc0202110 <unmap_range+0x122>
ffffffffc0202020:	4785                	li	a5,1
ffffffffc0202022:	07fe                	slli	a5,a5,0x1f
ffffffffc0202024:	0ec7e663          	bltu	a5,a2,ffffffffc0202110 <unmap_range+0x122>
ffffffffc0202028:	89aa                	mv	s3,a0
            continue;
        }
        if (*ptep != 0) {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc020202a:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc020202c:	000b0c97          	auipc	s9,0xb0
ffffffffc0202030:	75cc8c93          	addi	s9,s9,1884 # ffffffffc02b2788 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202034:	000b0c17          	auipc	s8,0xb0
ffffffffc0202038:	75cc0c13          	addi	s8,s8,1884 # ffffffffc02b2790 <pages>
ffffffffc020203c:	fff80bb7          	lui	s7,0xfff80
        pmm_manager->free_pages(base, n);
ffffffffc0202040:	000b0d17          	auipc	s10,0xb0
ffffffffc0202044:	758d0d13          	addi	s10,s10,1880 # ffffffffc02b2798 <pmm_manager>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0202048:	00200b37          	lui	s6,0x200
ffffffffc020204c:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc0202050:	4601                	li	a2,0
ffffffffc0202052:	85a2                	mv	a1,s0
ffffffffc0202054:	854e                	mv	a0,s3
ffffffffc0202056:	d73ff0ef          	jal	ra,ffffffffc0201dc8 <get_pte>
ffffffffc020205a:	84aa                	mv	s1,a0
        if (ptep == NULL) {
ffffffffc020205c:	cd29                	beqz	a0,ffffffffc02020b6 <unmap_range+0xc8>
        if (*ptep != 0) {
ffffffffc020205e:	611c                	ld	a5,0(a0)
ffffffffc0202060:	e395                	bnez	a5,ffffffffc0202084 <unmap_range+0x96>
        start += PGSIZE;
ffffffffc0202062:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc0202064:	ff2466e3          	bltu	s0,s2,ffffffffc0202050 <unmap_range+0x62>
}
ffffffffc0202068:	70a6                	ld	ra,104(sp)
ffffffffc020206a:	7406                	ld	s0,96(sp)
ffffffffc020206c:	64e6                	ld	s1,88(sp)
ffffffffc020206e:	6946                	ld	s2,80(sp)
ffffffffc0202070:	69a6                	ld	s3,72(sp)
ffffffffc0202072:	6a06                	ld	s4,64(sp)
ffffffffc0202074:	7ae2                	ld	s5,56(sp)
ffffffffc0202076:	7b42                	ld	s6,48(sp)
ffffffffc0202078:	7ba2                	ld	s7,40(sp)
ffffffffc020207a:	7c02                	ld	s8,32(sp)
ffffffffc020207c:	6ce2                	ld	s9,24(sp)
ffffffffc020207e:	6d42                	ld	s10,16(sp)
ffffffffc0202080:	6165                	addi	sp,sp,112
ffffffffc0202082:	8082                	ret
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0202084:	0017f713          	andi	a4,a5,1
ffffffffc0202088:	df69                	beqz	a4,ffffffffc0202062 <unmap_range+0x74>
    if (PPN(pa) >= npage) {
ffffffffc020208a:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc020208e:	078a                	slli	a5,a5,0x2
ffffffffc0202090:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202092:	08e7ff63          	bgeu	a5,a4,ffffffffc0202130 <unmap_range+0x142>
    return &pages[PPN(pa) - nbase];
ffffffffc0202096:	000c3503          	ld	a0,0(s8)
ffffffffc020209a:	97de                	add	a5,a5,s7
ffffffffc020209c:	079a                	slli	a5,a5,0x6
ffffffffc020209e:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc02020a0:	411c                	lw	a5,0(a0)
ffffffffc02020a2:	fff7871b          	addiw	a4,a5,-1
ffffffffc02020a6:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc02020a8:	cf11                	beqz	a4,ffffffffc02020c4 <unmap_range+0xd6>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc02020aa:	0004b023          	sd	zero,0(s1)
}

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02020ae:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc02020b2:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc02020b4:	bf45                	j	ffffffffc0202064 <unmap_range+0x76>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02020b6:	945a                	add	s0,s0,s6
ffffffffc02020b8:	01547433          	and	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc02020bc:	d455                	beqz	s0,ffffffffc0202068 <unmap_range+0x7a>
ffffffffc02020be:	f92469e3          	bltu	s0,s2,ffffffffc0202050 <unmap_range+0x62>
ffffffffc02020c2:	b75d                	j	ffffffffc0202068 <unmap_range+0x7a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02020c4:	100027f3          	csrr	a5,sstatus
ffffffffc02020c8:	8b89                	andi	a5,a5,2
ffffffffc02020ca:	e799                	bnez	a5,ffffffffc02020d8 <unmap_range+0xea>
        pmm_manager->free_pages(base, n);
ffffffffc02020cc:	000d3783          	ld	a5,0(s10)
ffffffffc02020d0:	4585                	li	a1,1
ffffffffc02020d2:	739c                	ld	a5,32(a5)
ffffffffc02020d4:	9782                	jalr	a5
    if (flag) {
ffffffffc02020d6:	bfd1                	j	ffffffffc02020aa <unmap_range+0xbc>
ffffffffc02020d8:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02020da:	d48fe0ef          	jal	ra,ffffffffc0200622 <intr_disable>
ffffffffc02020de:	000d3783          	ld	a5,0(s10)
ffffffffc02020e2:	6522                	ld	a0,8(sp)
ffffffffc02020e4:	4585                	li	a1,1
ffffffffc02020e6:	739c                	ld	a5,32(a5)
ffffffffc02020e8:	9782                	jalr	a5
        intr_enable();
ffffffffc02020ea:	d32fe0ef          	jal	ra,ffffffffc020061c <intr_enable>
ffffffffc02020ee:	bf75                	j	ffffffffc02020aa <unmap_range+0xbc>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02020f0:	00005697          	auipc	a3,0x5
ffffffffc02020f4:	1a868693          	addi	a3,a3,424 # ffffffffc0207298 <default_pmm_manager+0x160>
ffffffffc02020f8:	00005617          	auipc	a2,0x5
ffffffffc02020fc:	9a860613          	addi	a2,a2,-1624 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0202100:	10f00593          	li	a1,271
ffffffffc0202104:	00005517          	auipc	a0,0x5
ffffffffc0202108:	18450513          	addi	a0,a0,388 # ffffffffc0207288 <default_pmm_manager+0x150>
ffffffffc020210c:	b6efe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0202110:	00005697          	auipc	a3,0x5
ffffffffc0202114:	1b868693          	addi	a3,a3,440 # ffffffffc02072c8 <default_pmm_manager+0x190>
ffffffffc0202118:	00005617          	auipc	a2,0x5
ffffffffc020211c:	98860613          	addi	a2,a2,-1656 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0202120:	11000593          	li	a1,272
ffffffffc0202124:	00005517          	auipc	a0,0x5
ffffffffc0202128:	16450513          	addi	a0,a0,356 # ffffffffc0207288 <default_pmm_manager+0x150>
ffffffffc020212c:	b4efe0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc0202130:	b55ff0ef          	jal	ra,ffffffffc0201c84 <pa2page.part.0>

ffffffffc0202134 <exit_range>:
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0202134:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202136:	00c5e7b3          	or	a5,a1,a2
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc020213a:	fc86                	sd	ra,120(sp)
ffffffffc020213c:	f8a2                	sd	s0,112(sp)
ffffffffc020213e:	f4a6                	sd	s1,104(sp)
ffffffffc0202140:	f0ca                	sd	s2,96(sp)
ffffffffc0202142:	ecce                	sd	s3,88(sp)
ffffffffc0202144:	e8d2                	sd	s4,80(sp)
ffffffffc0202146:	e4d6                	sd	s5,72(sp)
ffffffffc0202148:	e0da                	sd	s6,64(sp)
ffffffffc020214a:	fc5e                	sd	s7,56(sp)
ffffffffc020214c:	f862                	sd	s8,48(sp)
ffffffffc020214e:	f466                	sd	s9,40(sp)
ffffffffc0202150:	f06a                	sd	s10,32(sp)
ffffffffc0202152:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202154:	17d2                	slli	a5,a5,0x34
ffffffffc0202156:	20079a63          	bnez	a5,ffffffffc020236a <exit_range+0x236>
    assert(USER_ACCESS(start, end));
ffffffffc020215a:	002007b7          	lui	a5,0x200
ffffffffc020215e:	24f5e463          	bltu	a1,a5,ffffffffc02023a6 <exit_range+0x272>
ffffffffc0202162:	8ab2                	mv	s5,a2
ffffffffc0202164:	24c5f163          	bgeu	a1,a2,ffffffffc02023a6 <exit_range+0x272>
ffffffffc0202168:	4785                	li	a5,1
ffffffffc020216a:	07fe                	slli	a5,a5,0x1f
ffffffffc020216c:	22c7ed63          	bltu	a5,a2,ffffffffc02023a6 <exit_range+0x272>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc0202170:	c00009b7          	lui	s3,0xc0000
ffffffffc0202174:	0135f9b3          	and	s3,a1,s3
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc0202178:	ffe00937          	lui	s2,0xffe00
ffffffffc020217c:	400007b7          	lui	a5,0x40000
    return KADDR(page2pa(page));
ffffffffc0202180:	5cfd                	li	s9,-1
ffffffffc0202182:	8c2a                	mv	s8,a0
ffffffffc0202184:	0125f933          	and	s2,a1,s2
ffffffffc0202188:	99be                	add	s3,s3,a5
    if (PPN(pa) >= npage) {
ffffffffc020218a:	000b0d17          	auipc	s10,0xb0
ffffffffc020218e:	5fed0d13          	addi	s10,s10,1534 # ffffffffc02b2788 <npage>
    return KADDR(page2pa(page));
ffffffffc0202192:	00ccdc93          	srli	s9,s9,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc0202196:	000b0717          	auipc	a4,0xb0
ffffffffc020219a:	5fa70713          	addi	a4,a4,1530 # ffffffffc02b2790 <pages>
        pmm_manager->free_pages(base, n);
ffffffffc020219e:	000b0d97          	auipc	s11,0xb0
ffffffffc02021a2:	5fad8d93          	addi	s11,s11,1530 # ffffffffc02b2798 <pmm_manager>
        pde1 = pgdir[PDX1(d1start)];
ffffffffc02021a6:	c0000437          	lui	s0,0xc0000
ffffffffc02021aa:	944e                	add	s0,s0,s3
ffffffffc02021ac:	8079                	srli	s0,s0,0x1e
ffffffffc02021ae:	1ff47413          	andi	s0,s0,511
ffffffffc02021b2:	040e                	slli	s0,s0,0x3
ffffffffc02021b4:	9462                	add	s0,s0,s8
ffffffffc02021b6:	00043a03          	ld	s4,0(s0) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff4ee0>
        if (pde1&PTE_V){
ffffffffc02021ba:	001a7793          	andi	a5,s4,1
ffffffffc02021be:	eb99                	bnez	a5,ffffffffc02021d4 <exit_range+0xa0>
    } while (d1start != 0 && d1start < end);
ffffffffc02021c0:	12098463          	beqz	s3,ffffffffc02022e8 <exit_range+0x1b4>
ffffffffc02021c4:	400007b7          	lui	a5,0x40000
ffffffffc02021c8:	97ce                	add	a5,a5,s3
ffffffffc02021ca:	894e                	mv	s2,s3
ffffffffc02021cc:	1159fe63          	bgeu	s3,s5,ffffffffc02022e8 <exit_range+0x1b4>
ffffffffc02021d0:	89be                	mv	s3,a5
ffffffffc02021d2:	bfd1                	j	ffffffffc02021a6 <exit_range+0x72>
    if (PPN(pa) >= npage) {
ffffffffc02021d4:	000d3783          	ld	a5,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc02021d8:	0a0a                	slli	s4,s4,0x2
ffffffffc02021da:	00ca5a13          	srli	s4,s4,0xc
    if (PPN(pa) >= npage) {
ffffffffc02021de:	1cfa7263          	bgeu	s4,a5,ffffffffc02023a2 <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc02021e2:	fff80637          	lui	a2,0xfff80
ffffffffc02021e6:	9652                	add	a2,a2,s4
    return page - pages + nbase;
ffffffffc02021e8:	000806b7          	lui	a3,0x80
ffffffffc02021ec:	96b2                	add	a3,a3,a2
    return KADDR(page2pa(page));
ffffffffc02021ee:	0196f5b3          	and	a1,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc02021f2:	061a                	slli	a2,a2,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc02021f4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02021f6:	18f5fa63          	bgeu	a1,a5,ffffffffc020238a <exit_range+0x256>
ffffffffc02021fa:	000b0817          	auipc	a6,0xb0
ffffffffc02021fe:	5a680813          	addi	a6,a6,1446 # ffffffffc02b27a0 <va_pa_offset>
ffffffffc0202202:	00083b03          	ld	s6,0(a6)
            free_pd0 = 1;
ffffffffc0202206:	4b85                	li	s7,1
    return &pages[PPN(pa) - nbase];
ffffffffc0202208:	fff80e37          	lui	t3,0xfff80
    return KADDR(page2pa(page));
ffffffffc020220c:	9b36                	add	s6,s6,a3
    return page - pages + nbase;
ffffffffc020220e:	00080337          	lui	t1,0x80
ffffffffc0202212:	6885                	lui	a7,0x1
ffffffffc0202214:	a819                	j	ffffffffc020222a <exit_range+0xf6>
                    free_pd0 = 0;
ffffffffc0202216:	4b81                	li	s7,0
                d0start += PTSIZE;
ffffffffc0202218:	002007b7          	lui	a5,0x200
ffffffffc020221c:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc020221e:	08090c63          	beqz	s2,ffffffffc02022b6 <exit_range+0x182>
ffffffffc0202222:	09397a63          	bgeu	s2,s3,ffffffffc02022b6 <exit_range+0x182>
ffffffffc0202226:	0f597063          	bgeu	s2,s5,ffffffffc0202306 <exit_range+0x1d2>
                pde0 = pd0[PDX0(d0start)];
ffffffffc020222a:	01595493          	srli	s1,s2,0x15
ffffffffc020222e:	1ff4f493          	andi	s1,s1,511
ffffffffc0202232:	048e                	slli	s1,s1,0x3
ffffffffc0202234:	94da                	add	s1,s1,s6
ffffffffc0202236:	609c                	ld	a5,0(s1)
                if (pde0&PTE_V) {
ffffffffc0202238:	0017f693          	andi	a3,a5,1
ffffffffc020223c:	dee9                	beqz	a3,ffffffffc0202216 <exit_range+0xe2>
    if (PPN(pa) >= npage) {
ffffffffc020223e:	000d3583          	ld	a1,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202242:	078a                	slli	a5,a5,0x2
ffffffffc0202244:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202246:	14b7fe63          	bgeu	a5,a1,ffffffffc02023a2 <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc020224a:	97f2                	add	a5,a5,t3
    return page - pages + nbase;
ffffffffc020224c:	006786b3          	add	a3,a5,t1
    return KADDR(page2pa(page));
ffffffffc0202250:	0196feb3          	and	t4,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc0202254:	00679513          	slli	a0,a5,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202258:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020225a:	12bef863          	bgeu	t4,a1,ffffffffc020238a <exit_range+0x256>
ffffffffc020225e:	00083783          	ld	a5,0(a6)
ffffffffc0202262:	96be                	add	a3,a3,a5
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc0202264:	011685b3          	add	a1,a3,a7
                        if (pt[i]&PTE_V){
ffffffffc0202268:	629c                	ld	a5,0(a3)
ffffffffc020226a:	8b85                	andi	a5,a5,1
ffffffffc020226c:	f7d5                	bnez	a5,ffffffffc0202218 <exit_range+0xe4>
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc020226e:	06a1                	addi	a3,a3,8
ffffffffc0202270:	fed59ce3          	bne	a1,a3,ffffffffc0202268 <exit_range+0x134>
    return &pages[PPN(pa) - nbase];
ffffffffc0202274:	631c                	ld	a5,0(a4)
ffffffffc0202276:	953e                	add	a0,a0,a5
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202278:	100027f3          	csrr	a5,sstatus
ffffffffc020227c:	8b89                	andi	a5,a5,2
ffffffffc020227e:	e7d9                	bnez	a5,ffffffffc020230c <exit_range+0x1d8>
        pmm_manager->free_pages(base, n);
ffffffffc0202280:	000db783          	ld	a5,0(s11)
ffffffffc0202284:	4585                	li	a1,1
ffffffffc0202286:	e032                	sd	a2,0(sp)
ffffffffc0202288:	739c                	ld	a5,32(a5)
ffffffffc020228a:	9782                	jalr	a5
    if (flag) {
ffffffffc020228c:	6602                	ld	a2,0(sp)
ffffffffc020228e:	000b0817          	auipc	a6,0xb0
ffffffffc0202292:	51280813          	addi	a6,a6,1298 # ffffffffc02b27a0 <va_pa_offset>
ffffffffc0202296:	fff80e37          	lui	t3,0xfff80
ffffffffc020229a:	00080337          	lui	t1,0x80
ffffffffc020229e:	6885                	lui	a7,0x1
ffffffffc02022a0:	000b0717          	auipc	a4,0xb0
ffffffffc02022a4:	4f070713          	addi	a4,a4,1264 # ffffffffc02b2790 <pages>
                        pd0[PDX0(d0start)] = 0;
ffffffffc02022a8:	0004b023          	sd	zero,0(s1)
                d0start += PTSIZE;
ffffffffc02022ac:	002007b7          	lui	a5,0x200
ffffffffc02022b0:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc02022b2:	f60918e3          	bnez	s2,ffffffffc0202222 <exit_range+0xee>
            if (free_pd0) {
ffffffffc02022b6:	f00b85e3          	beqz	s7,ffffffffc02021c0 <exit_range+0x8c>
    if (PPN(pa) >= npage) {
ffffffffc02022ba:	000d3783          	ld	a5,0(s10)
ffffffffc02022be:	0efa7263          	bgeu	s4,a5,ffffffffc02023a2 <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc02022c2:	6308                	ld	a0,0(a4)
ffffffffc02022c4:	9532                	add	a0,a0,a2
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02022c6:	100027f3          	csrr	a5,sstatus
ffffffffc02022ca:	8b89                	andi	a5,a5,2
ffffffffc02022cc:	efad                	bnez	a5,ffffffffc0202346 <exit_range+0x212>
        pmm_manager->free_pages(base, n);
ffffffffc02022ce:	000db783          	ld	a5,0(s11)
ffffffffc02022d2:	4585                	li	a1,1
ffffffffc02022d4:	739c                	ld	a5,32(a5)
ffffffffc02022d6:	9782                	jalr	a5
ffffffffc02022d8:	000b0717          	auipc	a4,0xb0
ffffffffc02022dc:	4b870713          	addi	a4,a4,1208 # ffffffffc02b2790 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc02022e0:	00043023          	sd	zero,0(s0)
    } while (d1start != 0 && d1start < end);
ffffffffc02022e4:	ee0990e3          	bnez	s3,ffffffffc02021c4 <exit_range+0x90>
}
ffffffffc02022e8:	70e6                	ld	ra,120(sp)
ffffffffc02022ea:	7446                	ld	s0,112(sp)
ffffffffc02022ec:	74a6                	ld	s1,104(sp)
ffffffffc02022ee:	7906                	ld	s2,96(sp)
ffffffffc02022f0:	69e6                	ld	s3,88(sp)
ffffffffc02022f2:	6a46                	ld	s4,80(sp)
ffffffffc02022f4:	6aa6                	ld	s5,72(sp)
ffffffffc02022f6:	6b06                	ld	s6,64(sp)
ffffffffc02022f8:	7be2                	ld	s7,56(sp)
ffffffffc02022fa:	7c42                	ld	s8,48(sp)
ffffffffc02022fc:	7ca2                	ld	s9,40(sp)
ffffffffc02022fe:	7d02                	ld	s10,32(sp)
ffffffffc0202300:	6de2                	ld	s11,24(sp)
ffffffffc0202302:	6109                	addi	sp,sp,128
ffffffffc0202304:	8082                	ret
            if (free_pd0) {
ffffffffc0202306:	ea0b8fe3          	beqz	s7,ffffffffc02021c4 <exit_range+0x90>
ffffffffc020230a:	bf45                	j	ffffffffc02022ba <exit_range+0x186>
ffffffffc020230c:	e032                	sd	a2,0(sp)
        intr_disable();
ffffffffc020230e:	e42a                	sd	a0,8(sp)
ffffffffc0202310:	b12fe0ef          	jal	ra,ffffffffc0200622 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202314:	000db783          	ld	a5,0(s11)
ffffffffc0202318:	6522                	ld	a0,8(sp)
ffffffffc020231a:	4585                	li	a1,1
ffffffffc020231c:	739c                	ld	a5,32(a5)
ffffffffc020231e:	9782                	jalr	a5
        intr_enable();
ffffffffc0202320:	afcfe0ef          	jal	ra,ffffffffc020061c <intr_enable>
ffffffffc0202324:	6602                	ld	a2,0(sp)
ffffffffc0202326:	000b0717          	auipc	a4,0xb0
ffffffffc020232a:	46a70713          	addi	a4,a4,1130 # ffffffffc02b2790 <pages>
ffffffffc020232e:	6885                	lui	a7,0x1
ffffffffc0202330:	00080337          	lui	t1,0x80
ffffffffc0202334:	fff80e37          	lui	t3,0xfff80
ffffffffc0202338:	000b0817          	auipc	a6,0xb0
ffffffffc020233c:	46880813          	addi	a6,a6,1128 # ffffffffc02b27a0 <va_pa_offset>
                        pd0[PDX0(d0start)] = 0;
ffffffffc0202340:	0004b023          	sd	zero,0(s1)
ffffffffc0202344:	b7a5                	j	ffffffffc02022ac <exit_range+0x178>
ffffffffc0202346:	e02a                	sd	a0,0(sp)
        intr_disable();
ffffffffc0202348:	adafe0ef          	jal	ra,ffffffffc0200622 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020234c:	000db783          	ld	a5,0(s11)
ffffffffc0202350:	6502                	ld	a0,0(sp)
ffffffffc0202352:	4585                	li	a1,1
ffffffffc0202354:	739c                	ld	a5,32(a5)
ffffffffc0202356:	9782                	jalr	a5
        intr_enable();
ffffffffc0202358:	ac4fe0ef          	jal	ra,ffffffffc020061c <intr_enable>
ffffffffc020235c:	000b0717          	auipc	a4,0xb0
ffffffffc0202360:	43470713          	addi	a4,a4,1076 # ffffffffc02b2790 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc0202364:	00043023          	sd	zero,0(s0)
ffffffffc0202368:	bfb5                	j	ffffffffc02022e4 <exit_range+0x1b0>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020236a:	00005697          	auipc	a3,0x5
ffffffffc020236e:	f2e68693          	addi	a3,a3,-210 # ffffffffc0207298 <default_pmm_manager+0x160>
ffffffffc0202372:	00004617          	auipc	a2,0x4
ffffffffc0202376:	72e60613          	addi	a2,a2,1838 # ffffffffc0206aa0 <commands+0x450>
ffffffffc020237a:	12000593          	li	a1,288
ffffffffc020237e:	00005517          	auipc	a0,0x5
ffffffffc0202382:	f0a50513          	addi	a0,a0,-246 # ffffffffc0207288 <default_pmm_manager+0x150>
ffffffffc0202386:	8f4fe0ef          	jal	ra,ffffffffc020047a <__panic>
    return KADDR(page2pa(page));
ffffffffc020238a:	00005617          	auipc	a2,0x5
ffffffffc020238e:	de660613          	addi	a2,a2,-538 # ffffffffc0207170 <default_pmm_manager+0x38>
ffffffffc0202392:	06900593          	li	a1,105
ffffffffc0202396:	00005517          	auipc	a0,0x5
ffffffffc020239a:	e0250513          	addi	a0,a0,-510 # ffffffffc0207198 <default_pmm_manager+0x60>
ffffffffc020239e:	8dcfe0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc02023a2:	8e3ff0ef          	jal	ra,ffffffffc0201c84 <pa2page.part.0>
    assert(USER_ACCESS(start, end));
ffffffffc02023a6:	00005697          	auipc	a3,0x5
ffffffffc02023aa:	f2268693          	addi	a3,a3,-222 # ffffffffc02072c8 <default_pmm_manager+0x190>
ffffffffc02023ae:	00004617          	auipc	a2,0x4
ffffffffc02023b2:	6f260613          	addi	a2,a2,1778 # ffffffffc0206aa0 <commands+0x450>
ffffffffc02023b6:	12100593          	li	a1,289
ffffffffc02023ba:	00005517          	auipc	a0,0x5
ffffffffc02023be:	ece50513          	addi	a0,a0,-306 # ffffffffc0207288 <default_pmm_manager+0x150>
ffffffffc02023c2:	8b8fe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02023c6 <copy_range>:
               bool share) {
ffffffffc02023c6:	711d                	addi	sp,sp,-96
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02023c8:	00d667b3          	or	a5,a2,a3
               bool share) {
ffffffffc02023cc:	ec86                	sd	ra,88(sp)
ffffffffc02023ce:	e8a2                	sd	s0,80(sp)
ffffffffc02023d0:	e4a6                	sd	s1,72(sp)
ffffffffc02023d2:	e0ca                	sd	s2,64(sp)
ffffffffc02023d4:	fc4e                	sd	s3,56(sp)
ffffffffc02023d6:	f852                	sd	s4,48(sp)
ffffffffc02023d8:	f456                	sd	s5,40(sp)
ffffffffc02023da:	f05a                	sd	s6,32(sp)
ffffffffc02023dc:	ec5e                	sd	s7,24(sp)
ffffffffc02023de:	e862                	sd	s8,16(sp)
ffffffffc02023e0:	e466                	sd	s9,8(sp)
ffffffffc02023e2:	e06a                	sd	s10,0(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02023e4:	17d2                	slli	a5,a5,0x34
ffffffffc02023e6:	14079663          	bnez	a5,ffffffffc0202532 <copy_range+0x16c>
    assert(USER_ACCESS(start, end));
ffffffffc02023ea:	002007b7          	lui	a5,0x200
ffffffffc02023ee:	84b2                	mv	s1,a2
ffffffffc02023f0:	10f66563          	bltu	a2,a5,ffffffffc02024fa <copy_range+0x134>
ffffffffc02023f4:	8936                	mv	s2,a3
ffffffffc02023f6:	10d67263          	bgeu	a2,a3,ffffffffc02024fa <copy_range+0x134>
ffffffffc02023fa:	4785                	li	a5,1
ffffffffc02023fc:	07fe                	slli	a5,a5,0x1f
ffffffffc02023fe:	0ed7ee63          	bltu	a5,a3,ffffffffc02024fa <copy_range+0x134>
ffffffffc0202402:	8aaa                	mv	s5,a0
ffffffffc0202404:	89ae                	mv	s3,a1
        start += PGSIZE;
ffffffffc0202406:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc0202408:	000b0c17          	auipc	s8,0xb0
ffffffffc020240c:	380c0c13          	addi	s8,s8,896 # ffffffffc02b2788 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202410:	000b0b97          	auipc	s7,0xb0
ffffffffc0202414:	380b8b93          	addi	s7,s7,896 # ffffffffc02b2790 <pages>
ffffffffc0202418:	fff80b37          	lui	s6,0xfff80
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc020241c:	00200d37          	lui	s10,0x200
ffffffffc0202420:	ffe00cb7          	lui	s9,0xffe00
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc0202424:	4601                	li	a2,0
ffffffffc0202426:	85a6                	mv	a1,s1
ffffffffc0202428:	854e                	mv	a0,s3
ffffffffc020242a:	99fff0ef          	jal	ra,ffffffffc0201dc8 <get_pte>
ffffffffc020242e:	842a                	mv	s0,a0
        if (ptep == NULL) {
ffffffffc0202430:	c141                	beqz	a0,ffffffffc02024b0 <copy_range+0xea>
        if (*ptep & PTE_V) {
ffffffffc0202432:	611c                	ld	a5,0(a0)
ffffffffc0202434:	8b85                	andi	a5,a5,1
ffffffffc0202436:	e39d                	bnez	a5,ffffffffc020245c <copy_range+0x96>
        start += PGSIZE;
ffffffffc0202438:	94d2                	add	s1,s1,s4
    } while (start != 0 && start < end);
ffffffffc020243a:	ff24e5e3          	bltu	s1,s2,ffffffffc0202424 <copy_range+0x5e>
    return 0;
ffffffffc020243e:	4501                	li	a0,0
}
ffffffffc0202440:	60e6                	ld	ra,88(sp)
ffffffffc0202442:	6446                	ld	s0,80(sp)
ffffffffc0202444:	64a6                	ld	s1,72(sp)
ffffffffc0202446:	6906                	ld	s2,64(sp)
ffffffffc0202448:	79e2                	ld	s3,56(sp)
ffffffffc020244a:	7a42                	ld	s4,48(sp)
ffffffffc020244c:	7aa2                	ld	s5,40(sp)
ffffffffc020244e:	7b02                	ld	s6,32(sp)
ffffffffc0202450:	6be2                	ld	s7,24(sp)
ffffffffc0202452:	6c42                	ld	s8,16(sp)
ffffffffc0202454:	6ca2                	ld	s9,8(sp)
ffffffffc0202456:	6d02                	ld	s10,0(sp)
ffffffffc0202458:	6125                	addi	sp,sp,96
ffffffffc020245a:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL) {
ffffffffc020245c:	4605                	li	a2,1
ffffffffc020245e:	85a6                	mv	a1,s1
ffffffffc0202460:	8556                	mv	a0,s5
ffffffffc0202462:	967ff0ef          	jal	ra,ffffffffc0201dc8 <get_pte>
ffffffffc0202466:	cd21                	beqz	a0,ffffffffc02024be <copy_range+0xf8>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc0202468:	601c                	ld	a5,0(s0)
    if (!(pte & PTE_V)) {
ffffffffc020246a:	0017f713          	andi	a4,a5,1
ffffffffc020246e:	c755                	beqz	a4,ffffffffc020251a <copy_range+0x154>
    if (PPN(pa) >= npage) {
ffffffffc0202470:	000c3703          	ld	a4,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202474:	078a                	slli	a5,a5,0x2
ffffffffc0202476:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202478:	06e7f563          	bgeu	a5,a4,ffffffffc02024e2 <copy_range+0x11c>
    return &pages[PPN(pa) - nbase];
ffffffffc020247c:	000bb403          	ld	s0,0(s7)
ffffffffc0202480:	97da                	add	a5,a5,s6
ffffffffc0202482:	079a                	slli	a5,a5,0x6
ffffffffc0202484:	943e                	add	s0,s0,a5
            struct Page *npage = alloc_page();
ffffffffc0202486:	4505                	li	a0,1
ffffffffc0202488:	835ff0ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
            assert(page != NULL);
ffffffffc020248c:	c81d                	beqz	s0,ffffffffc02024c2 <copy_range+0xfc>
            assert(npage != NULL);
ffffffffc020248e:	f54d                	bnez	a0,ffffffffc0202438 <copy_range+0x72>
ffffffffc0202490:	00005697          	auipc	a3,0x5
ffffffffc0202494:	e6068693          	addi	a3,a3,-416 # ffffffffc02072f0 <default_pmm_manager+0x1b8>
ffffffffc0202498:	00004617          	auipc	a2,0x4
ffffffffc020249c:	60860613          	addi	a2,a2,1544 # ffffffffc0206aa0 <commands+0x450>
ffffffffc02024a0:	17300593          	li	a1,371
ffffffffc02024a4:	00005517          	auipc	a0,0x5
ffffffffc02024a8:	de450513          	addi	a0,a0,-540 # ffffffffc0207288 <default_pmm_manager+0x150>
ffffffffc02024ac:	fcffd0ef          	jal	ra,ffffffffc020047a <__panic>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02024b0:	94ea                	add	s1,s1,s10
ffffffffc02024b2:	0194f4b3          	and	s1,s1,s9
    } while (start != 0 && start < end);
ffffffffc02024b6:	d4c1                	beqz	s1,ffffffffc020243e <copy_range+0x78>
ffffffffc02024b8:	f724e6e3          	bltu	s1,s2,ffffffffc0202424 <copy_range+0x5e>
ffffffffc02024bc:	b749                	j	ffffffffc020243e <copy_range+0x78>
                return -E_NO_MEM;
ffffffffc02024be:	5571                	li	a0,-4
ffffffffc02024c0:	b741                	j	ffffffffc0202440 <copy_range+0x7a>
            assert(page != NULL);
ffffffffc02024c2:	00005697          	auipc	a3,0x5
ffffffffc02024c6:	e1e68693          	addi	a3,a3,-482 # ffffffffc02072e0 <default_pmm_manager+0x1a8>
ffffffffc02024ca:	00004617          	auipc	a2,0x4
ffffffffc02024ce:	5d660613          	addi	a2,a2,1494 # ffffffffc0206aa0 <commands+0x450>
ffffffffc02024d2:	17200593          	li	a1,370
ffffffffc02024d6:	00005517          	auipc	a0,0x5
ffffffffc02024da:	db250513          	addi	a0,a0,-590 # ffffffffc0207288 <default_pmm_manager+0x150>
ffffffffc02024de:	f9dfd0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02024e2:	00005617          	auipc	a2,0x5
ffffffffc02024e6:	d5e60613          	addi	a2,a2,-674 # ffffffffc0207240 <default_pmm_manager+0x108>
ffffffffc02024ea:	06200593          	li	a1,98
ffffffffc02024ee:	00005517          	auipc	a0,0x5
ffffffffc02024f2:	caa50513          	addi	a0,a0,-854 # ffffffffc0207198 <default_pmm_manager+0x60>
ffffffffc02024f6:	f85fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc02024fa:	00005697          	auipc	a3,0x5
ffffffffc02024fe:	dce68693          	addi	a3,a3,-562 # ffffffffc02072c8 <default_pmm_manager+0x190>
ffffffffc0202502:	00004617          	auipc	a2,0x4
ffffffffc0202506:	59e60613          	addi	a2,a2,1438 # ffffffffc0206aa0 <commands+0x450>
ffffffffc020250a:	15e00593          	li	a1,350
ffffffffc020250e:	00005517          	auipc	a0,0x5
ffffffffc0202512:	d7a50513          	addi	a0,a0,-646 # ffffffffc0207288 <default_pmm_manager+0x150>
ffffffffc0202516:	f65fd0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("pte2page called with invalid pte");
ffffffffc020251a:	00005617          	auipc	a2,0x5
ffffffffc020251e:	d4660613          	addi	a2,a2,-698 # ffffffffc0207260 <default_pmm_manager+0x128>
ffffffffc0202522:	07400593          	li	a1,116
ffffffffc0202526:	00005517          	auipc	a0,0x5
ffffffffc020252a:	c7250513          	addi	a0,a0,-910 # ffffffffc0207198 <default_pmm_manager+0x60>
ffffffffc020252e:	f4dfd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202532:	00005697          	auipc	a3,0x5
ffffffffc0202536:	d6668693          	addi	a3,a3,-666 # ffffffffc0207298 <default_pmm_manager+0x160>
ffffffffc020253a:	00004617          	auipc	a2,0x4
ffffffffc020253e:	56660613          	addi	a2,a2,1382 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0202542:	15d00593          	li	a1,349
ffffffffc0202546:	00005517          	auipc	a0,0x5
ffffffffc020254a:	d4250513          	addi	a0,a0,-702 # ffffffffc0207288 <default_pmm_manager+0x150>
ffffffffc020254e:	f2dfd0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0202552 <page_remove>:
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0202552:	7179                	addi	sp,sp,-48
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202554:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0202556:	ec26                	sd	s1,24(sp)
ffffffffc0202558:	f406                	sd	ra,40(sp)
ffffffffc020255a:	f022                	sd	s0,32(sp)
ffffffffc020255c:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020255e:	86bff0ef          	jal	ra,ffffffffc0201dc8 <get_pte>
    if (ptep != NULL) {
ffffffffc0202562:	c511                	beqz	a0,ffffffffc020256e <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0202564:	611c                	ld	a5,0(a0)
ffffffffc0202566:	842a                	mv	s0,a0
ffffffffc0202568:	0017f713          	andi	a4,a5,1
ffffffffc020256c:	e711                	bnez	a4,ffffffffc0202578 <page_remove+0x26>
}
ffffffffc020256e:	70a2                	ld	ra,40(sp)
ffffffffc0202570:	7402                	ld	s0,32(sp)
ffffffffc0202572:	64e2                	ld	s1,24(sp)
ffffffffc0202574:	6145                	addi	sp,sp,48
ffffffffc0202576:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202578:	078a                	slli	a5,a5,0x2
ffffffffc020257a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020257c:	000b0717          	auipc	a4,0xb0
ffffffffc0202580:	20c73703          	ld	a4,524(a4) # ffffffffc02b2788 <npage>
ffffffffc0202584:	06e7f363          	bgeu	a5,a4,ffffffffc02025ea <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc0202588:	fff80537          	lui	a0,0xfff80
ffffffffc020258c:	97aa                	add	a5,a5,a0
ffffffffc020258e:	079a                	slli	a5,a5,0x6
ffffffffc0202590:	000b0517          	auipc	a0,0xb0
ffffffffc0202594:	20053503          	ld	a0,512(a0) # ffffffffc02b2790 <pages>
ffffffffc0202598:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc020259a:	411c                	lw	a5,0(a0)
ffffffffc020259c:	fff7871b          	addiw	a4,a5,-1
ffffffffc02025a0:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc02025a2:	cb11                	beqz	a4,ffffffffc02025b6 <page_remove+0x64>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc02025a4:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02025a8:	12048073          	sfence.vma	s1
}
ffffffffc02025ac:	70a2                	ld	ra,40(sp)
ffffffffc02025ae:	7402                	ld	s0,32(sp)
ffffffffc02025b0:	64e2                	ld	s1,24(sp)
ffffffffc02025b2:	6145                	addi	sp,sp,48
ffffffffc02025b4:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02025b6:	100027f3          	csrr	a5,sstatus
ffffffffc02025ba:	8b89                	andi	a5,a5,2
ffffffffc02025bc:	eb89                	bnez	a5,ffffffffc02025ce <page_remove+0x7c>
        pmm_manager->free_pages(base, n);
ffffffffc02025be:	000b0797          	auipc	a5,0xb0
ffffffffc02025c2:	1da7b783          	ld	a5,474(a5) # ffffffffc02b2798 <pmm_manager>
ffffffffc02025c6:	739c                	ld	a5,32(a5)
ffffffffc02025c8:	4585                	li	a1,1
ffffffffc02025ca:	9782                	jalr	a5
    if (flag) {
ffffffffc02025cc:	bfe1                	j	ffffffffc02025a4 <page_remove+0x52>
        intr_disable();
ffffffffc02025ce:	e42a                	sd	a0,8(sp)
ffffffffc02025d0:	852fe0ef          	jal	ra,ffffffffc0200622 <intr_disable>
ffffffffc02025d4:	000b0797          	auipc	a5,0xb0
ffffffffc02025d8:	1c47b783          	ld	a5,452(a5) # ffffffffc02b2798 <pmm_manager>
ffffffffc02025dc:	739c                	ld	a5,32(a5)
ffffffffc02025de:	6522                	ld	a0,8(sp)
ffffffffc02025e0:	4585                	li	a1,1
ffffffffc02025e2:	9782                	jalr	a5
        intr_enable();
ffffffffc02025e4:	838fe0ef          	jal	ra,ffffffffc020061c <intr_enable>
ffffffffc02025e8:	bf75                	j	ffffffffc02025a4 <page_remove+0x52>
ffffffffc02025ea:	e9aff0ef          	jal	ra,ffffffffc0201c84 <pa2page.part.0>

ffffffffc02025ee <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc02025ee:	7139                	addi	sp,sp,-64
ffffffffc02025f0:	e852                	sd	s4,16(sp)
ffffffffc02025f2:	8a32                	mv	s4,a2
ffffffffc02025f4:	f822                	sd	s0,48(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02025f6:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc02025f8:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02025fa:	85d2                	mv	a1,s4
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc02025fc:	f426                	sd	s1,40(sp)
ffffffffc02025fe:	fc06                	sd	ra,56(sp)
ffffffffc0202600:	f04a                	sd	s2,32(sp)
ffffffffc0202602:	ec4e                	sd	s3,24(sp)
ffffffffc0202604:	e456                	sd	s5,8(sp)
ffffffffc0202606:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202608:	fc0ff0ef          	jal	ra,ffffffffc0201dc8 <get_pte>
    if (ptep == NULL) {
ffffffffc020260c:	c961                	beqz	a0,ffffffffc02026dc <page_insert+0xee>
    page->ref += 1;
ffffffffc020260e:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc0202610:	611c                	ld	a5,0(a0)
ffffffffc0202612:	89aa                	mv	s3,a0
ffffffffc0202614:	0016871b          	addiw	a4,a3,1
ffffffffc0202618:	c018                	sw	a4,0(s0)
ffffffffc020261a:	0017f713          	andi	a4,a5,1
ffffffffc020261e:	ef05                	bnez	a4,ffffffffc0202656 <page_insert+0x68>
    return page - pages + nbase;
ffffffffc0202620:	000b0717          	auipc	a4,0xb0
ffffffffc0202624:	17073703          	ld	a4,368(a4) # ffffffffc02b2790 <pages>
ffffffffc0202628:	8c19                	sub	s0,s0,a4
ffffffffc020262a:	000807b7          	lui	a5,0x80
ffffffffc020262e:	8419                	srai	s0,s0,0x6
ffffffffc0202630:	943e                	add	s0,s0,a5
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202632:	042a                	slli	s0,s0,0xa
ffffffffc0202634:	8cc1                	or	s1,s1,s0
ffffffffc0202636:	0014e493          	ori	s1,s1,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc020263a:	0099b023          	sd	s1,0(s3) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff4ee0>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020263e:	120a0073          	sfence.vma	s4
    return 0;
ffffffffc0202642:	4501                	li	a0,0
}
ffffffffc0202644:	70e2                	ld	ra,56(sp)
ffffffffc0202646:	7442                	ld	s0,48(sp)
ffffffffc0202648:	74a2                	ld	s1,40(sp)
ffffffffc020264a:	7902                	ld	s2,32(sp)
ffffffffc020264c:	69e2                	ld	s3,24(sp)
ffffffffc020264e:	6a42                	ld	s4,16(sp)
ffffffffc0202650:	6aa2                	ld	s5,8(sp)
ffffffffc0202652:	6121                	addi	sp,sp,64
ffffffffc0202654:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202656:	078a                	slli	a5,a5,0x2
ffffffffc0202658:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020265a:	000b0717          	auipc	a4,0xb0
ffffffffc020265e:	12e73703          	ld	a4,302(a4) # ffffffffc02b2788 <npage>
ffffffffc0202662:	06e7ff63          	bgeu	a5,a4,ffffffffc02026e0 <page_insert+0xf2>
    return &pages[PPN(pa) - nbase];
ffffffffc0202666:	000b0a97          	auipc	s5,0xb0
ffffffffc020266a:	12aa8a93          	addi	s5,s5,298 # ffffffffc02b2790 <pages>
ffffffffc020266e:	000ab703          	ld	a4,0(s5)
ffffffffc0202672:	fff80937          	lui	s2,0xfff80
ffffffffc0202676:	993e                	add	s2,s2,a5
ffffffffc0202678:	091a                	slli	s2,s2,0x6
ffffffffc020267a:	993a                	add	s2,s2,a4
        if (p == page) {
ffffffffc020267c:	01240c63          	beq	s0,s2,ffffffffc0202694 <page_insert+0xa6>
    page->ref -= 1;
ffffffffc0202680:	00092783          	lw	a5,0(s2) # fffffffffff80000 <end+0x3fccd814>
ffffffffc0202684:	fff7869b          	addiw	a3,a5,-1
ffffffffc0202688:	00d92023          	sw	a3,0(s2)
        if (page_ref(page) ==
ffffffffc020268c:	c691                	beqz	a3,ffffffffc0202698 <page_insert+0xaa>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020268e:	120a0073          	sfence.vma	s4
}
ffffffffc0202692:	bf59                	j	ffffffffc0202628 <page_insert+0x3a>
ffffffffc0202694:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0202696:	bf49                	j	ffffffffc0202628 <page_insert+0x3a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202698:	100027f3          	csrr	a5,sstatus
ffffffffc020269c:	8b89                	andi	a5,a5,2
ffffffffc020269e:	ef91                	bnez	a5,ffffffffc02026ba <page_insert+0xcc>
        pmm_manager->free_pages(base, n);
ffffffffc02026a0:	000b0797          	auipc	a5,0xb0
ffffffffc02026a4:	0f87b783          	ld	a5,248(a5) # ffffffffc02b2798 <pmm_manager>
ffffffffc02026a8:	739c                	ld	a5,32(a5)
ffffffffc02026aa:	4585                	li	a1,1
ffffffffc02026ac:	854a                	mv	a0,s2
ffffffffc02026ae:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc02026b0:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02026b4:	120a0073          	sfence.vma	s4
ffffffffc02026b8:	bf85                	j	ffffffffc0202628 <page_insert+0x3a>
        intr_disable();
ffffffffc02026ba:	f69fd0ef          	jal	ra,ffffffffc0200622 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02026be:	000b0797          	auipc	a5,0xb0
ffffffffc02026c2:	0da7b783          	ld	a5,218(a5) # ffffffffc02b2798 <pmm_manager>
ffffffffc02026c6:	739c                	ld	a5,32(a5)
ffffffffc02026c8:	4585                	li	a1,1
ffffffffc02026ca:	854a                	mv	a0,s2
ffffffffc02026cc:	9782                	jalr	a5
        intr_enable();
ffffffffc02026ce:	f4ffd0ef          	jal	ra,ffffffffc020061c <intr_enable>
ffffffffc02026d2:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02026d6:	120a0073          	sfence.vma	s4
ffffffffc02026da:	b7b9                	j	ffffffffc0202628 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc02026dc:	5571                	li	a0,-4
ffffffffc02026de:	b79d                	j	ffffffffc0202644 <page_insert+0x56>
ffffffffc02026e0:	da4ff0ef          	jal	ra,ffffffffc0201c84 <pa2page.part.0>

ffffffffc02026e4 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc02026e4:	00005797          	auipc	a5,0x5
ffffffffc02026e8:	a5478793          	addi	a5,a5,-1452 # ffffffffc0207138 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02026ec:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc02026ee:	711d                	addi	sp,sp,-96
ffffffffc02026f0:	ec5e                	sd	s7,24(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02026f2:	00005517          	auipc	a0,0x5
ffffffffc02026f6:	c0e50513          	addi	a0,a0,-1010 # ffffffffc0207300 <default_pmm_manager+0x1c8>
    pmm_manager = &default_pmm_manager;
ffffffffc02026fa:	000b0b97          	auipc	s7,0xb0
ffffffffc02026fe:	09eb8b93          	addi	s7,s7,158 # ffffffffc02b2798 <pmm_manager>
void pmm_init(void) {
ffffffffc0202702:	ec86                	sd	ra,88(sp)
ffffffffc0202704:	e4a6                	sd	s1,72(sp)
ffffffffc0202706:	fc4e                	sd	s3,56(sp)
ffffffffc0202708:	f05a                	sd	s6,32(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc020270a:	00fbb023          	sd	a5,0(s7)
void pmm_init(void) {
ffffffffc020270e:	e8a2                	sd	s0,80(sp)
ffffffffc0202710:	e0ca                	sd	s2,64(sp)
ffffffffc0202712:	f852                	sd	s4,48(sp)
ffffffffc0202714:	f456                	sd	s5,40(sp)
ffffffffc0202716:	e862                	sd	s8,16(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202718:	a69fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
    pmm_manager->init();
ffffffffc020271c:	000bb783          	ld	a5,0(s7)
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202720:	000b0997          	auipc	s3,0xb0
ffffffffc0202724:	08098993          	addi	s3,s3,128 # ffffffffc02b27a0 <va_pa_offset>
    npage = maxpa / PGSIZE;
ffffffffc0202728:	000b0497          	auipc	s1,0xb0
ffffffffc020272c:	06048493          	addi	s1,s1,96 # ffffffffc02b2788 <npage>
    pmm_manager->init();
ffffffffc0202730:	679c                	ld	a5,8(a5)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202732:	000b0b17          	auipc	s6,0xb0
ffffffffc0202736:	05eb0b13          	addi	s6,s6,94 # ffffffffc02b2790 <pages>
    pmm_manager->init();
ffffffffc020273a:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc020273c:	57f5                	li	a5,-3
ffffffffc020273e:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0202740:	00005517          	auipc	a0,0x5
ffffffffc0202744:	bd850513          	addi	a0,a0,-1064 # ffffffffc0207318 <default_pmm_manager+0x1e0>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202748:	00f9b023          	sd	a5,0(s3)
    cprintf("physcial memory map:\n");
ffffffffc020274c:	a35fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0202750:	46c5                	li	a3,17
ffffffffc0202752:	06ee                	slli	a3,a3,0x1b
ffffffffc0202754:	40100613          	li	a2,1025
ffffffffc0202758:	07e005b7          	lui	a1,0x7e00
ffffffffc020275c:	16fd                	addi	a3,a3,-1
ffffffffc020275e:	0656                	slli	a2,a2,0x15
ffffffffc0202760:	00005517          	auipc	a0,0x5
ffffffffc0202764:	bd050513          	addi	a0,a0,-1072 # ffffffffc0207330 <default_pmm_manager+0x1f8>
ffffffffc0202768:	a19fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020276c:	777d                	lui	a4,0xfffff
ffffffffc020276e:	000b1797          	auipc	a5,0xb1
ffffffffc0202772:	07d78793          	addi	a5,a5,125 # ffffffffc02b37eb <end+0xfff>
ffffffffc0202776:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0202778:	00088737          	lui	a4,0x88
ffffffffc020277c:	e098                	sd	a4,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020277e:	00fb3023          	sd	a5,0(s6)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0202782:	4701                	li	a4,0
ffffffffc0202784:	4585                	li	a1,1
ffffffffc0202786:	fff80837          	lui	a6,0xfff80
ffffffffc020278a:	a019                	j	ffffffffc0202790 <pmm_init+0xac>
        SetPageReserved(pages + i);
ffffffffc020278c:	000b3783          	ld	a5,0(s6)
ffffffffc0202790:	00671693          	slli	a3,a4,0x6
ffffffffc0202794:	97b6                	add	a5,a5,a3
ffffffffc0202796:	07a1                	addi	a5,a5,8
ffffffffc0202798:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020279c:	6090                	ld	a2,0(s1)
ffffffffc020279e:	0705                	addi	a4,a4,1
ffffffffc02027a0:	010607b3          	add	a5,a2,a6
ffffffffc02027a4:	fef764e3          	bltu	a4,a5,ffffffffc020278c <pmm_init+0xa8>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02027a8:	000b3503          	ld	a0,0(s6)
ffffffffc02027ac:	079a                	slli	a5,a5,0x6
ffffffffc02027ae:	c0200737          	lui	a4,0xc0200
ffffffffc02027b2:	00f506b3          	add	a3,a0,a5
ffffffffc02027b6:	60e6e563          	bltu	a3,a4,ffffffffc0202dc0 <pmm_init+0x6dc>
ffffffffc02027ba:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc02027be:	4745                	li	a4,17
ffffffffc02027c0:	076e                	slli	a4,a4,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02027c2:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc02027c4:	4ae6e563          	bltu	a3,a4,ffffffffc0202c6e <pmm_init+0x58a>
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc02027c8:	00005517          	auipc	a0,0x5
ffffffffc02027cc:	b9050513          	addi	a0,a0,-1136 # ffffffffc0207358 <default_pmm_manager+0x220>
ffffffffc02027d0:	9b1fd0ef          	jal	ra,ffffffffc0200180 <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc02027d4:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc02027d8:	000b0917          	auipc	s2,0xb0
ffffffffc02027dc:	fa890913          	addi	s2,s2,-88 # ffffffffc02b2780 <boot_pgdir>
    pmm_manager->check();
ffffffffc02027e0:	7b9c                	ld	a5,48(a5)
ffffffffc02027e2:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02027e4:	00005517          	auipc	a0,0x5
ffffffffc02027e8:	b8c50513          	addi	a0,a0,-1140 # ffffffffc0207370 <default_pmm_manager+0x238>
ffffffffc02027ec:	995fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc02027f0:	00009697          	auipc	a3,0x9
ffffffffc02027f4:	81068693          	addi	a3,a3,-2032 # ffffffffc020b000 <boot_page_table_sv39>
ffffffffc02027f8:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc02027fc:	c02007b7          	lui	a5,0xc0200
ffffffffc0202800:	5cf6ec63          	bltu	a3,a5,ffffffffc0202dd8 <pmm_init+0x6f4>
ffffffffc0202804:	0009b783          	ld	a5,0(s3)
ffffffffc0202808:	8e9d                	sub	a3,a3,a5
ffffffffc020280a:	000b0797          	auipc	a5,0xb0
ffffffffc020280e:	f6d7b723          	sd	a3,-146(a5) # ffffffffc02b2778 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202812:	100027f3          	csrr	a5,sstatus
ffffffffc0202816:	8b89                	andi	a5,a5,2
ffffffffc0202818:	48079263          	bnez	a5,ffffffffc0202c9c <pmm_init+0x5b8>
        ret = pmm_manager->nr_free_pages();
ffffffffc020281c:	000bb783          	ld	a5,0(s7)
ffffffffc0202820:	779c                	ld	a5,40(a5)
ffffffffc0202822:	9782                	jalr	a5
ffffffffc0202824:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202826:	6098                	ld	a4,0(s1)
ffffffffc0202828:	c80007b7          	lui	a5,0xc8000
ffffffffc020282c:	83b1                	srli	a5,a5,0xc
ffffffffc020282e:	5ee7e163          	bltu	a5,a4,ffffffffc0202e10 <pmm_init+0x72c>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0202832:	00093503          	ld	a0,0(s2)
ffffffffc0202836:	5a050d63          	beqz	a0,ffffffffc0202df0 <pmm_init+0x70c>
ffffffffc020283a:	03451793          	slli	a5,a0,0x34
ffffffffc020283e:	5a079963          	bnez	a5,ffffffffc0202df0 <pmm_init+0x70c>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0202842:	4601                	li	a2,0
ffffffffc0202844:	4581                	li	a1,0
ffffffffc0202846:	f54ff0ef          	jal	ra,ffffffffc0201f9a <get_page>
ffffffffc020284a:	62051563          	bnez	a0,ffffffffc0202e74 <pmm_init+0x790>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc020284e:	4505                	li	a0,1
ffffffffc0202850:	c6cff0ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
ffffffffc0202854:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0202856:	00093503          	ld	a0,0(s2)
ffffffffc020285a:	4681                	li	a3,0
ffffffffc020285c:	4601                	li	a2,0
ffffffffc020285e:	85d2                	mv	a1,s4
ffffffffc0202860:	d8fff0ef          	jal	ra,ffffffffc02025ee <page_insert>
ffffffffc0202864:	5e051863          	bnez	a0,ffffffffc0202e54 <pmm_init+0x770>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202868:	00093503          	ld	a0,0(s2)
ffffffffc020286c:	4601                	li	a2,0
ffffffffc020286e:	4581                	li	a1,0
ffffffffc0202870:	d58ff0ef          	jal	ra,ffffffffc0201dc8 <get_pte>
ffffffffc0202874:	5c050063          	beqz	a0,ffffffffc0202e34 <pmm_init+0x750>
    assert(pte2page(*ptep) == p1);
ffffffffc0202878:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc020287a:	0017f713          	andi	a4,a5,1
ffffffffc020287e:	5a070963          	beqz	a4,ffffffffc0202e30 <pmm_init+0x74c>
    if (PPN(pa) >= npage) {
ffffffffc0202882:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202884:	078a                	slli	a5,a5,0x2
ffffffffc0202886:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202888:	52e7fa63          	bgeu	a5,a4,ffffffffc0202dbc <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc020288c:	000b3683          	ld	a3,0(s6)
ffffffffc0202890:	fff80637          	lui	a2,0xfff80
ffffffffc0202894:	97b2                	add	a5,a5,a2
ffffffffc0202896:	079a                	slli	a5,a5,0x6
ffffffffc0202898:	97b6                	add	a5,a5,a3
ffffffffc020289a:	10fa16e3          	bne	s4,a5,ffffffffc02031a6 <pmm_init+0xac2>
    assert(page_ref(p1) == 1);
ffffffffc020289e:	000a2683          	lw	a3,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8ba8>
ffffffffc02028a2:	4785                	li	a5,1
ffffffffc02028a4:	12f69de3          	bne	a3,a5,ffffffffc02031de <pmm_init+0xafa>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc02028a8:	00093503          	ld	a0,0(s2)
ffffffffc02028ac:	77fd                	lui	a5,0xfffff
ffffffffc02028ae:	6114                	ld	a3,0(a0)
ffffffffc02028b0:	068a                	slli	a3,a3,0x2
ffffffffc02028b2:	8efd                	and	a3,a3,a5
ffffffffc02028b4:	00c6d613          	srli	a2,a3,0xc
ffffffffc02028b8:	10e677e3          	bgeu	a2,a4,ffffffffc02031c6 <pmm_init+0xae2>
ffffffffc02028bc:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02028c0:	96e2                	add	a3,a3,s8
ffffffffc02028c2:	0006ba83          	ld	s5,0(a3)
ffffffffc02028c6:	0a8a                	slli	s5,s5,0x2
ffffffffc02028c8:	00fafab3          	and	s5,s5,a5
ffffffffc02028cc:	00cad793          	srli	a5,s5,0xc
ffffffffc02028d0:	62e7f263          	bgeu	a5,a4,ffffffffc0202ef4 <pmm_init+0x810>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02028d4:	4601                	li	a2,0
ffffffffc02028d6:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02028d8:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02028da:	ceeff0ef          	jal	ra,ffffffffc0201dc8 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02028de:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02028e0:	5f551a63          	bne	a0,s5,ffffffffc0202ed4 <pmm_init+0x7f0>

    p2 = alloc_page();
ffffffffc02028e4:	4505                	li	a0,1
ffffffffc02028e6:	bd6ff0ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
ffffffffc02028ea:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02028ec:	00093503          	ld	a0,0(s2)
ffffffffc02028f0:	46d1                	li	a3,20
ffffffffc02028f2:	6605                	lui	a2,0x1
ffffffffc02028f4:	85d6                	mv	a1,s5
ffffffffc02028f6:	cf9ff0ef          	jal	ra,ffffffffc02025ee <page_insert>
ffffffffc02028fa:	58051d63          	bnez	a0,ffffffffc0202e94 <pmm_init+0x7b0>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02028fe:	00093503          	ld	a0,0(s2)
ffffffffc0202902:	4601                	li	a2,0
ffffffffc0202904:	6585                	lui	a1,0x1
ffffffffc0202906:	cc2ff0ef          	jal	ra,ffffffffc0201dc8 <get_pte>
ffffffffc020290a:	0e050ae3          	beqz	a0,ffffffffc02031fe <pmm_init+0xb1a>
    assert(*ptep & PTE_U);
ffffffffc020290e:	611c                	ld	a5,0(a0)
ffffffffc0202910:	0107f713          	andi	a4,a5,16
ffffffffc0202914:	6e070d63          	beqz	a4,ffffffffc020300e <pmm_init+0x92a>
    assert(*ptep & PTE_W);
ffffffffc0202918:	8b91                	andi	a5,a5,4
ffffffffc020291a:	6a078a63          	beqz	a5,ffffffffc0202fce <pmm_init+0x8ea>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc020291e:	00093503          	ld	a0,0(s2)
ffffffffc0202922:	611c                	ld	a5,0(a0)
ffffffffc0202924:	8bc1                	andi	a5,a5,16
ffffffffc0202926:	68078463          	beqz	a5,ffffffffc0202fae <pmm_init+0x8ca>
    assert(page_ref(p2) == 1);
ffffffffc020292a:	000aa703          	lw	a4,0(s5)
ffffffffc020292e:	4785                	li	a5,1
ffffffffc0202930:	58f71263          	bne	a4,a5,ffffffffc0202eb4 <pmm_init+0x7d0>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0202934:	4681                	li	a3,0
ffffffffc0202936:	6605                	lui	a2,0x1
ffffffffc0202938:	85d2                	mv	a1,s4
ffffffffc020293a:	cb5ff0ef          	jal	ra,ffffffffc02025ee <page_insert>
ffffffffc020293e:	62051863          	bnez	a0,ffffffffc0202f6e <pmm_init+0x88a>
    assert(page_ref(p1) == 2);
ffffffffc0202942:	000a2703          	lw	a4,0(s4)
ffffffffc0202946:	4789                	li	a5,2
ffffffffc0202948:	60f71363          	bne	a4,a5,ffffffffc0202f4e <pmm_init+0x86a>
    assert(page_ref(p2) == 0);
ffffffffc020294c:	000aa783          	lw	a5,0(s5)
ffffffffc0202950:	5c079f63          	bnez	a5,ffffffffc0202f2e <pmm_init+0x84a>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202954:	00093503          	ld	a0,0(s2)
ffffffffc0202958:	4601                	li	a2,0
ffffffffc020295a:	6585                	lui	a1,0x1
ffffffffc020295c:	c6cff0ef          	jal	ra,ffffffffc0201dc8 <get_pte>
ffffffffc0202960:	5a050763          	beqz	a0,ffffffffc0202f0e <pmm_init+0x82a>
    assert(pte2page(*ptep) == p1);
ffffffffc0202964:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202966:	00177793          	andi	a5,a4,1
ffffffffc020296a:	4c078363          	beqz	a5,ffffffffc0202e30 <pmm_init+0x74c>
    if (PPN(pa) >= npage) {
ffffffffc020296e:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202970:	00271793          	slli	a5,a4,0x2
ffffffffc0202974:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202976:	44d7f363          	bgeu	a5,a3,ffffffffc0202dbc <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc020297a:	000b3683          	ld	a3,0(s6)
ffffffffc020297e:	fff80637          	lui	a2,0xfff80
ffffffffc0202982:	97b2                	add	a5,a5,a2
ffffffffc0202984:	079a                	slli	a5,a5,0x6
ffffffffc0202986:	97b6                	add	a5,a5,a3
ffffffffc0202988:	6efa1363          	bne	s4,a5,ffffffffc020306e <pmm_init+0x98a>
    assert((*ptep & PTE_U) == 0);
ffffffffc020298c:	8b41                	andi	a4,a4,16
ffffffffc020298e:	6c071063          	bnez	a4,ffffffffc020304e <pmm_init+0x96a>

    page_remove(boot_pgdir, 0x0);
ffffffffc0202992:	00093503          	ld	a0,0(s2)
ffffffffc0202996:	4581                	li	a1,0
ffffffffc0202998:	bbbff0ef          	jal	ra,ffffffffc0202552 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc020299c:	000a2703          	lw	a4,0(s4)
ffffffffc02029a0:	4785                	li	a5,1
ffffffffc02029a2:	68f71663          	bne	a4,a5,ffffffffc020302e <pmm_init+0x94a>
    assert(page_ref(p2) == 0);
ffffffffc02029a6:	000aa783          	lw	a5,0(s5)
ffffffffc02029aa:	74079e63          	bnez	a5,ffffffffc0203106 <pmm_init+0xa22>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc02029ae:	00093503          	ld	a0,0(s2)
ffffffffc02029b2:	6585                	lui	a1,0x1
ffffffffc02029b4:	b9fff0ef          	jal	ra,ffffffffc0202552 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc02029b8:	000a2783          	lw	a5,0(s4)
ffffffffc02029bc:	72079563          	bnez	a5,ffffffffc02030e6 <pmm_init+0xa02>
    assert(page_ref(p2) == 0);
ffffffffc02029c0:	000aa783          	lw	a5,0(s5)
ffffffffc02029c4:	70079163          	bnez	a5,ffffffffc02030c6 <pmm_init+0x9e2>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02029c8:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc02029cc:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02029ce:	000a3683          	ld	a3,0(s4)
ffffffffc02029d2:	068a                	slli	a3,a3,0x2
ffffffffc02029d4:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc02029d6:	3ee6f363          	bgeu	a3,a4,ffffffffc0202dbc <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc02029da:	fff807b7          	lui	a5,0xfff80
ffffffffc02029de:	000b3503          	ld	a0,0(s6)
ffffffffc02029e2:	96be                	add	a3,a3,a5
ffffffffc02029e4:	069a                	slli	a3,a3,0x6
    return page->ref;
ffffffffc02029e6:	00d507b3          	add	a5,a0,a3
ffffffffc02029ea:	4390                	lw	a2,0(a5)
ffffffffc02029ec:	4785                	li	a5,1
ffffffffc02029ee:	6af61c63          	bne	a2,a5,ffffffffc02030a6 <pmm_init+0x9c2>
    return page - pages + nbase;
ffffffffc02029f2:	8699                	srai	a3,a3,0x6
ffffffffc02029f4:	000805b7          	lui	a1,0x80
ffffffffc02029f8:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc02029fa:	00c69613          	slli	a2,a3,0xc
ffffffffc02029fe:	8231                	srli	a2,a2,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202a00:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202a02:	68e67663          	bgeu	a2,a4,ffffffffc020308e <pmm_init+0x9aa>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0202a06:	0009b603          	ld	a2,0(s3)
ffffffffc0202a0a:	96b2                	add	a3,a3,a2
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a0c:	629c                	ld	a5,0(a3)
ffffffffc0202a0e:	078a                	slli	a5,a5,0x2
ffffffffc0202a10:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202a12:	3ae7f563          	bgeu	a5,a4,ffffffffc0202dbc <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202a16:	8f8d                	sub	a5,a5,a1
ffffffffc0202a18:	079a                	slli	a5,a5,0x6
ffffffffc0202a1a:	953e                	add	a0,a0,a5
ffffffffc0202a1c:	100027f3          	csrr	a5,sstatus
ffffffffc0202a20:	8b89                	andi	a5,a5,2
ffffffffc0202a22:	2c079763          	bnez	a5,ffffffffc0202cf0 <pmm_init+0x60c>
        pmm_manager->free_pages(base, n);
ffffffffc0202a26:	000bb783          	ld	a5,0(s7)
ffffffffc0202a2a:	4585                	li	a1,1
ffffffffc0202a2c:	739c                	ld	a5,32(a5)
ffffffffc0202a2e:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a30:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0202a34:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a36:	078a                	slli	a5,a5,0x2
ffffffffc0202a38:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202a3a:	38e7f163          	bgeu	a5,a4,ffffffffc0202dbc <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202a3e:	000b3503          	ld	a0,0(s6)
ffffffffc0202a42:	fff80737          	lui	a4,0xfff80
ffffffffc0202a46:	97ba                	add	a5,a5,a4
ffffffffc0202a48:	079a                	slli	a5,a5,0x6
ffffffffc0202a4a:	953e                	add	a0,a0,a5
ffffffffc0202a4c:	100027f3          	csrr	a5,sstatus
ffffffffc0202a50:	8b89                	andi	a5,a5,2
ffffffffc0202a52:	28079363          	bnez	a5,ffffffffc0202cd8 <pmm_init+0x5f4>
ffffffffc0202a56:	000bb783          	ld	a5,0(s7)
ffffffffc0202a5a:	4585                	li	a1,1
ffffffffc0202a5c:	739c                	ld	a5,32(a5)
ffffffffc0202a5e:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0202a60:	00093783          	ld	a5,0(s2)
ffffffffc0202a64:	0007b023          	sd	zero,0(a5) # fffffffffff80000 <end+0x3fccd814>
  asm volatile("sfence.vma");
ffffffffc0202a68:	12000073          	sfence.vma
ffffffffc0202a6c:	100027f3          	csrr	a5,sstatus
ffffffffc0202a70:	8b89                	andi	a5,a5,2
ffffffffc0202a72:	24079963          	bnez	a5,ffffffffc0202cc4 <pmm_init+0x5e0>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202a76:	000bb783          	ld	a5,0(s7)
ffffffffc0202a7a:	779c                	ld	a5,40(a5)
ffffffffc0202a7c:	9782                	jalr	a5
ffffffffc0202a7e:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0202a80:	71441363          	bne	s0,s4,ffffffffc0203186 <pmm_init+0xaa2>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0202a84:	00005517          	auipc	a0,0x5
ffffffffc0202a88:	bd450513          	addi	a0,a0,-1068 # ffffffffc0207658 <default_pmm_manager+0x520>
ffffffffc0202a8c:	ef4fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0202a90:	100027f3          	csrr	a5,sstatus
ffffffffc0202a94:	8b89                	andi	a5,a5,2
ffffffffc0202a96:	20079d63          	bnez	a5,ffffffffc0202cb0 <pmm_init+0x5cc>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202a9a:	000bb783          	ld	a5,0(s7)
ffffffffc0202a9e:	779c                	ld	a5,40(a5)
ffffffffc0202aa0:	9782                	jalr	a5
ffffffffc0202aa2:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0202aa4:	6098                	ld	a4,0(s1)
ffffffffc0202aa6:	c0200437          	lui	s0,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202aaa:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0202aac:	00c71793          	slli	a5,a4,0xc
ffffffffc0202ab0:	6a05                	lui	s4,0x1
ffffffffc0202ab2:	02f47c63          	bgeu	s0,a5,ffffffffc0202aea <pmm_init+0x406>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202ab6:	00c45793          	srli	a5,s0,0xc
ffffffffc0202aba:	00093503          	ld	a0,0(s2)
ffffffffc0202abe:	2ee7f263          	bgeu	a5,a4,ffffffffc0202da2 <pmm_init+0x6be>
ffffffffc0202ac2:	0009b583          	ld	a1,0(s3)
ffffffffc0202ac6:	4601                	li	a2,0
ffffffffc0202ac8:	95a2                	add	a1,a1,s0
ffffffffc0202aca:	afeff0ef          	jal	ra,ffffffffc0201dc8 <get_pte>
ffffffffc0202ace:	2a050a63          	beqz	a0,ffffffffc0202d82 <pmm_init+0x69e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202ad2:	611c                	ld	a5,0(a0)
ffffffffc0202ad4:	078a                	slli	a5,a5,0x2
ffffffffc0202ad6:	0157f7b3          	and	a5,a5,s5
ffffffffc0202ada:	28879463          	bne	a5,s0,ffffffffc0202d62 <pmm_init+0x67e>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0202ade:	6098                	ld	a4,0(s1)
ffffffffc0202ae0:	9452                	add	s0,s0,s4
ffffffffc0202ae2:	00c71793          	slli	a5,a4,0xc
ffffffffc0202ae6:	fcf468e3          	bltu	s0,a5,ffffffffc0202ab6 <pmm_init+0x3d2>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0202aea:	00093783          	ld	a5,0(s2)
ffffffffc0202aee:	639c                	ld	a5,0(a5)
ffffffffc0202af0:	66079b63          	bnez	a5,ffffffffc0203166 <pmm_init+0xa82>

    struct Page *p;
    p = alloc_page();
ffffffffc0202af4:	4505                	li	a0,1
ffffffffc0202af6:	9c6ff0ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
ffffffffc0202afa:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202afc:	00093503          	ld	a0,0(s2)
ffffffffc0202b00:	4699                	li	a3,6
ffffffffc0202b02:	10000613          	li	a2,256
ffffffffc0202b06:	85d6                	mv	a1,s5
ffffffffc0202b08:	ae7ff0ef          	jal	ra,ffffffffc02025ee <page_insert>
ffffffffc0202b0c:	62051d63          	bnez	a0,ffffffffc0203146 <pmm_init+0xa62>
    assert(page_ref(p) == 1);
ffffffffc0202b10:	000aa703          	lw	a4,0(s5) # fffffffffffff000 <end+0x3fd4c814>
ffffffffc0202b14:	4785                	li	a5,1
ffffffffc0202b16:	60f71863          	bne	a4,a5,ffffffffc0203126 <pmm_init+0xa42>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202b1a:	00093503          	ld	a0,0(s2)
ffffffffc0202b1e:	6405                	lui	s0,0x1
ffffffffc0202b20:	4699                	li	a3,6
ffffffffc0202b22:	10040613          	addi	a2,s0,256 # 1100 <_binary_obj___user_faultread_out_size-0x8aa8>
ffffffffc0202b26:	85d6                	mv	a1,s5
ffffffffc0202b28:	ac7ff0ef          	jal	ra,ffffffffc02025ee <page_insert>
ffffffffc0202b2c:	46051163          	bnez	a0,ffffffffc0202f8e <pmm_init+0x8aa>
    assert(page_ref(p) == 2);
ffffffffc0202b30:	000aa703          	lw	a4,0(s5)
ffffffffc0202b34:	4789                	li	a5,2
ffffffffc0202b36:	72f71463          	bne	a4,a5,ffffffffc020325e <pmm_init+0xb7a>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0202b3a:	00005597          	auipc	a1,0x5
ffffffffc0202b3e:	c5658593          	addi	a1,a1,-938 # ffffffffc0207790 <default_pmm_manager+0x658>
ffffffffc0202b42:	10000513          	li	a0,256
ffffffffc0202b46:	02d030ef          	jal	ra,ffffffffc0206372 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202b4a:	10040593          	addi	a1,s0,256
ffffffffc0202b4e:	10000513          	li	a0,256
ffffffffc0202b52:	033030ef          	jal	ra,ffffffffc0206384 <strcmp>
ffffffffc0202b56:	6e051463          	bnez	a0,ffffffffc020323e <pmm_init+0xb5a>
    return page - pages + nbase;
ffffffffc0202b5a:	000b3683          	ld	a3,0(s6)
ffffffffc0202b5e:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0202b62:	547d                	li	s0,-1
    return page - pages + nbase;
ffffffffc0202b64:	40da86b3          	sub	a3,s5,a3
ffffffffc0202b68:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0202b6a:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc0202b6c:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0202b6e:	8031                	srli	s0,s0,0xc
ffffffffc0202b70:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc0202b74:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202b76:	50f77c63          	bgeu	a4,a5,ffffffffc020308e <pmm_init+0x9aa>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202b7a:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202b7e:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202b82:	96be                	add	a3,a3,a5
ffffffffc0202b84:	10068023          	sb	zero,256(a3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202b88:	7b4030ef          	jal	ra,ffffffffc020633c <strlen>
ffffffffc0202b8c:	68051963          	bnez	a0,ffffffffc020321e <pmm_init+0xb3a>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0202b90:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0202b94:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b96:	000a3683          	ld	a3,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8ba8>
ffffffffc0202b9a:	068a                	slli	a3,a3,0x2
ffffffffc0202b9c:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202b9e:	20f6ff63          	bgeu	a3,a5,ffffffffc0202dbc <pmm_init+0x6d8>
    return KADDR(page2pa(page));
ffffffffc0202ba2:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0202ba4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202ba6:	4ef47463          	bgeu	s0,a5,ffffffffc020308e <pmm_init+0x9aa>
ffffffffc0202baa:	0009b403          	ld	s0,0(s3)
ffffffffc0202bae:	9436                	add	s0,s0,a3
ffffffffc0202bb0:	100027f3          	csrr	a5,sstatus
ffffffffc0202bb4:	8b89                	andi	a5,a5,2
ffffffffc0202bb6:	18079b63          	bnez	a5,ffffffffc0202d4c <pmm_init+0x668>
        pmm_manager->free_pages(base, n);
ffffffffc0202bba:	000bb783          	ld	a5,0(s7)
ffffffffc0202bbe:	4585                	li	a1,1
ffffffffc0202bc0:	8556                	mv	a0,s5
ffffffffc0202bc2:	739c                	ld	a5,32(a5)
ffffffffc0202bc4:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202bc6:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0202bc8:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202bca:	078a                	slli	a5,a5,0x2
ffffffffc0202bcc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202bce:	1ee7f763          	bgeu	a5,a4,ffffffffc0202dbc <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202bd2:	000b3503          	ld	a0,0(s6)
ffffffffc0202bd6:	fff80737          	lui	a4,0xfff80
ffffffffc0202bda:	97ba                	add	a5,a5,a4
ffffffffc0202bdc:	079a                	slli	a5,a5,0x6
ffffffffc0202bde:	953e                	add	a0,a0,a5
ffffffffc0202be0:	100027f3          	csrr	a5,sstatus
ffffffffc0202be4:	8b89                	andi	a5,a5,2
ffffffffc0202be6:	14079763          	bnez	a5,ffffffffc0202d34 <pmm_init+0x650>
ffffffffc0202bea:	000bb783          	ld	a5,0(s7)
ffffffffc0202bee:	4585                	li	a1,1
ffffffffc0202bf0:	739c                	ld	a5,32(a5)
ffffffffc0202bf2:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202bf4:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0202bf8:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202bfa:	078a                	slli	a5,a5,0x2
ffffffffc0202bfc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202bfe:	1ae7ff63          	bgeu	a5,a4,ffffffffc0202dbc <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202c02:	000b3503          	ld	a0,0(s6)
ffffffffc0202c06:	fff80737          	lui	a4,0xfff80
ffffffffc0202c0a:	97ba                	add	a5,a5,a4
ffffffffc0202c0c:	079a                	slli	a5,a5,0x6
ffffffffc0202c0e:	953e                	add	a0,a0,a5
ffffffffc0202c10:	100027f3          	csrr	a5,sstatus
ffffffffc0202c14:	8b89                	andi	a5,a5,2
ffffffffc0202c16:	10079363          	bnez	a5,ffffffffc0202d1c <pmm_init+0x638>
ffffffffc0202c1a:	000bb783          	ld	a5,0(s7)
ffffffffc0202c1e:	4585                	li	a1,1
ffffffffc0202c20:	739c                	ld	a5,32(a5)
ffffffffc0202c22:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0202c24:	00093783          	ld	a5,0(s2)
ffffffffc0202c28:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc0202c2c:	12000073          	sfence.vma
ffffffffc0202c30:	100027f3          	csrr	a5,sstatus
ffffffffc0202c34:	8b89                	andi	a5,a5,2
ffffffffc0202c36:	0c079963          	bnez	a5,ffffffffc0202d08 <pmm_init+0x624>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202c3a:	000bb783          	ld	a5,0(s7)
ffffffffc0202c3e:	779c                	ld	a5,40(a5)
ffffffffc0202c40:	9782                	jalr	a5
ffffffffc0202c42:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0202c44:	3a8c1563          	bne	s8,s0,ffffffffc0202fee <pmm_init+0x90a>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202c48:	00005517          	auipc	a0,0x5
ffffffffc0202c4c:	bc050513          	addi	a0,a0,-1088 # ffffffffc0207808 <default_pmm_manager+0x6d0>
ffffffffc0202c50:	d30fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
}
ffffffffc0202c54:	6446                	ld	s0,80(sp)
ffffffffc0202c56:	60e6                	ld	ra,88(sp)
ffffffffc0202c58:	64a6                	ld	s1,72(sp)
ffffffffc0202c5a:	6906                	ld	s2,64(sp)
ffffffffc0202c5c:	79e2                	ld	s3,56(sp)
ffffffffc0202c5e:	7a42                	ld	s4,48(sp)
ffffffffc0202c60:	7aa2                	ld	s5,40(sp)
ffffffffc0202c62:	7b02                	ld	s6,32(sp)
ffffffffc0202c64:	6be2                	ld	s7,24(sp)
ffffffffc0202c66:	6c42                	ld	s8,16(sp)
ffffffffc0202c68:	6125                	addi	sp,sp,96
    kmalloc_init();
ffffffffc0202c6a:	e51fe06f          	j	ffffffffc0201aba <kmalloc_init>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0202c6e:	6785                	lui	a5,0x1
ffffffffc0202c70:	17fd                	addi	a5,a5,-1
ffffffffc0202c72:	96be                	add	a3,a3,a5
ffffffffc0202c74:	77fd                	lui	a5,0xfffff
ffffffffc0202c76:	8ff5                	and	a5,a5,a3
    if (PPN(pa) >= npage) {
ffffffffc0202c78:	00c7d693          	srli	a3,a5,0xc
ffffffffc0202c7c:	14c6f063          	bgeu	a3,a2,ffffffffc0202dbc <pmm_init+0x6d8>
    pmm_manager->init_memmap(base, n);
ffffffffc0202c80:	000bb603          	ld	a2,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc0202c84:	96c2                	add	a3,a3,a6
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202c86:	40f707b3          	sub	a5,a4,a5
    pmm_manager->init_memmap(base, n);
ffffffffc0202c8a:	6a10                	ld	a2,16(a2)
ffffffffc0202c8c:	069a                	slli	a3,a3,0x6
ffffffffc0202c8e:	00c7d593          	srli	a1,a5,0xc
ffffffffc0202c92:	9536                	add	a0,a0,a3
ffffffffc0202c94:	9602                	jalr	a2
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0202c96:	0009b583          	ld	a1,0(s3)
}
ffffffffc0202c9a:	b63d                	j	ffffffffc02027c8 <pmm_init+0xe4>
        intr_disable();
ffffffffc0202c9c:	987fd0ef          	jal	ra,ffffffffc0200622 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202ca0:	000bb783          	ld	a5,0(s7)
ffffffffc0202ca4:	779c                	ld	a5,40(a5)
ffffffffc0202ca6:	9782                	jalr	a5
ffffffffc0202ca8:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202caa:	973fd0ef          	jal	ra,ffffffffc020061c <intr_enable>
ffffffffc0202cae:	bea5                	j	ffffffffc0202826 <pmm_init+0x142>
        intr_disable();
ffffffffc0202cb0:	973fd0ef          	jal	ra,ffffffffc0200622 <intr_disable>
ffffffffc0202cb4:	000bb783          	ld	a5,0(s7)
ffffffffc0202cb8:	779c                	ld	a5,40(a5)
ffffffffc0202cba:	9782                	jalr	a5
ffffffffc0202cbc:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0202cbe:	95ffd0ef          	jal	ra,ffffffffc020061c <intr_enable>
ffffffffc0202cc2:	b3cd                	j	ffffffffc0202aa4 <pmm_init+0x3c0>
        intr_disable();
ffffffffc0202cc4:	95ffd0ef          	jal	ra,ffffffffc0200622 <intr_disable>
ffffffffc0202cc8:	000bb783          	ld	a5,0(s7)
ffffffffc0202ccc:	779c                	ld	a5,40(a5)
ffffffffc0202cce:	9782                	jalr	a5
ffffffffc0202cd0:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202cd2:	94bfd0ef          	jal	ra,ffffffffc020061c <intr_enable>
ffffffffc0202cd6:	b36d                	j	ffffffffc0202a80 <pmm_init+0x39c>
ffffffffc0202cd8:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202cda:	949fd0ef          	jal	ra,ffffffffc0200622 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202cde:	000bb783          	ld	a5,0(s7)
ffffffffc0202ce2:	6522                	ld	a0,8(sp)
ffffffffc0202ce4:	4585                	li	a1,1
ffffffffc0202ce6:	739c                	ld	a5,32(a5)
ffffffffc0202ce8:	9782                	jalr	a5
        intr_enable();
ffffffffc0202cea:	933fd0ef          	jal	ra,ffffffffc020061c <intr_enable>
ffffffffc0202cee:	bb8d                	j	ffffffffc0202a60 <pmm_init+0x37c>
ffffffffc0202cf0:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202cf2:	931fd0ef          	jal	ra,ffffffffc0200622 <intr_disable>
ffffffffc0202cf6:	000bb783          	ld	a5,0(s7)
ffffffffc0202cfa:	6522                	ld	a0,8(sp)
ffffffffc0202cfc:	4585                	li	a1,1
ffffffffc0202cfe:	739c                	ld	a5,32(a5)
ffffffffc0202d00:	9782                	jalr	a5
        intr_enable();
ffffffffc0202d02:	91bfd0ef          	jal	ra,ffffffffc020061c <intr_enable>
ffffffffc0202d06:	b32d                	j	ffffffffc0202a30 <pmm_init+0x34c>
        intr_disable();
ffffffffc0202d08:	91bfd0ef          	jal	ra,ffffffffc0200622 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202d0c:	000bb783          	ld	a5,0(s7)
ffffffffc0202d10:	779c                	ld	a5,40(a5)
ffffffffc0202d12:	9782                	jalr	a5
ffffffffc0202d14:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202d16:	907fd0ef          	jal	ra,ffffffffc020061c <intr_enable>
ffffffffc0202d1a:	b72d                	j	ffffffffc0202c44 <pmm_init+0x560>
ffffffffc0202d1c:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202d1e:	905fd0ef          	jal	ra,ffffffffc0200622 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202d22:	000bb783          	ld	a5,0(s7)
ffffffffc0202d26:	6522                	ld	a0,8(sp)
ffffffffc0202d28:	4585                	li	a1,1
ffffffffc0202d2a:	739c                	ld	a5,32(a5)
ffffffffc0202d2c:	9782                	jalr	a5
        intr_enable();
ffffffffc0202d2e:	8effd0ef          	jal	ra,ffffffffc020061c <intr_enable>
ffffffffc0202d32:	bdcd                	j	ffffffffc0202c24 <pmm_init+0x540>
ffffffffc0202d34:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202d36:	8edfd0ef          	jal	ra,ffffffffc0200622 <intr_disable>
ffffffffc0202d3a:	000bb783          	ld	a5,0(s7)
ffffffffc0202d3e:	6522                	ld	a0,8(sp)
ffffffffc0202d40:	4585                	li	a1,1
ffffffffc0202d42:	739c                	ld	a5,32(a5)
ffffffffc0202d44:	9782                	jalr	a5
        intr_enable();
ffffffffc0202d46:	8d7fd0ef          	jal	ra,ffffffffc020061c <intr_enable>
ffffffffc0202d4a:	b56d                	j	ffffffffc0202bf4 <pmm_init+0x510>
        intr_disable();
ffffffffc0202d4c:	8d7fd0ef          	jal	ra,ffffffffc0200622 <intr_disable>
ffffffffc0202d50:	000bb783          	ld	a5,0(s7)
ffffffffc0202d54:	4585                	li	a1,1
ffffffffc0202d56:	8556                	mv	a0,s5
ffffffffc0202d58:	739c                	ld	a5,32(a5)
ffffffffc0202d5a:	9782                	jalr	a5
        intr_enable();
ffffffffc0202d5c:	8c1fd0ef          	jal	ra,ffffffffc020061c <intr_enable>
ffffffffc0202d60:	b59d                	j	ffffffffc0202bc6 <pmm_init+0x4e2>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202d62:	00005697          	auipc	a3,0x5
ffffffffc0202d66:	95668693          	addi	a3,a3,-1706 # ffffffffc02076b8 <default_pmm_manager+0x580>
ffffffffc0202d6a:	00004617          	auipc	a2,0x4
ffffffffc0202d6e:	d3660613          	addi	a2,a2,-714 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0202d72:	22500593          	li	a1,549
ffffffffc0202d76:	00004517          	auipc	a0,0x4
ffffffffc0202d7a:	51250513          	addi	a0,a0,1298 # ffffffffc0207288 <default_pmm_manager+0x150>
ffffffffc0202d7e:	efcfd0ef          	jal	ra,ffffffffc020047a <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202d82:	00005697          	auipc	a3,0x5
ffffffffc0202d86:	8f668693          	addi	a3,a3,-1802 # ffffffffc0207678 <default_pmm_manager+0x540>
ffffffffc0202d8a:	00004617          	auipc	a2,0x4
ffffffffc0202d8e:	d1660613          	addi	a2,a2,-746 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0202d92:	22400593          	li	a1,548
ffffffffc0202d96:	00004517          	auipc	a0,0x4
ffffffffc0202d9a:	4f250513          	addi	a0,a0,1266 # ffffffffc0207288 <default_pmm_manager+0x150>
ffffffffc0202d9e:	edcfd0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc0202da2:	86a2                	mv	a3,s0
ffffffffc0202da4:	00004617          	auipc	a2,0x4
ffffffffc0202da8:	3cc60613          	addi	a2,a2,972 # ffffffffc0207170 <default_pmm_manager+0x38>
ffffffffc0202dac:	22400593          	li	a1,548
ffffffffc0202db0:	00004517          	auipc	a0,0x4
ffffffffc0202db4:	4d850513          	addi	a0,a0,1240 # ffffffffc0207288 <default_pmm_manager+0x150>
ffffffffc0202db8:	ec2fd0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc0202dbc:	ec9fe0ef          	jal	ra,ffffffffc0201c84 <pa2page.part.0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202dc0:	00004617          	auipc	a2,0x4
ffffffffc0202dc4:	45860613          	addi	a2,a2,1112 # ffffffffc0207218 <default_pmm_manager+0xe0>
ffffffffc0202dc8:	07f00593          	li	a1,127
ffffffffc0202dcc:	00004517          	auipc	a0,0x4
ffffffffc0202dd0:	4bc50513          	addi	a0,a0,1212 # ffffffffc0207288 <default_pmm_manager+0x150>
ffffffffc0202dd4:	ea6fd0ef          	jal	ra,ffffffffc020047a <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0202dd8:	00004617          	auipc	a2,0x4
ffffffffc0202ddc:	44060613          	addi	a2,a2,1088 # ffffffffc0207218 <default_pmm_manager+0xe0>
ffffffffc0202de0:	0c100593          	li	a1,193
ffffffffc0202de4:	00004517          	auipc	a0,0x4
ffffffffc0202de8:	4a450513          	addi	a0,a0,1188 # ffffffffc0207288 <default_pmm_manager+0x150>
ffffffffc0202dec:	e8efd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0202df0:	00004697          	auipc	a3,0x4
ffffffffc0202df4:	5c068693          	addi	a3,a3,1472 # ffffffffc02073b0 <default_pmm_manager+0x278>
ffffffffc0202df8:	00004617          	auipc	a2,0x4
ffffffffc0202dfc:	ca860613          	addi	a2,a2,-856 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0202e00:	1e800593          	li	a1,488
ffffffffc0202e04:	00004517          	auipc	a0,0x4
ffffffffc0202e08:	48450513          	addi	a0,a0,1156 # ffffffffc0207288 <default_pmm_manager+0x150>
ffffffffc0202e0c:	e6efd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202e10:	00004697          	auipc	a3,0x4
ffffffffc0202e14:	58068693          	addi	a3,a3,1408 # ffffffffc0207390 <default_pmm_manager+0x258>
ffffffffc0202e18:	00004617          	auipc	a2,0x4
ffffffffc0202e1c:	c8860613          	addi	a2,a2,-888 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0202e20:	1e700593          	li	a1,487
ffffffffc0202e24:	00004517          	auipc	a0,0x4
ffffffffc0202e28:	46450513          	addi	a0,a0,1124 # ffffffffc0207288 <default_pmm_manager+0x150>
ffffffffc0202e2c:	e4efd0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc0202e30:	e71fe0ef          	jal	ra,ffffffffc0201ca0 <pte2page.part.0>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202e34:	00004697          	auipc	a3,0x4
ffffffffc0202e38:	60c68693          	addi	a3,a3,1548 # ffffffffc0207440 <default_pmm_manager+0x308>
ffffffffc0202e3c:	00004617          	auipc	a2,0x4
ffffffffc0202e40:	c6460613          	addi	a2,a2,-924 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0202e44:	1f000593          	li	a1,496
ffffffffc0202e48:	00004517          	auipc	a0,0x4
ffffffffc0202e4c:	44050513          	addi	a0,a0,1088 # ffffffffc0207288 <default_pmm_manager+0x150>
ffffffffc0202e50:	e2afd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0202e54:	00004697          	auipc	a3,0x4
ffffffffc0202e58:	5bc68693          	addi	a3,a3,1468 # ffffffffc0207410 <default_pmm_manager+0x2d8>
ffffffffc0202e5c:	00004617          	auipc	a2,0x4
ffffffffc0202e60:	c4460613          	addi	a2,a2,-956 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0202e64:	1ed00593          	li	a1,493
ffffffffc0202e68:	00004517          	auipc	a0,0x4
ffffffffc0202e6c:	42050513          	addi	a0,a0,1056 # ffffffffc0207288 <default_pmm_manager+0x150>
ffffffffc0202e70:	e0afd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0202e74:	00004697          	auipc	a3,0x4
ffffffffc0202e78:	57468693          	addi	a3,a3,1396 # ffffffffc02073e8 <default_pmm_manager+0x2b0>
ffffffffc0202e7c:	00004617          	auipc	a2,0x4
ffffffffc0202e80:	c2460613          	addi	a2,a2,-988 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0202e84:	1e900593          	li	a1,489
ffffffffc0202e88:	00004517          	auipc	a0,0x4
ffffffffc0202e8c:	40050513          	addi	a0,a0,1024 # ffffffffc0207288 <default_pmm_manager+0x150>
ffffffffc0202e90:	deafd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202e94:	00004697          	auipc	a3,0x4
ffffffffc0202e98:	63468693          	addi	a3,a3,1588 # ffffffffc02074c8 <default_pmm_manager+0x390>
ffffffffc0202e9c:	00004617          	auipc	a2,0x4
ffffffffc0202ea0:	c0460613          	addi	a2,a2,-1020 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0202ea4:	1f900593          	li	a1,505
ffffffffc0202ea8:	00004517          	auipc	a0,0x4
ffffffffc0202eac:	3e050513          	addi	a0,a0,992 # ffffffffc0207288 <default_pmm_manager+0x150>
ffffffffc0202eb0:	dcafd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0202eb4:	00004697          	auipc	a3,0x4
ffffffffc0202eb8:	6b468693          	addi	a3,a3,1716 # ffffffffc0207568 <default_pmm_manager+0x430>
ffffffffc0202ebc:	00004617          	auipc	a2,0x4
ffffffffc0202ec0:	be460613          	addi	a2,a2,-1052 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0202ec4:	1fe00593          	li	a1,510
ffffffffc0202ec8:	00004517          	auipc	a0,0x4
ffffffffc0202ecc:	3c050513          	addi	a0,a0,960 # ffffffffc0207288 <default_pmm_manager+0x150>
ffffffffc0202ed0:	daafd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202ed4:	00004697          	auipc	a3,0x4
ffffffffc0202ed8:	5cc68693          	addi	a3,a3,1484 # ffffffffc02074a0 <default_pmm_manager+0x368>
ffffffffc0202edc:	00004617          	auipc	a2,0x4
ffffffffc0202ee0:	bc460613          	addi	a2,a2,-1084 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0202ee4:	1f600593          	li	a1,502
ffffffffc0202ee8:	00004517          	auipc	a0,0x4
ffffffffc0202eec:	3a050513          	addi	a0,a0,928 # ffffffffc0207288 <default_pmm_manager+0x150>
ffffffffc0202ef0:	d8afd0ef          	jal	ra,ffffffffc020047a <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202ef4:	86d6                	mv	a3,s5
ffffffffc0202ef6:	00004617          	auipc	a2,0x4
ffffffffc0202efa:	27a60613          	addi	a2,a2,634 # ffffffffc0207170 <default_pmm_manager+0x38>
ffffffffc0202efe:	1f500593          	li	a1,501
ffffffffc0202f02:	00004517          	auipc	a0,0x4
ffffffffc0202f06:	38650513          	addi	a0,a0,902 # ffffffffc0207288 <default_pmm_manager+0x150>
ffffffffc0202f0a:	d70fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202f0e:	00004697          	auipc	a3,0x4
ffffffffc0202f12:	5f268693          	addi	a3,a3,1522 # ffffffffc0207500 <default_pmm_manager+0x3c8>
ffffffffc0202f16:	00004617          	auipc	a2,0x4
ffffffffc0202f1a:	b8a60613          	addi	a2,a2,-1142 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0202f1e:	20300593          	li	a1,515
ffffffffc0202f22:	00004517          	auipc	a0,0x4
ffffffffc0202f26:	36650513          	addi	a0,a0,870 # ffffffffc0207288 <default_pmm_manager+0x150>
ffffffffc0202f2a:	d50fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202f2e:	00004697          	auipc	a3,0x4
ffffffffc0202f32:	69a68693          	addi	a3,a3,1690 # ffffffffc02075c8 <default_pmm_manager+0x490>
ffffffffc0202f36:	00004617          	auipc	a2,0x4
ffffffffc0202f3a:	b6a60613          	addi	a2,a2,-1174 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0202f3e:	20200593          	li	a1,514
ffffffffc0202f42:	00004517          	auipc	a0,0x4
ffffffffc0202f46:	34650513          	addi	a0,a0,838 # ffffffffc0207288 <default_pmm_manager+0x150>
ffffffffc0202f4a:	d30fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0202f4e:	00004697          	auipc	a3,0x4
ffffffffc0202f52:	66268693          	addi	a3,a3,1634 # ffffffffc02075b0 <default_pmm_manager+0x478>
ffffffffc0202f56:	00004617          	auipc	a2,0x4
ffffffffc0202f5a:	b4a60613          	addi	a2,a2,-1206 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0202f5e:	20100593          	li	a1,513
ffffffffc0202f62:	00004517          	auipc	a0,0x4
ffffffffc0202f66:	32650513          	addi	a0,a0,806 # ffffffffc0207288 <default_pmm_manager+0x150>
ffffffffc0202f6a:	d10fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0202f6e:	00004697          	auipc	a3,0x4
ffffffffc0202f72:	61268693          	addi	a3,a3,1554 # ffffffffc0207580 <default_pmm_manager+0x448>
ffffffffc0202f76:	00004617          	auipc	a2,0x4
ffffffffc0202f7a:	b2a60613          	addi	a2,a2,-1238 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0202f7e:	20000593          	li	a1,512
ffffffffc0202f82:	00004517          	auipc	a0,0x4
ffffffffc0202f86:	30650513          	addi	a0,a0,774 # ffffffffc0207288 <default_pmm_manager+0x150>
ffffffffc0202f8a:	cf0fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202f8e:	00004697          	auipc	a3,0x4
ffffffffc0202f92:	7aa68693          	addi	a3,a3,1962 # ffffffffc0207738 <default_pmm_manager+0x600>
ffffffffc0202f96:	00004617          	auipc	a2,0x4
ffffffffc0202f9a:	b0a60613          	addi	a2,a2,-1270 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0202f9e:	22f00593          	li	a1,559
ffffffffc0202fa2:	00004517          	auipc	a0,0x4
ffffffffc0202fa6:	2e650513          	addi	a0,a0,742 # ffffffffc0207288 <default_pmm_manager+0x150>
ffffffffc0202faa:	cd0fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0202fae:	00004697          	auipc	a3,0x4
ffffffffc0202fb2:	5a268693          	addi	a3,a3,1442 # ffffffffc0207550 <default_pmm_manager+0x418>
ffffffffc0202fb6:	00004617          	auipc	a2,0x4
ffffffffc0202fba:	aea60613          	addi	a2,a2,-1302 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0202fbe:	1fd00593          	li	a1,509
ffffffffc0202fc2:	00004517          	auipc	a0,0x4
ffffffffc0202fc6:	2c650513          	addi	a0,a0,710 # ffffffffc0207288 <default_pmm_manager+0x150>
ffffffffc0202fca:	cb0fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(*ptep & PTE_W);
ffffffffc0202fce:	00004697          	auipc	a3,0x4
ffffffffc0202fd2:	57268693          	addi	a3,a3,1394 # ffffffffc0207540 <default_pmm_manager+0x408>
ffffffffc0202fd6:	00004617          	auipc	a2,0x4
ffffffffc0202fda:	aca60613          	addi	a2,a2,-1334 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0202fde:	1fc00593          	li	a1,508
ffffffffc0202fe2:	00004517          	auipc	a0,0x4
ffffffffc0202fe6:	2a650513          	addi	a0,a0,678 # ffffffffc0207288 <default_pmm_manager+0x150>
ffffffffc0202fea:	c90fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0202fee:	00004697          	auipc	a3,0x4
ffffffffc0202ff2:	64a68693          	addi	a3,a3,1610 # ffffffffc0207638 <default_pmm_manager+0x500>
ffffffffc0202ff6:	00004617          	auipc	a2,0x4
ffffffffc0202ffa:	aaa60613          	addi	a2,a2,-1366 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0202ffe:	24000593          	li	a1,576
ffffffffc0203002:	00004517          	auipc	a0,0x4
ffffffffc0203006:	28650513          	addi	a0,a0,646 # ffffffffc0207288 <default_pmm_manager+0x150>
ffffffffc020300a:	c70fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(*ptep & PTE_U);
ffffffffc020300e:	00004697          	auipc	a3,0x4
ffffffffc0203012:	52268693          	addi	a3,a3,1314 # ffffffffc0207530 <default_pmm_manager+0x3f8>
ffffffffc0203016:	00004617          	auipc	a2,0x4
ffffffffc020301a:	a8a60613          	addi	a2,a2,-1398 # ffffffffc0206aa0 <commands+0x450>
ffffffffc020301e:	1fb00593          	li	a1,507
ffffffffc0203022:	00004517          	auipc	a0,0x4
ffffffffc0203026:	26650513          	addi	a0,a0,614 # ffffffffc0207288 <default_pmm_manager+0x150>
ffffffffc020302a:	c50fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020302e:	00004697          	auipc	a3,0x4
ffffffffc0203032:	45a68693          	addi	a3,a3,1114 # ffffffffc0207488 <default_pmm_manager+0x350>
ffffffffc0203036:	00004617          	auipc	a2,0x4
ffffffffc020303a:	a6a60613          	addi	a2,a2,-1430 # ffffffffc0206aa0 <commands+0x450>
ffffffffc020303e:	20800593          	li	a1,520
ffffffffc0203042:	00004517          	auipc	a0,0x4
ffffffffc0203046:	24650513          	addi	a0,a0,582 # ffffffffc0207288 <default_pmm_manager+0x150>
ffffffffc020304a:	c30fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc020304e:	00004697          	auipc	a3,0x4
ffffffffc0203052:	59268693          	addi	a3,a3,1426 # ffffffffc02075e0 <default_pmm_manager+0x4a8>
ffffffffc0203056:	00004617          	auipc	a2,0x4
ffffffffc020305a:	a4a60613          	addi	a2,a2,-1462 # ffffffffc0206aa0 <commands+0x450>
ffffffffc020305e:	20500593          	li	a1,517
ffffffffc0203062:	00004517          	auipc	a0,0x4
ffffffffc0203066:	22650513          	addi	a0,a0,550 # ffffffffc0207288 <default_pmm_manager+0x150>
ffffffffc020306a:	c10fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc020306e:	00004697          	auipc	a3,0x4
ffffffffc0203072:	40268693          	addi	a3,a3,1026 # ffffffffc0207470 <default_pmm_manager+0x338>
ffffffffc0203076:	00004617          	auipc	a2,0x4
ffffffffc020307a:	a2a60613          	addi	a2,a2,-1494 # ffffffffc0206aa0 <commands+0x450>
ffffffffc020307e:	20400593          	li	a1,516
ffffffffc0203082:	00004517          	auipc	a0,0x4
ffffffffc0203086:	20650513          	addi	a0,a0,518 # ffffffffc0207288 <default_pmm_manager+0x150>
ffffffffc020308a:	bf0fd0ef          	jal	ra,ffffffffc020047a <__panic>
    return KADDR(page2pa(page));
ffffffffc020308e:	00004617          	auipc	a2,0x4
ffffffffc0203092:	0e260613          	addi	a2,a2,226 # ffffffffc0207170 <default_pmm_manager+0x38>
ffffffffc0203096:	06900593          	li	a1,105
ffffffffc020309a:	00004517          	auipc	a0,0x4
ffffffffc020309e:	0fe50513          	addi	a0,a0,254 # ffffffffc0207198 <default_pmm_manager+0x60>
ffffffffc02030a2:	bd8fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02030a6:	00004697          	auipc	a3,0x4
ffffffffc02030aa:	56a68693          	addi	a3,a3,1386 # ffffffffc0207610 <default_pmm_manager+0x4d8>
ffffffffc02030ae:	00004617          	auipc	a2,0x4
ffffffffc02030b2:	9f260613          	addi	a2,a2,-1550 # ffffffffc0206aa0 <commands+0x450>
ffffffffc02030b6:	20f00593          	li	a1,527
ffffffffc02030ba:	00004517          	auipc	a0,0x4
ffffffffc02030be:	1ce50513          	addi	a0,a0,462 # ffffffffc0207288 <default_pmm_manager+0x150>
ffffffffc02030c2:	bb8fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02030c6:	00004697          	auipc	a3,0x4
ffffffffc02030ca:	50268693          	addi	a3,a3,1282 # ffffffffc02075c8 <default_pmm_manager+0x490>
ffffffffc02030ce:	00004617          	auipc	a2,0x4
ffffffffc02030d2:	9d260613          	addi	a2,a2,-1582 # ffffffffc0206aa0 <commands+0x450>
ffffffffc02030d6:	20d00593          	li	a1,525
ffffffffc02030da:	00004517          	auipc	a0,0x4
ffffffffc02030de:	1ae50513          	addi	a0,a0,430 # ffffffffc0207288 <default_pmm_manager+0x150>
ffffffffc02030e2:	b98fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p1) == 0);
ffffffffc02030e6:	00004697          	auipc	a3,0x4
ffffffffc02030ea:	51268693          	addi	a3,a3,1298 # ffffffffc02075f8 <default_pmm_manager+0x4c0>
ffffffffc02030ee:	00004617          	auipc	a2,0x4
ffffffffc02030f2:	9b260613          	addi	a2,a2,-1614 # ffffffffc0206aa0 <commands+0x450>
ffffffffc02030f6:	20c00593          	li	a1,524
ffffffffc02030fa:	00004517          	auipc	a0,0x4
ffffffffc02030fe:	18e50513          	addi	a0,a0,398 # ffffffffc0207288 <default_pmm_manager+0x150>
ffffffffc0203102:	b78fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203106:	00004697          	auipc	a3,0x4
ffffffffc020310a:	4c268693          	addi	a3,a3,1218 # ffffffffc02075c8 <default_pmm_manager+0x490>
ffffffffc020310e:	00004617          	auipc	a2,0x4
ffffffffc0203112:	99260613          	addi	a2,a2,-1646 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0203116:	20900593          	li	a1,521
ffffffffc020311a:	00004517          	auipc	a0,0x4
ffffffffc020311e:	16e50513          	addi	a0,a0,366 # ffffffffc0207288 <default_pmm_manager+0x150>
ffffffffc0203122:	b58fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p) == 1);
ffffffffc0203126:	00004697          	auipc	a3,0x4
ffffffffc020312a:	5fa68693          	addi	a3,a3,1530 # ffffffffc0207720 <default_pmm_manager+0x5e8>
ffffffffc020312e:	00004617          	auipc	a2,0x4
ffffffffc0203132:	97260613          	addi	a2,a2,-1678 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0203136:	22e00593          	li	a1,558
ffffffffc020313a:	00004517          	auipc	a0,0x4
ffffffffc020313e:	14e50513          	addi	a0,a0,334 # ffffffffc0207288 <default_pmm_manager+0x150>
ffffffffc0203142:	b38fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0203146:	00004697          	auipc	a3,0x4
ffffffffc020314a:	5a268693          	addi	a3,a3,1442 # ffffffffc02076e8 <default_pmm_manager+0x5b0>
ffffffffc020314e:	00004617          	auipc	a2,0x4
ffffffffc0203152:	95260613          	addi	a2,a2,-1710 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0203156:	22d00593          	li	a1,557
ffffffffc020315a:	00004517          	auipc	a0,0x4
ffffffffc020315e:	12e50513          	addi	a0,a0,302 # ffffffffc0207288 <default_pmm_manager+0x150>
ffffffffc0203162:	b18fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0203166:	00004697          	auipc	a3,0x4
ffffffffc020316a:	56a68693          	addi	a3,a3,1386 # ffffffffc02076d0 <default_pmm_manager+0x598>
ffffffffc020316e:	00004617          	auipc	a2,0x4
ffffffffc0203172:	93260613          	addi	a2,a2,-1742 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0203176:	22900593          	li	a1,553
ffffffffc020317a:	00004517          	auipc	a0,0x4
ffffffffc020317e:	10e50513          	addi	a0,a0,270 # ffffffffc0207288 <default_pmm_manager+0x150>
ffffffffc0203182:	af8fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0203186:	00004697          	auipc	a3,0x4
ffffffffc020318a:	4b268693          	addi	a3,a3,1202 # ffffffffc0207638 <default_pmm_manager+0x500>
ffffffffc020318e:	00004617          	auipc	a2,0x4
ffffffffc0203192:	91260613          	addi	a2,a2,-1774 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0203196:	21700593          	li	a1,535
ffffffffc020319a:	00004517          	auipc	a0,0x4
ffffffffc020319e:	0ee50513          	addi	a0,a0,238 # ffffffffc0207288 <default_pmm_manager+0x150>
ffffffffc02031a2:	ad8fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02031a6:	00004697          	auipc	a3,0x4
ffffffffc02031aa:	2ca68693          	addi	a3,a3,714 # ffffffffc0207470 <default_pmm_manager+0x338>
ffffffffc02031ae:	00004617          	auipc	a2,0x4
ffffffffc02031b2:	8f260613          	addi	a2,a2,-1806 # ffffffffc0206aa0 <commands+0x450>
ffffffffc02031b6:	1f100593          	li	a1,497
ffffffffc02031ba:	00004517          	auipc	a0,0x4
ffffffffc02031be:	0ce50513          	addi	a0,a0,206 # ffffffffc0207288 <default_pmm_manager+0x150>
ffffffffc02031c2:	ab8fd0ef          	jal	ra,ffffffffc020047a <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc02031c6:	00004617          	auipc	a2,0x4
ffffffffc02031ca:	faa60613          	addi	a2,a2,-86 # ffffffffc0207170 <default_pmm_manager+0x38>
ffffffffc02031ce:	1f400593          	li	a1,500
ffffffffc02031d2:	00004517          	auipc	a0,0x4
ffffffffc02031d6:	0b650513          	addi	a0,a0,182 # ffffffffc0207288 <default_pmm_manager+0x150>
ffffffffc02031da:	aa0fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02031de:	00004697          	auipc	a3,0x4
ffffffffc02031e2:	2aa68693          	addi	a3,a3,682 # ffffffffc0207488 <default_pmm_manager+0x350>
ffffffffc02031e6:	00004617          	auipc	a2,0x4
ffffffffc02031ea:	8ba60613          	addi	a2,a2,-1862 # ffffffffc0206aa0 <commands+0x450>
ffffffffc02031ee:	1f200593          	li	a1,498
ffffffffc02031f2:	00004517          	auipc	a0,0x4
ffffffffc02031f6:	09650513          	addi	a0,a0,150 # ffffffffc0207288 <default_pmm_manager+0x150>
ffffffffc02031fa:	a80fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02031fe:	00004697          	auipc	a3,0x4
ffffffffc0203202:	30268693          	addi	a3,a3,770 # ffffffffc0207500 <default_pmm_manager+0x3c8>
ffffffffc0203206:	00004617          	auipc	a2,0x4
ffffffffc020320a:	89a60613          	addi	a2,a2,-1894 # ffffffffc0206aa0 <commands+0x450>
ffffffffc020320e:	1fa00593          	li	a1,506
ffffffffc0203212:	00004517          	auipc	a0,0x4
ffffffffc0203216:	07650513          	addi	a0,a0,118 # ffffffffc0207288 <default_pmm_manager+0x150>
ffffffffc020321a:	a60fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc020321e:	00004697          	auipc	a3,0x4
ffffffffc0203222:	5c268693          	addi	a3,a3,1474 # ffffffffc02077e0 <default_pmm_manager+0x6a8>
ffffffffc0203226:	00004617          	auipc	a2,0x4
ffffffffc020322a:	87a60613          	addi	a2,a2,-1926 # ffffffffc0206aa0 <commands+0x450>
ffffffffc020322e:	23700593          	li	a1,567
ffffffffc0203232:	00004517          	auipc	a0,0x4
ffffffffc0203236:	05650513          	addi	a0,a0,86 # ffffffffc0207288 <default_pmm_manager+0x150>
ffffffffc020323a:	a40fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc020323e:	00004697          	auipc	a3,0x4
ffffffffc0203242:	56a68693          	addi	a3,a3,1386 # ffffffffc02077a8 <default_pmm_manager+0x670>
ffffffffc0203246:	00004617          	auipc	a2,0x4
ffffffffc020324a:	85a60613          	addi	a2,a2,-1958 # ffffffffc0206aa0 <commands+0x450>
ffffffffc020324e:	23400593          	li	a1,564
ffffffffc0203252:	00004517          	auipc	a0,0x4
ffffffffc0203256:	03650513          	addi	a0,a0,54 # ffffffffc0207288 <default_pmm_manager+0x150>
ffffffffc020325a:	a20fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p) == 2);
ffffffffc020325e:	00004697          	auipc	a3,0x4
ffffffffc0203262:	51a68693          	addi	a3,a3,1306 # ffffffffc0207778 <default_pmm_manager+0x640>
ffffffffc0203266:	00004617          	auipc	a2,0x4
ffffffffc020326a:	83a60613          	addi	a2,a2,-1990 # ffffffffc0206aa0 <commands+0x450>
ffffffffc020326e:	23000593          	li	a1,560
ffffffffc0203272:	00004517          	auipc	a0,0x4
ffffffffc0203276:	01650513          	addi	a0,a0,22 # ffffffffc0207288 <default_pmm_manager+0x150>
ffffffffc020327a:	a00fd0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc020327e <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020327e:	12058073          	sfence.vma	a1
}
ffffffffc0203282:	8082                	ret

ffffffffc0203284 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0203284:	7179                	addi	sp,sp,-48
ffffffffc0203286:	e84a                	sd	s2,16(sp)
ffffffffc0203288:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc020328a:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc020328c:	f022                	sd	s0,32(sp)
ffffffffc020328e:	ec26                	sd	s1,24(sp)
ffffffffc0203290:	e44e                	sd	s3,8(sp)
ffffffffc0203292:	f406                	sd	ra,40(sp)
ffffffffc0203294:	84ae                	mv	s1,a1
ffffffffc0203296:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0203298:	a25fe0ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
ffffffffc020329c:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc020329e:	cd05                	beqz	a0,ffffffffc02032d6 <pgdir_alloc_page+0x52>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc02032a0:	85aa                	mv	a1,a0
ffffffffc02032a2:	86ce                	mv	a3,s3
ffffffffc02032a4:	8626                	mv	a2,s1
ffffffffc02032a6:	854a                	mv	a0,s2
ffffffffc02032a8:	b46ff0ef          	jal	ra,ffffffffc02025ee <page_insert>
ffffffffc02032ac:	ed0d                	bnez	a0,ffffffffc02032e6 <pgdir_alloc_page+0x62>
        if (swap_init_ok) {
ffffffffc02032ae:	000af797          	auipc	a5,0xaf
ffffffffc02032b2:	50a7a783          	lw	a5,1290(a5) # ffffffffc02b27b8 <swap_init_ok>
ffffffffc02032b6:	c385                	beqz	a5,ffffffffc02032d6 <pgdir_alloc_page+0x52>
            if (check_mm_struct != NULL) {
ffffffffc02032b8:	000af517          	auipc	a0,0xaf
ffffffffc02032bc:	50853503          	ld	a0,1288(a0) # ffffffffc02b27c0 <check_mm_struct>
ffffffffc02032c0:	c919                	beqz	a0,ffffffffc02032d6 <pgdir_alloc_page+0x52>
                swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc02032c2:	4681                	li	a3,0
ffffffffc02032c4:	8622                	mv	a2,s0
ffffffffc02032c6:	85a6                	mv	a1,s1
ffffffffc02032c8:	7e4000ef          	jal	ra,ffffffffc0203aac <swap_map_swappable>
                assert(page_ref(page) == 1);
ffffffffc02032cc:	4018                	lw	a4,0(s0)
                page->pra_vaddr = la;
ffffffffc02032ce:	fc04                	sd	s1,56(s0)
                assert(page_ref(page) == 1);
ffffffffc02032d0:	4785                	li	a5,1
ffffffffc02032d2:	04f71663          	bne	a4,a5,ffffffffc020331e <pgdir_alloc_page+0x9a>
}
ffffffffc02032d6:	70a2                	ld	ra,40(sp)
ffffffffc02032d8:	8522                	mv	a0,s0
ffffffffc02032da:	7402                	ld	s0,32(sp)
ffffffffc02032dc:	64e2                	ld	s1,24(sp)
ffffffffc02032de:	6942                	ld	s2,16(sp)
ffffffffc02032e0:	69a2                	ld	s3,8(sp)
ffffffffc02032e2:	6145                	addi	sp,sp,48
ffffffffc02032e4:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02032e6:	100027f3          	csrr	a5,sstatus
ffffffffc02032ea:	8b89                	andi	a5,a5,2
ffffffffc02032ec:	eb99                	bnez	a5,ffffffffc0203302 <pgdir_alloc_page+0x7e>
        pmm_manager->free_pages(base, n);
ffffffffc02032ee:	000af797          	auipc	a5,0xaf
ffffffffc02032f2:	4aa7b783          	ld	a5,1194(a5) # ffffffffc02b2798 <pmm_manager>
ffffffffc02032f6:	739c                	ld	a5,32(a5)
ffffffffc02032f8:	8522                	mv	a0,s0
ffffffffc02032fa:	4585                	li	a1,1
ffffffffc02032fc:	9782                	jalr	a5
            return NULL;
ffffffffc02032fe:	4401                	li	s0,0
ffffffffc0203300:	bfd9                	j	ffffffffc02032d6 <pgdir_alloc_page+0x52>
        intr_disable();
ffffffffc0203302:	b20fd0ef          	jal	ra,ffffffffc0200622 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0203306:	000af797          	auipc	a5,0xaf
ffffffffc020330a:	4927b783          	ld	a5,1170(a5) # ffffffffc02b2798 <pmm_manager>
ffffffffc020330e:	739c                	ld	a5,32(a5)
ffffffffc0203310:	8522                	mv	a0,s0
ffffffffc0203312:	4585                	li	a1,1
ffffffffc0203314:	9782                	jalr	a5
            return NULL;
ffffffffc0203316:	4401                	li	s0,0
        intr_enable();
ffffffffc0203318:	b04fd0ef          	jal	ra,ffffffffc020061c <intr_enable>
ffffffffc020331c:	bf6d                	j	ffffffffc02032d6 <pgdir_alloc_page+0x52>
                assert(page_ref(page) == 1);
ffffffffc020331e:	00004697          	auipc	a3,0x4
ffffffffc0203322:	50a68693          	addi	a3,a3,1290 # ffffffffc0207828 <default_pmm_manager+0x6f0>
ffffffffc0203326:	00003617          	auipc	a2,0x3
ffffffffc020332a:	77a60613          	addi	a2,a2,1914 # ffffffffc0206aa0 <commands+0x450>
ffffffffc020332e:	1c800593          	li	a1,456
ffffffffc0203332:	00004517          	auipc	a0,0x4
ffffffffc0203336:	f5650513          	addi	a0,a0,-170 # ffffffffc0207288 <default_pmm_manager+0x150>
ffffffffc020333a:	940fd0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc020333e <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc020333e:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0203340:	00004617          	auipc	a2,0x4
ffffffffc0203344:	f0060613          	addi	a2,a2,-256 # ffffffffc0207240 <default_pmm_manager+0x108>
ffffffffc0203348:	06200593          	li	a1,98
ffffffffc020334c:	00004517          	auipc	a0,0x4
ffffffffc0203350:	e4c50513          	addi	a0,a0,-436 # ffffffffc0207198 <default_pmm_manager+0x60>
pa2page(uintptr_t pa) {
ffffffffc0203354:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0203356:	924fd0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc020335a <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc020335a:	7135                	addi	sp,sp,-160
ffffffffc020335c:	ed06                	sd	ra,152(sp)
ffffffffc020335e:	e922                	sd	s0,144(sp)
ffffffffc0203360:	e526                	sd	s1,136(sp)
ffffffffc0203362:	e14a                	sd	s2,128(sp)
ffffffffc0203364:	fcce                	sd	s3,120(sp)
ffffffffc0203366:	f8d2                	sd	s4,112(sp)
ffffffffc0203368:	f4d6                	sd	s5,104(sp)
ffffffffc020336a:	f0da                	sd	s6,96(sp)
ffffffffc020336c:	ecde                	sd	s7,88(sp)
ffffffffc020336e:	e8e2                	sd	s8,80(sp)
ffffffffc0203370:	e4e6                	sd	s9,72(sp)
ffffffffc0203372:	e0ea                	sd	s10,64(sp)
ffffffffc0203374:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0203376:	690010ef          	jal	ra,ffffffffc0204a06 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc020337a:	000af697          	auipc	a3,0xaf
ffffffffc020337e:	42e6b683          	ld	a3,1070(a3) # ffffffffc02b27a8 <max_swap_offset>
ffffffffc0203382:	010007b7          	lui	a5,0x1000
ffffffffc0203386:	ff968713          	addi	a4,a3,-7
ffffffffc020338a:	17e1                	addi	a5,a5,-8
ffffffffc020338c:	42e7e663          	bltu	a5,a4,ffffffffc02037b8 <swap_init+0x45e>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }
     

     sm = &swap_manager_fifo;
ffffffffc0203390:	000a4797          	auipc	a5,0xa4
ffffffffc0203394:	eb078793          	addi	a5,a5,-336 # ffffffffc02a7240 <swap_manager_fifo>
     int r = sm->init();
ffffffffc0203398:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc020339a:	000afb97          	auipc	s7,0xaf
ffffffffc020339e:	416b8b93          	addi	s7,s7,1046 # ffffffffc02b27b0 <sm>
ffffffffc02033a2:	00fbb023          	sd	a5,0(s7)
     int r = sm->init();
ffffffffc02033a6:	9702                	jalr	a4
ffffffffc02033a8:	892a                	mv	s2,a0
     
     if (r == 0)
ffffffffc02033aa:	c10d                	beqz	a0,ffffffffc02033cc <swap_init+0x72>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc02033ac:	60ea                	ld	ra,152(sp)
ffffffffc02033ae:	644a                	ld	s0,144(sp)
ffffffffc02033b0:	64aa                	ld	s1,136(sp)
ffffffffc02033b2:	79e6                	ld	s3,120(sp)
ffffffffc02033b4:	7a46                	ld	s4,112(sp)
ffffffffc02033b6:	7aa6                	ld	s5,104(sp)
ffffffffc02033b8:	7b06                	ld	s6,96(sp)
ffffffffc02033ba:	6be6                	ld	s7,88(sp)
ffffffffc02033bc:	6c46                	ld	s8,80(sp)
ffffffffc02033be:	6ca6                	ld	s9,72(sp)
ffffffffc02033c0:	6d06                	ld	s10,64(sp)
ffffffffc02033c2:	7de2                	ld	s11,56(sp)
ffffffffc02033c4:	854a                	mv	a0,s2
ffffffffc02033c6:	690a                	ld	s2,128(sp)
ffffffffc02033c8:	610d                	addi	sp,sp,160
ffffffffc02033ca:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02033cc:	000bb783          	ld	a5,0(s7)
ffffffffc02033d0:	00004517          	auipc	a0,0x4
ffffffffc02033d4:	4a050513          	addi	a0,a0,1184 # ffffffffc0207870 <default_pmm_manager+0x738>
    return listelm->next;
ffffffffc02033d8:	000ab417          	auipc	s0,0xab
ffffffffc02033dc:	2b840413          	addi	s0,s0,696 # ffffffffc02ae690 <free_area>
ffffffffc02033e0:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc02033e2:	4785                	li	a5,1
ffffffffc02033e4:	000af717          	auipc	a4,0xaf
ffffffffc02033e8:	3cf72a23          	sw	a5,980(a4) # ffffffffc02b27b8 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02033ec:	d95fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc02033f0:	641c                	ld	a5,8(s0)

static void
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
ffffffffc02033f2:	4d01                	li	s10,0
ffffffffc02033f4:	4d81                	li	s11,0
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc02033f6:	34878163          	beq	a5,s0,ffffffffc0203738 <swap_init+0x3de>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02033fa:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc02033fe:	8b09                	andi	a4,a4,2
ffffffffc0203400:	32070e63          	beqz	a4,ffffffffc020373c <swap_init+0x3e2>
        count ++, total += p->property;
ffffffffc0203404:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203408:	679c                	ld	a5,8(a5)
ffffffffc020340a:	2d85                	addiw	s11,s11,1
ffffffffc020340c:	01a70d3b          	addw	s10,a4,s10
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203410:	fe8795e3          	bne	a5,s0,ffffffffc02033fa <swap_init+0xa0>
     }
     assert(total == nr_free_pages());
ffffffffc0203414:	84ea                	mv	s1,s10
ffffffffc0203416:	979fe0ef          	jal	ra,ffffffffc0201d8e <nr_free_pages>
ffffffffc020341a:	42951763          	bne	a0,s1,ffffffffc0203848 <swap_init+0x4ee>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc020341e:	866a                	mv	a2,s10
ffffffffc0203420:	85ee                	mv	a1,s11
ffffffffc0203422:	00004517          	auipc	a0,0x4
ffffffffc0203426:	46650513          	addi	a0,a0,1126 # ffffffffc0207888 <default_pmm_manager+0x750>
ffffffffc020342a:	d57fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc020342e:	3b1000ef          	jal	ra,ffffffffc0203fde <mm_create>
ffffffffc0203432:	8aaa                	mv	s5,a0
     assert(mm != NULL);
ffffffffc0203434:	46050a63          	beqz	a0,ffffffffc02038a8 <swap_init+0x54e>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc0203438:	000af797          	auipc	a5,0xaf
ffffffffc020343c:	38878793          	addi	a5,a5,904 # ffffffffc02b27c0 <check_mm_struct>
ffffffffc0203440:	6398                	ld	a4,0(a5)
ffffffffc0203442:	3e071363          	bnez	a4,ffffffffc0203828 <swap_init+0x4ce>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203446:	000af717          	auipc	a4,0xaf
ffffffffc020344a:	33a70713          	addi	a4,a4,826 # ffffffffc02b2780 <boot_pgdir>
ffffffffc020344e:	00073b03          	ld	s6,0(a4)
     check_mm_struct = mm;
ffffffffc0203452:	e388                	sd	a0,0(a5)
     assert(pgdir[0] == 0);
ffffffffc0203454:	000b3783          	ld	a5,0(s6)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203458:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc020345c:	42079663          	bnez	a5,ffffffffc0203888 <swap_init+0x52e>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0203460:	6599                	lui	a1,0x6
ffffffffc0203462:	460d                	li	a2,3
ffffffffc0203464:	6505                	lui	a0,0x1
ffffffffc0203466:	3c1000ef          	jal	ra,ffffffffc0204026 <vma_create>
ffffffffc020346a:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc020346c:	52050a63          	beqz	a0,ffffffffc02039a0 <swap_init+0x646>

     insert_vma_struct(mm, vma);
ffffffffc0203470:	8556                	mv	a0,s5
ffffffffc0203472:	423000ef          	jal	ra,ffffffffc0204094 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc0203476:	00004517          	auipc	a0,0x4
ffffffffc020347a:	48250513          	addi	a0,a0,1154 # ffffffffc02078f8 <default_pmm_manager+0x7c0>
ffffffffc020347e:	d03fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0203482:	018ab503          	ld	a0,24(s5)
ffffffffc0203486:	4605                	li	a2,1
ffffffffc0203488:	6585                	lui	a1,0x1
ffffffffc020348a:	93ffe0ef          	jal	ra,ffffffffc0201dc8 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc020348e:	4c050963          	beqz	a0,ffffffffc0203960 <swap_init+0x606>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0203492:	00004517          	auipc	a0,0x4
ffffffffc0203496:	4b650513          	addi	a0,a0,1206 # ffffffffc0207948 <default_pmm_manager+0x810>
ffffffffc020349a:	000ab497          	auipc	s1,0xab
ffffffffc020349e:	22e48493          	addi	s1,s1,558 # ffffffffc02ae6c8 <check_rp>
ffffffffc02034a2:	cdffc0ef          	jal	ra,ffffffffc0200180 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02034a6:	000ab997          	auipc	s3,0xab
ffffffffc02034aa:	24298993          	addi	s3,s3,578 # ffffffffc02ae6e8 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02034ae:	8a26                	mv	s4,s1
          check_rp[i] = alloc_page();
ffffffffc02034b0:	4505                	li	a0,1
ffffffffc02034b2:	80bfe0ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
ffffffffc02034b6:	00aa3023          	sd	a0,0(s4)
          assert(check_rp[i] != NULL );
ffffffffc02034ba:	2c050f63          	beqz	a0,ffffffffc0203798 <swap_init+0x43e>
ffffffffc02034be:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc02034c0:	8b89                	andi	a5,a5,2
ffffffffc02034c2:	34079363          	bnez	a5,ffffffffc0203808 <swap_init+0x4ae>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02034c6:	0a21                	addi	s4,s4,8
ffffffffc02034c8:	ff3a14e3          	bne	s4,s3,ffffffffc02034b0 <swap_init+0x156>
     }
     list_entry_t free_list_store = free_list;
ffffffffc02034cc:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc02034ce:	000aba17          	auipc	s4,0xab
ffffffffc02034d2:	1faa0a13          	addi	s4,s4,506 # ffffffffc02ae6c8 <check_rp>
    elm->prev = elm->next = elm;
ffffffffc02034d6:	e000                	sd	s0,0(s0)
     list_entry_t free_list_store = free_list;
ffffffffc02034d8:	ec3e                	sd	a5,24(sp)
ffffffffc02034da:	641c                	ld	a5,8(s0)
ffffffffc02034dc:	e400                	sd	s0,8(s0)
ffffffffc02034de:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc02034e0:	481c                	lw	a5,16(s0)
ffffffffc02034e2:	f43e                	sd	a5,40(sp)
     nr_free = 0;
ffffffffc02034e4:	000ab797          	auipc	a5,0xab
ffffffffc02034e8:	1a07ae23          	sw	zero,444(a5) # ffffffffc02ae6a0 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc02034ec:	000a3503          	ld	a0,0(s4)
ffffffffc02034f0:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02034f2:	0a21                	addi	s4,s4,8
        free_pages(check_rp[i],1);
ffffffffc02034f4:	85bfe0ef          	jal	ra,ffffffffc0201d4e <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02034f8:	ff3a1ae3          	bne	s4,s3,ffffffffc02034ec <swap_init+0x192>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc02034fc:	01042a03          	lw	s4,16(s0)
ffffffffc0203500:	4791                	li	a5,4
ffffffffc0203502:	42fa1f63          	bne	s4,a5,ffffffffc0203940 <swap_init+0x5e6>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0203506:	00004517          	auipc	a0,0x4
ffffffffc020350a:	4ca50513          	addi	a0,a0,1226 # ffffffffc02079d0 <default_pmm_manager+0x898>
ffffffffc020350e:	c73fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203512:	6705                	lui	a4,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0203514:	000af797          	auipc	a5,0xaf
ffffffffc0203518:	2a07aa23          	sw	zero,692(a5) # ffffffffc02b27c8 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc020351c:	4629                	li	a2,10
ffffffffc020351e:	00c70023          	sb	a2,0(a4) # 1000 <_binary_obj___user_faultread_out_size-0x8ba8>
     assert(pgfault_num==1);
ffffffffc0203522:	000af697          	auipc	a3,0xaf
ffffffffc0203526:	2a66a683          	lw	a3,678(a3) # ffffffffc02b27c8 <pgfault_num>
ffffffffc020352a:	4585                	li	a1,1
ffffffffc020352c:	000af797          	auipc	a5,0xaf
ffffffffc0203530:	29c78793          	addi	a5,a5,668 # ffffffffc02b27c8 <pgfault_num>
ffffffffc0203534:	54b69663          	bne	a3,a1,ffffffffc0203a80 <swap_init+0x726>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0203538:	00c70823          	sb	a2,16(a4)
     assert(pgfault_num==1);
ffffffffc020353c:	4398                	lw	a4,0(a5)
ffffffffc020353e:	2701                	sext.w	a4,a4
ffffffffc0203540:	3ed71063          	bne	a4,a3,ffffffffc0203920 <swap_init+0x5c6>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203544:	6689                	lui	a3,0x2
ffffffffc0203546:	462d                	li	a2,11
ffffffffc0203548:	00c68023          	sb	a2,0(a3) # 2000 <_binary_obj___user_faultread_out_size-0x7ba8>
     assert(pgfault_num==2);
ffffffffc020354c:	4398                	lw	a4,0(a5)
ffffffffc020354e:	4589                	li	a1,2
ffffffffc0203550:	2701                	sext.w	a4,a4
ffffffffc0203552:	4ab71763          	bne	a4,a1,ffffffffc0203a00 <swap_init+0x6a6>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0203556:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc020355a:	4394                	lw	a3,0(a5)
ffffffffc020355c:	2681                	sext.w	a3,a3
ffffffffc020355e:	4ce69163          	bne	a3,a4,ffffffffc0203a20 <swap_init+0x6c6>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203562:	668d                	lui	a3,0x3
ffffffffc0203564:	4631                	li	a2,12
ffffffffc0203566:	00c68023          	sb	a2,0(a3) # 3000 <_binary_obj___user_faultread_out_size-0x6ba8>
     assert(pgfault_num==3);
ffffffffc020356a:	4398                	lw	a4,0(a5)
ffffffffc020356c:	458d                	li	a1,3
ffffffffc020356e:	2701                	sext.w	a4,a4
ffffffffc0203570:	4cb71863          	bne	a4,a1,ffffffffc0203a40 <swap_init+0x6e6>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0203574:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc0203578:	4394                	lw	a3,0(a5)
ffffffffc020357a:	2681                	sext.w	a3,a3
ffffffffc020357c:	4ee69263          	bne	a3,a4,ffffffffc0203a60 <swap_init+0x706>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203580:	6691                	lui	a3,0x4
ffffffffc0203582:	4635                	li	a2,13
ffffffffc0203584:	00c68023          	sb	a2,0(a3) # 4000 <_binary_obj___user_faultread_out_size-0x5ba8>
     assert(pgfault_num==4);
ffffffffc0203588:	4398                	lw	a4,0(a5)
ffffffffc020358a:	2701                	sext.w	a4,a4
ffffffffc020358c:	43471a63          	bne	a4,s4,ffffffffc02039c0 <swap_init+0x666>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0203590:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0203594:	439c                	lw	a5,0(a5)
ffffffffc0203596:	2781                	sext.w	a5,a5
ffffffffc0203598:	44e79463          	bne	a5,a4,ffffffffc02039e0 <swap_init+0x686>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc020359c:	481c                	lw	a5,16(s0)
ffffffffc020359e:	2c079563          	bnez	a5,ffffffffc0203868 <swap_init+0x50e>
ffffffffc02035a2:	000ab797          	auipc	a5,0xab
ffffffffc02035a6:	14678793          	addi	a5,a5,326 # ffffffffc02ae6e8 <swap_in_seq_no>
ffffffffc02035aa:	000ab717          	auipc	a4,0xab
ffffffffc02035ae:	16670713          	addi	a4,a4,358 # ffffffffc02ae710 <swap_out_seq_no>
ffffffffc02035b2:	000ab617          	auipc	a2,0xab
ffffffffc02035b6:	15e60613          	addi	a2,a2,350 # ffffffffc02ae710 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc02035ba:	56fd                	li	a3,-1
ffffffffc02035bc:	c394                	sw	a3,0(a5)
ffffffffc02035be:	c314                	sw	a3,0(a4)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc02035c0:	0791                	addi	a5,a5,4
ffffffffc02035c2:	0711                	addi	a4,a4,4
ffffffffc02035c4:	fec79ce3          	bne	a5,a2,ffffffffc02035bc <swap_init+0x262>
ffffffffc02035c8:	000ab717          	auipc	a4,0xab
ffffffffc02035cc:	0e070713          	addi	a4,a4,224 # ffffffffc02ae6a8 <check_ptep>
ffffffffc02035d0:	000ab697          	auipc	a3,0xab
ffffffffc02035d4:	0f868693          	addi	a3,a3,248 # ffffffffc02ae6c8 <check_rp>
ffffffffc02035d8:	6585                	lui	a1,0x1
    if (PPN(pa) >= npage) {
ffffffffc02035da:	000afc17          	auipc	s8,0xaf
ffffffffc02035de:	1aec0c13          	addi	s8,s8,430 # ffffffffc02b2788 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02035e2:	000afc97          	auipc	s9,0xaf
ffffffffc02035e6:	1aec8c93          	addi	s9,s9,430 # ffffffffc02b2790 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc02035ea:	00073023          	sd	zero,0(a4)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc02035ee:	4601                	li	a2,0
ffffffffc02035f0:	855a                	mv	a0,s6
ffffffffc02035f2:	e836                	sd	a3,16(sp)
ffffffffc02035f4:	e42e                	sd	a1,8(sp)
         check_ptep[i]=0;
ffffffffc02035f6:	e03a                	sd	a4,0(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc02035f8:	fd0fe0ef          	jal	ra,ffffffffc0201dc8 <get_pte>
ffffffffc02035fc:	6702                	ld	a4,0(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc02035fe:	65a2                	ld	a1,8(sp)
ffffffffc0203600:	66c2                	ld	a3,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203602:	e308                	sd	a0,0(a4)
         assert(check_ptep[i] != NULL);
ffffffffc0203604:	1c050663          	beqz	a0,ffffffffc02037d0 <swap_init+0x476>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0203608:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc020360a:	0017f613          	andi	a2,a5,1
ffffffffc020360e:	1e060163          	beqz	a2,ffffffffc02037f0 <swap_init+0x496>
    if (PPN(pa) >= npage) {
ffffffffc0203612:	000c3603          	ld	a2,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203616:	078a                	slli	a5,a5,0x2
ffffffffc0203618:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020361a:	14c7f363          	bgeu	a5,a2,ffffffffc0203760 <swap_init+0x406>
    return &pages[PPN(pa) - nbase];
ffffffffc020361e:	00005617          	auipc	a2,0x5
ffffffffc0203622:	43a60613          	addi	a2,a2,1082 # ffffffffc0208a58 <nbase>
ffffffffc0203626:	00063a03          	ld	s4,0(a2)
ffffffffc020362a:	000cb603          	ld	a2,0(s9)
ffffffffc020362e:	6288                	ld	a0,0(a3)
ffffffffc0203630:	414787b3          	sub	a5,a5,s4
ffffffffc0203634:	079a                	slli	a5,a5,0x6
ffffffffc0203636:	97b2                	add	a5,a5,a2
ffffffffc0203638:	14f51063          	bne	a0,a5,ffffffffc0203778 <swap_init+0x41e>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020363c:	6785                	lui	a5,0x1
ffffffffc020363e:	95be                	add	a1,a1,a5
ffffffffc0203640:	6795                	lui	a5,0x5
ffffffffc0203642:	0721                	addi	a4,a4,8
ffffffffc0203644:	06a1                	addi	a3,a3,8
ffffffffc0203646:	faf592e3          	bne	a1,a5,ffffffffc02035ea <swap_init+0x290>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc020364a:	00004517          	auipc	a0,0x4
ffffffffc020364e:	42e50513          	addi	a0,a0,1070 # ffffffffc0207a78 <default_pmm_manager+0x940>
ffffffffc0203652:	b2ffc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    int ret = sm->check_swap();
ffffffffc0203656:	000bb783          	ld	a5,0(s7)
ffffffffc020365a:	7f9c                	ld	a5,56(a5)
ffffffffc020365c:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc020365e:	32051163          	bnez	a0,ffffffffc0203980 <swap_init+0x626>

     nr_free = nr_free_store;
ffffffffc0203662:	77a2                	ld	a5,40(sp)
ffffffffc0203664:	c81c                	sw	a5,16(s0)
     free_list = free_list_store;
ffffffffc0203666:	67e2                	ld	a5,24(sp)
ffffffffc0203668:	e01c                	sd	a5,0(s0)
ffffffffc020366a:	7782                	ld	a5,32(sp)
ffffffffc020366c:	e41c                	sd	a5,8(s0)

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc020366e:	6088                	ld	a0,0(s1)
ffffffffc0203670:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203672:	04a1                	addi	s1,s1,8
         free_pages(check_rp[i],1);
ffffffffc0203674:	edafe0ef          	jal	ra,ffffffffc0201d4e <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203678:	ff349be3          	bne	s1,s3,ffffffffc020366e <swap_init+0x314>
     } 

     //free_page(pte2page(*temp_ptep));

     mm->pgdir = NULL;
ffffffffc020367c:	000abc23          	sd	zero,24(s5)
     mm_destroy(mm);
ffffffffc0203680:	8556                	mv	a0,s5
ffffffffc0203682:	2e3000ef          	jal	ra,ffffffffc0204164 <mm_destroy>
     check_mm_struct = NULL;

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0203686:	000af797          	auipc	a5,0xaf
ffffffffc020368a:	0fa78793          	addi	a5,a5,250 # ffffffffc02b2780 <boot_pgdir>
ffffffffc020368e:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0203690:	000c3703          	ld	a4,0(s8)
     check_mm_struct = NULL;
ffffffffc0203694:	000af697          	auipc	a3,0xaf
ffffffffc0203698:	1206b623          	sd	zero,300(a3) # ffffffffc02b27c0 <check_mm_struct>
    return pa2page(PDE_ADDR(pde));
ffffffffc020369c:	639c                	ld	a5,0(a5)
ffffffffc020369e:	078a                	slli	a5,a5,0x2
ffffffffc02036a0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02036a2:	0ae7fd63          	bgeu	a5,a4,ffffffffc020375c <swap_init+0x402>
    return &pages[PPN(pa) - nbase];
ffffffffc02036a6:	414786b3          	sub	a3,a5,s4
ffffffffc02036aa:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc02036ac:	8699                	srai	a3,a3,0x6
ffffffffc02036ae:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc02036b0:	00c69793          	slli	a5,a3,0xc
ffffffffc02036b4:	83b1                	srli	a5,a5,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc02036b6:	000cb503          	ld	a0,0(s9)
    return page2ppn(page) << PGSHIFT;
ffffffffc02036ba:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02036bc:	22e7f663          	bgeu	a5,a4,ffffffffc02038e8 <swap_init+0x58e>
     free_page(pde2page(pd0[0]));
ffffffffc02036c0:	000af797          	auipc	a5,0xaf
ffffffffc02036c4:	0e07b783          	ld	a5,224(a5) # ffffffffc02b27a0 <va_pa_offset>
ffffffffc02036c8:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02036ca:	629c                	ld	a5,0(a3)
ffffffffc02036cc:	078a                	slli	a5,a5,0x2
ffffffffc02036ce:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02036d0:	08e7f663          	bgeu	a5,a4,ffffffffc020375c <swap_init+0x402>
    return &pages[PPN(pa) - nbase];
ffffffffc02036d4:	414787b3          	sub	a5,a5,s4
ffffffffc02036d8:	079a                	slli	a5,a5,0x6
ffffffffc02036da:	953e                	add	a0,a0,a5
ffffffffc02036dc:	4585                	li	a1,1
ffffffffc02036de:	e70fe0ef          	jal	ra,ffffffffc0201d4e <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02036e2:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc02036e6:	000c3703          	ld	a4,0(s8)
    return pa2page(PDE_ADDR(pde));
ffffffffc02036ea:	078a                	slli	a5,a5,0x2
ffffffffc02036ec:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02036ee:	06e7f763          	bgeu	a5,a4,ffffffffc020375c <swap_init+0x402>
    return &pages[PPN(pa) - nbase];
ffffffffc02036f2:	000cb503          	ld	a0,0(s9)
ffffffffc02036f6:	414787b3          	sub	a5,a5,s4
ffffffffc02036fa:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc02036fc:	4585                	li	a1,1
ffffffffc02036fe:	953e                	add	a0,a0,a5
ffffffffc0203700:	e4efe0ef          	jal	ra,ffffffffc0201d4e <free_pages>
     pgdir[0] = 0;
ffffffffc0203704:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc0203708:	12000073          	sfence.vma
    return listelm->next;
ffffffffc020370c:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc020370e:	00878a63          	beq	a5,s0,ffffffffc0203722 <swap_init+0x3c8>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0203712:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203716:	679c                	ld	a5,8(a5)
ffffffffc0203718:	3dfd                	addiw	s11,s11,-1
ffffffffc020371a:	40ed0d3b          	subw	s10,s10,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc020371e:	fe879ae3          	bne	a5,s0,ffffffffc0203712 <swap_init+0x3b8>
     }
     assert(count==0);
ffffffffc0203722:	1c0d9f63          	bnez	s11,ffffffffc0203900 <swap_init+0x5a6>
     assert(total==0);
ffffffffc0203726:	1a0d1163          	bnez	s10,ffffffffc02038c8 <swap_init+0x56e>

     cprintf("check_swap() succeeded!\n");
ffffffffc020372a:	00004517          	auipc	a0,0x4
ffffffffc020372e:	39e50513          	addi	a0,a0,926 # ffffffffc0207ac8 <default_pmm_manager+0x990>
ffffffffc0203732:	a4ffc0ef          	jal	ra,ffffffffc0200180 <cprintf>
}
ffffffffc0203736:	b99d                	j	ffffffffc02033ac <swap_init+0x52>
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203738:	4481                	li	s1,0
ffffffffc020373a:	b9f1                	j	ffffffffc0203416 <swap_init+0xbc>
        assert(PageProperty(p));
ffffffffc020373c:	00003697          	auipc	a3,0x3
ffffffffc0203740:	65468693          	addi	a3,a3,1620 # ffffffffc0206d90 <commands+0x740>
ffffffffc0203744:	00003617          	auipc	a2,0x3
ffffffffc0203748:	35c60613          	addi	a2,a2,860 # ffffffffc0206aa0 <commands+0x450>
ffffffffc020374c:	0bc00593          	li	a1,188
ffffffffc0203750:	00004517          	auipc	a0,0x4
ffffffffc0203754:	11050513          	addi	a0,a0,272 # ffffffffc0207860 <default_pmm_manager+0x728>
ffffffffc0203758:	d23fc0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc020375c:	be3ff0ef          	jal	ra,ffffffffc020333e <pa2page.part.0>
        panic("pa2page called with invalid pa");
ffffffffc0203760:	00004617          	auipc	a2,0x4
ffffffffc0203764:	ae060613          	addi	a2,a2,-1312 # ffffffffc0207240 <default_pmm_manager+0x108>
ffffffffc0203768:	06200593          	li	a1,98
ffffffffc020376c:	00004517          	auipc	a0,0x4
ffffffffc0203770:	a2c50513          	addi	a0,a0,-1492 # ffffffffc0207198 <default_pmm_manager+0x60>
ffffffffc0203774:	d07fc0ef          	jal	ra,ffffffffc020047a <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0203778:	00004697          	auipc	a3,0x4
ffffffffc020377c:	2d868693          	addi	a3,a3,728 # ffffffffc0207a50 <default_pmm_manager+0x918>
ffffffffc0203780:	00003617          	auipc	a2,0x3
ffffffffc0203784:	32060613          	addi	a2,a2,800 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0203788:	0fc00593          	li	a1,252
ffffffffc020378c:	00004517          	auipc	a0,0x4
ffffffffc0203790:	0d450513          	addi	a0,a0,212 # ffffffffc0207860 <default_pmm_manager+0x728>
ffffffffc0203794:	ce7fc0ef          	jal	ra,ffffffffc020047a <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0203798:	00004697          	auipc	a3,0x4
ffffffffc020379c:	1d868693          	addi	a3,a3,472 # ffffffffc0207970 <default_pmm_manager+0x838>
ffffffffc02037a0:	00003617          	auipc	a2,0x3
ffffffffc02037a4:	30060613          	addi	a2,a2,768 # ffffffffc0206aa0 <commands+0x450>
ffffffffc02037a8:	0dc00593          	li	a1,220
ffffffffc02037ac:	00004517          	auipc	a0,0x4
ffffffffc02037b0:	0b450513          	addi	a0,a0,180 # ffffffffc0207860 <default_pmm_manager+0x728>
ffffffffc02037b4:	cc7fc0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc02037b8:	00004617          	auipc	a2,0x4
ffffffffc02037bc:	08860613          	addi	a2,a2,136 # ffffffffc0207840 <default_pmm_manager+0x708>
ffffffffc02037c0:	02800593          	li	a1,40
ffffffffc02037c4:	00004517          	auipc	a0,0x4
ffffffffc02037c8:	09c50513          	addi	a0,a0,156 # ffffffffc0207860 <default_pmm_manager+0x728>
ffffffffc02037cc:	caffc0ef          	jal	ra,ffffffffc020047a <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc02037d0:	00004697          	auipc	a3,0x4
ffffffffc02037d4:	26868693          	addi	a3,a3,616 # ffffffffc0207a38 <default_pmm_manager+0x900>
ffffffffc02037d8:	00003617          	auipc	a2,0x3
ffffffffc02037dc:	2c860613          	addi	a2,a2,712 # ffffffffc0206aa0 <commands+0x450>
ffffffffc02037e0:	0fb00593          	li	a1,251
ffffffffc02037e4:	00004517          	auipc	a0,0x4
ffffffffc02037e8:	07c50513          	addi	a0,a0,124 # ffffffffc0207860 <default_pmm_manager+0x728>
ffffffffc02037ec:	c8ffc0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02037f0:	00004617          	auipc	a2,0x4
ffffffffc02037f4:	a7060613          	addi	a2,a2,-1424 # ffffffffc0207260 <default_pmm_manager+0x128>
ffffffffc02037f8:	07400593          	li	a1,116
ffffffffc02037fc:	00004517          	auipc	a0,0x4
ffffffffc0203800:	99c50513          	addi	a0,a0,-1636 # ffffffffc0207198 <default_pmm_manager+0x60>
ffffffffc0203804:	c77fc0ef          	jal	ra,ffffffffc020047a <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0203808:	00004697          	auipc	a3,0x4
ffffffffc020380c:	18068693          	addi	a3,a3,384 # ffffffffc0207988 <default_pmm_manager+0x850>
ffffffffc0203810:	00003617          	auipc	a2,0x3
ffffffffc0203814:	29060613          	addi	a2,a2,656 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0203818:	0dd00593          	li	a1,221
ffffffffc020381c:	00004517          	auipc	a0,0x4
ffffffffc0203820:	04450513          	addi	a0,a0,68 # ffffffffc0207860 <default_pmm_manager+0x728>
ffffffffc0203824:	c57fc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0203828:	00004697          	auipc	a3,0x4
ffffffffc020382c:	09868693          	addi	a3,a3,152 # ffffffffc02078c0 <default_pmm_manager+0x788>
ffffffffc0203830:	00003617          	auipc	a2,0x3
ffffffffc0203834:	27060613          	addi	a2,a2,624 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0203838:	0c700593          	li	a1,199
ffffffffc020383c:	00004517          	auipc	a0,0x4
ffffffffc0203840:	02450513          	addi	a0,a0,36 # ffffffffc0207860 <default_pmm_manager+0x728>
ffffffffc0203844:	c37fc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(total == nr_free_pages());
ffffffffc0203848:	00003697          	auipc	a3,0x3
ffffffffc020384c:	57068693          	addi	a3,a3,1392 # ffffffffc0206db8 <commands+0x768>
ffffffffc0203850:	00003617          	auipc	a2,0x3
ffffffffc0203854:	25060613          	addi	a2,a2,592 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0203858:	0bf00593          	li	a1,191
ffffffffc020385c:	00004517          	auipc	a0,0x4
ffffffffc0203860:	00450513          	addi	a0,a0,4 # ffffffffc0207860 <default_pmm_manager+0x728>
ffffffffc0203864:	c17fc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert( nr_free == 0);         
ffffffffc0203868:	00003697          	auipc	a3,0x3
ffffffffc020386c:	6f868693          	addi	a3,a3,1784 # ffffffffc0206f60 <commands+0x910>
ffffffffc0203870:	00003617          	auipc	a2,0x3
ffffffffc0203874:	23060613          	addi	a2,a2,560 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0203878:	0f300593          	li	a1,243
ffffffffc020387c:	00004517          	auipc	a0,0x4
ffffffffc0203880:	fe450513          	addi	a0,a0,-28 # ffffffffc0207860 <default_pmm_manager+0x728>
ffffffffc0203884:	bf7fc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgdir[0] == 0);
ffffffffc0203888:	00004697          	auipc	a3,0x4
ffffffffc020388c:	05068693          	addi	a3,a3,80 # ffffffffc02078d8 <default_pmm_manager+0x7a0>
ffffffffc0203890:	00003617          	auipc	a2,0x3
ffffffffc0203894:	21060613          	addi	a2,a2,528 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0203898:	0cc00593          	li	a1,204
ffffffffc020389c:	00004517          	auipc	a0,0x4
ffffffffc02038a0:	fc450513          	addi	a0,a0,-60 # ffffffffc0207860 <default_pmm_manager+0x728>
ffffffffc02038a4:	bd7fc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(mm != NULL);
ffffffffc02038a8:	00004697          	auipc	a3,0x4
ffffffffc02038ac:	00868693          	addi	a3,a3,8 # ffffffffc02078b0 <default_pmm_manager+0x778>
ffffffffc02038b0:	00003617          	auipc	a2,0x3
ffffffffc02038b4:	1f060613          	addi	a2,a2,496 # ffffffffc0206aa0 <commands+0x450>
ffffffffc02038b8:	0c400593          	li	a1,196
ffffffffc02038bc:	00004517          	auipc	a0,0x4
ffffffffc02038c0:	fa450513          	addi	a0,a0,-92 # ffffffffc0207860 <default_pmm_manager+0x728>
ffffffffc02038c4:	bb7fc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(total==0);
ffffffffc02038c8:	00004697          	auipc	a3,0x4
ffffffffc02038cc:	1f068693          	addi	a3,a3,496 # ffffffffc0207ab8 <default_pmm_manager+0x980>
ffffffffc02038d0:	00003617          	auipc	a2,0x3
ffffffffc02038d4:	1d060613          	addi	a2,a2,464 # ffffffffc0206aa0 <commands+0x450>
ffffffffc02038d8:	11e00593          	li	a1,286
ffffffffc02038dc:	00004517          	auipc	a0,0x4
ffffffffc02038e0:	f8450513          	addi	a0,a0,-124 # ffffffffc0207860 <default_pmm_manager+0x728>
ffffffffc02038e4:	b97fc0ef          	jal	ra,ffffffffc020047a <__panic>
    return KADDR(page2pa(page));
ffffffffc02038e8:	00004617          	auipc	a2,0x4
ffffffffc02038ec:	88860613          	addi	a2,a2,-1912 # ffffffffc0207170 <default_pmm_manager+0x38>
ffffffffc02038f0:	06900593          	li	a1,105
ffffffffc02038f4:	00004517          	auipc	a0,0x4
ffffffffc02038f8:	8a450513          	addi	a0,a0,-1884 # ffffffffc0207198 <default_pmm_manager+0x60>
ffffffffc02038fc:	b7ffc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(count==0);
ffffffffc0203900:	00004697          	auipc	a3,0x4
ffffffffc0203904:	1a868693          	addi	a3,a3,424 # ffffffffc0207aa8 <default_pmm_manager+0x970>
ffffffffc0203908:	00003617          	auipc	a2,0x3
ffffffffc020390c:	19860613          	addi	a2,a2,408 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0203910:	11d00593          	li	a1,285
ffffffffc0203914:	00004517          	auipc	a0,0x4
ffffffffc0203918:	f4c50513          	addi	a0,a0,-180 # ffffffffc0207860 <default_pmm_manager+0x728>
ffffffffc020391c:	b5ffc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgfault_num==1);
ffffffffc0203920:	00004697          	auipc	a3,0x4
ffffffffc0203924:	0d868693          	addi	a3,a3,216 # ffffffffc02079f8 <default_pmm_manager+0x8c0>
ffffffffc0203928:	00003617          	auipc	a2,0x3
ffffffffc020392c:	17860613          	addi	a2,a2,376 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0203930:	09500593          	li	a1,149
ffffffffc0203934:	00004517          	auipc	a0,0x4
ffffffffc0203938:	f2c50513          	addi	a0,a0,-212 # ffffffffc0207860 <default_pmm_manager+0x728>
ffffffffc020393c:	b3ffc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203940:	00004697          	auipc	a3,0x4
ffffffffc0203944:	06868693          	addi	a3,a3,104 # ffffffffc02079a8 <default_pmm_manager+0x870>
ffffffffc0203948:	00003617          	auipc	a2,0x3
ffffffffc020394c:	15860613          	addi	a2,a2,344 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0203950:	0ea00593          	li	a1,234
ffffffffc0203954:	00004517          	auipc	a0,0x4
ffffffffc0203958:	f0c50513          	addi	a0,a0,-244 # ffffffffc0207860 <default_pmm_manager+0x728>
ffffffffc020395c:	b1ffc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0203960:	00004697          	auipc	a3,0x4
ffffffffc0203964:	fd068693          	addi	a3,a3,-48 # ffffffffc0207930 <default_pmm_manager+0x7f8>
ffffffffc0203968:	00003617          	auipc	a2,0x3
ffffffffc020396c:	13860613          	addi	a2,a2,312 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0203970:	0d700593          	li	a1,215
ffffffffc0203974:	00004517          	auipc	a0,0x4
ffffffffc0203978:	eec50513          	addi	a0,a0,-276 # ffffffffc0207860 <default_pmm_manager+0x728>
ffffffffc020397c:	afffc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(ret==0);
ffffffffc0203980:	00004697          	auipc	a3,0x4
ffffffffc0203984:	12068693          	addi	a3,a3,288 # ffffffffc0207aa0 <default_pmm_manager+0x968>
ffffffffc0203988:	00003617          	auipc	a2,0x3
ffffffffc020398c:	11860613          	addi	a2,a2,280 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0203990:	10200593          	li	a1,258
ffffffffc0203994:	00004517          	auipc	a0,0x4
ffffffffc0203998:	ecc50513          	addi	a0,a0,-308 # ffffffffc0207860 <default_pmm_manager+0x728>
ffffffffc020399c:	adffc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(vma != NULL);
ffffffffc02039a0:	00004697          	auipc	a3,0x4
ffffffffc02039a4:	f4868693          	addi	a3,a3,-184 # ffffffffc02078e8 <default_pmm_manager+0x7b0>
ffffffffc02039a8:	00003617          	auipc	a2,0x3
ffffffffc02039ac:	0f860613          	addi	a2,a2,248 # ffffffffc0206aa0 <commands+0x450>
ffffffffc02039b0:	0cf00593          	li	a1,207
ffffffffc02039b4:	00004517          	auipc	a0,0x4
ffffffffc02039b8:	eac50513          	addi	a0,a0,-340 # ffffffffc0207860 <default_pmm_manager+0x728>
ffffffffc02039bc:	abffc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgfault_num==4);
ffffffffc02039c0:	00004697          	auipc	a3,0x4
ffffffffc02039c4:	06868693          	addi	a3,a3,104 # ffffffffc0207a28 <default_pmm_manager+0x8f0>
ffffffffc02039c8:	00003617          	auipc	a2,0x3
ffffffffc02039cc:	0d860613          	addi	a2,a2,216 # ffffffffc0206aa0 <commands+0x450>
ffffffffc02039d0:	09f00593          	li	a1,159
ffffffffc02039d4:	00004517          	auipc	a0,0x4
ffffffffc02039d8:	e8c50513          	addi	a0,a0,-372 # ffffffffc0207860 <default_pmm_manager+0x728>
ffffffffc02039dc:	a9ffc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgfault_num==4);
ffffffffc02039e0:	00004697          	auipc	a3,0x4
ffffffffc02039e4:	04868693          	addi	a3,a3,72 # ffffffffc0207a28 <default_pmm_manager+0x8f0>
ffffffffc02039e8:	00003617          	auipc	a2,0x3
ffffffffc02039ec:	0b860613          	addi	a2,a2,184 # ffffffffc0206aa0 <commands+0x450>
ffffffffc02039f0:	0a100593          	li	a1,161
ffffffffc02039f4:	00004517          	auipc	a0,0x4
ffffffffc02039f8:	e6c50513          	addi	a0,a0,-404 # ffffffffc0207860 <default_pmm_manager+0x728>
ffffffffc02039fc:	a7ffc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgfault_num==2);
ffffffffc0203a00:	00004697          	auipc	a3,0x4
ffffffffc0203a04:	00868693          	addi	a3,a3,8 # ffffffffc0207a08 <default_pmm_manager+0x8d0>
ffffffffc0203a08:	00003617          	auipc	a2,0x3
ffffffffc0203a0c:	09860613          	addi	a2,a2,152 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0203a10:	09700593          	li	a1,151
ffffffffc0203a14:	00004517          	auipc	a0,0x4
ffffffffc0203a18:	e4c50513          	addi	a0,a0,-436 # ffffffffc0207860 <default_pmm_manager+0x728>
ffffffffc0203a1c:	a5ffc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgfault_num==2);
ffffffffc0203a20:	00004697          	auipc	a3,0x4
ffffffffc0203a24:	fe868693          	addi	a3,a3,-24 # ffffffffc0207a08 <default_pmm_manager+0x8d0>
ffffffffc0203a28:	00003617          	auipc	a2,0x3
ffffffffc0203a2c:	07860613          	addi	a2,a2,120 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0203a30:	09900593          	li	a1,153
ffffffffc0203a34:	00004517          	auipc	a0,0x4
ffffffffc0203a38:	e2c50513          	addi	a0,a0,-468 # ffffffffc0207860 <default_pmm_manager+0x728>
ffffffffc0203a3c:	a3ffc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgfault_num==3);
ffffffffc0203a40:	00004697          	auipc	a3,0x4
ffffffffc0203a44:	fd868693          	addi	a3,a3,-40 # ffffffffc0207a18 <default_pmm_manager+0x8e0>
ffffffffc0203a48:	00003617          	auipc	a2,0x3
ffffffffc0203a4c:	05860613          	addi	a2,a2,88 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0203a50:	09b00593          	li	a1,155
ffffffffc0203a54:	00004517          	auipc	a0,0x4
ffffffffc0203a58:	e0c50513          	addi	a0,a0,-500 # ffffffffc0207860 <default_pmm_manager+0x728>
ffffffffc0203a5c:	a1ffc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgfault_num==3);
ffffffffc0203a60:	00004697          	auipc	a3,0x4
ffffffffc0203a64:	fb868693          	addi	a3,a3,-72 # ffffffffc0207a18 <default_pmm_manager+0x8e0>
ffffffffc0203a68:	00003617          	auipc	a2,0x3
ffffffffc0203a6c:	03860613          	addi	a2,a2,56 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0203a70:	09d00593          	li	a1,157
ffffffffc0203a74:	00004517          	auipc	a0,0x4
ffffffffc0203a78:	dec50513          	addi	a0,a0,-532 # ffffffffc0207860 <default_pmm_manager+0x728>
ffffffffc0203a7c:	9fffc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgfault_num==1);
ffffffffc0203a80:	00004697          	auipc	a3,0x4
ffffffffc0203a84:	f7868693          	addi	a3,a3,-136 # ffffffffc02079f8 <default_pmm_manager+0x8c0>
ffffffffc0203a88:	00003617          	auipc	a2,0x3
ffffffffc0203a8c:	01860613          	addi	a2,a2,24 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0203a90:	09300593          	li	a1,147
ffffffffc0203a94:	00004517          	auipc	a0,0x4
ffffffffc0203a98:	dcc50513          	addi	a0,a0,-564 # ffffffffc0207860 <default_pmm_manager+0x728>
ffffffffc0203a9c:	9dffc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0203aa0 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0203aa0:	000af797          	auipc	a5,0xaf
ffffffffc0203aa4:	d107b783          	ld	a5,-752(a5) # ffffffffc02b27b0 <sm>
ffffffffc0203aa8:	6b9c                	ld	a5,16(a5)
ffffffffc0203aaa:	8782                	jr	a5

ffffffffc0203aac <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0203aac:	000af797          	auipc	a5,0xaf
ffffffffc0203ab0:	d047b783          	ld	a5,-764(a5) # ffffffffc02b27b0 <sm>
ffffffffc0203ab4:	739c                	ld	a5,32(a5)
ffffffffc0203ab6:	8782                	jr	a5

ffffffffc0203ab8 <swap_out>:
{
ffffffffc0203ab8:	711d                	addi	sp,sp,-96
ffffffffc0203aba:	ec86                	sd	ra,88(sp)
ffffffffc0203abc:	e8a2                	sd	s0,80(sp)
ffffffffc0203abe:	e4a6                	sd	s1,72(sp)
ffffffffc0203ac0:	e0ca                	sd	s2,64(sp)
ffffffffc0203ac2:	fc4e                	sd	s3,56(sp)
ffffffffc0203ac4:	f852                	sd	s4,48(sp)
ffffffffc0203ac6:	f456                	sd	s5,40(sp)
ffffffffc0203ac8:	f05a                	sd	s6,32(sp)
ffffffffc0203aca:	ec5e                	sd	s7,24(sp)
ffffffffc0203acc:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0203ace:	cde9                	beqz	a1,ffffffffc0203ba8 <swap_out+0xf0>
ffffffffc0203ad0:	8a2e                	mv	s4,a1
ffffffffc0203ad2:	892a                	mv	s2,a0
ffffffffc0203ad4:	8ab2                	mv	s5,a2
ffffffffc0203ad6:	4401                	li	s0,0
ffffffffc0203ad8:	000af997          	auipc	s3,0xaf
ffffffffc0203adc:	cd898993          	addi	s3,s3,-808 # ffffffffc02b27b0 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203ae0:	00004b17          	auipc	s6,0x4
ffffffffc0203ae4:	068b0b13          	addi	s6,s6,104 # ffffffffc0207b48 <default_pmm_manager+0xa10>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203ae8:	00004b97          	auipc	s7,0x4
ffffffffc0203aec:	048b8b93          	addi	s7,s7,72 # ffffffffc0207b30 <default_pmm_manager+0x9f8>
ffffffffc0203af0:	a825                	j	ffffffffc0203b28 <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203af2:	67a2                	ld	a5,8(sp)
ffffffffc0203af4:	8626                	mv	a2,s1
ffffffffc0203af6:	85a2                	mv	a1,s0
ffffffffc0203af8:	7f94                	ld	a3,56(a5)
ffffffffc0203afa:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0203afc:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203afe:	82b1                	srli	a3,a3,0xc
ffffffffc0203b00:	0685                	addi	a3,a3,1
ffffffffc0203b02:	e7efc0ef          	jal	ra,ffffffffc0200180 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203b06:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0203b08:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203b0a:	7d1c                	ld	a5,56(a0)
ffffffffc0203b0c:	83b1                	srli	a5,a5,0xc
ffffffffc0203b0e:	0785                	addi	a5,a5,1
ffffffffc0203b10:	07a2                	slli	a5,a5,0x8
ffffffffc0203b12:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0203b16:	a38fe0ef          	jal	ra,ffffffffc0201d4e <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0203b1a:	01893503          	ld	a0,24(s2)
ffffffffc0203b1e:	85a6                	mv	a1,s1
ffffffffc0203b20:	f5eff0ef          	jal	ra,ffffffffc020327e <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0203b24:	048a0d63          	beq	s4,s0,ffffffffc0203b7e <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0203b28:	0009b783          	ld	a5,0(s3)
ffffffffc0203b2c:	8656                	mv	a2,s5
ffffffffc0203b2e:	002c                	addi	a1,sp,8
ffffffffc0203b30:	7b9c                	ld	a5,48(a5)
ffffffffc0203b32:	854a                	mv	a0,s2
ffffffffc0203b34:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0203b36:	e12d                	bnez	a0,ffffffffc0203b98 <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0203b38:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203b3a:	01893503          	ld	a0,24(s2)
ffffffffc0203b3e:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0203b40:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203b42:	85a6                	mv	a1,s1
ffffffffc0203b44:	a84fe0ef          	jal	ra,ffffffffc0201dc8 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203b48:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203b4a:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0203b4c:	8b85                	andi	a5,a5,1
ffffffffc0203b4e:	cfb9                	beqz	a5,ffffffffc0203bac <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0203b50:	65a2                	ld	a1,8(sp)
ffffffffc0203b52:	7d9c                	ld	a5,56(a1)
ffffffffc0203b54:	83b1                	srli	a5,a5,0xc
ffffffffc0203b56:	0785                	addi	a5,a5,1
ffffffffc0203b58:	00879513          	slli	a0,a5,0x8
ffffffffc0203b5c:	6e3000ef          	jal	ra,ffffffffc0204a3e <swapfs_write>
ffffffffc0203b60:	d949                	beqz	a0,ffffffffc0203af2 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203b62:	855e                	mv	a0,s7
ffffffffc0203b64:	e1cfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203b68:	0009b783          	ld	a5,0(s3)
ffffffffc0203b6c:	6622                	ld	a2,8(sp)
ffffffffc0203b6e:	4681                	li	a3,0
ffffffffc0203b70:	739c                	ld	a5,32(a5)
ffffffffc0203b72:	85a6                	mv	a1,s1
ffffffffc0203b74:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0203b76:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203b78:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0203b7a:	fa8a17e3          	bne	s4,s0,ffffffffc0203b28 <swap_out+0x70>
}
ffffffffc0203b7e:	60e6                	ld	ra,88(sp)
ffffffffc0203b80:	8522                	mv	a0,s0
ffffffffc0203b82:	6446                	ld	s0,80(sp)
ffffffffc0203b84:	64a6                	ld	s1,72(sp)
ffffffffc0203b86:	6906                	ld	s2,64(sp)
ffffffffc0203b88:	79e2                	ld	s3,56(sp)
ffffffffc0203b8a:	7a42                	ld	s4,48(sp)
ffffffffc0203b8c:	7aa2                	ld	s5,40(sp)
ffffffffc0203b8e:	7b02                	ld	s6,32(sp)
ffffffffc0203b90:	6be2                	ld	s7,24(sp)
ffffffffc0203b92:	6c42                	ld	s8,16(sp)
ffffffffc0203b94:	6125                	addi	sp,sp,96
ffffffffc0203b96:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0203b98:	85a2                	mv	a1,s0
ffffffffc0203b9a:	00004517          	auipc	a0,0x4
ffffffffc0203b9e:	f4e50513          	addi	a0,a0,-178 # ffffffffc0207ae8 <default_pmm_manager+0x9b0>
ffffffffc0203ba2:	ddefc0ef          	jal	ra,ffffffffc0200180 <cprintf>
                  break;
ffffffffc0203ba6:	bfe1                	j	ffffffffc0203b7e <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0203ba8:	4401                	li	s0,0
ffffffffc0203baa:	bfd1                	j	ffffffffc0203b7e <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203bac:	00004697          	auipc	a3,0x4
ffffffffc0203bb0:	f6c68693          	addi	a3,a3,-148 # ffffffffc0207b18 <default_pmm_manager+0x9e0>
ffffffffc0203bb4:	00003617          	auipc	a2,0x3
ffffffffc0203bb8:	eec60613          	addi	a2,a2,-276 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0203bbc:	06800593          	li	a1,104
ffffffffc0203bc0:	00004517          	auipc	a0,0x4
ffffffffc0203bc4:	ca050513          	addi	a0,a0,-864 # ffffffffc0207860 <default_pmm_manager+0x728>
ffffffffc0203bc8:	8b3fc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0203bcc <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc0203bcc:	000ab797          	auipc	a5,0xab
ffffffffc0203bd0:	b6c78793          	addi	a5,a5,-1172 # ffffffffc02ae738 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc0203bd4:	f51c                	sd	a5,40(a0)
ffffffffc0203bd6:	e79c                	sd	a5,8(a5)
ffffffffc0203bd8:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0203bda:	4501                	li	a0,0
ffffffffc0203bdc:	8082                	ret

ffffffffc0203bde <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc0203bde:	4501                	li	a0,0
ffffffffc0203be0:	8082                	ret

ffffffffc0203be2 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0203be2:	4501                	li	a0,0
ffffffffc0203be4:	8082                	ret

ffffffffc0203be6 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0203be6:	4501                	li	a0,0
ffffffffc0203be8:	8082                	ret

ffffffffc0203bea <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc0203bea:	711d                	addi	sp,sp,-96
ffffffffc0203bec:	fc4e                	sd	s3,56(sp)
ffffffffc0203bee:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203bf0:	00004517          	auipc	a0,0x4
ffffffffc0203bf4:	f9850513          	addi	a0,a0,-104 # ffffffffc0207b88 <default_pmm_manager+0xa50>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203bf8:	698d                	lui	s3,0x3
ffffffffc0203bfa:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc0203bfc:	e0ca                	sd	s2,64(sp)
ffffffffc0203bfe:	ec86                	sd	ra,88(sp)
ffffffffc0203c00:	e8a2                	sd	s0,80(sp)
ffffffffc0203c02:	e4a6                	sd	s1,72(sp)
ffffffffc0203c04:	f456                	sd	s5,40(sp)
ffffffffc0203c06:	f05a                	sd	s6,32(sp)
ffffffffc0203c08:	ec5e                	sd	s7,24(sp)
ffffffffc0203c0a:	e862                	sd	s8,16(sp)
ffffffffc0203c0c:	e466                	sd	s9,8(sp)
ffffffffc0203c0e:	e06a                	sd	s10,0(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203c10:	d70fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203c14:	01498023          	sb	s4,0(s3) # 3000 <_binary_obj___user_faultread_out_size-0x6ba8>
    assert(pgfault_num==4);
ffffffffc0203c18:	000af917          	auipc	s2,0xaf
ffffffffc0203c1c:	bb092903          	lw	s2,-1104(s2) # ffffffffc02b27c8 <pgfault_num>
ffffffffc0203c20:	4791                	li	a5,4
ffffffffc0203c22:	14f91e63          	bne	s2,a5,ffffffffc0203d7e <_fifo_check_swap+0x194>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203c26:	00004517          	auipc	a0,0x4
ffffffffc0203c2a:	fa250513          	addi	a0,a0,-94 # ffffffffc0207bc8 <default_pmm_manager+0xa90>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203c2e:	6a85                	lui	s5,0x1
ffffffffc0203c30:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203c32:	d4efc0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0203c36:	000af417          	auipc	s0,0xaf
ffffffffc0203c3a:	b9240413          	addi	s0,s0,-1134 # ffffffffc02b27c8 <pgfault_num>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203c3e:	016a8023          	sb	s6,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x8ba8>
    assert(pgfault_num==4);
ffffffffc0203c42:	4004                	lw	s1,0(s0)
ffffffffc0203c44:	2481                	sext.w	s1,s1
ffffffffc0203c46:	2b249c63          	bne	s1,s2,ffffffffc0203efe <_fifo_check_swap+0x314>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203c4a:	00004517          	auipc	a0,0x4
ffffffffc0203c4e:	fa650513          	addi	a0,a0,-90 # ffffffffc0207bf0 <default_pmm_manager+0xab8>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203c52:	6b91                	lui	s7,0x4
ffffffffc0203c54:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203c56:	d2afc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203c5a:	018b8023          	sb	s8,0(s7) # 4000 <_binary_obj___user_faultread_out_size-0x5ba8>
    assert(pgfault_num==4);
ffffffffc0203c5e:	00042903          	lw	s2,0(s0)
ffffffffc0203c62:	2901                	sext.w	s2,s2
ffffffffc0203c64:	26991d63          	bne	s2,s1,ffffffffc0203ede <_fifo_check_swap+0x2f4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203c68:	00004517          	auipc	a0,0x4
ffffffffc0203c6c:	fb050513          	addi	a0,a0,-80 # ffffffffc0207c18 <default_pmm_manager+0xae0>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203c70:	6c89                	lui	s9,0x2
ffffffffc0203c72:	4d2d                	li	s10,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203c74:	d0cfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203c78:	01ac8023          	sb	s10,0(s9) # 2000 <_binary_obj___user_faultread_out_size-0x7ba8>
    assert(pgfault_num==4);
ffffffffc0203c7c:	401c                	lw	a5,0(s0)
ffffffffc0203c7e:	2781                	sext.w	a5,a5
ffffffffc0203c80:	23279f63          	bne	a5,s2,ffffffffc0203ebe <_fifo_check_swap+0x2d4>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203c84:	00004517          	auipc	a0,0x4
ffffffffc0203c88:	fbc50513          	addi	a0,a0,-68 # ffffffffc0207c40 <default_pmm_manager+0xb08>
ffffffffc0203c8c:	cf4fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203c90:	6795                	lui	a5,0x5
ffffffffc0203c92:	4739                	li	a4,14
ffffffffc0203c94:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4ba8>
    assert(pgfault_num==5);
ffffffffc0203c98:	4004                	lw	s1,0(s0)
ffffffffc0203c9a:	4795                	li	a5,5
ffffffffc0203c9c:	2481                	sext.w	s1,s1
ffffffffc0203c9e:	20f49063          	bne	s1,a5,ffffffffc0203e9e <_fifo_check_swap+0x2b4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203ca2:	00004517          	auipc	a0,0x4
ffffffffc0203ca6:	f7650513          	addi	a0,a0,-138 # ffffffffc0207c18 <default_pmm_manager+0xae0>
ffffffffc0203caa:	cd6fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203cae:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==5);
ffffffffc0203cb2:	401c                	lw	a5,0(s0)
ffffffffc0203cb4:	2781                	sext.w	a5,a5
ffffffffc0203cb6:	1c979463          	bne	a5,s1,ffffffffc0203e7e <_fifo_check_swap+0x294>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203cba:	00004517          	auipc	a0,0x4
ffffffffc0203cbe:	f0e50513          	addi	a0,a0,-242 # ffffffffc0207bc8 <default_pmm_manager+0xa90>
ffffffffc0203cc2:	cbefc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203cc6:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc0203cca:	401c                	lw	a5,0(s0)
ffffffffc0203ccc:	4719                	li	a4,6
ffffffffc0203cce:	2781                	sext.w	a5,a5
ffffffffc0203cd0:	18e79763          	bne	a5,a4,ffffffffc0203e5e <_fifo_check_swap+0x274>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203cd4:	00004517          	auipc	a0,0x4
ffffffffc0203cd8:	f4450513          	addi	a0,a0,-188 # ffffffffc0207c18 <default_pmm_manager+0xae0>
ffffffffc0203cdc:	ca4fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203ce0:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==7);
ffffffffc0203ce4:	401c                	lw	a5,0(s0)
ffffffffc0203ce6:	471d                	li	a4,7
ffffffffc0203ce8:	2781                	sext.w	a5,a5
ffffffffc0203cea:	14e79a63          	bne	a5,a4,ffffffffc0203e3e <_fifo_check_swap+0x254>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203cee:	00004517          	auipc	a0,0x4
ffffffffc0203cf2:	e9a50513          	addi	a0,a0,-358 # ffffffffc0207b88 <default_pmm_manager+0xa50>
ffffffffc0203cf6:	c8afc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203cfa:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc0203cfe:	401c                	lw	a5,0(s0)
ffffffffc0203d00:	4721                	li	a4,8
ffffffffc0203d02:	2781                	sext.w	a5,a5
ffffffffc0203d04:	10e79d63          	bne	a5,a4,ffffffffc0203e1e <_fifo_check_swap+0x234>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203d08:	00004517          	auipc	a0,0x4
ffffffffc0203d0c:	ee850513          	addi	a0,a0,-280 # ffffffffc0207bf0 <default_pmm_manager+0xab8>
ffffffffc0203d10:	c70fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203d14:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc0203d18:	401c                	lw	a5,0(s0)
ffffffffc0203d1a:	4725                	li	a4,9
ffffffffc0203d1c:	2781                	sext.w	a5,a5
ffffffffc0203d1e:	0ee79063          	bne	a5,a4,ffffffffc0203dfe <_fifo_check_swap+0x214>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203d22:	00004517          	auipc	a0,0x4
ffffffffc0203d26:	f1e50513          	addi	a0,a0,-226 # ffffffffc0207c40 <default_pmm_manager+0xb08>
ffffffffc0203d2a:	c56fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203d2e:	6795                	lui	a5,0x5
ffffffffc0203d30:	4739                	li	a4,14
ffffffffc0203d32:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4ba8>
    assert(pgfault_num==10);
ffffffffc0203d36:	4004                	lw	s1,0(s0)
ffffffffc0203d38:	47a9                	li	a5,10
ffffffffc0203d3a:	2481                	sext.w	s1,s1
ffffffffc0203d3c:	0af49163          	bne	s1,a5,ffffffffc0203dde <_fifo_check_swap+0x1f4>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203d40:	00004517          	auipc	a0,0x4
ffffffffc0203d44:	e8850513          	addi	a0,a0,-376 # ffffffffc0207bc8 <default_pmm_manager+0xa90>
ffffffffc0203d48:	c38fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203d4c:	6785                	lui	a5,0x1
ffffffffc0203d4e:	0007c783          	lbu	a5,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x8ba8>
ffffffffc0203d52:	06979663          	bne	a5,s1,ffffffffc0203dbe <_fifo_check_swap+0x1d4>
    assert(pgfault_num==11);
ffffffffc0203d56:	401c                	lw	a5,0(s0)
ffffffffc0203d58:	472d                	li	a4,11
ffffffffc0203d5a:	2781                	sext.w	a5,a5
ffffffffc0203d5c:	04e79163          	bne	a5,a4,ffffffffc0203d9e <_fifo_check_swap+0x1b4>
}
ffffffffc0203d60:	60e6                	ld	ra,88(sp)
ffffffffc0203d62:	6446                	ld	s0,80(sp)
ffffffffc0203d64:	64a6                	ld	s1,72(sp)
ffffffffc0203d66:	6906                	ld	s2,64(sp)
ffffffffc0203d68:	79e2                	ld	s3,56(sp)
ffffffffc0203d6a:	7a42                	ld	s4,48(sp)
ffffffffc0203d6c:	7aa2                	ld	s5,40(sp)
ffffffffc0203d6e:	7b02                	ld	s6,32(sp)
ffffffffc0203d70:	6be2                	ld	s7,24(sp)
ffffffffc0203d72:	6c42                	ld	s8,16(sp)
ffffffffc0203d74:	6ca2                	ld	s9,8(sp)
ffffffffc0203d76:	6d02                	ld	s10,0(sp)
ffffffffc0203d78:	4501                	li	a0,0
ffffffffc0203d7a:	6125                	addi	sp,sp,96
ffffffffc0203d7c:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0203d7e:	00004697          	auipc	a3,0x4
ffffffffc0203d82:	caa68693          	addi	a3,a3,-854 # ffffffffc0207a28 <default_pmm_manager+0x8f0>
ffffffffc0203d86:	00003617          	auipc	a2,0x3
ffffffffc0203d8a:	d1a60613          	addi	a2,a2,-742 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0203d8e:	05100593          	li	a1,81
ffffffffc0203d92:	00004517          	auipc	a0,0x4
ffffffffc0203d96:	e1e50513          	addi	a0,a0,-482 # ffffffffc0207bb0 <default_pmm_manager+0xa78>
ffffffffc0203d9a:	ee0fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==11);
ffffffffc0203d9e:	00004697          	auipc	a3,0x4
ffffffffc0203da2:	f5268693          	addi	a3,a3,-174 # ffffffffc0207cf0 <default_pmm_manager+0xbb8>
ffffffffc0203da6:	00003617          	auipc	a2,0x3
ffffffffc0203daa:	cfa60613          	addi	a2,a2,-774 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0203dae:	07300593          	li	a1,115
ffffffffc0203db2:	00004517          	auipc	a0,0x4
ffffffffc0203db6:	dfe50513          	addi	a0,a0,-514 # ffffffffc0207bb0 <default_pmm_manager+0xa78>
ffffffffc0203dba:	ec0fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203dbe:	00004697          	auipc	a3,0x4
ffffffffc0203dc2:	f0a68693          	addi	a3,a3,-246 # ffffffffc0207cc8 <default_pmm_manager+0xb90>
ffffffffc0203dc6:	00003617          	auipc	a2,0x3
ffffffffc0203dca:	cda60613          	addi	a2,a2,-806 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0203dce:	07100593          	li	a1,113
ffffffffc0203dd2:	00004517          	auipc	a0,0x4
ffffffffc0203dd6:	dde50513          	addi	a0,a0,-546 # ffffffffc0207bb0 <default_pmm_manager+0xa78>
ffffffffc0203dda:	ea0fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==10);
ffffffffc0203dde:	00004697          	auipc	a3,0x4
ffffffffc0203de2:	eda68693          	addi	a3,a3,-294 # ffffffffc0207cb8 <default_pmm_manager+0xb80>
ffffffffc0203de6:	00003617          	auipc	a2,0x3
ffffffffc0203dea:	cba60613          	addi	a2,a2,-838 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0203dee:	06f00593          	li	a1,111
ffffffffc0203df2:	00004517          	auipc	a0,0x4
ffffffffc0203df6:	dbe50513          	addi	a0,a0,-578 # ffffffffc0207bb0 <default_pmm_manager+0xa78>
ffffffffc0203dfa:	e80fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==9);
ffffffffc0203dfe:	00004697          	auipc	a3,0x4
ffffffffc0203e02:	eaa68693          	addi	a3,a3,-342 # ffffffffc0207ca8 <default_pmm_manager+0xb70>
ffffffffc0203e06:	00003617          	auipc	a2,0x3
ffffffffc0203e0a:	c9a60613          	addi	a2,a2,-870 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0203e0e:	06c00593          	li	a1,108
ffffffffc0203e12:	00004517          	auipc	a0,0x4
ffffffffc0203e16:	d9e50513          	addi	a0,a0,-610 # ffffffffc0207bb0 <default_pmm_manager+0xa78>
ffffffffc0203e1a:	e60fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==8);
ffffffffc0203e1e:	00004697          	auipc	a3,0x4
ffffffffc0203e22:	e7a68693          	addi	a3,a3,-390 # ffffffffc0207c98 <default_pmm_manager+0xb60>
ffffffffc0203e26:	00003617          	auipc	a2,0x3
ffffffffc0203e2a:	c7a60613          	addi	a2,a2,-902 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0203e2e:	06900593          	li	a1,105
ffffffffc0203e32:	00004517          	auipc	a0,0x4
ffffffffc0203e36:	d7e50513          	addi	a0,a0,-642 # ffffffffc0207bb0 <default_pmm_manager+0xa78>
ffffffffc0203e3a:	e40fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==7);
ffffffffc0203e3e:	00004697          	auipc	a3,0x4
ffffffffc0203e42:	e4a68693          	addi	a3,a3,-438 # ffffffffc0207c88 <default_pmm_manager+0xb50>
ffffffffc0203e46:	00003617          	auipc	a2,0x3
ffffffffc0203e4a:	c5a60613          	addi	a2,a2,-934 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0203e4e:	06600593          	li	a1,102
ffffffffc0203e52:	00004517          	auipc	a0,0x4
ffffffffc0203e56:	d5e50513          	addi	a0,a0,-674 # ffffffffc0207bb0 <default_pmm_manager+0xa78>
ffffffffc0203e5a:	e20fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==6);
ffffffffc0203e5e:	00004697          	auipc	a3,0x4
ffffffffc0203e62:	e1a68693          	addi	a3,a3,-486 # ffffffffc0207c78 <default_pmm_manager+0xb40>
ffffffffc0203e66:	00003617          	auipc	a2,0x3
ffffffffc0203e6a:	c3a60613          	addi	a2,a2,-966 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0203e6e:	06300593          	li	a1,99
ffffffffc0203e72:	00004517          	auipc	a0,0x4
ffffffffc0203e76:	d3e50513          	addi	a0,a0,-706 # ffffffffc0207bb0 <default_pmm_manager+0xa78>
ffffffffc0203e7a:	e00fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==5);
ffffffffc0203e7e:	00004697          	auipc	a3,0x4
ffffffffc0203e82:	dea68693          	addi	a3,a3,-534 # ffffffffc0207c68 <default_pmm_manager+0xb30>
ffffffffc0203e86:	00003617          	auipc	a2,0x3
ffffffffc0203e8a:	c1a60613          	addi	a2,a2,-998 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0203e8e:	06000593          	li	a1,96
ffffffffc0203e92:	00004517          	auipc	a0,0x4
ffffffffc0203e96:	d1e50513          	addi	a0,a0,-738 # ffffffffc0207bb0 <default_pmm_manager+0xa78>
ffffffffc0203e9a:	de0fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==5);
ffffffffc0203e9e:	00004697          	auipc	a3,0x4
ffffffffc0203ea2:	dca68693          	addi	a3,a3,-566 # ffffffffc0207c68 <default_pmm_manager+0xb30>
ffffffffc0203ea6:	00003617          	auipc	a2,0x3
ffffffffc0203eaa:	bfa60613          	addi	a2,a2,-1030 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0203eae:	05d00593          	li	a1,93
ffffffffc0203eb2:	00004517          	auipc	a0,0x4
ffffffffc0203eb6:	cfe50513          	addi	a0,a0,-770 # ffffffffc0207bb0 <default_pmm_manager+0xa78>
ffffffffc0203eba:	dc0fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==4);
ffffffffc0203ebe:	00004697          	auipc	a3,0x4
ffffffffc0203ec2:	b6a68693          	addi	a3,a3,-1174 # ffffffffc0207a28 <default_pmm_manager+0x8f0>
ffffffffc0203ec6:	00003617          	auipc	a2,0x3
ffffffffc0203eca:	bda60613          	addi	a2,a2,-1062 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0203ece:	05a00593          	li	a1,90
ffffffffc0203ed2:	00004517          	auipc	a0,0x4
ffffffffc0203ed6:	cde50513          	addi	a0,a0,-802 # ffffffffc0207bb0 <default_pmm_manager+0xa78>
ffffffffc0203eda:	da0fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==4);
ffffffffc0203ede:	00004697          	auipc	a3,0x4
ffffffffc0203ee2:	b4a68693          	addi	a3,a3,-1206 # ffffffffc0207a28 <default_pmm_manager+0x8f0>
ffffffffc0203ee6:	00003617          	auipc	a2,0x3
ffffffffc0203eea:	bba60613          	addi	a2,a2,-1094 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0203eee:	05700593          	li	a1,87
ffffffffc0203ef2:	00004517          	auipc	a0,0x4
ffffffffc0203ef6:	cbe50513          	addi	a0,a0,-834 # ffffffffc0207bb0 <default_pmm_manager+0xa78>
ffffffffc0203efa:	d80fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==4);
ffffffffc0203efe:	00004697          	auipc	a3,0x4
ffffffffc0203f02:	b2a68693          	addi	a3,a3,-1238 # ffffffffc0207a28 <default_pmm_manager+0x8f0>
ffffffffc0203f06:	00003617          	auipc	a2,0x3
ffffffffc0203f0a:	b9a60613          	addi	a2,a2,-1126 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0203f0e:	05400593          	li	a1,84
ffffffffc0203f12:	00004517          	auipc	a0,0x4
ffffffffc0203f16:	c9e50513          	addi	a0,a0,-866 # ffffffffc0207bb0 <default_pmm_manager+0xa78>
ffffffffc0203f1a:	d60fc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0203f1e <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0203f1e:	751c                	ld	a5,40(a0)
{
ffffffffc0203f20:	1141                	addi	sp,sp,-16
ffffffffc0203f22:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc0203f24:	cf91                	beqz	a5,ffffffffc0203f40 <_fifo_swap_out_victim+0x22>
     assert(in_tick==0);
ffffffffc0203f26:	ee0d                	bnez	a2,ffffffffc0203f60 <_fifo_swap_out_victim+0x42>
    return listelm->next;
ffffffffc0203f28:	679c                	ld	a5,8(a5)
}
ffffffffc0203f2a:	60a2                	ld	ra,8(sp)
ffffffffc0203f2c:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc0203f2e:	6394                	ld	a3,0(a5)
ffffffffc0203f30:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc0203f32:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc0203f36:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0203f38:	e314                	sd	a3,0(a4)
ffffffffc0203f3a:	e19c                	sd	a5,0(a1)
}
ffffffffc0203f3c:	0141                	addi	sp,sp,16
ffffffffc0203f3e:	8082                	ret
         assert(head != NULL);
ffffffffc0203f40:	00004697          	auipc	a3,0x4
ffffffffc0203f44:	dc068693          	addi	a3,a3,-576 # ffffffffc0207d00 <default_pmm_manager+0xbc8>
ffffffffc0203f48:	00003617          	auipc	a2,0x3
ffffffffc0203f4c:	b5860613          	addi	a2,a2,-1192 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0203f50:	04100593          	li	a1,65
ffffffffc0203f54:	00004517          	auipc	a0,0x4
ffffffffc0203f58:	c5c50513          	addi	a0,a0,-932 # ffffffffc0207bb0 <default_pmm_manager+0xa78>
ffffffffc0203f5c:	d1efc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(in_tick==0);
ffffffffc0203f60:	00004697          	auipc	a3,0x4
ffffffffc0203f64:	db068693          	addi	a3,a3,-592 # ffffffffc0207d10 <default_pmm_manager+0xbd8>
ffffffffc0203f68:	00003617          	auipc	a2,0x3
ffffffffc0203f6c:	b3860613          	addi	a2,a2,-1224 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0203f70:	04200593          	li	a1,66
ffffffffc0203f74:	00004517          	auipc	a0,0x4
ffffffffc0203f78:	c3c50513          	addi	a0,a0,-964 # ffffffffc0207bb0 <default_pmm_manager+0xa78>
ffffffffc0203f7c:	cfefc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0203f80 <_fifo_map_swappable>:
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0203f80:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc0203f82:	cb91                	beqz	a5,ffffffffc0203f96 <_fifo_map_swappable+0x16>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0203f84:	6394                	ld	a3,0(a5)
ffffffffc0203f86:	02860713          	addi	a4,a2,40
    prev->next = next->prev = elm;
ffffffffc0203f8a:	e398                	sd	a4,0(a5)
ffffffffc0203f8c:	e698                	sd	a4,8(a3)
}
ffffffffc0203f8e:	4501                	li	a0,0
    elm->next = next;
ffffffffc0203f90:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc0203f92:	f614                	sd	a3,40(a2)
ffffffffc0203f94:	8082                	ret
{
ffffffffc0203f96:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0203f98:	00004697          	auipc	a3,0x4
ffffffffc0203f9c:	d8868693          	addi	a3,a3,-632 # ffffffffc0207d20 <default_pmm_manager+0xbe8>
ffffffffc0203fa0:	00003617          	auipc	a2,0x3
ffffffffc0203fa4:	b0060613          	addi	a2,a2,-1280 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0203fa8:	03200593          	li	a1,50
ffffffffc0203fac:	00004517          	auipc	a0,0x4
ffffffffc0203fb0:	c0450513          	addi	a0,a0,-1020 # ffffffffc0207bb0 <default_pmm_manager+0xa78>
{
ffffffffc0203fb4:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc0203fb6:	cc4fc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0203fba <check_vma_overlap.part.0>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0203fba:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0203fbc:	00004697          	auipc	a3,0x4
ffffffffc0203fc0:	d9c68693          	addi	a3,a3,-612 # ffffffffc0207d58 <default_pmm_manager+0xc20>
ffffffffc0203fc4:	00003617          	auipc	a2,0x3
ffffffffc0203fc8:	adc60613          	addi	a2,a2,-1316 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0203fcc:	06d00593          	li	a1,109
ffffffffc0203fd0:	00004517          	auipc	a0,0x4
ffffffffc0203fd4:	da850513          	addi	a0,a0,-600 # ffffffffc0207d78 <default_pmm_manager+0xc40>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0203fd8:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0203fda:	ca0fc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0203fde <mm_create>:
mm_create(void) {
ffffffffc0203fde:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203fe0:	04000513          	li	a0,64
mm_create(void) {
ffffffffc0203fe4:	e022                	sd	s0,0(sp)
ffffffffc0203fe6:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203fe8:	af7fd0ef          	jal	ra,ffffffffc0201ade <kmalloc>
ffffffffc0203fec:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0203fee:	c505                	beqz	a0,ffffffffc0204016 <mm_create+0x38>
    elm->prev = elm->next = elm;
ffffffffc0203ff0:	e408                	sd	a0,8(s0)
ffffffffc0203ff2:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0203ff4:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203ff8:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0203ffc:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0204000:	000ae797          	auipc	a5,0xae
ffffffffc0204004:	7b87a783          	lw	a5,1976(a5) # ffffffffc02b27b8 <swap_init_ok>
ffffffffc0204008:	ef81                	bnez	a5,ffffffffc0204020 <mm_create+0x42>
        else mm->sm_priv = NULL;
ffffffffc020400a:	02053423          	sd	zero,40(a0)
    return mm->mm_count;
}

static inline void
set_mm_count(struct mm_struct *mm, int val) {
    mm->mm_count = val;
ffffffffc020400e:	02042823          	sw	zero,48(s0)

typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock) {
    *lock = 0;
ffffffffc0204012:	02043c23          	sd	zero,56(s0)
}
ffffffffc0204016:	60a2                	ld	ra,8(sp)
ffffffffc0204018:	8522                	mv	a0,s0
ffffffffc020401a:	6402                	ld	s0,0(sp)
ffffffffc020401c:	0141                	addi	sp,sp,16
ffffffffc020401e:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0204020:	a81ff0ef          	jal	ra,ffffffffc0203aa0 <swap_init_mm>
ffffffffc0204024:	b7ed                	j	ffffffffc020400e <mm_create+0x30>

ffffffffc0204026 <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0204026:	1101                	addi	sp,sp,-32
ffffffffc0204028:	e04a                	sd	s2,0(sp)
ffffffffc020402a:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020402c:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0204030:	e822                	sd	s0,16(sp)
ffffffffc0204032:	e426                	sd	s1,8(sp)
ffffffffc0204034:	ec06                	sd	ra,24(sp)
ffffffffc0204036:	84ae                	mv	s1,a1
ffffffffc0204038:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020403a:	aa5fd0ef          	jal	ra,ffffffffc0201ade <kmalloc>
    if (vma != NULL) {
ffffffffc020403e:	c509                	beqz	a0,ffffffffc0204048 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0204040:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0204044:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0204046:	cd00                	sw	s0,24(a0)
}
ffffffffc0204048:	60e2                	ld	ra,24(sp)
ffffffffc020404a:	6442                	ld	s0,16(sp)
ffffffffc020404c:	64a2                	ld	s1,8(sp)
ffffffffc020404e:	6902                	ld	s2,0(sp)
ffffffffc0204050:	6105                	addi	sp,sp,32
ffffffffc0204052:	8082                	ret

ffffffffc0204054 <find_vma>:
find_vma(struct mm_struct *mm, uintptr_t addr) {
ffffffffc0204054:	86aa                	mv	a3,a0
    if (mm != NULL) {
ffffffffc0204056:	c505                	beqz	a0,ffffffffc020407e <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc0204058:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc020405a:	c501                	beqz	a0,ffffffffc0204062 <find_vma+0xe>
ffffffffc020405c:	651c                	ld	a5,8(a0)
ffffffffc020405e:	02f5f263          	bgeu	a1,a5,ffffffffc0204082 <find_vma+0x2e>
    return listelm->next;
ffffffffc0204062:	669c                	ld	a5,8(a3)
                while ((le = list_next(le)) != list) {
ffffffffc0204064:	00f68d63          	beq	a3,a5,ffffffffc020407e <find_vma+0x2a>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0204068:	fe87b703          	ld	a4,-24(a5)
ffffffffc020406c:	00e5e663          	bltu	a1,a4,ffffffffc0204078 <find_vma+0x24>
ffffffffc0204070:	ff07b703          	ld	a4,-16(a5)
ffffffffc0204074:	00e5ec63          	bltu	a1,a4,ffffffffc020408c <find_vma+0x38>
ffffffffc0204078:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc020407a:	fef697e3          	bne	a3,a5,ffffffffc0204068 <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc020407e:	4501                	li	a0,0
}
ffffffffc0204080:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0204082:	691c                	ld	a5,16(a0)
ffffffffc0204084:	fcf5ffe3          	bgeu	a1,a5,ffffffffc0204062 <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc0204088:	ea88                	sd	a0,16(a3)
ffffffffc020408a:	8082                	ret
                    vma = le2vma(le, list_link);
ffffffffc020408c:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc0204090:	ea88                	sd	a0,16(a3)
ffffffffc0204092:	8082                	ret

ffffffffc0204094 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0204094:	6590                	ld	a2,8(a1)
ffffffffc0204096:	0105b803          	ld	a6,16(a1) # 1010 <_binary_obj___user_faultread_out_size-0x8b98>
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc020409a:	1141                	addi	sp,sp,-16
ffffffffc020409c:	e406                	sd	ra,8(sp)
ffffffffc020409e:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc02040a0:	01066763          	bltu	a2,a6,ffffffffc02040ae <insert_vma_struct+0x1a>
ffffffffc02040a4:	a085                	j	ffffffffc0204104 <insert_vma_struct+0x70>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc02040a6:	fe87b703          	ld	a4,-24(a5)
ffffffffc02040aa:	04e66863          	bltu	a2,a4,ffffffffc02040fa <insert_vma_struct+0x66>
ffffffffc02040ae:	86be                	mv	a3,a5
ffffffffc02040b0:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc02040b2:	fef51ae3          	bne	a0,a5,ffffffffc02040a6 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc02040b6:	02a68463          	beq	a3,a0,ffffffffc02040de <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc02040ba:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc02040be:	fe86b883          	ld	a7,-24(a3)
ffffffffc02040c2:	08e8f163          	bgeu	a7,a4,ffffffffc0204144 <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02040c6:	04e66f63          	bltu	a2,a4,ffffffffc0204124 <insert_vma_struct+0x90>
    }
    if (le_next != list) {
ffffffffc02040ca:	00f50a63          	beq	a0,a5,ffffffffc02040de <insert_vma_struct+0x4a>
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc02040ce:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc02040d2:	05076963          	bltu	a4,a6,ffffffffc0204124 <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc02040d6:	ff07b603          	ld	a2,-16(a5)
ffffffffc02040da:	02c77363          	bgeu	a4,a2,ffffffffc0204100 <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc02040de:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc02040e0:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc02040e2:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc02040e6:	e390                	sd	a2,0(a5)
ffffffffc02040e8:	e690                	sd	a2,8(a3)
}
ffffffffc02040ea:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc02040ec:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc02040ee:	f194                	sd	a3,32(a1)
    mm->map_count ++;
ffffffffc02040f0:	0017079b          	addiw	a5,a4,1
ffffffffc02040f4:	d11c                	sw	a5,32(a0)
}
ffffffffc02040f6:	0141                	addi	sp,sp,16
ffffffffc02040f8:	8082                	ret
    if (le_prev != list) {
ffffffffc02040fa:	fca690e3          	bne	a3,a0,ffffffffc02040ba <insert_vma_struct+0x26>
ffffffffc02040fe:	bfd1                	j	ffffffffc02040d2 <insert_vma_struct+0x3e>
ffffffffc0204100:	ebbff0ef          	jal	ra,ffffffffc0203fba <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0204104:	00004697          	auipc	a3,0x4
ffffffffc0204108:	c8468693          	addi	a3,a3,-892 # ffffffffc0207d88 <default_pmm_manager+0xc50>
ffffffffc020410c:	00003617          	auipc	a2,0x3
ffffffffc0204110:	99460613          	addi	a2,a2,-1644 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0204114:	07400593          	li	a1,116
ffffffffc0204118:	00004517          	auipc	a0,0x4
ffffffffc020411c:	c6050513          	addi	a0,a0,-928 # ffffffffc0207d78 <default_pmm_manager+0xc40>
ffffffffc0204120:	b5afc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0204124:	00004697          	auipc	a3,0x4
ffffffffc0204128:	ca468693          	addi	a3,a3,-860 # ffffffffc0207dc8 <default_pmm_manager+0xc90>
ffffffffc020412c:	00003617          	auipc	a2,0x3
ffffffffc0204130:	97460613          	addi	a2,a2,-1676 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0204134:	06c00593          	li	a1,108
ffffffffc0204138:	00004517          	auipc	a0,0x4
ffffffffc020413c:	c4050513          	addi	a0,a0,-960 # ffffffffc0207d78 <default_pmm_manager+0xc40>
ffffffffc0204140:	b3afc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0204144:	00004697          	auipc	a3,0x4
ffffffffc0204148:	c6468693          	addi	a3,a3,-924 # ffffffffc0207da8 <default_pmm_manager+0xc70>
ffffffffc020414c:	00003617          	auipc	a2,0x3
ffffffffc0204150:	95460613          	addi	a2,a2,-1708 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0204154:	06b00593          	li	a1,107
ffffffffc0204158:	00004517          	auipc	a0,0x4
ffffffffc020415c:	c2050513          	addi	a0,a0,-992 # ffffffffc0207d78 <default_pmm_manager+0xc40>
ffffffffc0204160:	b1afc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0204164 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
    assert(mm_count(mm) == 0);
ffffffffc0204164:	591c                	lw	a5,48(a0)
mm_destroy(struct mm_struct *mm) {
ffffffffc0204166:	1141                	addi	sp,sp,-16
ffffffffc0204168:	e406                	sd	ra,8(sp)
ffffffffc020416a:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc020416c:	e78d                	bnez	a5,ffffffffc0204196 <mm_destroy+0x32>
ffffffffc020416e:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0204170:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0204172:	00a40c63          	beq	s0,a0,ffffffffc020418a <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0204176:	6118                	ld	a4,0(a0)
ffffffffc0204178:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc020417a:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc020417c:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020417e:	e398                	sd	a4,0(a5)
ffffffffc0204180:	a0ffd0ef          	jal	ra,ffffffffc0201b8e <kfree>
    return listelm->next;
ffffffffc0204184:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0204186:	fea418e3          	bne	s0,a0,ffffffffc0204176 <mm_destroy+0x12>
    }
    kfree(mm); //kfree mm
ffffffffc020418a:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc020418c:	6402                	ld	s0,0(sp)
ffffffffc020418e:	60a2                	ld	ra,8(sp)
ffffffffc0204190:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc0204192:	9fdfd06f          	j	ffffffffc0201b8e <kfree>
    assert(mm_count(mm) == 0);
ffffffffc0204196:	00004697          	auipc	a3,0x4
ffffffffc020419a:	c5268693          	addi	a3,a3,-942 # ffffffffc0207de8 <default_pmm_manager+0xcb0>
ffffffffc020419e:	00003617          	auipc	a2,0x3
ffffffffc02041a2:	90260613          	addi	a2,a2,-1790 # ffffffffc0206aa0 <commands+0x450>
ffffffffc02041a6:	09400593          	li	a1,148
ffffffffc02041aa:	00004517          	auipc	a0,0x4
ffffffffc02041ae:	bce50513          	addi	a0,a0,-1074 # ffffffffc0207d78 <default_pmm_manager+0xc40>
ffffffffc02041b2:	ac8fc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02041b6 <mm_map>:

int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
       struct vma_struct **vma_store) {
ffffffffc02041b6:	7139                	addi	sp,sp,-64
ffffffffc02041b8:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02041ba:	6405                	lui	s0,0x1
ffffffffc02041bc:	147d                	addi	s0,s0,-1
ffffffffc02041be:	77fd                	lui	a5,0xfffff
ffffffffc02041c0:	9622                	add	a2,a2,s0
ffffffffc02041c2:	962e                	add	a2,a2,a1
       struct vma_struct **vma_store) {
ffffffffc02041c4:	f426                	sd	s1,40(sp)
ffffffffc02041c6:	fc06                	sd	ra,56(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02041c8:	00f5f4b3          	and	s1,a1,a5
       struct vma_struct **vma_store) {
ffffffffc02041cc:	f04a                	sd	s2,32(sp)
ffffffffc02041ce:	ec4e                	sd	s3,24(sp)
ffffffffc02041d0:	e852                	sd	s4,16(sp)
ffffffffc02041d2:	e456                	sd	s5,8(sp)
    if (!USER_ACCESS(start, end)) {
ffffffffc02041d4:	002005b7          	lui	a1,0x200
ffffffffc02041d8:	00f67433          	and	s0,a2,a5
ffffffffc02041dc:	06b4e363          	bltu	s1,a1,ffffffffc0204242 <mm_map+0x8c>
ffffffffc02041e0:	0684f163          	bgeu	s1,s0,ffffffffc0204242 <mm_map+0x8c>
ffffffffc02041e4:	4785                	li	a5,1
ffffffffc02041e6:	07fe                	slli	a5,a5,0x1f
ffffffffc02041e8:	0487ed63          	bltu	a5,s0,ffffffffc0204242 <mm_map+0x8c>
ffffffffc02041ec:	89aa                	mv	s3,a0
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc02041ee:	cd21                	beqz	a0,ffffffffc0204246 <mm_map+0x90>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
ffffffffc02041f0:	85a6                	mv	a1,s1
ffffffffc02041f2:	8ab6                	mv	s5,a3
ffffffffc02041f4:	8a3a                	mv	s4,a4
ffffffffc02041f6:	e5fff0ef          	jal	ra,ffffffffc0204054 <find_vma>
ffffffffc02041fa:	c501                	beqz	a0,ffffffffc0204202 <mm_map+0x4c>
ffffffffc02041fc:	651c                	ld	a5,8(a0)
ffffffffc02041fe:	0487e263          	bltu	a5,s0,ffffffffc0204242 <mm_map+0x8c>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204202:	03000513          	li	a0,48
ffffffffc0204206:	8d9fd0ef          	jal	ra,ffffffffc0201ade <kmalloc>
ffffffffc020420a:	892a                	mv	s2,a0
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc020420c:	5571                	li	a0,-4
    if (vma != NULL) {
ffffffffc020420e:	02090163          	beqz	s2,ffffffffc0204230 <mm_map+0x7a>

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc0204212:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc0204214:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc0204218:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc020421c:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc0204220:	85ca                	mv	a1,s2
ffffffffc0204222:	e73ff0ef          	jal	ra,ffffffffc0204094 <insert_vma_struct>
    if (vma_store != NULL) {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc0204226:	4501                	li	a0,0
    if (vma_store != NULL) {
ffffffffc0204228:	000a0463          	beqz	s4,ffffffffc0204230 <mm_map+0x7a>
        *vma_store = vma;
ffffffffc020422c:	012a3023          	sd	s2,0(s4)

out:
    return ret;
}
ffffffffc0204230:	70e2                	ld	ra,56(sp)
ffffffffc0204232:	7442                	ld	s0,48(sp)
ffffffffc0204234:	74a2                	ld	s1,40(sp)
ffffffffc0204236:	7902                	ld	s2,32(sp)
ffffffffc0204238:	69e2                	ld	s3,24(sp)
ffffffffc020423a:	6a42                	ld	s4,16(sp)
ffffffffc020423c:	6aa2                	ld	s5,8(sp)
ffffffffc020423e:	6121                	addi	sp,sp,64
ffffffffc0204240:	8082                	ret
        return -E_INVAL;
ffffffffc0204242:	5575                	li	a0,-3
ffffffffc0204244:	b7f5                	j	ffffffffc0204230 <mm_map+0x7a>
    assert(mm != NULL);
ffffffffc0204246:	00003697          	auipc	a3,0x3
ffffffffc020424a:	66a68693          	addi	a3,a3,1642 # ffffffffc02078b0 <default_pmm_manager+0x778>
ffffffffc020424e:	00003617          	auipc	a2,0x3
ffffffffc0204252:	85260613          	addi	a2,a2,-1966 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0204256:	0a700593          	li	a1,167
ffffffffc020425a:	00004517          	auipc	a0,0x4
ffffffffc020425e:	b1e50513          	addi	a0,a0,-1250 # ffffffffc0207d78 <default_pmm_manager+0xc40>
ffffffffc0204262:	a18fc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0204266 <dup_mmap>:

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
ffffffffc0204266:	7139                	addi	sp,sp,-64
ffffffffc0204268:	fc06                	sd	ra,56(sp)
ffffffffc020426a:	f822                	sd	s0,48(sp)
ffffffffc020426c:	f426                	sd	s1,40(sp)
ffffffffc020426e:	f04a                	sd	s2,32(sp)
ffffffffc0204270:	ec4e                	sd	s3,24(sp)
ffffffffc0204272:	e852                	sd	s4,16(sp)
ffffffffc0204274:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc0204276:	c52d                	beqz	a0,ffffffffc02042e0 <dup_mmap+0x7a>
ffffffffc0204278:	892a                	mv	s2,a0
ffffffffc020427a:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc020427c:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc020427e:	e595                	bnez	a1,ffffffffc02042aa <dup_mmap+0x44>
ffffffffc0204280:	a085                	j	ffffffffc02042e0 <dup_mmap+0x7a>
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
        if (nvma == NULL) {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc0204282:	854a                	mv	a0,s2
        vma->vm_start = vm_start;
ffffffffc0204284:	0155b423          	sd	s5,8(a1) # 200008 <_binary_obj___user_exit_out_size+0x1f4ee8>
        vma->vm_end = vm_end;
ffffffffc0204288:	0145b823          	sd	s4,16(a1)
        vma->vm_flags = vm_flags;
ffffffffc020428c:	0135ac23          	sw	s3,24(a1)
        insert_vma_struct(to, nvma);
ffffffffc0204290:	e05ff0ef          	jal	ra,ffffffffc0204094 <insert_vma_struct>

        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
ffffffffc0204294:	ff043683          	ld	a3,-16(s0) # ff0 <_binary_obj___user_faultread_out_size-0x8bb8>
ffffffffc0204298:	fe843603          	ld	a2,-24(s0)
ffffffffc020429c:	6c8c                	ld	a1,24(s1)
ffffffffc020429e:	01893503          	ld	a0,24(s2)
ffffffffc02042a2:	4701                	li	a4,0
ffffffffc02042a4:	922fe0ef          	jal	ra,ffffffffc02023c6 <copy_range>
ffffffffc02042a8:	e105                	bnez	a0,ffffffffc02042c8 <dup_mmap+0x62>
    return listelm->prev;
ffffffffc02042aa:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list) {
ffffffffc02042ac:	02848863          	beq	s1,s0,ffffffffc02042dc <dup_mmap+0x76>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02042b0:	03000513          	li	a0,48
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc02042b4:	fe843a83          	ld	s5,-24(s0)
ffffffffc02042b8:	ff043a03          	ld	s4,-16(s0)
ffffffffc02042bc:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02042c0:	81ffd0ef          	jal	ra,ffffffffc0201ade <kmalloc>
ffffffffc02042c4:	85aa                	mv	a1,a0
    if (vma != NULL) {
ffffffffc02042c6:	fd55                	bnez	a0,ffffffffc0204282 <dup_mmap+0x1c>
            return -E_NO_MEM;
ffffffffc02042c8:	5571                	li	a0,-4
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc02042ca:	70e2                	ld	ra,56(sp)
ffffffffc02042cc:	7442                	ld	s0,48(sp)
ffffffffc02042ce:	74a2                	ld	s1,40(sp)
ffffffffc02042d0:	7902                	ld	s2,32(sp)
ffffffffc02042d2:	69e2                	ld	s3,24(sp)
ffffffffc02042d4:	6a42                	ld	s4,16(sp)
ffffffffc02042d6:	6aa2                	ld	s5,8(sp)
ffffffffc02042d8:	6121                	addi	sp,sp,64
ffffffffc02042da:	8082                	ret
    return 0;
ffffffffc02042dc:	4501                	li	a0,0
ffffffffc02042de:	b7f5                	j	ffffffffc02042ca <dup_mmap+0x64>
    assert(to != NULL && from != NULL);
ffffffffc02042e0:	00004697          	auipc	a3,0x4
ffffffffc02042e4:	b2068693          	addi	a3,a3,-1248 # ffffffffc0207e00 <default_pmm_manager+0xcc8>
ffffffffc02042e8:	00002617          	auipc	a2,0x2
ffffffffc02042ec:	7b860613          	addi	a2,a2,1976 # ffffffffc0206aa0 <commands+0x450>
ffffffffc02042f0:	0c000593          	li	a1,192
ffffffffc02042f4:	00004517          	auipc	a0,0x4
ffffffffc02042f8:	a8450513          	addi	a0,a0,-1404 # ffffffffc0207d78 <default_pmm_manager+0xc40>
ffffffffc02042fc:	97efc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0204300 <exit_mmap>:

void
exit_mmap(struct mm_struct *mm) {
ffffffffc0204300:	1101                	addi	sp,sp,-32
ffffffffc0204302:	ec06                	sd	ra,24(sp)
ffffffffc0204304:	e822                	sd	s0,16(sp)
ffffffffc0204306:	e426                	sd	s1,8(sp)
ffffffffc0204308:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc020430a:	c531                	beqz	a0,ffffffffc0204356 <exit_mmap+0x56>
ffffffffc020430c:	591c                	lw	a5,48(a0)
ffffffffc020430e:	84aa                	mv	s1,a0
ffffffffc0204310:	e3b9                	bnez	a5,ffffffffc0204356 <exit_mmap+0x56>
    return listelm->next;
ffffffffc0204312:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc0204314:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) {
ffffffffc0204318:	02850663          	beq	a0,s0,ffffffffc0204344 <exit_mmap+0x44>
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc020431c:	ff043603          	ld	a2,-16(s0)
ffffffffc0204320:	fe843583          	ld	a1,-24(s0)
ffffffffc0204324:	854a                	mv	a0,s2
ffffffffc0204326:	cc9fd0ef          	jal	ra,ffffffffc0201fee <unmap_range>
ffffffffc020432a:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc020432c:	fe8498e3          	bne	s1,s0,ffffffffc020431c <exit_mmap+0x1c>
ffffffffc0204330:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list) {
ffffffffc0204332:	00848c63          	beq	s1,s0,ffffffffc020434a <exit_mmap+0x4a>
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0204336:	ff043603          	ld	a2,-16(s0)
ffffffffc020433a:	fe843583          	ld	a1,-24(s0)
ffffffffc020433e:	854a                	mv	a0,s2
ffffffffc0204340:	df5fd0ef          	jal	ra,ffffffffc0202134 <exit_range>
ffffffffc0204344:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc0204346:	fe8498e3          	bne	s1,s0,ffffffffc0204336 <exit_mmap+0x36>
    }
}
ffffffffc020434a:	60e2                	ld	ra,24(sp)
ffffffffc020434c:	6442                	ld	s0,16(sp)
ffffffffc020434e:	64a2                	ld	s1,8(sp)
ffffffffc0204350:	6902                	ld	s2,0(sp)
ffffffffc0204352:	6105                	addi	sp,sp,32
ffffffffc0204354:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0204356:	00004697          	auipc	a3,0x4
ffffffffc020435a:	aca68693          	addi	a3,a3,-1334 # ffffffffc0207e20 <default_pmm_manager+0xce8>
ffffffffc020435e:	00002617          	auipc	a2,0x2
ffffffffc0204362:	74260613          	addi	a2,a2,1858 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0204366:	0d600593          	li	a1,214
ffffffffc020436a:	00004517          	auipc	a0,0x4
ffffffffc020436e:	a0e50513          	addi	a0,a0,-1522 # ffffffffc0207d78 <default_pmm_manager+0xc40>
ffffffffc0204372:	908fc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0204376 <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0204376:	7139                	addi	sp,sp,-64
ffffffffc0204378:	f822                	sd	s0,48(sp)
ffffffffc020437a:	f426                	sd	s1,40(sp)
ffffffffc020437c:	fc06                	sd	ra,56(sp)
ffffffffc020437e:	f04a                	sd	s2,32(sp)
ffffffffc0204380:	ec4e                	sd	s3,24(sp)
ffffffffc0204382:	e852                	sd	s4,16(sp)
ffffffffc0204384:	e456                	sd	s5,8(sp)

static void
check_vma_struct(void) {
    // size_t nr_free_pages_store = nr_free_pages();

    struct mm_struct *mm = mm_create();
ffffffffc0204386:	c59ff0ef          	jal	ra,ffffffffc0203fde <mm_create>
    assert(mm != NULL);
ffffffffc020438a:	84aa                	mv	s1,a0
ffffffffc020438c:	03200413          	li	s0,50
ffffffffc0204390:	e919                	bnez	a0,ffffffffc02043a6 <vmm_init+0x30>
ffffffffc0204392:	a991                	j	ffffffffc02047e6 <vmm_init+0x470>
        vma->vm_start = vm_start;
ffffffffc0204394:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0204396:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0204398:	00052c23          	sw	zero,24(a0)

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
ffffffffc020439c:	146d                	addi	s0,s0,-5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc020439e:	8526                	mv	a0,s1
ffffffffc02043a0:	cf5ff0ef          	jal	ra,ffffffffc0204094 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc02043a4:	c80d                	beqz	s0,ffffffffc02043d6 <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02043a6:	03000513          	li	a0,48
ffffffffc02043aa:	f34fd0ef          	jal	ra,ffffffffc0201ade <kmalloc>
ffffffffc02043ae:	85aa                	mv	a1,a0
ffffffffc02043b0:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc02043b4:	f165                	bnez	a0,ffffffffc0204394 <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc02043b6:	00003697          	auipc	a3,0x3
ffffffffc02043ba:	53268693          	addi	a3,a3,1330 # ffffffffc02078e8 <default_pmm_manager+0x7b0>
ffffffffc02043be:	00002617          	auipc	a2,0x2
ffffffffc02043c2:	6e260613          	addi	a2,a2,1762 # ffffffffc0206aa0 <commands+0x450>
ffffffffc02043c6:	11300593          	li	a1,275
ffffffffc02043ca:	00004517          	auipc	a0,0x4
ffffffffc02043ce:	9ae50513          	addi	a0,a0,-1618 # ffffffffc0207d78 <default_pmm_manager+0xc40>
ffffffffc02043d2:	8a8fc0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc02043d6:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02043da:	1f900913          	li	s2,505
ffffffffc02043de:	a819                	j	ffffffffc02043f4 <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc02043e0:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc02043e2:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02043e4:	00052c23          	sw	zero,24(a0)
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02043e8:	0415                	addi	s0,s0,5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02043ea:	8526                	mv	a0,s1
ffffffffc02043ec:	ca9ff0ef          	jal	ra,ffffffffc0204094 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02043f0:	03240a63          	beq	s0,s2,ffffffffc0204424 <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02043f4:	03000513          	li	a0,48
ffffffffc02043f8:	ee6fd0ef          	jal	ra,ffffffffc0201ade <kmalloc>
ffffffffc02043fc:	85aa                	mv	a1,a0
ffffffffc02043fe:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0204402:	fd79                	bnez	a0,ffffffffc02043e0 <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc0204404:	00003697          	auipc	a3,0x3
ffffffffc0204408:	4e468693          	addi	a3,a3,1252 # ffffffffc02078e8 <default_pmm_manager+0x7b0>
ffffffffc020440c:	00002617          	auipc	a2,0x2
ffffffffc0204410:	69460613          	addi	a2,a2,1684 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0204414:	11900593          	li	a1,281
ffffffffc0204418:	00004517          	auipc	a0,0x4
ffffffffc020441c:	96050513          	addi	a0,a0,-1696 # ffffffffc0207d78 <default_pmm_manager+0xc40>
ffffffffc0204420:	85afc0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc0204424:	649c                	ld	a5,8(s1)
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
        assert(le != &(mm->mmap_list));
ffffffffc0204426:	471d                	li	a4,7
    for (i = 1; i <= step2; i ++) {
ffffffffc0204428:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc020442c:	2cf48d63          	beq	s1,a5,ffffffffc0204706 <vmm_init+0x390>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0204430:	fe87b683          	ld	a3,-24(a5) # ffffffffffffefe8 <end+0x3fd4c7fc>
ffffffffc0204434:	ffe70613          	addi	a2,a4,-2
ffffffffc0204438:	24d61763          	bne	a2,a3,ffffffffc0204686 <vmm_init+0x310>
ffffffffc020443c:	ff07b683          	ld	a3,-16(a5)
ffffffffc0204440:	24e69363          	bne	a3,a4,ffffffffc0204686 <vmm_init+0x310>
    for (i = 1; i <= step2; i ++) {
ffffffffc0204444:	0715                	addi	a4,a4,5
ffffffffc0204446:	679c                	ld	a5,8(a5)
ffffffffc0204448:	feb712e3          	bne	a4,a1,ffffffffc020442c <vmm_init+0xb6>
ffffffffc020444c:	4a1d                	li	s4,7
ffffffffc020444e:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0204450:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0204454:	85a2                	mv	a1,s0
ffffffffc0204456:	8526                	mv	a0,s1
ffffffffc0204458:	bfdff0ef          	jal	ra,ffffffffc0204054 <find_vma>
ffffffffc020445c:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc020445e:	30050463          	beqz	a0,ffffffffc0204766 <vmm_init+0x3f0>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0204462:	00140593          	addi	a1,s0,1
ffffffffc0204466:	8526                	mv	a0,s1
ffffffffc0204468:	bedff0ef          	jal	ra,ffffffffc0204054 <find_vma>
ffffffffc020446c:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc020446e:	2c050c63          	beqz	a0,ffffffffc0204746 <vmm_init+0x3d0>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0204472:	85d2                	mv	a1,s4
ffffffffc0204474:	8526                	mv	a0,s1
ffffffffc0204476:	bdfff0ef          	jal	ra,ffffffffc0204054 <find_vma>
        assert(vma3 == NULL);
ffffffffc020447a:	2a051663          	bnez	a0,ffffffffc0204726 <vmm_init+0x3b0>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc020447e:	00340593          	addi	a1,s0,3
ffffffffc0204482:	8526                	mv	a0,s1
ffffffffc0204484:	bd1ff0ef          	jal	ra,ffffffffc0204054 <find_vma>
        assert(vma4 == NULL);
ffffffffc0204488:	30051f63          	bnez	a0,ffffffffc02047a6 <vmm_init+0x430>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc020448c:	00440593          	addi	a1,s0,4
ffffffffc0204490:	8526                	mv	a0,s1
ffffffffc0204492:	bc3ff0ef          	jal	ra,ffffffffc0204054 <find_vma>
        assert(vma5 == NULL);
ffffffffc0204496:	2e051863          	bnez	a0,ffffffffc0204786 <vmm_init+0x410>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc020449a:	00893783          	ld	a5,8(s2)
ffffffffc020449e:	20879463          	bne	a5,s0,ffffffffc02046a6 <vmm_init+0x330>
ffffffffc02044a2:	01093783          	ld	a5,16(s2)
ffffffffc02044a6:	20fa1063          	bne	s4,a5,ffffffffc02046a6 <vmm_init+0x330>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02044aa:	0089b783          	ld	a5,8(s3)
ffffffffc02044ae:	20879c63          	bne	a5,s0,ffffffffc02046c6 <vmm_init+0x350>
ffffffffc02044b2:	0109b783          	ld	a5,16(s3)
ffffffffc02044b6:	20fa1863          	bne	s4,a5,ffffffffc02046c6 <vmm_init+0x350>
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc02044ba:	0415                	addi	s0,s0,5
ffffffffc02044bc:	0a15                	addi	s4,s4,5
ffffffffc02044be:	f9541be3          	bne	s0,s5,ffffffffc0204454 <vmm_init+0xde>
ffffffffc02044c2:	4411                	li	s0,4
    }

    for (i =4; i>=0; i--) {
ffffffffc02044c4:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc02044c6:	85a2                	mv	a1,s0
ffffffffc02044c8:	8526                	mv	a0,s1
ffffffffc02044ca:	b8bff0ef          	jal	ra,ffffffffc0204054 <find_vma>
ffffffffc02044ce:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL ) {
ffffffffc02044d2:	c90d                	beqz	a0,ffffffffc0204504 <vmm_init+0x18e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc02044d4:	6914                	ld	a3,16(a0)
ffffffffc02044d6:	6510                	ld	a2,8(a0)
ffffffffc02044d8:	00004517          	auipc	a0,0x4
ffffffffc02044dc:	a6850513          	addi	a0,a0,-1432 # ffffffffc0207f40 <default_pmm_manager+0xe08>
ffffffffc02044e0:	ca1fb0ef          	jal	ra,ffffffffc0200180 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc02044e4:	00004697          	auipc	a3,0x4
ffffffffc02044e8:	a8468693          	addi	a3,a3,-1404 # ffffffffc0207f68 <default_pmm_manager+0xe30>
ffffffffc02044ec:	00002617          	auipc	a2,0x2
ffffffffc02044f0:	5b460613          	addi	a2,a2,1460 # ffffffffc0206aa0 <commands+0x450>
ffffffffc02044f4:	13b00593          	li	a1,315
ffffffffc02044f8:	00004517          	auipc	a0,0x4
ffffffffc02044fc:	88050513          	addi	a0,a0,-1920 # ffffffffc0207d78 <default_pmm_manager+0xc40>
ffffffffc0204500:	f7bfb0ef          	jal	ra,ffffffffc020047a <__panic>
    for (i =4; i>=0; i--) {
ffffffffc0204504:	147d                	addi	s0,s0,-1
ffffffffc0204506:	fd2410e3          	bne	s0,s2,ffffffffc02044c6 <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc020450a:	8526                	mv	a0,s1
ffffffffc020450c:	c59ff0ef          	jal	ra,ffffffffc0204164 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0204510:	00004517          	auipc	a0,0x4
ffffffffc0204514:	a7050513          	addi	a0,a0,-1424 # ffffffffc0207f80 <default_pmm_manager+0xe48>
ffffffffc0204518:	c69fb0ef          	jal	ra,ffffffffc0200180 <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc020451c:	873fd0ef          	jal	ra,ffffffffc0201d8e <nr_free_pages>
ffffffffc0204520:	892a                	mv	s2,a0

    check_mm_struct = mm_create();
ffffffffc0204522:	abdff0ef          	jal	ra,ffffffffc0203fde <mm_create>
ffffffffc0204526:	000ae797          	auipc	a5,0xae
ffffffffc020452a:	28a7bd23          	sd	a0,666(a5) # ffffffffc02b27c0 <check_mm_struct>
ffffffffc020452e:	842a                	mv	s0,a0
    assert(check_mm_struct != NULL);
ffffffffc0204530:	28050b63          	beqz	a0,ffffffffc02047c6 <vmm_init+0x450>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0204534:	000ae497          	auipc	s1,0xae
ffffffffc0204538:	24c4b483          	ld	s1,588(s1) # ffffffffc02b2780 <boot_pgdir>
    assert(pgdir[0] == 0);
ffffffffc020453c:	609c                	ld	a5,0(s1)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020453e:	ed04                	sd	s1,24(a0)
    assert(pgdir[0] == 0);
ffffffffc0204540:	2e079f63          	bnez	a5,ffffffffc020483e <vmm_init+0x4c8>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204544:	03000513          	li	a0,48
ffffffffc0204548:	d96fd0ef          	jal	ra,ffffffffc0201ade <kmalloc>
ffffffffc020454c:	89aa                	mv	s3,a0
    if (vma != NULL) {
ffffffffc020454e:	18050c63          	beqz	a0,ffffffffc02046e6 <vmm_init+0x370>
        vma->vm_end = vm_end;
ffffffffc0204552:	002007b7          	lui	a5,0x200
ffffffffc0204556:	00f9b823          	sd	a5,16(s3)
        vma->vm_flags = vm_flags;
ffffffffc020455a:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc020455c:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc020455e:	00f9ac23          	sw	a5,24(s3)
    insert_vma_struct(mm, vma);
ffffffffc0204562:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc0204564:	0009b423          	sd	zero,8(s3)
    insert_vma_struct(mm, vma);
ffffffffc0204568:	b2dff0ef          	jal	ra,ffffffffc0204094 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc020456c:	10000593          	li	a1,256
ffffffffc0204570:	8522                	mv	a0,s0
ffffffffc0204572:	ae3ff0ef          	jal	ra,ffffffffc0204054 <find_vma>
ffffffffc0204576:	10000793          	li	a5,256

    int i, sum = 0;

    for (i = 0; i < 100; i ++) {
ffffffffc020457a:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc020457e:	2ea99063          	bne	s3,a0,ffffffffc020485e <vmm_init+0x4e8>
        *(char *)(addr + i) = i;
ffffffffc0204582:	00f78023          	sb	a5,0(a5) # 200000 <_binary_obj___user_exit_out_size+0x1f4ee0>
    for (i = 0; i < 100; i ++) {
ffffffffc0204586:	0785                	addi	a5,a5,1
ffffffffc0204588:	fee79de3          	bne	a5,a4,ffffffffc0204582 <vmm_init+0x20c>
        sum += i;
ffffffffc020458c:	6705                	lui	a4,0x1
ffffffffc020458e:	10000793          	li	a5,256
ffffffffc0204592:	35670713          	addi	a4,a4,854 # 1356 <_binary_obj___user_faultread_out_size-0x8852>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0204596:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc020459a:	0007c683          	lbu	a3,0(a5)
    for (i = 0; i < 100; i ++) {
ffffffffc020459e:	0785                	addi	a5,a5,1
        sum -= *(char *)(addr + i);
ffffffffc02045a0:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc02045a2:	fec79ce3          	bne	a5,a2,ffffffffc020459a <vmm_init+0x224>
    }

    assert(sum == 0);
ffffffffc02045a6:	2e071863          	bnez	a4,ffffffffc0204896 <vmm_init+0x520>
    return pa2page(PDE_ADDR(pde));
ffffffffc02045aa:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc02045ac:	000aea97          	auipc	s5,0xae
ffffffffc02045b0:	1dca8a93          	addi	s5,s5,476 # ffffffffc02b2788 <npage>
ffffffffc02045b4:	000ab603          	ld	a2,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02045b8:	078a                	slli	a5,a5,0x2
ffffffffc02045ba:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02045bc:	2cc7f163          	bgeu	a5,a2,ffffffffc020487e <vmm_init+0x508>
    return &pages[PPN(pa) - nbase];
ffffffffc02045c0:	00004a17          	auipc	s4,0x4
ffffffffc02045c4:	498a3a03          	ld	s4,1176(s4) # ffffffffc0208a58 <nbase>
ffffffffc02045c8:	414787b3          	sub	a5,a5,s4
ffffffffc02045cc:	079a                	slli	a5,a5,0x6
    return page - pages + nbase;
ffffffffc02045ce:	8799                	srai	a5,a5,0x6
ffffffffc02045d0:	97d2                	add	a5,a5,s4
    return KADDR(page2pa(page));
ffffffffc02045d2:	00c79713          	slli	a4,a5,0xc
ffffffffc02045d6:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02045d8:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc02045dc:	24c77563          	bgeu	a4,a2,ffffffffc0204826 <vmm_init+0x4b0>
ffffffffc02045e0:	000ae997          	auipc	s3,0xae
ffffffffc02045e4:	1c09b983          	ld	s3,448(s3) # ffffffffc02b27a0 <va_pa_offset>

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc02045e8:	4581                	li	a1,0
ffffffffc02045ea:	8526                	mv	a0,s1
ffffffffc02045ec:	99b6                	add	s3,s3,a3
ffffffffc02045ee:	f65fd0ef          	jal	ra,ffffffffc0202552 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc02045f2:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc02045f6:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02045fa:	078a                	slli	a5,a5,0x2
ffffffffc02045fc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02045fe:	28e7f063          	bgeu	a5,a4,ffffffffc020487e <vmm_init+0x508>
    return &pages[PPN(pa) - nbase];
ffffffffc0204602:	000ae997          	auipc	s3,0xae
ffffffffc0204606:	18e98993          	addi	s3,s3,398 # ffffffffc02b2790 <pages>
ffffffffc020460a:	0009b503          	ld	a0,0(s3)
ffffffffc020460e:	414787b3          	sub	a5,a5,s4
ffffffffc0204612:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0204614:	953e                	add	a0,a0,a5
ffffffffc0204616:	4585                	li	a1,1
ffffffffc0204618:	f36fd0ef          	jal	ra,ffffffffc0201d4e <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc020461c:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc020461e:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0204622:	078a                	slli	a5,a5,0x2
ffffffffc0204624:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204626:	24e7fc63          	bgeu	a5,a4,ffffffffc020487e <vmm_init+0x508>
    return &pages[PPN(pa) - nbase];
ffffffffc020462a:	0009b503          	ld	a0,0(s3)
ffffffffc020462e:	414787b3          	sub	a5,a5,s4
ffffffffc0204632:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0204634:	4585                	li	a1,1
ffffffffc0204636:	953e                	add	a0,a0,a5
ffffffffc0204638:	f16fd0ef          	jal	ra,ffffffffc0201d4e <free_pages>
    pgdir[0] = 0;
ffffffffc020463c:	0004b023          	sd	zero,0(s1)
  asm volatile("sfence.vma");
ffffffffc0204640:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
    mm_destroy(mm);
ffffffffc0204644:	8522                	mv	a0,s0
    mm->pgdir = NULL;
ffffffffc0204646:	00043c23          	sd	zero,24(s0)
    mm_destroy(mm);
ffffffffc020464a:	b1bff0ef          	jal	ra,ffffffffc0204164 <mm_destroy>
    check_mm_struct = NULL;
ffffffffc020464e:	000ae797          	auipc	a5,0xae
ffffffffc0204652:	1607b923          	sd	zero,370(a5) # ffffffffc02b27c0 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0204656:	f38fd0ef          	jal	ra,ffffffffc0201d8e <nr_free_pages>
ffffffffc020465a:	1aa91663          	bne	s2,a0,ffffffffc0204806 <vmm_init+0x490>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc020465e:	00004517          	auipc	a0,0x4
ffffffffc0204662:	9b250513          	addi	a0,a0,-1614 # ffffffffc0208010 <default_pmm_manager+0xed8>
ffffffffc0204666:	b1bfb0ef          	jal	ra,ffffffffc0200180 <cprintf>
}
ffffffffc020466a:	7442                	ld	s0,48(sp)
ffffffffc020466c:	70e2                	ld	ra,56(sp)
ffffffffc020466e:	74a2                	ld	s1,40(sp)
ffffffffc0204670:	7902                	ld	s2,32(sp)
ffffffffc0204672:	69e2                	ld	s3,24(sp)
ffffffffc0204674:	6a42                	ld	s4,16(sp)
ffffffffc0204676:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0204678:	00004517          	auipc	a0,0x4
ffffffffc020467c:	9b850513          	addi	a0,a0,-1608 # ffffffffc0208030 <default_pmm_manager+0xef8>
}
ffffffffc0204680:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0204682:	afffb06f          	j	ffffffffc0200180 <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0204686:	00003697          	auipc	a3,0x3
ffffffffc020468a:	7d268693          	addi	a3,a3,2002 # ffffffffc0207e58 <default_pmm_manager+0xd20>
ffffffffc020468e:	00002617          	auipc	a2,0x2
ffffffffc0204692:	41260613          	addi	a2,a2,1042 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0204696:	12200593          	li	a1,290
ffffffffc020469a:	00003517          	auipc	a0,0x3
ffffffffc020469e:	6de50513          	addi	a0,a0,1758 # ffffffffc0207d78 <default_pmm_manager+0xc40>
ffffffffc02046a2:	dd9fb0ef          	jal	ra,ffffffffc020047a <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc02046a6:	00004697          	auipc	a3,0x4
ffffffffc02046aa:	83a68693          	addi	a3,a3,-1990 # ffffffffc0207ee0 <default_pmm_manager+0xda8>
ffffffffc02046ae:	00002617          	auipc	a2,0x2
ffffffffc02046b2:	3f260613          	addi	a2,a2,1010 # ffffffffc0206aa0 <commands+0x450>
ffffffffc02046b6:	13200593          	li	a1,306
ffffffffc02046ba:	00003517          	auipc	a0,0x3
ffffffffc02046be:	6be50513          	addi	a0,a0,1726 # ffffffffc0207d78 <default_pmm_manager+0xc40>
ffffffffc02046c2:	db9fb0ef          	jal	ra,ffffffffc020047a <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02046c6:	00004697          	auipc	a3,0x4
ffffffffc02046ca:	84a68693          	addi	a3,a3,-1974 # ffffffffc0207f10 <default_pmm_manager+0xdd8>
ffffffffc02046ce:	00002617          	auipc	a2,0x2
ffffffffc02046d2:	3d260613          	addi	a2,a2,978 # ffffffffc0206aa0 <commands+0x450>
ffffffffc02046d6:	13300593          	li	a1,307
ffffffffc02046da:	00003517          	auipc	a0,0x3
ffffffffc02046de:	69e50513          	addi	a0,a0,1694 # ffffffffc0207d78 <default_pmm_manager+0xc40>
ffffffffc02046e2:	d99fb0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(vma != NULL);
ffffffffc02046e6:	00003697          	auipc	a3,0x3
ffffffffc02046ea:	20268693          	addi	a3,a3,514 # ffffffffc02078e8 <default_pmm_manager+0x7b0>
ffffffffc02046ee:	00002617          	auipc	a2,0x2
ffffffffc02046f2:	3b260613          	addi	a2,a2,946 # ffffffffc0206aa0 <commands+0x450>
ffffffffc02046f6:	15200593          	li	a1,338
ffffffffc02046fa:	00003517          	auipc	a0,0x3
ffffffffc02046fe:	67e50513          	addi	a0,a0,1662 # ffffffffc0207d78 <default_pmm_manager+0xc40>
ffffffffc0204702:	d79fb0ef          	jal	ra,ffffffffc020047a <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0204706:	00003697          	auipc	a3,0x3
ffffffffc020470a:	73a68693          	addi	a3,a3,1850 # ffffffffc0207e40 <default_pmm_manager+0xd08>
ffffffffc020470e:	00002617          	auipc	a2,0x2
ffffffffc0204712:	39260613          	addi	a2,a2,914 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0204716:	12000593          	li	a1,288
ffffffffc020471a:	00003517          	auipc	a0,0x3
ffffffffc020471e:	65e50513          	addi	a0,a0,1630 # ffffffffc0207d78 <default_pmm_manager+0xc40>
ffffffffc0204722:	d59fb0ef          	jal	ra,ffffffffc020047a <__panic>
        assert(vma3 == NULL);
ffffffffc0204726:	00003697          	auipc	a3,0x3
ffffffffc020472a:	78a68693          	addi	a3,a3,1930 # ffffffffc0207eb0 <default_pmm_manager+0xd78>
ffffffffc020472e:	00002617          	auipc	a2,0x2
ffffffffc0204732:	37260613          	addi	a2,a2,882 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0204736:	12c00593          	li	a1,300
ffffffffc020473a:	00003517          	auipc	a0,0x3
ffffffffc020473e:	63e50513          	addi	a0,a0,1598 # ffffffffc0207d78 <default_pmm_manager+0xc40>
ffffffffc0204742:	d39fb0ef          	jal	ra,ffffffffc020047a <__panic>
        assert(vma2 != NULL);
ffffffffc0204746:	00003697          	auipc	a3,0x3
ffffffffc020474a:	75a68693          	addi	a3,a3,1882 # ffffffffc0207ea0 <default_pmm_manager+0xd68>
ffffffffc020474e:	00002617          	auipc	a2,0x2
ffffffffc0204752:	35260613          	addi	a2,a2,850 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0204756:	12a00593          	li	a1,298
ffffffffc020475a:	00003517          	auipc	a0,0x3
ffffffffc020475e:	61e50513          	addi	a0,a0,1566 # ffffffffc0207d78 <default_pmm_manager+0xc40>
ffffffffc0204762:	d19fb0ef          	jal	ra,ffffffffc020047a <__panic>
        assert(vma1 != NULL);
ffffffffc0204766:	00003697          	auipc	a3,0x3
ffffffffc020476a:	72a68693          	addi	a3,a3,1834 # ffffffffc0207e90 <default_pmm_manager+0xd58>
ffffffffc020476e:	00002617          	auipc	a2,0x2
ffffffffc0204772:	33260613          	addi	a2,a2,818 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0204776:	12800593          	li	a1,296
ffffffffc020477a:	00003517          	auipc	a0,0x3
ffffffffc020477e:	5fe50513          	addi	a0,a0,1534 # ffffffffc0207d78 <default_pmm_manager+0xc40>
ffffffffc0204782:	cf9fb0ef          	jal	ra,ffffffffc020047a <__panic>
        assert(vma5 == NULL);
ffffffffc0204786:	00003697          	auipc	a3,0x3
ffffffffc020478a:	74a68693          	addi	a3,a3,1866 # ffffffffc0207ed0 <default_pmm_manager+0xd98>
ffffffffc020478e:	00002617          	auipc	a2,0x2
ffffffffc0204792:	31260613          	addi	a2,a2,786 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0204796:	13000593          	li	a1,304
ffffffffc020479a:	00003517          	auipc	a0,0x3
ffffffffc020479e:	5de50513          	addi	a0,a0,1502 # ffffffffc0207d78 <default_pmm_manager+0xc40>
ffffffffc02047a2:	cd9fb0ef          	jal	ra,ffffffffc020047a <__panic>
        assert(vma4 == NULL);
ffffffffc02047a6:	00003697          	auipc	a3,0x3
ffffffffc02047aa:	71a68693          	addi	a3,a3,1818 # ffffffffc0207ec0 <default_pmm_manager+0xd88>
ffffffffc02047ae:	00002617          	auipc	a2,0x2
ffffffffc02047b2:	2f260613          	addi	a2,a2,754 # ffffffffc0206aa0 <commands+0x450>
ffffffffc02047b6:	12e00593          	li	a1,302
ffffffffc02047ba:	00003517          	auipc	a0,0x3
ffffffffc02047be:	5be50513          	addi	a0,a0,1470 # ffffffffc0207d78 <default_pmm_manager+0xc40>
ffffffffc02047c2:	cb9fb0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(check_mm_struct != NULL);
ffffffffc02047c6:	00003697          	auipc	a3,0x3
ffffffffc02047ca:	7da68693          	addi	a3,a3,2010 # ffffffffc0207fa0 <default_pmm_manager+0xe68>
ffffffffc02047ce:	00002617          	auipc	a2,0x2
ffffffffc02047d2:	2d260613          	addi	a2,a2,722 # ffffffffc0206aa0 <commands+0x450>
ffffffffc02047d6:	14b00593          	li	a1,331
ffffffffc02047da:	00003517          	auipc	a0,0x3
ffffffffc02047de:	59e50513          	addi	a0,a0,1438 # ffffffffc0207d78 <default_pmm_manager+0xc40>
ffffffffc02047e2:	c99fb0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(mm != NULL);
ffffffffc02047e6:	00003697          	auipc	a3,0x3
ffffffffc02047ea:	0ca68693          	addi	a3,a3,202 # ffffffffc02078b0 <default_pmm_manager+0x778>
ffffffffc02047ee:	00002617          	auipc	a2,0x2
ffffffffc02047f2:	2b260613          	addi	a2,a2,690 # ffffffffc0206aa0 <commands+0x450>
ffffffffc02047f6:	10c00593          	li	a1,268
ffffffffc02047fa:	00003517          	auipc	a0,0x3
ffffffffc02047fe:	57e50513          	addi	a0,a0,1406 # ffffffffc0207d78 <default_pmm_manager+0xc40>
ffffffffc0204802:	c79fb0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0204806:	00003697          	auipc	a3,0x3
ffffffffc020480a:	7e268693          	addi	a3,a3,2018 # ffffffffc0207fe8 <default_pmm_manager+0xeb0>
ffffffffc020480e:	00002617          	auipc	a2,0x2
ffffffffc0204812:	29260613          	addi	a2,a2,658 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0204816:	17000593          	li	a1,368
ffffffffc020481a:	00003517          	auipc	a0,0x3
ffffffffc020481e:	55e50513          	addi	a0,a0,1374 # ffffffffc0207d78 <default_pmm_manager+0xc40>
ffffffffc0204822:	c59fb0ef          	jal	ra,ffffffffc020047a <__panic>
    return KADDR(page2pa(page));
ffffffffc0204826:	00003617          	auipc	a2,0x3
ffffffffc020482a:	94a60613          	addi	a2,a2,-1718 # ffffffffc0207170 <default_pmm_manager+0x38>
ffffffffc020482e:	06900593          	li	a1,105
ffffffffc0204832:	00003517          	auipc	a0,0x3
ffffffffc0204836:	96650513          	addi	a0,a0,-1690 # ffffffffc0207198 <default_pmm_manager+0x60>
ffffffffc020483a:	c41fb0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgdir[0] == 0);
ffffffffc020483e:	00003697          	auipc	a3,0x3
ffffffffc0204842:	09a68693          	addi	a3,a3,154 # ffffffffc02078d8 <default_pmm_manager+0x7a0>
ffffffffc0204846:	00002617          	auipc	a2,0x2
ffffffffc020484a:	25a60613          	addi	a2,a2,602 # ffffffffc0206aa0 <commands+0x450>
ffffffffc020484e:	14f00593          	li	a1,335
ffffffffc0204852:	00003517          	auipc	a0,0x3
ffffffffc0204856:	52650513          	addi	a0,a0,1318 # ffffffffc0207d78 <default_pmm_manager+0xc40>
ffffffffc020485a:	c21fb0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc020485e:	00003697          	auipc	a3,0x3
ffffffffc0204862:	75a68693          	addi	a3,a3,1882 # ffffffffc0207fb8 <default_pmm_manager+0xe80>
ffffffffc0204866:	00002617          	auipc	a2,0x2
ffffffffc020486a:	23a60613          	addi	a2,a2,570 # ffffffffc0206aa0 <commands+0x450>
ffffffffc020486e:	15700593          	li	a1,343
ffffffffc0204872:	00003517          	auipc	a0,0x3
ffffffffc0204876:	50650513          	addi	a0,a0,1286 # ffffffffc0207d78 <default_pmm_manager+0xc40>
ffffffffc020487a:	c01fb0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020487e:	00003617          	auipc	a2,0x3
ffffffffc0204882:	9c260613          	addi	a2,a2,-1598 # ffffffffc0207240 <default_pmm_manager+0x108>
ffffffffc0204886:	06200593          	li	a1,98
ffffffffc020488a:	00003517          	auipc	a0,0x3
ffffffffc020488e:	90e50513          	addi	a0,a0,-1778 # ffffffffc0207198 <default_pmm_manager+0x60>
ffffffffc0204892:	be9fb0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(sum == 0);
ffffffffc0204896:	00003697          	auipc	a3,0x3
ffffffffc020489a:	74268693          	addi	a3,a3,1858 # ffffffffc0207fd8 <default_pmm_manager+0xea0>
ffffffffc020489e:	00002617          	auipc	a2,0x2
ffffffffc02048a2:	20260613          	addi	a2,a2,514 # ffffffffc0206aa0 <commands+0x450>
ffffffffc02048a6:	16300593          	li	a1,355
ffffffffc02048aa:	00003517          	auipc	a0,0x3
ffffffffc02048ae:	4ce50513          	addi	a0,a0,1230 # ffffffffc0207d78 <default_pmm_manager+0xc40>
ffffffffc02048b2:	bc9fb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02048b6 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc02048b6:	1101                	addi	sp,sp,-32
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02048b8:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc02048ba:	e822                	sd	s0,16(sp)
ffffffffc02048bc:	e426                	sd	s1,8(sp)
ffffffffc02048be:	ec06                	sd	ra,24(sp)
ffffffffc02048c0:	e04a                	sd	s2,0(sp)
ffffffffc02048c2:	8432                	mv	s0,a2
ffffffffc02048c4:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02048c6:	f8eff0ef          	jal	ra,ffffffffc0204054 <find_vma>

    pgfault_num++;
ffffffffc02048ca:	000ae797          	auipc	a5,0xae
ffffffffc02048ce:	efe7a783          	lw	a5,-258(a5) # ffffffffc02b27c8 <pgfault_num>
ffffffffc02048d2:	2785                	addiw	a5,a5,1
ffffffffc02048d4:	000ae717          	auipc	a4,0xae
ffffffffc02048d8:	eef72a23          	sw	a5,-268(a4) # ffffffffc02b27c8 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc02048dc:	c931                	beqz	a0,ffffffffc0204930 <do_pgfault+0x7a>
ffffffffc02048de:	651c                	ld	a5,8(a0)
ffffffffc02048e0:	04f46863          	bltu	s0,a5,ffffffffc0204930 <do_pgfault+0x7a>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc02048e4:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc02048e6:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc02048e8:	8b89                	andi	a5,a5,2
ffffffffc02048ea:	e39d                	bnez	a5,ffffffffc0204910 <do_pgfault+0x5a>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02048ec:	75fd                	lui	a1,0xfffff

    pte_t *ptep=NULL;
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc02048ee:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02048f0:	8c6d                	and	s0,s0,a1
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc02048f2:	4605                	li	a2,1
ffffffffc02048f4:	85a2                	mv	a1,s0
ffffffffc02048f6:	cd2fd0ef          	jal	ra,ffffffffc0201dc8 <get_pte>
ffffffffc02048fa:	cd21                	beqz	a0,ffffffffc0204952 <do_pgfault+0x9c>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc02048fc:	610c                	ld	a1,0(a0)
ffffffffc02048fe:	c999                	beqz	a1,ffffffffc0204914 <do_pgfault+0x5e>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0204900:	000ae797          	auipc	a5,0xae
ffffffffc0204904:	eb87a783          	lw	a5,-328(a5) # ffffffffc02b27b8 <swap_init_ok>
ffffffffc0204908:	cf8d                	beqz	a5,ffffffffc0204942 <do_pgfault+0x8c>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            page->pra_vaddr = addr;
ffffffffc020490a:	02003c23          	sd	zero,56(zero) # 38 <_binary_obj___user_faultread_out_size-0x9b70>
ffffffffc020490e:	9002                	ebreak
        perm |= READ_WRITE;
ffffffffc0204910:	495d                	li	s2,23
ffffffffc0204912:	bfe9                	j	ffffffffc02048ec <do_pgfault+0x36>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0204914:	6c88                	ld	a0,24(s1)
ffffffffc0204916:	864a                	mv	a2,s2
ffffffffc0204918:	85a2                	mv	a1,s0
ffffffffc020491a:	96bfe0ef          	jal	ra,ffffffffc0203284 <pgdir_alloc_page>
ffffffffc020491e:	87aa                	mv	a5,a0
        } else {
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }
   ret = 0;
ffffffffc0204920:	4501                	li	a0,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0204922:	c3a1                	beqz	a5,ffffffffc0204962 <do_pgfault+0xac>
failed:
    return ret;
}
ffffffffc0204924:	60e2                	ld	ra,24(sp)
ffffffffc0204926:	6442                	ld	s0,16(sp)
ffffffffc0204928:	64a2                	ld	s1,8(sp)
ffffffffc020492a:	6902                	ld	s2,0(sp)
ffffffffc020492c:	6105                	addi	sp,sp,32
ffffffffc020492e:	8082                	ret
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0204930:	85a2                	mv	a1,s0
ffffffffc0204932:	00003517          	auipc	a0,0x3
ffffffffc0204936:	71650513          	addi	a0,a0,1814 # ffffffffc0208048 <default_pmm_manager+0xf10>
ffffffffc020493a:	847fb0ef          	jal	ra,ffffffffc0200180 <cprintf>
    int ret = -E_INVAL;
ffffffffc020493e:	5575                	li	a0,-3
        goto failed;
ffffffffc0204940:	b7d5                	j	ffffffffc0204924 <do_pgfault+0x6e>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0204942:	00003517          	auipc	a0,0x3
ffffffffc0204946:	77e50513          	addi	a0,a0,1918 # ffffffffc02080c0 <default_pmm_manager+0xf88>
ffffffffc020494a:	837fb0ef          	jal	ra,ffffffffc0200180 <cprintf>
    ret = -E_NO_MEM;
ffffffffc020494e:	5571                	li	a0,-4
            goto failed;
ffffffffc0204950:	bfd1                	j	ffffffffc0204924 <do_pgfault+0x6e>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc0204952:	00003517          	auipc	a0,0x3
ffffffffc0204956:	72650513          	addi	a0,a0,1830 # ffffffffc0208078 <default_pmm_manager+0xf40>
ffffffffc020495a:	827fb0ef          	jal	ra,ffffffffc0200180 <cprintf>
    ret = -E_NO_MEM;
ffffffffc020495e:	5571                	li	a0,-4
        goto failed;
ffffffffc0204960:	b7d1                	j	ffffffffc0204924 <do_pgfault+0x6e>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0204962:	00003517          	auipc	a0,0x3
ffffffffc0204966:	73650513          	addi	a0,a0,1846 # ffffffffc0208098 <default_pmm_manager+0xf60>
ffffffffc020496a:	817fb0ef          	jal	ra,ffffffffc0200180 <cprintf>
    ret = -E_NO_MEM;
ffffffffc020496e:	5571                	li	a0,-4
            goto failed;
ffffffffc0204970:	bf55                	j	ffffffffc0204924 <do_pgfault+0x6e>

ffffffffc0204972 <user_mem_check>:

bool
user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
ffffffffc0204972:	7179                	addi	sp,sp,-48
ffffffffc0204974:	f022                	sd	s0,32(sp)
ffffffffc0204976:	f406                	sd	ra,40(sp)
ffffffffc0204978:	ec26                	sd	s1,24(sp)
ffffffffc020497a:	e84a                	sd	s2,16(sp)
ffffffffc020497c:	e44e                	sd	s3,8(sp)
ffffffffc020497e:	e052                	sd	s4,0(sp)
ffffffffc0204980:	842e                	mv	s0,a1
    if (mm != NULL) {
ffffffffc0204982:	c135                	beqz	a0,ffffffffc02049e6 <user_mem_check+0x74>
        if (!USER_ACCESS(addr, addr + len)) {
ffffffffc0204984:	002007b7          	lui	a5,0x200
ffffffffc0204988:	04f5e663          	bltu	a1,a5,ffffffffc02049d4 <user_mem_check+0x62>
ffffffffc020498c:	00c584b3          	add	s1,a1,a2
ffffffffc0204990:	0495f263          	bgeu	a1,s1,ffffffffc02049d4 <user_mem_check+0x62>
ffffffffc0204994:	4785                	li	a5,1
ffffffffc0204996:	07fe                	slli	a5,a5,0x1f
ffffffffc0204998:	0297ee63          	bltu	a5,s1,ffffffffc02049d4 <user_mem_check+0x62>
ffffffffc020499c:	892a                	mv	s2,a0
ffffffffc020499e:	89b6                	mv	s3,a3
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK)) {
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc02049a0:	6a05                	lui	s4,0x1
ffffffffc02049a2:	a821                	j	ffffffffc02049ba <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc02049a4:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc02049a8:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc02049aa:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc02049ac:	c685                	beqz	a3,ffffffffc02049d4 <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc02049ae:	c399                	beqz	a5,ffffffffc02049b4 <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc02049b0:	02e46263          	bltu	s0,a4,ffffffffc02049d4 <user_mem_check+0x62>
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc02049b4:	6900                	ld	s0,16(a0)
        while (start < end) {
ffffffffc02049b6:	04947663          	bgeu	s0,s1,ffffffffc0204a02 <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
ffffffffc02049ba:	85a2                	mv	a1,s0
ffffffffc02049bc:	854a                	mv	a0,s2
ffffffffc02049be:	e96ff0ef          	jal	ra,ffffffffc0204054 <find_vma>
ffffffffc02049c2:	c909                	beqz	a0,ffffffffc02049d4 <user_mem_check+0x62>
ffffffffc02049c4:	6518                	ld	a4,8(a0)
ffffffffc02049c6:	00e46763          	bltu	s0,a4,ffffffffc02049d4 <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc02049ca:	4d1c                	lw	a5,24(a0)
ffffffffc02049cc:	fc099ce3          	bnez	s3,ffffffffc02049a4 <user_mem_check+0x32>
ffffffffc02049d0:	8b85                	andi	a5,a5,1
ffffffffc02049d2:	f3ed                	bnez	a5,ffffffffc02049b4 <user_mem_check+0x42>
            return 0;
ffffffffc02049d4:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc02049d6:	70a2                	ld	ra,40(sp)
ffffffffc02049d8:	7402                	ld	s0,32(sp)
ffffffffc02049da:	64e2                	ld	s1,24(sp)
ffffffffc02049dc:	6942                	ld	s2,16(sp)
ffffffffc02049de:	69a2                	ld	s3,8(sp)
ffffffffc02049e0:	6a02                	ld	s4,0(sp)
ffffffffc02049e2:	6145                	addi	sp,sp,48
ffffffffc02049e4:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc02049e6:	c02007b7          	lui	a5,0xc0200
ffffffffc02049ea:	4501                	li	a0,0
ffffffffc02049ec:	fef5e5e3          	bltu	a1,a5,ffffffffc02049d6 <user_mem_check+0x64>
ffffffffc02049f0:	962e                	add	a2,a2,a1
ffffffffc02049f2:	fec5f2e3          	bgeu	a1,a2,ffffffffc02049d6 <user_mem_check+0x64>
ffffffffc02049f6:	c8000537          	lui	a0,0xc8000
ffffffffc02049fa:	0505                	addi	a0,a0,1
ffffffffc02049fc:	00a63533          	sltu	a0,a2,a0
ffffffffc0204a00:	bfd9                	j	ffffffffc02049d6 <user_mem_check+0x64>
        return 1;
ffffffffc0204a02:	4505                	li	a0,1
ffffffffc0204a04:	bfc9                	j	ffffffffc02049d6 <user_mem_check+0x64>

ffffffffc0204a06 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0204a06:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204a08:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0204a0a:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204a0c:	be1fb0ef          	jal	ra,ffffffffc02005ec <ide_device_valid>
ffffffffc0204a10:	cd01                	beqz	a0,ffffffffc0204a28 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204a12:	4505                	li	a0,1
ffffffffc0204a14:	bdffb0ef          	jal	ra,ffffffffc02005f2 <ide_device_size>
}
ffffffffc0204a18:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204a1a:	810d                	srli	a0,a0,0x3
ffffffffc0204a1c:	000ae797          	auipc	a5,0xae
ffffffffc0204a20:	d8a7b623          	sd	a0,-628(a5) # ffffffffc02b27a8 <max_swap_offset>
}
ffffffffc0204a24:	0141                	addi	sp,sp,16
ffffffffc0204a26:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0204a28:	00003617          	auipc	a2,0x3
ffffffffc0204a2c:	6c060613          	addi	a2,a2,1728 # ffffffffc02080e8 <default_pmm_manager+0xfb0>
ffffffffc0204a30:	45b5                	li	a1,13
ffffffffc0204a32:	00003517          	auipc	a0,0x3
ffffffffc0204a36:	6d650513          	addi	a0,a0,1750 # ffffffffc0208108 <default_pmm_manager+0xfd0>
ffffffffc0204a3a:	a41fb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0204a3e <swapfs_write>:
swapfs_read(swap_entry_t entry, struct Page *page) {
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
}

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0204a3e:	1141                	addi	sp,sp,-16
ffffffffc0204a40:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204a42:	00855793          	srli	a5,a0,0x8
ffffffffc0204a46:	cbb1                	beqz	a5,ffffffffc0204a9a <swapfs_write+0x5c>
ffffffffc0204a48:	000ae717          	auipc	a4,0xae
ffffffffc0204a4c:	d6073703          	ld	a4,-672(a4) # ffffffffc02b27a8 <max_swap_offset>
ffffffffc0204a50:	04e7f563          	bgeu	a5,a4,ffffffffc0204a9a <swapfs_write+0x5c>
    return page - pages + nbase;
ffffffffc0204a54:	000ae617          	auipc	a2,0xae
ffffffffc0204a58:	d3c63603          	ld	a2,-708(a2) # ffffffffc02b2790 <pages>
ffffffffc0204a5c:	8d91                	sub	a1,a1,a2
ffffffffc0204a5e:	4065d613          	srai	a2,a1,0x6
ffffffffc0204a62:	00004717          	auipc	a4,0x4
ffffffffc0204a66:	ff673703          	ld	a4,-10(a4) # ffffffffc0208a58 <nbase>
ffffffffc0204a6a:	963a                	add	a2,a2,a4
    return KADDR(page2pa(page));
ffffffffc0204a6c:	00c61713          	slli	a4,a2,0xc
ffffffffc0204a70:	8331                	srli	a4,a4,0xc
ffffffffc0204a72:	000ae697          	auipc	a3,0xae
ffffffffc0204a76:	d166b683          	ld	a3,-746(a3) # ffffffffc02b2788 <npage>
ffffffffc0204a7a:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204a7e:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204a80:	02d77963          	bgeu	a4,a3,ffffffffc0204ab2 <swapfs_write+0x74>
}
ffffffffc0204a84:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204a86:	000ae797          	auipc	a5,0xae
ffffffffc0204a8a:	d1a7b783          	ld	a5,-742(a5) # ffffffffc02b27a0 <va_pa_offset>
ffffffffc0204a8e:	46a1                	li	a3,8
ffffffffc0204a90:	963e                	add	a2,a2,a5
ffffffffc0204a92:	4505                	li	a0,1
}
ffffffffc0204a94:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204a96:	b63fb06f          	j	ffffffffc02005f8 <ide_write_secs>
ffffffffc0204a9a:	86aa                	mv	a3,a0
ffffffffc0204a9c:	00003617          	auipc	a2,0x3
ffffffffc0204aa0:	68460613          	addi	a2,a2,1668 # ffffffffc0208120 <default_pmm_manager+0xfe8>
ffffffffc0204aa4:	45e5                	li	a1,25
ffffffffc0204aa6:	00003517          	auipc	a0,0x3
ffffffffc0204aaa:	66250513          	addi	a0,a0,1634 # ffffffffc0208108 <default_pmm_manager+0xfd0>
ffffffffc0204aae:	9cdfb0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc0204ab2:	86b2                	mv	a3,a2
ffffffffc0204ab4:	06900593          	li	a1,105
ffffffffc0204ab8:	00002617          	auipc	a2,0x2
ffffffffc0204abc:	6b860613          	addi	a2,a2,1720 # ffffffffc0207170 <default_pmm_manager+0x38>
ffffffffc0204ac0:	00002517          	auipc	a0,0x2
ffffffffc0204ac4:	6d850513          	addi	a0,a0,1752 # ffffffffc0207198 <default_pmm_manager+0x60>
ffffffffc0204ac8:	9b3fb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0204acc <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0204acc:	8526                	mv	a0,s1
	jalr s0
ffffffffc0204ace:	9402                	jalr	s0

	jal do_exit
ffffffffc0204ad0:	642000ef          	jal	ra,ffffffffc0205112 <do_exit>

ffffffffc0204ad4 <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
ffffffffc0204ad4:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204ad6:	10800513          	li	a0,264
alloc_proc(void) {
ffffffffc0204ada:	e022                	sd	s0,0(sp)
ffffffffc0204adc:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204ade:	800fd0ef          	jal	ra,ffffffffc0201ade <kmalloc>
ffffffffc0204ae2:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc0204ae4:	cd21                	beqz	a0,ffffffffc0204b3c <alloc_proc+0x68>
     *       uint32_t wait_state;                        // waiting state
     *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
     */

    // 初始化进程状态为未初始化
        proc->state = PROC_UNINIT;
ffffffffc0204ae6:	57fd                	li	a5,-1
ffffffffc0204ae8:	1782                	slli	a5,a5,0x20
ffffffffc0204aea:	e11c                	sd	a5,0(a0)

        // 内存管理结构体指针初始化为NULL，稍后由do_fork复制或共享
        proc->mm = NULL;

        // 上下文结构体清零
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204aec:	07000613          	li	a2,112
ffffffffc0204af0:	4581                	li	a1,0
        proc->runs = 0;
ffffffffc0204af2:	00052423          	sw	zero,8(a0)
        proc->kstack = 0;
ffffffffc0204af6:	00053823          	sd	zero,16(a0)
        proc->need_resched = 0;
ffffffffc0204afa:	00053c23          	sd	zero,24(a0)
        proc->parent = NULL;
ffffffffc0204afe:	02053023          	sd	zero,32(a0)
        proc->mm = NULL;
ffffffffc0204b02:	02053423          	sd	zero,40(a0)
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204b06:	03050513          	addi	a0,a0,48
ffffffffc0204b0a:	0af010ef          	jal	ra,ffffffffc02063b8 <memset>

        // 陷阱帧指针初始化为NULL，稍后由copy_thread设置
        proc->tf = NULL;

        // 页目录表基地址初始化为ucore内核表的起始地址
        proc->cr3 = boot_cr3;
ffffffffc0204b0e:	000ae797          	auipc	a5,0xae
ffffffffc0204b12:	c6a7b783          	ld	a5,-918(a5) # ffffffffc02b2778 <boot_cr3>
        proc->tf = NULL;
ffffffffc0204b16:	0a043023          	sd	zero,160(s0)
        proc->cr3 = boot_cr3;
ffffffffc0204b1a:	f45c                	sd	a5,168(s0)

        // 进程标志初始化为0
        proc->flags = 0;
ffffffffc0204b1c:	0a042823          	sw	zero,176(s0)

        // 进程名称初始化为空字符串
        memset(proc->name, 0, PROC_NAME_LEN);
ffffffffc0204b20:	463d                	li	a2,15
ffffffffc0204b22:	4581                	li	a1,0
ffffffffc0204b24:	0b440513          	addi	a0,s0,180
ffffffffc0204b28:	091010ef          	jal	ra,ffffffffc02063b8 <memset>

        // 初始化等待状态为0（默认不等待）
        proc->wait_state = 0;
ffffffffc0204b2c:	0e042623          	sw	zero,236(s0)

        // 初始化进程关系指针为NULL
        proc->cptr = NULL;
ffffffffc0204b30:	0e043823          	sd	zero,240(s0)
        proc->yptr = NULL;
ffffffffc0204b34:	0e043c23          	sd	zero,248(s0)
        proc->optr = NULL;
ffffffffc0204b38:	10043023          	sd	zero,256(s0)
    }
    return proc;
}
ffffffffc0204b3c:	60a2                	ld	ra,8(sp)
ffffffffc0204b3e:	8522                	mv	a0,s0
ffffffffc0204b40:	6402                	ld	s0,0(sp)
ffffffffc0204b42:	0141                	addi	sp,sp,16
ffffffffc0204b44:	8082                	ret

ffffffffc0204b46 <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc0204b46:	000ae797          	auipc	a5,0xae
ffffffffc0204b4a:	c8a7b783          	ld	a5,-886(a5) # ffffffffc02b27d0 <current>
ffffffffc0204b4e:	73c8                	ld	a0,160(a5)
ffffffffc0204b50:	a02fc06f          	j	ffffffffc0200d52 <forkrets>

ffffffffc0204b54 <user_main>:

// user_main - kernel thread used to exec a user program
static int
user_main(void *arg) {
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204b54:	000ae797          	auipc	a5,0xae
ffffffffc0204b58:	c7c7b783          	ld	a5,-900(a5) # ffffffffc02b27d0 <current>
ffffffffc0204b5c:	43cc                	lw	a1,4(a5)
user_main(void *arg) {
ffffffffc0204b5e:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204b60:	00003617          	auipc	a2,0x3
ffffffffc0204b64:	5e060613          	addi	a2,a2,1504 # ffffffffc0208140 <default_pmm_manager+0x1008>
ffffffffc0204b68:	00003517          	auipc	a0,0x3
ffffffffc0204b6c:	5e850513          	addi	a0,a0,1512 # ffffffffc0208150 <default_pmm_manager+0x1018>
user_main(void *arg) {
ffffffffc0204b70:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204b72:	e0efb0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0204b76:	3fe06797          	auipc	a5,0x3fe06
ffffffffc0204b7a:	dea78793          	addi	a5,a5,-534 # a960 <_binary_obj___user_forktest_out_size>
ffffffffc0204b7e:	e43e                	sd	a5,8(sp)
ffffffffc0204b80:	00003517          	auipc	a0,0x3
ffffffffc0204b84:	5c050513          	addi	a0,a0,1472 # ffffffffc0208140 <default_pmm_manager+0x1008>
ffffffffc0204b88:	00046797          	auipc	a5,0x46
ffffffffc0204b8c:	b5078793          	addi	a5,a5,-1200 # ffffffffc024a6d8 <_binary_obj___user_forktest_out_start>
ffffffffc0204b90:	f03e                	sd	a5,32(sp)
ffffffffc0204b92:	f42a                	sd	a0,40(sp)
    int64_t ret=0, len = strlen(name);
ffffffffc0204b94:	e802                	sd	zero,16(sp)
ffffffffc0204b96:	7a6010ef          	jal	ra,ffffffffc020633c <strlen>
ffffffffc0204b9a:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc0204b9c:	4511                	li	a0,4
ffffffffc0204b9e:	55a2                	lw	a1,40(sp)
ffffffffc0204ba0:	4662                	lw	a2,24(sp)
ffffffffc0204ba2:	5682                	lw	a3,32(sp)
ffffffffc0204ba4:	4722                	lw	a4,8(sp)
ffffffffc0204ba6:	48a9                	li	a7,10
ffffffffc0204ba8:	9002                	ebreak
ffffffffc0204baa:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc0204bac:	65c2                	ld	a1,16(sp)
ffffffffc0204bae:	00003517          	auipc	a0,0x3
ffffffffc0204bb2:	5ca50513          	addi	a0,a0,1482 # ffffffffc0208178 <default_pmm_manager+0x1040>
ffffffffc0204bb6:	dcafb0ef          	jal	ra,ffffffffc0200180 <cprintf>
#else
    KERNEL_EXECVE(exit);
#endif
    panic("user_main execve failed.\n");
ffffffffc0204bba:	00003617          	auipc	a2,0x3
ffffffffc0204bbe:	5ce60613          	addi	a2,a2,1486 # ffffffffc0208188 <default_pmm_manager+0x1050>
ffffffffc0204bc2:	38a00593          	li	a1,906
ffffffffc0204bc6:	00003517          	auipc	a0,0x3
ffffffffc0204bca:	5e250513          	addi	a0,a0,1506 # ffffffffc02081a8 <default_pmm_manager+0x1070>
ffffffffc0204bce:	8adfb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0204bd2 <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0204bd2:	6d14                	ld	a3,24(a0)
put_pgdir(struct mm_struct *mm) {
ffffffffc0204bd4:	1141                	addi	sp,sp,-16
ffffffffc0204bd6:	e406                	sd	ra,8(sp)
ffffffffc0204bd8:	c02007b7          	lui	a5,0xc0200
ffffffffc0204bdc:	02f6ee63          	bltu	a3,a5,ffffffffc0204c18 <put_pgdir+0x46>
ffffffffc0204be0:	000ae517          	auipc	a0,0xae
ffffffffc0204be4:	bc053503          	ld	a0,-1088(a0) # ffffffffc02b27a0 <va_pa_offset>
ffffffffc0204be8:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage) {
ffffffffc0204bea:	82b1                	srli	a3,a3,0xc
ffffffffc0204bec:	000ae797          	auipc	a5,0xae
ffffffffc0204bf0:	b9c7b783          	ld	a5,-1124(a5) # ffffffffc02b2788 <npage>
ffffffffc0204bf4:	02f6fe63          	bgeu	a3,a5,ffffffffc0204c30 <put_pgdir+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc0204bf8:	00004517          	auipc	a0,0x4
ffffffffc0204bfc:	e6053503          	ld	a0,-416(a0) # ffffffffc0208a58 <nbase>
}
ffffffffc0204c00:	60a2                	ld	ra,8(sp)
ffffffffc0204c02:	8e89                	sub	a3,a3,a0
ffffffffc0204c04:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0204c06:	000ae517          	auipc	a0,0xae
ffffffffc0204c0a:	b8a53503          	ld	a0,-1142(a0) # ffffffffc02b2790 <pages>
ffffffffc0204c0e:	4585                	li	a1,1
ffffffffc0204c10:	9536                	add	a0,a0,a3
}
ffffffffc0204c12:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc0204c14:	93afd06f          	j	ffffffffc0201d4e <free_pages>
    return pa2page(PADDR(kva));
ffffffffc0204c18:	00002617          	auipc	a2,0x2
ffffffffc0204c1c:	60060613          	addi	a2,a2,1536 # ffffffffc0207218 <default_pmm_manager+0xe0>
ffffffffc0204c20:	06e00593          	li	a1,110
ffffffffc0204c24:	00002517          	auipc	a0,0x2
ffffffffc0204c28:	57450513          	addi	a0,a0,1396 # ffffffffc0207198 <default_pmm_manager+0x60>
ffffffffc0204c2c:	84ffb0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204c30:	00002617          	auipc	a2,0x2
ffffffffc0204c34:	61060613          	addi	a2,a2,1552 # ffffffffc0207240 <default_pmm_manager+0x108>
ffffffffc0204c38:	06200593          	li	a1,98
ffffffffc0204c3c:	00002517          	auipc	a0,0x2
ffffffffc0204c40:	55c50513          	addi	a0,a0,1372 # ffffffffc0207198 <default_pmm_manager+0x60>
ffffffffc0204c44:	837fb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0204c48 <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc0204c48:	7179                	addi	sp,sp,-48
ffffffffc0204c4a:	ec4a                	sd	s2,24(sp)
    if (proc != current) {
ffffffffc0204c4c:	000ae917          	auipc	s2,0xae
ffffffffc0204c50:	b8490913          	addi	s2,s2,-1148 # ffffffffc02b27d0 <current>
proc_run(struct proc_struct *proc) {
ffffffffc0204c54:	f026                	sd	s1,32(sp)
    if (proc != current) {
ffffffffc0204c56:	00093483          	ld	s1,0(s2)
proc_run(struct proc_struct *proc) {
ffffffffc0204c5a:	f406                	sd	ra,40(sp)
ffffffffc0204c5c:	e84e                	sd	s3,16(sp)
    if (proc != current) {
ffffffffc0204c5e:	02a48863          	beq	s1,a0,ffffffffc0204c8e <proc_run+0x46>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204c62:	100027f3          	csrr	a5,sstatus
ffffffffc0204c66:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204c68:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204c6a:	ef9d                	bnez	a5,ffffffffc0204ca8 <proc_run+0x60>

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned long cr3) {
    write_csr(satp, 0x8000000000000000 | (cr3 >> RISCV_PGSHIFT));
ffffffffc0204c6c:	755c                	ld	a5,168(a0)
ffffffffc0204c6e:	577d                	li	a4,-1
ffffffffc0204c70:	177e                	slli	a4,a4,0x3f
ffffffffc0204c72:	83b1                	srli	a5,a5,0xc
            current=proc;
ffffffffc0204c74:	00a93023          	sd	a0,0(s2)
ffffffffc0204c78:	8fd9                	or	a5,a5,a4
ffffffffc0204c7a:	18079073          	csrw	satp,a5
            switch_to(&(pre->context),&(proc->context));
ffffffffc0204c7e:	03050593          	addi	a1,a0,48
ffffffffc0204c82:	03048513          	addi	a0,s1,48
ffffffffc0204c86:	05c010ef          	jal	ra,ffffffffc0205ce2 <switch_to>
    if (flag) {
ffffffffc0204c8a:	00099863          	bnez	s3,ffffffffc0204c9a <proc_run+0x52>
}
ffffffffc0204c8e:	70a2                	ld	ra,40(sp)
ffffffffc0204c90:	7482                	ld	s1,32(sp)
ffffffffc0204c92:	6962                	ld	s2,24(sp)
ffffffffc0204c94:	69c2                	ld	s3,16(sp)
ffffffffc0204c96:	6145                	addi	sp,sp,48
ffffffffc0204c98:	8082                	ret
ffffffffc0204c9a:	70a2                	ld	ra,40(sp)
ffffffffc0204c9c:	7482                	ld	s1,32(sp)
ffffffffc0204c9e:	6962                	ld	s2,24(sp)
ffffffffc0204ca0:	69c2                	ld	s3,16(sp)
ffffffffc0204ca2:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc0204ca4:	979fb06f          	j	ffffffffc020061c <intr_enable>
ffffffffc0204ca8:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0204caa:	979fb0ef          	jal	ra,ffffffffc0200622 <intr_disable>
        return 1;
ffffffffc0204cae:	6522                	ld	a0,8(sp)
ffffffffc0204cb0:	4985                	li	s3,1
ffffffffc0204cb2:	bf6d                	j	ffffffffc0204c6c <proc_run+0x24>

ffffffffc0204cb4 <do_fork>:
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204cb4:	7159                	addi	sp,sp,-112
ffffffffc0204cb6:	e8ca                	sd	s2,80(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204cb8:	000ae917          	auipc	s2,0xae
ffffffffc0204cbc:	b3090913          	addi	s2,s2,-1232 # ffffffffc02b27e8 <nr_process>
ffffffffc0204cc0:	00092703          	lw	a4,0(s2)
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204cc4:	f486                	sd	ra,104(sp)
ffffffffc0204cc6:	f0a2                	sd	s0,96(sp)
ffffffffc0204cc8:	eca6                	sd	s1,88(sp)
ffffffffc0204cca:	e4ce                	sd	s3,72(sp)
ffffffffc0204ccc:	e0d2                	sd	s4,64(sp)
ffffffffc0204cce:	fc56                	sd	s5,56(sp)
ffffffffc0204cd0:	f85a                	sd	s6,48(sp)
ffffffffc0204cd2:	f45e                	sd	s7,40(sp)
ffffffffc0204cd4:	f062                	sd	s8,32(sp)
ffffffffc0204cd6:	ec66                	sd	s9,24(sp)
ffffffffc0204cd8:	e86a                	sd	s10,16(sp)
ffffffffc0204cda:	e46e                	sd	s11,8(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204cdc:	6785                	lui	a5,0x1
ffffffffc0204cde:	34f75063          	bge	a4,a5,ffffffffc020501e <do_fork+0x36a>
ffffffffc0204ce2:	8a2a                	mv	s4,a0
ffffffffc0204ce4:	89ae                	mv	s3,a1
ffffffffc0204ce6:	8432                	mv	s0,a2
    if ((proc = alloc_proc()) == NULL) {
ffffffffc0204ce8:	dedff0ef          	jal	ra,ffffffffc0204ad4 <alloc_proc>
ffffffffc0204cec:	84aa                	mv	s1,a0
ffffffffc0204cee:	2c050863          	beqz	a0,ffffffffc0204fbe <do_fork+0x30a>
    proc->parent = current;
ffffffffc0204cf2:	000aea97          	auipc	s5,0xae
ffffffffc0204cf6:	adea8a93          	addi	s5,s5,-1314 # ffffffffc02b27d0 <current>
ffffffffc0204cfa:	000ab783          	ld	a5,0(s5)
    assert(current->wait_state==0);
ffffffffc0204cfe:	0ec7a703          	lw	a4,236(a5) # 10ec <_binary_obj___user_faultread_out_size-0x8abc>
    proc->parent = current;
ffffffffc0204d02:	f11c                	sd	a5,32(a0)
    assert(current->wait_state==0);
ffffffffc0204d04:	38071363          	bnez	a4,ffffffffc020508a <do_fork+0x3d6>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0204d08:	4509                	li	a0,2
ffffffffc0204d0a:	fb3fc0ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
    if (page != NULL) {
ffffffffc0204d0e:	2c050763          	beqz	a0,ffffffffc0204fdc <do_fork+0x328>
    return page - pages + nbase;
ffffffffc0204d12:	000aed97          	auipc	s11,0xae
ffffffffc0204d16:	a7ed8d93          	addi	s11,s11,-1410 # ffffffffc02b2790 <pages>
ffffffffc0204d1a:	000db683          	ld	a3,0(s11)
    return KADDR(page2pa(page));
ffffffffc0204d1e:	000aed17          	auipc	s10,0xae
ffffffffc0204d22:	a6ad0d13          	addi	s10,s10,-1430 # ffffffffc02b2788 <npage>
    return page - pages + nbase;
ffffffffc0204d26:	00004c97          	auipc	s9,0x4
ffffffffc0204d2a:	d32cbc83          	ld	s9,-718(s9) # ffffffffc0208a58 <nbase>
ffffffffc0204d2e:	40d506b3          	sub	a3,a0,a3
ffffffffc0204d32:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204d34:	5c7d                	li	s8,-1
ffffffffc0204d36:	000d3783          	ld	a5,0(s10)
    return page - pages + nbase;
ffffffffc0204d3a:	96e6                	add	a3,a3,s9
    return KADDR(page2pa(page));
ffffffffc0204d3c:	00cc5c13          	srli	s8,s8,0xc
ffffffffc0204d40:	0186f733          	and	a4,a3,s8
    return page2ppn(page) << PGSHIFT;
ffffffffc0204d44:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204d46:	30f77963          	bgeu	a4,a5,ffffffffc0205058 <do_fork+0x3a4>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc0204d4a:	000ab703          	ld	a4,0(s5)
ffffffffc0204d4e:	000aea97          	auipc	s5,0xae
ffffffffc0204d52:	a52a8a93          	addi	s5,s5,-1454 # ffffffffc02b27a0 <va_pa_offset>
ffffffffc0204d56:	000ab783          	ld	a5,0(s5)
ffffffffc0204d5a:	02873b83          	ld	s7,40(a4)
ffffffffc0204d5e:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0204d60:	e894                	sd	a3,16(s1)
    if (oldmm == NULL) {
ffffffffc0204d62:	020b8863          	beqz	s7,ffffffffc0204d92 <do_fork+0xde>
    if (clone_flags & CLONE_VM) {
ffffffffc0204d66:	100a7a13          	andi	s4,s4,256
ffffffffc0204d6a:	1c0a0163          	beqz	s4,ffffffffc0204f2c <do_fork+0x278>
}

static inline int
mm_count_inc(struct mm_struct *mm) {
    mm->mm_count += 1;
ffffffffc0204d6e:	030ba703          	lw	a4,48(s7)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0204d72:	018bb783          	ld	a5,24(s7)
ffffffffc0204d76:	c02006b7          	lui	a3,0xc0200
ffffffffc0204d7a:	2705                	addiw	a4,a4,1
ffffffffc0204d7c:	02eba823          	sw	a4,48(s7)
    proc->mm = mm;
ffffffffc0204d80:	0374b423          	sd	s7,40(s1)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0204d84:	2ed7e663          	bltu	a5,a3,ffffffffc0205070 <do_fork+0x3bc>
ffffffffc0204d88:	000ab703          	ld	a4,0(s5)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204d8c:	6894                	ld	a3,16(s1)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0204d8e:	8f99                	sub	a5,a5,a4
ffffffffc0204d90:	f4dc                	sd	a5,168(s1)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204d92:	6789                	lui	a5,0x2
ffffffffc0204d94:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7cc8>
ffffffffc0204d98:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc0204d9a:	8622                	mv	a2,s0
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204d9c:	f0d4                	sd	a3,160(s1)
    *(proc->tf) = *tf;
ffffffffc0204d9e:	87b6                	mv	a5,a3
ffffffffc0204da0:	12040893          	addi	a7,s0,288
ffffffffc0204da4:	00063803          	ld	a6,0(a2)
ffffffffc0204da8:	6608                	ld	a0,8(a2)
ffffffffc0204daa:	6a0c                	ld	a1,16(a2)
ffffffffc0204dac:	6e18                	ld	a4,24(a2)
ffffffffc0204dae:	0107b023          	sd	a6,0(a5)
ffffffffc0204db2:	e788                	sd	a0,8(a5)
ffffffffc0204db4:	eb8c                	sd	a1,16(a5)
ffffffffc0204db6:	ef98                	sd	a4,24(a5)
ffffffffc0204db8:	02060613          	addi	a2,a2,32
ffffffffc0204dbc:	02078793          	addi	a5,a5,32
ffffffffc0204dc0:	ff1612e3          	bne	a2,a7,ffffffffc0204da4 <do_fork+0xf0>
    proc->tf->gpr.a0 = 0;
ffffffffc0204dc4:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x1e>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0204dc8:	12098f63          	beqz	s3,ffffffffc0204f06 <do_fork+0x252>
ffffffffc0204dcc:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0204dd0:	00000797          	auipc	a5,0x0
ffffffffc0204dd4:	d7678793          	addi	a5,a5,-650 # ffffffffc0204b46 <forkret>
ffffffffc0204dd8:	f89c                	sd	a5,48(s1)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0204dda:	fc94                	sd	a3,56(s1)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204ddc:	100027f3          	csrr	a5,sstatus
ffffffffc0204de0:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204de2:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204de4:	14079063          	bnez	a5,ffffffffc0204f24 <do_fork+0x270>
    if (++ last_pid >= MAX_PID) {
ffffffffc0204de8:	000a2817          	auipc	a6,0xa2
ffffffffc0204dec:	4a080813          	addi	a6,a6,1184 # ffffffffc02a7288 <last_pid.1>
ffffffffc0204df0:	00082783          	lw	a5,0(a6)
ffffffffc0204df4:	6709                	lui	a4,0x2
ffffffffc0204df6:	0017851b          	addiw	a0,a5,1
ffffffffc0204dfa:	00a82023          	sw	a0,0(a6)
ffffffffc0204dfe:	08e55d63          	bge	a0,a4,ffffffffc0204e98 <do_fork+0x1e4>
    if (last_pid >= next_safe) {
ffffffffc0204e02:	000a2317          	auipc	t1,0xa2
ffffffffc0204e06:	48a30313          	addi	t1,t1,1162 # ffffffffc02a728c <next_safe.0>
ffffffffc0204e0a:	00032783          	lw	a5,0(t1)
ffffffffc0204e0e:	000ae417          	auipc	s0,0xae
ffffffffc0204e12:	93a40413          	addi	s0,s0,-1734 # ffffffffc02b2748 <proc_list>
ffffffffc0204e16:	08f55963          	bge	a0,a5,ffffffffc0204ea8 <do_fork+0x1f4>
        proc->pid=get_pid();
ffffffffc0204e1a:	c0c8                	sw	a0,4(s1)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0204e1c:	45a9                	li	a1,10
ffffffffc0204e1e:	2501                	sext.w	a0,a0
ffffffffc0204e20:	118010ef          	jal	ra,ffffffffc0205f38 <hash32>
ffffffffc0204e24:	02051793          	slli	a5,a0,0x20
ffffffffc0204e28:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0204e2c:	000aa797          	auipc	a5,0xaa
ffffffffc0204e30:	91c78793          	addi	a5,a5,-1764 # ffffffffc02ae748 <hash_list>
ffffffffc0204e34:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc0204e36:	650c                	ld	a1,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0204e38:	7094                	ld	a3,32(s1)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0204e3a:	0d848793          	addi	a5,s1,216
    prev->next = next->prev = elm;
ffffffffc0204e3e:	e19c                	sd	a5,0(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0204e40:	6410                	ld	a2,8(s0)
    prev->next = next->prev = elm;
ffffffffc0204e42:	e51c                	sd	a5,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0204e44:	7af8                	ld	a4,240(a3)
    list_add(&proc_list, &(proc->list_link));
ffffffffc0204e46:	0c848793          	addi	a5,s1,200
    elm->next = next;
ffffffffc0204e4a:	f0ec                	sd	a1,224(s1)
    elm->prev = prev;
ffffffffc0204e4c:	ece8                	sd	a0,216(s1)
    prev->next = next->prev = elm;
ffffffffc0204e4e:	e21c                	sd	a5,0(a2)
ffffffffc0204e50:	e41c                	sd	a5,8(s0)
    elm->next = next;
ffffffffc0204e52:	e8f0                	sd	a2,208(s1)
    elm->prev = prev;
ffffffffc0204e54:	e4e0                	sd	s0,200(s1)
    proc->yptr = NULL;
ffffffffc0204e56:	0e04bc23          	sd	zero,248(s1)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0204e5a:	10e4b023          	sd	a4,256(s1)
ffffffffc0204e5e:	c311                	beqz	a4,ffffffffc0204e62 <do_fork+0x1ae>
        proc->optr->yptr = proc;
ffffffffc0204e60:	ff64                	sd	s1,248(a4)
    nr_process ++;
ffffffffc0204e62:	00092783          	lw	a5,0(s2)
    proc->parent->cptr = proc;
ffffffffc0204e66:	fae4                	sd	s1,240(a3)
    nr_process ++;
ffffffffc0204e68:	2785                	addiw	a5,a5,1
ffffffffc0204e6a:	00f92023          	sw	a5,0(s2)
    if (flag) {
ffffffffc0204e6e:	14099a63          	bnez	s3,ffffffffc0204fc2 <do_fork+0x30e>
    wakeup_proc(proc);
ffffffffc0204e72:	8526                	mv	a0,s1
ffffffffc0204e74:	6d9000ef          	jal	ra,ffffffffc0205d4c <wakeup_proc>
    ret = proc->pid;
ffffffffc0204e78:	40c8                	lw	a0,4(s1)
}
ffffffffc0204e7a:	70a6                	ld	ra,104(sp)
ffffffffc0204e7c:	7406                	ld	s0,96(sp)
ffffffffc0204e7e:	64e6                	ld	s1,88(sp)
ffffffffc0204e80:	6946                	ld	s2,80(sp)
ffffffffc0204e82:	69a6                	ld	s3,72(sp)
ffffffffc0204e84:	6a06                	ld	s4,64(sp)
ffffffffc0204e86:	7ae2                	ld	s5,56(sp)
ffffffffc0204e88:	7b42                	ld	s6,48(sp)
ffffffffc0204e8a:	7ba2                	ld	s7,40(sp)
ffffffffc0204e8c:	7c02                	ld	s8,32(sp)
ffffffffc0204e8e:	6ce2                	ld	s9,24(sp)
ffffffffc0204e90:	6d42                	ld	s10,16(sp)
ffffffffc0204e92:	6da2                	ld	s11,8(sp)
ffffffffc0204e94:	6165                	addi	sp,sp,112
ffffffffc0204e96:	8082                	ret
        last_pid = 1;
ffffffffc0204e98:	4785                	li	a5,1
ffffffffc0204e9a:	00f82023          	sw	a5,0(a6)
        goto inside;
ffffffffc0204e9e:	4505                	li	a0,1
ffffffffc0204ea0:	000a2317          	auipc	t1,0xa2
ffffffffc0204ea4:	3ec30313          	addi	t1,t1,1004 # ffffffffc02a728c <next_safe.0>
    return listelm->next;
ffffffffc0204ea8:	000ae417          	auipc	s0,0xae
ffffffffc0204eac:	8a040413          	addi	s0,s0,-1888 # ffffffffc02b2748 <proc_list>
ffffffffc0204eb0:	00843e03          	ld	t3,8(s0)
        next_safe = MAX_PID;
ffffffffc0204eb4:	6789                	lui	a5,0x2
ffffffffc0204eb6:	00f32023          	sw	a5,0(t1)
ffffffffc0204eba:	86aa                	mv	a3,a0
ffffffffc0204ebc:	4581                	li	a1,0
        while ((le = list_next(le)) != list) {
ffffffffc0204ebe:	6e89                	lui	t4,0x2
ffffffffc0204ec0:	108e0963          	beq	t3,s0,ffffffffc0204fd2 <do_fork+0x31e>
ffffffffc0204ec4:	88ae                	mv	a7,a1
ffffffffc0204ec6:	87f2                	mv	a5,t3
ffffffffc0204ec8:	6609                	lui	a2,0x2
ffffffffc0204eca:	a811                	j	ffffffffc0204ede <do_fork+0x22a>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc0204ecc:	00e6d663          	bge	a3,a4,ffffffffc0204ed8 <do_fork+0x224>
ffffffffc0204ed0:	00c75463          	bge	a4,a2,ffffffffc0204ed8 <do_fork+0x224>
ffffffffc0204ed4:	863a                	mv	a2,a4
ffffffffc0204ed6:	4885                	li	a7,1
ffffffffc0204ed8:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0204eda:	00878d63          	beq	a5,s0,ffffffffc0204ef4 <do_fork+0x240>
            if (proc->pid == last_pid) {
ffffffffc0204ede:	f3c7a703          	lw	a4,-196(a5) # 1f3c <_binary_obj___user_faultread_out_size-0x7c6c>
ffffffffc0204ee2:	fed715e3          	bne	a4,a3,ffffffffc0204ecc <do_fork+0x218>
                if (++ last_pid >= next_safe) {
ffffffffc0204ee6:	2685                	addiw	a3,a3,1
ffffffffc0204ee8:	0ec6d063          	bge	a3,a2,ffffffffc0204fc8 <do_fork+0x314>
ffffffffc0204eec:	679c                	ld	a5,8(a5)
ffffffffc0204eee:	4585                	li	a1,1
        while ((le = list_next(le)) != list) {
ffffffffc0204ef0:	fe8797e3          	bne	a5,s0,ffffffffc0204ede <do_fork+0x22a>
ffffffffc0204ef4:	c581                	beqz	a1,ffffffffc0204efc <do_fork+0x248>
ffffffffc0204ef6:	00d82023          	sw	a3,0(a6)
ffffffffc0204efa:	8536                	mv	a0,a3
ffffffffc0204efc:	f0088fe3          	beqz	a7,ffffffffc0204e1a <do_fork+0x166>
ffffffffc0204f00:	00c32023          	sw	a2,0(t1)
ffffffffc0204f04:	bf19                	j	ffffffffc0204e1a <do_fork+0x166>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0204f06:	89b6                	mv	s3,a3
ffffffffc0204f08:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0204f0c:	00000797          	auipc	a5,0x0
ffffffffc0204f10:	c3a78793          	addi	a5,a5,-966 # ffffffffc0204b46 <forkret>
ffffffffc0204f14:	f89c                	sd	a5,48(s1)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0204f16:	fc94                	sd	a3,56(s1)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204f18:	100027f3          	csrr	a5,sstatus
ffffffffc0204f1c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204f1e:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204f20:	ec0784e3          	beqz	a5,ffffffffc0204de8 <do_fork+0x134>
        intr_disable();
ffffffffc0204f24:	efefb0ef          	jal	ra,ffffffffc0200622 <intr_disable>
        return 1;
ffffffffc0204f28:	4985                	li	s3,1
ffffffffc0204f2a:	bd7d                	j	ffffffffc0204de8 <do_fork+0x134>
    if ((mm = mm_create()) == NULL) {
ffffffffc0204f2c:	8b2ff0ef          	jal	ra,ffffffffc0203fde <mm_create>
ffffffffc0204f30:	8b2a                	mv	s6,a0
ffffffffc0204f32:	c159                	beqz	a0,ffffffffc0204fb8 <do_fork+0x304>
    if ((page = alloc_page()) == NULL) {
ffffffffc0204f34:	4505                	li	a0,1
ffffffffc0204f36:	d87fc0ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
ffffffffc0204f3a:	cd25                	beqz	a0,ffffffffc0204fb2 <do_fork+0x2fe>
    return page - pages + nbase;
ffffffffc0204f3c:	000db683          	ld	a3,0(s11)
    return KADDR(page2pa(page));
ffffffffc0204f40:	000d3783          	ld	a5,0(s10)
    return page - pages + nbase;
ffffffffc0204f44:	40d506b3          	sub	a3,a0,a3
ffffffffc0204f48:	8699                	srai	a3,a3,0x6
ffffffffc0204f4a:	96e6                	add	a3,a3,s9
    return KADDR(page2pa(page));
ffffffffc0204f4c:	0186fc33          	and	s8,a3,s8
    return page2ppn(page) << PGSHIFT;
ffffffffc0204f50:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204f52:	10fc7363          	bgeu	s8,a5,ffffffffc0205058 <do_fork+0x3a4>
ffffffffc0204f56:	000aba03          	ld	s4,0(s5)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc0204f5a:	6605                	lui	a2,0x1
ffffffffc0204f5c:	000ae597          	auipc	a1,0xae
ffffffffc0204f60:	8245b583          	ld	a1,-2012(a1) # ffffffffc02b2780 <boot_pgdir>
ffffffffc0204f64:	9a36                	add	s4,s4,a3
ffffffffc0204f66:	8552                	mv	a0,s4
ffffffffc0204f68:	462010ef          	jal	ra,ffffffffc02063ca <memcpy>
}

static inline void
lock_mm(struct mm_struct *mm) {
    if (mm != NULL) {
        lock(&(mm->mm_lock));
ffffffffc0204f6c:	038b8c13          	addi	s8,s7,56
    mm->pgdir = pgdir;
ffffffffc0204f70:	014b3c23          	sd	s4,24(s6)
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0204f74:	4785                	li	a5,1
ffffffffc0204f76:	40fc37af          	amoor.d	a5,a5,(s8)
    return !test_and_set_bit(0, lock);
}

static inline void
lock(lock_t *lock) {
    while (!try_lock(lock)) {
ffffffffc0204f7a:	8b85                	andi	a5,a5,1
ffffffffc0204f7c:	4a05                	li	s4,1
ffffffffc0204f7e:	c799                	beqz	a5,ffffffffc0204f8c <do_fork+0x2d8>
        schedule();
ffffffffc0204f80:	64d000ef          	jal	ra,ffffffffc0205dcc <schedule>
ffffffffc0204f84:	414c37af          	amoor.d	a5,s4,(s8)
    while (!try_lock(lock)) {
ffffffffc0204f88:	8b85                	andi	a5,a5,1
ffffffffc0204f8a:	fbfd                	bnez	a5,ffffffffc0204f80 <do_fork+0x2cc>
        ret = dup_mmap(mm, oldmm);
ffffffffc0204f8c:	85de                	mv	a1,s7
ffffffffc0204f8e:	855a                	mv	a0,s6
ffffffffc0204f90:	ad6ff0ef          	jal	ra,ffffffffc0204266 <dup_mmap>
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0204f94:	57f9                	li	a5,-2
ffffffffc0204f96:	60fc37af          	amoand.d	a5,a5,(s8)
ffffffffc0204f9a:	8b85                	andi	a5,a5,1
    }
}

static inline void
unlock(lock_t *lock) {
    if (!test_and_clear_bit(0, lock)) {
ffffffffc0204f9c:	10078763          	beqz	a5,ffffffffc02050aa <do_fork+0x3f6>
good_mm:
ffffffffc0204fa0:	8bda                	mv	s7,s6
    if (ret != 0) {
ffffffffc0204fa2:	dc0506e3          	beqz	a0,ffffffffc0204d6e <do_fork+0xba>
    exit_mmap(mm);
ffffffffc0204fa6:	855a                	mv	a0,s6
ffffffffc0204fa8:	b58ff0ef          	jal	ra,ffffffffc0204300 <exit_mmap>
    put_pgdir(mm);
ffffffffc0204fac:	855a                	mv	a0,s6
ffffffffc0204fae:	c25ff0ef          	jal	ra,ffffffffc0204bd2 <put_pgdir>
    mm_destroy(mm);
ffffffffc0204fb2:	855a                	mv	a0,s6
ffffffffc0204fb4:	9b0ff0ef          	jal	ra,ffffffffc0204164 <mm_destroy>
    kfree(proc);
ffffffffc0204fb8:	8526                	mv	a0,s1
ffffffffc0204fba:	bd5fc0ef          	jal	ra,ffffffffc0201b8e <kfree>
    ret = -E_NO_MEM;
ffffffffc0204fbe:	5571                	li	a0,-4
    return ret;
ffffffffc0204fc0:	bd6d                	j	ffffffffc0204e7a <do_fork+0x1c6>
        intr_enable();
ffffffffc0204fc2:	e5afb0ef          	jal	ra,ffffffffc020061c <intr_enable>
ffffffffc0204fc6:	b575                	j	ffffffffc0204e72 <do_fork+0x1be>
                    if (last_pid >= MAX_PID) {
ffffffffc0204fc8:	01d6c363          	blt	a3,t4,ffffffffc0204fce <do_fork+0x31a>
                        last_pid = 1;
ffffffffc0204fcc:	4685                	li	a3,1
                    goto repeat;
ffffffffc0204fce:	4585                	li	a1,1
ffffffffc0204fd0:	bdc5                	j	ffffffffc0204ec0 <do_fork+0x20c>
ffffffffc0204fd2:	c9a1                	beqz	a1,ffffffffc0205022 <do_fork+0x36e>
ffffffffc0204fd4:	00d82023          	sw	a3,0(a6)
    return last_pid;
ffffffffc0204fd8:	8536                	mv	a0,a3
ffffffffc0204fda:	b581                	j	ffffffffc0204e1a <do_fork+0x166>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0204fdc:	6894                	ld	a3,16(s1)
    return pa2page(PADDR(kva));
ffffffffc0204fde:	c02007b7          	lui	a5,0xc0200
ffffffffc0204fe2:	04f6ef63          	bltu	a3,a5,ffffffffc0205040 <do_fork+0x38c>
ffffffffc0204fe6:	000ad797          	auipc	a5,0xad
ffffffffc0204fea:	7ba7b783          	ld	a5,1978(a5) # ffffffffc02b27a0 <va_pa_offset>
ffffffffc0204fee:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc0204ff2:	83b1                	srli	a5,a5,0xc
ffffffffc0204ff4:	000ad717          	auipc	a4,0xad
ffffffffc0204ff8:	79473703          	ld	a4,1940(a4) # ffffffffc02b2788 <npage>
ffffffffc0204ffc:	02e7f663          	bgeu	a5,a4,ffffffffc0205028 <do_fork+0x374>
    return &pages[PPN(pa) - nbase];
ffffffffc0205000:	00004717          	auipc	a4,0x4
ffffffffc0205004:	a5873703          	ld	a4,-1448(a4) # ffffffffc0208a58 <nbase>
ffffffffc0205008:	8f99                	sub	a5,a5,a4
ffffffffc020500a:	079a                	slli	a5,a5,0x6
ffffffffc020500c:	000ad517          	auipc	a0,0xad
ffffffffc0205010:	78453503          	ld	a0,1924(a0) # ffffffffc02b2790 <pages>
ffffffffc0205014:	4589                	li	a1,2
ffffffffc0205016:	953e                	add	a0,a0,a5
ffffffffc0205018:	d37fc0ef          	jal	ra,ffffffffc0201d4e <free_pages>
}
ffffffffc020501c:	bf71                	j	ffffffffc0204fb8 <do_fork+0x304>
    int ret = -E_NO_FREE_PROC;
ffffffffc020501e:	556d                	li	a0,-5
ffffffffc0205020:	bda9                	j	ffffffffc0204e7a <do_fork+0x1c6>
    return last_pid;
ffffffffc0205022:	00082503          	lw	a0,0(a6)
ffffffffc0205026:	bbd5                	j	ffffffffc0204e1a <do_fork+0x166>
        panic("pa2page called with invalid pa");
ffffffffc0205028:	00002617          	auipc	a2,0x2
ffffffffc020502c:	21860613          	addi	a2,a2,536 # ffffffffc0207240 <default_pmm_manager+0x108>
ffffffffc0205030:	06200593          	li	a1,98
ffffffffc0205034:	00002517          	auipc	a0,0x2
ffffffffc0205038:	16450513          	addi	a0,a0,356 # ffffffffc0207198 <default_pmm_manager+0x60>
ffffffffc020503c:	c3efb0ef          	jal	ra,ffffffffc020047a <__panic>
    return pa2page(PADDR(kva));
ffffffffc0205040:	00002617          	auipc	a2,0x2
ffffffffc0205044:	1d860613          	addi	a2,a2,472 # ffffffffc0207218 <default_pmm_manager+0xe0>
ffffffffc0205048:	06e00593          	li	a1,110
ffffffffc020504c:	00002517          	auipc	a0,0x2
ffffffffc0205050:	14c50513          	addi	a0,a0,332 # ffffffffc0207198 <default_pmm_manager+0x60>
ffffffffc0205054:	c26fb0ef          	jal	ra,ffffffffc020047a <__panic>
    return KADDR(page2pa(page));
ffffffffc0205058:	00002617          	auipc	a2,0x2
ffffffffc020505c:	11860613          	addi	a2,a2,280 # ffffffffc0207170 <default_pmm_manager+0x38>
ffffffffc0205060:	06900593          	li	a1,105
ffffffffc0205064:	00002517          	auipc	a0,0x2
ffffffffc0205068:	13450513          	addi	a0,a0,308 # ffffffffc0207198 <default_pmm_manager+0x60>
ffffffffc020506c:	c0efb0ef          	jal	ra,ffffffffc020047a <__panic>
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0205070:	86be                	mv	a3,a5
ffffffffc0205072:	00002617          	auipc	a2,0x2
ffffffffc0205076:	1a660613          	addi	a2,a2,422 # ffffffffc0207218 <default_pmm_manager+0xe0>
ffffffffc020507a:	18700593          	li	a1,391
ffffffffc020507e:	00003517          	auipc	a0,0x3
ffffffffc0205082:	12a50513          	addi	a0,a0,298 # ffffffffc02081a8 <default_pmm_manager+0x1070>
ffffffffc0205086:	bf4fb0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(current->wait_state==0);
ffffffffc020508a:	00003697          	auipc	a3,0x3
ffffffffc020508e:	13668693          	addi	a3,a3,310 # ffffffffc02081c0 <default_pmm_manager+0x1088>
ffffffffc0205092:	00002617          	auipc	a2,0x2
ffffffffc0205096:	a0e60613          	addi	a2,a2,-1522 # ffffffffc0206aa0 <commands+0x450>
ffffffffc020509a:	1d900593          	li	a1,473
ffffffffc020509e:	00003517          	auipc	a0,0x3
ffffffffc02050a2:	10a50513          	addi	a0,a0,266 # ffffffffc02081a8 <default_pmm_manager+0x1070>
ffffffffc02050a6:	bd4fb0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("Unlock failed.\n");
ffffffffc02050aa:	00003617          	auipc	a2,0x3
ffffffffc02050ae:	12e60613          	addi	a2,a2,302 # ffffffffc02081d8 <default_pmm_manager+0x10a0>
ffffffffc02050b2:	03100593          	li	a1,49
ffffffffc02050b6:	00003517          	auipc	a0,0x3
ffffffffc02050ba:	13250513          	addi	a0,a0,306 # ffffffffc02081e8 <default_pmm_manager+0x10b0>
ffffffffc02050be:	bbcfb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02050c2 <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02050c2:	7129                	addi	sp,sp,-320
ffffffffc02050c4:	fa22                	sd	s0,304(sp)
ffffffffc02050c6:	f626                	sd	s1,296(sp)
ffffffffc02050c8:	f24a                	sd	s2,288(sp)
ffffffffc02050ca:	84ae                	mv	s1,a1
ffffffffc02050cc:	892a                	mv	s2,a0
ffffffffc02050ce:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02050d0:	4581                	li	a1,0
ffffffffc02050d2:	12000613          	li	a2,288
ffffffffc02050d6:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02050d8:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02050da:	2de010ef          	jal	ra,ffffffffc02063b8 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc02050de:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc02050e0:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc02050e2:	100027f3          	csrr	a5,sstatus
ffffffffc02050e6:	edd7f793          	andi	a5,a5,-291
ffffffffc02050ea:	1207e793          	ori	a5,a5,288
ffffffffc02050ee:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02050f0:	860a                	mv	a2,sp
ffffffffc02050f2:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02050f6:	00000797          	auipc	a5,0x0
ffffffffc02050fa:	9d678793          	addi	a5,a5,-1578 # ffffffffc0204acc <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02050fe:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0205100:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205102:	bb3ff0ef          	jal	ra,ffffffffc0204cb4 <do_fork>
}
ffffffffc0205106:	70f2                	ld	ra,312(sp)
ffffffffc0205108:	7452                	ld	s0,304(sp)
ffffffffc020510a:	74b2                	ld	s1,296(sp)
ffffffffc020510c:	7912                	ld	s2,288(sp)
ffffffffc020510e:	6131                	addi	sp,sp,320
ffffffffc0205110:	8082                	ret

ffffffffc0205112 <do_exit>:
do_exit(int error_code) {
ffffffffc0205112:	7179                	addi	sp,sp,-48
ffffffffc0205114:	f022                	sd	s0,32(sp)
    if (current == idleproc) {
ffffffffc0205116:	000ad417          	auipc	s0,0xad
ffffffffc020511a:	6ba40413          	addi	s0,s0,1722 # ffffffffc02b27d0 <current>
ffffffffc020511e:	601c                	ld	a5,0(s0)
do_exit(int error_code) {
ffffffffc0205120:	f406                	sd	ra,40(sp)
ffffffffc0205122:	ec26                	sd	s1,24(sp)
ffffffffc0205124:	e84a                	sd	s2,16(sp)
ffffffffc0205126:	e44e                	sd	s3,8(sp)
ffffffffc0205128:	e052                	sd	s4,0(sp)
    if (current == idleproc) {
ffffffffc020512a:	000ad717          	auipc	a4,0xad
ffffffffc020512e:	6ae73703          	ld	a4,1710(a4) # ffffffffc02b27d8 <idleproc>
ffffffffc0205132:	0ce78c63          	beq	a5,a4,ffffffffc020520a <do_exit+0xf8>
    if (current == initproc) {
ffffffffc0205136:	000ad497          	auipc	s1,0xad
ffffffffc020513a:	6aa48493          	addi	s1,s1,1706 # ffffffffc02b27e0 <initproc>
ffffffffc020513e:	6098                	ld	a4,0(s1)
ffffffffc0205140:	0ee78b63          	beq	a5,a4,ffffffffc0205236 <do_exit+0x124>
    struct mm_struct *mm = current->mm;
ffffffffc0205144:	0287b983          	ld	s3,40(a5)
ffffffffc0205148:	892a                	mv	s2,a0
    if (mm != NULL) {
ffffffffc020514a:	02098663          	beqz	s3,ffffffffc0205176 <do_exit+0x64>
ffffffffc020514e:	000ad797          	auipc	a5,0xad
ffffffffc0205152:	62a7b783          	ld	a5,1578(a5) # ffffffffc02b2778 <boot_cr3>
ffffffffc0205156:	577d                	li	a4,-1
ffffffffc0205158:	177e                	slli	a4,a4,0x3f
ffffffffc020515a:	83b1                	srli	a5,a5,0xc
ffffffffc020515c:	8fd9                	or	a5,a5,a4
ffffffffc020515e:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc0205162:	0309a783          	lw	a5,48(s3)
ffffffffc0205166:	fff7871b          	addiw	a4,a5,-1
ffffffffc020516a:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0) {
ffffffffc020516e:	cb55                	beqz	a4,ffffffffc0205222 <do_exit+0x110>
        current->mm = NULL;
ffffffffc0205170:	601c                	ld	a5,0(s0)
ffffffffc0205172:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc0205176:	601c                	ld	a5,0(s0)
ffffffffc0205178:	470d                	li	a4,3
ffffffffc020517a:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc020517c:	0f27a423          	sw	s2,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205180:	100027f3          	csrr	a5,sstatus
ffffffffc0205184:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205186:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205188:	e3f9                	bnez	a5,ffffffffc020524e <do_exit+0x13c>
        proc = current->parent;
ffffffffc020518a:	6018                	ld	a4,0(s0)
        if (proc->wait_state == WT_CHILD) {
ffffffffc020518c:	800007b7          	lui	a5,0x80000
ffffffffc0205190:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc0205192:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD) {
ffffffffc0205194:	0ec52703          	lw	a4,236(a0)
ffffffffc0205198:	0af70f63          	beq	a4,a5,ffffffffc0205256 <do_exit+0x144>
        while (current->cptr != NULL) {
ffffffffc020519c:	6018                	ld	a4,0(s0)
ffffffffc020519e:	7b7c                	ld	a5,240(a4)
ffffffffc02051a0:	c3a1                	beqz	a5,ffffffffc02051e0 <do_exit+0xce>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc02051a2:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02051a6:	490d                	li	s2,3
                if (initproc->wait_state == WT_CHILD) {
ffffffffc02051a8:	0985                	addi	s3,s3,1
ffffffffc02051aa:	a021                	j	ffffffffc02051b2 <do_exit+0xa0>
        while (current->cptr != NULL) {
ffffffffc02051ac:	6018                	ld	a4,0(s0)
ffffffffc02051ae:	7b7c                	ld	a5,240(a4)
ffffffffc02051b0:	cb85                	beqz	a5,ffffffffc02051e0 <do_exit+0xce>
            current->cptr = proc->optr;
ffffffffc02051b2:	1007b683          	ld	a3,256(a5) # ffffffff80000100 <_binary_obj___user_exit_out_size+0xffffffff7fff4fe0>
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc02051b6:	6088                	ld	a0,0(s1)
            current->cptr = proc->optr;
ffffffffc02051b8:	fb74                	sd	a3,240(a4)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc02051ba:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc02051bc:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc02051c0:	10e7b023          	sd	a4,256(a5)
ffffffffc02051c4:	c311                	beqz	a4,ffffffffc02051c8 <do_exit+0xb6>
                initproc->cptr->yptr = proc;
ffffffffc02051c6:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02051c8:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc02051ca:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc02051cc:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02051ce:	fd271fe3          	bne	a4,s2,ffffffffc02051ac <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc02051d2:	0ec52783          	lw	a5,236(a0)
ffffffffc02051d6:	fd379be3          	bne	a5,s3,ffffffffc02051ac <do_exit+0x9a>
                    wakeup_proc(initproc);
ffffffffc02051da:	373000ef          	jal	ra,ffffffffc0205d4c <wakeup_proc>
ffffffffc02051de:	b7f9                	j	ffffffffc02051ac <do_exit+0x9a>
    if (flag) {
ffffffffc02051e0:	020a1263          	bnez	s4,ffffffffc0205204 <do_exit+0xf2>
    schedule();
ffffffffc02051e4:	3e9000ef          	jal	ra,ffffffffc0205dcc <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc02051e8:	601c                	ld	a5,0(s0)
ffffffffc02051ea:	00003617          	auipc	a2,0x3
ffffffffc02051ee:	03660613          	addi	a2,a2,54 # ffffffffc0208220 <default_pmm_manager+0x10e8>
ffffffffc02051f2:	23a00593          	li	a1,570
ffffffffc02051f6:	43d4                	lw	a3,4(a5)
ffffffffc02051f8:	00003517          	auipc	a0,0x3
ffffffffc02051fc:	fb050513          	addi	a0,a0,-80 # ffffffffc02081a8 <default_pmm_manager+0x1070>
ffffffffc0205200:	a7afb0ef          	jal	ra,ffffffffc020047a <__panic>
        intr_enable();
ffffffffc0205204:	c18fb0ef          	jal	ra,ffffffffc020061c <intr_enable>
ffffffffc0205208:	bff1                	j	ffffffffc02051e4 <do_exit+0xd2>
        panic("idleproc exit.\n");
ffffffffc020520a:	00003617          	auipc	a2,0x3
ffffffffc020520e:	ff660613          	addi	a2,a2,-10 # ffffffffc0208200 <default_pmm_manager+0x10c8>
ffffffffc0205212:	20e00593          	li	a1,526
ffffffffc0205216:	00003517          	auipc	a0,0x3
ffffffffc020521a:	f9250513          	addi	a0,a0,-110 # ffffffffc02081a8 <default_pmm_manager+0x1070>
ffffffffc020521e:	a5cfb0ef          	jal	ra,ffffffffc020047a <__panic>
            exit_mmap(mm);
ffffffffc0205222:	854e                	mv	a0,s3
ffffffffc0205224:	8dcff0ef          	jal	ra,ffffffffc0204300 <exit_mmap>
            put_pgdir(mm);
ffffffffc0205228:	854e                	mv	a0,s3
ffffffffc020522a:	9a9ff0ef          	jal	ra,ffffffffc0204bd2 <put_pgdir>
            mm_destroy(mm);
ffffffffc020522e:	854e                	mv	a0,s3
ffffffffc0205230:	f35fe0ef          	jal	ra,ffffffffc0204164 <mm_destroy>
ffffffffc0205234:	bf35                	j	ffffffffc0205170 <do_exit+0x5e>
        panic("initproc exit.\n");
ffffffffc0205236:	00003617          	auipc	a2,0x3
ffffffffc020523a:	fda60613          	addi	a2,a2,-38 # ffffffffc0208210 <default_pmm_manager+0x10d8>
ffffffffc020523e:	21100593          	li	a1,529
ffffffffc0205242:	00003517          	auipc	a0,0x3
ffffffffc0205246:	f6650513          	addi	a0,a0,-154 # ffffffffc02081a8 <default_pmm_manager+0x1070>
ffffffffc020524a:	a30fb0ef          	jal	ra,ffffffffc020047a <__panic>
        intr_disable();
ffffffffc020524e:	bd4fb0ef          	jal	ra,ffffffffc0200622 <intr_disable>
        return 1;
ffffffffc0205252:	4a05                	li	s4,1
ffffffffc0205254:	bf1d                	j	ffffffffc020518a <do_exit+0x78>
            wakeup_proc(proc);
ffffffffc0205256:	2f7000ef          	jal	ra,ffffffffc0205d4c <wakeup_proc>
ffffffffc020525a:	b789                	j	ffffffffc020519c <do_exit+0x8a>

ffffffffc020525c <do_wait.part.0>:
do_wait(int pid, int *code_store) {
ffffffffc020525c:	715d                	addi	sp,sp,-80
ffffffffc020525e:	f84a                	sd	s2,48(sp)
ffffffffc0205260:	f44e                	sd	s3,40(sp)
        current->wait_state = WT_CHILD;
ffffffffc0205262:	80000937          	lui	s2,0x80000
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205266:	6989                	lui	s3,0x2
do_wait(int pid, int *code_store) {
ffffffffc0205268:	fc26                	sd	s1,56(sp)
ffffffffc020526a:	f052                	sd	s4,32(sp)
ffffffffc020526c:	ec56                	sd	s5,24(sp)
ffffffffc020526e:	e85a                	sd	s6,16(sp)
ffffffffc0205270:	e45e                	sd	s7,8(sp)
ffffffffc0205272:	e486                	sd	ra,72(sp)
ffffffffc0205274:	e0a2                	sd	s0,64(sp)
ffffffffc0205276:	84aa                	mv	s1,a0
ffffffffc0205278:	8a2e                	mv	s4,a1
        proc = current->cptr;
ffffffffc020527a:	000adb97          	auipc	s7,0xad
ffffffffc020527e:	556b8b93          	addi	s7,s7,1366 # ffffffffc02b27d0 <current>
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205282:	00050b1b          	sext.w	s6,a0
ffffffffc0205286:	fff50a9b          	addiw	s5,a0,-1
ffffffffc020528a:	19f9                	addi	s3,s3,-2
        current->wait_state = WT_CHILD;
ffffffffc020528c:	0905                	addi	s2,s2,1
    if (pid != 0) {
ffffffffc020528e:	ccbd                	beqz	s1,ffffffffc020530c <do_wait.part.0+0xb0>
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205290:	0359e863          	bltu	s3,s5,ffffffffc02052c0 <do_wait.part.0+0x64>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205294:	45a9                	li	a1,10
ffffffffc0205296:	855a                	mv	a0,s6
ffffffffc0205298:	4a1000ef          	jal	ra,ffffffffc0205f38 <hash32>
ffffffffc020529c:	02051793          	slli	a5,a0,0x20
ffffffffc02052a0:	01c7d513          	srli	a0,a5,0x1c
ffffffffc02052a4:	000a9797          	auipc	a5,0xa9
ffffffffc02052a8:	4a478793          	addi	a5,a5,1188 # ffffffffc02ae748 <hash_list>
ffffffffc02052ac:	953e                	add	a0,a0,a5
ffffffffc02052ae:	842a                	mv	s0,a0
        while ((le = list_next(le)) != list) {
ffffffffc02052b0:	a029                	j	ffffffffc02052ba <do_wait.part.0+0x5e>
            if (proc->pid == pid) {
ffffffffc02052b2:	f2c42783          	lw	a5,-212(s0)
ffffffffc02052b6:	02978163          	beq	a5,s1,ffffffffc02052d8 <do_wait.part.0+0x7c>
ffffffffc02052ba:	6400                	ld	s0,8(s0)
        while ((le = list_next(le)) != list) {
ffffffffc02052bc:	fe851be3          	bne	a0,s0,ffffffffc02052b2 <do_wait.part.0+0x56>
    return -E_BAD_PROC;
ffffffffc02052c0:	5579                	li	a0,-2
}
ffffffffc02052c2:	60a6                	ld	ra,72(sp)
ffffffffc02052c4:	6406                	ld	s0,64(sp)
ffffffffc02052c6:	74e2                	ld	s1,56(sp)
ffffffffc02052c8:	7942                	ld	s2,48(sp)
ffffffffc02052ca:	79a2                	ld	s3,40(sp)
ffffffffc02052cc:	7a02                	ld	s4,32(sp)
ffffffffc02052ce:	6ae2                	ld	s5,24(sp)
ffffffffc02052d0:	6b42                	ld	s6,16(sp)
ffffffffc02052d2:	6ba2                	ld	s7,8(sp)
ffffffffc02052d4:	6161                	addi	sp,sp,80
ffffffffc02052d6:	8082                	ret
        if (proc != NULL && proc->parent == current) {
ffffffffc02052d8:	000bb683          	ld	a3,0(s7)
ffffffffc02052dc:	f4843783          	ld	a5,-184(s0)
ffffffffc02052e0:	fed790e3          	bne	a5,a3,ffffffffc02052c0 <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02052e4:	f2842703          	lw	a4,-216(s0)
ffffffffc02052e8:	478d                	li	a5,3
ffffffffc02052ea:	0ef70b63          	beq	a4,a5,ffffffffc02053e0 <do_wait.part.0+0x184>
        current->state = PROC_SLEEPING;
ffffffffc02052ee:	4785                	li	a5,1
ffffffffc02052f0:	c29c                	sw	a5,0(a3)
        current->wait_state = WT_CHILD;
ffffffffc02052f2:	0f26a623          	sw	s2,236(a3)
        schedule();
ffffffffc02052f6:	2d7000ef          	jal	ra,ffffffffc0205dcc <schedule>
        if (current->flags & PF_EXITING) {
ffffffffc02052fa:	000bb783          	ld	a5,0(s7)
ffffffffc02052fe:	0b07a783          	lw	a5,176(a5)
ffffffffc0205302:	8b85                	andi	a5,a5,1
ffffffffc0205304:	d7c9                	beqz	a5,ffffffffc020528e <do_wait.part.0+0x32>
            do_exit(-E_KILLED);
ffffffffc0205306:	555d                	li	a0,-9
ffffffffc0205308:	e0bff0ef          	jal	ra,ffffffffc0205112 <do_exit>
        proc = current->cptr;
ffffffffc020530c:	000bb683          	ld	a3,0(s7)
ffffffffc0205310:	7ae0                	ld	s0,240(a3)
        for (; proc != NULL; proc = proc->optr) {
ffffffffc0205312:	d45d                	beqz	s0,ffffffffc02052c0 <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205314:	470d                	li	a4,3
ffffffffc0205316:	a021                	j	ffffffffc020531e <do_wait.part.0+0xc2>
        for (; proc != NULL; proc = proc->optr) {
ffffffffc0205318:	10043403          	ld	s0,256(s0)
ffffffffc020531c:	d869                	beqz	s0,ffffffffc02052ee <do_wait.part.0+0x92>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc020531e:	401c                	lw	a5,0(s0)
ffffffffc0205320:	fee79ce3          	bne	a5,a4,ffffffffc0205318 <do_wait.part.0+0xbc>
    if (proc == idleproc || proc == initproc) {
ffffffffc0205324:	000ad797          	auipc	a5,0xad
ffffffffc0205328:	4b47b783          	ld	a5,1204(a5) # ffffffffc02b27d8 <idleproc>
ffffffffc020532c:	0c878963          	beq	a5,s0,ffffffffc02053fe <do_wait.part.0+0x1a2>
ffffffffc0205330:	000ad797          	auipc	a5,0xad
ffffffffc0205334:	4b07b783          	ld	a5,1200(a5) # ffffffffc02b27e0 <initproc>
ffffffffc0205338:	0cf40363          	beq	s0,a5,ffffffffc02053fe <do_wait.part.0+0x1a2>
    if (code_store != NULL) {
ffffffffc020533c:	000a0663          	beqz	s4,ffffffffc0205348 <do_wait.part.0+0xec>
        *code_store = proc->exit_code;
ffffffffc0205340:	0e842783          	lw	a5,232(s0)
ffffffffc0205344:	00fa2023          	sw	a5,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8ba8>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205348:	100027f3          	csrr	a5,sstatus
ffffffffc020534c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020534e:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205350:	e7c1                	bnez	a5,ffffffffc02053d8 <do_wait.part.0+0x17c>
    __list_del(listelm->prev, listelm->next);
ffffffffc0205352:	6c70                	ld	a2,216(s0)
ffffffffc0205354:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL) {
ffffffffc0205356:	10043703          	ld	a4,256(s0)
        proc->optr->yptr = proc->yptr;
ffffffffc020535a:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc020535c:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc020535e:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0205360:	6470                	ld	a2,200(s0)
ffffffffc0205362:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc0205364:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc0205366:	e290                	sd	a2,0(a3)
    if (proc->optr != NULL) {
ffffffffc0205368:	c319                	beqz	a4,ffffffffc020536e <do_wait.part.0+0x112>
        proc->optr->yptr = proc->yptr;
ffffffffc020536a:	ff7c                	sd	a5,248(a4)
    if (proc->yptr != NULL) {
ffffffffc020536c:	7c7c                	ld	a5,248(s0)
ffffffffc020536e:	c3b5                	beqz	a5,ffffffffc02053d2 <do_wait.part.0+0x176>
        proc->yptr->optr = proc->optr;
ffffffffc0205370:	10e7b023          	sd	a4,256(a5)
    nr_process --;
ffffffffc0205374:	000ad717          	auipc	a4,0xad
ffffffffc0205378:	47470713          	addi	a4,a4,1140 # ffffffffc02b27e8 <nr_process>
ffffffffc020537c:	431c                	lw	a5,0(a4)
ffffffffc020537e:	37fd                	addiw	a5,a5,-1
ffffffffc0205380:	c31c                	sw	a5,0(a4)
    if (flag) {
ffffffffc0205382:	e5a9                	bnez	a1,ffffffffc02053cc <do_wait.part.0+0x170>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0205384:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc0205386:	c02007b7          	lui	a5,0xc0200
ffffffffc020538a:	04f6ee63          	bltu	a3,a5,ffffffffc02053e6 <do_wait.part.0+0x18a>
ffffffffc020538e:	000ad797          	auipc	a5,0xad
ffffffffc0205392:	4127b783          	ld	a5,1042(a5) # ffffffffc02b27a0 <va_pa_offset>
ffffffffc0205396:	8e9d                	sub	a3,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc0205398:	82b1                	srli	a3,a3,0xc
ffffffffc020539a:	000ad797          	auipc	a5,0xad
ffffffffc020539e:	3ee7b783          	ld	a5,1006(a5) # ffffffffc02b2788 <npage>
ffffffffc02053a2:	06f6fa63          	bgeu	a3,a5,ffffffffc0205416 <do_wait.part.0+0x1ba>
    return &pages[PPN(pa) - nbase];
ffffffffc02053a6:	00003517          	auipc	a0,0x3
ffffffffc02053aa:	6b253503          	ld	a0,1714(a0) # ffffffffc0208a58 <nbase>
ffffffffc02053ae:	8e89                	sub	a3,a3,a0
ffffffffc02053b0:	069a                	slli	a3,a3,0x6
ffffffffc02053b2:	000ad517          	auipc	a0,0xad
ffffffffc02053b6:	3de53503          	ld	a0,990(a0) # ffffffffc02b2790 <pages>
ffffffffc02053ba:	9536                	add	a0,a0,a3
ffffffffc02053bc:	4589                	li	a1,2
ffffffffc02053be:	991fc0ef          	jal	ra,ffffffffc0201d4e <free_pages>
    kfree(proc);
ffffffffc02053c2:	8522                	mv	a0,s0
ffffffffc02053c4:	fcafc0ef          	jal	ra,ffffffffc0201b8e <kfree>
    return 0;
ffffffffc02053c8:	4501                	li	a0,0
ffffffffc02053ca:	bde5                	j	ffffffffc02052c2 <do_wait.part.0+0x66>
        intr_enable();
ffffffffc02053cc:	a50fb0ef          	jal	ra,ffffffffc020061c <intr_enable>
ffffffffc02053d0:	bf55                	j	ffffffffc0205384 <do_wait.part.0+0x128>
       proc->parent->cptr = proc->optr;
ffffffffc02053d2:	701c                	ld	a5,32(s0)
ffffffffc02053d4:	fbf8                	sd	a4,240(a5)
ffffffffc02053d6:	bf79                	j	ffffffffc0205374 <do_wait.part.0+0x118>
        intr_disable();
ffffffffc02053d8:	a4afb0ef          	jal	ra,ffffffffc0200622 <intr_disable>
        return 1;
ffffffffc02053dc:	4585                	li	a1,1
ffffffffc02053de:	bf95                	j	ffffffffc0205352 <do_wait.part.0+0xf6>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc02053e0:	f2840413          	addi	s0,s0,-216
ffffffffc02053e4:	b781                	j	ffffffffc0205324 <do_wait.part.0+0xc8>
    return pa2page(PADDR(kva));
ffffffffc02053e6:	00002617          	auipc	a2,0x2
ffffffffc02053ea:	e3260613          	addi	a2,a2,-462 # ffffffffc0207218 <default_pmm_manager+0xe0>
ffffffffc02053ee:	06e00593          	li	a1,110
ffffffffc02053f2:	00002517          	auipc	a0,0x2
ffffffffc02053f6:	da650513          	addi	a0,a0,-602 # ffffffffc0207198 <default_pmm_manager+0x60>
ffffffffc02053fa:	880fb0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("wait idleproc or initproc.\n");
ffffffffc02053fe:	00003617          	auipc	a2,0x3
ffffffffc0205402:	e4260613          	addi	a2,a2,-446 # ffffffffc0208240 <default_pmm_manager+0x1108>
ffffffffc0205406:	33800593          	li	a1,824
ffffffffc020540a:	00003517          	auipc	a0,0x3
ffffffffc020540e:	d9e50513          	addi	a0,a0,-610 # ffffffffc02081a8 <default_pmm_manager+0x1070>
ffffffffc0205412:	868fb0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0205416:	00002617          	auipc	a2,0x2
ffffffffc020541a:	e2a60613          	addi	a2,a2,-470 # ffffffffc0207240 <default_pmm_manager+0x108>
ffffffffc020541e:	06200593          	li	a1,98
ffffffffc0205422:	00002517          	auipc	a0,0x2
ffffffffc0205426:	d7650513          	addi	a0,a0,-650 # ffffffffc0207198 <default_pmm_manager+0x60>
ffffffffc020542a:	850fb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc020542e <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
ffffffffc020542e:	1141                	addi	sp,sp,-16
ffffffffc0205430:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0205432:	95dfc0ef          	jal	ra,ffffffffc0201d8e <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc0205436:	ea4fc0ef          	jal	ra,ffffffffc0201ada <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc020543a:	4601                	li	a2,0
ffffffffc020543c:	4581                	li	a1,0
ffffffffc020543e:	fffff517          	auipc	a0,0xfffff
ffffffffc0205442:	71650513          	addi	a0,a0,1814 # ffffffffc0204b54 <user_main>
ffffffffc0205446:	c7dff0ef          	jal	ra,ffffffffc02050c2 <kernel_thread>
    if (pid <= 0) {
ffffffffc020544a:	00a04563          	bgtz	a0,ffffffffc0205454 <init_main+0x26>
ffffffffc020544e:	a071                	j	ffffffffc02054da <init_main+0xac>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0) {
        schedule();
ffffffffc0205450:	17d000ef          	jal	ra,ffffffffc0205dcc <schedule>
    if (code_store != NULL) {
ffffffffc0205454:	4581                	li	a1,0
ffffffffc0205456:	4501                	li	a0,0
ffffffffc0205458:	e05ff0ef          	jal	ra,ffffffffc020525c <do_wait.part.0>
    while (do_wait(0, NULL) == 0) {
ffffffffc020545c:	d975                	beqz	a0,ffffffffc0205450 <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc020545e:	00003517          	auipc	a0,0x3
ffffffffc0205462:	e2250513          	addi	a0,a0,-478 # ffffffffc0208280 <default_pmm_manager+0x1148>
ffffffffc0205466:	d1bfa0ef          	jal	ra,ffffffffc0200180 <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc020546a:	000ad797          	auipc	a5,0xad
ffffffffc020546e:	3767b783          	ld	a5,886(a5) # ffffffffc02b27e0 <initproc>
ffffffffc0205472:	7bf8                	ld	a4,240(a5)
ffffffffc0205474:	e339                	bnez	a4,ffffffffc02054ba <init_main+0x8c>
ffffffffc0205476:	7ff8                	ld	a4,248(a5)
ffffffffc0205478:	e329                	bnez	a4,ffffffffc02054ba <init_main+0x8c>
ffffffffc020547a:	1007b703          	ld	a4,256(a5)
ffffffffc020547e:	ef15                	bnez	a4,ffffffffc02054ba <init_main+0x8c>
    assert(nr_process == 2);
ffffffffc0205480:	000ad697          	auipc	a3,0xad
ffffffffc0205484:	3686a683          	lw	a3,872(a3) # ffffffffc02b27e8 <nr_process>
ffffffffc0205488:	4709                	li	a4,2
ffffffffc020548a:	0ae69463          	bne	a3,a4,ffffffffc0205532 <init_main+0x104>
    return listelm->next;
ffffffffc020548e:	000ad697          	auipc	a3,0xad
ffffffffc0205492:	2ba68693          	addi	a3,a3,698 # ffffffffc02b2748 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0205496:	6698                	ld	a4,8(a3)
ffffffffc0205498:	0c878793          	addi	a5,a5,200
ffffffffc020549c:	06f71b63          	bne	a4,a5,ffffffffc0205512 <init_main+0xe4>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc02054a0:	629c                	ld	a5,0(a3)
ffffffffc02054a2:	04f71863          	bne	a4,a5,ffffffffc02054f2 <init_main+0xc4>

    cprintf("init check memory pass.\n");
ffffffffc02054a6:	00003517          	auipc	a0,0x3
ffffffffc02054aa:	ec250513          	addi	a0,a0,-318 # ffffffffc0208368 <default_pmm_manager+0x1230>
ffffffffc02054ae:	cd3fa0ef          	jal	ra,ffffffffc0200180 <cprintf>
    return 0;
}
ffffffffc02054b2:	60a2                	ld	ra,8(sp)
ffffffffc02054b4:	4501                	li	a0,0
ffffffffc02054b6:	0141                	addi	sp,sp,16
ffffffffc02054b8:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc02054ba:	00003697          	auipc	a3,0x3
ffffffffc02054be:	dee68693          	addi	a3,a3,-530 # ffffffffc02082a8 <default_pmm_manager+0x1170>
ffffffffc02054c2:	00001617          	auipc	a2,0x1
ffffffffc02054c6:	5de60613          	addi	a2,a2,1502 # ffffffffc0206aa0 <commands+0x450>
ffffffffc02054ca:	39d00593          	li	a1,925
ffffffffc02054ce:	00003517          	auipc	a0,0x3
ffffffffc02054d2:	cda50513          	addi	a0,a0,-806 # ffffffffc02081a8 <default_pmm_manager+0x1070>
ffffffffc02054d6:	fa5fa0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("create user_main failed.\n");
ffffffffc02054da:	00003617          	auipc	a2,0x3
ffffffffc02054de:	d8660613          	addi	a2,a2,-634 # ffffffffc0208260 <default_pmm_manager+0x1128>
ffffffffc02054e2:	39500593          	li	a1,917
ffffffffc02054e6:	00003517          	auipc	a0,0x3
ffffffffc02054ea:	cc250513          	addi	a0,a0,-830 # ffffffffc02081a8 <default_pmm_manager+0x1070>
ffffffffc02054ee:	f8dfa0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc02054f2:	00003697          	auipc	a3,0x3
ffffffffc02054f6:	e4668693          	addi	a3,a3,-442 # ffffffffc0208338 <default_pmm_manager+0x1200>
ffffffffc02054fa:	00001617          	auipc	a2,0x1
ffffffffc02054fe:	5a660613          	addi	a2,a2,1446 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0205502:	3a000593          	li	a1,928
ffffffffc0205506:	00003517          	auipc	a0,0x3
ffffffffc020550a:	ca250513          	addi	a0,a0,-862 # ffffffffc02081a8 <default_pmm_manager+0x1070>
ffffffffc020550e:	f6dfa0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0205512:	00003697          	auipc	a3,0x3
ffffffffc0205516:	df668693          	addi	a3,a3,-522 # ffffffffc0208308 <default_pmm_manager+0x11d0>
ffffffffc020551a:	00001617          	auipc	a2,0x1
ffffffffc020551e:	58660613          	addi	a2,a2,1414 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0205522:	39f00593          	li	a1,927
ffffffffc0205526:	00003517          	auipc	a0,0x3
ffffffffc020552a:	c8250513          	addi	a0,a0,-894 # ffffffffc02081a8 <default_pmm_manager+0x1070>
ffffffffc020552e:	f4dfa0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(nr_process == 2);
ffffffffc0205532:	00003697          	auipc	a3,0x3
ffffffffc0205536:	dc668693          	addi	a3,a3,-570 # ffffffffc02082f8 <default_pmm_manager+0x11c0>
ffffffffc020553a:	00001617          	auipc	a2,0x1
ffffffffc020553e:	56660613          	addi	a2,a2,1382 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0205542:	39e00593          	li	a1,926
ffffffffc0205546:	00003517          	auipc	a0,0x3
ffffffffc020554a:	c6250513          	addi	a0,a0,-926 # ffffffffc02081a8 <default_pmm_manager+0x1070>
ffffffffc020554e:	f2dfa0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0205552 <do_execve>:
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205552:	7171                	addi	sp,sp,-176
ffffffffc0205554:	e4ee                	sd	s11,72(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0205556:	000add97          	auipc	s11,0xad
ffffffffc020555a:	27ad8d93          	addi	s11,s11,634 # ffffffffc02b27d0 <current>
ffffffffc020555e:	000db783          	ld	a5,0(s11)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205562:	e54e                	sd	s3,136(sp)
ffffffffc0205564:	ed26                	sd	s1,152(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0205566:	0287b983          	ld	s3,40(a5)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc020556a:	e94a                	sd	s2,144(sp)
ffffffffc020556c:	f4de                	sd	s7,104(sp)
ffffffffc020556e:	892a                	mv	s2,a0
ffffffffc0205570:	8bb2                	mv	s7,a2
ffffffffc0205572:	84ae                	mv	s1,a1
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc0205574:	862e                	mv	a2,a1
ffffffffc0205576:	4681                	li	a3,0
ffffffffc0205578:	85aa                	mv	a1,a0
ffffffffc020557a:	854e                	mv	a0,s3
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc020557c:	f506                	sd	ra,168(sp)
ffffffffc020557e:	f122                	sd	s0,160(sp)
ffffffffc0205580:	e152                	sd	s4,128(sp)
ffffffffc0205582:	fcd6                	sd	s5,120(sp)
ffffffffc0205584:	f8da                	sd	s6,112(sp)
ffffffffc0205586:	f0e2                	sd	s8,96(sp)
ffffffffc0205588:	ece6                	sd	s9,88(sp)
ffffffffc020558a:	e8ea                	sd	s10,80(sp)
ffffffffc020558c:	f05e                	sd	s7,32(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc020558e:	be4ff0ef          	jal	ra,ffffffffc0204972 <user_mem_check>
ffffffffc0205592:	40050a63          	beqz	a0,ffffffffc02059a6 <do_execve+0x454>
    memset(local_name, 0, sizeof(local_name));
ffffffffc0205596:	4641                	li	a2,16
ffffffffc0205598:	4581                	li	a1,0
ffffffffc020559a:	1808                	addi	a0,sp,48
ffffffffc020559c:	61d000ef          	jal	ra,ffffffffc02063b8 <memset>
    memcpy(local_name, name, len);
ffffffffc02055a0:	47bd                	li	a5,15
ffffffffc02055a2:	8626                	mv	a2,s1
ffffffffc02055a4:	1e97e263          	bltu	a5,s1,ffffffffc0205788 <do_execve+0x236>
ffffffffc02055a8:	85ca                	mv	a1,s2
ffffffffc02055aa:	1808                	addi	a0,sp,48
ffffffffc02055ac:	61f000ef          	jal	ra,ffffffffc02063ca <memcpy>
    if (mm != NULL) {
ffffffffc02055b0:	1e098363          	beqz	s3,ffffffffc0205796 <do_execve+0x244>
        cputs("mm != NULL");
ffffffffc02055b4:	00002517          	auipc	a0,0x2
ffffffffc02055b8:	2fc50513          	addi	a0,a0,764 # ffffffffc02078b0 <default_pmm_manager+0x778>
ffffffffc02055bc:	bfdfa0ef          	jal	ra,ffffffffc02001b8 <cputs>
ffffffffc02055c0:	000ad797          	auipc	a5,0xad
ffffffffc02055c4:	1b87b783          	ld	a5,440(a5) # ffffffffc02b2778 <boot_cr3>
ffffffffc02055c8:	577d                	li	a4,-1
ffffffffc02055ca:	177e                	slli	a4,a4,0x3f
ffffffffc02055cc:	83b1                	srli	a5,a5,0xc
ffffffffc02055ce:	8fd9                	or	a5,a5,a4
ffffffffc02055d0:	18079073          	csrw	satp,a5
ffffffffc02055d4:	0309a783          	lw	a5,48(s3) # 2030 <_binary_obj___user_faultread_out_size-0x7b78>
ffffffffc02055d8:	fff7871b          	addiw	a4,a5,-1
ffffffffc02055dc:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0) {
ffffffffc02055e0:	2c070463          	beqz	a4,ffffffffc02058a8 <do_execve+0x356>
        current->mm = NULL;
ffffffffc02055e4:	000db783          	ld	a5,0(s11)
ffffffffc02055e8:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL) {
ffffffffc02055ec:	9f3fe0ef          	jal	ra,ffffffffc0203fde <mm_create>
ffffffffc02055f0:	84aa                	mv	s1,a0
ffffffffc02055f2:	1c050d63          	beqz	a0,ffffffffc02057cc <do_execve+0x27a>
    if ((page = alloc_page()) == NULL) {
ffffffffc02055f6:	4505                	li	a0,1
ffffffffc02055f8:	ec4fc0ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
ffffffffc02055fc:	3a050963          	beqz	a0,ffffffffc02059ae <do_execve+0x45c>
    return page - pages + nbase;
ffffffffc0205600:	000adc97          	auipc	s9,0xad
ffffffffc0205604:	190c8c93          	addi	s9,s9,400 # ffffffffc02b2790 <pages>
ffffffffc0205608:	000cb683          	ld	a3,0(s9)
    return KADDR(page2pa(page));
ffffffffc020560c:	000adc17          	auipc	s8,0xad
ffffffffc0205610:	17cc0c13          	addi	s8,s8,380 # ffffffffc02b2788 <npage>
    return page - pages + nbase;
ffffffffc0205614:	00003717          	auipc	a4,0x3
ffffffffc0205618:	44473703          	ld	a4,1092(a4) # ffffffffc0208a58 <nbase>
ffffffffc020561c:	40d506b3          	sub	a3,a0,a3
ffffffffc0205620:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205622:	5afd                	li	s5,-1
ffffffffc0205624:	000c3783          	ld	a5,0(s8)
    return page - pages + nbase;
ffffffffc0205628:	96ba                	add	a3,a3,a4
ffffffffc020562a:	e83a                	sd	a4,16(sp)
    return KADDR(page2pa(page));
ffffffffc020562c:	00cad713          	srli	a4,s5,0xc
ffffffffc0205630:	ec3a                	sd	a4,24(sp)
ffffffffc0205632:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0205634:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205636:	38f77063          	bgeu	a4,a5,ffffffffc02059b6 <do_execve+0x464>
ffffffffc020563a:	000adb17          	auipc	s6,0xad
ffffffffc020563e:	166b0b13          	addi	s6,s6,358 # ffffffffc02b27a0 <va_pa_offset>
ffffffffc0205642:	000b3903          	ld	s2,0(s6)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc0205646:	6605                	lui	a2,0x1
ffffffffc0205648:	000ad597          	auipc	a1,0xad
ffffffffc020564c:	1385b583          	ld	a1,312(a1) # ffffffffc02b2780 <boot_pgdir>
ffffffffc0205650:	9936                	add	s2,s2,a3
ffffffffc0205652:	854a                	mv	a0,s2
ffffffffc0205654:	577000ef          	jal	ra,ffffffffc02063ca <memcpy>
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc0205658:	7782                	ld	a5,32(sp)
ffffffffc020565a:	4398                	lw	a4,0(a5)
ffffffffc020565c:	464c47b7          	lui	a5,0x464c4
    mm->pgdir = pgdir;
ffffffffc0205660:	0124bc23          	sd	s2,24(s1)
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc0205664:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_exit_out_size+0x464b945f>
ffffffffc0205668:	14f71863          	bne	a4,a5,ffffffffc02057b8 <do_execve+0x266>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc020566c:	7682                	ld	a3,32(sp)
ffffffffc020566e:	0386d703          	lhu	a4,56(a3)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0205672:	0206b983          	ld	s3,32(a3)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205676:	00371793          	slli	a5,a4,0x3
ffffffffc020567a:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc020567c:	99b6                	add	s3,s3,a3
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc020567e:	078e                	slli	a5,a5,0x3
ffffffffc0205680:	97ce                	add	a5,a5,s3
ffffffffc0205682:	f43e                	sd	a5,40(sp)
    for (; ph < ph_end; ph ++) {
ffffffffc0205684:	00f9fc63          	bgeu	s3,a5,ffffffffc020569c <do_execve+0x14a>
        if (ph->p_type != ELF_PT_LOAD) {
ffffffffc0205688:	0009a783          	lw	a5,0(s3)
ffffffffc020568c:	4705                	li	a4,1
ffffffffc020568e:	14e78163          	beq	a5,a4,ffffffffc02057d0 <do_execve+0x27e>
    for (; ph < ph_end; ph ++) {
ffffffffc0205692:	77a2                	ld	a5,40(sp)
ffffffffc0205694:	03898993          	addi	s3,s3,56
ffffffffc0205698:	fef9e8e3          	bltu	s3,a5,ffffffffc0205688 <do_execve+0x136>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
ffffffffc020569c:	4701                	li	a4,0
ffffffffc020569e:	46ad                	li	a3,11
ffffffffc02056a0:	00100637          	lui	a2,0x100
ffffffffc02056a4:	7ff005b7          	lui	a1,0x7ff00
ffffffffc02056a8:	8526                	mv	a0,s1
ffffffffc02056aa:	b0dfe0ef          	jal	ra,ffffffffc02041b6 <mm_map>
ffffffffc02056ae:	8a2a                	mv	s4,a0
ffffffffc02056b0:	1e051263          	bnez	a0,ffffffffc0205894 <do_execve+0x342>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc02056b4:	6c88                	ld	a0,24(s1)
ffffffffc02056b6:	467d                	li	a2,31
ffffffffc02056b8:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc02056bc:	bc9fd0ef          	jal	ra,ffffffffc0203284 <pgdir_alloc_page>
ffffffffc02056c0:	38050363          	beqz	a0,ffffffffc0205a46 <do_execve+0x4f4>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc02056c4:	6c88                	ld	a0,24(s1)
ffffffffc02056c6:	467d                	li	a2,31
ffffffffc02056c8:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc02056cc:	bb9fd0ef          	jal	ra,ffffffffc0203284 <pgdir_alloc_page>
ffffffffc02056d0:	34050b63          	beqz	a0,ffffffffc0205a26 <do_execve+0x4d4>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc02056d4:	6c88                	ld	a0,24(s1)
ffffffffc02056d6:	467d                	li	a2,31
ffffffffc02056d8:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc02056dc:	ba9fd0ef          	jal	ra,ffffffffc0203284 <pgdir_alloc_page>
ffffffffc02056e0:	32050363          	beqz	a0,ffffffffc0205a06 <do_execve+0x4b4>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc02056e4:	6c88                	ld	a0,24(s1)
ffffffffc02056e6:	467d                	li	a2,31
ffffffffc02056e8:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc02056ec:	b99fd0ef          	jal	ra,ffffffffc0203284 <pgdir_alloc_page>
ffffffffc02056f0:	2e050b63          	beqz	a0,ffffffffc02059e6 <do_execve+0x494>
    mm->mm_count += 1;
ffffffffc02056f4:	589c                	lw	a5,48(s1)
    current->mm = mm;
ffffffffc02056f6:	000db603          	ld	a2,0(s11)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc02056fa:	6c94                	ld	a3,24(s1)
ffffffffc02056fc:	2785                	addiw	a5,a5,1
ffffffffc02056fe:	d89c                	sw	a5,48(s1)
    current->mm = mm;
ffffffffc0205700:	f604                	sd	s1,40(a2)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205702:	c02007b7          	lui	a5,0xc0200
ffffffffc0205706:	2cf6e463          	bltu	a3,a5,ffffffffc02059ce <do_execve+0x47c>
ffffffffc020570a:	000b3783          	ld	a5,0(s6)
ffffffffc020570e:	577d                	li	a4,-1
ffffffffc0205710:	177e                	slli	a4,a4,0x3f
ffffffffc0205712:	8e9d                	sub	a3,a3,a5
ffffffffc0205714:	00c6d793          	srli	a5,a3,0xc
ffffffffc0205718:	f654                	sd	a3,168(a2)
ffffffffc020571a:	8fd9                	or	a5,a5,a4
ffffffffc020571c:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc0205720:	7240                	ld	s0,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0205722:	4581                	li	a1,0
ffffffffc0205724:	12000613          	li	a2,288
ffffffffc0205728:	8522                	mv	a0,s0
    uintptr_t sstatus = tf->status;
ffffffffc020572a:	10043483          	ld	s1,256(s0)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc020572e:	48b000ef          	jal	ra,ffffffffc02063b8 <memset>
    tf->epc=elf->e_entry;
ffffffffc0205732:	7782                	ld	a5,32(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205734:	000db903          	ld	s2,0(s11)
    tf->status=(sstatus|SSTATUS_SPIE)&(~SSTATUS_SPP);
ffffffffc0205738:	edf4f493          	andi	s1,s1,-289
    tf->epc=elf->e_entry;
ffffffffc020573c:	6f98                	ld	a4,24(a5)
    tf->gpr.sp=USTACKTOP;
ffffffffc020573e:	4785                	li	a5,1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205740:	0b490913          	addi	s2,s2,180 # ffffffff800000b4 <_binary_obj___user_exit_out_size+0xffffffff7fff4f94>
    tf->gpr.sp=USTACKTOP;
ffffffffc0205744:	07fe                	slli	a5,a5,0x1f
    tf->status=(sstatus|SSTATUS_SPIE)&(~SSTATUS_SPP);
ffffffffc0205746:	0204e493          	ori	s1,s1,32
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020574a:	4641                	li	a2,16
ffffffffc020574c:	4581                	li	a1,0
    tf->gpr.sp=USTACKTOP;
ffffffffc020574e:	e81c                	sd	a5,16(s0)
    tf->epc=elf->e_entry;
ffffffffc0205750:	10e43423          	sd	a4,264(s0)
    tf->status=(sstatus|SSTATUS_SPIE)&(~SSTATUS_SPP);
ffffffffc0205754:	10943023          	sd	s1,256(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205758:	854a                	mv	a0,s2
ffffffffc020575a:	45f000ef          	jal	ra,ffffffffc02063b8 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc020575e:	463d                	li	a2,15
ffffffffc0205760:	180c                	addi	a1,sp,48
ffffffffc0205762:	854a                	mv	a0,s2
ffffffffc0205764:	467000ef          	jal	ra,ffffffffc02063ca <memcpy>
}
ffffffffc0205768:	70aa                	ld	ra,168(sp)
ffffffffc020576a:	740a                	ld	s0,160(sp)
ffffffffc020576c:	64ea                	ld	s1,152(sp)
ffffffffc020576e:	694a                	ld	s2,144(sp)
ffffffffc0205770:	69aa                	ld	s3,136(sp)
ffffffffc0205772:	7ae6                	ld	s5,120(sp)
ffffffffc0205774:	7b46                	ld	s6,112(sp)
ffffffffc0205776:	7ba6                	ld	s7,104(sp)
ffffffffc0205778:	7c06                	ld	s8,96(sp)
ffffffffc020577a:	6ce6                	ld	s9,88(sp)
ffffffffc020577c:	6d46                	ld	s10,80(sp)
ffffffffc020577e:	6da6                	ld	s11,72(sp)
ffffffffc0205780:	8552                	mv	a0,s4
ffffffffc0205782:	6a0a                	ld	s4,128(sp)
ffffffffc0205784:	614d                	addi	sp,sp,176
ffffffffc0205786:	8082                	ret
    memcpy(local_name, name, len);
ffffffffc0205788:	463d                	li	a2,15
ffffffffc020578a:	85ca                	mv	a1,s2
ffffffffc020578c:	1808                	addi	a0,sp,48
ffffffffc020578e:	43d000ef          	jal	ra,ffffffffc02063ca <memcpy>
    if (mm != NULL) {
ffffffffc0205792:	e20991e3          	bnez	s3,ffffffffc02055b4 <do_execve+0x62>
    if (current->mm != NULL) {
ffffffffc0205796:	000db783          	ld	a5,0(s11)
ffffffffc020579a:	779c                	ld	a5,40(a5)
ffffffffc020579c:	e40788e3          	beqz	a5,ffffffffc02055ec <do_execve+0x9a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc02057a0:	00003617          	auipc	a2,0x3
ffffffffc02057a4:	be860613          	addi	a2,a2,-1048 # ffffffffc0208388 <default_pmm_manager+0x1250>
ffffffffc02057a8:	24400593          	li	a1,580
ffffffffc02057ac:	00003517          	auipc	a0,0x3
ffffffffc02057b0:	9fc50513          	addi	a0,a0,-1540 # ffffffffc02081a8 <default_pmm_manager+0x1070>
ffffffffc02057b4:	cc7fa0ef          	jal	ra,ffffffffc020047a <__panic>
    put_pgdir(mm);
ffffffffc02057b8:	8526                	mv	a0,s1
ffffffffc02057ba:	c18ff0ef          	jal	ra,ffffffffc0204bd2 <put_pgdir>
    mm_destroy(mm);
ffffffffc02057be:	8526                	mv	a0,s1
ffffffffc02057c0:	9a5fe0ef          	jal	ra,ffffffffc0204164 <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc02057c4:	5a61                	li	s4,-8
    do_exit(ret);
ffffffffc02057c6:	8552                	mv	a0,s4
ffffffffc02057c8:	94bff0ef          	jal	ra,ffffffffc0205112 <do_exit>
    int ret = -E_NO_MEM;
ffffffffc02057cc:	5a71                	li	s4,-4
ffffffffc02057ce:	bfe5                	j	ffffffffc02057c6 <do_execve+0x274>
        if (ph->p_filesz > ph->p_memsz) {
ffffffffc02057d0:	0289b603          	ld	a2,40(s3)
ffffffffc02057d4:	0209b783          	ld	a5,32(s3)
ffffffffc02057d8:	1cf66d63          	bltu	a2,a5,ffffffffc02059b2 <do_execve+0x460>
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc02057dc:	0049a783          	lw	a5,4(s3)
ffffffffc02057e0:	0017f693          	andi	a3,a5,1
ffffffffc02057e4:	c291                	beqz	a3,ffffffffc02057e8 <do_execve+0x296>
ffffffffc02057e6:	4691                	li	a3,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc02057e8:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc02057ec:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc02057ee:	e779                	bnez	a4,ffffffffc02058bc <do_execve+0x36a>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc02057f0:	4d45                	li	s10,17
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc02057f2:	c781                	beqz	a5,ffffffffc02057fa <do_execve+0x2a8>
ffffffffc02057f4:	0016e693          	ori	a3,a3,1
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc02057f8:	4d4d                	li	s10,19
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc02057fa:	0026f793          	andi	a5,a3,2
ffffffffc02057fe:	e3f1                	bnez	a5,ffffffffc02058c2 <do_execve+0x370>
        if (vm_flags & VM_EXEC) perm |= PTE_X;
ffffffffc0205800:	0046f793          	andi	a5,a3,4
ffffffffc0205804:	c399                	beqz	a5,ffffffffc020580a <do_execve+0x2b8>
ffffffffc0205806:	008d6d13          	ori	s10,s10,8
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
ffffffffc020580a:	0109b583          	ld	a1,16(s3)
ffffffffc020580e:	4701                	li	a4,0
ffffffffc0205810:	8526                	mv	a0,s1
ffffffffc0205812:	9a5fe0ef          	jal	ra,ffffffffc02041b6 <mm_map>
ffffffffc0205816:	8a2a                	mv	s4,a0
ffffffffc0205818:	ed35                	bnez	a0,ffffffffc0205894 <do_execve+0x342>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc020581a:	0109bb83          	ld	s7,16(s3)
ffffffffc020581e:	77fd                	lui	a5,0xfffff
        end = ph->p_va + ph->p_filesz;
ffffffffc0205820:	0209ba03          	ld	s4,32(s3)
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205824:	0089b903          	ld	s2,8(s3)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205828:	00fbfab3          	and	s5,s7,a5
        unsigned char *from = binary + ph->p_offset;
ffffffffc020582c:	7782                	ld	a5,32(sp)
        end = ph->p_va + ph->p_filesz;
ffffffffc020582e:	9a5e                	add	s4,s4,s7
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205830:	993e                	add	s2,s2,a5
        while (start < end) {
ffffffffc0205832:	054be963          	bltu	s7,s4,ffffffffc0205884 <do_execve+0x332>
ffffffffc0205836:	aa95                	j	ffffffffc02059aa <do_execve+0x458>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205838:	6785                	lui	a5,0x1
ffffffffc020583a:	415b8533          	sub	a0,s7,s5
ffffffffc020583e:	9abe                	add	s5,s5,a5
ffffffffc0205840:	417a8633          	sub	a2,s5,s7
            if (end < la) {
ffffffffc0205844:	015a7463          	bgeu	s4,s5,ffffffffc020584c <do_execve+0x2fa>
                size -= la - end;
ffffffffc0205848:	417a0633          	sub	a2,s4,s7
    return page - pages + nbase;
ffffffffc020584c:	000cb683          	ld	a3,0(s9)
ffffffffc0205850:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205852:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0205856:	40d406b3          	sub	a3,s0,a3
ffffffffc020585a:	8699                	srai	a3,a3,0x6
ffffffffc020585c:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc020585e:	67e2                	ld	a5,24(sp)
ffffffffc0205860:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205864:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205866:	14b87863          	bgeu	a6,a1,ffffffffc02059b6 <do_execve+0x464>
ffffffffc020586a:	000b3803          	ld	a6,0(s6)
            memcpy(page2kva(page) + off, from, size);
ffffffffc020586e:	85ca                	mv	a1,s2
            start += size, from += size;
ffffffffc0205870:	9bb2                	add	s7,s7,a2
ffffffffc0205872:	96c2                	add	a3,a3,a6
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205874:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc0205876:	e432                	sd	a2,8(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205878:	353000ef          	jal	ra,ffffffffc02063ca <memcpy>
            start += size, from += size;
ffffffffc020587c:	6622                	ld	a2,8(sp)
ffffffffc020587e:	9932                	add	s2,s2,a2
        while (start < end) {
ffffffffc0205880:	054bf363          	bgeu	s7,s4,ffffffffc02058c6 <do_execve+0x374>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205884:	6c88                	ld	a0,24(s1)
ffffffffc0205886:	866a                	mv	a2,s10
ffffffffc0205888:	85d6                	mv	a1,s5
ffffffffc020588a:	9fbfd0ef          	jal	ra,ffffffffc0203284 <pgdir_alloc_page>
ffffffffc020588e:	842a                	mv	s0,a0
ffffffffc0205890:	f545                	bnez	a0,ffffffffc0205838 <do_execve+0x2e6>
        ret = -E_NO_MEM;
ffffffffc0205892:	5a71                	li	s4,-4
    exit_mmap(mm);
ffffffffc0205894:	8526                	mv	a0,s1
ffffffffc0205896:	a6bfe0ef          	jal	ra,ffffffffc0204300 <exit_mmap>
    put_pgdir(mm);
ffffffffc020589a:	8526                	mv	a0,s1
ffffffffc020589c:	b36ff0ef          	jal	ra,ffffffffc0204bd2 <put_pgdir>
    mm_destroy(mm);
ffffffffc02058a0:	8526                	mv	a0,s1
ffffffffc02058a2:	8c3fe0ef          	jal	ra,ffffffffc0204164 <mm_destroy>
    return ret;
ffffffffc02058a6:	b705                	j	ffffffffc02057c6 <do_execve+0x274>
            exit_mmap(mm);
ffffffffc02058a8:	854e                	mv	a0,s3
ffffffffc02058aa:	a57fe0ef          	jal	ra,ffffffffc0204300 <exit_mmap>
            put_pgdir(mm);
ffffffffc02058ae:	854e                	mv	a0,s3
ffffffffc02058b0:	b22ff0ef          	jal	ra,ffffffffc0204bd2 <put_pgdir>
            mm_destroy(mm);
ffffffffc02058b4:	854e                	mv	a0,s3
ffffffffc02058b6:	8affe0ef          	jal	ra,ffffffffc0204164 <mm_destroy>
ffffffffc02058ba:	b32d                	j	ffffffffc02055e4 <do_execve+0x92>
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc02058bc:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc02058c0:	fb95                	bnez	a5,ffffffffc02057f4 <do_execve+0x2a2>
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc02058c2:	4d5d                	li	s10,23
ffffffffc02058c4:	bf35                	j	ffffffffc0205800 <do_execve+0x2ae>
        end = ph->p_va + ph->p_memsz;
ffffffffc02058c6:	0109b683          	ld	a3,16(s3)
ffffffffc02058ca:	0289b903          	ld	s2,40(s3)
ffffffffc02058ce:	9936                	add	s2,s2,a3
        if (start < la) {
ffffffffc02058d0:	075bfd63          	bgeu	s7,s5,ffffffffc020594a <do_execve+0x3f8>
            if (start == end) {
ffffffffc02058d4:	db790fe3          	beq	s2,s7,ffffffffc0205692 <do_execve+0x140>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc02058d8:	6785                	lui	a5,0x1
ffffffffc02058da:	00fb8533          	add	a0,s7,a5
ffffffffc02058de:	41550533          	sub	a0,a0,s5
                size -= la - end;
ffffffffc02058e2:	41790a33          	sub	s4,s2,s7
            if (end < la) {
ffffffffc02058e6:	0b597d63          	bgeu	s2,s5,ffffffffc02059a0 <do_execve+0x44e>
    return page - pages + nbase;
ffffffffc02058ea:	000cb683          	ld	a3,0(s9)
ffffffffc02058ee:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc02058f0:	000c3603          	ld	a2,0(s8)
    return page - pages + nbase;
ffffffffc02058f4:	40d406b3          	sub	a3,s0,a3
ffffffffc02058f8:	8699                	srai	a3,a3,0x6
ffffffffc02058fa:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc02058fc:	67e2                	ld	a5,24(sp)
ffffffffc02058fe:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205902:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205904:	0ac5f963          	bgeu	a1,a2,ffffffffc02059b6 <do_execve+0x464>
ffffffffc0205908:	000b3803          	ld	a6,0(s6)
            memset(page2kva(page) + off, 0, size);
ffffffffc020590c:	8652                	mv	a2,s4
ffffffffc020590e:	4581                	li	a1,0
ffffffffc0205910:	96c2                	add	a3,a3,a6
ffffffffc0205912:	9536                	add	a0,a0,a3
ffffffffc0205914:	2a5000ef          	jal	ra,ffffffffc02063b8 <memset>
            start += size;
ffffffffc0205918:	017a0733          	add	a4,s4,s7
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc020591c:	03597463          	bgeu	s2,s5,ffffffffc0205944 <do_execve+0x3f2>
ffffffffc0205920:	d6e909e3          	beq	s2,a4,ffffffffc0205692 <do_execve+0x140>
ffffffffc0205924:	00003697          	auipc	a3,0x3
ffffffffc0205928:	a8c68693          	addi	a3,a3,-1396 # ffffffffc02083b0 <default_pmm_manager+0x1278>
ffffffffc020592c:	00001617          	auipc	a2,0x1
ffffffffc0205930:	17460613          	addi	a2,a2,372 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0205934:	29900593          	li	a1,665
ffffffffc0205938:	00003517          	auipc	a0,0x3
ffffffffc020593c:	87050513          	addi	a0,a0,-1936 # ffffffffc02081a8 <default_pmm_manager+0x1070>
ffffffffc0205940:	b3bfa0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc0205944:	ff5710e3          	bne	a4,s5,ffffffffc0205924 <do_execve+0x3d2>
ffffffffc0205948:	8bd6                	mv	s7,s5
        while (start < end) {
ffffffffc020594a:	d52bf4e3          	bgeu	s7,s2,ffffffffc0205692 <do_execve+0x140>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc020594e:	6c88                	ld	a0,24(s1)
ffffffffc0205950:	866a                	mv	a2,s10
ffffffffc0205952:	85d6                	mv	a1,s5
ffffffffc0205954:	931fd0ef          	jal	ra,ffffffffc0203284 <pgdir_alloc_page>
ffffffffc0205958:	842a                	mv	s0,a0
ffffffffc020595a:	dd05                	beqz	a0,ffffffffc0205892 <do_execve+0x340>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc020595c:	6785                	lui	a5,0x1
ffffffffc020595e:	415b8533          	sub	a0,s7,s5
ffffffffc0205962:	9abe                	add	s5,s5,a5
ffffffffc0205964:	417a8633          	sub	a2,s5,s7
            if (end < la) {
ffffffffc0205968:	01597463          	bgeu	s2,s5,ffffffffc0205970 <do_execve+0x41e>
                size -= la - end;
ffffffffc020596c:	41790633          	sub	a2,s2,s7
    return page - pages + nbase;
ffffffffc0205970:	000cb683          	ld	a3,0(s9)
ffffffffc0205974:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205976:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc020597a:	40d406b3          	sub	a3,s0,a3
ffffffffc020597e:	8699                	srai	a3,a3,0x6
ffffffffc0205980:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205982:	67e2                	ld	a5,24(sp)
ffffffffc0205984:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205988:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020598a:	02b87663          	bgeu	a6,a1,ffffffffc02059b6 <do_execve+0x464>
ffffffffc020598e:	000b3803          	ld	a6,0(s6)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205992:	4581                	li	a1,0
            start += size;
ffffffffc0205994:	9bb2                	add	s7,s7,a2
ffffffffc0205996:	96c2                	add	a3,a3,a6
            memset(page2kva(page) + off, 0, size);
ffffffffc0205998:	9536                	add	a0,a0,a3
ffffffffc020599a:	21f000ef          	jal	ra,ffffffffc02063b8 <memset>
ffffffffc020599e:	b775                	j	ffffffffc020594a <do_execve+0x3f8>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc02059a0:	417a8a33          	sub	s4,s5,s7
ffffffffc02059a4:	b799                	j	ffffffffc02058ea <do_execve+0x398>
        return -E_INVAL;
ffffffffc02059a6:	5a75                	li	s4,-3
ffffffffc02059a8:	b3c1                	j	ffffffffc0205768 <do_execve+0x216>
        while (start < end) {
ffffffffc02059aa:	86de                	mv	a3,s7
ffffffffc02059ac:	bf39                	j	ffffffffc02058ca <do_execve+0x378>
    int ret = -E_NO_MEM;
ffffffffc02059ae:	5a71                	li	s4,-4
ffffffffc02059b0:	bdc5                	j	ffffffffc02058a0 <do_execve+0x34e>
            ret = -E_INVAL_ELF;
ffffffffc02059b2:	5a61                	li	s4,-8
ffffffffc02059b4:	b5c5                	j	ffffffffc0205894 <do_execve+0x342>
ffffffffc02059b6:	00001617          	auipc	a2,0x1
ffffffffc02059ba:	7ba60613          	addi	a2,a2,1978 # ffffffffc0207170 <default_pmm_manager+0x38>
ffffffffc02059be:	06900593          	li	a1,105
ffffffffc02059c2:	00001517          	auipc	a0,0x1
ffffffffc02059c6:	7d650513          	addi	a0,a0,2006 # ffffffffc0207198 <default_pmm_manager+0x60>
ffffffffc02059ca:	ab1fa0ef          	jal	ra,ffffffffc020047a <__panic>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc02059ce:	00002617          	auipc	a2,0x2
ffffffffc02059d2:	84a60613          	addi	a2,a2,-1974 # ffffffffc0207218 <default_pmm_manager+0xe0>
ffffffffc02059d6:	2b400593          	li	a1,692
ffffffffc02059da:	00002517          	auipc	a0,0x2
ffffffffc02059de:	7ce50513          	addi	a0,a0,1998 # ffffffffc02081a8 <default_pmm_manager+0x1070>
ffffffffc02059e2:	a99fa0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc02059e6:	00003697          	auipc	a3,0x3
ffffffffc02059ea:	ae268693          	addi	a3,a3,-1310 # ffffffffc02084c8 <default_pmm_manager+0x1390>
ffffffffc02059ee:	00001617          	auipc	a2,0x1
ffffffffc02059f2:	0b260613          	addi	a2,a2,178 # ffffffffc0206aa0 <commands+0x450>
ffffffffc02059f6:	2af00593          	li	a1,687
ffffffffc02059fa:	00002517          	auipc	a0,0x2
ffffffffc02059fe:	7ae50513          	addi	a0,a0,1966 # ffffffffc02081a8 <default_pmm_manager+0x1070>
ffffffffc0205a02:	a79fa0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205a06:	00003697          	auipc	a3,0x3
ffffffffc0205a0a:	a7a68693          	addi	a3,a3,-1414 # ffffffffc0208480 <default_pmm_manager+0x1348>
ffffffffc0205a0e:	00001617          	auipc	a2,0x1
ffffffffc0205a12:	09260613          	addi	a2,a2,146 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0205a16:	2ae00593          	li	a1,686
ffffffffc0205a1a:	00002517          	auipc	a0,0x2
ffffffffc0205a1e:	78e50513          	addi	a0,a0,1934 # ffffffffc02081a8 <default_pmm_manager+0x1070>
ffffffffc0205a22:	a59fa0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205a26:	00003697          	auipc	a3,0x3
ffffffffc0205a2a:	a1268693          	addi	a3,a3,-1518 # ffffffffc0208438 <default_pmm_manager+0x1300>
ffffffffc0205a2e:	00001617          	auipc	a2,0x1
ffffffffc0205a32:	07260613          	addi	a2,a2,114 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0205a36:	2ad00593          	li	a1,685
ffffffffc0205a3a:	00002517          	auipc	a0,0x2
ffffffffc0205a3e:	76e50513          	addi	a0,a0,1902 # ffffffffc02081a8 <default_pmm_manager+0x1070>
ffffffffc0205a42:	a39fa0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205a46:	00003697          	auipc	a3,0x3
ffffffffc0205a4a:	9aa68693          	addi	a3,a3,-1622 # ffffffffc02083f0 <default_pmm_manager+0x12b8>
ffffffffc0205a4e:	00001617          	auipc	a2,0x1
ffffffffc0205a52:	05260613          	addi	a2,a2,82 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0205a56:	2ac00593          	li	a1,684
ffffffffc0205a5a:	00002517          	auipc	a0,0x2
ffffffffc0205a5e:	74e50513          	addi	a0,a0,1870 # ffffffffc02081a8 <default_pmm_manager+0x1070>
ffffffffc0205a62:	a19fa0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0205a66 <do_yield>:
    current->need_resched = 1;
ffffffffc0205a66:	000ad797          	auipc	a5,0xad
ffffffffc0205a6a:	d6a7b783          	ld	a5,-662(a5) # ffffffffc02b27d0 <current>
ffffffffc0205a6e:	4705                	li	a4,1
ffffffffc0205a70:	ef98                	sd	a4,24(a5)
}
ffffffffc0205a72:	4501                	li	a0,0
ffffffffc0205a74:	8082                	ret

ffffffffc0205a76 <do_wait>:
do_wait(int pid, int *code_store) {
ffffffffc0205a76:	1101                	addi	sp,sp,-32
ffffffffc0205a78:	e822                	sd	s0,16(sp)
ffffffffc0205a7a:	e426                	sd	s1,8(sp)
ffffffffc0205a7c:	ec06                	sd	ra,24(sp)
ffffffffc0205a7e:	842e                	mv	s0,a1
ffffffffc0205a80:	84aa                	mv	s1,a0
    if (code_store != NULL) {
ffffffffc0205a82:	c999                	beqz	a1,ffffffffc0205a98 <do_wait+0x22>
    struct mm_struct *mm = current->mm;
ffffffffc0205a84:	000ad797          	auipc	a5,0xad
ffffffffc0205a88:	d4c7b783          	ld	a5,-692(a5) # ffffffffc02b27d0 <current>
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
ffffffffc0205a8c:	7788                	ld	a0,40(a5)
ffffffffc0205a8e:	4685                	li	a3,1
ffffffffc0205a90:	4611                	li	a2,4
ffffffffc0205a92:	ee1fe0ef          	jal	ra,ffffffffc0204972 <user_mem_check>
ffffffffc0205a96:	c909                	beqz	a0,ffffffffc0205aa8 <do_wait+0x32>
ffffffffc0205a98:	85a2                	mv	a1,s0
}
ffffffffc0205a9a:	6442                	ld	s0,16(sp)
ffffffffc0205a9c:	60e2                	ld	ra,24(sp)
ffffffffc0205a9e:	8526                	mv	a0,s1
ffffffffc0205aa0:	64a2                	ld	s1,8(sp)
ffffffffc0205aa2:	6105                	addi	sp,sp,32
ffffffffc0205aa4:	fb8ff06f          	j	ffffffffc020525c <do_wait.part.0>
ffffffffc0205aa8:	60e2                	ld	ra,24(sp)
ffffffffc0205aaa:	6442                	ld	s0,16(sp)
ffffffffc0205aac:	64a2                	ld	s1,8(sp)
ffffffffc0205aae:	5575                	li	a0,-3
ffffffffc0205ab0:	6105                	addi	sp,sp,32
ffffffffc0205ab2:	8082                	ret

ffffffffc0205ab4 <do_kill>:
do_kill(int pid) {
ffffffffc0205ab4:	1141                	addi	sp,sp,-16
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205ab6:	6789                	lui	a5,0x2
do_kill(int pid) {
ffffffffc0205ab8:	e406                	sd	ra,8(sp)
ffffffffc0205aba:	e022                	sd	s0,0(sp)
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205abc:	fff5071b          	addiw	a4,a0,-1
ffffffffc0205ac0:	17f9                	addi	a5,a5,-2
ffffffffc0205ac2:	02e7e963          	bltu	a5,a4,ffffffffc0205af4 <do_kill+0x40>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205ac6:	842a                	mv	s0,a0
ffffffffc0205ac8:	45a9                	li	a1,10
ffffffffc0205aca:	2501                	sext.w	a0,a0
ffffffffc0205acc:	46c000ef          	jal	ra,ffffffffc0205f38 <hash32>
ffffffffc0205ad0:	02051793          	slli	a5,a0,0x20
ffffffffc0205ad4:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0205ad8:	000a9797          	auipc	a5,0xa9
ffffffffc0205adc:	c7078793          	addi	a5,a5,-912 # ffffffffc02ae748 <hash_list>
ffffffffc0205ae0:	953e                	add	a0,a0,a5
ffffffffc0205ae2:	87aa                	mv	a5,a0
        while ((le = list_next(le)) != list) {
ffffffffc0205ae4:	a029                	j	ffffffffc0205aee <do_kill+0x3a>
            if (proc->pid == pid) {
ffffffffc0205ae6:	f2c7a703          	lw	a4,-212(a5)
ffffffffc0205aea:	00870b63          	beq	a4,s0,ffffffffc0205b00 <do_kill+0x4c>
ffffffffc0205aee:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0205af0:	fef51be3          	bne	a0,a5,ffffffffc0205ae6 <do_kill+0x32>
    return -E_INVAL;
ffffffffc0205af4:	5475                	li	s0,-3
}
ffffffffc0205af6:	60a2                	ld	ra,8(sp)
ffffffffc0205af8:	8522                	mv	a0,s0
ffffffffc0205afa:	6402                	ld	s0,0(sp)
ffffffffc0205afc:	0141                	addi	sp,sp,16
ffffffffc0205afe:	8082                	ret
        if (!(proc->flags & PF_EXITING)) {
ffffffffc0205b00:	fd87a703          	lw	a4,-40(a5)
ffffffffc0205b04:	00177693          	andi	a3,a4,1
ffffffffc0205b08:	e295                	bnez	a3,ffffffffc0205b2c <do_kill+0x78>
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205b0a:	4bd4                	lw	a3,20(a5)
            proc->flags |= PF_EXITING;
ffffffffc0205b0c:	00176713          	ori	a4,a4,1
ffffffffc0205b10:	fce7ac23          	sw	a4,-40(a5)
            return 0;
ffffffffc0205b14:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205b16:	fe06d0e3          	bgez	a3,ffffffffc0205af6 <do_kill+0x42>
                wakeup_proc(proc);
ffffffffc0205b1a:	f2878513          	addi	a0,a5,-216
ffffffffc0205b1e:	22e000ef          	jal	ra,ffffffffc0205d4c <wakeup_proc>
}
ffffffffc0205b22:	60a2                	ld	ra,8(sp)
ffffffffc0205b24:	8522                	mv	a0,s0
ffffffffc0205b26:	6402                	ld	s0,0(sp)
ffffffffc0205b28:	0141                	addi	sp,sp,16
ffffffffc0205b2a:	8082                	ret
        return -E_KILLED;
ffffffffc0205b2c:	545d                	li	s0,-9
ffffffffc0205b2e:	b7e1                	j	ffffffffc0205af6 <do_kill+0x42>

ffffffffc0205b30 <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc0205b30:	1101                	addi	sp,sp,-32
ffffffffc0205b32:	e426                	sd	s1,8(sp)
    elm->prev = elm->next = elm;
ffffffffc0205b34:	000ad797          	auipc	a5,0xad
ffffffffc0205b38:	c1478793          	addi	a5,a5,-1004 # ffffffffc02b2748 <proc_list>
ffffffffc0205b3c:	ec06                	sd	ra,24(sp)
ffffffffc0205b3e:	e822                	sd	s0,16(sp)
ffffffffc0205b40:	e04a                	sd	s2,0(sp)
ffffffffc0205b42:	000a9497          	auipc	s1,0xa9
ffffffffc0205b46:	c0648493          	addi	s1,s1,-1018 # ffffffffc02ae748 <hash_list>
ffffffffc0205b4a:	e79c                	sd	a5,8(a5)
ffffffffc0205b4c:	e39c                	sd	a5,0(a5)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc0205b4e:	000ad717          	auipc	a4,0xad
ffffffffc0205b52:	bfa70713          	addi	a4,a4,-1030 # ffffffffc02b2748 <proc_list>
ffffffffc0205b56:	87a6                	mv	a5,s1
ffffffffc0205b58:	e79c                	sd	a5,8(a5)
ffffffffc0205b5a:	e39c                	sd	a5,0(a5)
ffffffffc0205b5c:	07c1                	addi	a5,a5,16
ffffffffc0205b5e:	fef71de3          	bne	a4,a5,ffffffffc0205b58 <proc_init+0x28>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc0205b62:	f73fe0ef          	jal	ra,ffffffffc0204ad4 <alloc_proc>
ffffffffc0205b66:	000ad917          	auipc	s2,0xad
ffffffffc0205b6a:	c7290913          	addi	s2,s2,-910 # ffffffffc02b27d8 <idleproc>
ffffffffc0205b6e:	00a93023          	sd	a0,0(s2)
ffffffffc0205b72:	0e050f63          	beqz	a0,ffffffffc0205c70 <proc_init+0x140>
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0205b76:	4789                	li	a5,2
ffffffffc0205b78:	e11c                	sd	a5,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205b7a:	00003797          	auipc	a5,0x3
ffffffffc0205b7e:	48678793          	addi	a5,a5,1158 # ffffffffc0209000 <bootstack>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205b82:	0b450413          	addi	s0,a0,180
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205b86:	e91c                	sd	a5,16(a0)
    idleproc->need_resched = 1;
ffffffffc0205b88:	4785                	li	a5,1
ffffffffc0205b8a:	ed1c                	sd	a5,24(a0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205b8c:	4641                	li	a2,16
ffffffffc0205b8e:	4581                	li	a1,0
ffffffffc0205b90:	8522                	mv	a0,s0
ffffffffc0205b92:	027000ef          	jal	ra,ffffffffc02063b8 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205b96:	463d                	li	a2,15
ffffffffc0205b98:	00003597          	auipc	a1,0x3
ffffffffc0205b9c:	99058593          	addi	a1,a1,-1648 # ffffffffc0208528 <default_pmm_manager+0x13f0>
ffffffffc0205ba0:	8522                	mv	a0,s0
ffffffffc0205ba2:	029000ef          	jal	ra,ffffffffc02063ca <memcpy>
    set_proc_name(idleproc, "idle");
    nr_process ++;
ffffffffc0205ba6:	000ad717          	auipc	a4,0xad
ffffffffc0205baa:	c4270713          	addi	a4,a4,-958 # ffffffffc02b27e8 <nr_process>
ffffffffc0205bae:	431c                	lw	a5,0(a4)

    current = idleproc;
ffffffffc0205bb0:	00093683          	ld	a3,0(s2)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205bb4:	4601                	li	a2,0
    nr_process ++;
ffffffffc0205bb6:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205bb8:	4581                	li	a1,0
ffffffffc0205bba:	00000517          	auipc	a0,0x0
ffffffffc0205bbe:	87450513          	addi	a0,a0,-1932 # ffffffffc020542e <init_main>
    nr_process ++;
ffffffffc0205bc2:	c31c                	sw	a5,0(a4)
    current = idleproc;
ffffffffc0205bc4:	000ad797          	auipc	a5,0xad
ffffffffc0205bc8:	c0d7b623          	sd	a3,-1012(a5) # ffffffffc02b27d0 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205bcc:	cf6ff0ef          	jal	ra,ffffffffc02050c2 <kernel_thread>
ffffffffc0205bd0:	842a                	mv	s0,a0
    if (pid <= 0) {
ffffffffc0205bd2:	08a05363          	blez	a0,ffffffffc0205c58 <proc_init+0x128>
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205bd6:	6789                	lui	a5,0x2
ffffffffc0205bd8:	fff5071b          	addiw	a4,a0,-1
ffffffffc0205bdc:	17f9                	addi	a5,a5,-2
ffffffffc0205bde:	2501                	sext.w	a0,a0
ffffffffc0205be0:	02e7e363          	bltu	a5,a4,ffffffffc0205c06 <proc_init+0xd6>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205be4:	45a9                	li	a1,10
ffffffffc0205be6:	352000ef          	jal	ra,ffffffffc0205f38 <hash32>
ffffffffc0205bea:	02051793          	slli	a5,a0,0x20
ffffffffc0205bee:	01c7d693          	srli	a3,a5,0x1c
ffffffffc0205bf2:	96a6                	add	a3,a3,s1
ffffffffc0205bf4:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc0205bf6:	a029                	j	ffffffffc0205c00 <proc_init+0xd0>
            if (proc->pid == pid) {
ffffffffc0205bf8:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x7c7c>
ffffffffc0205bfc:	04870b63          	beq	a4,s0,ffffffffc0205c52 <proc_init+0x122>
    return listelm->next;
ffffffffc0205c00:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0205c02:	fef69be3          	bne	a3,a5,ffffffffc0205bf8 <proc_init+0xc8>
    return NULL;
ffffffffc0205c06:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205c08:	0b478493          	addi	s1,a5,180
ffffffffc0205c0c:	4641                	li	a2,16
ffffffffc0205c0e:	4581                	li	a1,0
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0205c10:	000ad417          	auipc	s0,0xad
ffffffffc0205c14:	bd040413          	addi	s0,s0,-1072 # ffffffffc02b27e0 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205c18:	8526                	mv	a0,s1
    initproc = find_proc(pid);
ffffffffc0205c1a:	e01c                	sd	a5,0(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205c1c:	79c000ef          	jal	ra,ffffffffc02063b8 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205c20:	463d                	li	a2,15
ffffffffc0205c22:	00003597          	auipc	a1,0x3
ffffffffc0205c26:	92e58593          	addi	a1,a1,-1746 # ffffffffc0208550 <default_pmm_manager+0x1418>
ffffffffc0205c2a:	8526                	mv	a0,s1
ffffffffc0205c2c:	79e000ef          	jal	ra,ffffffffc02063ca <memcpy>
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205c30:	00093783          	ld	a5,0(s2)
ffffffffc0205c34:	cbb5                	beqz	a5,ffffffffc0205ca8 <proc_init+0x178>
ffffffffc0205c36:	43dc                	lw	a5,4(a5)
ffffffffc0205c38:	eba5                	bnez	a5,ffffffffc0205ca8 <proc_init+0x178>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205c3a:	601c                	ld	a5,0(s0)
ffffffffc0205c3c:	c7b1                	beqz	a5,ffffffffc0205c88 <proc_init+0x158>
ffffffffc0205c3e:	43d8                	lw	a4,4(a5)
ffffffffc0205c40:	4785                	li	a5,1
ffffffffc0205c42:	04f71363          	bne	a4,a5,ffffffffc0205c88 <proc_init+0x158>
}
ffffffffc0205c46:	60e2                	ld	ra,24(sp)
ffffffffc0205c48:	6442                	ld	s0,16(sp)
ffffffffc0205c4a:	64a2                	ld	s1,8(sp)
ffffffffc0205c4c:	6902                	ld	s2,0(sp)
ffffffffc0205c4e:	6105                	addi	sp,sp,32
ffffffffc0205c50:	8082                	ret
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0205c52:	f2878793          	addi	a5,a5,-216
ffffffffc0205c56:	bf4d                	j	ffffffffc0205c08 <proc_init+0xd8>
        panic("create init_main failed.\n");
ffffffffc0205c58:	00003617          	auipc	a2,0x3
ffffffffc0205c5c:	8d860613          	addi	a2,a2,-1832 # ffffffffc0208530 <default_pmm_manager+0x13f8>
ffffffffc0205c60:	3c000593          	li	a1,960
ffffffffc0205c64:	00002517          	auipc	a0,0x2
ffffffffc0205c68:	54450513          	addi	a0,a0,1348 # ffffffffc02081a8 <default_pmm_manager+0x1070>
ffffffffc0205c6c:	80ffa0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("cannot alloc idleproc.\n");
ffffffffc0205c70:	00003617          	auipc	a2,0x3
ffffffffc0205c74:	8a060613          	addi	a2,a2,-1888 # ffffffffc0208510 <default_pmm_manager+0x13d8>
ffffffffc0205c78:	3b200593          	li	a1,946
ffffffffc0205c7c:	00002517          	auipc	a0,0x2
ffffffffc0205c80:	52c50513          	addi	a0,a0,1324 # ffffffffc02081a8 <default_pmm_manager+0x1070>
ffffffffc0205c84:	ff6fa0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205c88:	00003697          	auipc	a3,0x3
ffffffffc0205c8c:	8f868693          	addi	a3,a3,-1800 # ffffffffc0208580 <default_pmm_manager+0x1448>
ffffffffc0205c90:	00001617          	auipc	a2,0x1
ffffffffc0205c94:	e1060613          	addi	a2,a2,-496 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0205c98:	3c700593          	li	a1,967
ffffffffc0205c9c:	00002517          	auipc	a0,0x2
ffffffffc0205ca0:	50c50513          	addi	a0,a0,1292 # ffffffffc02081a8 <default_pmm_manager+0x1070>
ffffffffc0205ca4:	fd6fa0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205ca8:	00003697          	auipc	a3,0x3
ffffffffc0205cac:	8b068693          	addi	a3,a3,-1872 # ffffffffc0208558 <default_pmm_manager+0x1420>
ffffffffc0205cb0:	00001617          	auipc	a2,0x1
ffffffffc0205cb4:	df060613          	addi	a2,a2,-528 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0205cb8:	3c600593          	li	a1,966
ffffffffc0205cbc:	00002517          	auipc	a0,0x2
ffffffffc0205cc0:	4ec50513          	addi	a0,a0,1260 # ffffffffc02081a8 <default_pmm_manager+0x1070>
ffffffffc0205cc4:	fb6fa0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0205cc8 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc0205cc8:	1141                	addi	sp,sp,-16
ffffffffc0205cca:	e022                	sd	s0,0(sp)
ffffffffc0205ccc:	e406                	sd	ra,8(sp)
ffffffffc0205cce:	000ad417          	auipc	s0,0xad
ffffffffc0205cd2:	b0240413          	addi	s0,s0,-1278 # ffffffffc02b27d0 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc0205cd6:	6018                	ld	a4,0(s0)
ffffffffc0205cd8:	6f1c                	ld	a5,24(a4)
ffffffffc0205cda:	dffd                	beqz	a5,ffffffffc0205cd8 <cpu_idle+0x10>
            schedule();
ffffffffc0205cdc:	0f0000ef          	jal	ra,ffffffffc0205dcc <schedule>
ffffffffc0205ce0:	bfdd                	j	ffffffffc0205cd6 <cpu_idle+0xe>

ffffffffc0205ce2 <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0205ce2:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0205ce6:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0205cea:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0205cec:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0205cee:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0205cf2:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0205cf6:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0205cfa:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0205cfe:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0205d02:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0205d06:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0205d0a:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0205d0e:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0205d12:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0205d16:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0205d1a:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0205d1e:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0205d20:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0205d22:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0205d26:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0205d2a:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0205d2e:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0205d32:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0205d36:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0205d3a:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0205d3e:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0205d42:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0205d46:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0205d4a:	8082                	ret

ffffffffc0205d4c <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205d4c:	4118                	lw	a4,0(a0)
wakeup_proc(struct proc_struct *proc) {
ffffffffc0205d4e:	1101                	addi	sp,sp,-32
ffffffffc0205d50:	ec06                	sd	ra,24(sp)
ffffffffc0205d52:	e822                	sd	s0,16(sp)
ffffffffc0205d54:	e426                	sd	s1,8(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205d56:	478d                	li	a5,3
ffffffffc0205d58:	04f70b63          	beq	a4,a5,ffffffffc0205dae <wakeup_proc+0x62>
ffffffffc0205d5c:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205d5e:	100027f3          	csrr	a5,sstatus
ffffffffc0205d62:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205d64:	4481                	li	s1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205d66:	ef9d                	bnez	a5,ffffffffc0205da4 <wakeup_proc+0x58>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE) {
ffffffffc0205d68:	4789                	li	a5,2
ffffffffc0205d6a:	02f70163          	beq	a4,a5,ffffffffc0205d8c <wakeup_proc+0x40>
            proc->state = PROC_RUNNABLE;
ffffffffc0205d6e:	c01c                	sw	a5,0(s0)
            proc->wait_state = 0;
ffffffffc0205d70:	0e042623          	sw	zero,236(s0)
    if (flag) {
ffffffffc0205d74:	e491                	bnez	s1,ffffffffc0205d80 <wakeup_proc+0x34>
        else {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205d76:	60e2                	ld	ra,24(sp)
ffffffffc0205d78:	6442                	ld	s0,16(sp)
ffffffffc0205d7a:	64a2                	ld	s1,8(sp)
ffffffffc0205d7c:	6105                	addi	sp,sp,32
ffffffffc0205d7e:	8082                	ret
ffffffffc0205d80:	6442                	ld	s0,16(sp)
ffffffffc0205d82:	60e2                	ld	ra,24(sp)
ffffffffc0205d84:	64a2                	ld	s1,8(sp)
ffffffffc0205d86:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0205d88:	895fa06f          	j	ffffffffc020061c <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc0205d8c:	00003617          	auipc	a2,0x3
ffffffffc0205d90:	85460613          	addi	a2,a2,-1964 # ffffffffc02085e0 <default_pmm_manager+0x14a8>
ffffffffc0205d94:	45c9                	li	a1,18
ffffffffc0205d96:	00003517          	auipc	a0,0x3
ffffffffc0205d9a:	83250513          	addi	a0,a0,-1998 # ffffffffc02085c8 <default_pmm_manager+0x1490>
ffffffffc0205d9e:	f44fa0ef          	jal	ra,ffffffffc02004e2 <__warn>
ffffffffc0205da2:	bfc9                	j	ffffffffc0205d74 <wakeup_proc+0x28>
        intr_disable();
ffffffffc0205da4:	87ffa0ef          	jal	ra,ffffffffc0200622 <intr_disable>
        if (proc->state != PROC_RUNNABLE) {
ffffffffc0205da8:	4018                	lw	a4,0(s0)
        return 1;
ffffffffc0205daa:	4485                	li	s1,1
ffffffffc0205dac:	bf75                	j	ffffffffc0205d68 <wakeup_proc+0x1c>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205dae:	00002697          	auipc	a3,0x2
ffffffffc0205db2:	7fa68693          	addi	a3,a3,2042 # ffffffffc02085a8 <default_pmm_manager+0x1470>
ffffffffc0205db6:	00001617          	auipc	a2,0x1
ffffffffc0205dba:	cea60613          	addi	a2,a2,-790 # ffffffffc0206aa0 <commands+0x450>
ffffffffc0205dbe:	45a5                	li	a1,9
ffffffffc0205dc0:	00003517          	auipc	a0,0x3
ffffffffc0205dc4:	80850513          	addi	a0,a0,-2040 # ffffffffc02085c8 <default_pmm_manager+0x1490>
ffffffffc0205dc8:	eb2fa0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0205dcc <schedule>:

void
schedule(void) {
ffffffffc0205dcc:	1141                	addi	sp,sp,-16
ffffffffc0205dce:	e406                	sd	ra,8(sp)
ffffffffc0205dd0:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205dd2:	100027f3          	csrr	a5,sstatus
ffffffffc0205dd6:	8b89                	andi	a5,a5,2
ffffffffc0205dd8:	4401                	li	s0,0
ffffffffc0205dda:	efbd                	bnez	a5,ffffffffc0205e58 <schedule+0x8c>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc0205ddc:	000ad897          	auipc	a7,0xad
ffffffffc0205de0:	9f48b883          	ld	a7,-1548(a7) # ffffffffc02b27d0 <current>
ffffffffc0205de4:	0008bc23          	sd	zero,24(a7)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0205de8:	000ad517          	auipc	a0,0xad
ffffffffc0205dec:	9f053503          	ld	a0,-1552(a0) # ffffffffc02b27d8 <idleproc>
ffffffffc0205df0:	04a88e63          	beq	a7,a0,ffffffffc0205e4c <schedule+0x80>
ffffffffc0205df4:	0c888693          	addi	a3,a7,200
ffffffffc0205df8:	000ad617          	auipc	a2,0xad
ffffffffc0205dfc:	95060613          	addi	a2,a2,-1712 # ffffffffc02b2748 <proc_list>
        le = last;
ffffffffc0205e00:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc0205e02:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc0205e04:	4809                	li	a6,2
ffffffffc0205e06:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc0205e08:	00c78863          	beq	a5,a2,ffffffffc0205e18 <schedule+0x4c>
                if (next->state == PROC_RUNNABLE) {
ffffffffc0205e0c:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc0205e10:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc0205e14:	03070163          	beq	a4,a6,ffffffffc0205e36 <schedule+0x6a>
                    break;
                }
            }
        } while (le != last);
ffffffffc0205e18:	fef697e3          	bne	a3,a5,ffffffffc0205e06 <schedule+0x3a>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0205e1c:	ed89                	bnez	a1,ffffffffc0205e36 <schedule+0x6a>
            next = idleproc;
        }
        next->runs ++;
ffffffffc0205e1e:	451c                	lw	a5,8(a0)
ffffffffc0205e20:	2785                	addiw	a5,a5,1
ffffffffc0205e22:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc0205e24:	00a88463          	beq	a7,a0,ffffffffc0205e2c <schedule+0x60>
            proc_run(next);
ffffffffc0205e28:	e21fe0ef          	jal	ra,ffffffffc0204c48 <proc_run>
    if (flag) {
ffffffffc0205e2c:	e819                	bnez	s0,ffffffffc0205e42 <schedule+0x76>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205e2e:	60a2                	ld	ra,8(sp)
ffffffffc0205e30:	6402                	ld	s0,0(sp)
ffffffffc0205e32:	0141                	addi	sp,sp,16
ffffffffc0205e34:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0205e36:	4198                	lw	a4,0(a1)
ffffffffc0205e38:	4789                	li	a5,2
ffffffffc0205e3a:	fef712e3          	bne	a4,a5,ffffffffc0205e1e <schedule+0x52>
ffffffffc0205e3e:	852e                	mv	a0,a1
ffffffffc0205e40:	bff9                	j	ffffffffc0205e1e <schedule+0x52>
}
ffffffffc0205e42:	6402                	ld	s0,0(sp)
ffffffffc0205e44:	60a2                	ld	ra,8(sp)
ffffffffc0205e46:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0205e48:	fd4fa06f          	j	ffffffffc020061c <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0205e4c:	000ad617          	auipc	a2,0xad
ffffffffc0205e50:	8fc60613          	addi	a2,a2,-1796 # ffffffffc02b2748 <proc_list>
ffffffffc0205e54:	86b2                	mv	a3,a2
ffffffffc0205e56:	b76d                	j	ffffffffc0205e00 <schedule+0x34>
        intr_disable();
ffffffffc0205e58:	fcafa0ef          	jal	ra,ffffffffc0200622 <intr_disable>
        return 1;
ffffffffc0205e5c:	4405                	li	s0,1
ffffffffc0205e5e:	bfbd                	j	ffffffffc0205ddc <schedule+0x10>

ffffffffc0205e60 <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc0205e60:	000ad797          	auipc	a5,0xad
ffffffffc0205e64:	9707b783          	ld	a5,-1680(a5) # ffffffffc02b27d0 <current>
}
ffffffffc0205e68:	43c8                	lw	a0,4(a5)
ffffffffc0205e6a:	8082                	ret

ffffffffc0205e6c <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc0205e6c:	4501                	li	a0,0
ffffffffc0205e6e:	8082                	ret

ffffffffc0205e70 <sys_putc>:
    cputchar(c);
ffffffffc0205e70:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc0205e72:	1141                	addi	sp,sp,-16
ffffffffc0205e74:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc0205e76:	b40fa0ef          	jal	ra,ffffffffc02001b6 <cputchar>
}
ffffffffc0205e7a:	60a2                	ld	ra,8(sp)
ffffffffc0205e7c:	4501                	li	a0,0
ffffffffc0205e7e:	0141                	addi	sp,sp,16
ffffffffc0205e80:	8082                	ret

ffffffffc0205e82 <sys_kill>:
    return do_kill(pid);
ffffffffc0205e82:	4108                	lw	a0,0(a0)
ffffffffc0205e84:	c31ff06f          	j	ffffffffc0205ab4 <do_kill>

ffffffffc0205e88 <sys_yield>:
    return do_yield();
ffffffffc0205e88:	bdfff06f          	j	ffffffffc0205a66 <do_yield>

ffffffffc0205e8c <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc0205e8c:	6d14                	ld	a3,24(a0)
ffffffffc0205e8e:	6910                	ld	a2,16(a0)
ffffffffc0205e90:	650c                	ld	a1,8(a0)
ffffffffc0205e92:	6108                	ld	a0,0(a0)
ffffffffc0205e94:	ebeff06f          	j	ffffffffc0205552 <do_execve>

ffffffffc0205e98 <sys_wait>:
    return do_wait(pid, store);
ffffffffc0205e98:	650c                	ld	a1,8(a0)
ffffffffc0205e9a:	4108                	lw	a0,0(a0)
ffffffffc0205e9c:	bdbff06f          	j	ffffffffc0205a76 <do_wait>

ffffffffc0205ea0 <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc0205ea0:	000ad797          	auipc	a5,0xad
ffffffffc0205ea4:	9307b783          	ld	a5,-1744(a5) # ffffffffc02b27d0 <current>
ffffffffc0205ea8:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc0205eaa:	4501                	li	a0,0
ffffffffc0205eac:	6a0c                	ld	a1,16(a2)
ffffffffc0205eae:	e07fe06f          	j	ffffffffc0204cb4 <do_fork>

ffffffffc0205eb2 <sys_exit>:
    return do_exit(error_code);
ffffffffc0205eb2:	4108                	lw	a0,0(a0)
ffffffffc0205eb4:	a5eff06f          	j	ffffffffc0205112 <do_exit>

ffffffffc0205eb8 <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc0205eb8:	715d                	addi	sp,sp,-80
ffffffffc0205eba:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc0205ebc:	000ad497          	auipc	s1,0xad
ffffffffc0205ec0:	91448493          	addi	s1,s1,-1772 # ffffffffc02b27d0 <current>
ffffffffc0205ec4:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc0205ec6:	e0a2                	sd	s0,64(sp)
ffffffffc0205ec8:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc0205eca:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc0205ecc:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0205ece:	47fd                	li	a5,31
    int num = tf->gpr.a0;
ffffffffc0205ed0:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0205ed4:	0327ee63          	bltu	a5,s2,ffffffffc0205f10 <syscall+0x58>
        if (syscalls[num] != NULL) {
ffffffffc0205ed8:	00391713          	slli	a4,s2,0x3
ffffffffc0205edc:	00002797          	auipc	a5,0x2
ffffffffc0205ee0:	76c78793          	addi	a5,a5,1900 # ffffffffc0208648 <syscalls>
ffffffffc0205ee4:	97ba                	add	a5,a5,a4
ffffffffc0205ee6:	639c                	ld	a5,0(a5)
ffffffffc0205ee8:	c785                	beqz	a5,ffffffffc0205f10 <syscall+0x58>
            arg[0] = tf->gpr.a1;
ffffffffc0205eea:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
ffffffffc0205eec:	702c                	ld	a1,96(s0)
            arg[2] = tf->gpr.a3;
ffffffffc0205eee:	7430                	ld	a2,104(s0)
            arg[3] = tf->gpr.a4;
ffffffffc0205ef0:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc0205ef2:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc0205ef4:	e42a                	sd	a0,8(sp)
            arg[1] = tf->gpr.a2;
ffffffffc0205ef6:	e82e                	sd	a1,16(sp)
            arg[2] = tf->gpr.a3;
ffffffffc0205ef8:	ec32                	sd	a2,24(sp)
            arg[3] = tf->gpr.a4;
ffffffffc0205efa:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc0205efc:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc0205efe:	0028                	addi	a0,sp,8
ffffffffc0205f00:	9782                	jalr	a5
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc0205f02:	60a6                	ld	ra,72(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc0205f04:	e828                	sd	a0,80(s0)
}
ffffffffc0205f06:	6406                	ld	s0,64(sp)
ffffffffc0205f08:	74e2                	ld	s1,56(sp)
ffffffffc0205f0a:	7942                	ld	s2,48(sp)
ffffffffc0205f0c:	6161                	addi	sp,sp,80
ffffffffc0205f0e:	8082                	ret
    print_trapframe(tf);
ffffffffc0205f10:	8522                	mv	a0,s0
ffffffffc0205f12:	8fffa0ef          	jal	ra,ffffffffc0200810 <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc0205f16:	609c                	ld	a5,0(s1)
ffffffffc0205f18:	86ca                	mv	a3,s2
ffffffffc0205f1a:	00002617          	auipc	a2,0x2
ffffffffc0205f1e:	6e660613          	addi	a2,a2,1766 # ffffffffc0208600 <default_pmm_manager+0x14c8>
ffffffffc0205f22:	43d8                	lw	a4,4(a5)
ffffffffc0205f24:	06200593          	li	a1,98
ffffffffc0205f28:	0b478793          	addi	a5,a5,180
ffffffffc0205f2c:	00002517          	auipc	a0,0x2
ffffffffc0205f30:	70450513          	addi	a0,a0,1796 # ffffffffc0208630 <default_pmm_manager+0x14f8>
ffffffffc0205f34:	d46fa0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0205f38 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc0205f38:	9e3707b7          	lui	a5,0x9e370
ffffffffc0205f3c:	2785                	addiw	a5,a5,1
ffffffffc0205f3e:	02a7853b          	mulw	a0,a5,a0
    return (hash >> (32 - bits));
ffffffffc0205f42:	02000793          	li	a5,32
ffffffffc0205f46:	9f8d                	subw	a5,a5,a1
}
ffffffffc0205f48:	00f5553b          	srlw	a0,a0,a5
ffffffffc0205f4c:	8082                	ret

ffffffffc0205f4e <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0205f4e:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0205f52:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0205f54:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0205f58:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0205f5a:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0205f5e:	f022                	sd	s0,32(sp)
ffffffffc0205f60:	ec26                	sd	s1,24(sp)
ffffffffc0205f62:	e84a                	sd	s2,16(sp)
ffffffffc0205f64:	f406                	sd	ra,40(sp)
ffffffffc0205f66:	e44e                	sd	s3,8(sp)
ffffffffc0205f68:	84aa                	mv	s1,a0
ffffffffc0205f6a:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0205f6c:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0205f70:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0205f72:	03067e63          	bgeu	a2,a6,ffffffffc0205fae <printnum+0x60>
ffffffffc0205f76:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0205f78:	00805763          	blez	s0,ffffffffc0205f86 <printnum+0x38>
ffffffffc0205f7c:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0205f7e:	85ca                	mv	a1,s2
ffffffffc0205f80:	854e                	mv	a0,s3
ffffffffc0205f82:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0205f84:	fc65                	bnez	s0,ffffffffc0205f7c <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0205f86:	1a02                	slli	s4,s4,0x20
ffffffffc0205f88:	00002797          	auipc	a5,0x2
ffffffffc0205f8c:	7c078793          	addi	a5,a5,1984 # ffffffffc0208748 <syscalls+0x100>
ffffffffc0205f90:	020a5a13          	srli	s4,s4,0x20
ffffffffc0205f94:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc0205f96:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0205f98:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0205f9c:	70a2                	ld	ra,40(sp)
ffffffffc0205f9e:	69a2                	ld	s3,8(sp)
ffffffffc0205fa0:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0205fa2:	85ca                	mv	a1,s2
ffffffffc0205fa4:	87a6                	mv	a5,s1
}
ffffffffc0205fa6:	6942                	ld	s2,16(sp)
ffffffffc0205fa8:	64e2                	ld	s1,24(sp)
ffffffffc0205faa:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0205fac:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0205fae:	03065633          	divu	a2,a2,a6
ffffffffc0205fb2:	8722                	mv	a4,s0
ffffffffc0205fb4:	f9bff0ef          	jal	ra,ffffffffc0205f4e <printnum>
ffffffffc0205fb8:	b7f9                	j	ffffffffc0205f86 <printnum+0x38>

ffffffffc0205fba <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0205fba:	7119                	addi	sp,sp,-128
ffffffffc0205fbc:	f4a6                	sd	s1,104(sp)
ffffffffc0205fbe:	f0ca                	sd	s2,96(sp)
ffffffffc0205fc0:	ecce                	sd	s3,88(sp)
ffffffffc0205fc2:	e8d2                	sd	s4,80(sp)
ffffffffc0205fc4:	e4d6                	sd	s5,72(sp)
ffffffffc0205fc6:	e0da                	sd	s6,64(sp)
ffffffffc0205fc8:	fc5e                	sd	s7,56(sp)
ffffffffc0205fca:	f06a                	sd	s10,32(sp)
ffffffffc0205fcc:	fc86                	sd	ra,120(sp)
ffffffffc0205fce:	f8a2                	sd	s0,112(sp)
ffffffffc0205fd0:	f862                	sd	s8,48(sp)
ffffffffc0205fd2:	f466                	sd	s9,40(sp)
ffffffffc0205fd4:	ec6e                	sd	s11,24(sp)
ffffffffc0205fd6:	892a                	mv	s2,a0
ffffffffc0205fd8:	84ae                	mv	s1,a1
ffffffffc0205fda:	8d32                	mv	s10,a2
ffffffffc0205fdc:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0205fde:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0205fe2:	5b7d                	li	s6,-1
ffffffffc0205fe4:	00002a97          	auipc	s5,0x2
ffffffffc0205fe8:	790a8a93          	addi	s5,s5,1936 # ffffffffc0208774 <syscalls+0x12c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0205fec:	00003b97          	auipc	s7,0x3
ffffffffc0205ff0:	9a4b8b93          	addi	s7,s7,-1628 # ffffffffc0208990 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0205ff4:	000d4503          	lbu	a0,0(s10)
ffffffffc0205ff8:	001d0413          	addi	s0,s10,1
ffffffffc0205ffc:	01350a63          	beq	a0,s3,ffffffffc0206010 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0206000:	c121                	beqz	a0,ffffffffc0206040 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0206002:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206004:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0206006:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206008:	fff44503          	lbu	a0,-1(s0)
ffffffffc020600c:	ff351ae3          	bne	a0,s3,ffffffffc0206000 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206010:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0206014:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0206018:	4c81                	li	s9,0
ffffffffc020601a:	4881                	li	a7,0
        width = precision = -1;
ffffffffc020601c:	5c7d                	li	s8,-1
ffffffffc020601e:	5dfd                	li	s11,-1
ffffffffc0206020:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0206024:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206026:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020602a:	0ff5f593          	zext.b	a1,a1
ffffffffc020602e:	00140d13          	addi	s10,s0,1
ffffffffc0206032:	04b56263          	bltu	a0,a1,ffffffffc0206076 <vprintfmt+0xbc>
ffffffffc0206036:	058a                	slli	a1,a1,0x2
ffffffffc0206038:	95d6                	add	a1,a1,s5
ffffffffc020603a:	4194                	lw	a3,0(a1)
ffffffffc020603c:	96d6                	add	a3,a3,s5
ffffffffc020603e:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0206040:	70e6                	ld	ra,120(sp)
ffffffffc0206042:	7446                	ld	s0,112(sp)
ffffffffc0206044:	74a6                	ld	s1,104(sp)
ffffffffc0206046:	7906                	ld	s2,96(sp)
ffffffffc0206048:	69e6                	ld	s3,88(sp)
ffffffffc020604a:	6a46                	ld	s4,80(sp)
ffffffffc020604c:	6aa6                	ld	s5,72(sp)
ffffffffc020604e:	6b06                	ld	s6,64(sp)
ffffffffc0206050:	7be2                	ld	s7,56(sp)
ffffffffc0206052:	7c42                	ld	s8,48(sp)
ffffffffc0206054:	7ca2                	ld	s9,40(sp)
ffffffffc0206056:	7d02                	ld	s10,32(sp)
ffffffffc0206058:	6de2                	ld	s11,24(sp)
ffffffffc020605a:	6109                	addi	sp,sp,128
ffffffffc020605c:	8082                	ret
            padc = '0';
ffffffffc020605e:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0206060:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206064:	846a                	mv	s0,s10
ffffffffc0206066:	00140d13          	addi	s10,s0,1
ffffffffc020606a:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020606e:	0ff5f593          	zext.b	a1,a1
ffffffffc0206072:	fcb572e3          	bgeu	a0,a1,ffffffffc0206036 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0206076:	85a6                	mv	a1,s1
ffffffffc0206078:	02500513          	li	a0,37
ffffffffc020607c:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc020607e:	fff44783          	lbu	a5,-1(s0)
ffffffffc0206082:	8d22                	mv	s10,s0
ffffffffc0206084:	f73788e3          	beq	a5,s3,ffffffffc0205ff4 <vprintfmt+0x3a>
ffffffffc0206088:	ffed4783          	lbu	a5,-2(s10)
ffffffffc020608c:	1d7d                	addi	s10,s10,-1
ffffffffc020608e:	ff379de3          	bne	a5,s3,ffffffffc0206088 <vprintfmt+0xce>
ffffffffc0206092:	b78d                	j	ffffffffc0205ff4 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0206094:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0206098:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020609c:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc020609e:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02060a2:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02060a6:	02d86463          	bltu	a6,a3,ffffffffc02060ce <vprintfmt+0x114>
                ch = *fmt;
ffffffffc02060aa:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02060ae:	002c169b          	slliw	a3,s8,0x2
ffffffffc02060b2:	0186873b          	addw	a4,a3,s8
ffffffffc02060b6:	0017171b          	slliw	a4,a4,0x1
ffffffffc02060ba:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc02060bc:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc02060c0:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02060c2:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc02060c6:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02060ca:	fed870e3          	bgeu	a6,a3,ffffffffc02060aa <vprintfmt+0xf0>
            if (width < 0)
ffffffffc02060ce:	f40ddce3          	bgez	s11,ffffffffc0206026 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc02060d2:	8de2                	mv	s11,s8
ffffffffc02060d4:	5c7d                	li	s8,-1
ffffffffc02060d6:	bf81                	j	ffffffffc0206026 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc02060d8:	fffdc693          	not	a3,s11
ffffffffc02060dc:	96fd                	srai	a3,a3,0x3f
ffffffffc02060de:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02060e2:	00144603          	lbu	a2,1(s0)
ffffffffc02060e6:	2d81                	sext.w	s11,s11
ffffffffc02060e8:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02060ea:	bf35                	j	ffffffffc0206026 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc02060ec:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02060f0:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02060f4:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02060f6:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc02060f8:	bfd9                	j	ffffffffc02060ce <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc02060fa:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02060fc:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0206100:	01174463          	blt	a4,a7,ffffffffc0206108 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0206104:	1a088e63          	beqz	a7,ffffffffc02062c0 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0206108:	000a3603          	ld	a2,0(s4)
ffffffffc020610c:	46c1                	li	a3,16
ffffffffc020610e:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0206110:	2781                	sext.w	a5,a5
ffffffffc0206112:	876e                	mv	a4,s11
ffffffffc0206114:	85a6                	mv	a1,s1
ffffffffc0206116:	854a                	mv	a0,s2
ffffffffc0206118:	e37ff0ef          	jal	ra,ffffffffc0205f4e <printnum>
            break;
ffffffffc020611c:	bde1                	j	ffffffffc0205ff4 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc020611e:	000a2503          	lw	a0,0(s4)
ffffffffc0206122:	85a6                	mv	a1,s1
ffffffffc0206124:	0a21                	addi	s4,s4,8
ffffffffc0206126:	9902                	jalr	s2
            break;
ffffffffc0206128:	b5f1                	j	ffffffffc0205ff4 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020612a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020612c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0206130:	01174463          	blt	a4,a7,ffffffffc0206138 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0206134:	18088163          	beqz	a7,ffffffffc02062b6 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0206138:	000a3603          	ld	a2,0(s4)
ffffffffc020613c:	46a9                	li	a3,10
ffffffffc020613e:	8a2e                	mv	s4,a1
ffffffffc0206140:	bfc1                	j	ffffffffc0206110 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206142:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0206146:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206148:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020614a:	bdf1                	j	ffffffffc0206026 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc020614c:	85a6                	mv	a1,s1
ffffffffc020614e:	02500513          	li	a0,37
ffffffffc0206152:	9902                	jalr	s2
            break;
ffffffffc0206154:	b545                	j	ffffffffc0205ff4 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206156:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc020615a:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020615c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020615e:	b5e1                	j	ffffffffc0206026 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0206160:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0206162:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0206166:	01174463          	blt	a4,a7,ffffffffc020616e <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc020616a:	14088163          	beqz	a7,ffffffffc02062ac <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc020616e:	000a3603          	ld	a2,0(s4)
ffffffffc0206172:	46a1                	li	a3,8
ffffffffc0206174:	8a2e                	mv	s4,a1
ffffffffc0206176:	bf69                	j	ffffffffc0206110 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0206178:	03000513          	li	a0,48
ffffffffc020617c:	85a6                	mv	a1,s1
ffffffffc020617e:	e03e                	sd	a5,0(sp)
ffffffffc0206180:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0206182:	85a6                	mv	a1,s1
ffffffffc0206184:	07800513          	li	a0,120
ffffffffc0206188:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020618a:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc020618c:	6782                	ld	a5,0(sp)
ffffffffc020618e:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0206190:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0206194:	bfb5                	j	ffffffffc0206110 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0206196:	000a3403          	ld	s0,0(s4)
ffffffffc020619a:	008a0713          	addi	a4,s4,8
ffffffffc020619e:	e03a                	sd	a4,0(sp)
ffffffffc02061a0:	14040263          	beqz	s0,ffffffffc02062e4 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc02061a4:	0fb05763          	blez	s11,ffffffffc0206292 <vprintfmt+0x2d8>
ffffffffc02061a8:	02d00693          	li	a3,45
ffffffffc02061ac:	0cd79163          	bne	a5,a3,ffffffffc020626e <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02061b0:	00044783          	lbu	a5,0(s0)
ffffffffc02061b4:	0007851b          	sext.w	a0,a5
ffffffffc02061b8:	cf85                	beqz	a5,ffffffffc02061f0 <vprintfmt+0x236>
ffffffffc02061ba:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02061be:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02061c2:	000c4563          	bltz	s8,ffffffffc02061cc <vprintfmt+0x212>
ffffffffc02061c6:	3c7d                	addiw	s8,s8,-1
ffffffffc02061c8:	036c0263          	beq	s8,s6,ffffffffc02061ec <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc02061cc:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02061ce:	0e0c8e63          	beqz	s9,ffffffffc02062ca <vprintfmt+0x310>
ffffffffc02061d2:	3781                	addiw	a5,a5,-32
ffffffffc02061d4:	0ef47b63          	bgeu	s0,a5,ffffffffc02062ca <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc02061d8:	03f00513          	li	a0,63
ffffffffc02061dc:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02061de:	000a4783          	lbu	a5,0(s4)
ffffffffc02061e2:	3dfd                	addiw	s11,s11,-1
ffffffffc02061e4:	0a05                	addi	s4,s4,1
ffffffffc02061e6:	0007851b          	sext.w	a0,a5
ffffffffc02061ea:	ffe1                	bnez	a5,ffffffffc02061c2 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc02061ec:	01b05963          	blez	s11,ffffffffc02061fe <vprintfmt+0x244>
ffffffffc02061f0:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02061f2:	85a6                	mv	a1,s1
ffffffffc02061f4:	02000513          	li	a0,32
ffffffffc02061f8:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02061fa:	fe0d9be3          	bnez	s11,ffffffffc02061f0 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02061fe:	6a02                	ld	s4,0(sp)
ffffffffc0206200:	bbd5                	j	ffffffffc0205ff4 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0206202:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0206204:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0206208:	01174463          	blt	a4,a7,ffffffffc0206210 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc020620c:	08088d63          	beqz	a7,ffffffffc02062a6 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0206210:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0206214:	0a044d63          	bltz	s0,ffffffffc02062ce <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0206218:	8622                	mv	a2,s0
ffffffffc020621a:	8a66                	mv	s4,s9
ffffffffc020621c:	46a9                	li	a3,10
ffffffffc020621e:	bdcd                	j	ffffffffc0206110 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0206220:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0206224:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc0206226:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0206228:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc020622c:	8fb5                	xor	a5,a5,a3
ffffffffc020622e:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0206232:	02d74163          	blt	a4,a3,ffffffffc0206254 <vprintfmt+0x29a>
ffffffffc0206236:	00369793          	slli	a5,a3,0x3
ffffffffc020623a:	97de                	add	a5,a5,s7
ffffffffc020623c:	639c                	ld	a5,0(a5)
ffffffffc020623e:	cb99                	beqz	a5,ffffffffc0206254 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0206240:	86be                	mv	a3,a5
ffffffffc0206242:	00000617          	auipc	a2,0x0
ffffffffc0206246:	1ce60613          	addi	a2,a2,462 # ffffffffc0206410 <etext+0x2e>
ffffffffc020624a:	85a6                	mv	a1,s1
ffffffffc020624c:	854a                	mv	a0,s2
ffffffffc020624e:	0ce000ef          	jal	ra,ffffffffc020631c <printfmt>
ffffffffc0206252:	b34d                	j	ffffffffc0205ff4 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0206254:	00002617          	auipc	a2,0x2
ffffffffc0206258:	51460613          	addi	a2,a2,1300 # ffffffffc0208768 <syscalls+0x120>
ffffffffc020625c:	85a6                	mv	a1,s1
ffffffffc020625e:	854a                	mv	a0,s2
ffffffffc0206260:	0bc000ef          	jal	ra,ffffffffc020631c <printfmt>
ffffffffc0206264:	bb41                	j	ffffffffc0205ff4 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0206266:	00002417          	auipc	s0,0x2
ffffffffc020626a:	4fa40413          	addi	s0,s0,1274 # ffffffffc0208760 <syscalls+0x118>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020626e:	85e2                	mv	a1,s8
ffffffffc0206270:	8522                	mv	a0,s0
ffffffffc0206272:	e43e                	sd	a5,8(sp)
ffffffffc0206274:	0e2000ef          	jal	ra,ffffffffc0206356 <strnlen>
ffffffffc0206278:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020627c:	01b05b63          	blez	s11,ffffffffc0206292 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0206280:	67a2                	ld	a5,8(sp)
ffffffffc0206282:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0206286:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0206288:	85a6                	mv	a1,s1
ffffffffc020628a:	8552                	mv	a0,s4
ffffffffc020628c:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020628e:	fe0d9ce3          	bnez	s11,ffffffffc0206286 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206292:	00044783          	lbu	a5,0(s0)
ffffffffc0206296:	00140a13          	addi	s4,s0,1
ffffffffc020629a:	0007851b          	sext.w	a0,a5
ffffffffc020629e:	d3a5                	beqz	a5,ffffffffc02061fe <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02062a0:	05e00413          	li	s0,94
ffffffffc02062a4:	bf39                	j	ffffffffc02061c2 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc02062a6:	000a2403          	lw	s0,0(s4)
ffffffffc02062aa:	b7ad                	j	ffffffffc0206214 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc02062ac:	000a6603          	lwu	a2,0(s4)
ffffffffc02062b0:	46a1                	li	a3,8
ffffffffc02062b2:	8a2e                	mv	s4,a1
ffffffffc02062b4:	bdb1                	j	ffffffffc0206110 <vprintfmt+0x156>
ffffffffc02062b6:	000a6603          	lwu	a2,0(s4)
ffffffffc02062ba:	46a9                	li	a3,10
ffffffffc02062bc:	8a2e                	mv	s4,a1
ffffffffc02062be:	bd89                	j	ffffffffc0206110 <vprintfmt+0x156>
ffffffffc02062c0:	000a6603          	lwu	a2,0(s4)
ffffffffc02062c4:	46c1                	li	a3,16
ffffffffc02062c6:	8a2e                	mv	s4,a1
ffffffffc02062c8:	b5a1                	j	ffffffffc0206110 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc02062ca:	9902                	jalr	s2
ffffffffc02062cc:	bf09                	j	ffffffffc02061de <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc02062ce:	85a6                	mv	a1,s1
ffffffffc02062d0:	02d00513          	li	a0,45
ffffffffc02062d4:	e03e                	sd	a5,0(sp)
ffffffffc02062d6:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02062d8:	6782                	ld	a5,0(sp)
ffffffffc02062da:	8a66                	mv	s4,s9
ffffffffc02062dc:	40800633          	neg	a2,s0
ffffffffc02062e0:	46a9                	li	a3,10
ffffffffc02062e2:	b53d                	j	ffffffffc0206110 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc02062e4:	03b05163          	blez	s11,ffffffffc0206306 <vprintfmt+0x34c>
ffffffffc02062e8:	02d00693          	li	a3,45
ffffffffc02062ec:	f6d79de3          	bne	a5,a3,ffffffffc0206266 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc02062f0:	00002417          	auipc	s0,0x2
ffffffffc02062f4:	47040413          	addi	s0,s0,1136 # ffffffffc0208760 <syscalls+0x118>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02062f8:	02800793          	li	a5,40
ffffffffc02062fc:	02800513          	li	a0,40
ffffffffc0206300:	00140a13          	addi	s4,s0,1
ffffffffc0206304:	bd6d                	j	ffffffffc02061be <vprintfmt+0x204>
ffffffffc0206306:	00002a17          	auipc	s4,0x2
ffffffffc020630a:	45ba0a13          	addi	s4,s4,1115 # ffffffffc0208761 <syscalls+0x119>
ffffffffc020630e:	02800513          	li	a0,40
ffffffffc0206312:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0206316:	05e00413          	li	s0,94
ffffffffc020631a:	b565                	j	ffffffffc02061c2 <vprintfmt+0x208>

ffffffffc020631c <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020631c:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc020631e:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0206322:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0206324:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0206326:	ec06                	sd	ra,24(sp)
ffffffffc0206328:	f83a                	sd	a4,48(sp)
ffffffffc020632a:	fc3e                	sd	a5,56(sp)
ffffffffc020632c:	e0c2                	sd	a6,64(sp)
ffffffffc020632e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0206330:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0206332:	c89ff0ef          	jal	ra,ffffffffc0205fba <vprintfmt>
}
ffffffffc0206336:	60e2                	ld	ra,24(sp)
ffffffffc0206338:	6161                	addi	sp,sp,80
ffffffffc020633a:	8082                	ret

ffffffffc020633c <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc020633c:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0206340:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0206342:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0206344:	cb81                	beqz	a5,ffffffffc0206354 <strlen+0x18>
        cnt ++;
ffffffffc0206346:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0206348:	00a707b3          	add	a5,a4,a0
ffffffffc020634c:	0007c783          	lbu	a5,0(a5)
ffffffffc0206350:	fbfd                	bnez	a5,ffffffffc0206346 <strlen+0xa>
ffffffffc0206352:	8082                	ret
    }
    return cnt;
}
ffffffffc0206354:	8082                	ret

ffffffffc0206356 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0206356:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0206358:	e589                	bnez	a1,ffffffffc0206362 <strnlen+0xc>
ffffffffc020635a:	a811                	j	ffffffffc020636e <strnlen+0x18>
        cnt ++;
ffffffffc020635c:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc020635e:	00f58863          	beq	a1,a5,ffffffffc020636e <strnlen+0x18>
ffffffffc0206362:	00f50733          	add	a4,a0,a5
ffffffffc0206366:	00074703          	lbu	a4,0(a4)
ffffffffc020636a:	fb6d                	bnez	a4,ffffffffc020635c <strnlen+0x6>
ffffffffc020636c:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc020636e:	852e                	mv	a0,a1
ffffffffc0206370:	8082                	ret

ffffffffc0206372 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0206372:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0206374:	0005c703          	lbu	a4,0(a1)
ffffffffc0206378:	0785                	addi	a5,a5,1
ffffffffc020637a:	0585                	addi	a1,a1,1
ffffffffc020637c:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0206380:	fb75                	bnez	a4,ffffffffc0206374 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0206382:	8082                	ret

ffffffffc0206384 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0206384:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0206388:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020638c:	cb89                	beqz	a5,ffffffffc020639e <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc020638e:	0505                	addi	a0,a0,1
ffffffffc0206390:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0206392:	fee789e3          	beq	a5,a4,ffffffffc0206384 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0206396:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc020639a:	9d19                	subw	a0,a0,a4
ffffffffc020639c:	8082                	ret
ffffffffc020639e:	4501                	li	a0,0
ffffffffc02063a0:	bfed                	j	ffffffffc020639a <strcmp+0x16>

ffffffffc02063a2 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02063a2:	00054783          	lbu	a5,0(a0)
ffffffffc02063a6:	c799                	beqz	a5,ffffffffc02063b4 <strchr+0x12>
        if (*s == c) {
ffffffffc02063a8:	00f58763          	beq	a1,a5,ffffffffc02063b6 <strchr+0x14>
    while (*s != '\0') {
ffffffffc02063ac:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc02063b0:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02063b2:	fbfd                	bnez	a5,ffffffffc02063a8 <strchr+0x6>
    }
    return NULL;
ffffffffc02063b4:	4501                	li	a0,0
}
ffffffffc02063b6:	8082                	ret

ffffffffc02063b8 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02063b8:	ca01                	beqz	a2,ffffffffc02063c8 <memset+0x10>
ffffffffc02063ba:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02063bc:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02063be:	0785                	addi	a5,a5,1
ffffffffc02063c0:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02063c4:	fec79de3          	bne	a5,a2,ffffffffc02063be <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02063c8:	8082                	ret

ffffffffc02063ca <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc02063ca:	ca19                	beqz	a2,ffffffffc02063e0 <memcpy+0x16>
ffffffffc02063cc:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc02063ce:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc02063d0:	0005c703          	lbu	a4,0(a1)
ffffffffc02063d4:	0585                	addi	a1,a1,1
ffffffffc02063d6:	0785                	addi	a5,a5,1
ffffffffc02063d8:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc02063dc:	fec59ae3          	bne	a1,a2,ffffffffc02063d0 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc02063e0:	8082                	ret
