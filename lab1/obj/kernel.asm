
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080200000 <kern_entry>:
#include <memlayout.h>

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    la sp, bootstacktop
    80200000:	00004117          	auipc	sp,0x4
    80200004:	00010113          	mv	sp,sp

    tail kern_init
    80200008:	a009                	j	8020000a <kern_init>

000000008020000a <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);

int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
    8020000a:	00004517          	auipc	a0,0x4
    8020000e:	00650513          	addi	a0,a0,6 # 80204010 <ticks>
    80200012:	00004617          	auipc	a2,0x4
    80200016:	01e60613          	addi	a2,a2,30 # 80204030 <end>
int kern_init(void) {
    8020001a:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
    8020001c:	8e09                	sub	a2,a2,a0
    8020001e:	4581                	li	a1,0
int kern_init(void) {
    80200020:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
    80200022:	16d000ef          	jal	ra,8020098e <memset>

    cons_init();  // init the console
    80200026:	14a000ef          	jal	ra,80200170 <cons_init>

    const char *message = "(THU.CST) os is loading ...\n";
    cprintf("%s\n\n", message);
    8020002a:	00001597          	auipc	a1,0x1
    8020002e:	97658593          	addi	a1,a1,-1674 # 802009a0 <etext>
    80200032:	00001517          	auipc	a0,0x1
    80200036:	98e50513          	addi	a0,a0,-1650 # 802009c0 <etext+0x20>
    8020003a:	030000ef          	jal	ra,8020006a <cprintf>

    print_kerninfo();
    8020003e:	062000ef          	jal	ra,802000a0 <print_kerninfo>

    // grade_backtrace();

    idt_init();  // init interrupt descriptor table
    80200042:	13e000ef          	jal	ra,80200180 <idt_init>

    // rdtime in mbare mode crashes
    clock_init();  // init clock interrupt
    80200046:	0e8000ef          	jal	ra,8020012e <clock_init>

    intr_enable();  // enable irq interrupt
    8020004a:	130000ef          	jal	ra,8020017a <intr_enable>
    
    while (1)
    8020004e:	a001                	j	8020004e <kern_init+0x44>

0000000080200050 <cputch>:

/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void cputch(int c, int *cnt) {
    80200050:	1141                	addi	sp,sp,-16
    80200052:	e022                	sd	s0,0(sp)
    80200054:	e406                	sd	ra,8(sp)
    80200056:	842e                	mv	s0,a1
    cons_putc(c);
    80200058:	11a000ef          	jal	ra,80200172 <cons_putc>
    (*cnt)++;
    8020005c:	401c                	lw	a5,0(s0)
}
    8020005e:	60a2                	ld	ra,8(sp)
    (*cnt)++;
    80200060:	2785                	addiw	a5,a5,1
    80200062:	c01c                	sw	a5,0(s0)
}
    80200064:	6402                	ld	s0,0(sp)
    80200066:	0141                	addi	sp,sp,16
    80200068:	8082                	ret

000000008020006a <cprintf>:
 * cprintf - formats a string and writes it to stdout
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...) {
    8020006a:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
    8020006c:	02810313          	addi	t1,sp,40 # 80204028 <SBI_SET_TIMER>
int cprintf(const char *fmt, ...) {
    80200070:	8e2a                	mv	t3,a0
    80200072:	f42e                	sd	a1,40(sp)
    80200074:	f832                	sd	a2,48(sp)
    80200076:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200078:	00000517          	auipc	a0,0x0
    8020007c:	fd850513          	addi	a0,a0,-40 # 80200050 <cputch>
    80200080:	004c                	addi	a1,sp,4
    80200082:	869a                	mv	a3,t1
    80200084:	8672                	mv	a2,t3
int cprintf(const char *fmt, ...) {
    80200086:	ec06                	sd	ra,24(sp)
    80200088:	e0ba                	sd	a4,64(sp)
    8020008a:	e4be                	sd	a5,72(sp)
    8020008c:	e8c2                	sd	a6,80(sp)
    8020008e:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
    80200090:	e41a                	sd	t1,8(sp)
    int cnt = 0;
    80200092:	c202                	sw	zero,4(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200094:	50e000ef          	jal	ra,802005a2 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
    80200098:	60e2                	ld	ra,24(sp)
    8020009a:	4512                	lw	a0,4(sp)
    8020009c:	6125                	addi	sp,sp,96
    8020009e:	8082                	ret

00000000802000a0 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
    802000a0:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
    802000a2:	00001517          	auipc	a0,0x1
    802000a6:	92650513          	addi	a0,a0,-1754 # 802009c8 <etext+0x28>
void print_kerninfo(void) {
    802000aa:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
    802000ac:	fbfff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  entry  0x%016x (virtual)\n", kern_init);
    802000b0:	00000597          	auipc	a1,0x0
    802000b4:	f5a58593          	addi	a1,a1,-166 # 8020000a <kern_init>
    802000b8:	00001517          	auipc	a0,0x1
    802000bc:	93050513          	addi	a0,a0,-1744 # 802009e8 <etext+0x48>
    802000c0:	fabff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  etext  0x%016x (virtual)\n", etext);
    802000c4:	00001597          	auipc	a1,0x1
    802000c8:	8dc58593          	addi	a1,a1,-1828 # 802009a0 <etext>
    802000cc:	00001517          	auipc	a0,0x1
    802000d0:	93c50513          	addi	a0,a0,-1732 # 80200a08 <etext+0x68>
    802000d4:	f97ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  edata  0x%016x (virtual)\n", edata);
    802000d8:	00004597          	auipc	a1,0x4
    802000dc:	f3858593          	addi	a1,a1,-200 # 80204010 <ticks>
    802000e0:	00001517          	auipc	a0,0x1
    802000e4:	94850513          	addi	a0,a0,-1720 # 80200a28 <etext+0x88>
    802000e8:	f83ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  end    0x%016x (virtual)\n", end);
    802000ec:	00004597          	auipc	a1,0x4
    802000f0:	f4458593          	addi	a1,a1,-188 # 80204030 <end>
    802000f4:	00001517          	auipc	a0,0x1
    802000f8:	95450513          	addi	a0,a0,-1708 # 80200a48 <etext+0xa8>
    802000fc:	f6fff0ef          	jal	ra,8020006a <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
    80200100:	00004597          	auipc	a1,0x4
    80200104:	32f58593          	addi	a1,a1,815 # 8020442f <end+0x3ff>
    80200108:	00000797          	auipc	a5,0x0
    8020010c:	f0278793          	addi	a5,a5,-254 # 8020000a <kern_init>
    80200110:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200114:	43f7d593          	srai	a1,a5,0x3f
}
    80200118:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
    8020011a:	3ff5f593          	andi	a1,a1,1023
    8020011e:	95be                	add	a1,a1,a5
    80200120:	85a9                	srai	a1,a1,0xa
    80200122:	00001517          	auipc	a0,0x1
    80200126:	94650513          	addi	a0,a0,-1722 # 80200a68 <etext+0xc8>
}
    8020012a:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
    8020012c:	bf3d                	j	8020006a <cprintf>

000000008020012e <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    8020012e:	1141                	addi	sp,sp,-16
    80200130:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
    80200132:	02000793          	li	a5,32
    80200136:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    8020013a:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    8020013e:	67e1                	lui	a5,0x18
    80200140:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0x801e7960>
    80200144:	953e                	add	a0,a0,a5
    80200146:	7f8000ef          	jal	ra,8020093e <sbi_set_timer>
}
    8020014a:	60a2                	ld	ra,8(sp)
    ticks = 0;
    8020014c:	00004797          	auipc	a5,0x4
    80200150:	ec07b223          	sd	zero,-316(a5) # 80204010 <ticks>
    cprintf("++ setup timer interrupts\n");
    80200154:	00001517          	auipc	a0,0x1
    80200158:	94450513          	addi	a0,a0,-1724 # 80200a98 <etext+0xf8>
}
    8020015c:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
    8020015e:	b731                	j	8020006a <cprintf>

0000000080200160 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    80200160:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    80200164:	67e1                	lui	a5,0x18
    80200166:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0x801e7960>
    8020016a:	953e                	add	a0,a0,a5
    8020016c:	7d20006f          	j	8020093e <sbi_set_timer>

0000000080200170 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
    80200170:	8082                	ret

0000000080200172 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
    80200172:	0ff57513          	zext.b	a0,a0
    80200176:	7ae0006f          	j	80200924 <sbi_console_putchar>

000000008020017a <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
    8020017a:	100167f3          	csrrsi	a5,sstatus,2
    8020017e:	8082                	ret

0000000080200180 <idt_init>:
 */
void idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
    80200180:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
    80200184:	00000797          	auipc	a5,0x0
    80200188:	2fc78793          	addi	a5,a5,764 # 80200480 <__alltraps>
    8020018c:	10579073          	csrw	stvec,a5
}
    80200190:	8082                	ret

0000000080200192 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
    80200192:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
    80200194:	1141                	addi	sp,sp,-16
    80200196:	e022                	sd	s0,0(sp)
    80200198:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
    8020019a:	00001517          	auipc	a0,0x1
    8020019e:	91e50513          	addi	a0,a0,-1762 # 80200ab8 <etext+0x118>
void print_regs(struct pushregs *gpr) {
    802001a2:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001a4:	ec7ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
    802001a8:	640c                	ld	a1,8(s0)
    802001aa:	00001517          	auipc	a0,0x1
    802001ae:	92650513          	addi	a0,a0,-1754 # 80200ad0 <etext+0x130>
    802001b2:	eb9ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
    802001b6:	680c                	ld	a1,16(s0)
    802001b8:	00001517          	auipc	a0,0x1
    802001bc:	93050513          	addi	a0,a0,-1744 # 80200ae8 <etext+0x148>
    802001c0:	eabff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
    802001c4:	6c0c                	ld	a1,24(s0)
    802001c6:	00001517          	auipc	a0,0x1
    802001ca:	93a50513          	addi	a0,a0,-1734 # 80200b00 <etext+0x160>
    802001ce:	e9dff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
    802001d2:	700c                	ld	a1,32(s0)
    802001d4:	00001517          	auipc	a0,0x1
    802001d8:	94450513          	addi	a0,a0,-1724 # 80200b18 <etext+0x178>
    802001dc:	e8fff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
    802001e0:	740c                	ld	a1,40(s0)
    802001e2:	00001517          	auipc	a0,0x1
    802001e6:	94e50513          	addi	a0,a0,-1714 # 80200b30 <etext+0x190>
    802001ea:	e81ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
    802001ee:	780c                	ld	a1,48(s0)
    802001f0:	00001517          	auipc	a0,0x1
    802001f4:	95850513          	addi	a0,a0,-1704 # 80200b48 <etext+0x1a8>
    802001f8:	e73ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
    802001fc:	7c0c                	ld	a1,56(s0)
    802001fe:	00001517          	auipc	a0,0x1
    80200202:	96250513          	addi	a0,a0,-1694 # 80200b60 <etext+0x1c0>
    80200206:	e65ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
    8020020a:	602c                	ld	a1,64(s0)
    8020020c:	00001517          	auipc	a0,0x1
    80200210:	96c50513          	addi	a0,a0,-1684 # 80200b78 <etext+0x1d8>
    80200214:	e57ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
    80200218:	642c                	ld	a1,72(s0)
    8020021a:	00001517          	auipc	a0,0x1
    8020021e:	97650513          	addi	a0,a0,-1674 # 80200b90 <etext+0x1f0>
    80200222:	e49ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
    80200226:	682c                	ld	a1,80(s0)
    80200228:	00001517          	auipc	a0,0x1
    8020022c:	98050513          	addi	a0,a0,-1664 # 80200ba8 <etext+0x208>
    80200230:	e3bff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
    80200234:	6c2c                	ld	a1,88(s0)
    80200236:	00001517          	auipc	a0,0x1
    8020023a:	98a50513          	addi	a0,a0,-1654 # 80200bc0 <etext+0x220>
    8020023e:	e2dff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
    80200242:	702c                	ld	a1,96(s0)
    80200244:	00001517          	auipc	a0,0x1
    80200248:	99450513          	addi	a0,a0,-1644 # 80200bd8 <etext+0x238>
    8020024c:	e1fff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
    80200250:	742c                	ld	a1,104(s0)
    80200252:	00001517          	auipc	a0,0x1
    80200256:	99e50513          	addi	a0,a0,-1634 # 80200bf0 <etext+0x250>
    8020025a:	e11ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
    8020025e:	782c                	ld	a1,112(s0)
    80200260:	00001517          	auipc	a0,0x1
    80200264:	9a850513          	addi	a0,a0,-1624 # 80200c08 <etext+0x268>
    80200268:	e03ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
    8020026c:	7c2c                	ld	a1,120(s0)
    8020026e:	00001517          	auipc	a0,0x1
    80200272:	9b250513          	addi	a0,a0,-1614 # 80200c20 <etext+0x280>
    80200276:	df5ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
    8020027a:	604c                	ld	a1,128(s0)
    8020027c:	00001517          	auipc	a0,0x1
    80200280:	9bc50513          	addi	a0,a0,-1604 # 80200c38 <etext+0x298>
    80200284:	de7ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
    80200288:	644c                	ld	a1,136(s0)
    8020028a:	00001517          	auipc	a0,0x1
    8020028e:	9c650513          	addi	a0,a0,-1594 # 80200c50 <etext+0x2b0>
    80200292:	dd9ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
    80200296:	684c                	ld	a1,144(s0)
    80200298:	00001517          	auipc	a0,0x1
    8020029c:	9d050513          	addi	a0,a0,-1584 # 80200c68 <etext+0x2c8>
    802002a0:	dcbff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
    802002a4:	6c4c                	ld	a1,152(s0)
    802002a6:	00001517          	auipc	a0,0x1
    802002aa:	9da50513          	addi	a0,a0,-1574 # 80200c80 <etext+0x2e0>
    802002ae:	dbdff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
    802002b2:	704c                	ld	a1,160(s0)
    802002b4:	00001517          	auipc	a0,0x1
    802002b8:	9e450513          	addi	a0,a0,-1564 # 80200c98 <etext+0x2f8>
    802002bc:	dafff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
    802002c0:	744c                	ld	a1,168(s0)
    802002c2:	00001517          	auipc	a0,0x1
    802002c6:	9ee50513          	addi	a0,a0,-1554 # 80200cb0 <etext+0x310>
    802002ca:	da1ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
    802002ce:	784c                	ld	a1,176(s0)
    802002d0:	00001517          	auipc	a0,0x1
    802002d4:	9f850513          	addi	a0,a0,-1544 # 80200cc8 <etext+0x328>
    802002d8:	d93ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
    802002dc:	7c4c                	ld	a1,184(s0)
    802002de:	00001517          	auipc	a0,0x1
    802002e2:	a0250513          	addi	a0,a0,-1534 # 80200ce0 <etext+0x340>
    802002e6:	d85ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
    802002ea:	606c                	ld	a1,192(s0)
    802002ec:	00001517          	auipc	a0,0x1
    802002f0:	a0c50513          	addi	a0,a0,-1524 # 80200cf8 <etext+0x358>
    802002f4:	d77ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
    802002f8:	646c                	ld	a1,200(s0)
    802002fa:	00001517          	auipc	a0,0x1
    802002fe:	a1650513          	addi	a0,a0,-1514 # 80200d10 <etext+0x370>
    80200302:	d69ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
    80200306:	686c                	ld	a1,208(s0)
    80200308:	00001517          	auipc	a0,0x1
    8020030c:	a2050513          	addi	a0,a0,-1504 # 80200d28 <etext+0x388>
    80200310:	d5bff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
    80200314:	6c6c                	ld	a1,216(s0)
    80200316:	00001517          	auipc	a0,0x1
    8020031a:	a2a50513          	addi	a0,a0,-1494 # 80200d40 <etext+0x3a0>
    8020031e:	d4dff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
    80200322:	706c                	ld	a1,224(s0)
    80200324:	00001517          	auipc	a0,0x1
    80200328:	a3450513          	addi	a0,a0,-1484 # 80200d58 <etext+0x3b8>
    8020032c:	d3fff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
    80200330:	746c                	ld	a1,232(s0)
    80200332:	00001517          	auipc	a0,0x1
    80200336:	a3e50513          	addi	a0,a0,-1474 # 80200d70 <etext+0x3d0>
    8020033a:	d31ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
    8020033e:	786c                	ld	a1,240(s0)
    80200340:	00001517          	auipc	a0,0x1
    80200344:	a4850513          	addi	a0,a0,-1464 # 80200d88 <etext+0x3e8>
    80200348:	d23ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
    8020034c:	7c6c                	ld	a1,248(s0)
}
    8020034e:	6402                	ld	s0,0(sp)
    80200350:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200352:	00001517          	auipc	a0,0x1
    80200356:	a4e50513          	addi	a0,a0,-1458 # 80200da0 <etext+0x400>
}
    8020035a:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
    8020035c:	b339                	j	8020006a <cprintf>

000000008020035e <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
    8020035e:	1141                	addi	sp,sp,-16
    80200360:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
    80200362:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
    80200364:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
    80200366:	00001517          	auipc	a0,0x1
    8020036a:	a5250513          	addi	a0,a0,-1454 # 80200db8 <etext+0x418>
void print_trapframe(struct trapframe *tf) {
    8020036e:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
    80200370:	cfbff0ef          	jal	ra,8020006a <cprintf>
    print_regs(&tf->gpr);
    80200374:	8522                	mv	a0,s0
    80200376:	e1dff0ef          	jal	ra,80200192 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
    8020037a:	10043583          	ld	a1,256(s0)
    8020037e:	00001517          	auipc	a0,0x1
    80200382:	a5250513          	addi	a0,a0,-1454 # 80200dd0 <etext+0x430>
    80200386:	ce5ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
    8020038a:	10843583          	ld	a1,264(s0)
    8020038e:	00001517          	auipc	a0,0x1
    80200392:	a5a50513          	addi	a0,a0,-1446 # 80200de8 <etext+0x448>
    80200396:	cd5ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    8020039a:	11043583          	ld	a1,272(s0)
    8020039e:	00001517          	auipc	a0,0x1
    802003a2:	a6250513          	addi	a0,a0,-1438 # 80200e00 <etext+0x460>
    802003a6:	cc5ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
    802003aa:	11843583          	ld	a1,280(s0)
}
    802003ae:	6402                	ld	s0,0(sp)
    802003b0:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
    802003b2:	00001517          	auipc	a0,0x1
    802003b6:	a6650513          	addi	a0,a0,-1434 # 80200e18 <etext+0x478>
}
    802003ba:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
    802003bc:	b17d                	j	8020006a <cprintf>

00000000802003be <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    802003be:	11853783          	ld	a5,280(a0)
    802003c2:	472d                	li	a4,11
    802003c4:	0786                	slli	a5,a5,0x1
    802003c6:	8385                	srli	a5,a5,0x1
    802003c8:	06f76963          	bltu	a4,a5,8020043a <interrupt_handler+0x7c>
    802003cc:	00001717          	auipc	a4,0x1
    802003d0:	b1470713          	addi	a4,a4,-1260 # 80200ee0 <etext+0x540>
    802003d4:	078a                	slli	a5,a5,0x2
    802003d6:	97ba                	add	a5,a5,a4
    802003d8:	439c                	lw	a5,0(a5)
    802003da:	97ba                	add	a5,a5,a4
    802003dc:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
    802003de:	00001517          	auipc	a0,0x1
    802003e2:	ab250513          	addi	a0,a0,-1358 # 80200e90 <etext+0x4f0>
    802003e6:	b151                	j	8020006a <cprintf>
            cprintf("Hypervisor software interrupt\n");
    802003e8:	00001517          	auipc	a0,0x1
    802003ec:	a8850513          	addi	a0,a0,-1400 # 80200e70 <etext+0x4d0>
    802003f0:	b9ad                	j	8020006a <cprintf>
            cprintf("User software interrupt\n");
    802003f2:	00001517          	auipc	a0,0x1
    802003f6:	a3e50513          	addi	a0,a0,-1474 # 80200e30 <etext+0x490>
    802003fa:	b985                	j	8020006a <cprintf>
            cprintf("Supervisor software interrupt\n");
    802003fc:	00001517          	auipc	a0,0x1
    80200400:	a5450513          	addi	a0,a0,-1452 # 80200e50 <etext+0x4b0>
    80200404:	b19d                	j	8020006a <cprintf>
void interrupt_handler(struct trapframe *tf) {
    80200406:	1141                	addi	sp,sp,-16
    80200408:	e406                	sd	ra,8(sp)
    8020040a:	e022                	sd	s0,0(sp)
             *(2)计数器（ticks）加一
             *(3)当计数器加到100的时候，我们会输出一个`100ticks`表示我们触发了100次时钟中断，同时打印次数（num）加一
            * (4)判断打印次数，当打印次数为10时，调用<sbi.h>中的关机函数关机
            */
            // (1) 设置下次时钟中断
            clock_set_next_event();
    8020040c:	d55ff0ef          	jal	ra,80200160 <clock_set_next_event>

            // (2) 计数器（ticks）加一
            static int ticks = 0;
            ticks++;
    80200410:	00004697          	auipc	a3,0x4
    80200414:	c1068693          	addi	a3,a3,-1008 # 80204020 <ticks.0>
    80200418:	429c                	lw	a5,0(a3)

            // (3) 当计数器加到 100 的时候，输出 "100 ticks"，并打印次数加一
            if (ticks % 100 == 0)
    8020041a:	06400713          	li	a4,100
            ticks++;
    8020041e:	2785                	addiw	a5,a5,1
            if (ticks % 100 == 0)
    80200420:	02e7e73b          	remw	a4,a5,a4
            ticks++;
    80200424:	c29c                	sw	a5,0(a3)
            if (ticks % 100 == 0)
    80200426:	cb19                	beqz	a4,8020043c <interrupt_handler+0x7e>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    80200428:	60a2                	ld	ra,8(sp)
    8020042a:	6402                	ld	s0,0(sp)
    8020042c:	0141                	addi	sp,sp,16
    8020042e:	8082                	ret
            cprintf("Supervisor external interrupt\n");
    80200430:	00001517          	auipc	a0,0x1
    80200434:	a9050513          	addi	a0,a0,-1392 # 80200ec0 <etext+0x520>
    80200438:	b90d                	j	8020006a <cprintf>
            print_trapframe(tf);
    8020043a:	b715                	j	8020035e <print_trapframe>
                num++; // 全局变量，记录打印次数
    8020043c:	00004417          	auipc	s0,0x4
    80200440:	bdc40413          	addi	s0,s0,-1060 # 80204018 <num>
    80200444:	601c                	ld	a5,0(s0)
    cprintf("%d ticks\n", TICK_NUM);
    80200446:	06400593          	li	a1,100
    8020044a:	00001517          	auipc	a0,0x1
    8020044e:	a6650513          	addi	a0,a0,-1434 # 80200eb0 <etext+0x510>
                num++; // 全局变量，记录打印次数
    80200452:	0785                	addi	a5,a5,1
    80200454:	e01c                	sd	a5,0(s0)
    cprintf("%d ticks\n", TICK_NUM);
    80200456:	c15ff0ef          	jal	ra,8020006a <cprintf>
                if (num == 10)
    8020045a:	6018                	ld	a4,0(s0)
    8020045c:	47a9                	li	a5,10
    8020045e:	fcf715e3          	bne	a4,a5,80200428 <interrupt_handler+0x6a>
}
    80200462:	6402                	ld	s0,0(sp)
    80200464:	60a2                	ld	ra,8(sp)
    80200466:	0141                	addi	sp,sp,16
                    sbi_shutdown();
    80200468:	a9c5                	j	80200958 <sbi_shutdown>

000000008020046a <trap>:
    }
}

/* trap_dispatch - dispatch based on what type of trap occurred */
static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
    8020046a:	11853783          	ld	a5,280(a0)
    8020046e:	0007c763          	bltz	a5,8020047c <trap+0x12>
    switch (tf->cause) {
    80200472:	472d                	li	a4,11
    80200474:	00f76363          	bltu	a4,a5,8020047a <trap+0x10>
 * trap - handles or dispatches an exception/interrupt. if and when trap()
 * returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) { trap_dispatch(tf); }
    80200478:	8082                	ret
            print_trapframe(tf);
    8020047a:	b5d5                	j	8020035e <print_trapframe>
        interrupt_handler(tf);
    8020047c:	b789                	j	802003be <interrupt_handler>
	...

0000000080200480 <__alltraps>:
    .endm

    .globl __alltraps
.align(2)
__alltraps:
    SAVE_ALL
    80200480:	14011073          	csrw	sscratch,sp
    80200484:	712d                	addi	sp,sp,-288
    80200486:	e002                	sd	zero,0(sp)
    80200488:	e406                	sd	ra,8(sp)
    8020048a:	ec0e                	sd	gp,24(sp)
    8020048c:	f012                	sd	tp,32(sp)
    8020048e:	f416                	sd	t0,40(sp)
    80200490:	f81a                	sd	t1,48(sp)
    80200492:	fc1e                	sd	t2,56(sp)
    80200494:	e0a2                	sd	s0,64(sp)
    80200496:	e4a6                	sd	s1,72(sp)
    80200498:	e8aa                	sd	a0,80(sp)
    8020049a:	ecae                	sd	a1,88(sp)
    8020049c:	f0b2                	sd	a2,96(sp)
    8020049e:	f4b6                	sd	a3,104(sp)
    802004a0:	f8ba                	sd	a4,112(sp)
    802004a2:	fcbe                	sd	a5,120(sp)
    802004a4:	e142                	sd	a6,128(sp)
    802004a6:	e546                	sd	a7,136(sp)
    802004a8:	e94a                	sd	s2,144(sp)
    802004aa:	ed4e                	sd	s3,152(sp)
    802004ac:	f152                	sd	s4,160(sp)
    802004ae:	f556                	sd	s5,168(sp)
    802004b0:	f95a                	sd	s6,176(sp)
    802004b2:	fd5e                	sd	s7,184(sp)
    802004b4:	e1e2                	sd	s8,192(sp)
    802004b6:	e5e6                	sd	s9,200(sp)
    802004b8:	e9ea                	sd	s10,208(sp)
    802004ba:	edee                	sd	s11,216(sp)
    802004bc:	f1f2                	sd	t3,224(sp)
    802004be:	f5f6                	sd	t4,232(sp)
    802004c0:	f9fa                	sd	t5,240(sp)
    802004c2:	fdfe                	sd	t6,248(sp)
    802004c4:	14001473          	csrrw	s0,sscratch,zero
    802004c8:	100024f3          	csrr	s1,sstatus
    802004cc:	14102973          	csrr	s2,sepc
    802004d0:	143029f3          	csrr	s3,stval
    802004d4:	14202a73          	csrr	s4,scause
    802004d8:	e822                	sd	s0,16(sp)
    802004da:	e226                	sd	s1,256(sp)
    802004dc:	e64a                	sd	s2,264(sp)
    802004de:	ea4e                	sd	s3,272(sp)
    802004e0:	ee52                	sd	s4,280(sp)

    move  a0, sp
    802004e2:	850a                	mv	a0,sp
    jal trap
    802004e4:	f87ff0ef          	jal	ra,8020046a <trap>

00000000802004e8 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
    802004e8:	6492                	ld	s1,256(sp)
    802004ea:	6932                	ld	s2,264(sp)
    802004ec:	10049073          	csrw	sstatus,s1
    802004f0:	14191073          	csrw	sepc,s2
    802004f4:	60a2                	ld	ra,8(sp)
    802004f6:	61e2                	ld	gp,24(sp)
    802004f8:	7202                	ld	tp,32(sp)
    802004fa:	72a2                	ld	t0,40(sp)
    802004fc:	7342                	ld	t1,48(sp)
    802004fe:	73e2                	ld	t2,56(sp)
    80200500:	6406                	ld	s0,64(sp)
    80200502:	64a6                	ld	s1,72(sp)
    80200504:	6546                	ld	a0,80(sp)
    80200506:	65e6                	ld	a1,88(sp)
    80200508:	7606                	ld	a2,96(sp)
    8020050a:	76a6                	ld	a3,104(sp)
    8020050c:	7746                	ld	a4,112(sp)
    8020050e:	77e6                	ld	a5,120(sp)
    80200510:	680a                	ld	a6,128(sp)
    80200512:	68aa                	ld	a7,136(sp)
    80200514:	694a                	ld	s2,144(sp)
    80200516:	69ea                	ld	s3,152(sp)
    80200518:	7a0a                	ld	s4,160(sp)
    8020051a:	7aaa                	ld	s5,168(sp)
    8020051c:	7b4a                	ld	s6,176(sp)
    8020051e:	7bea                	ld	s7,184(sp)
    80200520:	6c0e                	ld	s8,192(sp)
    80200522:	6cae                	ld	s9,200(sp)
    80200524:	6d4e                	ld	s10,208(sp)
    80200526:	6dee                	ld	s11,216(sp)
    80200528:	7e0e                	ld	t3,224(sp)
    8020052a:	7eae                	ld	t4,232(sp)
    8020052c:	7f4e                	ld	t5,240(sp)
    8020052e:	7fee                	ld	t6,248(sp)
    80200530:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
    80200532:	10200073          	sret

0000000080200536 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
    80200536:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    8020053a:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
    8020053c:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    80200540:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
    80200542:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
    80200546:	f022                	sd	s0,32(sp)
    80200548:	ec26                	sd	s1,24(sp)
    8020054a:	e84a                	sd	s2,16(sp)
    8020054c:	f406                	sd	ra,40(sp)
    8020054e:	e44e                	sd	s3,8(sp)
    80200550:	84aa                	mv	s1,a0
    80200552:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
    80200554:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
    80200558:	2a01                	sext.w	s4,s4
    if (num >= base) {
    8020055a:	03067e63          	bgeu	a2,a6,80200596 <printnum+0x60>
    8020055e:	89be                	mv	s3,a5
        while (-- width > 0)
    80200560:	00805763          	blez	s0,8020056e <printnum+0x38>
    80200564:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
    80200566:	85ca                	mv	a1,s2
    80200568:	854e                	mv	a0,s3
    8020056a:	9482                	jalr	s1
        while (-- width > 0)
    8020056c:	fc65                	bnez	s0,80200564 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
    8020056e:	1a02                	slli	s4,s4,0x20
    80200570:	00001797          	auipc	a5,0x1
    80200574:	9a078793          	addi	a5,a5,-1632 # 80200f10 <etext+0x570>
    80200578:	020a5a13          	srli	s4,s4,0x20
    8020057c:	9a3e                	add	s4,s4,a5
}
    8020057e:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
    80200580:	000a4503          	lbu	a0,0(s4)
}
    80200584:	70a2                	ld	ra,40(sp)
    80200586:	69a2                	ld	s3,8(sp)
    80200588:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
    8020058a:	85ca                	mv	a1,s2
    8020058c:	87a6                	mv	a5,s1
}
    8020058e:	6942                	ld	s2,16(sp)
    80200590:	64e2                	ld	s1,24(sp)
    80200592:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
    80200594:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
    80200596:	03065633          	divu	a2,a2,a6
    8020059a:	8722                	mv	a4,s0
    8020059c:	f9bff0ef          	jal	ra,80200536 <printnum>
    802005a0:	b7f9                	j	8020056e <printnum+0x38>

00000000802005a2 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
    802005a2:	7119                	addi	sp,sp,-128
    802005a4:	f4a6                	sd	s1,104(sp)
    802005a6:	f0ca                	sd	s2,96(sp)
    802005a8:	ecce                	sd	s3,88(sp)
    802005aa:	e8d2                	sd	s4,80(sp)
    802005ac:	e4d6                	sd	s5,72(sp)
    802005ae:	e0da                	sd	s6,64(sp)
    802005b0:	fc5e                	sd	s7,56(sp)
    802005b2:	f06a                	sd	s10,32(sp)
    802005b4:	fc86                	sd	ra,120(sp)
    802005b6:	f8a2                	sd	s0,112(sp)
    802005b8:	f862                	sd	s8,48(sp)
    802005ba:	f466                	sd	s9,40(sp)
    802005bc:	ec6e                	sd	s11,24(sp)
    802005be:	892a                	mv	s2,a0
    802005c0:	84ae                	mv	s1,a1
    802005c2:	8d32                	mv	s10,a2
    802005c4:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802005c6:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
    802005ca:	5b7d                	li	s6,-1
    802005cc:	00001a97          	auipc	s5,0x1
    802005d0:	978a8a93          	addi	s5,s5,-1672 # 80200f44 <etext+0x5a4>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    802005d4:	00001b97          	auipc	s7,0x1
    802005d8:	b4cb8b93          	addi	s7,s7,-1204 # 80201120 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802005dc:	000d4503          	lbu	a0,0(s10)
    802005e0:	001d0413          	addi	s0,s10,1
    802005e4:	01350a63          	beq	a0,s3,802005f8 <vprintfmt+0x56>
            if (ch == '\0') {
    802005e8:	c121                	beqz	a0,80200628 <vprintfmt+0x86>
            putch(ch, putdat);
    802005ea:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802005ec:	0405                	addi	s0,s0,1
            putch(ch, putdat);
    802005ee:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802005f0:	fff44503          	lbu	a0,-1(s0)
    802005f4:	ff351ae3          	bne	a0,s3,802005e8 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
    802005f8:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
    802005fc:	02000793          	li	a5,32
        lflag = altflag = 0;
    80200600:	4c81                	li	s9,0
    80200602:	4881                	li	a7,0
        width = precision = -1;
    80200604:	5c7d                	li	s8,-1
    80200606:	5dfd                	li	s11,-1
    80200608:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
    8020060c:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
    8020060e:	fdd6059b          	addiw	a1,a2,-35
    80200612:	0ff5f593          	zext.b	a1,a1
    80200616:	00140d13          	addi	s10,s0,1
    8020061a:	04b56263          	bltu	a0,a1,8020065e <vprintfmt+0xbc>
    8020061e:	058a                	slli	a1,a1,0x2
    80200620:	95d6                	add	a1,a1,s5
    80200622:	4194                	lw	a3,0(a1)
    80200624:	96d6                	add	a3,a3,s5
    80200626:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
    80200628:	70e6                	ld	ra,120(sp)
    8020062a:	7446                	ld	s0,112(sp)
    8020062c:	74a6                	ld	s1,104(sp)
    8020062e:	7906                	ld	s2,96(sp)
    80200630:	69e6                	ld	s3,88(sp)
    80200632:	6a46                	ld	s4,80(sp)
    80200634:	6aa6                	ld	s5,72(sp)
    80200636:	6b06                	ld	s6,64(sp)
    80200638:	7be2                	ld	s7,56(sp)
    8020063a:	7c42                	ld	s8,48(sp)
    8020063c:	7ca2                	ld	s9,40(sp)
    8020063e:	7d02                	ld	s10,32(sp)
    80200640:	6de2                	ld	s11,24(sp)
    80200642:	6109                	addi	sp,sp,128
    80200644:	8082                	ret
            padc = '0';
    80200646:	87b2                	mv	a5,a2
            goto reswitch;
    80200648:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    8020064c:	846a                	mv	s0,s10
    8020064e:	00140d13          	addi	s10,s0,1
    80200652:	fdd6059b          	addiw	a1,a2,-35
    80200656:	0ff5f593          	zext.b	a1,a1
    8020065a:	fcb572e3          	bgeu	a0,a1,8020061e <vprintfmt+0x7c>
            putch('%', putdat);
    8020065e:	85a6                	mv	a1,s1
    80200660:	02500513          	li	a0,37
    80200664:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
    80200666:	fff44783          	lbu	a5,-1(s0)
    8020066a:	8d22                	mv	s10,s0
    8020066c:	f73788e3          	beq	a5,s3,802005dc <vprintfmt+0x3a>
    80200670:	ffed4783          	lbu	a5,-2(s10)
    80200674:	1d7d                	addi	s10,s10,-1
    80200676:	ff379de3          	bne	a5,s3,80200670 <vprintfmt+0xce>
    8020067a:	b78d                	j	802005dc <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
    8020067c:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
    80200680:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    80200684:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
    80200686:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
    8020068a:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
    8020068e:	02d86463          	bltu	a6,a3,802006b6 <vprintfmt+0x114>
                ch = *fmt;
    80200692:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
    80200696:	002c169b          	slliw	a3,s8,0x2
    8020069a:	0186873b          	addw	a4,a3,s8
    8020069e:	0017171b          	slliw	a4,a4,0x1
    802006a2:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
    802006a4:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
    802006a8:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
    802006aa:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
    802006ae:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
    802006b2:	fed870e3          	bgeu	a6,a3,80200692 <vprintfmt+0xf0>
            if (width < 0)
    802006b6:	f40ddce3          	bgez	s11,8020060e <vprintfmt+0x6c>
                width = precision, precision = -1;
    802006ba:	8de2                	mv	s11,s8
    802006bc:	5c7d                	li	s8,-1
    802006be:	bf81                	j	8020060e <vprintfmt+0x6c>
            if (width < 0)
    802006c0:	fffdc693          	not	a3,s11
    802006c4:	96fd                	srai	a3,a3,0x3f
    802006c6:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
    802006ca:	00144603          	lbu	a2,1(s0)
    802006ce:	2d81                	sext.w	s11,s11
    802006d0:	846a                	mv	s0,s10
            goto reswitch;
    802006d2:	bf35                	j	8020060e <vprintfmt+0x6c>
            precision = va_arg(ap, int);
    802006d4:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
    802006d8:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
    802006dc:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
    802006de:	846a                	mv	s0,s10
            goto process_precision;
    802006e0:	bfd9                	j	802006b6 <vprintfmt+0x114>
    if (lflag >= 2) {
    802006e2:	4705                	li	a4,1
            precision = va_arg(ap, int);
    802006e4:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
    802006e8:	01174463          	blt	a4,a7,802006f0 <vprintfmt+0x14e>
    else if (lflag) {
    802006ec:	1a088e63          	beqz	a7,802008a8 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
    802006f0:	000a3603          	ld	a2,0(s4)
    802006f4:	46c1                	li	a3,16
    802006f6:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
    802006f8:	2781                	sext.w	a5,a5
    802006fa:	876e                	mv	a4,s11
    802006fc:	85a6                	mv	a1,s1
    802006fe:	854a                	mv	a0,s2
    80200700:	e37ff0ef          	jal	ra,80200536 <printnum>
            break;
    80200704:	bde1                	j	802005dc <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
    80200706:	000a2503          	lw	a0,0(s4)
    8020070a:	85a6                	mv	a1,s1
    8020070c:	0a21                	addi	s4,s4,8
    8020070e:	9902                	jalr	s2
            break;
    80200710:	b5f1                	j	802005dc <vprintfmt+0x3a>
    if (lflag >= 2) {
    80200712:	4705                	li	a4,1
            precision = va_arg(ap, int);
    80200714:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
    80200718:	01174463          	blt	a4,a7,80200720 <vprintfmt+0x17e>
    else if (lflag) {
    8020071c:	18088163          	beqz	a7,8020089e <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
    80200720:	000a3603          	ld	a2,0(s4)
    80200724:	46a9                	li	a3,10
    80200726:	8a2e                	mv	s4,a1
    80200728:	bfc1                	j	802006f8 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
    8020072a:	00144603          	lbu	a2,1(s0)
            altflag = 1;
    8020072e:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
    80200730:	846a                	mv	s0,s10
            goto reswitch;
    80200732:	bdf1                	j	8020060e <vprintfmt+0x6c>
            putch(ch, putdat);
    80200734:	85a6                	mv	a1,s1
    80200736:	02500513          	li	a0,37
    8020073a:	9902                	jalr	s2
            break;
    8020073c:	b545                	j	802005dc <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
    8020073e:	00144603          	lbu	a2,1(s0)
            lflag ++;
    80200742:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
    80200744:	846a                	mv	s0,s10
            goto reswitch;
    80200746:	b5e1                	j	8020060e <vprintfmt+0x6c>
    if (lflag >= 2) {
    80200748:	4705                	li	a4,1
            precision = va_arg(ap, int);
    8020074a:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
    8020074e:	01174463          	blt	a4,a7,80200756 <vprintfmt+0x1b4>
    else if (lflag) {
    80200752:	14088163          	beqz	a7,80200894 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
    80200756:	000a3603          	ld	a2,0(s4)
    8020075a:	46a1                	li	a3,8
    8020075c:	8a2e                	mv	s4,a1
    8020075e:	bf69                	j	802006f8 <vprintfmt+0x156>
            putch('0', putdat);
    80200760:	03000513          	li	a0,48
    80200764:	85a6                	mv	a1,s1
    80200766:	e03e                	sd	a5,0(sp)
    80200768:	9902                	jalr	s2
            putch('x', putdat);
    8020076a:	85a6                	mv	a1,s1
    8020076c:	07800513          	li	a0,120
    80200770:	9902                	jalr	s2
            num = (unsigned long long)va_arg(ap, void *);
    80200772:	0a21                	addi	s4,s4,8
            goto number;
    80200774:	6782                	ld	a5,0(sp)
    80200776:	46c1                	li	a3,16
            num = (unsigned long long)va_arg(ap, void *);
    80200778:	ff8a3603          	ld	a2,-8(s4)
            goto number;
    8020077c:	bfb5                	j	802006f8 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
    8020077e:	000a3403          	ld	s0,0(s4)
    80200782:	008a0713          	addi	a4,s4,8
    80200786:	e03a                	sd	a4,0(sp)
    80200788:	14040263          	beqz	s0,802008cc <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
    8020078c:	0fb05763          	blez	s11,8020087a <vprintfmt+0x2d8>
    80200790:	02d00693          	li	a3,45
    80200794:	0cd79163          	bne	a5,a3,80200856 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200798:	00044783          	lbu	a5,0(s0)
    8020079c:	0007851b          	sext.w	a0,a5
    802007a0:	cf85                	beqz	a5,802007d8 <vprintfmt+0x236>
    802007a2:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
    802007a6:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802007aa:	000c4563          	bltz	s8,802007b4 <vprintfmt+0x212>
    802007ae:	3c7d                	addiw	s8,s8,-1
    802007b0:	036c0263          	beq	s8,s6,802007d4 <vprintfmt+0x232>
                    putch('?', putdat);
    802007b4:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
    802007b6:	0e0c8e63          	beqz	s9,802008b2 <vprintfmt+0x310>
    802007ba:	3781                	addiw	a5,a5,-32
    802007bc:	0ef47b63          	bgeu	s0,a5,802008b2 <vprintfmt+0x310>
                    putch('?', putdat);
    802007c0:	03f00513          	li	a0,63
    802007c4:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802007c6:	000a4783          	lbu	a5,0(s4)
    802007ca:	3dfd                	addiw	s11,s11,-1
    802007cc:	0a05                	addi	s4,s4,1
    802007ce:	0007851b          	sext.w	a0,a5
    802007d2:	ffe1                	bnez	a5,802007aa <vprintfmt+0x208>
            for (; width > 0; width --) {
    802007d4:	01b05963          	blez	s11,802007e6 <vprintfmt+0x244>
    802007d8:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    802007da:	85a6                	mv	a1,s1
    802007dc:	02000513          	li	a0,32
    802007e0:	9902                	jalr	s2
            for (; width > 0; width --) {
    802007e2:	fe0d9be3          	bnez	s11,802007d8 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
    802007e6:	6a02                	ld	s4,0(sp)
    802007e8:	bbd5                	j	802005dc <vprintfmt+0x3a>
    if (lflag >= 2) {
    802007ea:	4705                	li	a4,1
            precision = va_arg(ap, int);
    802007ec:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
    802007f0:	01174463          	blt	a4,a7,802007f8 <vprintfmt+0x256>
    else if (lflag) {
    802007f4:	08088d63          	beqz	a7,8020088e <vprintfmt+0x2ec>
        return va_arg(*ap, long);
    802007f8:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
    802007fc:	0a044d63          	bltz	s0,802008b6 <vprintfmt+0x314>
            num = getint(&ap, lflag);
    80200800:	8622                	mv	a2,s0
    80200802:	8a66                	mv	s4,s9
    80200804:	46a9                	li	a3,10
    80200806:	bdcd                	j	802006f8 <vprintfmt+0x156>
            err = va_arg(ap, int);
    80200808:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    8020080c:	4719                	li	a4,6
            err = va_arg(ap, int);
    8020080e:	0a21                	addi	s4,s4,8
            if (err < 0) {
    80200810:	41f7d69b          	sraiw	a3,a5,0x1f
    80200814:	8fb5                	xor	a5,a5,a3
    80200816:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    8020081a:	02d74163          	blt	a4,a3,8020083c <vprintfmt+0x29a>
    8020081e:	00369793          	slli	a5,a3,0x3
    80200822:	97de                	add	a5,a5,s7
    80200824:	639c                	ld	a5,0(a5)
    80200826:	cb99                	beqz	a5,8020083c <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
    80200828:	86be                	mv	a3,a5
    8020082a:	00000617          	auipc	a2,0x0
    8020082e:	71660613          	addi	a2,a2,1814 # 80200f40 <etext+0x5a0>
    80200832:	85a6                	mv	a1,s1
    80200834:	854a                	mv	a0,s2
    80200836:	0ce000ef          	jal	ra,80200904 <printfmt>
    8020083a:	b34d                	j	802005dc <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
    8020083c:	00000617          	auipc	a2,0x0
    80200840:	6f460613          	addi	a2,a2,1780 # 80200f30 <etext+0x590>
    80200844:	85a6                	mv	a1,s1
    80200846:	854a                	mv	a0,s2
    80200848:	0bc000ef          	jal	ra,80200904 <printfmt>
    8020084c:	bb41                	j	802005dc <vprintfmt+0x3a>
                p = "(null)";
    8020084e:	00000417          	auipc	s0,0x0
    80200852:	6da40413          	addi	s0,s0,1754 # 80200f28 <etext+0x588>
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200856:	85e2                	mv	a1,s8
    80200858:	8522                	mv	a0,s0
    8020085a:	e43e                	sd	a5,8(sp)
    8020085c:	116000ef          	jal	ra,80200972 <strnlen>
    80200860:	40ad8dbb          	subw	s11,s11,a0
    80200864:	01b05b63          	blez	s11,8020087a <vprintfmt+0x2d8>
                    putch(padc, putdat);
    80200868:	67a2                	ld	a5,8(sp)
    8020086a:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
    8020086e:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
    80200870:	85a6                	mv	a1,s1
    80200872:	8552                	mv	a0,s4
    80200874:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200876:	fe0d9ce3          	bnez	s11,8020086e <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    8020087a:	00044783          	lbu	a5,0(s0)
    8020087e:	00140a13          	addi	s4,s0,1
    80200882:	0007851b          	sext.w	a0,a5
    80200886:	d3a5                	beqz	a5,802007e6 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
    80200888:	05e00413          	li	s0,94
    8020088c:	bf39                	j	802007aa <vprintfmt+0x208>
        return va_arg(*ap, int);
    8020088e:	000a2403          	lw	s0,0(s4)
    80200892:	b7ad                	j	802007fc <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
    80200894:	000a6603          	lwu	a2,0(s4)
    80200898:	46a1                	li	a3,8
    8020089a:	8a2e                	mv	s4,a1
    8020089c:	bdb1                	j	802006f8 <vprintfmt+0x156>
    8020089e:	000a6603          	lwu	a2,0(s4)
    802008a2:	46a9                	li	a3,10
    802008a4:	8a2e                	mv	s4,a1
    802008a6:	bd89                	j	802006f8 <vprintfmt+0x156>
    802008a8:	000a6603          	lwu	a2,0(s4)
    802008ac:	46c1                	li	a3,16
    802008ae:	8a2e                	mv	s4,a1
    802008b0:	b5a1                	j	802006f8 <vprintfmt+0x156>
                    putch(ch, putdat);
    802008b2:	9902                	jalr	s2
    802008b4:	bf09                	j	802007c6 <vprintfmt+0x224>
                putch('-', putdat);
    802008b6:	85a6                	mv	a1,s1
    802008b8:	02d00513          	li	a0,45
    802008bc:	e03e                	sd	a5,0(sp)
    802008be:	9902                	jalr	s2
                num = -(long long)num;
    802008c0:	6782                	ld	a5,0(sp)
    802008c2:	8a66                	mv	s4,s9
    802008c4:	40800633          	neg	a2,s0
    802008c8:	46a9                	li	a3,10
    802008ca:	b53d                	j	802006f8 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
    802008cc:	03b05163          	blez	s11,802008ee <vprintfmt+0x34c>
    802008d0:	02d00693          	li	a3,45
    802008d4:	f6d79de3          	bne	a5,a3,8020084e <vprintfmt+0x2ac>
                p = "(null)";
    802008d8:	00000417          	auipc	s0,0x0
    802008dc:	65040413          	addi	s0,s0,1616 # 80200f28 <etext+0x588>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802008e0:	02800793          	li	a5,40
    802008e4:	02800513          	li	a0,40
    802008e8:	00140a13          	addi	s4,s0,1
    802008ec:	bd6d                	j	802007a6 <vprintfmt+0x204>
    802008ee:	00000a17          	auipc	s4,0x0
    802008f2:	63ba0a13          	addi	s4,s4,1595 # 80200f29 <etext+0x589>
    802008f6:	02800513          	li	a0,40
    802008fa:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
    802008fe:	05e00413          	li	s0,94
    80200902:	b565                	j	802007aa <vprintfmt+0x208>

0000000080200904 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200904:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
    80200906:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    8020090a:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
    8020090c:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    8020090e:	ec06                	sd	ra,24(sp)
    80200910:	f83a                	sd	a4,48(sp)
    80200912:	fc3e                	sd	a5,56(sp)
    80200914:	e0c2                	sd	a6,64(sp)
    80200916:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
    80200918:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
    8020091a:	c89ff0ef          	jal	ra,802005a2 <vprintfmt>
}
    8020091e:	60e2                	ld	ra,24(sp)
    80200920:	6161                	addi	sp,sp,80
    80200922:	8082                	ret

0000000080200924 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
    80200924:	4781                	li	a5,0
    80200926:	00003717          	auipc	a4,0x3
    8020092a:	6da73703          	ld	a4,1754(a4) # 80204000 <SBI_CONSOLE_PUTCHAR>
    8020092e:	88ba                	mv	a7,a4
    80200930:	852a                	mv	a0,a0
    80200932:	85be                	mv	a1,a5
    80200934:	863e                	mv	a2,a5
    80200936:	00000073          	ecall
    8020093a:	87aa                	mv	a5,a0
int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
    8020093c:	8082                	ret

000000008020093e <sbi_set_timer>:
    __asm__ volatile (
    8020093e:	4781                	li	a5,0
    80200940:	00003717          	auipc	a4,0x3
    80200944:	6e873703          	ld	a4,1768(a4) # 80204028 <SBI_SET_TIMER>
    80200948:	88ba                	mv	a7,a4
    8020094a:	852a                	mv	a0,a0
    8020094c:	85be                	mv	a1,a5
    8020094e:	863e                	mv	a2,a5
    80200950:	00000073          	ecall
    80200954:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
    80200956:	8082                	ret

0000000080200958 <sbi_shutdown>:
    __asm__ volatile (
    80200958:	4781                	li	a5,0
    8020095a:	00003717          	auipc	a4,0x3
    8020095e:	6ae73703          	ld	a4,1710(a4) # 80204008 <SBI_SHUTDOWN>
    80200962:	88ba                	mv	a7,a4
    80200964:	853e                	mv	a0,a5
    80200966:	85be                	mv	a1,a5
    80200968:	863e                	mv	a2,a5
    8020096a:	00000073          	ecall
    8020096e:	87aa                	mv	a5,a0


void sbi_shutdown(void)
{
    sbi_call(SBI_SHUTDOWN,0,0,0);
    80200970:	8082                	ret

0000000080200972 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    80200972:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
    80200974:	e589                	bnez	a1,8020097e <strnlen+0xc>
    80200976:	a811                	j	8020098a <strnlen+0x18>
        cnt ++;
    80200978:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
    8020097a:	00f58863          	beq	a1,a5,8020098a <strnlen+0x18>
    8020097e:	00f50733          	add	a4,a0,a5
    80200982:	00074703          	lbu	a4,0(a4)
    80200986:	fb6d                	bnez	a4,80200978 <strnlen+0x6>
    80200988:	85be                	mv	a1,a5
    }
    return cnt;
}
    8020098a:	852e                	mv	a0,a1
    8020098c:	8082                	ret

000000008020098e <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
    8020098e:	ca01                	beqz	a2,8020099e <memset+0x10>
    80200990:	962a                	add	a2,a2,a0
    char *p = s;
    80200992:	87aa                	mv	a5,a0
        *p ++ = c;
    80200994:	0785                	addi	a5,a5,1
    80200996:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
    8020099a:	fec79de3          	bne	a5,a2,80200994 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
    8020099e:	8082                	ret
