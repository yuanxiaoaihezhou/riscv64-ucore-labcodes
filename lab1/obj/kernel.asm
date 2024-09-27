
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080200000 <kern_entry>:
    80200000:	00004117          	auipc	sp,0x4
    80200004:	00010113          	mv	sp,sp
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
    80200022:	1f5000ef          	jal	ra,80200a16 <memset>

    cons_init();  // init the console
    80200026:	154000ef          	jal	ra,8020017a <cons_init>

    const char *message = "(THU.CST) os is loading ...\n";
    cprintf("%s\n\n", message);
    8020002a:	00001597          	auipc	a1,0x1
    8020002e:	9fe58593          	addi	a1,a1,-1538 # 80200a28 <etext>
    80200032:	00001517          	auipc	a0,0x1
    80200036:	a1650513          	addi	a0,a0,-1514 # 80200a48 <etext+0x20>
    8020003a:	03a000ef          	jal	ra,80200074 <cprintf>

    print_kerninfo();
    8020003e:	06c000ef          	jal	ra,802000aa <print_kerninfo>

    // grade_backtrace();

    idt_init();  // init interrupt descriptor table
    80200042:	148000ef          	jal	ra,8020018a <idt_init>

    // rdtime in mbare mode crashes
    clock_init();  // init clock interrupt
    80200046:	0f2000ef          	jal	ra,80200138 <clock_init>

    intr_enable();  // enable irq interrupt
    8020004a:	13a000ef          	jal	ra,80200184 <intr_enable>
    
    asm("mret");
    8020004e:	30200073          	mret
    asm("ebreak");
    80200052:	9002                	ebreak
    asm("mret");
    80200054:	30200073          	mret

    while (1)
    80200058:	a001                	j	80200058 <kern_init+0x4e>

000000008020005a <cputch>:
    8020005a:	1141                	addi	sp,sp,-16
    8020005c:	e022                	sd	s0,0(sp)
    8020005e:	e406                	sd	ra,8(sp)
    80200060:	842e                	mv	s0,a1
    80200062:	11a000ef          	jal	ra,8020017c <cons_putc>
    80200066:	401c                	lw	a5,0(s0)
    80200068:	60a2                	ld	ra,8(sp)
    8020006a:	2785                	addiw	a5,a5,1
    8020006c:	c01c                	sw	a5,0(s0)
    8020006e:	6402                	ld	s0,0(sp)
    80200070:	0141                	addi	sp,sp,16
    80200072:	8082                	ret

0000000080200074 <cprintf>:
    80200074:	711d                	addi	sp,sp,-96
    80200076:	02810313          	addi	t1,sp,40 # 80204028 <SBI_SET_TIMER>
    8020007a:	8e2a                	mv	t3,a0
    8020007c:	f42e                	sd	a1,40(sp)
    8020007e:	f832                	sd	a2,48(sp)
    80200080:	fc36                	sd	a3,56(sp)
    80200082:	00000517          	auipc	a0,0x0
    80200086:	fd850513          	addi	a0,a0,-40 # 8020005a <cputch>
    8020008a:	004c                	addi	a1,sp,4
    8020008c:	869a                	mv	a3,t1
    8020008e:	8672                	mv	a2,t3
    80200090:	ec06                	sd	ra,24(sp)
    80200092:	e0ba                	sd	a4,64(sp)
    80200094:	e4be                	sd	a5,72(sp)
    80200096:	e8c2                	sd	a6,80(sp)
    80200098:	ecc6                	sd	a7,88(sp)
    8020009a:	e41a                	sd	t1,8(sp)
    8020009c:	c202                	sw	zero,4(sp)
    8020009e:	58c000ef          	jal	ra,8020062a <vprintfmt>
    802000a2:	60e2                	ld	ra,24(sp)
    802000a4:	4512                	lw	a0,4(sp)
    802000a6:	6125                	addi	sp,sp,96
    802000a8:	8082                	ret

00000000802000aa <print_kerninfo>:
    802000aa:	1141                	addi	sp,sp,-16
    802000ac:	00001517          	auipc	a0,0x1
    802000b0:	9a450513          	addi	a0,a0,-1628 # 80200a50 <etext+0x28>
    802000b4:	e406                	sd	ra,8(sp)
    802000b6:	fbfff0ef          	jal	ra,80200074 <cprintf>
    802000ba:	00000597          	auipc	a1,0x0
    802000be:	f5058593          	addi	a1,a1,-176 # 8020000a <kern_init>
    802000c2:	00001517          	auipc	a0,0x1
    802000c6:	9ae50513          	addi	a0,a0,-1618 # 80200a70 <etext+0x48>
    802000ca:	fabff0ef          	jal	ra,80200074 <cprintf>
    802000ce:	00001597          	auipc	a1,0x1
    802000d2:	95a58593          	addi	a1,a1,-1702 # 80200a28 <etext>
    802000d6:	00001517          	auipc	a0,0x1
    802000da:	9ba50513          	addi	a0,a0,-1606 # 80200a90 <etext+0x68>
    802000de:	f97ff0ef          	jal	ra,80200074 <cprintf>
    802000e2:	00004597          	auipc	a1,0x4
    802000e6:	f2e58593          	addi	a1,a1,-210 # 80204010 <ticks>
    802000ea:	00001517          	auipc	a0,0x1
    802000ee:	9c650513          	addi	a0,a0,-1594 # 80200ab0 <etext+0x88>
    802000f2:	f83ff0ef          	jal	ra,80200074 <cprintf>
    802000f6:	00004597          	auipc	a1,0x4
    802000fa:	f3a58593          	addi	a1,a1,-198 # 80204030 <end>
    802000fe:	00001517          	auipc	a0,0x1
    80200102:	9d250513          	addi	a0,a0,-1582 # 80200ad0 <etext+0xa8>
    80200106:	f6fff0ef          	jal	ra,80200074 <cprintf>
    8020010a:	00004597          	auipc	a1,0x4
    8020010e:	32558593          	addi	a1,a1,805 # 8020442f <end+0x3ff>
    80200112:	00000797          	auipc	a5,0x0
    80200116:	ef878793          	addi	a5,a5,-264 # 8020000a <kern_init>
    8020011a:	40f587b3          	sub	a5,a1,a5
    8020011e:	43f7d593          	srai	a1,a5,0x3f
    80200122:	60a2                	ld	ra,8(sp)
    80200124:	3ff5f593          	andi	a1,a1,1023
    80200128:	95be                	add	a1,a1,a5
    8020012a:	85a9                	srai	a1,a1,0xa
    8020012c:	00001517          	auipc	a0,0x1
    80200130:	9c450513          	addi	a0,a0,-1596 # 80200af0 <etext+0xc8>
    80200134:	0141                	addi	sp,sp,16
    80200136:	bf3d                	j	80200074 <cprintf>

0000000080200138 <clock_init>:
    80200138:	1141                	addi	sp,sp,-16
    8020013a:	e406                	sd	ra,8(sp)
    8020013c:	02000793          	li	a5,32
    80200140:	1047a7f3          	csrrs	a5,sie,a5
    80200144:	c0102573          	rdtime	a0
    80200148:	67e1                	lui	a5,0x18
    8020014a:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0x801e7960>
    8020014e:	953e                	add	a0,a0,a5
    80200150:	077000ef          	jal	ra,802009c6 <sbi_set_timer>
    80200154:	60a2                	ld	ra,8(sp)
    80200156:	00004797          	auipc	a5,0x4
    8020015a:	ea07bd23          	sd	zero,-326(a5) # 80204010 <ticks>
    8020015e:	00001517          	auipc	a0,0x1
    80200162:	9c250513          	addi	a0,a0,-1598 # 80200b20 <etext+0xf8>
    80200166:	0141                	addi	sp,sp,16
    80200168:	b731                	j	80200074 <cprintf>

000000008020016a <clock_set_next_event>:
    8020016a:	c0102573          	rdtime	a0
    8020016e:	67e1                	lui	a5,0x18
    80200170:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0x801e7960>
    80200174:	953e                	add	a0,a0,a5
    80200176:	0510006f          	j	802009c6 <sbi_set_timer>

000000008020017a <cons_init>:
    8020017a:	8082                	ret

000000008020017c <cons_putc>:
    8020017c:	0ff57513          	andi	a0,a0,255
    80200180:	02d0006f          	j	802009ac <sbi_console_putchar>

0000000080200184 <intr_enable>:
    80200184:	100167f3          	csrrsi	a5,sstatus,2
    80200188:	8082                	ret

000000008020018a <idt_init>:
 */
void idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
    8020018a:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
    8020018e:	00000797          	auipc	a5,0x0
    80200192:	37a78793          	addi	a5,a5,890 # 80200508 <__alltraps>
    80200196:	10579073          	csrw	stvec,a5
}
    8020019a:	8082                	ret

000000008020019c <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
    8020019c:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
    8020019e:	1141                	addi	sp,sp,-16
    802001a0:	e022                	sd	s0,0(sp)
    802001a2:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001a4:	00001517          	auipc	a0,0x1
    802001a8:	99c50513          	addi	a0,a0,-1636 # 80200b40 <etext+0x118>
void print_regs(struct pushregs *gpr) {
    802001ac:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001ae:	ec7ff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
    802001b2:	640c                	ld	a1,8(s0)
    802001b4:	00001517          	auipc	a0,0x1
    802001b8:	9a450513          	addi	a0,a0,-1628 # 80200b58 <etext+0x130>
    802001bc:	eb9ff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
    802001c0:	680c                	ld	a1,16(s0)
    802001c2:	00001517          	auipc	a0,0x1
    802001c6:	9ae50513          	addi	a0,a0,-1618 # 80200b70 <etext+0x148>
    802001ca:	eabff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
    802001ce:	6c0c                	ld	a1,24(s0)
    802001d0:	00001517          	auipc	a0,0x1
    802001d4:	9b850513          	addi	a0,a0,-1608 # 80200b88 <etext+0x160>
    802001d8:	e9dff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
    802001dc:	700c                	ld	a1,32(s0)
    802001de:	00001517          	auipc	a0,0x1
    802001e2:	9c250513          	addi	a0,a0,-1598 # 80200ba0 <etext+0x178>
    802001e6:	e8fff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
    802001ea:	740c                	ld	a1,40(s0)
    802001ec:	00001517          	auipc	a0,0x1
    802001f0:	9cc50513          	addi	a0,a0,-1588 # 80200bb8 <etext+0x190>
    802001f4:	e81ff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
    802001f8:	780c                	ld	a1,48(s0)
    802001fa:	00001517          	auipc	a0,0x1
    802001fe:	9d650513          	addi	a0,a0,-1578 # 80200bd0 <etext+0x1a8>
    80200202:	e73ff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
    80200206:	7c0c                	ld	a1,56(s0)
    80200208:	00001517          	auipc	a0,0x1
    8020020c:	9e050513          	addi	a0,a0,-1568 # 80200be8 <etext+0x1c0>
    80200210:	e65ff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
    80200214:	602c                	ld	a1,64(s0)
    80200216:	00001517          	auipc	a0,0x1
    8020021a:	9ea50513          	addi	a0,a0,-1558 # 80200c00 <etext+0x1d8>
    8020021e:	e57ff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
    80200222:	642c                	ld	a1,72(s0)
    80200224:	00001517          	auipc	a0,0x1
    80200228:	9f450513          	addi	a0,a0,-1548 # 80200c18 <etext+0x1f0>
    8020022c:	e49ff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
    80200230:	682c                	ld	a1,80(s0)
    80200232:	00001517          	auipc	a0,0x1
    80200236:	9fe50513          	addi	a0,a0,-1538 # 80200c30 <etext+0x208>
    8020023a:	e3bff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
    8020023e:	6c2c                	ld	a1,88(s0)
    80200240:	00001517          	auipc	a0,0x1
    80200244:	a0850513          	addi	a0,a0,-1528 # 80200c48 <etext+0x220>
    80200248:	e2dff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
    8020024c:	702c                	ld	a1,96(s0)
    8020024e:	00001517          	auipc	a0,0x1
    80200252:	a1250513          	addi	a0,a0,-1518 # 80200c60 <etext+0x238>
    80200256:	e1fff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
    8020025a:	742c                	ld	a1,104(s0)
    8020025c:	00001517          	auipc	a0,0x1
    80200260:	a1c50513          	addi	a0,a0,-1508 # 80200c78 <etext+0x250>
    80200264:	e11ff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
    80200268:	782c                	ld	a1,112(s0)
    8020026a:	00001517          	auipc	a0,0x1
    8020026e:	a2650513          	addi	a0,a0,-1498 # 80200c90 <etext+0x268>
    80200272:	e03ff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
    80200276:	7c2c                	ld	a1,120(s0)
    80200278:	00001517          	auipc	a0,0x1
    8020027c:	a3050513          	addi	a0,a0,-1488 # 80200ca8 <etext+0x280>
    80200280:	df5ff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
    80200284:	604c                	ld	a1,128(s0)
    80200286:	00001517          	auipc	a0,0x1
    8020028a:	a3a50513          	addi	a0,a0,-1478 # 80200cc0 <etext+0x298>
    8020028e:	de7ff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
    80200292:	644c                	ld	a1,136(s0)
    80200294:	00001517          	auipc	a0,0x1
    80200298:	a4450513          	addi	a0,a0,-1468 # 80200cd8 <etext+0x2b0>
    8020029c:	dd9ff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
    802002a0:	684c                	ld	a1,144(s0)
    802002a2:	00001517          	auipc	a0,0x1
    802002a6:	a4e50513          	addi	a0,a0,-1458 # 80200cf0 <etext+0x2c8>
    802002aa:	dcbff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
    802002ae:	6c4c                	ld	a1,152(s0)
    802002b0:	00001517          	auipc	a0,0x1
    802002b4:	a5850513          	addi	a0,a0,-1448 # 80200d08 <etext+0x2e0>
    802002b8:	dbdff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
    802002bc:	704c                	ld	a1,160(s0)
    802002be:	00001517          	auipc	a0,0x1
    802002c2:	a6250513          	addi	a0,a0,-1438 # 80200d20 <etext+0x2f8>
    802002c6:	dafff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
    802002ca:	744c                	ld	a1,168(s0)
    802002cc:	00001517          	auipc	a0,0x1
    802002d0:	a6c50513          	addi	a0,a0,-1428 # 80200d38 <etext+0x310>
    802002d4:	da1ff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
    802002d8:	784c                	ld	a1,176(s0)
    802002da:	00001517          	auipc	a0,0x1
    802002de:	a7650513          	addi	a0,a0,-1418 # 80200d50 <etext+0x328>
    802002e2:	d93ff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
    802002e6:	7c4c                	ld	a1,184(s0)
    802002e8:	00001517          	auipc	a0,0x1
    802002ec:	a8050513          	addi	a0,a0,-1408 # 80200d68 <etext+0x340>
    802002f0:	d85ff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
    802002f4:	606c                	ld	a1,192(s0)
    802002f6:	00001517          	auipc	a0,0x1
    802002fa:	a8a50513          	addi	a0,a0,-1398 # 80200d80 <etext+0x358>
    802002fe:	d77ff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
    80200302:	646c                	ld	a1,200(s0)
    80200304:	00001517          	auipc	a0,0x1
    80200308:	a9450513          	addi	a0,a0,-1388 # 80200d98 <etext+0x370>
    8020030c:	d69ff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
    80200310:	686c                	ld	a1,208(s0)
    80200312:	00001517          	auipc	a0,0x1
    80200316:	a9e50513          	addi	a0,a0,-1378 # 80200db0 <etext+0x388>
    8020031a:	d5bff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
    8020031e:	6c6c                	ld	a1,216(s0)
    80200320:	00001517          	auipc	a0,0x1
    80200324:	aa850513          	addi	a0,a0,-1368 # 80200dc8 <etext+0x3a0>
    80200328:	d4dff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
    8020032c:	706c                	ld	a1,224(s0)
    8020032e:	00001517          	auipc	a0,0x1
    80200332:	ab250513          	addi	a0,a0,-1358 # 80200de0 <etext+0x3b8>
    80200336:	d3fff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
    8020033a:	746c                	ld	a1,232(s0)
    8020033c:	00001517          	auipc	a0,0x1
    80200340:	abc50513          	addi	a0,a0,-1348 # 80200df8 <etext+0x3d0>
    80200344:	d31ff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
    80200348:	786c                	ld	a1,240(s0)
    8020034a:	00001517          	auipc	a0,0x1
    8020034e:	ac650513          	addi	a0,a0,-1338 # 80200e10 <etext+0x3e8>
    80200352:	d23ff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200356:	7c6c                	ld	a1,248(s0)
}
    80200358:	6402                	ld	s0,0(sp)
    8020035a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
    8020035c:	00001517          	auipc	a0,0x1
    80200360:	acc50513          	addi	a0,a0,-1332 # 80200e28 <etext+0x400>
}
    80200364:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200366:	b339                	j	80200074 <cprintf>

0000000080200368 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
    80200368:	1141                	addi	sp,sp,-16
    8020036a:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
    8020036c:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
    8020036e:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
    80200370:	00001517          	auipc	a0,0x1
    80200374:	ad050513          	addi	a0,a0,-1328 # 80200e40 <etext+0x418>
void print_trapframe(struct trapframe *tf) {
    80200378:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
    8020037a:	cfbff0ef          	jal	ra,80200074 <cprintf>
    print_regs(&tf->gpr);
    8020037e:	8522                	mv	a0,s0
    80200380:	e1dff0ef          	jal	ra,8020019c <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
    80200384:	10043583          	ld	a1,256(s0)
    80200388:	00001517          	auipc	a0,0x1
    8020038c:	ad050513          	addi	a0,a0,-1328 # 80200e58 <etext+0x430>
    80200390:	ce5ff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
    80200394:	10843583          	ld	a1,264(s0)
    80200398:	00001517          	auipc	a0,0x1
    8020039c:	ad850513          	addi	a0,a0,-1320 # 80200e70 <etext+0x448>
    802003a0:	cd5ff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    802003a4:	11043583          	ld	a1,272(s0)
    802003a8:	00001517          	auipc	a0,0x1
    802003ac:	ae050513          	addi	a0,a0,-1312 # 80200e88 <etext+0x460>
    802003b0:	cc5ff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
    802003b4:	11843583          	ld	a1,280(s0)
}
    802003b8:	6402                	ld	s0,0(sp)
    802003ba:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
    802003bc:	00001517          	auipc	a0,0x1
    802003c0:	ae450513          	addi	a0,a0,-1308 # 80200ea0 <etext+0x478>
}
    802003c4:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
    802003c6:	b17d                	j	80200074 <cprintf>

00000000802003c8 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    802003c8:	11853783          	ld	a5,280(a0)
    802003cc:	472d                	li	a4,11
    802003ce:	0786                	slli	a5,a5,0x1
    802003d0:	8385                	srli	a5,a5,0x1
    802003d2:	06f76963          	bltu	a4,a5,80200444 <interrupt_handler+0x7c>
    802003d6:	00001717          	auipc	a4,0x1
    802003da:	b9270713          	addi	a4,a4,-1134 # 80200f68 <etext+0x540>
    802003de:	078a                	slli	a5,a5,0x2
    802003e0:	97ba                	add	a5,a5,a4
    802003e2:	439c                	lw	a5,0(a5)
    802003e4:	97ba                	add	a5,a5,a4
    802003e6:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
    802003e8:	00001517          	auipc	a0,0x1
    802003ec:	b3050513          	addi	a0,a0,-1232 # 80200f18 <etext+0x4f0>
    802003f0:	b151                	j	80200074 <cprintf>
            cprintf("Hypervisor software interrupt\n");
    802003f2:	00001517          	auipc	a0,0x1
    802003f6:	b0650513          	addi	a0,a0,-1274 # 80200ef8 <etext+0x4d0>
    802003fa:	b9ad                	j	80200074 <cprintf>
            cprintf("User software interrupt\n");
    802003fc:	00001517          	auipc	a0,0x1
    80200400:	abc50513          	addi	a0,a0,-1348 # 80200eb8 <etext+0x490>
    80200404:	b985                	j	80200074 <cprintf>
            cprintf("Supervisor software interrupt\n");
    80200406:	00001517          	auipc	a0,0x1
    8020040a:	ad250513          	addi	a0,a0,-1326 # 80200ed8 <etext+0x4b0>
    8020040e:	b19d                	j	80200074 <cprintf>
void interrupt_handler(struct trapframe *tf) {
    80200410:	1141                	addi	sp,sp,-16
    80200412:	e406                	sd	ra,8(sp)
    80200414:	e022                	sd	s0,0(sp)
             *(2)计数器（ticks）加一
             *(3)当计数器加到100的时候，我们会输出一个`100ticks`表示我们触发了100次时钟中断，同时打印次数（num）加一
            * (4)判断打印次数，当打印次数为10时，调用<sbi.h>中的关机函数关机
            */
            // (1) 设置下次时钟中断
            clock_set_next_event();
    80200416:	d55ff0ef          	jal	ra,8020016a <clock_set_next_event>

            // (2) 计数器（ticks）加一
            static int ticks = 0;
            ticks++;
    8020041a:	00004697          	auipc	a3,0x4
    8020041e:	c0668693          	addi	a3,a3,-1018 # 80204020 <ticks.0>
    80200422:	429c                	lw	a5,0(a3)

            // (3) 当计数器加到 100 的时候，输出 "100 ticks"，并打印次数加一
            if (ticks % 100 == 0)
    80200424:	06400713          	li	a4,100
            ticks++;
    80200428:	2785                	addiw	a5,a5,1
            if (ticks % 100 == 0)
    8020042a:	02e7e73b          	remw	a4,a5,a4
            ticks++;
    8020042e:	c29c                	sw	a5,0(a3)
            if (ticks % 100 == 0)
    80200430:	cb19                	beqz	a4,80200446 <interrupt_handler+0x7e>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    80200432:	60a2                	ld	ra,8(sp)
    80200434:	6402                	ld	s0,0(sp)
    80200436:	0141                	addi	sp,sp,16
    80200438:	8082                	ret
            cprintf("Supervisor external interrupt\n");
    8020043a:	00001517          	auipc	a0,0x1
    8020043e:	b0e50513          	addi	a0,a0,-1266 # 80200f48 <etext+0x520>
    80200442:	b90d                	j	80200074 <cprintf>
            print_trapframe(tf);
    80200444:	b715                	j	80200368 <print_trapframe>
                num++; // 全局变量，记录打印次数
    80200446:	00004417          	auipc	s0,0x4
    8020044a:	bd240413          	addi	s0,s0,-1070 # 80204018 <num>
    8020044e:	601c                	ld	a5,0(s0)
    cprintf("%d ticks\n", TICK_NUM);
    80200450:	06400593          	li	a1,100
    80200454:	00001517          	auipc	a0,0x1
    80200458:	ae450513          	addi	a0,a0,-1308 # 80200f38 <etext+0x510>
                num++; // 全局变量，记录打印次数
    8020045c:	0785                	addi	a5,a5,1
    8020045e:	e01c                	sd	a5,0(s0)
    cprintf("%d ticks\n", TICK_NUM);
    80200460:	c15ff0ef          	jal	ra,80200074 <cprintf>
                if (num == 10)
    80200464:	6018                	ld	a4,0(s0)
    80200466:	47a9                	li	a5,10
    80200468:	fcf715e3          	bne	a4,a5,80200432 <interrupt_handler+0x6a>
}
    8020046c:	6402                	ld	s0,0(sp)
    8020046e:	60a2                	ld	ra,8(sp)
    80200470:	0141                	addi	sp,sp,16
                    sbi_shutdown();
    80200472:	a3bd                	j	802009e0 <sbi_shutdown>

0000000080200474 <exception_handler>:

void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
    80200474:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
    80200478:	1141                	addi	sp,sp,-16
    8020047a:	e022                	sd	s0,0(sp)
    8020047c:	e406                	sd	ra,8(sp)
    switch (tf->cause) {
    8020047e:	470d                	li	a4,3
void exception_handler(struct trapframe *tf) {
    80200480:	842a                	mv	s0,a0
    switch (tf->cause) {
    80200482:	04e78663          	beq	a5,a4,802004ce <exception_handler+0x5a>
    80200486:	02f76c63          	bltu	a4,a5,802004be <exception_handler+0x4a>
    8020048a:	4709                	li	a4,2
    8020048c:	02e79563          	bne	a5,a4,802004b6 <exception_handler+0x42>
            /* LAB1 CHALLENGE3   YOUR CODE :  2211133*/
            /*(1)输出指令异常类型（ Illegal instruction）
             *(2)输出异常指令地址
             *(3)更新 tf->epc寄存器
            */
		    cprintf("Exception Type: Illegal instruction\n");
    80200490:	00001517          	auipc	a0,0x1
    80200494:	b0850513          	addi	a0,a0,-1272 # 80200f98 <etext+0x570>
    80200498:	bddff0ef          	jal	ra,80200074 <cprintf>
			cprintf("Illegal instruction caught at %p\n", tf->epc);
    8020049c:	10843583          	ld	a1,264(s0)
    802004a0:	00001517          	auipc	a0,0x1
    802004a4:	b2050513          	addi	a0,a0,-1248 # 80200fc0 <etext+0x598>
    802004a8:	bcdff0ef          	jal	ra,80200074 <cprintf>
			tf->epc += 4;
    802004ac:	10843783          	ld	a5,264(s0)
    802004b0:	0791                	addi	a5,a5,4
    802004b2:	10f43423          	sd	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    802004b6:	60a2                	ld	ra,8(sp)
    802004b8:	6402                	ld	s0,0(sp)
    802004ba:	0141                	addi	sp,sp,16
    802004bc:	8082                	ret
    switch (tf->cause) {
    802004be:	17f1                	addi	a5,a5,-4
    802004c0:	471d                	li	a4,7
    802004c2:	fef77ae3          	bgeu	a4,a5,802004b6 <exception_handler+0x42>
}
    802004c6:	6402                	ld	s0,0(sp)
    802004c8:	60a2                	ld	ra,8(sp)
    802004ca:	0141                	addi	sp,sp,16
            print_trapframe(tf);
    802004cc:	bd71                	j	80200368 <print_trapframe>
		    cprintf("Exception Type: breakpoint\n");
    802004ce:	00001517          	auipc	a0,0x1
    802004d2:	b1a50513          	addi	a0,a0,-1254 # 80200fe8 <etext+0x5c0>
    802004d6:	b9fff0ef          	jal	ra,80200074 <cprintf>
			cprintf("ebreak caught at %p\n", tf->epc);
    802004da:	10843583          	ld	a1,264(s0)
    802004de:	00001517          	auipc	a0,0x1
    802004e2:	b2a50513          	addi	a0,a0,-1238 # 80201008 <etext+0x5e0>
    802004e6:	b8fff0ef          	jal	ra,80200074 <cprintf>
			tf->epc += 2; // 经查表ebreak为16位指令
    802004ea:	10843783          	ld	a5,264(s0)
}
    802004ee:	60a2                	ld	ra,8(sp)
			tf->epc += 2; // 经查表ebreak为16位指令
    802004f0:	0789                	addi	a5,a5,2
    802004f2:	10f43423          	sd	a5,264(s0)
}
    802004f6:	6402                	ld	s0,0(sp)
    802004f8:	0141                	addi	sp,sp,16
    802004fa:	8082                	ret

00000000802004fc <trap>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
    802004fc:	11853783          	ld	a5,280(a0)
    80200500:	0007c363          	bltz	a5,80200506 <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
    80200504:	bf85                	j	80200474 <exception_handler>
        interrupt_handler(tf);
    80200506:	b5c9                	j	802003c8 <interrupt_handler>

0000000080200508 <__alltraps>:
    80200508:	14011073          	csrw	sscratch,sp
    8020050c:	712d                	addi	sp,sp,-288
    8020050e:	e002                	sd	zero,0(sp)
    80200510:	e406                	sd	ra,8(sp)
    80200512:	ec0e                	sd	gp,24(sp)
    80200514:	f012                	sd	tp,32(sp)
    80200516:	f416                	sd	t0,40(sp)
    80200518:	f81a                	sd	t1,48(sp)
    8020051a:	fc1e                	sd	t2,56(sp)
    8020051c:	e0a2                	sd	s0,64(sp)
    8020051e:	e4a6                	sd	s1,72(sp)
    80200520:	e8aa                	sd	a0,80(sp)
    80200522:	ecae                	sd	a1,88(sp)
    80200524:	f0b2                	sd	a2,96(sp)
    80200526:	f4b6                	sd	a3,104(sp)
    80200528:	f8ba                	sd	a4,112(sp)
    8020052a:	fcbe                	sd	a5,120(sp)
    8020052c:	e142                	sd	a6,128(sp)
    8020052e:	e546                	sd	a7,136(sp)
    80200530:	e94a                	sd	s2,144(sp)
    80200532:	ed4e                	sd	s3,152(sp)
    80200534:	f152                	sd	s4,160(sp)
    80200536:	f556                	sd	s5,168(sp)
    80200538:	f95a                	sd	s6,176(sp)
    8020053a:	fd5e                	sd	s7,184(sp)
    8020053c:	e1e2                	sd	s8,192(sp)
    8020053e:	e5e6                	sd	s9,200(sp)
    80200540:	e9ea                	sd	s10,208(sp)
    80200542:	edee                	sd	s11,216(sp)
    80200544:	f1f2                	sd	t3,224(sp)
    80200546:	f5f6                	sd	t4,232(sp)
    80200548:	f9fa                	sd	t5,240(sp)
    8020054a:	fdfe                	sd	t6,248(sp)
    8020054c:	14001473          	csrrw	s0,sscratch,zero
    80200550:	100024f3          	csrr	s1,sstatus
    80200554:	14102973          	csrr	s2,sepc
    80200558:	143029f3          	csrr	s3,stval
    8020055c:	14202a73          	csrr	s4,scause
    80200560:	e822                	sd	s0,16(sp)
    80200562:	e226                	sd	s1,256(sp)
    80200564:	e64a                	sd	s2,264(sp)
    80200566:	ea4e                	sd	s3,272(sp)
    80200568:	ee52                	sd	s4,280(sp)
    8020056a:	850a                	mv	a0,sp
    8020056c:	f91ff0ef          	jal	ra,802004fc <trap>

0000000080200570 <__trapret>:
    80200570:	6492                	ld	s1,256(sp)
    80200572:	6932                	ld	s2,264(sp)
    80200574:	10049073          	csrw	sstatus,s1
    80200578:	14191073          	csrw	sepc,s2
    8020057c:	60a2                	ld	ra,8(sp)
    8020057e:	61e2                	ld	gp,24(sp)
    80200580:	7202                	ld	tp,32(sp)
    80200582:	72a2                	ld	t0,40(sp)
    80200584:	7342                	ld	t1,48(sp)
    80200586:	73e2                	ld	t2,56(sp)
    80200588:	6406                	ld	s0,64(sp)
    8020058a:	64a6                	ld	s1,72(sp)
    8020058c:	6546                	ld	a0,80(sp)
    8020058e:	65e6                	ld	a1,88(sp)
    80200590:	7606                	ld	a2,96(sp)
    80200592:	76a6                	ld	a3,104(sp)
    80200594:	7746                	ld	a4,112(sp)
    80200596:	77e6                	ld	a5,120(sp)
    80200598:	680a                	ld	a6,128(sp)
    8020059a:	68aa                	ld	a7,136(sp)
    8020059c:	694a                	ld	s2,144(sp)
    8020059e:	69ea                	ld	s3,152(sp)
    802005a0:	7a0a                	ld	s4,160(sp)
    802005a2:	7aaa                	ld	s5,168(sp)
    802005a4:	7b4a                	ld	s6,176(sp)
    802005a6:	7bea                	ld	s7,184(sp)
    802005a8:	6c0e                	ld	s8,192(sp)
    802005aa:	6cae                	ld	s9,200(sp)
    802005ac:	6d4e                	ld	s10,208(sp)
    802005ae:	6dee                	ld	s11,216(sp)
    802005b0:	7e0e                	ld	t3,224(sp)
    802005b2:	7eae                	ld	t4,232(sp)
    802005b4:	7f4e                	ld	t5,240(sp)
    802005b6:	7fee                	ld	t6,248(sp)
    802005b8:	6142                	ld	sp,16(sp)
    802005ba:	10200073          	sret

00000000802005be <printnum>:
    802005be:	02069813          	slli	a6,a3,0x20
    802005c2:	7179                	addi	sp,sp,-48
    802005c4:	02085813          	srli	a6,a6,0x20
    802005c8:	e052                	sd	s4,0(sp)
    802005ca:	03067a33          	remu	s4,a2,a6
    802005ce:	f022                	sd	s0,32(sp)
    802005d0:	ec26                	sd	s1,24(sp)
    802005d2:	e84a                	sd	s2,16(sp)
    802005d4:	f406                	sd	ra,40(sp)
    802005d6:	e44e                	sd	s3,8(sp)
    802005d8:	84aa                	mv	s1,a0
    802005da:	892e                	mv	s2,a1
    802005dc:	fff7041b          	addiw	s0,a4,-1
    802005e0:	2a01                	sext.w	s4,s4
    802005e2:	03067e63          	bgeu	a2,a6,8020061e <printnum+0x60>
    802005e6:	89be                	mv	s3,a5
    802005e8:	00805763          	blez	s0,802005f6 <printnum+0x38>
    802005ec:	347d                	addiw	s0,s0,-1
    802005ee:	85ca                	mv	a1,s2
    802005f0:	854e                	mv	a0,s3
    802005f2:	9482                	jalr	s1
    802005f4:	fc65                	bnez	s0,802005ec <printnum+0x2e>
    802005f6:	1a02                	slli	s4,s4,0x20
    802005f8:	00001797          	auipc	a5,0x1
    802005fc:	a2878793          	addi	a5,a5,-1496 # 80201020 <etext+0x5f8>
    80200600:	020a5a13          	srli	s4,s4,0x20
    80200604:	9a3e                	add	s4,s4,a5
    80200606:	7402                	ld	s0,32(sp)
    80200608:	000a4503          	lbu	a0,0(s4)
    8020060c:	70a2                	ld	ra,40(sp)
    8020060e:	69a2                	ld	s3,8(sp)
    80200610:	6a02                	ld	s4,0(sp)
    80200612:	85ca                	mv	a1,s2
    80200614:	87a6                	mv	a5,s1
    80200616:	6942                	ld	s2,16(sp)
    80200618:	64e2                	ld	s1,24(sp)
    8020061a:	6145                	addi	sp,sp,48
    8020061c:	8782                	jr	a5
    8020061e:	03065633          	divu	a2,a2,a6
    80200622:	8722                	mv	a4,s0
    80200624:	f9bff0ef          	jal	ra,802005be <printnum>
    80200628:	b7f9                	j	802005f6 <printnum+0x38>

000000008020062a <vprintfmt>:
    8020062a:	7119                	addi	sp,sp,-128
    8020062c:	f4a6                	sd	s1,104(sp)
    8020062e:	f0ca                	sd	s2,96(sp)
    80200630:	ecce                	sd	s3,88(sp)
    80200632:	e8d2                	sd	s4,80(sp)
    80200634:	e4d6                	sd	s5,72(sp)
    80200636:	e0da                	sd	s6,64(sp)
    80200638:	fc5e                	sd	s7,56(sp)
    8020063a:	f06a                	sd	s10,32(sp)
    8020063c:	fc86                	sd	ra,120(sp)
    8020063e:	f8a2                	sd	s0,112(sp)
    80200640:	f862                	sd	s8,48(sp)
    80200642:	f466                	sd	s9,40(sp)
    80200644:	ec6e                	sd	s11,24(sp)
    80200646:	892a                	mv	s2,a0
    80200648:	84ae                	mv	s1,a1
    8020064a:	8d32                	mv	s10,a2
    8020064c:	8a36                	mv	s4,a3
    8020064e:	02500993          	li	s3,37
    80200652:	5b7d                	li	s6,-1
    80200654:	00001a97          	auipc	s5,0x1
    80200658:	a00a8a93          	addi	s5,s5,-1536 # 80201054 <etext+0x62c>
    8020065c:	00001b97          	auipc	s7,0x1
    80200660:	bd4b8b93          	addi	s7,s7,-1068 # 80201230 <error_string>
    80200664:	000d4503          	lbu	a0,0(s10)
    80200668:	001d0413          	addi	s0,s10,1
    8020066c:	01350a63          	beq	a0,s3,80200680 <vprintfmt+0x56>
    80200670:	c121                	beqz	a0,802006b0 <vprintfmt+0x86>
    80200672:	85a6                	mv	a1,s1
    80200674:	0405                	addi	s0,s0,1
    80200676:	9902                	jalr	s2
    80200678:	fff44503          	lbu	a0,-1(s0)
    8020067c:	ff351ae3          	bne	a0,s3,80200670 <vprintfmt+0x46>
    80200680:	00044603          	lbu	a2,0(s0)
    80200684:	02000793          	li	a5,32
    80200688:	4c81                	li	s9,0
    8020068a:	4881                	li	a7,0
    8020068c:	5c7d                	li	s8,-1
    8020068e:	5dfd                	li	s11,-1
    80200690:	05500513          	li	a0,85
    80200694:	4825                	li	a6,9
    80200696:	fdd6059b          	addiw	a1,a2,-35
    8020069a:	0ff5f593          	andi	a1,a1,255
    8020069e:	00140d13          	addi	s10,s0,1
    802006a2:	04b56263          	bltu	a0,a1,802006e6 <vprintfmt+0xbc>
    802006a6:	058a                	slli	a1,a1,0x2
    802006a8:	95d6                	add	a1,a1,s5
    802006aa:	4194                	lw	a3,0(a1)
    802006ac:	96d6                	add	a3,a3,s5
    802006ae:	8682                	jr	a3
    802006b0:	70e6                	ld	ra,120(sp)
    802006b2:	7446                	ld	s0,112(sp)
    802006b4:	74a6                	ld	s1,104(sp)
    802006b6:	7906                	ld	s2,96(sp)
    802006b8:	69e6                	ld	s3,88(sp)
    802006ba:	6a46                	ld	s4,80(sp)
    802006bc:	6aa6                	ld	s5,72(sp)
    802006be:	6b06                	ld	s6,64(sp)
    802006c0:	7be2                	ld	s7,56(sp)
    802006c2:	7c42                	ld	s8,48(sp)
    802006c4:	7ca2                	ld	s9,40(sp)
    802006c6:	7d02                	ld	s10,32(sp)
    802006c8:	6de2                	ld	s11,24(sp)
    802006ca:	6109                	addi	sp,sp,128
    802006cc:	8082                	ret
    802006ce:	87b2                	mv	a5,a2
    802006d0:	00144603          	lbu	a2,1(s0)
    802006d4:	846a                	mv	s0,s10
    802006d6:	00140d13          	addi	s10,s0,1
    802006da:	fdd6059b          	addiw	a1,a2,-35
    802006de:	0ff5f593          	andi	a1,a1,255
    802006e2:	fcb572e3          	bgeu	a0,a1,802006a6 <vprintfmt+0x7c>
    802006e6:	85a6                	mv	a1,s1
    802006e8:	02500513          	li	a0,37
    802006ec:	9902                	jalr	s2
    802006ee:	fff44783          	lbu	a5,-1(s0)
    802006f2:	8d22                	mv	s10,s0
    802006f4:	f73788e3          	beq	a5,s3,80200664 <vprintfmt+0x3a>
    802006f8:	ffed4783          	lbu	a5,-2(s10)
    802006fc:	1d7d                	addi	s10,s10,-1
    802006fe:	ff379de3          	bne	a5,s3,802006f8 <vprintfmt+0xce>
    80200702:	b78d                	j	80200664 <vprintfmt+0x3a>
    80200704:	fd060c1b          	addiw	s8,a2,-48
    80200708:	00144603          	lbu	a2,1(s0)
    8020070c:	846a                	mv	s0,s10
    8020070e:	fd06069b          	addiw	a3,a2,-48
    80200712:	0006059b          	sext.w	a1,a2
    80200716:	02d86463          	bltu	a6,a3,8020073e <vprintfmt+0x114>
    8020071a:	00144603          	lbu	a2,1(s0)
    8020071e:	002c169b          	slliw	a3,s8,0x2
    80200722:	0186873b          	addw	a4,a3,s8
    80200726:	0017171b          	slliw	a4,a4,0x1
    8020072a:	9f2d                	addw	a4,a4,a1
    8020072c:	fd06069b          	addiw	a3,a2,-48
    80200730:	0405                	addi	s0,s0,1
    80200732:	fd070c1b          	addiw	s8,a4,-48
    80200736:	0006059b          	sext.w	a1,a2
    8020073a:	fed870e3          	bgeu	a6,a3,8020071a <vprintfmt+0xf0>
    8020073e:	f40ddce3          	bgez	s11,80200696 <vprintfmt+0x6c>
    80200742:	8de2                	mv	s11,s8
    80200744:	5c7d                	li	s8,-1
    80200746:	bf81                	j	80200696 <vprintfmt+0x6c>
    80200748:	fffdc693          	not	a3,s11
    8020074c:	96fd                	srai	a3,a3,0x3f
    8020074e:	00ddfdb3          	and	s11,s11,a3
    80200752:	00144603          	lbu	a2,1(s0)
    80200756:	2d81                	sext.w	s11,s11
    80200758:	846a                	mv	s0,s10
    8020075a:	bf35                	j	80200696 <vprintfmt+0x6c>
    8020075c:	000a2c03          	lw	s8,0(s4)
    80200760:	00144603          	lbu	a2,1(s0)
    80200764:	0a21                	addi	s4,s4,8
    80200766:	846a                	mv	s0,s10
    80200768:	bfd9                	j	8020073e <vprintfmt+0x114>
    8020076a:	4705                	li	a4,1
    8020076c:	008a0593          	addi	a1,s4,8
    80200770:	01174463          	blt	a4,a7,80200778 <vprintfmt+0x14e>
    80200774:	1a088e63          	beqz	a7,80200930 <vprintfmt+0x306>
    80200778:	000a3603          	ld	a2,0(s4)
    8020077c:	46c1                	li	a3,16
    8020077e:	8a2e                	mv	s4,a1
    80200780:	2781                	sext.w	a5,a5
    80200782:	876e                	mv	a4,s11
    80200784:	85a6                	mv	a1,s1
    80200786:	854a                	mv	a0,s2
    80200788:	e37ff0ef          	jal	ra,802005be <printnum>
    8020078c:	bde1                	j	80200664 <vprintfmt+0x3a>
    8020078e:	000a2503          	lw	a0,0(s4)
    80200792:	85a6                	mv	a1,s1
    80200794:	0a21                	addi	s4,s4,8
    80200796:	9902                	jalr	s2
    80200798:	b5f1                	j	80200664 <vprintfmt+0x3a>
    8020079a:	4705                	li	a4,1
    8020079c:	008a0593          	addi	a1,s4,8
    802007a0:	01174463          	blt	a4,a7,802007a8 <vprintfmt+0x17e>
    802007a4:	18088163          	beqz	a7,80200926 <vprintfmt+0x2fc>
    802007a8:	000a3603          	ld	a2,0(s4)
    802007ac:	46a9                	li	a3,10
    802007ae:	8a2e                	mv	s4,a1
    802007b0:	bfc1                	j	80200780 <vprintfmt+0x156>
    802007b2:	00144603          	lbu	a2,1(s0)
    802007b6:	4c85                	li	s9,1
    802007b8:	846a                	mv	s0,s10
    802007ba:	bdf1                	j	80200696 <vprintfmt+0x6c>
    802007bc:	85a6                	mv	a1,s1
    802007be:	02500513          	li	a0,37
    802007c2:	9902                	jalr	s2
    802007c4:	b545                	j	80200664 <vprintfmt+0x3a>
    802007c6:	00144603          	lbu	a2,1(s0)
    802007ca:	2885                	addiw	a7,a7,1
    802007cc:	846a                	mv	s0,s10
    802007ce:	b5e1                	j	80200696 <vprintfmt+0x6c>
    802007d0:	4705                	li	a4,1
    802007d2:	008a0593          	addi	a1,s4,8
    802007d6:	01174463          	blt	a4,a7,802007de <vprintfmt+0x1b4>
    802007da:	14088163          	beqz	a7,8020091c <vprintfmt+0x2f2>
    802007de:	000a3603          	ld	a2,0(s4)
    802007e2:	46a1                	li	a3,8
    802007e4:	8a2e                	mv	s4,a1
    802007e6:	bf69                	j	80200780 <vprintfmt+0x156>
    802007e8:	03000513          	li	a0,48
    802007ec:	85a6                	mv	a1,s1
    802007ee:	e03e                	sd	a5,0(sp)
    802007f0:	9902                	jalr	s2
    802007f2:	85a6                	mv	a1,s1
    802007f4:	07800513          	li	a0,120
    802007f8:	9902                	jalr	s2
    802007fa:	0a21                	addi	s4,s4,8
    802007fc:	6782                	ld	a5,0(sp)
    802007fe:	46c1                	li	a3,16
    80200800:	ff8a3603          	ld	a2,-8(s4)
    80200804:	bfb5                	j	80200780 <vprintfmt+0x156>
    80200806:	000a3403          	ld	s0,0(s4)
    8020080a:	008a0713          	addi	a4,s4,8
    8020080e:	e03a                	sd	a4,0(sp)
    80200810:	14040263          	beqz	s0,80200954 <vprintfmt+0x32a>
    80200814:	0fb05763          	blez	s11,80200902 <vprintfmt+0x2d8>
    80200818:	02d00693          	li	a3,45
    8020081c:	0cd79163          	bne	a5,a3,802008de <vprintfmt+0x2b4>
    80200820:	00044783          	lbu	a5,0(s0)
    80200824:	0007851b          	sext.w	a0,a5
    80200828:	cf85                	beqz	a5,80200860 <vprintfmt+0x236>
    8020082a:	00140a13          	addi	s4,s0,1
    8020082e:	05e00413          	li	s0,94
    80200832:	000c4563          	bltz	s8,8020083c <vprintfmt+0x212>
    80200836:	3c7d                	addiw	s8,s8,-1
    80200838:	036c0263          	beq	s8,s6,8020085c <vprintfmt+0x232>
    8020083c:	85a6                	mv	a1,s1
    8020083e:	0e0c8e63          	beqz	s9,8020093a <vprintfmt+0x310>
    80200842:	3781                	addiw	a5,a5,-32
    80200844:	0ef47b63          	bgeu	s0,a5,8020093a <vprintfmt+0x310>
    80200848:	03f00513          	li	a0,63
    8020084c:	9902                	jalr	s2
    8020084e:	000a4783          	lbu	a5,0(s4)
    80200852:	3dfd                	addiw	s11,s11,-1
    80200854:	0a05                	addi	s4,s4,1
    80200856:	0007851b          	sext.w	a0,a5
    8020085a:	ffe1                	bnez	a5,80200832 <vprintfmt+0x208>
    8020085c:	01b05963          	blez	s11,8020086e <vprintfmt+0x244>
    80200860:	3dfd                	addiw	s11,s11,-1
    80200862:	85a6                	mv	a1,s1
    80200864:	02000513          	li	a0,32
    80200868:	9902                	jalr	s2
    8020086a:	fe0d9be3          	bnez	s11,80200860 <vprintfmt+0x236>
    8020086e:	6a02                	ld	s4,0(sp)
    80200870:	bbd5                	j	80200664 <vprintfmt+0x3a>
    80200872:	4705                	li	a4,1
    80200874:	008a0c93          	addi	s9,s4,8
    80200878:	01174463          	blt	a4,a7,80200880 <vprintfmt+0x256>
    8020087c:	08088d63          	beqz	a7,80200916 <vprintfmt+0x2ec>
    80200880:	000a3403          	ld	s0,0(s4)
    80200884:	0a044d63          	bltz	s0,8020093e <vprintfmt+0x314>
    80200888:	8622                	mv	a2,s0
    8020088a:	8a66                	mv	s4,s9
    8020088c:	46a9                	li	a3,10
    8020088e:	bdcd                	j	80200780 <vprintfmt+0x156>
    80200890:	000a2783          	lw	a5,0(s4)
    80200894:	4719                	li	a4,6
    80200896:	0a21                	addi	s4,s4,8
    80200898:	41f7d69b          	sraiw	a3,a5,0x1f
    8020089c:	8fb5                	xor	a5,a5,a3
    8020089e:	40d786bb          	subw	a3,a5,a3
    802008a2:	02d74163          	blt	a4,a3,802008c4 <vprintfmt+0x29a>
    802008a6:	00369793          	slli	a5,a3,0x3
    802008aa:	97de                	add	a5,a5,s7
    802008ac:	639c                	ld	a5,0(a5)
    802008ae:	cb99                	beqz	a5,802008c4 <vprintfmt+0x29a>
    802008b0:	86be                	mv	a3,a5
    802008b2:	00000617          	auipc	a2,0x0
    802008b6:	79e60613          	addi	a2,a2,1950 # 80201050 <etext+0x628>
    802008ba:	85a6                	mv	a1,s1
    802008bc:	854a                	mv	a0,s2
    802008be:	0ce000ef          	jal	ra,8020098c <printfmt>
    802008c2:	b34d                	j	80200664 <vprintfmt+0x3a>
    802008c4:	00000617          	auipc	a2,0x0
    802008c8:	77c60613          	addi	a2,a2,1916 # 80201040 <etext+0x618>
    802008cc:	85a6                	mv	a1,s1
    802008ce:	854a                	mv	a0,s2
    802008d0:	0bc000ef          	jal	ra,8020098c <printfmt>
    802008d4:	bb41                	j	80200664 <vprintfmt+0x3a>
    802008d6:	00000417          	auipc	s0,0x0
    802008da:	76240413          	addi	s0,s0,1890 # 80201038 <etext+0x610>
    802008de:	85e2                	mv	a1,s8
    802008e0:	8522                	mv	a0,s0
    802008e2:	e43e                	sd	a5,8(sp)
    802008e4:	116000ef          	jal	ra,802009fa <strnlen>
    802008e8:	40ad8dbb          	subw	s11,s11,a0
    802008ec:	01b05b63          	blez	s11,80200902 <vprintfmt+0x2d8>
    802008f0:	67a2                	ld	a5,8(sp)
    802008f2:	00078a1b          	sext.w	s4,a5
    802008f6:	3dfd                	addiw	s11,s11,-1
    802008f8:	85a6                	mv	a1,s1
    802008fa:	8552                	mv	a0,s4
    802008fc:	9902                	jalr	s2
    802008fe:	fe0d9ce3          	bnez	s11,802008f6 <vprintfmt+0x2cc>
    80200902:	00044783          	lbu	a5,0(s0)
    80200906:	00140a13          	addi	s4,s0,1
    8020090a:	0007851b          	sext.w	a0,a5
    8020090e:	d3a5                	beqz	a5,8020086e <vprintfmt+0x244>
    80200910:	05e00413          	li	s0,94
    80200914:	bf39                	j	80200832 <vprintfmt+0x208>
    80200916:	000a2403          	lw	s0,0(s4)
    8020091a:	b7ad                	j	80200884 <vprintfmt+0x25a>
    8020091c:	000a6603          	lwu	a2,0(s4)
    80200920:	46a1                	li	a3,8
    80200922:	8a2e                	mv	s4,a1
    80200924:	bdb1                	j	80200780 <vprintfmt+0x156>
    80200926:	000a6603          	lwu	a2,0(s4)
    8020092a:	46a9                	li	a3,10
    8020092c:	8a2e                	mv	s4,a1
    8020092e:	bd89                	j	80200780 <vprintfmt+0x156>
    80200930:	000a6603          	lwu	a2,0(s4)
    80200934:	46c1                	li	a3,16
    80200936:	8a2e                	mv	s4,a1
    80200938:	b5a1                	j	80200780 <vprintfmt+0x156>
    8020093a:	9902                	jalr	s2
    8020093c:	bf09                	j	8020084e <vprintfmt+0x224>
    8020093e:	85a6                	mv	a1,s1
    80200940:	02d00513          	li	a0,45
    80200944:	e03e                	sd	a5,0(sp)
    80200946:	9902                	jalr	s2
    80200948:	6782                	ld	a5,0(sp)
    8020094a:	8a66                	mv	s4,s9
    8020094c:	40800633          	neg	a2,s0
    80200950:	46a9                	li	a3,10
    80200952:	b53d                	j	80200780 <vprintfmt+0x156>
    80200954:	03b05163          	blez	s11,80200976 <vprintfmt+0x34c>
    80200958:	02d00693          	li	a3,45
    8020095c:	f6d79de3          	bne	a5,a3,802008d6 <vprintfmt+0x2ac>
    80200960:	00000417          	auipc	s0,0x0
    80200964:	6d840413          	addi	s0,s0,1752 # 80201038 <etext+0x610>
    80200968:	02800793          	li	a5,40
    8020096c:	02800513          	li	a0,40
    80200970:	00140a13          	addi	s4,s0,1
    80200974:	bd6d                	j	8020082e <vprintfmt+0x204>
    80200976:	00000a17          	auipc	s4,0x0
    8020097a:	6c3a0a13          	addi	s4,s4,1731 # 80201039 <etext+0x611>
    8020097e:	02800513          	li	a0,40
    80200982:	02800793          	li	a5,40
    80200986:	05e00413          	li	s0,94
    8020098a:	b565                	j	80200832 <vprintfmt+0x208>

000000008020098c <printfmt>:
    8020098c:	715d                	addi	sp,sp,-80
    8020098e:	02810313          	addi	t1,sp,40
    80200992:	f436                	sd	a3,40(sp)
    80200994:	869a                	mv	a3,t1
    80200996:	ec06                	sd	ra,24(sp)
    80200998:	f83a                	sd	a4,48(sp)
    8020099a:	fc3e                	sd	a5,56(sp)
    8020099c:	e0c2                	sd	a6,64(sp)
    8020099e:	e4c6                	sd	a7,72(sp)
    802009a0:	e41a                	sd	t1,8(sp)
    802009a2:	c89ff0ef          	jal	ra,8020062a <vprintfmt>
    802009a6:	60e2                	ld	ra,24(sp)
    802009a8:	6161                	addi	sp,sp,80
    802009aa:	8082                	ret

00000000802009ac <sbi_console_putchar>:
    802009ac:	4781                	li	a5,0
    802009ae:	00003717          	auipc	a4,0x3
    802009b2:	65273703          	ld	a4,1618(a4) # 80204000 <SBI_CONSOLE_PUTCHAR>
    802009b6:	88ba                	mv	a7,a4
    802009b8:	852a                	mv	a0,a0
    802009ba:	85be                	mv	a1,a5
    802009bc:	863e                	mv	a2,a5
    802009be:	00000073          	ecall
    802009c2:	87aa                	mv	a5,a0
    802009c4:	8082                	ret

00000000802009c6 <sbi_set_timer>:
    802009c6:	4781                	li	a5,0
    802009c8:	00003717          	auipc	a4,0x3
    802009cc:	66073703          	ld	a4,1632(a4) # 80204028 <SBI_SET_TIMER>
    802009d0:	88ba                	mv	a7,a4
    802009d2:	852a                	mv	a0,a0
    802009d4:	85be                	mv	a1,a5
    802009d6:	863e                	mv	a2,a5
    802009d8:	00000073          	ecall
    802009dc:	87aa                	mv	a5,a0
    802009de:	8082                	ret

00000000802009e0 <sbi_shutdown>:
    802009e0:	4781                	li	a5,0
    802009e2:	00003717          	auipc	a4,0x3
    802009e6:	62673703          	ld	a4,1574(a4) # 80204008 <SBI_SHUTDOWN>
    802009ea:	88ba                	mv	a7,a4
    802009ec:	853e                	mv	a0,a5
    802009ee:	85be                	mv	a1,a5
    802009f0:	863e                	mv	a2,a5
    802009f2:	00000073          	ecall
    802009f6:	87aa                	mv	a5,a0
    802009f8:	8082                	ret

00000000802009fa <strnlen>:
    802009fa:	4781                	li	a5,0
    802009fc:	e589                	bnez	a1,80200a06 <strnlen+0xc>
    802009fe:	a811                	j	80200a12 <strnlen+0x18>
    80200a00:	0785                	addi	a5,a5,1
    80200a02:	00f58863          	beq	a1,a5,80200a12 <strnlen+0x18>
    80200a06:	00f50733          	add	a4,a0,a5
    80200a0a:	00074703          	lbu	a4,0(a4)
    80200a0e:	fb6d                	bnez	a4,80200a00 <strnlen+0x6>
    80200a10:	85be                	mv	a1,a5
    80200a12:	852e                	mv	a0,a1
    80200a14:	8082                	ret

0000000080200a16 <memset>:
    80200a16:	ca01                	beqz	a2,80200a26 <memset+0x10>
    80200a18:	962a                	add	a2,a2,a0
    80200a1a:	87aa                	mv	a5,a0
    80200a1c:	0785                	addi	a5,a5,1
    80200a1e:	feb78fa3          	sb	a1,-1(a5)
    80200a22:	fec79de3          	bne	a5,a2,80200a1c <memset+0x6>
    80200a26:	8082                	ret
