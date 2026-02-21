
./build/embedded_framework.elf:     file format elf32-littlearm


Disassembly of section .text:

0800024c <rt_hw_interrupt_disable>:
 * rt_base_t rt_hw_interrupt_disable();
 */
.global rt_hw_interrupt_disable
.type rt_hw_interrupt_disable, %function
rt_hw_interrupt_disable:
    MRS     r0, PRIMASK
 800024c:	f3ef 8010 	mrs	r0, PRIMASK
    CPSID   I
 8000250:	b672      	cpsid	i
    BX      LR
 8000252:	4770      	bx	lr

08000254 <rt_hw_interrupt_enable>:
 * void rt_hw_interrupt_enable(rt_base_t level);
 */
.global rt_hw_interrupt_enable
.type rt_hw_interrupt_enable, %function
rt_hw_interrupt_enable:
    MSR     PRIMASK, r0
 8000254:	f380 8810 	msr	PRIMASK, r0
    BX      LR
 8000258:	4770      	bx	lr

0800025a <rt_hw_context_switch>:
.type rt_hw_context_switch, %function

rt_hw_context_switch_interrupt:
rt_hw_context_switch:
    /* set rt_thread_switch_interrupt_flag to 1 */
    LDR     r2, =rt_thread_switch_interrupt_flag
 800025a:	4a46      	ldr	r2, [pc, #280]	@ (8000374 <_update_done+0x12>)
    LDR     r3, [r2]
 800025c:	6813      	ldr	r3, [r2, #0]
    CMP     r3, #1
 800025e:	2b01      	cmp	r3, #1
    BEQ     _reswitch
 8000260:	d004      	beq.n	800026c <_reswitch>
    MOV     r3, #1
 8000262:	f04f 0301 	mov.w	r3, #1
    STR     r3, [r2]
 8000266:	6013      	str	r3, [r2, #0]

    LDR     r2, =rt_interrupt_from_thread   /* set rt_interrupt_from_thread */
 8000268:	4a43      	ldr	r2, [pc, #268]	@ (8000378 <_update_done+0x16>)
    STR     r0, [r2]
 800026a:	6010      	str	r0, [r2, #0]

0800026c <_reswitch>:

_reswitch:
    LDR     r2, =rt_interrupt_to_thread     /* set rt_interrupt_to_thread */
 800026c:	4a43      	ldr	r2, [pc, #268]	@ (800037c <_update_done+0x1a>)
    STR     r1, [r2]
 800026e:	6011      	str	r1, [r2, #0]

    LDR r0, =NVIC_INT_CTRL              /* trigger the PendSV exception (causes context switch) */
 8000270:	4843      	ldr	r0, [pc, #268]	@ (8000380 <_update_done+0x1e>)
    LDR r1, =NVIC_PENDSVSET
 8000272:	f04f 5180 	mov.w	r1, #268435456	@ 0x10000000
    STR r1, [r0]
 8000276:	6001      	str	r1, [r0, #0]
    BX  LR
 8000278:	4770      	bx	lr

0800027a <PendSV_Handler>:
 */
.global PendSV_Handler
.type PendSV_Handler, %function
PendSV_Handler:
    /* disable interrupt to protect context switch */
    MRS r2, PRIMASK
 800027a:	f3ef 8210 	mrs	r2, PRIMASK
    CPSID   I
 800027e:	b672      	cpsid	i

    /* get rt_thread_switch_interrupt_flag */
    LDR r0, =rt_thread_switch_interrupt_flag
 8000280:	483c      	ldr	r0, [pc, #240]	@ (8000374 <_update_done+0x12>)
    LDR r1, [r0]
 8000282:	6801      	ldr	r1, [r0, #0]
    CBZ r1, pendsv_exit         /* pendsv already handled */
 8000284:	b351      	cbz	r1, 80002dc <pendsv_exit>

    /* clear rt_thread_switch_interrupt_flag to 0 */
    MOV r1, #0x00
 8000286:	f04f 0100 	mov.w	r1, #0
    STR r1, [r0]
 800028a:	6001      	str	r1, [r0, #0]

    LDR r0, =rt_interrupt_from_thread
 800028c:	483a      	ldr	r0, [pc, #232]	@ (8000378 <_update_done+0x16>)
    LDR r1, [r0]
 800028e:	6801      	ldr	r1, [r0, #0]
    CBZ r1, switch_to_thread    /* skip register save at the first time */
 8000290:	b191      	cbz	r1, 80002b8 <switch_to_thread>

    MRS r1, psp                 /* get from thread stack pointer */
 8000292:	f3ef 8109 	mrs	r1, PSP

#if defined (__VFP_FP__) && !defined(__SOFTFP__)
    TST     lr, #0x10           /* if(!EXC_RETURN[4]) */
 8000296:	f01e 0f10 	tst.w	lr, #16
    IT      EQ
 800029a:	bf08      	it	eq
    VSTMDBEQ r1!, {d8 - d15}    /* push FPU register s16~s31 */
 800029c:	ed21 8b10 	vstmdbeq	r1!, {d8-d15}
#endif

    STMFD   r1!, {r4 - r11}     /* push r4 - r11 register */
 80002a0:	e921 0ff0 	stmdb	r1!, {r4, r5, r6, r7, r8, r9, sl, fp}

#if defined (__VFP_FP__) && !defined(__SOFTFP__)
    MOV     r4, #0x00           /* flag = 0 */
 80002a4:	f04f 0400 	mov.w	r4, #0

    TST     lr, #0x10           /* if(!EXC_RETURN[4]) */
 80002a8:	f01e 0f10 	tst.w	lr, #16
    IT      EQ
 80002ac:	bf08      	it	eq
    MOVEQ   r4, #0x01           /* flag = 1 */
 80002ae:	2401      	moveq	r4, #1

    STMFD   r1!, {r4}           /* push flag */
 80002b0:	f841 4d04 	str.w	r4, [r1, #-4]!
#endif

    LDR r0, [r0]
 80002b4:	6800      	ldr	r0, [r0, #0]
    STR r1, [r0]                /* update from thread stack pointer */
 80002b6:	6001      	str	r1, [r0, #0]

080002b8 <switch_to_thread>:

switch_to_thread:
    LDR r1, =rt_interrupt_to_thread
 80002b8:	4930      	ldr	r1, [pc, #192]	@ (800037c <_update_done+0x1a>)
    LDR r1, [r1]
 80002ba:	6809      	ldr	r1, [r1, #0]
    LDR r1, [r1]                /* load thread stack pointer */
 80002bc:	6809      	ldr	r1, [r1, #0]

#if defined (__VFP_FP__) && !defined(__SOFTFP__)
    LDMFD   r1!, {r3}           /* pop flag */
 80002be:	c908      	ldmia	r1!, {r3}
#endif

    LDMFD   r1!, {r4 - r11}     /* pop r4 - r11 register */
 80002c0:	e8b1 0ff0 	ldmia.w	r1!, {r4, r5, r6, r7, r8, r9, sl, fp}

#if defined (__VFP_FP__) && !defined(__SOFTFP__)
    CMP     r3,  #0             /* if(flag_r3 != 0) */
 80002c4:	2b00      	cmp	r3, #0
    IT      NE
 80002c6:	bf18      	it	ne
    VLDMIANE  r1!, {d8 - d15}   /* pop FPU register s16~s31 */
 80002c8:	ecb1 8b10 	vldmiane	r1!, {d8-d15}
#endif

    MSR psp, r1                 /* update stack pointer */
 80002cc:	f381 8809 	msr	PSP, r1

#if defined (__VFP_FP__) && !defined(__SOFTFP__)
    ORR     lr, lr, #0x10       /* lr |=  (1 << 4), clean FPCA. */
 80002d0:	f04e 0e10 	orr.w	lr, lr, #16
    CMP     r3,  #0             /* if(flag_r3 != 0) */
 80002d4:	2b00      	cmp	r3, #0
    IT      NE
 80002d6:	bf18      	it	ne
    BICNE   lr, lr, #0x10       /* lr &= ~(1 << 4), set FPCA. */
 80002d8:	f02e 0e10 	bicne.w	lr, lr, #16

080002dc <pendsv_exit>:
#endif

pendsv_exit:
    /* restore interrupt */
    MSR PRIMASK, r2
 80002dc:	f382 8810 	msr	PRIMASK, r2

    ORR lr, lr, #0x04
 80002e0:	f04e 0e04 	orr.w	lr, lr, #4
    BX  lr
 80002e4:	4770      	bx	lr

080002e6 <rt_hw_context_switch_to>:
 * r0 --> to
 */
.global rt_hw_context_switch_to
.type rt_hw_context_switch_to, %function
rt_hw_context_switch_to:
    LDR r1, =rt_interrupt_to_thread
 80002e6:	4925      	ldr	r1, [pc, #148]	@ (800037c <_update_done+0x1a>)
    STR r0, [r1]
 80002e8:	6008      	str	r0, [r1, #0]

#if defined (__VFP_FP__) && !defined(__SOFTFP__)
    /* CLEAR CONTROL.FPCA */
    MRS     r2, CONTROL         /* read */
 80002ea:	f3ef 8214 	mrs	r2, CONTROL
    BIC     r2, #0x04           /* modify */
 80002ee:	f022 0204 	bic.w	r2, r2, #4
    MSR     CONTROL, r2         /* write-back */
 80002f2:	f382 8814 	msr	CONTROL, r2
#endif

    /* set from thread to 0 */
    LDR r1, =rt_interrupt_from_thread
 80002f6:	4920      	ldr	r1, [pc, #128]	@ (8000378 <_update_done+0x16>)
    MOV r0, #0x0
 80002f8:	f04f 0000 	mov.w	r0, #0
    STR r0, [r1]
 80002fc:	6008      	str	r0, [r1, #0]

    /* set interrupt flag to 1 */
    LDR     r1, =rt_thread_switch_interrupt_flag
 80002fe:	491d      	ldr	r1, [pc, #116]	@ (8000374 <_update_done+0x12>)
    MOV     r0, #1
 8000300:	f04f 0001 	mov.w	r0, #1
    STR     r0, [r1]
 8000304:	6008      	str	r0, [r1, #0]

    /* set the PendSV and SysTick exception priority */
    LDR r0, =NVIC_SYSPRI2
 8000306:	481f      	ldr	r0, [pc, #124]	@ (8000384 <_update_done+0x22>)
    LDR r1, =NVIC_PENDSV_PRI
 8000308:	491f      	ldr	r1, [pc, #124]	@ (8000388 <_update_done+0x26>)
    LDR.W   r2, [r0,#0x00]       /* read       */
 800030a:	f8d0 2000 	ldr.w	r2, [r0]
    ORR     r1,r1,r2             /* modify     */
 800030e:	ea41 0102 	orr.w	r1, r1, r2
    STR     r1, [r0]             /* write-back */
 8000312:	6001      	str	r1, [r0, #0]

    LDR r0, =NVIC_INT_CTRL      /* trigger the PendSV exception (causes context switch) */
 8000314:	481a      	ldr	r0, [pc, #104]	@ (8000380 <_update_done+0x1e>)
    LDR r1, =NVIC_PENDSVSET
 8000316:	f04f 5180 	mov.w	r1, #268435456	@ 0x10000000
    STR r1, [r0]
 800031a:	6001      	str	r1, [r0, #0]

    /* restore MSP */
    LDR     r0, =SCB_VTOR
 800031c:	481b      	ldr	r0, [pc, #108]	@ (800038c <_update_done+0x2a>)
    LDR     r0, [r0]
 800031e:	6800      	ldr	r0, [r0, #0]
    LDR     r0, [r0]
 8000320:	6800      	ldr	r0, [r0, #0]
    NOP
 8000322:	bf00      	nop
    MSR     msp, r0
 8000324:	f380 8808 	msr	MSP, r0

    /* enable interrupts at processor level */
    CPSIE   F
 8000328:	b661      	cpsie	f
    CPSIE   I
 800032a:	b662      	cpsie	i

    /* ensure PendSV exception taken place before subsequent operation */
    DSB
 800032c:	f3bf 8f4f 	dsb	sy
    ISB
 8000330:	f3bf 8f6f 	isb	sy

08000334 <rt_hw_interrupt_thread_switch>:

/* compatible with old version */
.global rt_hw_interrupt_thread_switch
.type rt_hw_interrupt_thread_switch, %function
rt_hw_interrupt_thread_switch:
    BX  lr
 8000334:	4770      	bx	lr
    NOP
 8000336:	bf00      	nop

08000338 <HardFault_Handler>:

.global HardFault_Handler
.type HardFault_Handler, %function
HardFault_Handler:
    /* get current context */
    MRS     r0, msp                 /* get fault context from handler. */
 8000338:	f3ef 8008 	mrs	r0, MSP
    TST     lr, #0x04               /* if(!EXC_RETURN[2]) */
 800033c:	f01e 0f04 	tst.w	lr, #4
    BEQ     _get_sp_done
 8000340:	d001      	beq.n	8000346 <_get_sp_done>
    MRS     r0, psp                 /* get fault context from thread. */
 8000342:	f3ef 8009 	mrs	r0, PSP

08000346 <_get_sp_done>:
_get_sp_done:

    STMFD   r0!, {r4 - r11}         /* push r4 - r11 register */
 8000346:	e920 0ff0 	stmdb	r0!, {r4, r5, r6, r7, r8, r9, sl, fp}
#if defined (__VFP_FP__) && !defined(__SOFTFP__)
    STMFD   r0!, {lr}               /* push dummy for flag */
 800034a:	f840 ed04 	str.w	lr, [r0, #-4]!
#endif
    STMFD   r0!, {lr}               /* push exec_return register */
 800034e:	f840 ed04 	str.w	lr, [r0, #-4]!

    TST     lr, #0x04               /* if(!EXC_RETURN[2]) */
 8000352:	f01e 0f04 	tst.w	lr, #4
    BEQ     _update_msp
 8000356:	d002      	beq.n	800035e <_update_msp>
    MSR     psp, r0                 /* update stack pointer to PSP. */
 8000358:	f380 8809 	msr	PSP, r0
    B       _update_done
 800035c:	e001      	b.n	8000362 <_update_done>

0800035e <_update_msp>:
_update_msp:
    MSR     msp, r0                 /* update stack pointer to MSP. */
 800035e:	f380 8808 	msr	MSP, r0

08000362 <_update_done>:
_update_done:

    PUSH    {LR}
 8000362:	b500      	push	{lr}
    BL      rt_hw_hard_fault_exception
 8000364:	f000 fbb4 	bl	8000ad0 <rt_hw_hard_fault_exception>
    POP     {LR}
 8000368:	f85d eb04 	ldr.w	lr, [sp], #4

    ORR     lr, lr, #0x04
 800036c:	f04e 0e04 	orr.w	lr, lr, #4
 8000370:	4770      	bx	lr
 8000372:	0000      	.short	0x0000
    LDR     r2, =rt_thread_switch_interrupt_flag
 8000374:	200000b8 	.word	0x200000b8
    LDR     r2, =rt_interrupt_from_thread   /* set rt_interrupt_from_thread */
 8000378:	200000c0 	.word	0x200000c0
    LDR     r2, =rt_interrupt_to_thread     /* set rt_interrupt_to_thread */
 800037c:	200000bc 	.word	0x200000bc
    LDR r0, =NVIC_INT_CTRL              /* trigger the PendSV exception (causes context switch) */
 8000380:	e000ed04 	.word	0xe000ed04
    LDR r0, =NVIC_SYSPRI2
 8000384:	e000ed20 	.word	0xe000ed20
    LDR r1, =NVIC_PENDSV_PRI
 8000388:	ffff0000 	.word	0xffff0000
    LDR     r0, =SCB_VTOR
 800038c:	e000ed08 	.word	0xe000ed08

08000390 <tzcall>:
 * int tzcall(int id, rt_ubase_t arg0, rt_ubase_t arg1, rt_ubase_t arg2);
 */
.global tzcall
.type tzcall, %function
tzcall:
    SVC     1                       /* call SVC 1 */
 8000390:	df01      	svc	1
    BX      LR
 8000392:	4770      	bx	lr

08000394 <tzcall_entry>:

tzcall_entry:
    PUSH    {R1, R4, LR}
 8000394:	b512      	push	{r1, r4, lr}
    MOV     R4, R1                  /* copy thread SP to R4 */
 8000396:	460c      	mov	r4, r1
    LDMFD   R4!, {r0 - r3}          /* pop user stack, get input arg0, arg1, arg2 */
 8000398:	cc0f      	ldmia	r4!, {r0, r1, r2, r3}
    STMFD   R4!, {r0 - r3}          /* push stack, user stack recovery */
 800039a:	e924 000f 	stmdb	r4!, {r0, r1, r2, r3}
    BL      rt_secure_svc_handle    /* call fun */
 800039e:	f000 fc55 	bl	8000c4c <rt_secure_svc_handle>
    POP     {R1, R4, LR}
 80003a2:	e8bd 4012 	ldmia.w	sp!, {r1, r4, lr}
    STR     R0, [R1]                /* update return value */
 80003a6:	6008      	str	r0, [r1, #0]
    BX      LR                      /* return to thread */
 80003a8:	4770      	bx	lr

080003aa <syscall_entry>:

syscall_entry:
    BX      LR                      /* return to user app */
 80003aa:	4770      	bx	lr

080003ac <SVC_Handler>:
.global SVC_Handler
.type SVC_Handler, %function
SVC_Handler:

    /* get SP, save to R1 */
    MRS     R1, MSP                 /* get fault context from handler. */
 80003ac:	f3ef 8108 	mrs	r1, MSP
    TST     LR, #0x04               /* if(!EXC_RETURN[2]) */
 80003b0:	f01e 0f04 	tst.w	lr, #4
    BEQ     get_sp_done
 80003b4:	d001      	beq.n	80003ba <get_sp_done>
    MRS     R1, PSP                 /* get fault context from thread. */
 80003b6:	f3ef 8109 	mrs	r1, PSP

080003ba <get_sp_done>:
get_sp_done:

    /* get svc index */
    LDR     R0, [R1, #24]
 80003ba:	6988      	ldr	r0, [r1, #24]
    LDRB    R0, [R0, #-2]
 80003bc:	f810 0c02 	ldrb.w	r0, [r0, #-2]

    /* if svc == 0, do system call */
    CMP     R0, #0x0
 80003c0:	2800      	cmp	r0, #0
    BEQ    syscall_entry
 80003c2:	d0f2      	beq.n	80003aa <syscall_entry>

    /* if svc == 1, do TrustZone call */
    CMP     R0, #0x1
 80003c4:	2801      	cmp	r0, #1
    BEQ    tzcall_entry
 80003c6:	d0e5      	beq.n	8000394 <tzcall_entry>

080003c8 <__aeabi_uldivmod>:
 80003c8:	b953      	cbnz	r3, 80003e0 <__aeabi_uldivmod+0x18>
 80003ca:	b94a      	cbnz	r2, 80003e0 <__aeabi_uldivmod+0x18>
 80003cc:	2900      	cmp	r1, #0
 80003ce:	bf08      	it	eq
 80003d0:	2800      	cmpeq	r0, #0
 80003d2:	bf1c      	itt	ne
 80003d4:	f04f 31ff 	movne.w	r1, #4294967295	@ 0xffffffff
 80003d8:	f04f 30ff 	movne.w	r0, #4294967295	@ 0xffffffff
 80003dc:	f000 b80c 	b.w	80003f8 <__aeabi_idiv0>
 80003e0:	f1ad 0c08 	sub.w	ip, sp, #8
 80003e4:	e96d ce04 	strd	ip, lr, [sp, #-16]!
 80003e8:	f007 fd44 	bl	8007e74 <__udivmoddi4>
 80003ec:	f8dd e004 	ldr.w	lr, [sp, #4]
 80003f0:	e9dd 2302 	ldrd	r2, r3, [sp, #8]
 80003f4:	b004      	add	sp, #16
 80003f6:	4770      	bx	lr

080003f8 <__aeabi_idiv0>:
 80003f8:	4770      	bx	lr
 80003fa:	bf00      	nop

080003fc <deregister_tm_clones>:
 80003fc:	4803      	ldr	r0, [pc, #12]	@ (800040c <deregister_tm_clones+0x10>)
 80003fe:	4b04      	ldr	r3, [pc, #16]	@ (8000410 <deregister_tm_clones+0x14>)
 8000400:	4283      	cmp	r3, r0
 8000402:	d002      	beq.n	800040a <deregister_tm_clones+0xe>
 8000404:	4b03      	ldr	r3, [pc, #12]	@ (8000414 <deregister_tm_clones+0x18>)
 8000406:	b103      	cbz	r3, 800040a <deregister_tm_clones+0xe>
 8000408:	4718      	bx	r3
 800040a:	4770      	bx	lr
 800040c:	20000098 	.word	0x20000098
 8000410:	20000098 	.word	0x20000098
 8000414:	00000000 	.word	0x00000000

08000418 <register_tm_clones>:
 8000418:	4b06      	ldr	r3, [pc, #24]	@ (8000434 <register_tm_clones+0x1c>)
 800041a:	4907      	ldr	r1, [pc, #28]	@ (8000438 <register_tm_clones+0x20>)
 800041c:	1ac9      	subs	r1, r1, r3
 800041e:	1089      	asrs	r1, r1, #2
 8000420:	bf48      	it	mi
 8000422:	3101      	addmi	r1, #1
 8000424:	1049      	asrs	r1, r1, #1
 8000426:	d003      	beq.n	8000430 <register_tm_clones+0x18>
 8000428:	4b04      	ldr	r3, [pc, #16]	@ (800043c <register_tm_clones+0x24>)
 800042a:	b10b      	cbz	r3, 8000430 <register_tm_clones+0x18>
 800042c:	4801      	ldr	r0, [pc, #4]	@ (8000434 <register_tm_clones+0x1c>)
 800042e:	4718      	bx	r3
 8000430:	4770      	bx	lr
 8000432:	bf00      	nop
 8000434:	20000098 	.word	0x20000098
 8000438:	20000098 	.word	0x20000098
 800043c:	00000000 	.word	0x00000000

08000440 <__do_global_dtors_aux>:
 8000440:	b510      	push	{r4, lr}
 8000442:	4c06      	ldr	r4, [pc, #24]	@ (800045c <__do_global_dtors_aux+0x1c>)
 8000444:	7823      	ldrb	r3, [r4, #0]
 8000446:	b943      	cbnz	r3, 800045a <__do_global_dtors_aux+0x1a>
 8000448:	f7ff ffd8 	bl	80003fc <deregister_tm_clones>
 800044c:	4b04      	ldr	r3, [pc, #16]	@ (8000460 <__do_global_dtors_aux+0x20>)
 800044e:	b113      	cbz	r3, 8000456 <__do_global_dtors_aux+0x16>
 8000450:	4804      	ldr	r0, [pc, #16]	@ (8000464 <__do_global_dtors_aux+0x24>)
 8000452:	f3af 8000 	nop.w
 8000456:	2301      	movs	r3, #1
 8000458:	7023      	strb	r3, [r4, #0]
 800045a:	bd10      	pop	{r4, pc}
 800045c:	20000098 	.word	0x20000098
 8000460:	00000000 	.word	0x00000000
 8000464:	080081c0 	.word	0x080081c0

08000468 <frame_dummy>:
 8000468:	b508      	push	{r3, lr}
 800046a:	4b05      	ldr	r3, [pc, #20]	@ (8000480 <frame_dummy+0x18>)
 800046c:	b11b      	cbz	r3, 8000476 <frame_dummy+0xe>
 800046e:	4905      	ldr	r1, [pc, #20]	@ (8000484 <frame_dummy+0x1c>)
 8000470:	4805      	ldr	r0, [pc, #20]	@ (8000488 <frame_dummy+0x20>)
 8000472:	f3af 8000 	nop.w
 8000476:	e8bd 4008 	ldmia.w	sp!, {r3, lr}
 800047a:	f7ff bfcd 	b.w	8000418 <register_tm_clones>
 800047e:	bf00      	nop
 8000480:	00000000 	.word	0x00000000
 8000484:	2000009c 	.word	0x2000009c
 8000488:	080081c0 	.word	0x080081c0

0800048c <WWDG_IRQHandler>:
/*------------------------------------------------------------------------------
 * External Interrupt Handlers (Weak Definitions)
 *----------------------------------------------------------------------------*/

/* WWDG (IRQ 15) */
FRAMEWORK_DEFINE_IRQ_HANDLER(WWDG_IRQHandler, 15)
 800048c:	b508      	push	{r3, lr}
 800048e:	200f      	movs	r0, #15
 8000490:	f007 fc2e 	bl	8007cf0 <framework_irq_handler>
 8000494:	bd08      	pop	{r3, pc}

08000496 <PVD_AVD_IRQHandler>:

/* PVD/AVD (IRQ 16) */
FRAMEWORK_DEFINE_IRQ_HANDLER(PVD_AVD_IRQHandler, 16)
 8000496:	b508      	push	{r3, lr}
 8000498:	2010      	movs	r0, #16
 800049a:	f007 fc29 	bl	8007cf0 <framework_irq_handler>
 800049e:	bd08      	pop	{r3, pc}

080004a0 <RTC_IRQHandler>:

/* RTC non-secure (IRQ 17) */
FRAMEWORK_DEFINE_IRQ_HANDLER(RTC_IRQHandler, 17)
 80004a0:	b508      	push	{r3, lr}
 80004a2:	2011      	movs	r0, #17
 80004a4:	f007 fc24 	bl	8007cf0 <framework_irq_handler>
 80004a8:	bd08      	pop	{r3, pc}

080004aa <RTC_S_IRQHandler>:

/* RTC secure (IRQ 18) */
FRAMEWORK_DEFINE_IRQ_HANDLER(RTC_S_IRQHandler, 18)
 80004aa:	b508      	push	{r3, lr}
 80004ac:	2012      	movs	r0, #18
 80004ae:	f007 fc1f 	bl	8007cf0 <framework_irq_handler>
 80004b2:	bd08      	pop	{r3, pc}

080004b4 <TAMP_IRQHandler>:

/* TAMP (IRQ 19) */
FRAMEWORK_DEFINE_IRQ_HANDLER(TAMP_IRQHandler, 19)
 80004b4:	b508      	push	{r3, lr}
 80004b6:	2013      	movs	r0, #19
 80004b8:	f007 fc1a 	bl	8007cf0 <framework_irq_handler>
 80004bc:	bd08      	pop	{r3, pc}

080004be <RAMCFG_IRQHandler>:

/* RAMCFG (IRQ 20) */
FRAMEWORK_DEFINE_IRQ_HANDLER(RAMCFG_IRQHandler, 20)
 80004be:	b508      	push	{r3, lr}
 80004c0:	2014      	movs	r0, #20
 80004c2:	f007 fc15 	bl	8007cf0 <framework_irq_handler>
 80004c6:	bd08      	pop	{r3, pc}

080004c8 <FLASH_IRQHandler>:

/* FLASH non-secure (IRQ 21) */
FRAMEWORK_DEFINE_IRQ_HANDLER(FLASH_IRQHandler, 21)
 80004c8:	b508      	push	{r3, lr}
 80004ca:	2015      	movs	r0, #21
 80004cc:	f007 fc10 	bl	8007cf0 <framework_irq_handler>
 80004d0:	bd08      	pop	{r3, pc}

080004d2 <FLASH_S_IRQHandler>:

/* FLASH secure (IRQ 22) */
FRAMEWORK_DEFINE_IRQ_HANDLER(FLASH_S_IRQHandler, 22)
 80004d2:	b508      	push	{r3, lr}
 80004d4:	2016      	movs	r0, #22
 80004d6:	f007 fc0b 	bl	8007cf0 <framework_irq_handler>
 80004da:	bd08      	pop	{r3, pc}

080004dc <GTZC_IRQHandler>:

/* GTZC (IRQ 23) */
FRAMEWORK_DEFINE_IRQ_HANDLER(GTZC_IRQHandler, 23)
 80004dc:	b508      	push	{r3, lr}
 80004de:	2017      	movs	r0, #23
 80004e0:	f007 fc06 	bl	8007cf0 <framework_irq_handler>
 80004e4:	bd08      	pop	{r3, pc}

080004e6 <RCC_IRQHandler>:

/* RCC non-secure (IRQ 24) */
FRAMEWORK_DEFINE_IRQ_HANDLER(RCC_IRQHandler, 24)
 80004e6:	b508      	push	{r3, lr}
 80004e8:	2018      	movs	r0, #24
 80004ea:	f007 fc01 	bl	8007cf0 <framework_irq_handler>
 80004ee:	bd08      	pop	{r3, pc}

080004f0 <RCC_S_IRQHandler>:

/* RCC secure (IRQ 25) */
FRAMEWORK_DEFINE_IRQ_HANDLER(RCC_S_IRQHandler, 25)
 80004f0:	b508      	push	{r3, lr}
 80004f2:	2019      	movs	r0, #25
 80004f4:	f007 fbfc 	bl	8007cf0 <framework_irq_handler>
 80004f8:	bd08      	pop	{r3, pc}

080004fa <EXTI0_IRQHandler>:

/* EXTI Line0 (IRQ 26) */
FRAMEWORK_DEFINE_IRQ_HANDLER(EXTI0_IRQHandler, 26)
 80004fa:	b508      	push	{r3, lr}
 80004fc:	201a      	movs	r0, #26
 80004fe:	f007 fbf7 	bl	8007cf0 <framework_irq_handler>
 8000502:	bd08      	pop	{r3, pc}

08000504 <EXTI1_IRQHandler>:

/* EXTI Line1 (IRQ 27) */
FRAMEWORK_DEFINE_IRQ_HANDLER(EXTI1_IRQHandler, 27)
 8000504:	b508      	push	{r3, lr}
 8000506:	201b      	movs	r0, #27
 8000508:	f007 fbf2 	bl	8007cf0 <framework_irq_handler>
 800050c:	bd08      	pop	{r3, pc}

0800050e <EXTI2_IRQHandler>:

/* EXTI Line2 (IRQ 28) */
FRAMEWORK_DEFINE_IRQ_HANDLER(EXTI2_IRQHandler, 28)
 800050e:	b508      	push	{r3, lr}
 8000510:	201c      	movs	r0, #28
 8000512:	f007 fbed 	bl	8007cf0 <framework_irq_handler>
 8000516:	bd08      	pop	{r3, pc}

08000518 <EXTI3_IRQHandler>:

/* EXTI Line3 (IRQ 29) */
FRAMEWORK_DEFINE_IRQ_HANDLER(EXTI3_IRQHandler, 29)
 8000518:	b508      	push	{r3, lr}
 800051a:	201d      	movs	r0, #29
 800051c:	f007 fbe8 	bl	8007cf0 <framework_irq_handler>
 8000520:	bd08      	pop	{r3, pc}

08000522 <EXTI4_IRQHandler>:

/* EXTI Line4 (IRQ 30) */
FRAMEWORK_DEFINE_IRQ_HANDLER(EXTI4_IRQHandler, 30)
 8000522:	b508      	push	{r3, lr}
 8000524:	201e      	movs	r0, #30
 8000526:	f007 fbe3 	bl	8007cf0 <framework_irq_handler>
 800052a:	bd08      	pop	{r3, pc}

0800052c <EXTI5_IRQHandler>:

/* EXTI Line5 (IRQ 31) */
FRAMEWORK_DEFINE_IRQ_HANDLER(EXTI5_IRQHandler, 31)
 800052c:	b508      	push	{r3, lr}
 800052e:	201f      	movs	r0, #31
 8000530:	f007 fbde 	bl	8007cf0 <framework_irq_handler>
 8000534:	bd08      	pop	{r3, pc}

08000536 <EXTI6_IRQHandler>:

/* EXTI Line6 (IRQ 32) */
FRAMEWORK_DEFINE_IRQ_HANDLER(EXTI6_IRQHandler, 32)
 8000536:	b508      	push	{r3, lr}
 8000538:	2020      	movs	r0, #32
 800053a:	f007 fbd9 	bl	8007cf0 <framework_irq_handler>
 800053e:	bd08      	pop	{r3, pc}

08000540 <EXTI7_IRQHandler>:

/* EXTI Line7 (IRQ 33) */
FRAMEWORK_DEFINE_IRQ_HANDLER(EXTI7_IRQHandler, 33)
 8000540:	b508      	push	{r3, lr}
 8000542:	2021      	movs	r0, #33	@ 0x21
 8000544:	f007 fbd4 	bl	8007cf0 <framework_irq_handler>
 8000548:	bd08      	pop	{r3, pc}

0800054a <EXTI8_IRQHandler>:

/* EXTI Line8 (IRQ 34) */
FRAMEWORK_DEFINE_IRQ_HANDLER(EXTI8_IRQHandler, 34)
 800054a:	b508      	push	{r3, lr}
 800054c:	2022      	movs	r0, #34	@ 0x22
 800054e:	f007 fbcf 	bl	8007cf0 <framework_irq_handler>
 8000552:	bd08      	pop	{r3, pc}

08000554 <EXTI9_IRQHandler>:

/* EXTI Line9 (IRQ 35) */
FRAMEWORK_DEFINE_IRQ_HANDLER(EXTI9_IRQHandler, 35)
 8000554:	b508      	push	{r3, lr}
 8000556:	2023      	movs	r0, #35	@ 0x23
 8000558:	f007 fbca 	bl	8007cf0 <framework_irq_handler>
 800055c:	bd08      	pop	{r3, pc}

0800055e <EXTI10_IRQHandler>:

/* EXTI Line10 (IRQ 36) */
FRAMEWORK_DEFINE_IRQ_HANDLER(EXTI10_IRQHandler, 36)
 800055e:	b508      	push	{r3, lr}
 8000560:	2024      	movs	r0, #36	@ 0x24
 8000562:	f007 fbc5 	bl	8007cf0 <framework_irq_handler>
 8000566:	bd08      	pop	{r3, pc}

08000568 <EXTI11_IRQHandler>:

/* EXTI Line11 (IRQ 37) */
FRAMEWORK_DEFINE_IRQ_HANDLER(EXTI11_IRQHandler, 37)
 8000568:	b508      	push	{r3, lr}
 800056a:	2025      	movs	r0, #37	@ 0x25
 800056c:	f007 fbc0 	bl	8007cf0 <framework_irq_handler>
 8000570:	bd08      	pop	{r3, pc}

08000572 <EXTI12_IRQHandler>:

/* EXTI Line12 (IRQ 38) */
FRAMEWORK_DEFINE_IRQ_HANDLER(EXTI12_IRQHandler, 38)
 8000572:	b508      	push	{r3, lr}
 8000574:	2026      	movs	r0, #38	@ 0x26
 8000576:	f007 fbbb 	bl	8007cf0 <framework_irq_handler>
 800057a:	bd08      	pop	{r3, pc}

0800057c <EXTI13_IRQHandler>:

/* EXTI Line13 (IRQ 39) */
FRAMEWORK_DEFINE_IRQ_HANDLER(EXTI13_IRQHandler, 39)
 800057c:	b508      	push	{r3, lr}
 800057e:	2027      	movs	r0, #39	@ 0x27
 8000580:	f007 fbb6 	bl	8007cf0 <framework_irq_handler>
 8000584:	bd08      	pop	{r3, pc}

08000586 <EXTI14_IRQHandler>:

/* EXTI Line14 (IRQ 40) */
FRAMEWORK_DEFINE_IRQ_HANDLER(EXTI14_IRQHandler, 40)
 8000586:	b508      	push	{r3, lr}
 8000588:	2028      	movs	r0, #40	@ 0x28
 800058a:	f007 fbb1 	bl	8007cf0 <framework_irq_handler>
 800058e:	bd08      	pop	{r3, pc}

08000590 <EXTI15_IRQHandler>:

/* EXTI Line15 (IRQ 41) */
FRAMEWORK_DEFINE_IRQ_HANDLER(EXTI15_IRQHandler, 41)
 8000590:	b508      	push	{r3, lr}
 8000592:	2029      	movs	r0, #41	@ 0x29
 8000594:	f007 fbac 	bl	8007cf0 <framework_irq_handler>
 8000598:	bd08      	pop	{r3, pc}

0800059a <GPDMA1_Channel0_IRQHandler>:

/* GPDMA1 Channel 0 (IRQ 42) */
FRAMEWORK_DEFINE_IRQ_HANDLER(GPDMA1_Channel0_IRQHandler, 42)
 800059a:	b508      	push	{r3, lr}
 800059c:	202a      	movs	r0, #42	@ 0x2a
 800059e:	f007 fba7 	bl	8007cf0 <framework_irq_handler>
 80005a2:	bd08      	pop	{r3, pc}

080005a4 <GPDMA1_Channel1_IRQHandler>:

/* GPDMA1 Channel 1 (IRQ 43) */
FRAMEWORK_DEFINE_IRQ_HANDLER(GPDMA1_Channel1_IRQHandler, 43)
 80005a4:	b508      	push	{r3, lr}
 80005a6:	202b      	movs	r0, #43	@ 0x2b
 80005a8:	f007 fba2 	bl	8007cf0 <framework_irq_handler>
 80005ac:	bd08      	pop	{r3, pc}

080005ae <GPDMA1_Channel2_IRQHandler>:

/* GPDMA1 Channel 2 (IRQ 44) */
FRAMEWORK_DEFINE_IRQ_HANDLER(GPDMA1_Channel2_IRQHandler, 44)
 80005ae:	b508      	push	{r3, lr}
 80005b0:	202c      	movs	r0, #44	@ 0x2c
 80005b2:	f007 fb9d 	bl	8007cf0 <framework_irq_handler>
 80005b6:	bd08      	pop	{r3, pc}

080005b8 <GPDMA1_Channel3_IRQHandler>:

/* GPDMA1 Channel 3 (IRQ 45) */
FRAMEWORK_DEFINE_IRQ_HANDLER(GPDMA1_Channel3_IRQHandler, 45)
 80005b8:	b508      	push	{r3, lr}
 80005ba:	202d      	movs	r0, #45	@ 0x2d
 80005bc:	f007 fb98 	bl	8007cf0 <framework_irq_handler>
 80005c0:	bd08      	pop	{r3, pc}

080005c2 <GPDMA1_Channel4_IRQHandler>:

/* GPDMA1 Channel 4 (IRQ 46) */
FRAMEWORK_DEFINE_IRQ_HANDLER(GPDMA1_Channel4_IRQHandler, 46)
 80005c2:	b508      	push	{r3, lr}
 80005c4:	202e      	movs	r0, #46	@ 0x2e
 80005c6:	f007 fb93 	bl	8007cf0 <framework_irq_handler>
 80005ca:	bd08      	pop	{r3, pc}

080005cc <GPDMA1_Channel5_IRQHandler>:

/* GPDMA1 Channel 5 (IRQ 47) */
FRAMEWORK_DEFINE_IRQ_HANDLER(GPDMA1_Channel5_IRQHandler, 47)
 80005cc:	b508      	push	{r3, lr}
 80005ce:	202f      	movs	r0, #47	@ 0x2f
 80005d0:	f007 fb8e 	bl	8007cf0 <framework_irq_handler>
 80005d4:	bd08      	pop	{r3, pc}

080005d6 <GPDMA1_Channel6_IRQHandler>:

/* GPDMA1 Channel 6 (IRQ 48) */
FRAMEWORK_DEFINE_IRQ_HANDLER(GPDMA1_Channel6_IRQHandler, 48)
 80005d6:	b508      	push	{r3, lr}
 80005d8:	2030      	movs	r0, #48	@ 0x30
 80005da:	f007 fb89 	bl	8007cf0 <framework_irq_handler>
 80005de:	bd08      	pop	{r3, pc}

080005e0 <GPDMA1_Channel7_IRQHandler>:

/* GPDMA1 Channel 7 (IRQ 49) */
FRAMEWORK_DEFINE_IRQ_HANDLER(GPDMA1_Channel7_IRQHandler, 49)
 80005e0:	b508      	push	{r3, lr}
 80005e2:	2031      	movs	r0, #49	@ 0x31
 80005e4:	f007 fb84 	bl	8007cf0 <framework_irq_handler>
 80005e8:	bd08      	pop	{r3, pc}

080005ea <IWDG_IRQHandler>:

/* IWDG (IRQ 50) */
FRAMEWORK_DEFINE_IRQ_HANDLER(IWDG_IRQHandler, 50)
 80005ea:	b508      	push	{r3, lr}
 80005ec:	2032      	movs	r0, #50	@ 0x32
 80005ee:	f007 fb7f 	bl	8007cf0 <framework_irq_handler>
 80005f2:	bd08      	pop	{r3, pc}

080005f4 <ADC1_IRQHandler>:

/* ADC1 (IRQ 52) */
FRAMEWORK_DEFINE_IRQ_HANDLER(ADC1_IRQHandler, 52)
 80005f4:	b508      	push	{r3, lr}
 80005f6:	2034      	movs	r0, #52	@ 0x34
 80005f8:	f007 fb7a 	bl	8007cf0 <framework_irq_handler>
 80005fc:	bd08      	pop	{r3, pc}

080005fe <DAC1_IRQHandler>:

/* DAC1 (IRQ 53) */
FRAMEWORK_DEFINE_IRQ_HANDLER(DAC1_IRQHandler, 53)
 80005fe:	b508      	push	{r3, lr}
 8000600:	2035      	movs	r0, #53	@ 0x35
 8000602:	f007 fb75 	bl	8007cf0 <framework_irq_handler>
 8000606:	bd08      	pop	{r3, pc}

08000608 <FDCAN1_IT0_IRQHandler>:

/* FDCAN1 IT0 (IRQ 54) */
FRAMEWORK_DEFINE_IRQ_HANDLER(FDCAN1_IT0_IRQHandler, 54)
 8000608:	b508      	push	{r3, lr}
 800060a:	2036      	movs	r0, #54	@ 0x36
 800060c:	f007 fb70 	bl	8007cf0 <framework_irq_handler>
 8000610:	bd08      	pop	{r3, pc}

08000612 <FDCAN1_IT1_IRQHandler>:

/* FDCAN1 IT1 (IRQ 55) */
FRAMEWORK_DEFINE_IRQ_HANDLER(FDCAN1_IT1_IRQHandler, 55)
 8000612:	b508      	push	{r3, lr}
 8000614:	2037      	movs	r0, #55	@ 0x37
 8000616:	f007 fb6b 	bl	8007cf0 <framework_irq_handler>
 800061a:	bd08      	pop	{r3, pc}

0800061c <TIM1_BRK_IRQHandler>:

/* TIM1 Break (IRQ 56) */
FRAMEWORK_DEFINE_IRQ_HANDLER(TIM1_BRK_IRQHandler, 56)
 800061c:	b508      	push	{r3, lr}
 800061e:	2038      	movs	r0, #56	@ 0x38
 8000620:	f007 fb66 	bl	8007cf0 <framework_irq_handler>
 8000624:	bd08      	pop	{r3, pc}

08000626 <TIM1_UP_IRQHandler>:

/* TIM1 Update (IRQ 57) */
FRAMEWORK_DEFINE_IRQ_HANDLER(TIM1_UP_IRQHandler, 57)
 8000626:	b508      	push	{r3, lr}
 8000628:	2039      	movs	r0, #57	@ 0x39
 800062a:	f007 fb61 	bl	8007cf0 <framework_irq_handler>
 800062e:	bd08      	pop	{r3, pc}

08000630 <TIM1_TRG_COM_IRQHandler>:

/* TIM1 Trigger and Commutation (IRQ 58) */
FRAMEWORK_DEFINE_IRQ_HANDLER(TIM1_TRG_COM_IRQHandler, 58)
 8000630:	b508      	push	{r3, lr}
 8000632:	203a      	movs	r0, #58	@ 0x3a
 8000634:	f007 fb5c 	bl	8007cf0 <framework_irq_handler>
 8000638:	bd08      	pop	{r3, pc}

0800063a <TIM1_CC_IRQHandler>:

/* TIM1 Capture Compare (IRQ 59) */
FRAMEWORK_DEFINE_IRQ_HANDLER(TIM1_CC_IRQHandler, 59)
 800063a:	b508      	push	{r3, lr}
 800063c:	203b      	movs	r0, #59	@ 0x3b
 800063e:	f007 fb57 	bl	8007cf0 <framework_irq_handler>
 8000642:	bd08      	pop	{r3, pc}

08000644 <TIM2_IRQHandler>:

/* TIM2 (IRQ 60) */
FRAMEWORK_DEFINE_IRQ_HANDLER(TIM2_IRQHandler, 60)
 8000644:	b508      	push	{r3, lr}
 8000646:	203c      	movs	r0, #60	@ 0x3c
 8000648:	f007 fb52 	bl	8007cf0 <framework_irq_handler>
 800064c:	bd08      	pop	{r3, pc}

0800064e <TIM3_IRQHandler>:

/* TIM3 (IRQ 61) */
FRAMEWORK_DEFINE_IRQ_HANDLER(TIM3_IRQHandler, 61)
 800064e:	b508      	push	{r3, lr}
 8000650:	203d      	movs	r0, #61	@ 0x3d
 8000652:	f007 fb4d 	bl	8007cf0 <framework_irq_handler>
 8000656:	bd08      	pop	{r3, pc}

08000658 <TIM4_IRQHandler>:

/* TIM4 (IRQ 62) */
FRAMEWORK_DEFINE_IRQ_HANDLER(TIM4_IRQHandler, 62)
 8000658:	b508      	push	{r3, lr}
 800065a:	203e      	movs	r0, #62	@ 0x3e
 800065c:	f007 fb48 	bl	8007cf0 <framework_irq_handler>
 8000660:	bd08      	pop	{r3, pc}

08000662 <TIM5_IRQHandler>:

/* TIM5 (IRQ 63) */
FRAMEWORK_DEFINE_IRQ_HANDLER(TIM5_IRQHandler, 63)
 8000662:	b508      	push	{r3, lr}
 8000664:	203f      	movs	r0, #63	@ 0x3f
 8000666:	f007 fb43 	bl	8007cf0 <framework_irq_handler>
 800066a:	bd08      	pop	{r3, pc}

0800066c <TIM6_IRQHandler>:

/* TIM6 (IRQ 64) */
FRAMEWORK_DEFINE_IRQ_HANDLER(TIM6_IRQHandler, 64)
 800066c:	b508      	push	{r3, lr}
 800066e:	2040      	movs	r0, #64	@ 0x40
 8000670:	f007 fb3e 	bl	8007cf0 <framework_irq_handler>
 8000674:	bd08      	pop	{r3, pc}

08000676 <TIM7_IRQHandler>:

/* TIM7 (IRQ 65) */
FRAMEWORK_DEFINE_IRQ_HANDLER(TIM7_IRQHandler, 65)
 8000676:	b508      	push	{r3, lr}
 8000678:	2041      	movs	r0, #65	@ 0x41
 800067a:	f007 fb39 	bl	8007cf0 <framework_irq_handler>
 800067e:	bd08      	pop	{r3, pc}

08000680 <I2C1_EV_IRQHandler>:

/* I2C1 Event (IRQ 66) */
FRAMEWORK_DEFINE_IRQ_HANDLER(I2C1_EV_IRQHandler, 66)
 8000680:	b508      	push	{r3, lr}
 8000682:	2042      	movs	r0, #66	@ 0x42
 8000684:	f007 fb34 	bl	8007cf0 <framework_irq_handler>
 8000688:	bd08      	pop	{r3, pc}

0800068a <I2C1_ER_IRQHandler>:

/* I2C1 Error (IRQ 67) */
FRAMEWORK_DEFINE_IRQ_HANDLER(I2C1_ER_IRQHandler, 67)
 800068a:	b508      	push	{r3, lr}
 800068c:	2043      	movs	r0, #67	@ 0x43
 800068e:	f007 fb2f 	bl	8007cf0 <framework_irq_handler>
 8000692:	bd08      	pop	{r3, pc}

08000694 <I2C2_EV_IRQHandler>:

/* I2C2 Event (IRQ 68) */
FRAMEWORK_DEFINE_IRQ_HANDLER(I2C2_EV_IRQHandler, 68)
 8000694:	b508      	push	{r3, lr}
 8000696:	2044      	movs	r0, #68	@ 0x44
 8000698:	f007 fb2a 	bl	8007cf0 <framework_irq_handler>
 800069c:	bd08      	pop	{r3, pc}

0800069e <I2C2_ER_IRQHandler>:

/* I2C2 Error (IRQ 69) */
FRAMEWORK_DEFINE_IRQ_HANDLER(I2C2_ER_IRQHandler, 69)
 800069e:	b508      	push	{r3, lr}
 80006a0:	2045      	movs	r0, #69	@ 0x45
 80006a2:	f007 fb25 	bl	8007cf0 <framework_irq_handler>
 80006a6:	bd08      	pop	{r3, pc}

080006a8 <SPI1_IRQHandler>:

/* SPI1 (IRQ 70) */
FRAMEWORK_DEFINE_IRQ_HANDLER(SPI1_IRQHandler, 70)
 80006a8:	b508      	push	{r3, lr}
 80006aa:	2046      	movs	r0, #70	@ 0x46
 80006ac:	f007 fb20 	bl	8007cf0 <framework_irq_handler>
 80006b0:	bd08      	pop	{r3, pc}

080006b2 <SPI2_IRQHandler>:

/* SPI2 (IRQ 71) */
FRAMEWORK_DEFINE_IRQ_HANDLER(SPI2_IRQHandler, 71)
 80006b2:	b508      	push	{r3, lr}
 80006b4:	2047      	movs	r0, #71	@ 0x47
 80006b6:	f007 fb1b 	bl	8007cf0 <framework_irq_handler>
 80006ba:	bd08      	pop	{r3, pc}

080006bc <SPI3_IRQHandler>:

/* SPI3 (IRQ 72) */
FRAMEWORK_DEFINE_IRQ_HANDLER(SPI3_IRQHandler, 72)
 80006bc:	b508      	push	{r3, lr}
 80006be:	2048      	movs	r0, #72	@ 0x48
 80006c0:	f007 fb16 	bl	8007cf0 <framework_irq_handler>
 80006c4:	bd08      	pop	{r3, pc}

080006c6 <USART1_IRQHandler>:

/* USART1 (IRQ 73) */
FRAMEWORK_DEFINE_IRQ_HANDLER(USART1_IRQHandler, 73)
 80006c6:	b508      	push	{r3, lr}
 80006c8:	2049      	movs	r0, #73	@ 0x49
 80006ca:	f007 fb11 	bl	8007cf0 <framework_irq_handler>
 80006ce:	bd08      	pop	{r3, pc}

080006d0 <USART2_IRQHandler>:

/* USART2 (IRQ 74) */
FRAMEWORK_DEFINE_IRQ_HANDLER(USART2_IRQHandler, 74)
 80006d0:	b508      	push	{r3, lr}
 80006d2:	204a      	movs	r0, #74	@ 0x4a
 80006d4:	f007 fb0c 	bl	8007cf0 <framework_irq_handler>
 80006d8:	bd08      	pop	{r3, pc}

080006da <USART3_IRQHandler>:

/* USART3 (IRQ 75) */
FRAMEWORK_DEFINE_IRQ_HANDLER(USART3_IRQHandler, 75)
 80006da:	b508      	push	{r3, lr}
 80006dc:	204b      	movs	r0, #75	@ 0x4b
 80006de:	f007 fb07 	bl	8007cf0 <framework_irq_handler>
 80006e2:	bd08      	pop	{r3, pc}

080006e4 <UART4_IRQHandler>:

/* UART4 (IRQ 76) */
FRAMEWORK_DEFINE_IRQ_HANDLER(UART4_IRQHandler, 76)
 80006e4:	b508      	push	{r3, lr}
 80006e6:	204c      	movs	r0, #76	@ 0x4c
 80006e8:	f007 fb02 	bl	8007cf0 <framework_irq_handler>
 80006ec:	bd08      	pop	{r3, pc}

080006ee <UART5_IRQHandler>:

/* UART5 (IRQ 77) */
FRAMEWORK_DEFINE_IRQ_HANDLER(UART5_IRQHandler, 77)
 80006ee:	b508      	push	{r3, lr}
 80006f0:	204d      	movs	r0, #77	@ 0x4d
 80006f2:	f007 fafd 	bl	8007cf0 <framework_irq_handler>
 80006f6:	bd08      	pop	{r3, pc}

080006f8 <LPUART1_IRQHandler>:

/* LPUART1 (IRQ 78) */
FRAMEWORK_DEFINE_IRQ_HANDLER(LPUART1_IRQHandler, 78)
 80006f8:	b508      	push	{r3, lr}
 80006fa:	204e      	movs	r0, #78	@ 0x4e
 80006fc:	f007 faf8 	bl	8007cf0 <framework_irq_handler>
 8000700:	bd08      	pop	{r3, pc}

08000702 <LPTIM1_IRQHandler>:

/* LPTIM1 (IRQ 79) */
FRAMEWORK_DEFINE_IRQ_HANDLER(LPTIM1_IRQHandler, 79)
 8000702:	b508      	push	{r3, lr}
 8000704:	204f      	movs	r0, #79	@ 0x4f
 8000706:	f007 faf3 	bl	8007cf0 <framework_irq_handler>
 800070a:	bd08      	pop	{r3, pc}

0800070c <TIM8_BRK_IRQHandler>:

/* TIM8 Break (IRQ 80) */
FRAMEWORK_DEFINE_IRQ_HANDLER(TIM8_BRK_IRQHandler, 80)
 800070c:	b508      	push	{r3, lr}
 800070e:	2050      	movs	r0, #80	@ 0x50
 8000710:	f007 faee 	bl	8007cf0 <framework_irq_handler>
 8000714:	bd08      	pop	{r3, pc}

08000716 <TIM8_UP_IRQHandler>:

/* TIM8 Update (IRQ 81) */
FRAMEWORK_DEFINE_IRQ_HANDLER(TIM8_UP_IRQHandler, 81)
 8000716:	b508      	push	{r3, lr}
 8000718:	2051      	movs	r0, #81	@ 0x51
 800071a:	f007 fae9 	bl	8007cf0 <framework_irq_handler>
 800071e:	bd08      	pop	{r3, pc}

08000720 <TIM8_TRG_COM_IRQHandler>:

/* TIM8 Trigger and Commutation (IRQ 82) */
FRAMEWORK_DEFINE_IRQ_HANDLER(TIM8_TRG_COM_IRQHandler, 82)
 8000720:	b508      	push	{r3, lr}
 8000722:	2052      	movs	r0, #82	@ 0x52
 8000724:	f007 fae4 	bl	8007cf0 <framework_irq_handler>
 8000728:	bd08      	pop	{r3, pc}

0800072a <TIM8_CC_IRQHandler>:

/* TIM8 Capture Compare (IRQ 83) */
FRAMEWORK_DEFINE_IRQ_HANDLER(TIM8_CC_IRQHandler, 83)
 800072a:	b508      	push	{r3, lr}
 800072c:	2053      	movs	r0, #83	@ 0x53
 800072e:	f007 fadf 	bl	8007cf0 <framework_irq_handler>
 8000732:	bd08      	pop	{r3, pc}

08000734 <ADC2_IRQHandler>:

/* ADC2 (IRQ 84) */
FRAMEWORK_DEFINE_IRQ_HANDLER(ADC2_IRQHandler, 84)
 8000734:	b508      	push	{r3, lr}
 8000736:	2054      	movs	r0, #84	@ 0x54
 8000738:	f007 fada 	bl	8007cf0 <framework_irq_handler>
 800073c:	bd08      	pop	{r3, pc}

0800073e <LPTIM2_IRQHandler>:

/* LPTIM2 (IRQ 85) */
FRAMEWORK_DEFINE_IRQ_HANDLER(LPTIM2_IRQHandler, 85)
 800073e:	b508      	push	{r3, lr}
 8000740:	2055      	movs	r0, #85	@ 0x55
 8000742:	f007 fad5 	bl	8007cf0 <framework_irq_handler>
 8000746:	bd08      	pop	{r3, pc}

08000748 <TIM15_IRQHandler>:

/* TIM15 (IRQ 86) */
FRAMEWORK_DEFINE_IRQ_HANDLER(TIM15_IRQHandler, 86)
 8000748:	b508      	push	{r3, lr}
 800074a:	2056      	movs	r0, #86	@ 0x56
 800074c:	f007 fad0 	bl	8007cf0 <framework_irq_handler>
 8000750:	bd08      	pop	{r3, pc}

08000752 <TIM16_IRQHandler>:

/* TIM16 (IRQ 87) */
FRAMEWORK_DEFINE_IRQ_HANDLER(TIM16_IRQHandler, 87)
 8000752:	b508      	push	{r3, lr}
 8000754:	2057      	movs	r0, #87	@ 0x57
 8000756:	f007 facb 	bl	8007cf0 <framework_irq_handler>
 800075a:	bd08      	pop	{r3, pc}

0800075c <TIM17_IRQHandler>:

/* TIM17 (IRQ 88) */
FRAMEWORK_DEFINE_IRQ_HANDLER(TIM17_IRQHandler, 88)
 800075c:	b508      	push	{r3, lr}
 800075e:	2058      	movs	r0, #88	@ 0x58
 8000760:	f007 fac6 	bl	8007cf0 <framework_irq_handler>
 8000764:	bd08      	pop	{r3, pc}

08000766 <USB_DRD_FS_IRQHandler>:

/* USB_DRD_FS (IRQ 89) */
FRAMEWORK_DEFINE_IRQ_HANDLER(USB_DRD_FS_IRQHandler, 89)
 8000766:	b508      	push	{r3, lr}
 8000768:	2059      	movs	r0, #89	@ 0x59
 800076a:	f007 fac1 	bl	8007cf0 <framework_irq_handler>
 800076e:	bd08      	pop	{r3, pc}

08000770 <CRS_IRQHandler>:

/* CRS (IRQ 90) */
FRAMEWORK_DEFINE_IRQ_HANDLER(CRS_IRQHandler, 90)
 8000770:	b508      	push	{r3, lr}
 8000772:	205a      	movs	r0, #90	@ 0x5a
 8000774:	f007 fabc 	bl	8007cf0 <framework_irq_handler>
 8000778:	bd08      	pop	{r3, pc}

0800077a <UCPD1_IRQHandler>:

/* UCPD1 (IRQ 91) */
FRAMEWORK_DEFINE_IRQ_HANDLER(UCPD1_IRQHandler, 91)
 800077a:	b508      	push	{r3, lr}
 800077c:	205b      	movs	r0, #91	@ 0x5b
 800077e:	f007 fab7 	bl	8007cf0 <framework_irq_handler>
 8000782:	bd08      	pop	{r3, pc}

08000784 <FMC_IRQHandler>:

/* FMC (IRQ 92) */
FRAMEWORK_DEFINE_IRQ_HANDLER(FMC_IRQHandler, 92)
 8000784:	b508      	push	{r3, lr}
 8000786:	205c      	movs	r0, #92	@ 0x5c
 8000788:	f007 fab2 	bl	8007cf0 <framework_irq_handler>
 800078c:	bd08      	pop	{r3, pc}

0800078e <OCTOSPI1_IRQHandler>:

/* OCTOSPI1 (IRQ 93) */
FRAMEWORK_DEFINE_IRQ_HANDLER(OCTOSPI1_IRQHandler, 93)
 800078e:	b508      	push	{r3, lr}
 8000790:	205d      	movs	r0, #93	@ 0x5d
 8000792:	f007 faad 	bl	8007cf0 <framework_irq_handler>
 8000796:	bd08      	pop	{r3, pc}

08000798 <SDMMC1_IRQHandler>:

/* SDMMC1 (IRQ 94) */
FRAMEWORK_DEFINE_IRQ_HANDLER(SDMMC1_IRQHandler, 94)
 8000798:	b508      	push	{r3, lr}
 800079a:	205e      	movs	r0, #94	@ 0x5e
 800079c:	f007 faa8 	bl	8007cf0 <framework_irq_handler>
 80007a0:	bd08      	pop	{r3, pc}

080007a2 <I2C3_EV_IRQHandler>:

/* I2C3 Event (IRQ 95) */
FRAMEWORK_DEFINE_IRQ_HANDLER(I2C3_EV_IRQHandler, 95)
 80007a2:	b508      	push	{r3, lr}
 80007a4:	205f      	movs	r0, #95	@ 0x5f
 80007a6:	f007 faa3 	bl	8007cf0 <framework_irq_handler>
 80007aa:	bd08      	pop	{r3, pc}

080007ac <I2C3_ER_IRQHandler>:

/* I2C3 Error (IRQ 96) */
FRAMEWORK_DEFINE_IRQ_HANDLER(I2C3_ER_IRQHandler, 96)
 80007ac:	b508      	push	{r3, lr}
 80007ae:	2060      	movs	r0, #96	@ 0x60
 80007b0:	f007 fa9e 	bl	8007cf0 <framework_irq_handler>
 80007b4:	bd08      	pop	{r3, pc}

080007b6 <SPI4_IRQHandler>:

/* SPI4 (IRQ 97) */
FRAMEWORK_DEFINE_IRQ_HANDLER(SPI4_IRQHandler, 97)
 80007b6:	b508      	push	{r3, lr}
 80007b8:	2061      	movs	r0, #97	@ 0x61
 80007ba:	f007 fa99 	bl	8007cf0 <framework_irq_handler>
 80007be:	bd08      	pop	{r3, pc}

080007c0 <SPI5_IRQHandler>:

/* SPI5 (IRQ 98) */
FRAMEWORK_DEFINE_IRQ_HANDLER(SPI5_IRQHandler, 98)
 80007c0:	b508      	push	{r3, lr}
 80007c2:	2062      	movs	r0, #98	@ 0x62
 80007c4:	f007 fa94 	bl	8007cf0 <framework_irq_handler>
 80007c8:	bd08      	pop	{r3, pc}

080007ca <SPI6_IRQHandler>:

/* SPI6 (IRQ 99) */
FRAMEWORK_DEFINE_IRQ_HANDLER(SPI6_IRQHandler, 99)
 80007ca:	b508      	push	{r3, lr}
 80007cc:	2063      	movs	r0, #99	@ 0x63
 80007ce:	f007 fa8f 	bl	8007cf0 <framework_irq_handler>
 80007d2:	bd08      	pop	{r3, pc}

080007d4 <USART6_IRQHandler>:

/* USART6 (IRQ 100) */
FRAMEWORK_DEFINE_IRQ_HANDLER(USART6_IRQHandler, 100)
 80007d4:	b508      	push	{r3, lr}
 80007d6:	2064      	movs	r0, #100	@ 0x64
 80007d8:	f007 fa8a 	bl	8007cf0 <framework_irq_handler>
 80007dc:	bd08      	pop	{r3, pc}

080007de <USART10_IRQHandler>:

/* USART10 (IRQ 101) */
FRAMEWORK_DEFINE_IRQ_HANDLER(USART10_IRQHandler, 101)
 80007de:	b508      	push	{r3, lr}
 80007e0:	2065      	movs	r0, #101	@ 0x65
 80007e2:	f007 fa85 	bl	8007cf0 <framework_irq_handler>
 80007e6:	bd08      	pop	{r3, pc}

080007e8 <USART11_IRQHandler>:

/* USART11 (IRQ 102) */
FRAMEWORK_DEFINE_IRQ_HANDLER(USART11_IRQHandler, 102)
 80007e8:	b508      	push	{r3, lr}
 80007ea:	2066      	movs	r0, #102	@ 0x66
 80007ec:	f007 fa80 	bl	8007cf0 <framework_irq_handler>
 80007f0:	bd08      	pop	{r3, pc}

080007f2 <SAI1_IRQHandler>:

/* SAI1 (IRQ 103) */
FRAMEWORK_DEFINE_IRQ_HANDLER(SAI1_IRQHandler, 103)
 80007f2:	b508      	push	{r3, lr}
 80007f4:	2067      	movs	r0, #103	@ 0x67
 80007f6:	f007 fa7b 	bl	8007cf0 <framework_irq_handler>
 80007fa:	bd08      	pop	{r3, pc}

080007fc <SAI2_IRQHandler>:

/* SAI2 (IRQ 104) */
FRAMEWORK_DEFINE_IRQ_HANDLER(SAI2_IRQHandler, 104)
 80007fc:	b508      	push	{r3, lr}
 80007fe:	2068      	movs	r0, #104	@ 0x68
 8000800:	f007 fa76 	bl	8007cf0 <framework_irq_handler>
 8000804:	bd08      	pop	{r3, pc}

08000806 <GPDMA2_Channel0_IRQHandler>:

/* GPDMA2 Channel 0 (IRQ 105) */
FRAMEWORK_DEFINE_IRQ_HANDLER(GPDMA2_Channel0_IRQHandler, 105)
 8000806:	b508      	push	{r3, lr}
 8000808:	2069      	movs	r0, #105	@ 0x69
 800080a:	f007 fa71 	bl	8007cf0 <framework_irq_handler>
 800080e:	bd08      	pop	{r3, pc}

08000810 <GPDMA2_Channel1_IRQHandler>:

/* GPDMA2 Channel 1 (IRQ 106) */
FRAMEWORK_DEFINE_IRQ_HANDLER(GPDMA2_Channel1_IRQHandler, 106)
 8000810:	b508      	push	{r3, lr}
 8000812:	206a      	movs	r0, #106	@ 0x6a
 8000814:	f007 fa6c 	bl	8007cf0 <framework_irq_handler>
 8000818:	bd08      	pop	{r3, pc}

0800081a <GPDMA2_Channel2_IRQHandler>:

/* GPDMA2 Channel 2 (IRQ 107) */
FRAMEWORK_DEFINE_IRQ_HANDLER(GPDMA2_Channel2_IRQHandler, 107)
 800081a:	b508      	push	{r3, lr}
 800081c:	206b      	movs	r0, #107	@ 0x6b
 800081e:	f007 fa67 	bl	8007cf0 <framework_irq_handler>
 8000822:	bd08      	pop	{r3, pc}

08000824 <GPDMA2_Channel3_IRQHandler>:

/* GPDMA2 Channel 3 (IRQ 108) */
FRAMEWORK_DEFINE_IRQ_HANDLER(GPDMA2_Channel3_IRQHandler, 108)
 8000824:	b508      	push	{r3, lr}
 8000826:	206c      	movs	r0, #108	@ 0x6c
 8000828:	f007 fa62 	bl	8007cf0 <framework_irq_handler>
 800082c:	bd08      	pop	{r3, pc}

0800082e <GPDMA2_Channel4_IRQHandler>:

/* GPDMA2 Channel 4 (IRQ 109) */
FRAMEWORK_DEFINE_IRQ_HANDLER(GPDMA2_Channel4_IRQHandler, 109)
 800082e:	b508      	push	{r3, lr}
 8000830:	206d      	movs	r0, #109	@ 0x6d
 8000832:	f007 fa5d 	bl	8007cf0 <framework_irq_handler>
 8000836:	bd08      	pop	{r3, pc}

08000838 <GPDMA2_Channel5_IRQHandler>:

/* GPDMA2 Channel 5 (IRQ 110) */
FRAMEWORK_DEFINE_IRQ_HANDLER(GPDMA2_Channel5_IRQHandler, 110)
 8000838:	b508      	push	{r3, lr}
 800083a:	206e      	movs	r0, #110	@ 0x6e
 800083c:	f007 fa58 	bl	8007cf0 <framework_irq_handler>
 8000840:	bd08      	pop	{r3, pc}

08000842 <GPDMA2_Channel6_IRQHandler>:

/* GPDMA2 Channel 6 (IRQ 111) */
FRAMEWORK_DEFINE_IRQ_HANDLER(GPDMA2_Channel6_IRQHandler, 111)
 8000842:	b508      	push	{r3, lr}
 8000844:	206f      	movs	r0, #111	@ 0x6f
 8000846:	f007 fa53 	bl	8007cf0 <framework_irq_handler>
 800084a:	bd08      	pop	{r3, pc}

0800084c <GPDMA2_Channel7_IRQHandler>:

/* GPDMA2 Channel 7 (IRQ 112) */
FRAMEWORK_DEFINE_IRQ_HANDLER(GPDMA2_Channel7_IRQHandler, 112)
 800084c:	b508      	push	{r3, lr}
 800084e:	2070      	movs	r0, #112	@ 0x70
 8000850:	f007 fa4e 	bl	8007cf0 <framework_irq_handler>
 8000854:	bd08      	pop	{r3, pc}

08000856 <UART7_IRQHandler>:

/* UART7 (IRQ 113) */
FRAMEWORK_DEFINE_IRQ_HANDLER(UART7_IRQHandler, 113)
 8000856:	b508      	push	{r3, lr}
 8000858:	2071      	movs	r0, #113	@ 0x71
 800085a:	f007 fa49 	bl	8007cf0 <framework_irq_handler>
 800085e:	bd08      	pop	{r3, pc}

08000860 <UART8_IRQHandler>:

/* UART8 (IRQ 114) */
FRAMEWORK_DEFINE_IRQ_HANDLER(UART8_IRQHandler, 114)
 8000860:	b508      	push	{r3, lr}
 8000862:	2072      	movs	r0, #114	@ 0x72
 8000864:	f007 fa44 	bl	8007cf0 <framework_irq_handler>
 8000868:	bd08      	pop	{r3, pc}

0800086a <UART9_IRQHandler>:

/* UART9 (IRQ 115) */
FRAMEWORK_DEFINE_IRQ_HANDLER(UART9_IRQHandler, 115)
 800086a:	b508      	push	{r3, lr}
 800086c:	2073      	movs	r0, #115	@ 0x73
 800086e:	f007 fa3f 	bl	8007cf0 <framework_irq_handler>
 8000872:	bd08      	pop	{r3, pc}

08000874 <UART12_IRQHandler>:

/* UART12 (IRQ 116) */
FRAMEWORK_DEFINE_IRQ_HANDLER(UART12_IRQHandler, 116)
 8000874:	b508      	push	{r3, lr}
 8000876:	2074      	movs	r0, #116	@ 0x74
 8000878:	f007 fa3a 	bl	8007cf0 <framework_irq_handler>
 800087c:	bd08      	pop	{r3, pc}

0800087e <SDMMC2_IRQHandler>:

/* SDMMC2 (IRQ 117) */
FRAMEWORK_DEFINE_IRQ_HANDLER(SDMMC2_IRQHandler, 117)
 800087e:	b508      	push	{r3, lr}
 8000880:	2075      	movs	r0, #117	@ 0x75
 8000882:	f007 fa35 	bl	8007cf0 <framework_irq_handler>
 8000886:	bd08      	pop	{r3, pc}

08000888 <FPU_IRQHandler>:

/* FPU (IRQ 118) */
FRAMEWORK_DEFINE_IRQ_HANDLER(FPU_IRQHandler, 118)
 8000888:	b508      	push	{r3, lr}
 800088a:	2076      	movs	r0, #118	@ 0x76
 800088c:	f007 fa30 	bl	8007cf0 <framework_irq_handler>
 8000890:	bd08      	pop	{r3, pc}

08000892 <ICACHE_IRQHandler>:

/* ICACHE (IRQ 119) */
FRAMEWORK_DEFINE_IRQ_HANDLER(ICACHE_IRQHandler, 119)
 8000892:	b508      	push	{r3, lr}
 8000894:	2077      	movs	r0, #119	@ 0x77
 8000896:	f007 fa2b 	bl	8007cf0 <framework_irq_handler>
 800089a:	bd08      	pop	{r3, pc}

0800089c <DCACHE1_IRQHandler>:

/* DCACHE1 (IRQ 120) */
FRAMEWORK_DEFINE_IRQ_HANDLER(DCACHE1_IRQHandler, 120)
 800089c:	b508      	push	{r3, lr}
 800089e:	2078      	movs	r0, #120	@ 0x78
 80008a0:	f007 fa26 	bl	8007cf0 <framework_irq_handler>
 80008a4:	bd08      	pop	{r3, pc}

080008a6 <ETH_IRQHandler>:

/* ETH (IRQ 121) */
FRAMEWORK_DEFINE_IRQ_HANDLER(ETH_IRQHandler, 121)
 80008a6:	b508      	push	{r3, lr}
 80008a8:	2079      	movs	r0, #121	@ 0x79
 80008aa:	f007 fa21 	bl	8007cf0 <framework_irq_handler>
 80008ae:	bd08      	pop	{r3, pc}

080008b0 <ETH_WKUP_IRQHandler>:

/* ETH_WKUP (IRQ 122) */
FRAMEWORK_DEFINE_IRQ_HANDLER(ETH_WKUP_IRQHandler, 122)
 80008b0:	b508      	push	{r3, lr}
 80008b2:	207a      	movs	r0, #122	@ 0x7a
 80008b4:	f007 fa1c 	bl	8007cf0 <framework_irq_handler>
 80008b8:	bd08      	pop	{r3, pc}

080008ba <DCMI_PSSI_IRQHandler>:

/* DCMI_PSSI (IRQ 123) */
FRAMEWORK_DEFINE_IRQ_HANDLER(DCMI_PSSI_IRQHandler, 123)
 80008ba:	b508      	push	{r3, lr}
 80008bc:	207b      	movs	r0, #123	@ 0x7b
 80008be:	f007 fa17 	bl	8007cf0 <framework_irq_handler>
 80008c2:	bd08      	pop	{r3, pc}

080008c4 <FDCAN2_IT0_IRQHandler>:

/* FDCAN2 IT0 (IRQ 124) */
FRAMEWORK_DEFINE_IRQ_HANDLER(FDCAN2_IT0_IRQHandler, 124)
 80008c4:	b508      	push	{r3, lr}
 80008c6:	207c      	movs	r0, #124	@ 0x7c
 80008c8:	f007 fa12 	bl	8007cf0 <framework_irq_handler>
 80008cc:	bd08      	pop	{r3, pc}

080008ce <FDCAN2_IT1_IRQHandler>:

/* FDCAN2 IT1 (IRQ 125) */
FRAMEWORK_DEFINE_IRQ_HANDLER(FDCAN2_IT1_IRQHandler, 125)
 80008ce:	b508      	push	{r3, lr}
 80008d0:	207d      	movs	r0, #125	@ 0x7d
 80008d2:	f007 fa0d 	bl	8007cf0 <framework_irq_handler>
 80008d6:	bd08      	pop	{r3, pc}

080008d8 <CORDIC_IRQHandler>:

/* CORDIC (IRQ 126) */
FRAMEWORK_DEFINE_IRQ_HANDLER(CORDIC_IRQHandler, 126)
 80008d8:	b508      	push	{r3, lr}
 80008da:	207e      	movs	r0, #126	@ 0x7e
 80008dc:	f007 fa08 	bl	8007cf0 <framework_irq_handler>
 80008e0:	bd08      	pop	{r3, pc}

080008e2 <FMAC_IRQHandler>:

/* FMAC (IRQ 127) */
FRAMEWORK_DEFINE_IRQ_HANDLER(FMAC_IRQHandler, 127)
 80008e2:	b508      	push	{r3, lr}
 80008e4:	207f      	movs	r0, #127	@ 0x7f
 80008e6:	f007 fa03 	bl	8007cf0 <framework_irq_handler>
 80008ea:	bd08      	pop	{r3, pc}

080008ec <DTS_IRQHandler>:

/* DTS (IRQ 128) */
FRAMEWORK_DEFINE_IRQ_HANDLER(DTS_IRQHandler, 128)
 80008ec:	b508      	push	{r3, lr}
 80008ee:	2080      	movs	r0, #128	@ 0x80
 80008f0:	f007 f9fe 	bl	8007cf0 <framework_irq_handler>
 80008f4:	bd08      	pop	{r3, pc}

080008f6 <RNG_IRQHandler>:

/* RNG (IRQ 129) */
FRAMEWORK_DEFINE_IRQ_HANDLER(RNG_IRQHandler, 129)
 80008f6:	b508      	push	{r3, lr}
 80008f8:	2081      	movs	r0, #129	@ 0x81
 80008fa:	f007 f9f9 	bl	8007cf0 <framework_irq_handler>
 80008fe:	bd08      	pop	{r3, pc}

08000900 <HASH_IRQHandler>:

/* HASH (IRQ 132) */
FRAMEWORK_DEFINE_IRQ_HANDLER(HASH_IRQHandler, 132)
 8000900:	b508      	push	{r3, lr}
 8000902:	2084      	movs	r0, #132	@ 0x84
 8000904:	f007 f9f4 	bl	8007cf0 <framework_irq_handler>
 8000908:	bd08      	pop	{r3, pc}

0800090a <CEC_IRQHandler>:

/* CEC (IRQ 134) */
FRAMEWORK_DEFINE_IRQ_HANDLER(CEC_IRQHandler, 134)
 800090a:	b508      	push	{r3, lr}
 800090c:	2086      	movs	r0, #134	@ 0x86
 800090e:	f007 f9ef 	bl	8007cf0 <framework_irq_handler>
 8000912:	bd08      	pop	{r3, pc}

08000914 <TIM12_IRQHandler>:

/* TIM12 (IRQ 135) */
FRAMEWORK_DEFINE_IRQ_HANDLER(TIM12_IRQHandler, 135)
 8000914:	b508      	push	{r3, lr}
 8000916:	2087      	movs	r0, #135	@ 0x87
 8000918:	f007 f9ea 	bl	8007cf0 <framework_irq_handler>
 800091c:	bd08      	pop	{r3, pc}

0800091e <TIM13_IRQHandler>:

/* TIM13 (IRQ 136) */
FRAMEWORK_DEFINE_IRQ_HANDLER(TIM13_IRQHandler, 136)
 800091e:	b508      	push	{r3, lr}
 8000920:	2088      	movs	r0, #136	@ 0x88
 8000922:	f007 f9e5 	bl	8007cf0 <framework_irq_handler>
 8000926:	bd08      	pop	{r3, pc}

08000928 <TIM14_IRQHandler>:

/* TIM14 (IRQ 137) */
FRAMEWORK_DEFINE_IRQ_HANDLER(TIM14_IRQHandler, 137)
 8000928:	b508      	push	{r3, lr}
 800092a:	2089      	movs	r0, #137	@ 0x89
 800092c:	f007 f9e0 	bl	8007cf0 <framework_irq_handler>
 8000930:	bd08      	pop	{r3, pc}

08000932 <I3C1_EV_IRQHandler>:

/* I3C1 Event (IRQ 138) */
FRAMEWORK_DEFINE_IRQ_HANDLER(I3C1_EV_IRQHandler, 138)
 8000932:	b508      	push	{r3, lr}
 8000934:	208a      	movs	r0, #138	@ 0x8a
 8000936:	f007 f9db 	bl	8007cf0 <framework_irq_handler>
 800093a:	bd08      	pop	{r3, pc}

0800093c <I3C1_ER_IRQHandler>:

/* I3C1 Error (IRQ 139) */
FRAMEWORK_DEFINE_IRQ_HANDLER(I3C1_ER_IRQHandler, 139)
 800093c:	b508      	push	{r3, lr}
 800093e:	208b      	movs	r0, #139	@ 0x8b
 8000940:	f007 f9d6 	bl	8007cf0 <framework_irq_handler>
 8000944:	bd08      	pop	{r3, pc}

08000946 <I2C4_EV_IRQHandler>:

/* I2C4 Event (IRQ 140) */
FRAMEWORK_DEFINE_IRQ_HANDLER(I2C4_EV_IRQHandler, 140)
 8000946:	b508      	push	{r3, lr}
 8000948:	208c      	movs	r0, #140	@ 0x8c
 800094a:	f007 f9d1 	bl	8007cf0 <framework_irq_handler>
 800094e:	bd08      	pop	{r3, pc}

08000950 <I2C4_ER_IRQHandler>:

/* I2C4 Error (IRQ 141) */
FRAMEWORK_DEFINE_IRQ_HANDLER(I2C4_ER_IRQHandler, 141)
 8000950:	b508      	push	{r3, lr}
 8000952:	208d      	movs	r0, #141	@ 0x8d
 8000954:	f007 f9cc 	bl	8007cf0 <framework_irq_handler>
 8000958:	bd08      	pop	{r3, pc}

0800095a <LPTIM3_IRQHandler>:

/* LPTIM3 (IRQ 142) */
FRAMEWORK_DEFINE_IRQ_HANDLER(LPTIM3_IRQHandler, 142)
 800095a:	b508      	push	{r3, lr}
 800095c:	208e      	movs	r0, #142	@ 0x8e
 800095e:	f007 f9c7 	bl	8007cf0 <framework_irq_handler>
 8000962:	bd08      	pop	{r3, pc}

08000964 <LPTIM4_IRQHandler>:

/* LPTIM4 (IRQ 143) */
FRAMEWORK_DEFINE_IRQ_HANDLER(LPTIM4_IRQHandler, 143)
 8000964:	b508      	push	{r3, lr}
 8000966:	208f      	movs	r0, #143	@ 0x8f
 8000968:	f007 f9c2 	bl	8007cf0 <framework_irq_handler>
 800096c:	bd08      	pop	{r3, pc}

0800096e <LPTIM5_IRQHandler>:

/* LPTIM5 (IRQ 144) */
FRAMEWORK_DEFINE_IRQ_HANDLER(LPTIM5_IRQHandler, 144)
 800096e:	b508      	push	{r3, lr}
 8000970:	2090      	movs	r0, #144	@ 0x90
 8000972:	f007 f9bd 	bl	8007cf0 <framework_irq_handler>
 8000976:	bd08      	pop	{r3, pc}

08000978 <LPTIM6_IRQHandler>:

/* LPTIM6 (IRQ 145) */
FRAMEWORK_DEFINE_IRQ_HANDLER(LPTIM6_IRQHandler, 145)
 8000978:	b508      	push	{r3, lr}
 800097a:	2091      	movs	r0, #145	@ 0x91
 800097c:	f007 f9b8 	bl	8007cf0 <framework_irq_handler>
 8000980:	bd08      	pop	{r3, pc}

08000982 <Reset_Handler>:
 *
 * This is the first code executed after reset.
 * It calls framework initialization functions and then framework_start().
 *----------------------------------------------------------------------------*/
void __attribute__((noreturn)) Reset_Handler(void)
{
 8000982:	b508      	push	{r3, lr}
    /* Note: Stack pointer is already initialized by hardware from vector table */

    /* 1. Initialize system clock using framework */
    framework_system_clock_init();
 8000984:	f007 f928 	bl	8007bd8 <framework_system_clock_init>

    /* 2. Initialize data sections using framework */
    framework_data_init();
 8000988:	f007 f92a 	bl	8007be0 <framework_data_init>

    /* 3. Call framework unified startup function */
    framework_start();
 800098c:	f007 f98e 	bl	8007cac <framework_start>

    /* Should never reach here */
    while (1)
 8000990:	e7fe      	b.n	8000990 <Reset_Handler+0xe>

08000992 <Default_Handler>:
    while (1)
 8000992:	e7fe      	b.n	8000992 <Default_Handler>

08000994 <NMI_Handler>:
void __attribute__((weak)) NMI_Handler(void) { Default_Handler(); }
 8000994:	b508      	push	{r3, lr}
 8000996:	f7ff fffc 	bl	8000992 <Default_Handler>
 800099a:	bd08      	pop	{r3, pc}

0800099c <MemManage_Handler>:
void __attribute__((weak)) MemManage_Handler(void) { Default_Handler(); }
 800099c:	b508      	push	{r3, lr}
 800099e:	f7ff fff8 	bl	8000992 <Default_Handler>
 80009a2:	bd08      	pop	{r3, pc}

080009a4 <BusFault_Handler>:
void __attribute__((weak)) BusFault_Handler(void) { Default_Handler(); }
 80009a4:	b508      	push	{r3, lr}
 80009a6:	f7ff fff4 	bl	8000992 <Default_Handler>
 80009aa:	bd08      	pop	{r3, pc}

080009ac <UsageFault_Handler>:
void __attribute__((weak)) UsageFault_Handler(void) { Default_Handler(); }
 80009ac:	b508      	push	{r3, lr}
 80009ae:	f7ff fff0 	bl	8000992 <Default_Handler>
 80009b2:	bd08      	pop	{r3, pc}

080009b4 <SecureFault_Handler>:
void __attribute__((weak)) SecureFault_Handler(void) { Default_Handler(); }
 80009b4:	b508      	push	{r3, lr}
 80009b6:	f7ff ffec 	bl	8000992 <Default_Handler>
 80009ba:	bd08      	pop	{r3, pc}

080009bc <DebugMon_Handler>:
void __attribute__((weak)) DebugMon_Handler(void) { Default_Handler(); }
 80009bc:	b508      	push	{r3, lr}
 80009be:	f7ff ffe8 	bl	8000992 <Default_Handler>
 80009c2:	bd08      	pop	{r3, pc}
{
 80009c4:	b508      	push	{r3, lr}
    framework_system_clock_init();
 80009c6:	f007 f907 	bl	8007bd8 <framework_system_clock_init>
}
 80009ca:	bd08      	pop	{r3, pc}

080009cc <SystemInit>:
  * @param  None
  * @retval None
  */

void SystemInit(void)
{
 80009cc:	b410      	push	{r4}
  uint32_t reg_opsr;

  /* FPU settings ------------------------------------------------------------*/
  #if (__FPU_PRESENT == 1) && (__FPU_USED == 1)
   SCB->CPACR |= ((3UL << 20U)|(3UL << 22U));  /* set CP10 and CP11 Full Access */
 80009ce:	4922      	ldr	r1, [pc, #136]	@ (8000a58 <SystemInit+0x8c>)
 80009d0:	f8d1 3088 	ldr.w	r3, [r1, #136]	@ 0x88
 80009d4:	f443 0370 	orr.w	r3, r3, #15728640	@ 0xf00000
 80009d8:	f8c1 3088 	str.w	r3, [r1, #136]	@ 0x88
  #endif

  /* Reset the RCC clock configuration to the default reset state ------------*/
  /* Set HSION bit */
  RCC->CR = RCC_CR_HSION;
 80009dc:	4b1f      	ldr	r3, [pc, #124]	@ (8000a5c <SystemInit+0x90>)
 80009de:	2201      	movs	r2, #1
 80009e0:	601a      	str	r2, [r3, #0]

  /* Reset CFGR register */
  RCC->CFGR1 = 0U;
 80009e2:	2200      	movs	r2, #0
 80009e4:	61da      	str	r2, [r3, #28]
  RCC->CFGR2 = 0U;
 80009e6:	621a      	str	r2, [r3, #32]

  /* Reset HSEON, HSECSSON, HSEBYP, HSEEXT, HSIDIV, HSIKERON, CSION, CSIKERON, HSI48 and PLLxON bits */
#if defined(RCC_CR_PLL3ON)
  RCC->CR &= ~(RCC_CR_HSEON | RCC_CR_HSECSSON | RCC_CR_HSEBYP | RCC_CR_HSEEXT | RCC_CR_HSIDIV | RCC_CR_HSIKERON | \
 80009e8:	681c      	ldr	r4, [r3, #0]
 80009ea:	481d      	ldr	r0, [pc, #116]	@ (8000a60 <SystemInit+0x94>)
 80009ec:	4020      	ands	r0, r4
 80009ee:	6018      	str	r0, [r3, #0]
  RCC->CR &= ~(RCC_CR_HSEON | RCC_CR_HSECSSON | RCC_CR_HSEBYP | RCC_CR_HSEEXT | RCC_CR_HSIDIV | RCC_CR_HSIKERON | \
               RCC_CR_CSION | RCC_CR_CSIKERON |RCC_CR_HSI48ON | RCC_CR_PLL1ON | RCC_CR_PLL2ON);
#endif

  /* Reset PLLxCFGR register */
  RCC->PLL1CFGR = 0U;
 80009f0:	629a      	str	r2, [r3, #40]	@ 0x28
  RCC->PLL2CFGR = 0U;
 80009f2:	62da      	str	r2, [r3, #44]	@ 0x2c
#if defined(RCC_CR_PLL3ON)
  RCC->PLL3CFGR = 0U;
 80009f4:	631a      	str	r2, [r3, #48]	@ 0x30
#endif /* RCC_CR_PLL3ON */

  /* Reset PLL1DIVR register */
  RCC->PLL1DIVR = 0x01010280U;
 80009f6:	481b      	ldr	r0, [pc, #108]	@ (8000a64 <SystemInit+0x98>)
 80009f8:	6358      	str	r0, [r3, #52]	@ 0x34
  /* Reset PLL1FRACR register */
  RCC->PLL1FRACR = 0x00000000U;
 80009fa:	639a      	str	r2, [r3, #56]	@ 0x38
  /* Reset PLL2DIVR register */
  RCC->PLL2DIVR = 0x01010280U;
 80009fc:	63d8      	str	r0, [r3, #60]	@ 0x3c
  /* Reset PLL2FRACR register */
  RCC->PLL2FRACR = 0x00000000U;
 80009fe:	641a      	str	r2, [r3, #64]	@ 0x40
#if defined(RCC_CR_PLL3ON)
  /* Reset PLL3DIVR register */
  RCC->PLL3DIVR = 0x01010280U;
 8000a00:	6458      	str	r0, [r3, #68]	@ 0x44
  /* Reset PLL3FRACR register */
  RCC->PLL3FRACR = 0x00000000U;
 8000a02:	649a      	str	r2, [r3, #72]	@ 0x48
#endif /* RCC_CR_PLL3ON */

  /* Reset HSEBYP bit */
  RCC->CR &= ~(RCC_CR_HSEBYP);
 8000a04:	6818      	ldr	r0, [r3, #0]
 8000a06:	f420 2080 	bic.w	r0, r0, #262144	@ 0x40000
 8000a0a:	6018      	str	r0, [r3, #0]

  /* Disable all interrupts */
  RCC->CIER = 0U;
 8000a0c:	651a      	str	r2, [r3, #80]	@ 0x50

  /* Configure the Vector Table location add offset address ------------------*/
  #ifdef VECT_TAB_SRAM
    SCB->VTOR = SRAM1_BASE | VECT_TAB_OFFSET; /* Vector Table Relocation in Internal SRAM */
  #else
    SCB->VTOR = FLASH_BASE | VECT_TAB_OFFSET; /* Vector Table Relocation in Internal FLASH */
 8000a0e:	f04f 6300 	mov.w	r3, #134217728	@ 0x8000000
 8000a12:	608b      	str	r3, [r1, #8]
  #endif /* VECT_TAB_SRAM */

  /* Check OPSR register to verify if there is an ongoing swap or option bytes update interrupted by a reset */
  reg_opsr = FLASH->OPSR & FLASH_OPSR_CODE_OP;
 8000a14:	4b14      	ldr	r3, [pc, #80]	@ (8000a68 <SystemInit+0x9c>)
 8000a16:	699b      	ldr	r3, [r3, #24]
 8000a18:	f003 4360 	and.w	r3, r3, #3758096384	@ 0xe0000000
  if ((reg_opsr == FLASH_OPSR_CODE_OP) || (reg_opsr == (FLASH_OPSR_CODE_OP_2 | FLASH_OPSR_CODE_OP_1)))
 8000a1c:	f1b3 4f60 	cmp.w	r3, #3758096384	@ 0xe0000000
 8000a20:	d002      	beq.n	8000a28 <SystemInit+0x5c>
 8000a22:	f1b3 4f40 	cmp.w	r3, #3221225472	@ 0xc0000000
 8000a26:	d113      	bne.n	8000a50 <SystemInit+0x84>
  {
    /* Check FLASH Option Control Register access */
    if ((FLASH->OPTCR & FLASH_OPTCR_OPTLOCK) != 0U)
 8000a28:	4b0f      	ldr	r3, [pc, #60]	@ (8000a68 <SystemInit+0x9c>)
 8000a2a:	69db      	ldr	r3, [r3, #28]
 8000a2c:	f013 0f01 	tst.w	r3, #1
 8000a30:	d005      	beq.n	8000a3e <SystemInit+0x72>
    {
      /* Authorizes the Option Byte registers programming */
      FLASH->OPTKEYR = 0x08192A3BU;
 8000a32:	4b0d      	ldr	r3, [pc, #52]	@ (8000a68 <SystemInit+0x9c>)
 8000a34:	4a0d      	ldr	r2, [pc, #52]	@ (8000a6c <SystemInit+0xa0>)
 8000a36:	60da      	str	r2, [r3, #12]
      FLASH->OPTKEYR = 0x4C5D6E7FU;
 8000a38:	f102 3244 	add.w	r2, r2, #1145324612	@ 0x44444444
 8000a3c:	60da      	str	r2, [r3, #12]
    }
    /* Launch the option bytes change operation */
    FLASH->OPTCR |= FLASH_OPTCR_OPTSTART;
 8000a3e:	4b0a      	ldr	r3, [pc, #40]	@ (8000a68 <SystemInit+0x9c>)
 8000a40:	69da      	ldr	r2, [r3, #28]
 8000a42:	f042 0202 	orr.w	r2, r2, #2
 8000a46:	61da      	str	r2, [r3, #28]

    /* Lock the FLASH Option Control Register access */
    FLASH->OPTCR |= FLASH_OPTCR_OPTLOCK;
 8000a48:	69da      	ldr	r2, [r3, #28]
 8000a4a:	f042 0201 	orr.w	r2, r2, #1
 8000a4e:	61da      	str	r2, [r3, #28]
  }
}
 8000a50:	f85d 4b04 	ldr.w	r4, [sp], #4
 8000a54:	4770      	bx	lr
 8000a56:	bf00      	nop
 8000a58:	e000ed00 	.word	0xe000ed00
 8000a5c:	44020c00 	.word	0x44020c00
 8000a60:	eae2eae3 	.word	0xeae2eae3
 8000a64:	01010280 	.word	0x01010280
 8000a68:	40022000 	.word	0x40022000
 8000a6c:	08192a3b 	.word	0x08192a3b

08000a70 <rt_hw_stack_init>:

rt_uint8_t *rt_hw_stack_init(void       *tentry,
                             void       *parameter,
                             rt_uint8_t *stack_addr,
                             void       *texit)
{
 8000a70:	b430      	push	{r4, r5}
 8000a72:	4605      	mov	r5, r0
    struct stack_frame *stack_frame;
    rt_uint8_t         *stk;
    unsigned long       i;

    stk  = stack_addr + sizeof(rt_uint32_t);
 8000a74:	3204      	adds	r2, #4
    stk  = (rt_uint8_t *)RT_ALIGN_DOWN((rt_uint32_t)stk, 8);
 8000a76:	f022 0c07 	bic.w	ip, r2, #7
    stk -= sizeof(struct stack_frame);
 8000a7a:	f1ac 0050 	sub.w	r0, ip, #80	@ 0x50

    stack_frame = (struct stack_frame *)stk;

    /* init all register */
    for (i = 0; i < sizeof(struct stack_frame) / sizeof(rt_uint32_t); i ++)
 8000a7e:	2200      	movs	r2, #0
 8000a80:	e003      	b.n	8000a8a <rt_hw_stack_init+0x1a>
    {
        ((rt_uint32_t *)stack_frame)[i] = 0xdeadbeef;
 8000a82:	4c12      	ldr	r4, [pc, #72]	@ (8000acc <rt_hw_stack_init+0x5c>)
 8000a84:	f840 4022 	str.w	r4, [r0, r2, lsl #2]
    for (i = 0; i < sizeof(struct stack_frame) / sizeof(rt_uint32_t); i ++)
 8000a88:	3201      	adds	r2, #1
 8000a8a:	2a13      	cmp	r2, #19
 8000a8c:	d9f9      	bls.n	8000a82 <rt_hw_stack_init+0x12>
    }

    stack_frame->exception_stack_frame.r0  = (unsigned long)parameter; /* r0 : argument */
 8000a8e:	f84c 1c20 	str.w	r1, [ip, #-32]
    stack_frame->exception_stack_frame.r1  = 0;                        /* r1 */
 8000a92:	2200      	movs	r2, #0
 8000a94:	f84c 2c1c 	str.w	r2, [ip, #-28]
    stack_frame->exception_stack_frame.r2  = 0;                        /* r2 */
 8000a98:	f84c 2c18 	str.w	r2, [ip, #-24]
    stack_frame->exception_stack_frame.r3  = 0;                        /* r3 */
 8000a9c:	f84c 2c14 	str.w	r2, [ip, #-20]
    stack_frame->exception_stack_frame.r12 = 0;                        /* r12 */
 8000aa0:	f84c 2c10 	str.w	r2, [ip, #-16]
    stack_frame->exception_stack_frame.lr  = (unsigned long)texit;     /* lr */
 8000aa4:	f84c 3c0c 	str.w	r3, [ip, #-12]
    stack_frame->exception_stack_frame.pc  = (unsigned long)tentry;    /* entry point, pc */
 8000aa8:	f84c 5c08 	str.w	r5, [ip, #-8]
    stack_frame->exception_stack_frame.psr = 0x01000000L;              /* PSR */
 8000aac:	f04f 7380 	mov.w	r3, #16777216	@ 0x1000000
 8000ab0:	f84c 3c04 	str.w	r3, [ip, #-4]

    stack_frame->tz = 0x00;                                            /* trustzone thread context */
 8000ab4:	f84c 2c50 	str.w	r2, [ip, #-80]
     *                    1: Process stack pointer.
     * ES     [0]      - Indicates the Security state the exception was taken to.
     *                    0: Non-secure.
     *                    1: Secure.
     */
    stack_frame->lr = 0xfffffffdL;
 8000ab8:	f06f 0302 	mvn.w	r3, #2
 8000abc:	f84c 3c4c 	str.w	r3, [ip, #-76]
    stack_frame->psplim = 0x00;
 8000ac0:	f84c 2c48 	str.w	r2, [ip, #-72]
     *                    0: Privileged.
     *                    1: Unprivileged.
     *                    This bit is banked between Security states.
     *
     */
    stack_frame->control = 0x00000000L;
 8000ac4:	f84c 2c44 	str.w	r2, [ip, #-68]

    /* return task's current stack address */
    return stk;
}
 8000ac8:	bc30      	pop	{r4, r5}
 8000aca:	4770      	bx	lr
 8000acc:	deadbeef 	.word	0xdeadbeef

08000ad0 <rt_hw_hard_fault_exception>:
    rt_uint32_t exc_return;
    struct stack_frame stack_frame;
};

void rt_hw_hard_fault_exception(struct exception_info *exception_info)
{
 8000ad0:	b538      	push	{r3, r4, r5, lr}
 8000ad2:	4604      	mov	r4, r0
    extern long list_thread(void);
#endif
    struct exception_stack_frame *exception_stack = &exception_info->stack_frame.exception_stack_frame;
    struct stack_frame *context = &exception_info->stack_frame;

    if (rt_exception_hook != RT_NULL)
 8000ad4:	4b41      	ldr	r3, [pc, #260]	@ (8000bdc <rt_hw_hard_fault_exception+0x10c>)
 8000ad6:	681b      	ldr	r3, [r3, #0]
 8000ad8:	b11b      	cbz	r3, 8000ae2 <rt_hw_hard_fault_exception+0x12>
 8000ada:	3034      	adds	r0, #52	@ 0x34
    {
        rt_err_t result;

        result = rt_exception_hook(exception_stack);
 8000adc:	4798      	blx	r3
        if (result == RT_EOK) return;
 8000ade:	2800      	cmp	r0, #0
 8000ae0:	d07b      	beq.n	8000bda <rt_hw_hard_fault_exception+0x10a>
    }

    rt_kprintf("psr: 0x%08x\n", context->exception_stack_frame.psr);
 8000ae2:	6d21      	ldr	r1, [r4, #80]	@ 0x50
 8000ae4:	483e      	ldr	r0, [pc, #248]	@ (8000be0 <rt_hw_hard_fault_exception+0x110>)
 8000ae6:	f001 f9ff 	bl	8001ee8 <rt_kprintf>

    rt_kprintf("r00: 0x%08x\n", context->exception_stack_frame.r0);
 8000aea:	6b61      	ldr	r1, [r4, #52]	@ 0x34
 8000aec:	483d      	ldr	r0, [pc, #244]	@ (8000be4 <rt_hw_hard_fault_exception+0x114>)
 8000aee:	f001 f9fb 	bl	8001ee8 <rt_kprintf>
    rt_kprintf("r01: 0x%08x\n", context->exception_stack_frame.r1);
 8000af2:	6ba1      	ldr	r1, [r4, #56]	@ 0x38
 8000af4:	483c      	ldr	r0, [pc, #240]	@ (8000be8 <rt_hw_hard_fault_exception+0x118>)
 8000af6:	f001 f9f7 	bl	8001ee8 <rt_kprintf>
    rt_kprintf("r02: 0x%08x\n", context->exception_stack_frame.r2);
 8000afa:	6be1      	ldr	r1, [r4, #60]	@ 0x3c
 8000afc:	483b      	ldr	r0, [pc, #236]	@ (8000bec <rt_hw_hard_fault_exception+0x11c>)
 8000afe:	f001 f9f3 	bl	8001ee8 <rt_kprintf>
    rt_kprintf("r03: 0x%08x\n", context->exception_stack_frame.r3);
 8000b02:	6c21      	ldr	r1, [r4, #64]	@ 0x40
 8000b04:	483a      	ldr	r0, [pc, #232]	@ (8000bf0 <rt_hw_hard_fault_exception+0x120>)
 8000b06:	f001 f9ef 	bl	8001ee8 <rt_kprintf>
    rt_kprintf("r04: 0x%08x\n", context->r4);
 8000b0a:	6961      	ldr	r1, [r4, #20]
 8000b0c:	4839      	ldr	r0, [pc, #228]	@ (8000bf4 <rt_hw_hard_fault_exception+0x124>)
 8000b0e:	f001 f9eb 	bl	8001ee8 <rt_kprintf>
    rt_kprintf("r05: 0x%08x\n", context->r5);
 8000b12:	69a1      	ldr	r1, [r4, #24]
 8000b14:	4838      	ldr	r0, [pc, #224]	@ (8000bf8 <rt_hw_hard_fault_exception+0x128>)
 8000b16:	f001 f9e7 	bl	8001ee8 <rt_kprintf>
    rt_kprintf("r06: 0x%08x\n", context->r6);
 8000b1a:	69e1      	ldr	r1, [r4, #28]
 8000b1c:	4837      	ldr	r0, [pc, #220]	@ (8000bfc <rt_hw_hard_fault_exception+0x12c>)
 8000b1e:	f001 f9e3 	bl	8001ee8 <rt_kprintf>
    rt_kprintf("r07: 0x%08x\n", context->r7);
 8000b22:	6a21      	ldr	r1, [r4, #32]
 8000b24:	4836      	ldr	r0, [pc, #216]	@ (8000c00 <rt_hw_hard_fault_exception+0x130>)
 8000b26:	f001 f9df 	bl	8001ee8 <rt_kprintf>
    rt_kprintf("r08: 0x%08x\n", context->r8);
 8000b2a:	6a61      	ldr	r1, [r4, #36]	@ 0x24
 8000b2c:	4835      	ldr	r0, [pc, #212]	@ (8000c04 <rt_hw_hard_fault_exception+0x134>)
 8000b2e:	f001 f9db 	bl	8001ee8 <rt_kprintf>
    rt_kprintf("r09: 0x%08x\n", context->r9);
 8000b32:	6aa1      	ldr	r1, [r4, #40]	@ 0x28
 8000b34:	4834      	ldr	r0, [pc, #208]	@ (8000c08 <rt_hw_hard_fault_exception+0x138>)
 8000b36:	f001 f9d7 	bl	8001ee8 <rt_kprintf>
    rt_kprintf("r10: 0x%08x\n", context->r10);
 8000b3a:	6ae1      	ldr	r1, [r4, #44]	@ 0x2c
 8000b3c:	4833      	ldr	r0, [pc, #204]	@ (8000c0c <rt_hw_hard_fault_exception+0x13c>)
 8000b3e:	f001 f9d3 	bl	8001ee8 <rt_kprintf>
    rt_kprintf("r11: 0x%08x\n", context->r11);
 8000b42:	6b21      	ldr	r1, [r4, #48]	@ 0x30
 8000b44:	4832      	ldr	r0, [pc, #200]	@ (8000c10 <rt_hw_hard_fault_exception+0x140>)
 8000b46:	f001 f9cf 	bl	8001ee8 <rt_kprintf>
    rt_kprintf("r12: 0x%08x\n", context->exception_stack_frame.r12);
 8000b4a:	6c61      	ldr	r1, [r4, #68]	@ 0x44
 8000b4c:	4831      	ldr	r0, [pc, #196]	@ (8000c14 <rt_hw_hard_fault_exception+0x144>)
 8000b4e:	f001 f9cb 	bl	8001ee8 <rt_kprintf>
    rt_kprintf(" lr: 0x%08x\n", context->exception_stack_frame.lr);
 8000b52:	6ca1      	ldr	r1, [r4, #72]	@ 0x48
 8000b54:	4830      	ldr	r0, [pc, #192]	@ (8000c18 <rt_hw_hard_fault_exception+0x148>)
 8000b56:	f001 f9c7 	bl	8001ee8 <rt_kprintf>
    rt_kprintf(" pc: 0x%08x\n", context->exception_stack_frame.pc);
 8000b5a:	6ce1      	ldr	r1, [r4, #76]	@ 0x4c
 8000b5c:	482f      	ldr	r0, [pc, #188]	@ (8000c1c <rt_hw_hard_fault_exception+0x14c>)
 8000b5e:	f001 f9c3 	bl	8001ee8 <rt_kprintf>

    rt_kprintf("Configurable Fault Status Register (CFSR): 0x%08x\n", SCB_CFSR);
 8000b62:	f04f 25e0 	mov.w	r5, #3758153728	@ 0xe000e000
 8000b66:	f8d5 1d28 	ldr.w	r1, [r5, #3368]	@ 0xd28
 8000b6a:	482d      	ldr	r0, [pc, #180]	@ (8000c20 <rt_hw_hard_fault_exception+0x150>)
 8000b6c:	f001 f9bc 	bl	8001ee8 <rt_kprintf>
    rt_kprintf("Hard Fault Status Register (HFSR): 0x%08x\n", SCB_HFSR);
 8000b70:	f8d5 1d2c 	ldr.w	r1, [r5, #3372]	@ 0xd2c
 8000b74:	482b      	ldr	r0, [pc, #172]	@ (8000c24 <rt_hw_hard_fault_exception+0x154>)
 8000b76:	f001 f9b7 	bl	8001ee8 <rt_kprintf>
    rt_kprintf("Memory Management Fault Address Register (MMFAR): 0x%08x\n", SCB_MMAR);
 8000b7a:	f8d5 1d34 	ldr.w	r1, [r5, #3380]	@ 0xd34
 8000b7e:	482a      	ldr	r0, [pc, #168]	@ (8000c28 <rt_hw_hard_fault_exception+0x158>)
 8000b80:	f001 f9b2 	bl	8001ee8 <rt_kprintf>
    rt_kprintf("Bus Fault Address Register (BFAR): 0x%08x\n", SCB_BFAR);
 8000b84:	f8d5 1d38 	ldr.w	r1, [r5, #3384]	@ 0xd38
 8000b88:	4828      	ldr	r0, [pc, #160]	@ (8000c2c <rt_hw_hard_fault_exception+0x15c>)
 8000b8a:	f001 f9ad 	bl	8001ee8 <rt_kprintf>
    rt_kprintf("System Handler Control and State Register (SHCSR): 0x%08x\n", SCB_SHCSR);
 8000b8e:	f8d5 1d24 	ldr.w	r1, [r5, #3364]	@ 0xd24
 8000b92:	4827      	ldr	r0, [pc, #156]	@ (8000c30 <rt_hw_hard_fault_exception+0x160>)
 8000b94:	f001 f9a8 	bl	8001ee8 <rt_kprintf>

    rt_kprintf("CFSR bits: MMFSR 0x%02x, BFSR 0x%02x, UFSR 0x%04x\n",
               SCB_CFSR_MFSR, SCB_CFSR_BFSR, SCB_CFSR_UFSR);
 8000b98:	4b26      	ldr	r3, [pc, #152]	@ (8000c34 <rt_hw_hard_fault_exception+0x164>)
 8000b9a:	f893 1028 	ldrb.w	r1, [r3, #40]	@ 0x28
 8000b9e:	f893 2029 	ldrb.w	r2, [r3, #41]	@ 0x29
 8000ba2:	8d5b      	ldrh	r3, [r3, #42]	@ 0x2a
    rt_kprintf("CFSR bits: MMFSR 0x%02x, BFSR 0x%02x, UFSR 0x%04x\n",
 8000ba4:	b29b      	uxth	r3, r3
 8000ba6:	4824      	ldr	r0, [pc, #144]	@ (8000c38 <rt_hw_hard_fault_exception+0x168>)
 8000ba8:	f001 f99e 	bl	8001ee8 <rt_kprintf>

    if (exception_info->exc_return & (1 << 2))
 8000bac:	6823      	ldr	r3, [r4, #0]
 8000bae:	f013 0f04 	tst.w	r3, #4
 8000bb2:	d00a      	beq.n	8000bca <rt_hw_hard_fault_exception+0xfa>
    {
        rt_kprintf("hard fault on thread: %s\r\n\r\n", rt_thread_self()->name);
 8000bb4:	f000 f92c 	bl	8000e10 <rt_thread_self>
 8000bb8:	4601      	mov	r1, r0
 8000bba:	4820      	ldr	r0, [pc, #128]	@ (8000c3c <rt_hw_hard_fault_exception+0x16c>)
 8000bbc:	f001 f994 	bl	8001ee8 <rt_kprintf>
    else
    {
        rt_kprintf("hard fault on handler\r\n\r\n");
    }

    if ( (exception_info->exc_return & 0x10) == 0)
 8000bc0:	6823      	ldr	r3, [r4, #0]
 8000bc2:	f013 0f10 	tst.w	r3, #16
 8000bc6:	d004      	beq.n	8000bd2 <rt_hw_hard_fault_exception+0x102>

#ifdef RT_USING_FINSH
    hard_fault_track();
#endif /* RT_USING_FINSH */

    while (1);
 8000bc8:	e7fe      	b.n	8000bc8 <rt_hw_hard_fault_exception+0xf8>
        rt_kprintf("hard fault on handler\r\n\r\n");
 8000bca:	481d      	ldr	r0, [pc, #116]	@ (8000c40 <rt_hw_hard_fault_exception+0x170>)
 8000bcc:	f001 f98c 	bl	8001ee8 <rt_kprintf>
 8000bd0:	e7f6      	b.n	8000bc0 <rt_hw_hard_fault_exception+0xf0>
        rt_kprintf("FPU active!\r\n");
 8000bd2:	481c      	ldr	r0, [pc, #112]	@ (8000c44 <rt_hw_hard_fault_exception+0x174>)
 8000bd4:	f001 f988 	bl	8001ee8 <rt_kprintf>
 8000bd8:	e7f6      	b.n	8000bc8 <rt_hw_hard_fault_exception+0xf8>
}
 8000bda:	bd38      	pop	{r3, r4, r5, pc}
 8000bdc:	200000b4 	.word	0x200000b4
 8000be0:	080081f0 	.word	0x080081f0
 8000be4:	08008200 	.word	0x08008200
 8000be8:	08008210 	.word	0x08008210
 8000bec:	08008220 	.word	0x08008220
 8000bf0:	08008230 	.word	0x08008230
 8000bf4:	08008240 	.word	0x08008240
 8000bf8:	08008250 	.word	0x08008250
 8000bfc:	08008260 	.word	0x08008260
 8000c00:	08008270 	.word	0x08008270
 8000c04:	08008280 	.word	0x08008280
 8000c08:	08008290 	.word	0x08008290
 8000c0c:	080082a0 	.word	0x080082a0
 8000c10:	080082b0 	.word	0x080082b0
 8000c14:	080082c0 	.word	0x080082c0
 8000c18:	080082d0 	.word	0x080082d0
 8000c1c:	080082e0 	.word	0x080082e0
 8000c20:	080082f0 	.word	0x080082f0
 8000c24:	08008324 	.word	0x08008324
 8000c28:	08008350 	.word	0x08008350
 8000c2c:	0800838c 	.word	0x0800838c
 8000c30:	080083b8 	.word	0x080083b8
 8000c34:	e000ed00 	.word	0xe000ed00
 8000c38:	080083f4 	.word	0x080083f4
 8000c3c:	08008428 	.word	0x08008428
 8000c40:	08008448 	.word	0x08008448
 8000c44:	08008464 	.word	0x08008464

08000c48 <TZ_AllocModuleContext_S>:
extern rt_uint32_t TZ_FreeModuleContext_S(rt_uint32_t id);
extern rt_uint32_t TZ_LoadContext_S(rt_uint32_t id);
extern rt_uint32_t TZ_StoreContext_S(rt_uint32_t id);
#else
void TZ_InitContextSystem_S(void){}
rt_uint32_t TZ_AllocModuleContext_S (rt_uint32_t module){return 0;}
 8000c48:	2000      	movs	r0, #0
 8000c4a:	4770      	bx	lr

08000c4c <rt_secure_svc_handle>:
{
    TZ_LoadContext_S(context);
}

int rt_secure_svc_handle(int svc_id, rt_ubase_t arg0, rt_ubase_t arg1, rt_ubase_t arg2)
{
 8000c4c:	b510      	push	{r4, lr}
    int res = 0;

    switch (svc_id)
 8000c4e:	f241 0202 	movw	r2, #4098	@ 0x1002
 8000c52:	4290      	cmp	r0, r2
 8000c54:	d005      	beq.n	8000c62 <rt_secure_svc_handle+0x16>
 8000c56:	f241 0203 	movw	r2, #4099	@ 0x1003
 8000c5a:	4290      	cmp	r0, r2
 8000c5c:	d00e      	beq.n	8000c7c <rt_secure_svc_handle+0x30>
 8000c5e:	2400      	movs	r4, #0
 8000c60:	e00f      	b.n	8000c82 <rt_secure_svc_handle+0x36>
    {
    case TZ_INIT_CONTEXT_ID:
        TZ_InitContextSystem_S();
        break;
    case TZ_ALLOC_CONTEXT_ID:
        res = TZ_AllocModuleContext_S(arg0);
 8000c62:	4608      	mov	r0, r1
 8000c64:	f7ff fff0 	bl	8000c48 <TZ_AllocModuleContext_S>
 8000c68:	4604      	mov	r4, r0
        if (res <= 0)
 8000c6a:	2800      	cmp	r0, #0
 8000c6c:	dd02      	ble.n	8000c74 <rt_secure_svc_handle+0x28>
        {
            rt_kprintf("Alloc Context Failed\n");
        }
        else
        {
            rt_trustzone_current_context = res;
 8000c6e:	4b06      	ldr	r3, [pc, #24]	@ (8000c88 <rt_secure_svc_handle+0x3c>)
 8000c70:	6018      	str	r0, [r3, #0]
            TZ_LoadContext_S(res);
 8000c72:	e006      	b.n	8000c82 <rt_secure_svc_handle+0x36>
            rt_kprintf("Alloc Context Failed\n");
 8000c74:	4805      	ldr	r0, [pc, #20]	@ (8000c8c <rt_secure_svc_handle+0x40>)
 8000c76:	f001 f937 	bl	8001ee8 <rt_kprintf>
 8000c7a:	e002      	b.n	8000c82 <rt_secure_svc_handle+0x36>
        }
        break;
    case TZ_FREE_CONTEXT_ID:
        TZ_FreeModuleContext_S(rt_trustzone_current_context);
        rt_trustzone_current_context = 0;
 8000c7c:	2400      	movs	r4, #0
 8000c7e:	4b02      	ldr	r3, [pc, #8]	@ (8000c88 <rt_secure_svc_handle+0x3c>)
 8000c80:	601c      	str	r4, [r3, #0]
        break;
    }
    return res;
}
 8000c82:	4620      	mov	r0, r4
 8000c84:	bd10      	pop	{r4, pc}
 8000c86:	bf00      	nop
 8000c88:	200000c4 	.word	0x200000c4
 8000c8c:	08008474 	.word	0x08008474

08000c90 <_thread_init>:
                             void             *parameter,
                             void             *stack_start,
                             rt_uint32_t       stack_size,
                             rt_uint8_t        priority,
                             rt_uint32_t       tick)
{
 8000c90:	b5f0      	push	{r4, r5, r6, r7, lr}
 8000c92:	b083      	sub	sp, #12
 8000c94:	4604      	mov	r4, r0
 8000c96:	4617      	mov	r7, r2
 8000c98:	9808      	ldr	r0, [sp, #32]
 8000c9a:	9a09      	ldr	r2, [sp, #36]	@ 0x24
 8000c9c:	f89d 5028 	ldrb.w	r5, [sp, #40]	@ 0x28
 8000ca0:	9e0b      	ldr	r6, [sp, #44]	@ 0x2c
    /* init thread list */
    rt_list_init(&(thread->tlist));
 8000ca2:	f104 0114 	add.w	r1, r4, #20
 *
 * @param l list to be initialized
 */
rt_inline void rt_list_init(rt_list_t *l)
{
    l->next = l->prev = l;
 8000ca6:	61a1      	str	r1, [r4, #24]
 8000ca8:	6161      	str	r1, [r4, #20]

    thread->entry = (void *)entry;
 8000caa:	6227      	str	r7, [r4, #32]
    thread->parameter = parameter;
 8000cac:	6263      	str	r3, [r4, #36]	@ 0x24

    /* stack init */
    thread->stack_addr = stack_start;
 8000cae:	62a0      	str	r0, [r4, #40]	@ 0x28
    thread->stack_size = stack_size;
 8000cb0:	62e2      	str	r2, [r4, #44]	@ 0x2c

    /* init thread stack */
    rt_memset(thread->stack_addr, '#', thread->stack_size);
 8000cb2:	2123      	movs	r1, #35	@ 0x23
 8000cb4:	f000 ff38 	bl	8001b28 <rt_memset>
    thread->sp = (void *)rt_hw_stack_init(thread->entry, thread->parameter,
                                          (void *)((char *)thread->stack_addr),
                                          (void *)_thread_exit);
#else
    thread->sp = (void *)rt_hw_stack_init(thread->entry, thread->parameter,
                                          (rt_uint8_t *)((char *)thread->stack_addr + thread->stack_size - sizeof(rt_ubase_t)),
 8000cb8:	6aa1      	ldr	r1, [r4, #40]	@ 0x28
 8000cba:	6ae3      	ldr	r3, [r4, #44]	@ 0x2c
 8000cbc:	1f1a      	subs	r2, r3, #4
    thread->sp = (void *)rt_hw_stack_init(thread->entry, thread->parameter,
 8000cbe:	4b14      	ldr	r3, [pc, #80]	@ (8000d10 <_thread_init+0x80>)
 8000cc0:	440a      	add	r2, r1
 8000cc2:	6a61      	ldr	r1, [r4, #36]	@ 0x24
 8000cc4:	6a20      	ldr	r0, [r4, #32]
 8000cc6:	f7ff fed3 	bl	8000a70 <rt_hw_stack_init>
 8000cca:	61e0      	str	r0, [r4, #28]
                                          (void *)_thread_exit);
#endif /* ARCH_CPU_STACK_GROWS_UPWARD */

    /* priority init */
    RT_ASSERT(priority < RT_THREAD_PRIORITY_MAX);
 8000ccc:	2d1f      	cmp	r5, #31
 8000cce:	d819      	bhi.n	8000d04 <_thread_init+0x74>
    thread->current_priority = priority;
 8000cd0:	f884 5035 	strb.w	r5, [r4, #53]	@ 0x35

    thread->number_mask = 0;
 8000cd4:	2500      	movs	r5, #0
 8000cd6:	63a5      	str	r5, [r4, #56]	@ 0x38

#ifdef RT_USING_EVENT
    thread->event_set = 0;
 8000cd8:	63e5      	str	r5, [r4, #60]	@ 0x3c
    thread->event_info = 0;
 8000cda:	f884 5040 	strb.w	r5, [r4, #64]	@ 0x40
    thread->number = 0;
    thread->high_mask = 0;
#endif /* RT_THREAD_PRIORITY_MAX > 32 */

    /* tick init */
    thread->init_tick      = tick;
 8000cde:	6466      	str	r6, [r4, #68]	@ 0x44
    thread->remaining_tick = tick;
 8000ce0:	64a6      	str	r6, [r4, #72]	@ 0x48

    /* error and flags */
    thread->error = RT_EOK;
 8000ce2:	6325      	str	r5, [r4, #48]	@ 0x30
    thread->stat  = RT_THREAD_INIT;
 8000ce4:	f884 5034 	strb.w	r5, [r4, #52]	@ 0x34
    thread->cpus_lock_nest = 0;
    thread->critical_lock_nest = 0;
#endif /* RT_USING_SMP */

    /* initialize cleanup function and user data */
    thread->cleanup   = 0;
 8000ce8:	67a5      	str	r5, [r4, #120]	@ 0x78
    thread->user_data = 0;
 8000cea:	67e5      	str	r5, [r4, #124]	@ 0x7c

    /* initialize thread timer */
    rt_timer_init(&(thread->thread_timer),
 8000cec:	9501      	str	r5, [sp, #4]
 8000cee:	9500      	str	r5, [sp, #0]
 8000cf0:	4623      	mov	r3, r4
 8000cf2:	4a08      	ldr	r2, [pc, #32]	@ (8000d14 <_thread_init+0x84>)
 8000cf4:	4621      	mov	r1, r4
 8000cf6:	f104 004c 	add.w	r0, r4, #76	@ 0x4c
 8000cfa:	f000 fb2d 	bl	8001358 <rt_timer_init>
#endif /* RT_USING_MODULE */

    RT_OBJECT_HOOK_CALL(rt_thread_inited_hook, (thread));

    return RT_EOK;
}
 8000cfe:	4628      	mov	r0, r5
 8000d00:	b003      	add	sp, #12
 8000d02:	bdf0      	pop	{r4, r5, r6, r7, pc}
    RT_ASSERT(priority < RT_THREAD_PRIORITY_MAX);
 8000d04:	22bd      	movs	r2, #189	@ 0xbd
 8000d06:	4904      	ldr	r1, [pc, #16]	@ (8000d18 <_thread_init+0x88>)
 8000d08:	4804      	ldr	r0, [pc, #16]	@ (8000d1c <_thread_init+0x8c>)
 8000d0a:	f001 f94d 	bl	8001fa8 <rt_assert_handler>
 8000d0e:	e7df      	b.n	8000cd0 <_thread_init+0x40>
 8000d10:	08000e1d 	.word	0x08000e1d
 8000d14:	08000d21 	.word	0x08000d21
 8000d18:	08009078 	.word	0x08009078
 8000d1c:	0800848c 	.word	0x0800848c

08000d20 <_thread_timeout>:
{
 8000d20:	b538      	push	{r3, r4, r5, lr}
    RT_ASSERT(thread != RT_NULL);
 8000d22:	4604      	mov	r4, r0
 8000d24:	b310      	cbz	r0, 8000d6c <_thread_timeout+0x4c>
    RT_ASSERT((thread->stat & RT_THREAD_STAT_MASK) == RT_THREAD_SUSPEND);
 8000d26:	f894 3034 	ldrb.w	r3, [r4, #52]	@ 0x34
 8000d2a:	f003 0307 	and.w	r3, r3, #7
 8000d2e:	2b02      	cmp	r3, #2
 8000d30:	d122      	bne.n	8000d78 <_thread_timeout+0x58>
    RT_ASSERT(rt_object_get_type((rt_object_t)thread) == RT_Object_Class_Thread);
 8000d32:	4620      	mov	r0, r4
 8000d34:	f000 fde4 	bl	8001900 <rt_object_get_type>
 8000d38:	2801      	cmp	r0, #1
 8000d3a:	d123      	bne.n	8000d84 <_thread_timeout+0x64>
    level = rt_hw_interrupt_disable();
 8000d3c:	f7ff fa86 	bl	800024c <rt_hw_interrupt_disable>
 8000d40:	4605      	mov	r5, r0
    thread->error = -RT_ETIMEOUT;
 8000d42:	f06f 0301 	mvn.w	r3, #1
 8000d46:	6323      	str	r3, [r4, #48]	@ 0x30
    rt_list_remove(&(thread->tlist));
 8000d48:	f104 0314 	add.w	r3, r4, #20
 * @brief remove node from list.
 * @param n the node to remove from the list.
 */
rt_inline void rt_list_remove(rt_list_t *n)
{
    n->next->prev = n->prev;
 8000d4c:	6961      	ldr	r1, [r4, #20]
 8000d4e:	69a2      	ldr	r2, [r4, #24]
 8000d50:	604a      	str	r2, [r1, #4]
    n->prev->next = n->next;
 8000d52:	6961      	ldr	r1, [r4, #20]
 8000d54:	6011      	str	r1, [r2, #0]

    n->next = n->prev = n;
 8000d56:	61a3      	str	r3, [r4, #24]
 8000d58:	6163      	str	r3, [r4, #20]
    rt_schedule_insert_thread(thread);
 8000d5a:	4620      	mov	r0, r4
 8000d5c:	f001 fd9e 	bl	800289c <rt_schedule_insert_thread>
    rt_hw_interrupt_enable(level);
 8000d60:	4628      	mov	r0, r5
 8000d62:	f7ff fa77 	bl	8000254 <rt_hw_interrupt_enable>
    rt_schedule();
 8000d66:	f001 fe33 	bl	80029d0 <rt_schedule>
}
 8000d6a:	bd38      	pop	{r3, r4, r5, pc}
    RT_ASSERT(thread != RT_NULL);
 8000d6c:	2286      	movs	r2, #134	@ 0x86
 8000d6e:	4908      	ldr	r1, [pc, #32]	@ (8000d90 <_thread_timeout+0x70>)
 8000d70:	4808      	ldr	r0, [pc, #32]	@ (8000d94 <_thread_timeout+0x74>)
 8000d72:	f001 f919 	bl	8001fa8 <rt_assert_handler>
 8000d76:	e7d6      	b.n	8000d26 <_thread_timeout+0x6>
    RT_ASSERT((thread->stat & RT_THREAD_STAT_MASK) == RT_THREAD_SUSPEND);
 8000d78:	2287      	movs	r2, #135	@ 0x87
 8000d7a:	4905      	ldr	r1, [pc, #20]	@ (8000d90 <_thread_timeout+0x70>)
 8000d7c:	4806      	ldr	r0, [pc, #24]	@ (8000d98 <_thread_timeout+0x78>)
 8000d7e:	f001 f913 	bl	8001fa8 <rt_assert_handler>
 8000d82:	e7d6      	b.n	8000d32 <_thread_timeout+0x12>
    RT_ASSERT(rt_object_get_type((rt_object_t)thread) == RT_Object_Class_Thread);
 8000d84:	2288      	movs	r2, #136	@ 0x88
 8000d86:	4902      	ldr	r1, [pc, #8]	@ (8000d90 <_thread_timeout+0x70>)
 8000d88:	4804      	ldr	r0, [pc, #16]	@ (8000d9c <_thread_timeout+0x7c>)
 8000d8a:	f001 f90d 	bl	8001fa8 <rt_assert_handler>
 8000d8e:	e7d5      	b.n	8000d3c <_thread_timeout+0x1c>
 8000d90:	08009058 	.word	0x08009058
 8000d94:	080084b0 	.word	0x080084b0
 8000d98:	080084c4 	.word	0x080084c4
 8000d9c:	08008500 	.word	0x08008500

08000da0 <rt_thread_init>:
                        void             *parameter,
                        void             *stack_start,
                        rt_uint32_t       stack_size,
                        rt_uint8_t        priority,
                        rt_uint32_t       tick)
{
 8000da0:	e92d 41f0 	stmdb	sp!, {r4, r5, r6, r7, r8, lr}
 8000da4:	b084      	sub	sp, #16
 8000da6:	460c      	mov	r4, r1
 8000da8:	4615      	mov	r5, r2
 8000daa:	461e      	mov	r6, r3
 8000dac:	f8dd 8028 	ldr.w	r8, [sp, #40]	@ 0x28
    /* parameter check */
    RT_ASSERT(thread != RT_NULL);
 8000db0:	4607      	mov	r7, r0
 8000db2:	b1c8      	cbz	r0, 8000de8 <rt_thread_init+0x48>
    RT_ASSERT(stack_start != RT_NULL);
 8000db4:	f1b8 0f00 	cmp.w	r8, #0
 8000db8:	d01d      	beq.n	8000df6 <rt_thread_init+0x56>

    /* initialize thread object */
    rt_object_init((rt_object_t)thread, RT_Object_Class_Thread, name);
 8000dba:	4622      	mov	r2, r4
 8000dbc:	2101      	movs	r1, #1
 8000dbe:	4638      	mov	r0, r7
 8000dc0:	f000 fcac 	bl	800171c <rt_object_init>

    return _thread_init(thread,
 8000dc4:	9b0d      	ldr	r3, [sp, #52]	@ 0x34
 8000dc6:	9303      	str	r3, [sp, #12]
 8000dc8:	f89d 3030 	ldrb.w	r3, [sp, #48]	@ 0x30
 8000dcc:	9302      	str	r3, [sp, #8]
 8000dce:	9b0b      	ldr	r3, [sp, #44]	@ 0x2c
 8000dd0:	9301      	str	r3, [sp, #4]
 8000dd2:	f8cd 8000 	str.w	r8, [sp]
 8000dd6:	4633      	mov	r3, r6
 8000dd8:	462a      	mov	r2, r5
 8000dda:	4621      	mov	r1, r4
 8000ddc:	4638      	mov	r0, r7
 8000dde:	f7ff ff57 	bl	8000c90 <_thread_init>
                        parameter,
                        stack_start,
                        stack_size,
                        priority,
                        tick);
}
 8000de2:	b004      	add	sp, #16
 8000de4:	e8bd 81f0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, pc}
    RT_ASSERT(thread != RT_NULL);
 8000de8:	f240 1233 	movw	r2, #307	@ 0x133
 8000dec:	4905      	ldr	r1, [pc, #20]	@ (8000e04 <rt_thread_init+0x64>)
 8000dee:	4806      	ldr	r0, [pc, #24]	@ (8000e08 <rt_thread_init+0x68>)
 8000df0:	f001 f8da 	bl	8001fa8 <rt_assert_handler>
 8000df4:	e7de      	b.n	8000db4 <rt_thread_init+0x14>
    RT_ASSERT(stack_start != RT_NULL);
 8000df6:	f44f 729a 	mov.w	r2, #308	@ 0x134
 8000dfa:	4902      	ldr	r1, [pc, #8]	@ (8000e04 <rt_thread_init+0x64>)
 8000dfc:	4803      	ldr	r0, [pc, #12]	@ (8000e0c <rt_thread_init+0x6c>)
 8000dfe:	f001 f8d3 	bl	8001fa8 <rt_assert_handler>
 8000e02:	e7da      	b.n	8000dba <rt_thread_init+0x1a>
 8000e04:	08009094 	.word	0x08009094
 8000e08:	080084b0 	.word	0x080084b0
 8000e0c:	08008544 	.word	0x08008544

08000e10 <rt_thread_self>:
#else
    extern rt_thread_t rt_current_thread;

    return rt_current_thread;
#endif /* RT_USING_SMP */
}
 8000e10:	4b01      	ldr	r3, [pc, #4]	@ (8000e18 <rt_thread_self+0x8>)
 8000e12:	6818      	ldr	r0, [r3, #0]
 8000e14:	4770      	bx	lr
 8000e16:	bf00      	nop
 8000e18:	2000020c 	.word	0x2000020c

08000e1c <_thread_exit>:
{
 8000e1c:	b538      	push	{r3, r4, r5, lr}
    thread = rt_thread_self();
 8000e1e:	f7ff fff7 	bl	8000e10 <rt_thread_self>
 8000e22:	4604      	mov	r4, r0
    level = rt_hw_interrupt_disable();
 8000e24:	f7ff fa12 	bl	800024c <rt_hw_interrupt_disable>
 8000e28:	4605      	mov	r5, r0
    rt_schedule_remove_thread(thread);
 8000e2a:	4620      	mov	r0, r4
 8000e2c:	f001 fd8a 	bl	8002944 <rt_schedule_remove_thread>
    rt_timer_detach(&thread->thread_timer);
 8000e30:	f104 004c 	add.w	r0, r4, #76	@ 0x4c
 8000e34:	f000 face 	bl	80013d4 <rt_timer_detach>
    thread->stat = RT_THREAD_CLOSE;
 8000e38:	2304      	movs	r3, #4
 8000e3a:	f884 3034 	strb.w	r3, [r4, #52]	@ 0x34
    rt_thread_defunct_enqueue(thread);
 8000e3e:	4620      	mov	r0, r4
 8000e40:	f001 fe70 	bl	8002b24 <rt_thread_defunct_enqueue>
    rt_hw_interrupt_enable(level);
 8000e44:	4628      	mov	r0, r5
 8000e46:	f7ff fa05 	bl	8000254 <rt_hw_interrupt_enable>
    rt_schedule();
 8000e4a:	f001 fdc1 	bl	80029d0 <rt_schedule>
}
 8000e4e:	bd38      	pop	{r3, r4, r5, pc}

08000e50 <rt_thread_detach>:
 *
 * @return  Return the operation status. If the return value is RT_EOK, the function is successfully executed.
 *          If the return value is any other values, it means this operation failed.
 */
rt_err_t rt_thread_detach(rt_thread_t thread)
{
 8000e50:	b538      	push	{r3, r4, r5, lr}
    rt_base_t level;

    /* parameter check */
    RT_ASSERT(thread != RT_NULL);
 8000e52:	4604      	mov	r4, r0
 8000e54:	b308      	cbz	r0, 8000e9a <rt_thread_detach+0x4a>
    RT_ASSERT(rt_object_get_type((rt_object_t)thread) == RT_Object_Class_Thread);
 8000e56:	4620      	mov	r0, r4
 8000e58:	f000 fd52 	bl	8001900 <rt_object_get_type>
 8000e5c:	2801      	cmp	r0, #1
 8000e5e:	d123      	bne.n	8000ea8 <rt_thread_detach+0x58>
    RT_ASSERT(rt_object_is_systemobject((rt_object_t)thread));
 8000e60:	4620      	mov	r0, r4
 8000e62:	f000 fd37 	bl	80018d4 <rt_object_is_systemobject>
 8000e66:	b330      	cbz	r0, 8000eb6 <rt_thread_detach+0x66>

    if ((thread->stat & RT_THREAD_STAT_MASK) == RT_THREAD_CLOSE)
 8000e68:	f894 3034 	ldrb.w	r3, [r4, #52]	@ 0x34
 8000e6c:	f003 0307 	and.w	r3, r3, #7
 8000e70:	2b04      	cmp	r3, #4
 8000e72:	d010      	beq.n	8000e96 <rt_thread_detach+0x46>
        return RT_EOK;

    if ((thread->stat & RT_THREAD_STAT_MASK) != RT_THREAD_INIT)
 8000e74:	bb33      	cbnz	r3, 8000ec4 <rt_thread_detach+0x74>
        /* remove from schedule */
        rt_schedule_remove_thread(thread);
    }

    /* disable interrupt */
    level = rt_hw_interrupt_disable();
 8000e76:	f7ff f9e9 	bl	800024c <rt_hw_interrupt_disable>
 8000e7a:	4605      	mov	r5, r0

    /* release thread timer */
    rt_timer_detach(&(thread->thread_timer));
 8000e7c:	f104 004c 	add.w	r0, r4, #76	@ 0x4c
 8000e80:	f000 faa8 	bl	80013d4 <rt_timer_detach>

    /* change stat */
    thread->stat = RT_THREAD_CLOSE;
 8000e84:	2304      	movs	r3, #4
 8000e86:	f884 3034 	strb.w	r3, [r4, #52]	@ 0x34

    /* insert to defunct thread list */
    rt_thread_defunct_enqueue(thread);
 8000e8a:	4620      	mov	r0, r4
 8000e8c:	f001 fe4a 	bl	8002b24 <rt_thread_defunct_enqueue>

    /* enable interrupt */
    rt_hw_interrupt_enable(level);
 8000e90:	4628      	mov	r0, r5
 8000e92:	f7ff f9df 	bl	8000254 <rt_hw_interrupt_enable>

    return RT_EOK;
}
 8000e96:	2000      	movs	r0, #0
 8000e98:	bd38      	pop	{r3, r4, r5, pc}
    RT_ASSERT(thread != RT_NULL);
 8000e9a:	f240 1291 	movw	r2, #401	@ 0x191
 8000e9e:	490b      	ldr	r1, [pc, #44]	@ (8000ecc <rt_thread_detach+0x7c>)
 8000ea0:	480b      	ldr	r0, [pc, #44]	@ (8000ed0 <rt_thread_detach+0x80>)
 8000ea2:	f001 f881 	bl	8001fa8 <rt_assert_handler>
 8000ea6:	e7d6      	b.n	8000e56 <rt_thread_detach+0x6>
    RT_ASSERT(rt_object_get_type((rt_object_t)thread) == RT_Object_Class_Thread);
 8000ea8:	f44f 72c9 	mov.w	r2, #402	@ 0x192
 8000eac:	4907      	ldr	r1, [pc, #28]	@ (8000ecc <rt_thread_detach+0x7c>)
 8000eae:	4809      	ldr	r0, [pc, #36]	@ (8000ed4 <rt_thread_detach+0x84>)
 8000eb0:	f001 f87a 	bl	8001fa8 <rt_assert_handler>
 8000eb4:	e7d4      	b.n	8000e60 <rt_thread_detach+0x10>
    RT_ASSERT(rt_object_is_systemobject((rt_object_t)thread));
 8000eb6:	f240 1293 	movw	r2, #403	@ 0x193
 8000eba:	4904      	ldr	r1, [pc, #16]	@ (8000ecc <rt_thread_detach+0x7c>)
 8000ebc:	4806      	ldr	r0, [pc, #24]	@ (8000ed8 <rt_thread_detach+0x88>)
 8000ebe:	f001 f873 	bl	8001fa8 <rt_assert_handler>
 8000ec2:	e7d1      	b.n	8000e68 <rt_thread_detach+0x18>
        rt_schedule_remove_thread(thread);
 8000ec4:	4620      	mov	r0, r4
 8000ec6:	f001 fd3d 	bl	8002944 <rt_schedule_remove_thread>
 8000eca:	e7d4      	b.n	8000e76 <rt_thread_detach+0x26>
 8000ecc:	08008fe4 	.word	0x08008fe4
 8000ed0:	080084b0 	.word	0x080084b0
 8000ed4:	08008500 	.word	0x08008500
 8000ed8:	0800855c 	.word	0x0800855c

08000edc <rt_thread_create>:
                             void (*entry)(void *parameter),
                             void       *parameter,
                             rt_uint32_t stack_size,
                             rt_uint8_t  priority,
                             rt_uint32_t tick)
{
 8000edc:	e92d 43f0 	stmdb	sp!, {r4, r5, r6, r7, r8, r9, lr}
 8000ee0:	b085      	sub	sp, #20
 8000ee2:	4604      	mov	r4, r0
 8000ee4:	460f      	mov	r7, r1
 8000ee6:	4690      	mov	r8, r2
 8000ee8:	461d      	mov	r5, r3
    struct rt_thread *thread;
    void *stack_start;

    thread = (struct rt_thread *)rt_object_allocate(RT_Object_Class_Thread,
 8000eea:	4601      	mov	r1, r0
 8000eec:	2001      	movs	r0, #1
 8000eee:	f000 fc77 	bl	80017e0 <rt_object_allocate>
                                                    name);
    if (thread == RT_NULL)
 8000ef2:	4606      	mov	r6, r0
 8000ef4:	b188      	cbz	r0, 8000f1a <rt_thread_create+0x3e>
        return RT_NULL;

    stack_start = (void *)RT_KERNEL_MALLOC(stack_size);
 8000ef6:	4628      	mov	r0, r5
 8000ef8:	f001 f8b0 	bl	800205c <rt_malloc>
    if (stack_start == RT_NULL)
 8000efc:	4681      	mov	r9, r0
 8000efe:	b180      	cbz	r0, 8000f22 <rt_thread_create+0x46>
        rt_object_delete((rt_object_t)thread);

        return RT_NULL;
    }

    _thread_init(thread,
 8000f00:	9b0d      	ldr	r3, [sp, #52]	@ 0x34
 8000f02:	9303      	str	r3, [sp, #12]
 8000f04:	f89d 3030 	ldrb.w	r3, [sp, #48]	@ 0x30
 8000f08:	9302      	str	r3, [sp, #8]
 8000f0a:	9501      	str	r5, [sp, #4]
 8000f0c:	9000      	str	r0, [sp, #0]
 8000f0e:	4643      	mov	r3, r8
 8000f10:	463a      	mov	r2, r7
 8000f12:	4621      	mov	r1, r4
 8000f14:	4630      	mov	r0, r6
 8000f16:	f7ff febb 	bl	8000c90 <_thread_init>
                 stack_size,
                 priority,
                 tick);

    return thread;
}
 8000f1a:	4630      	mov	r0, r6
 8000f1c:	b005      	add	sp, #20
 8000f1e:	e8bd 83f0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, pc}
        rt_object_delete((rt_object_t)thread);
 8000f22:	4630      	mov	r0, r6
 8000f24:	f000 fca8 	bl	8001878 <rt_object_delete>
        return RT_NULL;
 8000f28:	464e      	mov	r6, r9
 8000f2a:	e7f6      	b.n	8000f1a <rt_thread_create+0x3e>

08000f2c <rt_thread_delete>:
 *
 * @return  Return the operation status. If the return value is RT_EOK, the function is successfully executed.
 *          If the return value is any other values, it means this operation failed.
 */
rt_err_t rt_thread_delete(rt_thread_t thread)
{
 8000f2c:	b538      	push	{r3, r4, r5, lr}
    rt_base_t level;

    /* parameter check */
    RT_ASSERT(thread != RT_NULL);
 8000f2e:	4604      	mov	r4, r0
 8000f30:	b308      	cbz	r0, 8000f76 <rt_thread_delete+0x4a>
    RT_ASSERT(rt_object_get_type((rt_object_t)thread) == RT_Object_Class_Thread);
 8000f32:	4620      	mov	r0, r4
 8000f34:	f000 fce4 	bl	8001900 <rt_object_get_type>
 8000f38:	2801      	cmp	r0, #1
 8000f3a:	d123      	bne.n	8000f84 <rt_thread_delete+0x58>
    RT_ASSERT(rt_object_is_systemobject((rt_object_t)thread) == RT_FALSE);
 8000f3c:	4620      	mov	r0, r4
 8000f3e:	f000 fcc9 	bl	80018d4 <rt_object_is_systemobject>
 8000f42:	bb30      	cbnz	r0, 8000f92 <rt_thread_delete+0x66>

    if ((thread->stat & RT_THREAD_STAT_MASK) == RT_THREAD_CLOSE)
 8000f44:	f894 3034 	ldrb.w	r3, [r4, #52]	@ 0x34
 8000f48:	f003 0307 	and.w	r3, r3, #7
 8000f4c:	2b04      	cmp	r3, #4
 8000f4e:	d010      	beq.n	8000f72 <rt_thread_delete+0x46>
        return RT_EOK;

    if ((thread->stat & RT_THREAD_STAT_MASK) != RT_THREAD_INIT)
 8000f50:	bb33      	cbnz	r3, 8000fa0 <rt_thread_delete+0x74>
        /* remove from schedule */
        rt_schedule_remove_thread(thread);
    }

    /* disable interrupt */
    level = rt_hw_interrupt_disable();
 8000f52:	f7ff f97b 	bl	800024c <rt_hw_interrupt_disable>
 8000f56:	4605      	mov	r5, r0

    /* release thread timer */
    rt_timer_detach(&(thread->thread_timer));
 8000f58:	f104 004c 	add.w	r0, r4, #76	@ 0x4c
 8000f5c:	f000 fa3a 	bl	80013d4 <rt_timer_detach>

    /* change stat */
    thread->stat = RT_THREAD_CLOSE;
 8000f60:	2304      	movs	r3, #4
 8000f62:	f884 3034 	strb.w	r3, [r4, #52]	@ 0x34

    /* insert to defunct thread list */
    rt_thread_defunct_enqueue(thread);
 8000f66:	4620      	mov	r0, r4
 8000f68:	f001 fddc 	bl	8002b24 <rt_thread_defunct_enqueue>

    /* enable interrupt */
    rt_hw_interrupt_enable(level);
 8000f6c:	4628      	mov	r0, r5
 8000f6e:	f7ff f971 	bl	8000254 <rt_hw_interrupt_enable>

    return RT_EOK;
}
 8000f72:	2000      	movs	r0, #0
 8000f74:	bd38      	pop	{r3, r4, r5, pc}
    RT_ASSERT(thread != RT_NULL);
 8000f76:	f44f 72fc 	mov.w	r2, #504	@ 0x1f8
 8000f7a:	490b      	ldr	r1, [pc, #44]	@ (8000fa8 <rt_thread_delete+0x7c>)
 8000f7c:	480b      	ldr	r0, [pc, #44]	@ (8000fac <rt_thread_delete+0x80>)
 8000f7e:	f001 f813 	bl	8001fa8 <rt_assert_handler>
 8000f82:	e7d6      	b.n	8000f32 <rt_thread_delete+0x6>
    RT_ASSERT(rt_object_get_type((rt_object_t)thread) == RT_Object_Class_Thread);
 8000f84:	f240 12f9 	movw	r2, #505	@ 0x1f9
 8000f88:	4907      	ldr	r1, [pc, #28]	@ (8000fa8 <rt_thread_delete+0x7c>)
 8000f8a:	4809      	ldr	r0, [pc, #36]	@ (8000fb0 <rt_thread_delete+0x84>)
 8000f8c:	f001 f80c 	bl	8001fa8 <rt_assert_handler>
 8000f90:	e7d4      	b.n	8000f3c <rt_thread_delete+0x10>
    RT_ASSERT(rt_object_is_systemobject((rt_object_t)thread) == RT_FALSE);
 8000f92:	f44f 72fd 	mov.w	r2, #506	@ 0x1fa
 8000f96:	4904      	ldr	r1, [pc, #16]	@ (8000fa8 <rt_thread_delete+0x7c>)
 8000f98:	4806      	ldr	r0, [pc, #24]	@ (8000fb4 <rt_thread_delete+0x88>)
 8000f9a:	f001 f805 	bl	8001fa8 <rt_assert_handler>
 8000f9e:	e7d1      	b.n	8000f44 <rt_thread_delete+0x18>
        rt_schedule_remove_thread(thread);
 8000fa0:	4620      	mov	r0, r4
 8000fa2:	f001 fccf 	bl	8002944 <rt_schedule_remove_thread>
 8000fa6:	e7d4      	b.n	8000f52 <rt_thread_delete+0x26>
 8000fa8:	08008f9c 	.word	0x08008f9c
 8000fac:	080084b0 	.word	0x080084b0
 8000fb0:	08008500 	.word	0x08008500
 8000fb4:	0800858c 	.word	0x0800858c

08000fb8 <rt_thread_suspend>:
 *
 * @return  Return the operation status. If the return value is RT_EOK, the function is successfully executed.
 *          If the return value is any other values, it means this operation failed.
 */
rt_err_t rt_thread_suspend(rt_thread_t thread)
{
 8000fb8:	b538      	push	{r3, r4, r5, lr}
    rt_base_t stat;
    rt_base_t level;

    /* parameter check */
    RT_ASSERT(thread != RT_NULL);
 8000fba:	4604      	mov	r4, r0
 8000fbc:	b368      	cbz	r0, 800101a <rt_thread_suspend+0x62>
    RT_ASSERT(rt_object_get_type((rt_object_t)thread) == RT_Object_Class_Thread);
 8000fbe:	4620      	mov	r0, r4
 8000fc0:	f000 fc9e 	bl	8001900 <rt_object_get_type>
 8000fc4:	2801      	cmp	r0, #1
 8000fc6:	d12f      	bne.n	8001028 <rt_thread_suspend+0x70>
    RT_ASSERT(thread == rt_thread_self());
 8000fc8:	f7ff ff22 	bl	8000e10 <rt_thread_self>
 8000fcc:	4284      	cmp	r4, r0
 8000fce:	d005      	beq.n	8000fdc <rt_thread_suspend+0x24>
 8000fd0:	f44f 7254 	mov.w	r2, #848	@ 0x350
 8000fd4:	4919      	ldr	r1, [pc, #100]	@ (800103c <rt_thread_suspend+0x84>)
 8000fd6:	481a      	ldr	r0, [pc, #104]	@ (8001040 <rt_thread_suspend+0x88>)
 8000fd8:	f000 ffe6 	bl	8001fa8 <rt_assert_handler>

    RT_DEBUG_LOG(RT_DEBUG_THREAD, ("thread suspend:  %s\n", thread->name));

    stat = thread->stat & RT_THREAD_STAT_MASK;
 8000fdc:	f894 3034 	ldrb.w	r3, [r4, #52]	@ 0x34
 8000fe0:	f003 0307 	and.w	r3, r3, #7
    if ((stat != RT_THREAD_READY) && (stat != RT_THREAD_RUNNING))
 8000fe4:	2b01      	cmp	r3, #1
 8000fe6:	d001      	beq.n	8000fec <rt_thread_suspend+0x34>
 8000fe8:	2b03      	cmp	r3, #3
 8000fea:	d124      	bne.n	8001036 <rt_thread_suspend+0x7e>
        RT_DEBUG_LOG(RT_DEBUG_THREAD, ("thread suspend: thread disorder, 0x%2x\n", thread->stat));
        return -RT_ERROR;
    }

    /* disable interrupt */
    level = rt_hw_interrupt_disable();
 8000fec:	f7ff f92e 	bl	800024c <rt_hw_interrupt_disable>
 8000ff0:	4605      	mov	r5, r0

    /* change thread stat */
    rt_schedule_remove_thread(thread);
 8000ff2:	4620      	mov	r0, r4
 8000ff4:	f001 fca6 	bl	8002944 <rt_schedule_remove_thread>
    thread->stat = RT_THREAD_SUSPEND | (thread->stat & ~RT_THREAD_STAT_MASK);
 8000ff8:	f894 3034 	ldrb.w	r3, [r4, #52]	@ 0x34
 8000ffc:	f023 0307 	bic.w	r3, r3, #7
 8001000:	f043 0302 	orr.w	r3, r3, #2
 8001004:	f884 3034 	strb.w	r3, [r4, #52]	@ 0x34

    /* stop thread timer anyway */
    rt_timer_stop(&(thread->thread_timer));
 8001008:	f104 004c 	add.w	r0, r4, #76	@ 0x4c
 800100c:	f000 fa88 	bl	8001520 <rt_timer_stop>

    /* enable interrupt */
    rt_hw_interrupt_enable(level);
 8001010:	4628      	mov	r0, r5
 8001012:	f7ff f91f 	bl	8000254 <rt_hw_interrupt_enable>

    RT_OBJECT_HOOK_CALL(rt_thread_suspend_hook, (thread));
    return RT_EOK;
 8001016:	2000      	movs	r0, #0
}
 8001018:	bd38      	pop	{r3, r4, r5, pc}
    RT_ASSERT(thread != RT_NULL);
 800101a:	f240 324e 	movw	r2, #846	@ 0x34e
 800101e:	4907      	ldr	r1, [pc, #28]	@ (800103c <rt_thread_suspend+0x84>)
 8001020:	4808      	ldr	r0, [pc, #32]	@ (8001044 <rt_thread_suspend+0x8c>)
 8001022:	f000 ffc1 	bl	8001fa8 <rt_assert_handler>
 8001026:	e7ca      	b.n	8000fbe <rt_thread_suspend+0x6>
    RT_ASSERT(rt_object_get_type((rt_object_t)thread) == RT_Object_Class_Thread);
 8001028:	f240 324f 	movw	r2, #847	@ 0x34f
 800102c:	4903      	ldr	r1, [pc, #12]	@ (800103c <rt_thread_suspend+0x84>)
 800102e:	4806      	ldr	r0, [pc, #24]	@ (8001048 <rt_thread_suspend+0x90>)
 8001030:	f000 ffba 	bl	8001fa8 <rt_assert_handler>
 8001034:	e7c8      	b.n	8000fc8 <rt_thread_suspend+0x10>
        return -RT_ERROR;
 8001036:	f04f 30ff 	mov.w	r0, #4294967295	@ 0xffffffff
 800103a:	e7ed      	b.n	8001018 <rt_thread_suspend+0x60>
 800103c:	08008e1c 	.word	0x08008e1c
 8001040:	080085c8 	.word	0x080085c8
 8001044:	080084b0 	.word	0x080084b0
 8001048:	08008500 	.word	0x08008500

0800104c <rt_thread_resume>:
 *
 * @return  Return the operation status. If the return value is RT_EOK, the function is successfully executed.
 *          If the return value is any other values, it means this operation failed.
 */
rt_err_t rt_thread_resume(rt_thread_t thread)
{
 800104c:	b538      	push	{r3, r4, r5, lr}
    rt_base_t level;

    /* parameter check */
    RT_ASSERT(thread != RT_NULL);
 800104e:	4604      	mov	r4, r0
 8001050:	b310      	cbz	r0, 8001098 <rt_thread_resume+0x4c>
    RT_ASSERT(rt_object_get_type((rt_object_t)thread) == RT_Object_Class_Thread);
 8001052:	4620      	mov	r0, r4
 8001054:	f000 fc54 	bl	8001900 <rt_object_get_type>
 8001058:	2801      	cmp	r0, #1
 800105a:	d124      	bne.n	80010a6 <rt_thread_resume+0x5a>

    RT_DEBUG_LOG(RT_DEBUG_THREAD, ("thread resume:  %s\n", thread->name));

    if ((thread->stat & RT_THREAD_STAT_MASK) != RT_THREAD_SUSPEND)
 800105c:	f894 3034 	ldrb.w	r3, [r4, #52]	@ 0x34
 8001060:	f003 0307 	and.w	r3, r3, #7
 8001064:	2b02      	cmp	r3, #2
 8001066:	d125      	bne.n	80010b4 <rt_thread_resume+0x68>

        return -RT_ERROR;
    }

    /* disable interrupt */
    level = rt_hw_interrupt_disable();
 8001068:	f7ff f8f0 	bl	800024c <rt_hw_interrupt_disable>
 800106c:	4605      	mov	r5, r0

    /* remove from suspend list */
    rt_list_remove(&(thread->tlist));
 800106e:	f104 0314 	add.w	r3, r4, #20
    n->next->prev = n->prev;
 8001072:	6961      	ldr	r1, [r4, #20]
 8001074:	69a2      	ldr	r2, [r4, #24]
 8001076:	604a      	str	r2, [r1, #4]
    n->prev->next = n->next;
 8001078:	6961      	ldr	r1, [r4, #20]
 800107a:	6011      	str	r1, [r2, #0]
    n->next = n->prev = n;
 800107c:	61a3      	str	r3, [r4, #24]
 800107e:	6163      	str	r3, [r4, #20]

    rt_timer_stop(&thread->thread_timer);
 8001080:	f104 004c 	add.w	r0, r4, #76	@ 0x4c
 8001084:	f000 fa4c 	bl	8001520 <rt_timer_stop>

    /* insert to schedule ready list */
    rt_schedule_insert_thread(thread);
 8001088:	4620      	mov	r0, r4
 800108a:	f001 fc07 	bl	800289c <rt_schedule_insert_thread>

    /* enable interrupt */
    rt_hw_interrupt_enable(level);
 800108e:	4628      	mov	r0, r5
 8001090:	f7ff f8e0 	bl	8000254 <rt_hw_interrupt_enable>

    RT_OBJECT_HOOK_CALL(rt_thread_resume_hook, (thread));
    return RT_EOK;
 8001094:	2000      	movs	r0, #0
}
 8001096:	bd38      	pop	{r3, r4, r5, pc}
    RT_ASSERT(thread != RT_NULL);
 8001098:	f240 327a 	movw	r2, #890	@ 0x37a
 800109c:	4907      	ldr	r1, [pc, #28]	@ (80010bc <rt_thread_resume+0x70>)
 800109e:	4808      	ldr	r0, [pc, #32]	@ (80010c0 <rt_thread_resume+0x74>)
 80010a0:	f000 ff82 	bl	8001fa8 <rt_assert_handler>
 80010a4:	e7d5      	b.n	8001052 <rt_thread_resume+0x6>
    RT_ASSERT(rt_object_get_type((rt_object_t)thread) == RT_Object_Class_Thread);
 80010a6:	f240 327b 	movw	r2, #891	@ 0x37b
 80010aa:	4904      	ldr	r1, [pc, #16]	@ (80010bc <rt_thread_resume+0x70>)
 80010ac:	4805      	ldr	r0, [pc, #20]	@ (80010c4 <rt_thread_resume+0x78>)
 80010ae:	f000 ff7b 	bl	8001fa8 <rt_assert_handler>
 80010b2:	e7d3      	b.n	800105c <rt_thread_resume+0x10>
        return -RT_ERROR;
 80010b4:	f04f 30ff 	mov.w	r0, #4294967295	@ 0xffffffff
 80010b8:	e7ed      	b.n	8001096 <rt_thread_resume+0x4a>
 80010ba:	bf00      	nop
 80010bc:	08008d84 	.word	0x08008d84
 80010c0:	080084b0 	.word	0x080084b0
 80010c4:	08008500 	.word	0x08008500

080010c8 <rt_thread_startup>:
{
 80010c8:	b510      	push	{r4, lr}
    RT_ASSERT(thread != RT_NULL);
 80010ca:	4604      	mov	r4, r0
 80010cc:	b1d8      	cbz	r0, 8001106 <rt_thread_startup+0x3e>
    RT_ASSERT((thread->stat & RT_THREAD_STAT_MASK) == RT_THREAD_INIT);
 80010ce:	f894 3034 	ldrb.w	r3, [r4, #52]	@ 0x34
 80010d2:	f013 0f07 	tst.w	r3, #7
 80010d6:	d11d      	bne.n	8001114 <rt_thread_startup+0x4c>
    RT_ASSERT(rt_object_get_type((rt_object_t)thread) == RT_Object_Class_Thread);
 80010d8:	4620      	mov	r0, r4
 80010da:	f000 fc11 	bl	8001900 <rt_object_get_type>
 80010de:	2801      	cmp	r0, #1
 80010e0:	d11f      	bne.n	8001122 <rt_thread_startup+0x5a>
    thread->number_mask = 1L << thread->current_priority;
 80010e2:	f894 2035 	ldrb.w	r2, [r4, #53]	@ 0x35
 80010e6:	2301      	movs	r3, #1
 80010e8:	4093      	lsls	r3, r2
 80010ea:	63a3      	str	r3, [r4, #56]	@ 0x38
    thread->stat = RT_THREAD_SUSPEND;
 80010ec:	2302      	movs	r3, #2
 80010ee:	f884 3034 	strb.w	r3, [r4, #52]	@ 0x34
    rt_thread_resume(thread);
 80010f2:	4620      	mov	r0, r4
 80010f4:	f7ff ffaa 	bl	800104c <rt_thread_resume>
    if (rt_thread_self() != RT_NULL)
 80010f8:	f7ff fe8a 	bl	8000e10 <rt_thread_self>
 80010fc:	b108      	cbz	r0, 8001102 <rt_thread_startup+0x3a>
        rt_schedule();
 80010fe:	f001 fc67 	bl	80029d0 <rt_schedule>
}
 8001102:	2000      	movs	r0, #0
 8001104:	bd10      	pop	{r4, pc}
    RT_ASSERT(thread != RT_NULL);
 8001106:	f44f 72b3 	mov.w	r2, #358	@ 0x166
 800110a:	4909      	ldr	r1, [pc, #36]	@ (8001130 <rt_thread_startup+0x68>)
 800110c:	4809      	ldr	r0, [pc, #36]	@ (8001134 <rt_thread_startup+0x6c>)
 800110e:	f000 ff4b 	bl	8001fa8 <rt_assert_handler>
 8001112:	e7dc      	b.n	80010ce <rt_thread_startup+0x6>
    RT_ASSERT((thread->stat & RT_THREAD_STAT_MASK) == RT_THREAD_INIT);
 8001114:	f240 1267 	movw	r2, #359	@ 0x167
 8001118:	4905      	ldr	r1, [pc, #20]	@ (8001130 <rt_thread_startup+0x68>)
 800111a:	4807      	ldr	r0, [pc, #28]	@ (8001138 <rt_thread_startup+0x70>)
 800111c:	f000 ff44 	bl	8001fa8 <rt_assert_handler>
 8001120:	e7da      	b.n	80010d8 <rt_thread_startup+0x10>
    RT_ASSERT(rt_object_get_type((rt_object_t)thread) == RT_Object_Class_Thread);
 8001122:	f44f 72b4 	mov.w	r2, #360	@ 0x168
 8001126:	4902      	ldr	r1, [pc, #8]	@ (8001130 <rt_thread_startup+0x68>)
 8001128:	4804      	ldr	r0, [pc, #16]	@ (800113c <rt_thread_startup+0x74>)
 800112a:	f000 ff3d 	bl	8001fa8 <rt_assert_handler>
 800112e:	e7d8      	b.n	80010e2 <rt_thread_startup+0x1a>
 8001130:	08009028 	.word	0x08009028
 8001134:	080084b0 	.word	0x080084b0
 8001138:	080085e4 	.word	0x080085e4
 800113c:	08008500 	.word	0x08008500

08001140 <rt_thread_control>:
{
 8001140:	b570      	push	{r4, r5, r6, lr}
 8001142:	460c      	mov	r4, r1
 8001144:	4616      	mov	r6, r2
    RT_ASSERT(thread != RT_NULL);
 8001146:	4605      	mov	r5, r0
 8001148:	b158      	cbz	r0, 8001162 <rt_thread_control+0x22>
    RT_ASSERT(rt_object_get_type((rt_object_t)thread) == RT_Object_Class_Thread);
 800114a:	4628      	mov	r0, r5
 800114c:	f000 fbd8 	bl	8001900 <rt_object_get_type>
 8001150:	2801      	cmp	r0, #1
 8001152:	d10d      	bne.n	8001170 <rt_thread_control+0x30>
    switch (cmd)
 8001154:	2c01      	cmp	r4, #1
 8001156:	d039      	beq.n	80011cc <rt_thread_control+0x8c>
 8001158:	2c02      	cmp	r4, #2
 800115a:	d010      	beq.n	800117e <rt_thread_control+0x3e>
 800115c:	b38c      	cbz	r4, 80011c2 <rt_thread_control+0x82>
 800115e:	2400      	movs	r4, #0
 8001160:	e020      	b.n	80011a4 <rt_thread_control+0x64>
    RT_ASSERT(thread != RT_NULL);
 8001162:	f240 22d7 	movw	r2, #727	@ 0x2d7
 8001166:	4922      	ldr	r1, [pc, #136]	@ (80011f0 <rt_thread_control+0xb0>)
 8001168:	4822      	ldr	r0, [pc, #136]	@ (80011f4 <rt_thread_control+0xb4>)
 800116a:	f000 ff1d 	bl	8001fa8 <rt_assert_handler>
 800116e:	e7ec      	b.n	800114a <rt_thread_control+0xa>
    RT_ASSERT(rt_object_get_type((rt_object_t)thread) == RT_Object_Class_Thread);
 8001170:	f44f 7236 	mov.w	r2, #728	@ 0x2d8
 8001174:	491e      	ldr	r1, [pc, #120]	@ (80011f0 <rt_thread_control+0xb0>)
 8001176:	4820      	ldr	r0, [pc, #128]	@ (80011f8 <rt_thread_control+0xb8>)
 8001178:	f000 ff16 	bl	8001fa8 <rt_assert_handler>
 800117c:	e7ea      	b.n	8001154 <rt_thread_control+0x14>
            level = rt_hw_interrupt_disable();
 800117e:	f7ff f865 	bl	800024c <rt_hw_interrupt_disable>
 8001182:	4604      	mov	r4, r0
            if ((thread->stat & RT_THREAD_STAT_MASK) == RT_THREAD_READY)
 8001184:	f895 3034 	ldrb.w	r3, [r5, #52]	@ 0x34
 8001188:	f003 0307 	and.w	r3, r3, #7
 800118c:	2b01      	cmp	r3, #1
 800118e:	d00b      	beq.n	80011a8 <rt_thread_control+0x68>
                thread->current_priority = *(rt_uint8_t *)arg;
 8001190:	7832      	ldrb	r2, [r6, #0]
 8001192:	f885 2035 	strb.w	r2, [r5, #53]	@ 0x35
                thread->number_mask = 1 << thread->current_priority;
 8001196:	2301      	movs	r3, #1
 8001198:	4093      	lsls	r3, r2
 800119a:	63ab      	str	r3, [r5, #56]	@ 0x38
            rt_hw_interrupt_enable(level);
 800119c:	4620      	mov	r0, r4
 800119e:	f7ff f859 	bl	8000254 <rt_hw_interrupt_enable>
    return RT_EOK;
 80011a2:	2400      	movs	r4, #0
}
 80011a4:	4620      	mov	r0, r4
 80011a6:	bd70      	pop	{r4, r5, r6, pc}
                rt_schedule_remove_thread(thread);
 80011a8:	4628      	mov	r0, r5
 80011aa:	f001 fbcb 	bl	8002944 <rt_schedule_remove_thread>
                thread->current_priority = *(rt_uint8_t *)arg;
 80011ae:	7832      	ldrb	r2, [r6, #0]
 80011b0:	f885 2035 	strb.w	r2, [r5, #53]	@ 0x35
                thread->number_mask = 1 << thread->current_priority;
 80011b4:	2301      	movs	r3, #1
 80011b6:	4093      	lsls	r3, r2
 80011b8:	63ab      	str	r3, [r5, #56]	@ 0x38
                rt_schedule_insert_thread(thread);
 80011ba:	4628      	mov	r0, r5
 80011bc:	f001 fb6e 	bl	800289c <rt_schedule_insert_thread>
 80011c0:	e7ec      	b.n	800119c <rt_thread_control+0x5c>
            return rt_thread_startup(thread);
 80011c2:	4628      	mov	r0, r5
 80011c4:	f7ff ff80 	bl	80010c8 <rt_thread_startup>
 80011c8:	4604      	mov	r4, r0
 80011ca:	e7eb      	b.n	80011a4 <rt_thread_control+0x64>
            if (rt_object_is_systemobject((rt_object_t)thread) == RT_TRUE)
 80011cc:	4628      	mov	r0, r5
 80011ce:	f000 fb81 	bl	80018d4 <rt_object_is_systemobject>
 80011d2:	2801      	cmp	r0, #1
 80011d4:	d006      	beq.n	80011e4 <rt_thread_control+0xa4>
                rt_err = rt_thread_delete(thread);
 80011d6:	4628      	mov	r0, r5
 80011d8:	f7ff fea8 	bl	8000f2c <rt_thread_delete>
 80011dc:	4604      	mov	r4, r0
            rt_schedule();
 80011de:	f001 fbf7 	bl	80029d0 <rt_schedule>
            return rt_err;
 80011e2:	e7df      	b.n	80011a4 <rt_thread_control+0x64>
                rt_err = rt_thread_detach(thread);
 80011e4:	4628      	mov	r0, r5
 80011e6:	f7ff fe33 	bl	8000e50 <rt_thread_detach>
 80011ea:	4604      	mov	r4, r0
 80011ec:	e7f7      	b.n	80011de <rt_thread_control+0x9e>
 80011ee:	bf00      	nop
 80011f0:	08008e9c 	.word	0x08008e9c
 80011f4:	080084b0 	.word	0x080084b0
 80011f8:	08008500 	.word	0x08008500

080011fc <rti_start>:
 * etc.
 */
static int rti_start(void)
{
    return 0;
}
 80011fc:	2000      	movs	r0, #0
 80011fe:	4770      	bx	lr

08001200 <rti_board_start>:
INIT_EXPORT(rti_start, "0");

static int rti_board_start(void)
{
    return 0;
}
 8001200:	2000      	movs	r0, #0
 8001202:	4770      	bx	lr

08001204 <rti_board_end>:
INIT_EXPORT(rti_board_start, "0.end");

static int rti_board_end(void)
{
    return 0;
}
 8001204:	2000      	movs	r0, #0
 8001206:	4770      	bx	lr

08001208 <rti_end>:
INIT_EXPORT(rti_board_end, "1.end");

static int rti_end(void)
{
    return 0;
}
 8001208:	2000      	movs	r0, #0
 800120a:	4770      	bx	lr

0800120c <rt_components_board_init>:
 * @brief  Onboard components initialization. In this function, the board-level
 *         initialization function will be called to complete the initialization
 *         of the on-board peripherals.
 */
void rt_components_board_init(void)
{
 800120c:	b510      	push	{r4, lr}
#if RT_DEBUG_INIT
    int result;
    const struct rt_init_desc *desc;
    for (desc = &__rt_init_desc_rti_board_start; desc < &__rt_init_desc_rti_board_end; desc ++)
 800120e:	4c08      	ldr	r4, [pc, #32]	@ (8001230 <rt_components_board_init+0x24>)
 8001210:	e00a      	b.n	8001228 <rt_components_board_init+0x1c>
    {
        rt_kprintf("initialize %s", desc->fn_name);
 8001212:	6821      	ldr	r1, [r4, #0]
 8001214:	4807      	ldr	r0, [pc, #28]	@ (8001234 <rt_components_board_init+0x28>)
 8001216:	f000 fe67 	bl	8001ee8 <rt_kprintf>
        result = desc->fn();
 800121a:	6863      	ldr	r3, [r4, #4]
 800121c:	4798      	blx	r3
 800121e:	4601      	mov	r1, r0
        rt_kprintf(":%d done\n", result);
 8001220:	4805      	ldr	r0, [pc, #20]	@ (8001238 <rt_components_board_init+0x2c>)
 8001222:	f000 fe61 	bl	8001ee8 <rt_kprintf>
    for (desc = &__rt_init_desc_rti_board_start; desc < &__rt_init_desc_rti_board_end; desc ++)
 8001226:	3408      	adds	r4, #8
 8001228:	4b04      	ldr	r3, [pc, #16]	@ (800123c <rt_components_board_init+0x30>)
 800122a:	429c      	cmp	r4, r3
 800122c:	d3f1      	bcc.n	8001212 <rt_components_board_init+0x6>
    for (fn_ptr = &__rt_init_rti_board_start; fn_ptr < &__rt_init_rti_board_end; fn_ptr++)
    {
        (*fn_ptr)();
    }
#endif /* RT_DEBUG_INIT */
}
 800122e:	bd10      	pop	{r4, pc}
 8001230:	0800929c 	.word	0x0800929c
 8001234:	0800861c 	.word	0x0800861c
 8001238:	0800862c 	.word	0x0800862c
 800123c:	080092ac 	.word	0x080092ac

08001240 <rt_components_init>:

/**
 * @brief  RT-Thread Components Initialization.
 */
void rt_components_init(void)
{
 8001240:	b510      	push	{r4, lr}
#if RT_DEBUG_INIT
    int result;
    const struct rt_init_desc *desc;

    rt_kprintf("do components initialization.\n");
 8001242:	480a      	ldr	r0, [pc, #40]	@ (800126c <rt_components_init+0x2c>)
 8001244:	f000 fe50 	bl	8001ee8 <rt_kprintf>
    for (desc = &__rt_init_desc_rti_board_end; desc < &__rt_init_desc_rti_end; desc ++)
 8001248:	4c09      	ldr	r4, [pc, #36]	@ (8001270 <rt_components_init+0x30>)
 800124a:	e00a      	b.n	8001262 <rt_components_init+0x22>
    {
        rt_kprintf("initialize %s", desc->fn_name);
 800124c:	6821      	ldr	r1, [r4, #0]
 800124e:	4809      	ldr	r0, [pc, #36]	@ (8001274 <rt_components_init+0x34>)
 8001250:	f000 fe4a 	bl	8001ee8 <rt_kprintf>
        result = desc->fn();
 8001254:	6863      	ldr	r3, [r4, #4]
 8001256:	4798      	blx	r3
 8001258:	4601      	mov	r1, r0
        rt_kprintf(":%d done\n", result);
 800125a:	4807      	ldr	r0, [pc, #28]	@ (8001278 <rt_components_init+0x38>)
 800125c:	f000 fe44 	bl	8001ee8 <rt_kprintf>
    for (desc = &__rt_init_desc_rti_board_end; desc < &__rt_init_desc_rti_end; desc ++)
 8001260:	3408      	adds	r4, #8
 8001262:	4b06      	ldr	r3, [pc, #24]	@ (800127c <rt_components_init+0x3c>)
 8001264:	429c      	cmp	r4, r3
 8001266:	d3f1      	bcc.n	800124c <rt_components_init+0xc>
    for (fn_ptr = &__rt_init_rti_board_end; fn_ptr < &__rt_init_rti_end; fn_ptr ++)
    {
        (*fn_ptr)();
    }
#endif /* RT_DEBUG_INIT */
}
 8001268:	bd10      	pop	{r4, pc}
 800126a:	bf00      	nop
 800126c:	08008638 	.word	0x08008638
 8001270:	080092ac 	.word	0x080092ac
 8001274:	0800861c 	.word	0x0800861c
 8001278:	0800862c 	.word	0x0800862c
 800127c:	080092b4 	.word	0x080092b4

08001280 <main_thread_entry>:
 * @brief  The system main thread. In this thread will call the rt_components_init()
 *         for initialization of RT-Thread Components and call the user's programming
 *         entry main().
 */
void main_thread_entry(void *parameter)
{
 8001280:	b508      	push	{r3, lr}
    extern int main(void);

#ifdef RT_USING_COMPONENTS_INIT
    /* RT-Thread components initialization */
    rt_components_init();
 8001282:	f7ff ffdd 	bl	8001240 <rt_components_init>
    {
        extern int $Super$$main(void);
        $Super$$main(); /* for ARMCC. */
    }
#elif defined(__ICCARM__) || defined(__GNUC__) || defined(__TASKING__)
    main();
 8001286:	f006 fd3c 	bl	8007d02 <main>
#endif
}
 800128a:	bd08      	pop	{r3, pc}

0800128c <rt_application_init>:
/**
 * @brief  This function will create and start the main thread, but this thread
 *         will not run until the scheduler starts.
 */
void rt_application_init(void)
{
 800128c:	b510      	push	{r4, lr}
 800128e:	b082      	sub	sp, #8
    rt_thread_t tid;

#ifdef RT_USING_HEAP
    tid = rt_thread_create("main", main_thread_entry, RT_NULL,
 8001290:	2314      	movs	r3, #20
 8001292:	9301      	str	r3, [sp, #4]
 8001294:	230a      	movs	r3, #10
 8001296:	9300      	str	r3, [sp, #0]
 8001298:	f44f 6380 	mov.w	r3, #1024	@ 0x400
 800129c:	2200      	movs	r2, #0
 800129e:	4908      	ldr	r1, [pc, #32]	@ (80012c0 <rt_application_init+0x34>)
 80012a0:	4808      	ldr	r0, [pc, #32]	@ (80012c4 <rt_application_init+0x38>)
 80012a2:	f7ff fe1b 	bl	8000edc <rt_thread_create>
                           RT_MAIN_THREAD_STACK_SIZE, RT_MAIN_THREAD_PRIORITY, 20);
    RT_ASSERT(tid != RT_NULL);
 80012a6:	4604      	mov	r4, r0
 80012a8:	b120      	cbz	r0, 80012b4 <rt_application_init+0x28>

    /* if not define RT_USING_HEAP, using to eliminate the warning */
    (void)result;
#endif /* RT_USING_HEAP */

    rt_thread_startup(tid);
 80012aa:	4620      	mov	r0, r4
 80012ac:	f7ff ff0c 	bl	80010c8 <rt_thread_startup>
}
 80012b0:	b002      	add	sp, #8
 80012b2:	bd10      	pop	{r4, pc}
    RT_ASSERT(tid != RT_NULL);
 80012b4:	22d5      	movs	r2, #213	@ 0xd5
 80012b6:	4904      	ldr	r1, [pc, #16]	@ (80012c8 <rt_application_init+0x3c>)
 80012b8:	4804      	ldr	r0, [pc, #16]	@ (80012cc <rt_application_init+0x40>)
 80012ba:	f000 fe75 	bl	8001fa8 <rt_assert_handler>
 80012be:	e7f4      	b.n	80012aa <rt_application_init+0x1e>
 80012c0:	08001281 	.word	0x08001281
 80012c4:	08008658 	.word	0x08008658
 80012c8:	08008d98 	.word	0x08008d98
 80012cc:	08008660 	.word	0x08008660

080012d0 <rtthread_startup>:
/**
 * @brief  This function will call all levels of initialization functions to complete
 *         the initialization of the system, and finally start the scheduler.
 */
int rtthread_startup(void)
{
 80012d0:	b508      	push	{r3, lr}
    rt_hw_interrupt_disable();
 80012d2:	f7fe ffbb 	bl	800024c <rt_hw_interrupt_disable>

    /* board level initialization
     * NOTE: please initialize heap inside board initialization.
     */
    rt_hw_board_init();
 80012d6:	f001 fcb7 	bl	8002c48 <rt_hw_board_init>

    /* show RT-Thread version */
    rt_show_version();
 80012da:	f000 fe1f 	bl	8001f1c <rt_show_version>

    /* timer system initialization */
    rt_system_timer_init();
 80012de:	f000 f9fd 	bl	80016dc <rt_system_timer_init>

    /* scheduler system initialization */
    rt_system_scheduler_init();
 80012e2:	f001 fac3 	bl	800286c <rt_system_scheduler_init>
    /* signal system initialization */
    rt_system_signal_init();
#endif /* RT_USING_SIGNALS */

    /* create init_thread */
    rt_application_init();
 80012e6:	f7ff ffd1 	bl	800128c <rt_application_init>

    /* timer thread initialization */
    rt_system_timer_thread_init();
 80012ea:	f000 fa03 	bl	80016f4 <rt_system_timer_thread_init>

    /* idle thread initialization */
    rt_thread_idle_init();
 80012ee:	f001 fc5f 	bl	8002bb0 <rt_thread_idle_init>
#ifdef RT_USING_SMP
    rt_hw_spin_lock(&_cpus_lock);
#endif /* RT_USING_SMP */

    /* start scheduler */
    rt_system_scheduler_start();
 80012f2:	f001 fb57 	bl	80029a4 <rt_system_scheduler_start>

    /* never reach here */
    return 0;
}
 80012f6:	2000      	movs	r0, #0
 80012f8:	bd08      	pop	{r3, pc}

080012fa <_timer_init>:
static void _timer_init(rt_timer_t timer,
                        void (*timeout)(void *parameter),
                        void      *parameter,
                        rt_tick_t  time,
                        rt_uint8_t flag)
{
 80012fa:	f89d c000 	ldrb.w	ip, [sp]
    int i;

    /* set flag */
    timer->parent.flag  = flag;
 80012fe:	f880 c009 	strb.w	ip, [r0, #9]

    /* set deactivated */
    timer->parent.flag &= ~RT_TIMER_FLAG_ACTIVATED;
 8001302:	f02c 0c01 	bic.w	ip, ip, #1
 8001306:	f880 c009 	strb.w	ip, [r0, #9]

    timer->timeout_func = timeout;
 800130a:	61c1      	str	r1, [r0, #28]
    timer->parameter    = parameter;
 800130c:	6202      	str	r2, [r0, #32]

    timer->timeout_tick = 0;
 800130e:	2200      	movs	r2, #0
 8001310:	6282      	str	r2, [r0, #40]	@ 0x28
    timer->init_tick    = time;
 8001312:	6243      	str	r3, [r0, #36]	@ 0x24

    /* initialize timer list */
    for (i = 0; i < RT_TIMER_SKIP_LIST_LEVEL; i++)
 8001314:	4613      	mov	r3, r2
 8001316:	2b00      	cmp	r3, #0
 8001318:	dd00      	ble.n	800131c <_timer_init+0x22>
    {
        rt_list_init(&(timer->row[i]));
    }
}
 800131a:	4770      	bx	lr
        rt_list_init(&(timer->row[i]));
 800131c:	1c9a      	adds	r2, r3, #2
 800131e:	eb00 02c2 	add.w	r2, r0, r2, lsl #3
 8001322:	1d11      	adds	r1, r2, #4
    l->next = l->prev = l;
 8001324:	6091      	str	r1, [r2, #8]
 8001326:	6051      	str	r1, [r2, #4]
    for (i = 0; i < RT_TIMER_SKIP_LIST_LEVEL; i++)
 8001328:	3301      	adds	r3, #1
 800132a:	e7f4      	b.n	8001316 <_timer_init+0x1c>

0800132c <_timer_remove>:
 */
rt_inline void _timer_remove(rt_timer_t timer)
{
    int i;

    for (i = 0; i < RT_TIMER_SKIP_LIST_LEVEL; i++)
 800132c:	2200      	movs	r2, #0
 800132e:	2a00      	cmp	r2, #0
 8001330:	dd00      	ble.n	8001334 <_timer_remove+0x8>
 8001332:	4770      	bx	lr
{
 8001334:	b430      	push	{r4, r5}
    {
        rt_list_remove(&timer->row[i]);
 8001336:	1c93      	adds	r3, r2, #2
 8001338:	eb00 03c3 	add.w	r3, r0, r3, lsl #3
 800133c:	1d19      	adds	r1, r3, #4
    n->next->prev = n->prev;
 800133e:	689c      	ldr	r4, [r3, #8]
 8001340:	685d      	ldr	r5, [r3, #4]
 8001342:	606c      	str	r4, [r5, #4]
    n->prev->next = n->next;
 8001344:	685d      	ldr	r5, [r3, #4]
 8001346:	6025      	str	r5, [r4, #0]
    n->next = n->prev = n;
 8001348:	6099      	str	r1, [r3, #8]
 800134a:	6059      	str	r1, [r3, #4]
    for (i = 0; i < RT_TIMER_SKIP_LIST_LEVEL; i++)
 800134c:	3201      	adds	r2, #1
 800134e:	2a00      	cmp	r2, #0
 8001350:	ddf1      	ble.n	8001336 <_timer_remove+0xa>
    }
}
 8001352:	bc30      	pop	{r4, r5}
 8001354:	4770      	bx	lr
	...

08001358 <rt_timer_init>:
                   const char *name,
                   void (*timeout)(void *parameter),
                   void       *parameter,
                   rt_tick_t   time,
                   rt_uint8_t  flag)
{
 8001358:	e92d 41f0 	stmdb	sp!, {r4, r5, r6, r7, r8, lr}
 800135c:	b082      	sub	sp, #8
 800135e:	460e      	mov	r6, r1
 8001360:	4614      	mov	r4, r2
 8001362:	461d      	mov	r5, r3
 8001364:	f8dd 8020 	ldr.w	r8, [sp, #32]
    /* parameter check */
    RT_ASSERT(timer != RT_NULL);
 8001368:	4607      	mov	r7, r0
 800136a:	b1a8      	cbz	r0, 8001398 <rt_timer_init+0x40>
    RT_ASSERT(timeout != RT_NULL);
 800136c:	b1dc      	cbz	r4, 80013a6 <rt_timer_init+0x4e>
    RT_ASSERT(time < RT_TICK_MAX / 2);
 800136e:	f06f 4300 	mvn.w	r3, #2147483648	@ 0x80000000
 8001372:	4598      	cmp	r8, r3
 8001374:	d21e      	bcs.n	80013b4 <rt_timer_init+0x5c>

    /* timer object initialization */
    rt_object_init(&(timer->parent), RT_Object_Class_Timer, name);
 8001376:	4632      	mov	r2, r6
 8001378:	210a      	movs	r1, #10
 800137a:	4638      	mov	r0, r7
 800137c:	f000 f9ce 	bl	800171c <rt_object_init>

    _timer_init(timer, timeout, parameter, time, flag);
 8001380:	f89d 3024 	ldrb.w	r3, [sp, #36]	@ 0x24
 8001384:	9300      	str	r3, [sp, #0]
 8001386:	4643      	mov	r3, r8
 8001388:	462a      	mov	r2, r5
 800138a:	4621      	mov	r1, r4
 800138c:	4638      	mov	r0, r7
 800138e:	f7ff ffb4 	bl	80012fa <_timer_init>
}
 8001392:	b002      	add	sp, #8
 8001394:	e8bd 81f0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, pc}
    RT_ASSERT(timer != RT_NULL);
 8001398:	f44f 7288 	mov.w	r2, #272	@ 0x110
 800139c:	4909      	ldr	r1, [pc, #36]	@ (80013c4 <rt_timer_init+0x6c>)
 800139e:	480a      	ldr	r0, [pc, #40]	@ (80013c8 <rt_timer_init+0x70>)
 80013a0:	f000 fe02 	bl	8001fa8 <rt_assert_handler>
 80013a4:	e7e2      	b.n	800136c <rt_timer_init+0x14>
    RT_ASSERT(timeout != RT_NULL);
 80013a6:	f240 1211 	movw	r2, #273	@ 0x111
 80013aa:	4906      	ldr	r1, [pc, #24]	@ (80013c4 <rt_timer_init+0x6c>)
 80013ac:	4807      	ldr	r0, [pc, #28]	@ (80013cc <rt_timer_init+0x74>)
 80013ae:	f000 fdfb 	bl	8001fa8 <rt_assert_handler>
 80013b2:	e7dc      	b.n	800136e <rt_timer_init+0x16>
    RT_ASSERT(time < RT_TICK_MAX / 2);
 80013b4:	f44f 7289 	mov.w	r2, #274	@ 0x112
 80013b8:	4902      	ldr	r1, [pc, #8]	@ (80013c4 <rt_timer_init+0x6c>)
 80013ba:	4805      	ldr	r0, [pc, #20]	@ (80013d0 <rt_timer_init+0x78>)
 80013bc:	f000 fdf4 	bl	8001fa8 <rt_assert_handler>
 80013c0:	e7d9      	b.n	8001376 <rt_timer_init+0x1e>
 80013c2:	bf00      	nop
 80013c4:	0800903c 	.word	0x0800903c
 80013c8:	08008670 	.word	0x08008670
 80013cc:	08008684 	.word	0x08008684
 80013d0:	08008698 	.word	0x08008698

080013d4 <rt_timer_detach>:
 * @param timer is the timer to be detached
 *
 * @return the status of detach
 */
rt_err_t rt_timer_detach(rt_timer_t timer)
{
 80013d4:	b538      	push	{r3, r4, r5, lr}
    rt_base_t level;

    /* parameter check */
    RT_ASSERT(timer != RT_NULL);
 80013d6:	4604      	mov	r4, r0
 80013d8:	b1d0      	cbz	r0, 8001410 <rt_timer_detach+0x3c>
    RT_ASSERT(rt_object_get_type(&timer->parent) == RT_Object_Class_Timer);
 80013da:	4620      	mov	r0, r4
 80013dc:	f000 fa90 	bl	8001900 <rt_object_get_type>
 80013e0:	280a      	cmp	r0, #10
 80013e2:	d11c      	bne.n	800141e <rt_timer_detach+0x4a>
    RT_ASSERT(rt_object_is_systemobject(&timer->parent));
 80013e4:	4620      	mov	r0, r4
 80013e6:	f000 fa75 	bl	80018d4 <rt_object_is_systemobject>
 80013ea:	b1f8      	cbz	r0, 800142c <rt_timer_detach+0x58>

    /* disable interrupt */
    level = rt_hw_interrupt_disable();
 80013ec:	f7fe ff2e 	bl	800024c <rt_hw_interrupt_disable>
 80013f0:	4605      	mov	r5, r0

    _timer_remove(timer);
 80013f2:	4620      	mov	r0, r4
 80013f4:	f7ff ff9a 	bl	800132c <_timer_remove>
    /* stop timer */
    timer->parent.flag &= ~RT_TIMER_FLAG_ACTIVATED;
 80013f8:	7a63      	ldrb	r3, [r4, #9]
 80013fa:	f023 0301 	bic.w	r3, r3, #1
 80013fe:	7263      	strb	r3, [r4, #9]

    /* enable interrupt */
    rt_hw_interrupt_enable(level);
 8001400:	4628      	mov	r0, r5
 8001402:	f7fe ff27 	bl	8000254 <rt_hw_interrupt_enable>

    rt_object_detach(&(timer->parent));
 8001406:	4620      	mov	r0, r4
 8001408:	f000 f9cc 	bl	80017a4 <rt_object_detach>

    return RT_EOK;
}
 800140c:	2000      	movs	r0, #0
 800140e:	bd38      	pop	{r3, r4, r5, pc}
    RT_ASSERT(timer != RT_NULL);
 8001410:	f240 1227 	movw	r2, #295	@ 0x127
 8001414:	4909      	ldr	r1, [pc, #36]	@ (800143c <rt_timer_detach+0x68>)
 8001416:	480a      	ldr	r0, [pc, #40]	@ (8001440 <rt_timer_detach+0x6c>)
 8001418:	f000 fdc6 	bl	8001fa8 <rt_assert_handler>
 800141c:	e7dd      	b.n	80013da <rt_timer_detach+0x6>
    RT_ASSERT(rt_object_get_type(&timer->parent) == RT_Object_Class_Timer);
 800141e:	f44f 7294 	mov.w	r2, #296	@ 0x128
 8001422:	4906      	ldr	r1, [pc, #24]	@ (800143c <rt_timer_detach+0x68>)
 8001424:	4807      	ldr	r0, [pc, #28]	@ (8001444 <rt_timer_detach+0x70>)
 8001426:	f000 fdbf 	bl	8001fa8 <rt_assert_handler>
 800142a:	e7db      	b.n	80013e4 <rt_timer_detach+0x10>
    RT_ASSERT(rt_object_is_systemobject(&timer->parent));
 800142c:	f240 1229 	movw	r2, #297	@ 0x129
 8001430:	4902      	ldr	r1, [pc, #8]	@ (800143c <rt_timer_detach+0x68>)
 8001432:	4805      	ldr	r0, [pc, #20]	@ (8001448 <rt_timer_detach+0x74>)
 8001434:	f000 fdb8 	bl	8001fa8 <rt_assert_handler>
 8001438:	e7d8      	b.n	80013ec <rt_timer_detach+0x18>
 800143a:	bf00      	nop
 800143c:	08008ff8 	.word	0x08008ff8
 8001440:	08008670 	.word	0x08008670
 8001444:	080086b0 	.word	0x080086b0
 8001448:	080086ec 	.word	0x080086ec

0800144c <rt_timer_start>:
 * @param timer the timer to be started
 *
 * @return the operation status, RT_EOK on OK, -RT_ERROR on error
 */
rt_err_t rt_timer_start(rt_timer_t timer)
{
 800144c:	b570      	push	{r4, r5, r6, lr}
 800144e:	b082      	sub	sp, #8
    rt_list_t *row_head[RT_TIMER_SKIP_LIST_LEVEL];
    unsigned int tst_nr;
    static unsigned int random_nr;

    /* parameter check */
    RT_ASSERT(timer != RT_NULL);
 8001450:	4604      	mov	r4, r0
 8001452:	b370      	cbz	r0, 80014b2 <rt_timer_start+0x66>
    RT_ASSERT(rt_object_get_type(&timer->parent) == RT_Object_Class_Timer);
 8001454:	4620      	mov	r0, r4
 8001456:	f000 fa53 	bl	8001900 <rt_object_get_type>
 800145a:	280a      	cmp	r0, #10
 800145c:	d130      	bne.n	80014c0 <rt_timer_start+0x74>

    need_schedule = RT_FALSE;

    /* stop timer firstly */
    level = rt_hw_interrupt_disable();
 800145e:	f7fe fef5 	bl	800024c <rt_hw_interrupt_disable>
 8001462:	4605      	mov	r5, r0
    /* remove timer from list */
    _timer_remove(timer);
 8001464:	4620      	mov	r0, r4
 8001466:	f7ff ff61 	bl	800132c <_timer_remove>
    /* change status of timer */
    timer->parent.flag &= ~RT_TIMER_FLAG_ACTIVATED;
 800146a:	7a63      	ldrb	r3, [r4, #9]
 800146c:	f023 0301 	bic.w	r3, r3, #1
 8001470:	7263      	strb	r3, [r4, #9]

    RT_OBJECT_HOOK_CALL(rt_object_take_hook, (&(timer->parent)));

    timer->timeout_tick = rt_tick_get() + timer->init_tick;
 8001472:	f000 ffe3 	bl	800243c <rt_tick_get>
 8001476:	6a63      	ldr	r3, [r4, #36]	@ 0x24
 8001478:	18c6      	adds	r6, r0, r3
 800147a:	62a6      	str	r6, [r4, #40]	@ 0x28
    {
        /* insert timer to system timer list */
        timer_list = _timer_list;
    }

    row_head[0]  = &timer_list[0];
 800147c:	4b23      	ldr	r3, [pc, #140]	@ (800150c <rt_timer_start+0xc0>)
 800147e:	9301      	str	r3, [sp, #4]
    for (row_lvl = 0; row_lvl < RT_TIMER_SKIP_LIST_LEVEL; row_lvl++)
 8001480:	2200      	movs	r2, #0
 8001482:	b34a      	cbz	r2, 80014d8 <rt_timer_start+0x8c>

    /* Interestingly, this super simple timer insert counter works very very
     * well on distributing the list height uniformly. By means of "very very
     * well", I mean it beats the randomness of timer->timeout_tick very easily
     * (actually, the timeout_tick is not random and easy to be attacked). */
    random_nr++;
 8001484:	4a22      	ldr	r2, [pc, #136]	@ (8001510 <rt_timer_start+0xc4>)
 8001486:	6813      	ldr	r3, [r2, #0]
 8001488:	3301      	adds	r3, #1
 800148a:	6013      	str	r3, [r2, #0]
    tst_nr = random_nr;

    rt_list_insert_after(row_head[RT_TIMER_SKIP_LIST_LEVEL - 1],
 800148c:	9b01      	ldr	r3, [sp, #4]
 800148e:	f104 0214 	add.w	r2, r4, #20
    l->next->prev = n;
 8001492:	6819      	ldr	r1, [r3, #0]
 8001494:	604a      	str	r2, [r1, #4]
    n->next = l->next;
 8001496:	6819      	ldr	r1, [r3, #0]
 8001498:	6161      	str	r1, [r4, #20]
    l->next = n;
 800149a:	601a      	str	r2, [r3, #0]
    n->prev = l;
 800149c:	61a3      	str	r3, [r4, #24]
        /* Shift over the bits we have tested. Works well with 1 bit and 2
         * bits. */
        tst_nr >>= (RT_TIMER_SKIP_LIST_MASK + 1) >> 1;
    }

    timer->parent.flag |= RT_TIMER_FLAG_ACTIVATED;
 800149e:	7a63      	ldrb	r3, [r4, #9]
 80014a0:	f043 0301 	orr.w	r3, r3, #1
 80014a4:	7263      	strb	r3, [r4, #9]
        }
    }
#endif /* RT_USING_TIMER_SOFT */

    /* enable interrupt */
    rt_hw_interrupt_enable(level);
 80014a6:	4628      	mov	r0, r5
 80014a8:	f7fe fed4 	bl	8000254 <rt_hw_interrupt_enable>
    {
        rt_schedule();
    }

    return RT_EOK;
}
 80014ac:	2000      	movs	r0, #0
 80014ae:	b002      	add	sp, #8
 80014b0:	bd70      	pop	{r4, r5, r6, pc}
    RT_ASSERT(timer != RT_NULL);
 80014b2:	f44f 72d1 	mov.w	r2, #418	@ 0x1a2
 80014b6:	4917      	ldr	r1, [pc, #92]	@ (8001514 <rt_timer_start+0xc8>)
 80014b8:	4817      	ldr	r0, [pc, #92]	@ (8001518 <rt_timer_start+0xcc>)
 80014ba:	f000 fd75 	bl	8001fa8 <rt_assert_handler>
 80014be:	e7c9      	b.n	8001454 <rt_timer_start+0x8>
    RT_ASSERT(rt_object_get_type(&timer->parent) == RT_Object_Class_Timer);
 80014c0:	f240 12a3 	movw	r2, #419	@ 0x1a3
 80014c4:	4913      	ldr	r1, [pc, #76]	@ (8001514 <rt_timer_start+0xc8>)
 80014c6:	4815      	ldr	r0, [pc, #84]	@ (800151c <rt_timer_start+0xd0>)
 80014c8:	f000 fd6e 	bl	8001fa8 <rt_assert_handler>
 80014cc:	e7c7      	b.n	800145e <rt_timer_start+0x12>
             row_head[row_lvl]  = row_head[row_lvl]->next)
 80014ce:	ab02      	add	r3, sp, #8
 80014d0:	eb03 0382 	add.w	r3, r3, r2, lsl #2
 80014d4:	f843 1c04 	str.w	r1, [r3, #-4]
        for (; row_head[row_lvl] != timer_list[row_lvl].prev;
 80014d8:	ab02      	add	r3, sp, #8
 80014da:	eb03 0382 	add.w	r3, r3, r2, lsl #2
 80014de:	f853 0c04 	ldr.w	r0, [r3, #-4]
 80014e2:	00d3      	lsls	r3, r2, #3
 80014e4:	4909      	ldr	r1, [pc, #36]	@ (800150c <rt_timer_start+0xc0>)
 80014e6:	eb01 01c2 	add.w	r1, r1, r2, lsl #3
 80014ea:	6849      	ldr	r1, [r1, #4]
 80014ec:	4288      	cmp	r0, r1
 80014ee:	d00a      	beq.n	8001506 <rt_timer_start+0xba>
            rt_list_t *p = row_head[row_lvl]->next;
 80014f0:	6801      	ldr	r1, [r0, #0]
            t = rt_list_entry(p, struct rt_timer, row[row_lvl]);
 80014f2:	3314      	adds	r3, #20
 80014f4:	1acb      	subs	r3, r1, r3
            if ((t->timeout_tick - timer->timeout_tick) == 0)
 80014f6:	6a9b      	ldr	r3, [r3, #40]	@ 0x28
 80014f8:	429e      	cmp	r6, r3
 80014fa:	d0e8      	beq.n	80014ce <rt_timer_start+0x82>
            else if ((t->timeout_tick - timer->timeout_tick) < RT_TICK_MAX / 2)
 80014fc:	1b9b      	subs	r3, r3, r6
 80014fe:	f06f 4000 	mvn.w	r0, #2147483648	@ 0x80000000
 8001502:	4283      	cmp	r3, r0
 8001504:	d2e3      	bcs.n	80014ce <rt_timer_start+0x82>
    for (row_lvl = 0; row_lvl < RT_TIMER_SKIP_LIST_LEVEL; row_lvl++)
 8001506:	3201      	adds	r2, #1
 8001508:	e7bb      	b.n	8001482 <rt_timer_start+0x36>
 800150a:	bf00      	nop
 800150c:	200000cc 	.word	0x200000cc
 8001510:	200000c8 	.word	0x200000c8
 8001514:	08008f04 	.word	0x08008f04
 8001518:	08008670 	.word	0x08008670
 800151c:	080086b0 	.word	0x080086b0

08001520 <rt_timer_stop>:
 * @param timer the timer to be stopped
 *
 * @return the operation status, RT_EOK on OK, -RT_ERROR on error
 */
rt_err_t rt_timer_stop(rt_timer_t timer)
{
 8001520:	b538      	push	{r3, r4, r5, lr}
    rt_base_t level;

    /* parameter check */
    RT_ASSERT(timer != RT_NULL);
 8001522:	4604      	mov	r4, r0
 8001524:	b1b8      	cbz	r0, 8001556 <rt_timer_stop+0x36>
    RT_ASSERT(rt_object_get_type(&timer->parent) == RT_Object_Class_Timer);
 8001526:	4620      	mov	r0, r4
 8001528:	f000 f9ea 	bl	8001900 <rt_object_get_type>
 800152c:	280a      	cmp	r0, #10
 800152e:	d119      	bne.n	8001564 <rt_timer_stop+0x44>

    if (!(timer->parent.flag & RT_TIMER_FLAG_ACTIVATED))
 8001530:	7a63      	ldrb	r3, [r4, #9]
 8001532:	f013 0f01 	tst.w	r3, #1
 8001536:	d01c      	beq.n	8001572 <rt_timer_stop+0x52>
        return -RT_ERROR;

    RT_OBJECT_HOOK_CALL(rt_object_put_hook, (&(timer->parent)));

    /* disable interrupt */
    level = rt_hw_interrupt_disable();
 8001538:	f7fe fe88 	bl	800024c <rt_hw_interrupt_disable>
 800153c:	4605      	mov	r5, r0

    _timer_remove(timer);
 800153e:	4620      	mov	r0, r4
 8001540:	f7ff fef4 	bl	800132c <_timer_remove>
    /* change status */
    timer->parent.flag &= ~RT_TIMER_FLAG_ACTIVATED;
 8001544:	7a63      	ldrb	r3, [r4, #9]
 8001546:	f023 0301 	bic.w	r3, r3, #1
 800154a:	7263      	strb	r3, [r4, #9]

    /* enable interrupt */
    rt_hw_interrupt_enable(level);
 800154c:	4628      	mov	r0, r5
 800154e:	f7fe fe81 	bl	8000254 <rt_hw_interrupt_enable>

    return RT_EOK;
 8001552:	2000      	movs	r0, #0
}
 8001554:	bd38      	pop	{r3, r4, r5, pc}
    RT_ASSERT(timer != RT_NULL);
 8001556:	f240 221a 	movw	r2, #538	@ 0x21a
 800155a:	4907      	ldr	r1, [pc, #28]	@ (8001578 <rt_timer_stop+0x58>)
 800155c:	4807      	ldr	r0, [pc, #28]	@ (800157c <rt_timer_stop+0x5c>)
 800155e:	f000 fd23 	bl	8001fa8 <rt_assert_handler>
 8001562:	e7e0      	b.n	8001526 <rt_timer_stop+0x6>
    RT_ASSERT(rt_object_get_type(&timer->parent) == RT_Object_Class_Timer);
 8001564:	f240 221b 	movw	r2, #539	@ 0x21b
 8001568:	4903      	ldr	r1, [pc, #12]	@ (8001578 <rt_timer_stop+0x58>)
 800156a:	4805      	ldr	r0, [pc, #20]	@ (8001580 <rt_timer_stop+0x60>)
 800156c:	f000 fd1c 	bl	8001fa8 <rt_assert_handler>
 8001570:	e7de      	b.n	8001530 <rt_timer_stop+0x10>
        return -RT_ERROR;
 8001572:	f04f 30ff 	mov.w	r0, #4294967295	@ 0xffffffff
 8001576:	e7ed      	b.n	8001554 <rt_timer_stop+0x34>
 8001578:	08008e30 	.word	0x08008e30
 800157c:	08008670 	.word	0x08008670
 8001580:	080086b0 	.word	0x080086b0

08001584 <rt_timer_control>:
 * @param arg the argument
 *
 * @return the statu of control
 */
rt_err_t rt_timer_control(rt_timer_t timer, int cmd, void *arg)
{
 8001584:	b5f8      	push	{r3, r4, r5, r6, r7, lr}
 8001586:	460c      	mov	r4, r1
 8001588:	4616      	mov	r6, r2
    rt_base_t level;

    /* parameter check */
    RT_ASSERT(timer != RT_NULL);
 800158a:	4607      	mov	r7, r0
 800158c:	b170      	cbz	r0, 80015ac <rt_timer_control+0x28>
    RT_ASSERT(rt_object_get_type(&timer->parent) == RT_Object_Class_Timer);
 800158e:	4638      	mov	r0, r7
 8001590:	f000 f9b6 	bl	8001900 <rt_object_get_type>
 8001594:	280a      	cmp	r0, #10
 8001596:	d110      	bne.n	80015ba <rt_timer_control+0x36>

    level = rt_hw_interrupt_disable();
 8001598:	f7fe fe58 	bl	800024c <rt_hw_interrupt_disable>
 800159c:	4605      	mov	r5, r0
    switch (cmd)
 800159e:	2c05      	cmp	r4, #5
 80015a0:	d814      	bhi.n	80015cc <rt_timer_control+0x48>
 80015a2:	e8df f004 	tbb	[pc, r4]
 80015a6:	1118      	.short	0x1118
 80015a8:	3b312c27 	.word	0x3b312c27
    RT_ASSERT(timer != RT_NULL);
 80015ac:	f240 223e 	movw	r2, #574	@ 0x23e
 80015b0:	491c      	ldr	r1, [pc, #112]	@ (8001624 <rt_timer_control+0xa0>)
 80015b2:	481d      	ldr	r0, [pc, #116]	@ (8001628 <rt_timer_control+0xa4>)
 80015b4:	f000 fcf8 	bl	8001fa8 <rt_assert_handler>
 80015b8:	e7e9      	b.n	800158e <rt_timer_control+0xa>
    RT_ASSERT(rt_object_get_type(&timer->parent) == RT_Object_Class_Timer);
 80015ba:	f240 223f 	movw	r2, #575	@ 0x23f
 80015be:	4919      	ldr	r1, [pc, #100]	@ (8001624 <rt_timer_control+0xa0>)
 80015c0:	481a      	ldr	r0, [pc, #104]	@ (800162c <rt_timer_control+0xa8>)
 80015c2:	f000 fcf1 	bl	8001fa8 <rt_assert_handler>
 80015c6:	e7e7      	b.n	8001598 <rt_timer_control+0x14>
    {
    case RT_TIMER_CTRL_GET_TIME:
        *(rt_tick_t *)arg = timer->init_tick;
 80015c8:	6a7b      	ldr	r3, [r7, #36]	@ 0x24
 80015ca:	6033      	str	r3, [r6, #0]
        break;

    default:
        break;
    }
    rt_hw_interrupt_enable(level);
 80015cc:	4628      	mov	r0, r5
 80015ce:	f7fe fe41 	bl	8000254 <rt_hw_interrupt_enable>

    return RT_EOK;
}
 80015d2:	2000      	movs	r0, #0
 80015d4:	bdf8      	pop	{r3, r4, r5, r6, r7, pc}
        RT_ASSERT((*(rt_tick_t *)arg) < RT_TICK_MAX / 2);
 80015d6:	6832      	ldr	r2, [r6, #0]
 80015d8:	f06f 4300 	mvn.w	r3, #2147483648	@ 0x80000000
 80015dc:	429a      	cmp	r2, r3
 80015de:	d202      	bcs.n	80015e6 <rt_timer_control+0x62>
        timer->init_tick = *(rt_tick_t *)arg;
 80015e0:	6833      	ldr	r3, [r6, #0]
 80015e2:	627b      	str	r3, [r7, #36]	@ 0x24
        break;
 80015e4:	e7f2      	b.n	80015cc <rt_timer_control+0x48>
        RT_ASSERT((*(rt_tick_t *)arg) < RT_TICK_MAX / 2);
 80015e6:	f240 2249 	movw	r2, #585	@ 0x249
 80015ea:	490e      	ldr	r1, [pc, #56]	@ (8001624 <rt_timer_control+0xa0>)
 80015ec:	4810      	ldr	r0, [pc, #64]	@ (8001630 <rt_timer_control+0xac>)
 80015ee:	f000 fcdb 	bl	8001fa8 <rt_assert_handler>
 80015f2:	e7f5      	b.n	80015e0 <rt_timer_control+0x5c>
        timer->parent.flag &= ~RT_TIMER_FLAG_PERIODIC;
 80015f4:	7a7b      	ldrb	r3, [r7, #9]
 80015f6:	f023 0302 	bic.w	r3, r3, #2
 80015fa:	727b      	strb	r3, [r7, #9]
        break;
 80015fc:	e7e6      	b.n	80015cc <rt_timer_control+0x48>
        timer->parent.flag |= RT_TIMER_FLAG_PERIODIC;
 80015fe:	7a7b      	ldrb	r3, [r7, #9]
 8001600:	f043 0302 	orr.w	r3, r3, #2
 8001604:	727b      	strb	r3, [r7, #9]
        break;
 8001606:	e7e1      	b.n	80015cc <rt_timer_control+0x48>
        if(timer->parent.flag & RT_TIMER_FLAG_ACTIVATED)
 8001608:	7a7b      	ldrb	r3, [r7, #9]
 800160a:	f013 0f01 	tst.w	r3, #1
 800160e:	d002      	beq.n	8001616 <rt_timer_control+0x92>
            *(rt_uint32_t *)arg = RT_TIMER_FLAG_ACTIVATED;
 8001610:	2301      	movs	r3, #1
 8001612:	6033      	str	r3, [r6, #0]
 8001614:	e7da      	b.n	80015cc <rt_timer_control+0x48>
            *(rt_uint32_t *)arg = RT_TIMER_FLAG_DEACTIVATED;
 8001616:	2300      	movs	r3, #0
 8001618:	6033      	str	r3, [r6, #0]
 800161a:	e7d7      	b.n	80015cc <rt_timer_control+0x48>
        *(rt_tick_t *)arg =  timer->timeout_tick;
 800161c:	6abb      	ldr	r3, [r7, #40]	@ 0x28
 800161e:	6033      	str	r3, [r6, #0]
        break;
 8001620:	e7d4      	b.n	80015cc <rt_timer_control+0x48>
 8001622:	bf00      	nop
 8001624:	08008dac 	.word	0x08008dac
 8001628:	08008670 	.word	0x08008670
 800162c:	080086b0 	.word	0x080086b0
 8001630:	08008718 	.word	0x08008718

08001634 <rt_timer_check>:
 *        the corresponding timeout function will be invoked.
 *
 * @note This function shall be invoked in operating system timer interrupt.
 */
void rt_timer_check(void)
{
 8001634:	e92d 41f0 	stmdb	sp!, {r4, r5, r6, r7, r8, lr}
 8001638:	b082      	sub	sp, #8
    l->next = l->prev = l;
 800163a:	f8cd d004 	str.w	sp, [sp, #4]
 800163e:	f8cd d000 	str.w	sp, [sp]

    rt_list_init(&list);

    RT_DEBUG_LOG(RT_DEBUG_TIMER, ("timer check enter\n"));

    current_tick = rt_tick_get();
 8001642:	f000 fefb 	bl	800243c <rt_tick_get>
 8001646:	4605      	mov	r5, r0

    /* disable interrupt */
    level = rt_hw_interrupt_disable();
 8001648:	f7fe fe00 	bl	800024c <rt_hw_interrupt_disable>
 800164c:	4680      	mov	r8, r0
 * @brief tests whether a list is empty
 * @param l the list to test.
 */
rt_inline int rt_list_isempty(const rt_list_t *l)
{
    return l->next == l;
 800164e:	4b22      	ldr	r3, [pc, #136]	@ (80016d8 <rt_timer_check+0xa4>)
 8001650:	681c      	ldr	r4, [r3, #0]

    while (!rt_list_isempty(&_timer_list[RT_TIMER_SKIP_LIST_LEVEL - 1]))
 8001652:	429c      	cmp	r4, r3
 8001654:	d03a      	beq.n	80016cc <rt_timer_check+0x98>
    {
        t = rt_list_entry(_timer_list[RT_TIMER_SKIP_LIST_LEVEL - 1].next,
 8001656:	f1a4 0714 	sub.w	r7, r4, #20

        /*
         * It supposes that the new tick shall less than the half duration of
         * tick max.
         */
        if ((current_tick - t->timeout_tick) < RT_TICK_MAX / 2)
 800165a:	6963      	ldr	r3, [r4, #20]
 800165c:	1aeb      	subs	r3, r5, r3
 800165e:	f06f 4200 	mvn.w	r2, #2147483648	@ 0x80000000
 8001662:	4293      	cmp	r3, r2
 8001664:	d232      	bcs.n	80016cc <rt_timer_check+0x98>
        {
            RT_OBJECT_HOOK_CALL(rt_timer_enter_hook, (t));

            /* remove timer from timer list firstly */
            _timer_remove(t);
 8001666:	4638      	mov	r0, r7
 8001668:	f7ff fe60 	bl	800132c <_timer_remove>
            if (!(t->parent.flag & RT_TIMER_FLAG_PERIODIC))
 800166c:	f814 3c0b 	ldrb.w	r3, [r4, #-11]
 8001670:	f013 0f02 	tst.w	r3, #2
 8001674:	d103      	bne.n	800167e <rt_timer_check+0x4a>
            {
                t->parent.flag &= ~RT_TIMER_FLAG_ACTIVATED;
 8001676:	f023 0301 	bic.w	r3, r3, #1
 800167a:	f804 3c0b 	strb.w	r3, [r4, #-11]
    l->next->prev = n;
 800167e:	9b00      	ldr	r3, [sp, #0]
 8001680:	605c      	str	r4, [r3, #4]
    n->next = l->next;
 8001682:	6023      	str	r3, [r4, #0]
    l->next = n;
 8001684:	9400      	str	r4, [sp, #0]
    n->prev = l;
 8001686:	466e      	mov	r6, sp
 8001688:	f8c4 d004 	str.w	sp, [r4, #4]
            }
            /* add timer to temporary list  */
            rt_list_insert_after(&list, &(t->row[RT_TIMER_SKIP_LIST_LEVEL - 1]));
            /* call timeout function */
            t->timeout_func(t->parameter);
 800168c:	68a3      	ldr	r3, [r4, #8]
 800168e:	68e0      	ldr	r0, [r4, #12]
 8001690:	4798      	blx	r3

            /* re-get tick */
            current_tick = rt_tick_get();
 8001692:	f000 fed3 	bl	800243c <rt_tick_get>
 8001696:	4605      	mov	r5, r0
    return l->next == l;
 8001698:	9b00      	ldr	r3, [sp, #0]

            RT_OBJECT_HOOK_CALL(rt_timer_exit_hook, (t));
            RT_DEBUG_LOG(RT_DEBUG_TIMER, ("current tick: %d\n", current_tick));

            /* Check whether the timer object is detached or started again */
            if (rt_list_isempty(&list))
 800169a:	42b3      	cmp	r3, r6
 800169c:	d0d7      	beq.n	800164e <rt_timer_check+0x1a>
    n->next->prev = n->prev;
 800169e:	6822      	ldr	r2, [r4, #0]
 80016a0:	6863      	ldr	r3, [r4, #4]
 80016a2:	6053      	str	r3, [r2, #4]
    n->prev->next = n->next;
 80016a4:	6822      	ldr	r2, [r4, #0]
 80016a6:	601a      	str	r2, [r3, #0]
    n->next = n->prev = n;
 80016a8:	6064      	str	r4, [r4, #4]
 80016aa:	6024      	str	r4, [r4, #0]
            {
                continue;
            }
            rt_list_remove(&(t->row[RT_TIMER_SKIP_LIST_LEVEL - 1]));
            if ((t->parent.flag & RT_TIMER_FLAG_PERIODIC) &&
 80016ac:	f814 3c0b 	ldrb.w	r3, [r4, #-11]
 80016b0:	f013 0f02 	tst.w	r3, #2
 80016b4:	d0cb      	beq.n	800164e <rt_timer_check+0x1a>
 80016b6:	f013 0f01 	tst.w	r3, #1
 80016ba:	d0c8      	beq.n	800164e <rt_timer_check+0x1a>
                (t->parent.flag & RT_TIMER_FLAG_ACTIVATED))
            {
                /* start it */
                t->parent.flag &= ~RT_TIMER_FLAG_ACTIVATED;
 80016bc:	f023 0301 	bic.w	r3, r3, #1
 80016c0:	f804 3c0b 	strb.w	r3, [r4, #-11]
                rt_timer_start(t);
 80016c4:	4638      	mov	r0, r7
 80016c6:	f7ff fec1 	bl	800144c <rt_timer_start>
 80016ca:	e7c0      	b.n	800164e <rt_timer_check+0x1a>
        }
        else break;
    }

    /* enable interrupt */
    rt_hw_interrupt_enable(level);
 80016cc:	4640      	mov	r0, r8
 80016ce:	f7fe fdc1 	bl	8000254 <rt_hw_interrupt_enable>

    RT_DEBUG_LOG(RT_DEBUG_TIMER, ("timer check leave\n"));
}
 80016d2:	b002      	add	sp, #8
 80016d4:	e8bd 81f0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, pc}
 80016d8:	200000cc 	.word	0x200000cc

080016dc <rt_system_timer_init>:
 */
void rt_system_timer_init(void)
{
    rt_size_t i;

    for (i = 0; i < sizeof(_timer_list) / sizeof(_timer_list[0]); i++)
 80016dc:	2200      	movs	r2, #0
 80016de:	b102      	cbz	r2, 80016e2 <rt_system_timer_init+0x6>
    {
        rt_list_init(_timer_list + i);
    }
}
 80016e0:	4770      	bx	lr
        rt_list_init(_timer_list + i);
 80016e2:	4b03      	ldr	r3, [pc, #12]	@ (80016f0 <rt_system_timer_init+0x14>)
 80016e4:	eb03 03c2 	add.w	r3, r3, r2, lsl #3
    l->next = l->prev = l;
 80016e8:	605b      	str	r3, [r3, #4]
 80016ea:	601b      	str	r3, [r3, #0]
    for (i = 0; i < sizeof(_timer_list) / sizeof(_timer_list[0]); i++)
 80016ec:	3201      	adds	r2, #1
 80016ee:	e7f6      	b.n	80016de <rt_system_timer_init+0x2>
 80016f0:	200000cc 	.word	0x200000cc

080016f4 <rt_system_timer_thread_init>:
                   10);

    /* startup */
    rt_thread_startup(&_timer_thread);
#endif /* RT_USING_TIMER_SOFT */
}
 80016f4:	4770      	bx	lr
	...

080016f8 <rt_object_get_information>:
struct rt_object_information *
rt_object_get_information(enum rt_object_class_type type)
{
    int index;

    for (index = 0; index < RT_Object_Info_Unknown; index ++)
 80016f8:	2300      	movs	r3, #0
 80016fa:	2b07      	cmp	r3, #7
 80016fc:	dc09      	bgt.n	8001712 <rt_object_get_information+0x1a>
        if (_object_container[index].type == type) return &_object_container[index];
 80016fe:	011a      	lsls	r2, r3, #4
 8001700:	4905      	ldr	r1, [pc, #20]	@ (8001718 <rt_object_get_information+0x20>)
 8001702:	5c8a      	ldrb	r2, [r1, r2]
 8001704:	4282      	cmp	r2, r0
 8001706:	d001      	beq.n	800170c <rt_object_get_information+0x14>
    for (index = 0; index < RT_Object_Info_Unknown; index ++)
 8001708:	3301      	adds	r3, #1
 800170a:	e7f6      	b.n	80016fa <rt_object_get_information+0x2>
        if (_object_container[index].type == type) return &_object_container[index];
 800170c:	eb01 1003 	add.w	r0, r1, r3, lsl #4
 8001710:	4770      	bx	lr

    return RT_NULL;
 8001712:	2000      	movs	r0, #0
}
 8001714:	4770      	bx	lr
 8001716:	bf00      	nop
 8001718:	20000004 	.word	0x20000004

0800171c <rt_object_init>:
 * @param name is the object name. In system, the object's name must be unique.
 */
void rt_object_init(struct rt_object         *object,
                    enum rt_object_class_type type,
                    const char               *name)
{
 800171c:	e92d 43f8 	stmdb	sp!, {r3, r4, r5, r6, r7, r8, r9, lr}
 8001720:	4606      	mov	r6, r0
 8001722:	4688      	mov	r8, r1
 8001724:	4691      	mov	r9, r2
#ifdef RT_USING_MODULE
    struct rt_dlmodule *module = dlmodule_self();
#endif /* RT_USING_MODULE */

    /* get object information */
    information = rt_object_get_information(type);
 8001726:	4608      	mov	r0, r1
 8001728:	f7ff ffe6 	bl	80016f8 <rt_object_get_information>
    RT_ASSERT(information != RT_NULL);
 800172c:	4607      	mov	r7, r0
 800172e:	b118      	cbz	r0, 8001738 <rt_object_init+0x1c>

    /* check object type to avoid re-initialization */

    /* enter critical */
    rt_enter_critical();
 8001730:	f001 f9c8 	bl	8002ac4 <rt_enter_critical>
    /* try to find object */
    for (node  = information->object_list.next;
 8001734:	687c      	ldr	r4, [r7, #4]
 8001736:	e007      	b.n	8001748 <rt_object_init+0x2c>
    RT_ASSERT(information != RT_NULL);
 8001738:	f44f 72ab 	mov.w	r2, #342	@ 0x156
 800173c:	4916      	ldr	r1, [pc, #88]	@ (8001798 <rt_object_init+0x7c>)
 800173e:	4817      	ldr	r0, [pc, #92]	@ (800179c <rt_object_init+0x80>)
 8001740:	f000 fc32 	bl	8001fa8 <rt_assert_handler>
 8001744:	e7f4      	b.n	8001730 <rt_object_init+0x14>
            node != &(information->object_list);
            node  = node->next)
 8001746:	6824      	ldr	r4, [r4, #0]
            node != &(information->object_list);
 8001748:	1d3d      	adds	r5, r7, #4
 800174a:	42a5      	cmp	r5, r4
 800174c:	d00a      	beq.n	8001764 <rt_object_init+0x48>
    {
        struct rt_object *obj;

        obj = rt_list_entry(node, struct rt_object, list);
 800174e:	f1a4 030c 	sub.w	r3, r4, #12
        if (obj) /* skip warning when disable debug */
        {
            RT_ASSERT(obj != object);
 8001752:	429e      	cmp	r6, r3
 8001754:	d1f7      	bne.n	8001746 <rt_object_init+0x2a>
 8001756:	f44f 72b3 	mov.w	r2, #358	@ 0x166
 800175a:	490f      	ldr	r1, [pc, #60]	@ (8001798 <rt_object_init+0x7c>)
 800175c:	4810      	ldr	r0, [pc, #64]	@ (80017a0 <rt_object_init+0x84>)
 800175e:	f000 fc23 	bl	8001fa8 <rt_assert_handler>
 8001762:	e7f0      	b.n	8001746 <rt_object_init+0x2a>
        }
    }
    /* leave critical */
    rt_exit_critical();
 8001764:	f001 f9ba 	bl	8002adc <rt_exit_critical>

    /* initialize object's parameters */
    /* set object type to static */
    object->type = type | RT_Object_Class_Static;
 8001768:	f068 087f 	orn	r8, r8, #127	@ 0x7f
 800176c:	f886 8008 	strb.w	r8, [r6, #8]
    /* copy name */
    rt_strncpy(object->name, name, RT_NAME_MAX);
 8001770:	2208      	movs	r2, #8
 8001772:	4649      	mov	r1, r9
 8001774:	4630      	mov	r0, r6
 8001776:	f000 fa09 	bl	8001b8c <rt_strncpy>

    RT_OBJECT_HOOK_CALL(rt_object_attach_hook, (object));

    /* lock interrupt */
    level = rt_hw_interrupt_disable();
 800177a:	f7fe fd67 	bl	800024c <rt_hw_interrupt_disable>
    }
    else
#endif /* RT_USING_MODULE */
    {
        /* insert object into information object list */
        rt_list_insert_after(&(information->object_list), &(object->list));
 800177e:	f106 030c 	add.w	r3, r6, #12
    l->next->prev = n;
 8001782:	687a      	ldr	r2, [r7, #4]
 8001784:	6053      	str	r3, [r2, #4]
    n->next = l->next;
 8001786:	687a      	ldr	r2, [r7, #4]
 8001788:	60f2      	str	r2, [r6, #12]
    l->next = n;
 800178a:	607b      	str	r3, [r7, #4]
    n->prev = l;
 800178c:	6135      	str	r5, [r6, #16]
    }

    /* unlock interrupt */
    rt_hw_interrupt_enable(level);
 800178e:	f7fe fd61 	bl	8000254 <rt_hw_interrupt_enable>
}
 8001792:	e8bd 83f8 	ldmia.w	sp!, {r3, r4, r5, r6, r7, r8, r9, pc}
 8001796:	bf00      	nop
 8001798:	08009008 	.word	0x08009008
 800179c:	08008740 	.word	0x08008740
 80017a0:	08008758 	.word	0x08008758

080017a4 <rt_object_detach>:
 *        and the memory of static object is not freed.
 *
 * @param object the specified object to be detached.
 */
void rt_object_detach(rt_object_t object)
{
 80017a4:	b510      	push	{r4, lr}
    rt_base_t level;

    /* object check */
    RT_ASSERT(object != RT_NULL);
 80017a6:	4604      	mov	r4, r0
 80017a8:	b178      	cbz	r0, 80017ca <rt_object_detach+0x26>

    RT_OBJECT_HOOK_CALL(rt_object_detach_hook, (object));

    /* reset object type */
    object->type = 0;
 80017aa:	2300      	movs	r3, #0
 80017ac:	7223      	strb	r3, [r4, #8]

    /* lock interrupt */
    level = rt_hw_interrupt_disable();
 80017ae:	f7fe fd4d 	bl	800024c <rt_hw_interrupt_disable>

    /* remove from old list */
    rt_list_remove(&(object->list));
 80017b2:	f104 030c 	add.w	r3, r4, #12
    n->next->prev = n->prev;
 80017b6:	68e1      	ldr	r1, [r4, #12]
 80017b8:	6922      	ldr	r2, [r4, #16]
 80017ba:	604a      	str	r2, [r1, #4]
    n->prev->next = n->next;
 80017bc:	68e1      	ldr	r1, [r4, #12]
 80017be:	6011      	str	r1, [r2, #0]
    n->next = n->prev = n;
 80017c0:	6123      	str	r3, [r4, #16]
 80017c2:	60e3      	str	r3, [r4, #12]

    /* unlock interrupt */
    rt_hw_interrupt_enable(level);
 80017c4:	f7fe fd46 	bl	8000254 <rt_hw_interrupt_enable>
}
 80017c8:	bd10      	pop	{r4, pc}
    RT_ASSERT(object != RT_NULL);
 80017ca:	f240 1293 	movw	r2, #403	@ 0x193
 80017ce:	4902      	ldr	r1, [pc, #8]	@ (80017d8 <rt_object_detach+0x34>)
 80017d0:	4802      	ldr	r0, [pc, #8]	@ (80017dc <rt_object_detach+0x38>)
 80017d2:	f000 fbe9 	bl	8001fa8 <rt_assert_handler>
 80017d6:	e7e8      	b.n	80017aa <rt_object_detach+0x6>
 80017d8:	08008fc0 	.word	0x08008fc0
 80017dc:	08008768 	.word	0x08008768

080017e0 <rt_object_allocate>:
 * @param name is the object name. In system, the object's name must be unique.
 *
 * @return object
 */
rt_object_t rt_object_allocate(enum rt_object_class_type type, const char *name)
{
 80017e0:	b5f8      	push	{r3, r4, r5, r6, r7, lr}
 80017e2:	4606      	mov	r6, r0
 80017e4:	460f      	mov	r7, r1
    struct rt_object_information *information;
#ifdef RT_USING_MODULE
    struct rt_dlmodule *module = dlmodule_self();
#endif /* RT_USING_MODULE */

    RT_DEBUG_NOT_IN_INTERRUPT;
 80017e6:	f7fe fd31 	bl	800024c <rt_hw_interrupt_disable>
 80017ea:	4604      	mov	r4, r0
 80017ec:	f000 f8b6 	bl	800195c <rt_interrupt_get_nest>
 80017f0:	bb38      	cbnz	r0, 8001842 <rt_object_allocate+0x62>
 80017f2:	4620      	mov	r0, r4
 80017f4:	f7fe fd2e 	bl	8000254 <rt_hw_interrupt_enable>

    /* get object information */
    information = rt_object_get_information(type);
 80017f8:	4630      	mov	r0, r6
 80017fa:	f7ff ff7d 	bl	80016f8 <rt_object_get_information>
    RT_ASSERT(information != RT_NULL);
 80017fe:	4605      	mov	r5, r0
 8001800:	b358      	cbz	r0, 800185a <rt_object_allocate+0x7a>

    object = (struct rt_object *)RT_KERNEL_MALLOC(information->object_size);
 8001802:	68e8      	ldr	r0, [r5, #12]
 8001804:	f000 fc2a 	bl	800205c <rt_malloc>
    if (object == RT_NULL)
 8001808:	4604      	mov	r4, r0
 800180a:	b1c0      	cbz	r0, 800183e <rt_object_allocate+0x5e>
        /* no memory can be allocated */
        return RT_NULL;
    }

    /* clean memory data of object */
    rt_memset(object, 0x0, information->object_size);
 800180c:	68ea      	ldr	r2, [r5, #12]
 800180e:	2100      	movs	r1, #0
 8001810:	f000 f98a 	bl	8001b28 <rt_memset>

    /* initialize object's parameters */

    /* set object type */
    object->type = type;
 8001814:	7226      	strb	r6, [r4, #8]

    /* set object flag */
    object->flag = 0;
 8001816:	2300      	movs	r3, #0
 8001818:	7263      	strb	r3, [r4, #9]

    /* copy name */
    rt_strncpy(object->name, name, RT_NAME_MAX);
 800181a:	2208      	movs	r2, #8
 800181c:	4639      	mov	r1, r7
 800181e:	4620      	mov	r0, r4
 8001820:	f000 f9b4 	bl	8001b8c <rt_strncpy>

    RT_OBJECT_HOOK_CALL(rt_object_attach_hook, (object));

    /* lock interrupt */
    level = rt_hw_interrupt_disable();
 8001824:	f7fe fd12 	bl	800024c <rt_hw_interrupt_disable>
    }
    else
#endif /* RT_USING_MODULE */
    {
        /* insert object into information object list */
        rt_list_insert_after(&(information->object_list), &(object->list));
 8001828:	1d2a      	adds	r2, r5, #4
 800182a:	f104 030c 	add.w	r3, r4, #12
    l->next->prev = n;
 800182e:	6869      	ldr	r1, [r5, #4]
 8001830:	604b      	str	r3, [r1, #4]
    n->next = l->next;
 8001832:	6869      	ldr	r1, [r5, #4]
 8001834:	60e1      	str	r1, [r4, #12]
    l->next = n;
 8001836:	606b      	str	r3, [r5, #4]
    n->prev = l;
 8001838:	6122      	str	r2, [r4, #16]
    }

    /* unlock interrupt */
    rt_hw_interrupt_enable(level);
 800183a:	f7fe fd0b 	bl	8000254 <rt_hw_interrupt_enable>

    /* return object */
    return object;
}
 800183e:	4620      	mov	r0, r4
 8001840:	bdf8      	pop	{r3, r4, r5, r6, r7, pc}
    RT_DEBUG_NOT_IN_INTERRUPT;
 8001842:	4d09      	ldr	r5, [pc, #36]	@ (8001868 <rt_object_allocate+0x88>)
 8001844:	4629      	mov	r1, r5
 8001846:	4809      	ldr	r0, [pc, #36]	@ (800186c <rt_object_allocate+0x8c>)
 8001848:	f000 fb4e 	bl	8001ee8 <rt_kprintf>
 800184c:	f240 12b7 	movw	r2, #439	@ 0x1b7
 8001850:	4629      	mov	r1, r5
 8001852:	4807      	ldr	r0, [pc, #28]	@ (8001870 <rt_object_allocate+0x90>)
 8001854:	f000 fba8 	bl	8001fa8 <rt_assert_handler>
 8001858:	e7cb      	b.n	80017f2 <rt_object_allocate+0x12>
    RT_ASSERT(information != RT_NULL);
 800185a:	f240 12bb 	movw	r2, #443	@ 0x1bb
 800185e:	4902      	ldr	r1, [pc, #8]	@ (8001868 <rt_object_allocate+0x88>)
 8001860:	4804      	ldr	r0, [pc, #16]	@ (8001874 <rt_object_allocate+0x94>)
 8001862:	f000 fba1 	bl	8001fa8 <rt_assert_handler>
 8001866:	e7cc      	b.n	8001802 <rt_object_allocate+0x22>
 8001868:	08008f68 	.word	0x08008f68
 800186c:	0800877c 	.word	0x0800877c
 8001870:	080087a4 	.word	0x080087a4
 8001874:	08008740 	.word	0x08008740

08001878 <rt_object_delete>:
 * @brief This function will delete an object and release object memory.
 *
 * @param object is the specified object to be deleted.
 */
void rt_object_delete(rt_object_t object)
{
 8001878:	b510      	push	{r4, lr}
    rt_base_t level;

    /* object check */
    RT_ASSERT(object != RT_NULL);
 800187a:	4604      	mov	r4, r0
 800187c:	b1b0      	cbz	r0, 80018ac <rt_object_delete+0x34>
    RT_ASSERT(!(object->type & RT_Object_Class_Static));
 800187e:	f994 3008 	ldrsb.w	r3, [r4, #8]
 8001882:	2b00      	cmp	r3, #0
 8001884:	db19      	blt.n	80018ba <rt_object_delete+0x42>

    RT_OBJECT_HOOK_CALL(rt_object_detach_hook, (object));

    /* reset object type */
    object->type = RT_Object_Class_Null;
 8001886:	2300      	movs	r3, #0
 8001888:	7223      	strb	r3, [r4, #8]

    /* lock interrupt */
    level = rt_hw_interrupt_disable();
 800188a:	f7fe fcdf 	bl	800024c <rt_hw_interrupt_disable>

    /* remove from old list */
    rt_list_remove(&(object->list));
 800188e:	f104 030c 	add.w	r3, r4, #12
    n->next->prev = n->prev;
 8001892:	68e1      	ldr	r1, [r4, #12]
 8001894:	6922      	ldr	r2, [r4, #16]
 8001896:	604a      	str	r2, [r1, #4]
    n->prev->next = n->next;
 8001898:	68e1      	ldr	r1, [r4, #12]
 800189a:	6011      	str	r1, [r2, #0]
    n->next = n->prev = n;
 800189c:	6123      	str	r3, [r4, #16]
 800189e:	60e3      	str	r3, [r4, #12]

    /* unlock interrupt */
    rt_hw_interrupt_enable(level);
 80018a0:	f7fe fcd8 	bl	8000254 <rt_hw_interrupt_enable>

    /* free the memory of object */
    RT_KERNEL_FREE(object);
 80018a4:	4620      	mov	r0, r4
 80018a6:	f000 fbeb 	bl	8002080 <rt_free>
}
 80018aa:	bd10      	pop	{r4, pc}
    RT_ASSERT(object != RT_NULL);
 80018ac:	f240 12f5 	movw	r2, #501	@ 0x1f5
 80018b0:	4905      	ldr	r1, [pc, #20]	@ (80018c8 <rt_object_delete+0x50>)
 80018b2:	4806      	ldr	r0, [pc, #24]	@ (80018cc <rt_object_delete+0x54>)
 80018b4:	f000 fb78 	bl	8001fa8 <rt_assert_handler>
 80018b8:	e7e1      	b.n	800187e <rt_object_delete+0x6>
    RT_ASSERT(!(object->type & RT_Object_Class_Static));
 80018ba:	f44f 72fb 	mov.w	r2, #502	@ 0x1f6
 80018be:	4902      	ldr	r1, [pc, #8]	@ (80018c8 <rt_object_delete+0x50>)
 80018c0:	4803      	ldr	r0, [pc, #12]	@ (80018d0 <rt_object_delete+0x58>)
 80018c2:	f000 fb71 	bl	8001fa8 <rt_assert_handler>
 80018c6:	e7de      	b.n	8001886 <rt_object_delete+0xe>
 80018c8:	08008f14 	.word	0x08008f14
 80018cc:	08008768 	.word	0x08008768
 80018d0:	080087a8 	.word	0x080087a8

080018d4 <rt_object_is_systemobject>:
 * @param object is the specified object to be judged.
 *
 * @return RT_TRUE if a system object, RT_FALSE for others.
 */
rt_bool_t rt_object_is_systemobject(rt_object_t object)
{
 80018d4:	b510      	push	{r4, lr}
    /* object check */
    RT_ASSERT(object != RT_NULL);
 80018d6:	4604      	mov	r4, r0
 80018d8:	b128      	cbz	r0, 80018e6 <rt_object_is_systemobject+0x12>

    if (object->type & RT_Object_Class_Static)
 80018da:	f994 3008 	ldrsb.w	r3, [r4, #8]
 80018de:	2b00      	cmp	r3, #0
 80018e0:	db08      	blt.n	80018f4 <rt_object_is_systemobject+0x20>
        return RT_TRUE;

    return RT_FALSE;
 80018e2:	2000      	movs	r0, #0
}
 80018e4:	bd10      	pop	{r4, pc}
    RT_ASSERT(object != RT_NULL);
 80018e6:	f44f 7206 	mov.w	r2, #536	@ 0x218
 80018ea:	4903      	ldr	r1, [pc, #12]	@ (80018f8 <rt_object_is_systemobject+0x24>)
 80018ec:	4803      	ldr	r0, [pc, #12]	@ (80018fc <rt_object_is_systemobject+0x28>)
 80018ee:	f000 fb5b 	bl	8001fa8 <rt_assert_handler>
 80018f2:	e7f2      	b.n	80018da <rt_object_is_systemobject+0x6>
        return RT_TRUE;
 80018f4:	2001      	movs	r0, #1
 80018f6:	e7f5      	b.n	80018e4 <rt_object_is_systemobject+0x10>
 80018f8:	08008eb0 	.word	0x08008eb0
 80018fc:	08008768 	.word	0x08008768

08001900 <rt_object_get_type>:
 * @param object is the specified object to be get type.
 *
 * @return the type of object.
 */
rt_uint8_t rt_object_get_type(rt_object_t object)
{
 8001900:	b510      	push	{r4, lr}
    /* object check */
    RT_ASSERT(object != RT_NULL);
 8001902:	4604      	mov	r4, r0
 8001904:	b118      	cbz	r0, 800190e <rt_object_get_type+0xe>

    return object->type & ~RT_Object_Class_Static;
 8001906:	7a20      	ldrb	r0, [r4, #8]
}
 8001908:	f000 007f 	and.w	r0, r0, #127	@ 0x7f
 800190c:	bd10      	pop	{r4, pc}
    RT_ASSERT(object != RT_NULL);
 800190e:	f240 222b 	movw	r2, #555	@ 0x22b
 8001912:	4902      	ldr	r1, [pc, #8]	@ (800191c <rt_object_get_type+0x1c>)
 8001914:	4802      	ldr	r0, [pc, #8]	@ (8001920 <rt_object_get_type+0x20>)
 8001916:	f000 fb47 	bl	8001fa8 <rt_assert_handler>
 800191a:	e7f4      	b.n	8001906 <rt_object_get_type+0x6>
 800191c:	08008e40 	.word	0x08008e40
 8001920:	08008768 	.word	0x08008768

08001924 <rt_interrupt_enter>:
 * @note Please don't invoke this routine in application
 *
 * @see rt_interrupt_leave
 */
void rt_interrupt_enter(void)
{
 8001924:	b508      	push	{r3, lr}
    rt_base_t level;

    level = rt_hw_interrupt_disable();
 8001926:	f7fe fc91 	bl	800024c <rt_hw_interrupt_disable>
    rt_interrupt_nest ++;
 800192a:	4a04      	ldr	r2, [pc, #16]	@ (800193c <rt_interrupt_enter+0x18>)
 800192c:	7813      	ldrb	r3, [r2, #0]
 800192e:	3301      	adds	r3, #1
 8001930:	b2db      	uxtb	r3, r3
 8001932:	7013      	strb	r3, [r2, #0]
    RT_OBJECT_HOOK_CALL(rt_interrupt_enter_hook,());
    rt_hw_interrupt_enable(level);
 8001934:	f7fe fc8e 	bl	8000254 <rt_hw_interrupt_enable>

    RT_DEBUG_LOG(RT_DEBUG_IRQ, ("irq has come..., irq current nest:%d\n",
                                (rt_int32_t)rt_interrupt_nest));
}
 8001938:	bd08      	pop	{r3, pc}
 800193a:	bf00      	nop
 800193c:	200000d4 	.word	0x200000d4

08001940 <rt_interrupt_leave>:
 * @note Please don't invoke this routine in application
 *
 * @see rt_interrupt_enter
 */
void rt_interrupt_leave(void)
{
 8001940:	b508      	push	{r3, lr}
    rt_base_t level;

    RT_DEBUG_LOG(RT_DEBUG_IRQ, ("irq is going to leave, irq current nest:%d\n",
                                (rt_int32_t)rt_interrupt_nest));

    level = rt_hw_interrupt_disable();
 8001942:	f7fe fc83 	bl	800024c <rt_hw_interrupt_disable>
    RT_OBJECT_HOOK_CALL(rt_interrupt_leave_hook,());
    rt_interrupt_nest --;
 8001946:	4a04      	ldr	r2, [pc, #16]	@ (8001958 <rt_interrupt_leave+0x18>)
 8001948:	7813      	ldrb	r3, [r2, #0]
 800194a:	3b01      	subs	r3, #1
 800194c:	b2db      	uxtb	r3, r3
 800194e:	7013      	strb	r3, [r2, #0]
    rt_hw_interrupt_enable(level);
 8001950:	f7fe fc80 	bl	8000254 <rt_hw_interrupt_enable>
}
 8001954:	bd08      	pop	{r3, pc}
 8001956:	bf00      	nop
 8001958:	200000d4 	.word	0x200000d4

0800195c <rt_interrupt_get_nest>:
 * context is interrupt context.
 *
 * @return the number of nested interrupts.
 */
RT_WEAK rt_uint8_t rt_interrupt_get_nest(void)
{
 800195c:	b510      	push	{r4, lr}
    rt_uint8_t ret;
    rt_base_t level;

    level = rt_hw_interrupt_disable();
 800195e:	f7fe fc75 	bl	800024c <rt_hw_interrupt_disable>
    ret = rt_interrupt_nest;
 8001962:	4b03      	ldr	r3, [pc, #12]	@ (8001970 <rt_interrupt_get_nest+0x14>)
 8001964:	781c      	ldrb	r4, [r3, #0]
 8001966:	b2e4      	uxtb	r4, r4
    rt_hw_interrupt_enable(level);
 8001968:	f7fe fc74 	bl	8000254 <rt_hw_interrupt_enable>
    return ret;
}
 800196c:	4620      	mov	r0, r4
 800196e:	bd10      	pop	{r4, pc}
 8001970:	200000d4 	.word	0x200000d4

08001974 <skip_atoi>:

    return res;
}

rt_inline int skip_atoi(const char **s)
{
 8001974:	4601      	mov	r1, r0
    int i = 0;
 8001976:	2000      	movs	r0, #0
    while (_ISDIGIT(**s))
 8001978:	e008      	b.n	800198c <skip_atoi+0x18>
        i = i * 10 + *((*s)++) - '0';
 800197a:	eb00 0080 	add.w	r0, r0, r0, lsl #2
 800197e:	1c53      	adds	r3, r2, #1
 8001980:	600b      	str	r3, [r1, #0]
 8001982:	7813      	ldrb	r3, [r2, #0]
 8001984:	eb03 0340 	add.w	r3, r3, r0, lsl #1
 8001988:	f1a3 0030 	sub.w	r0, r3, #48	@ 0x30
    while (_ISDIGIT(**s))
 800198c:	680a      	ldr	r2, [r1, #0]
 800198e:	7813      	ldrb	r3, [r2, #0]
 8001990:	3b30      	subs	r3, #48	@ 0x30
 8001992:	2b09      	cmp	r3, #9
 8001994:	d9f1      	bls.n	800197a <skip_atoi+0x6>

    return i;
}
 8001996:	4770      	bx	lr

08001998 <print_number>:
                          int   s,
#ifdef RT_PRINTF_PRECISION
                          int   precision,
#endif /* RT_PRINTF_PRECISION */
                          int   type)
{
 8001998:	e92d 47f0 	stmdb	sp!, {r4, r5, r6, r7, r8, r9, sl, lr}
 800199c:	b084      	sub	sp, #16
 800199e:	4699      	mov	r9, r3
 80019a0:	9c0d      	ldr	r4, [sp, #52]	@ 0x34
 80019a2:	9d0e      	ldr	r5, [sp, #56]	@ 0x38
    static const char large_digits[] = "0123456789ABCDEF";
    int i, size;

    size = s;

    digits = (type & LARGE) ? large_digits : small_digits;
 80019a4:	f015 0f40 	tst.w	r5, #64	@ 0x40
 80019a8:	d014      	beq.n	80019d4 <print_number+0x3c>
 80019aa:	f8df a158 	ldr.w	sl, [pc, #344]	@ 8001b04 <print_number+0x16c>
    if (type & LEFT)
 80019ae:	f015 0f10 	tst.w	r5, #16
 80019b2:	d012      	beq.n	80019da <print_number+0x42>
        type &= ~ZEROPAD;
 80019b4:	f025 0501 	bic.w	r5, r5, #1

    c = (type & ZEROPAD) ? '0' : ' ';
 80019b8:	2620      	movs	r6, #32

    /* get sign */
    sign = 0;
    if (type & SIGN)
 80019ba:	f015 0f02 	tst.w	r5, #2
 80019be:	d016      	beq.n	80019ee <print_number+0x56>
    {
        if (num < 0)
 80019c0:	2a00      	cmp	r2, #0
 80019c2:	db11      	blt.n	80019e8 <print_number+0x50>
        {
            sign = '-';
            num = -num;
        }
        else if (type & PLUS)
 80019c4:	f015 0f04 	tst.w	r5, #4
 80019c8:	d129      	bne.n	8001a1e <print_number+0x86>
            sign = '+';
        else if (type & SPACE)
 80019ca:	f015 0f08 	tst.w	r5, #8
 80019ce:	d128      	bne.n	8001a22 <print_number+0x8a>
    sign = 0;
 80019d0:	2700      	movs	r7, #0
 80019d2:	e00d      	b.n	80019f0 <print_number+0x58>
    digits = (type & LARGE) ? large_digits : small_digits;
 80019d4:	f8df a130 	ldr.w	sl, [pc, #304]	@ 8001b08 <print_number+0x170>
 80019d8:	e7e9      	b.n	80019ae <print_number+0x16>
    c = (type & ZEROPAD) ? '0' : ' ';
 80019da:	f015 0f01 	tst.w	r5, #1
 80019de:	d001      	beq.n	80019e4 <print_number+0x4c>
 80019e0:	2630      	movs	r6, #48	@ 0x30
 80019e2:	e7ea      	b.n	80019ba <print_number+0x22>
 80019e4:	2620      	movs	r6, #32
 80019e6:	e7e8      	b.n	80019ba <print_number+0x22>
            num = -num;
 80019e8:	4252      	negs	r2, r2
            sign = '-';
 80019ea:	272d      	movs	r7, #45	@ 0x2d
 80019ec:	e000      	b.n	80019f0 <print_number+0x58>
    sign = 0;
 80019ee:	2700      	movs	r7, #0
            size--;
    }
#endif /* RT_PRINTF_SPECIAL */

    i = 0;
    if (num == 0)
 80019f0:	bbaa      	cbnz	r2, 8001a5e <print_number+0xc6>
        tmp[i++] = '0';
 80019f2:	2330      	movs	r3, #48	@ 0x30
 80019f4:	f88d 3000 	strb.w	r3, [sp]
 80019f8:	f04f 0c01 	mov.w	ip, #1
        while (num != 0)
            tmp[i++] = digits[divide(&num, base)];
    }

#ifdef RT_PRINTF_PRECISION
    if (i > precision)
 80019fc:	45a4      	cmp	ip, r4
 80019fe:	dc31      	bgt.n	8001a64 <print_number+0xcc>
 8001a00:	4622      	mov	r2, r4
        precision = i;
    size -= precision;
 8001a02:	9b0c      	ldr	r3, [sp, #48]	@ 0x30
 8001a04:	eba3 0e02 	sub.w	lr, r3, r2
#else
    size -= i;
#endif /* RT_PRINTF_PRECISION */

    if (!(type & (ZEROPAD | LEFT)))
 8001a08:	f015 0f11 	tst.w	r5, #17
 8001a0c:	d137      	bne.n	8001a7e <print_number+0xe6>
    {
        if ((sign) && (size > 0))
 8001a0e:	b127      	cbz	r7, 8001a1a <print_number+0x82>
 8001a10:	f1be 0f00 	cmp.w	lr, #0
 8001a14:	dd01      	ble.n	8001a1a <print_number+0x82>
            size--;
 8001a16:	f10e 3eff 	add.w	lr, lr, #4294967295	@ 0xffffffff
        precision = i;
 8001a1a:	4673      	mov	r3, lr
 8001a1c:	e026      	b.n	8001a6c <print_number+0xd4>
            sign = '+';
 8001a1e:	272b      	movs	r7, #43	@ 0x2b
 8001a20:	e7e6      	b.n	80019f0 <print_number+0x58>
            sign = ' ';
 8001a22:	2720      	movs	r7, #32
 8001a24:	e7e4      	b.n	80019f0 <print_number+0x58>
        res = (int)(((unsigned long)*n) % 10U);
 8001a26:	4b36      	ldr	r3, [pc, #216]	@ (8001b00 <print_number+0x168>)
 8001a28:	fba3 3e02 	umull	r3, lr, r3, r2
 8001a2c:	ea4f 0ede 	mov.w	lr, lr, lsr #3
 8001a30:	eb0e 088e 	add.w	r8, lr, lr, lsl #2
 8001a34:	eba2 0848 	sub.w	r8, r2, r8, lsl #1
        *n = (long)(((unsigned long)*n) / 10U);
 8001a38:	4672      	mov	r2, lr
            tmp[i++] = digits[divide(&num, base)];
 8001a3a:	f81a e008 	ldrb.w	lr, [sl, r8]
 8001a3e:	f10c 0310 	add.w	r3, ip, #16
 8001a42:	446b      	add	r3, sp
 8001a44:	f803 ec10 	strb.w	lr, [r3, #-16]
 8001a48:	f10c 0c01 	add.w	ip, ip, #1
        while (num != 0)
 8001a4c:	2a00      	cmp	r2, #0
 8001a4e:	d0d5      	beq.n	80019fc <print_number+0x64>
    if (base == 10)
 8001a50:	f1b9 0f0a 	cmp.w	r9, #10
 8001a54:	d0e7      	beq.n	8001a26 <print_number+0x8e>
        res = (int)(((unsigned long)*n) % 16U);
 8001a56:	f002 080f 	and.w	r8, r2, #15
        *n = (long)(((unsigned long)*n) / 16U);
 8001a5a:	0912      	lsrs	r2, r2, #4
 8001a5c:	e7ed      	b.n	8001a3a <print_number+0xa2>
    i = 0;
 8001a5e:	f04f 0c00 	mov.w	ip, #0
 8001a62:	e7f3      	b.n	8001a4c <print_number+0xb4>
        precision = i;
 8001a64:	4662      	mov	r2, ip
 8001a66:	e7cc      	b.n	8001a02 <print_number+0x6a>

        while (size-- > 0)
        {
            if (buf < end)
                *buf = ' ';
            ++ buf;
 8001a68:	3001      	adds	r0, #1
        while (size-- > 0)
 8001a6a:	4673      	mov	r3, lr
 8001a6c:	f103 3eff 	add.w	lr, r3, #4294967295	@ 0xffffffff
 8001a70:	2b00      	cmp	r3, #0
 8001a72:	dd04      	ble.n	8001a7e <print_number+0xe6>
            if (buf < end)
 8001a74:	4288      	cmp	r0, r1
 8001a76:	d2f7      	bcs.n	8001a68 <print_number+0xd0>
                *buf = ' ';
 8001a78:	2320      	movs	r3, #32
 8001a7a:	7003      	strb	r3, [r0, #0]
 8001a7c:	e7f4      	b.n	8001a68 <print_number+0xd0>
        }
    }

    if (sign)
 8001a7e:	b12f      	cbz	r7, 8001a8c <print_number+0xf4>
    {
        if (buf < end)
 8001a80:	4288      	cmp	r0, r1
 8001a82:	d200      	bcs.n	8001a86 <print_number+0xee>
        {
            *buf = sign;
 8001a84:	7007      	strb	r7, [r0, #0]
        }
        -- size;
 8001a86:	f10e 3eff 	add.w	lr, lr, #4294967295	@ 0xffffffff
        ++ buf;
 8001a8a:	3001      	adds	r0, #1
        }
    }
#endif /* RT_PRINTF_SPECIAL */

    /* no align to the left */
    if (!(type & LEFT))
 8001a8c:	f015 0f10 	tst.w	r5, #16
 8001a90:	d003      	beq.n	8001a9a <print_number+0x102>
 8001a92:	4673      	mov	r3, lr
 8001a94:	e00c      	b.n	8001ab0 <print_number+0x118>
    {
        while (size-- > 0)
        {
            if (buf < end)
                *buf = c;
            ++ buf;
 8001a96:	3001      	adds	r0, #1
        while (size-- > 0)
 8001a98:	469e      	mov	lr, r3
 8001a9a:	f10e 33ff 	add.w	r3, lr, #4294967295	@ 0xffffffff
 8001a9e:	f1be 0f00 	cmp.w	lr, #0
 8001aa2:	dd05      	ble.n	8001ab0 <print_number+0x118>
            if (buf < end)
 8001aa4:	4288      	cmp	r0, r1
 8001aa6:	d2f6      	bcs.n	8001a96 <print_number+0xfe>
                *buf = c;
 8001aa8:	7006      	strb	r6, [r0, #0]
 8001aaa:	e7f4      	b.n	8001a96 <print_number+0xfe>
#ifdef RT_PRINTF_PRECISION
    while (i < precision--)
    {
        if (buf < end)
            *buf = '0';
        ++ buf;
 8001aac:	3001      	adds	r0, #1
    while (i < precision--)
 8001aae:	4672      	mov	r2, lr
 8001ab0:	f102 3eff 	add.w	lr, r2, #4294967295	@ 0xffffffff
 8001ab4:	4562      	cmp	r2, ip
 8001ab6:	dd06      	ble.n	8001ac6 <print_number+0x12e>
        if (buf < end)
 8001ab8:	4288      	cmp	r0, r1
 8001aba:	d2f7      	bcs.n	8001aac <print_number+0x114>
            *buf = '0';
 8001abc:	2230      	movs	r2, #48	@ 0x30
 8001abe:	7002      	strb	r2, [r0, #0]
 8001ac0:	e7f4      	b.n	8001aac <print_number+0x114>
    /* put number in the temporary buffer */
    while (i-- > 0 && (precision_bak != 0))
    {
        if (buf < end)
            *buf = tmp[i];
        ++ buf;
 8001ac2:	3001      	adds	r0, #1
    while (i-- > 0 && (precision_bak != 0))
 8001ac4:	4694      	mov	ip, r2
 8001ac6:	f10c 32ff 	add.w	r2, ip, #4294967295	@ 0xffffffff
 8001aca:	f1bc 0f00 	cmp.w	ip, #0
 8001ace:	dd0b      	ble.n	8001ae8 <print_number+0x150>
 8001ad0:	b154      	cbz	r4, 8001ae8 <print_number+0x150>
        if (buf < end)
 8001ad2:	4288      	cmp	r0, r1
 8001ad4:	d2f5      	bcs.n	8001ac2 <print_number+0x12a>
            *buf = tmp[i];
 8001ad6:	f102 0510 	add.w	r5, r2, #16
 8001ada:	446d      	add	r5, sp
 8001adc:	f815 5c10 	ldrb.w	r5, [r5, #-16]
 8001ae0:	7005      	strb	r5, [r0, #0]
 8001ae2:	e7ee      	b.n	8001ac2 <print_number+0x12a>

    while (size-- > 0)
    {
        if (buf < end)
            *buf = ' ';
        ++ buf;
 8001ae4:	3001      	adds	r0, #1
    while (size-- > 0)
 8001ae6:	4613      	mov	r3, r2
 8001ae8:	1e5a      	subs	r2, r3, #1
 8001aea:	2b00      	cmp	r3, #0
 8001aec:	dd04      	ble.n	8001af8 <print_number+0x160>
        if (buf < end)
 8001aee:	4288      	cmp	r0, r1
 8001af0:	d2f8      	bcs.n	8001ae4 <print_number+0x14c>
            *buf = ' ';
 8001af2:	2320      	movs	r3, #32
 8001af4:	7003      	strb	r3, [r0, #0]
 8001af6:	e7f5      	b.n	8001ae4 <print_number+0x14c>
    }

    return buf;
}
 8001af8:	b004      	add	sp, #16
 8001afa:	e8bd 87f0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, pc}
 8001afe:	bf00      	nop
 8001b00:	cccccccd 	.word	0xcccccccd
 8001b04:	080090fc 	.word	0x080090fc
 8001b08:	080090e8 	.word	0x080090e8

08001b0c <_heap_lock>:
    rt_mutex_init(&_lock, "heap", RT_IPC_FLAG_PRIO);
#endif
}

rt_inline rt_base_t _heap_lock(void)
{
 8001b0c:	b508      	push	{r3, lr}
#if defined(RT_USING_HEAP_ISR)
    return rt_hw_interrupt_disable();
#elif defined(RT_USING_MUTEX)
    if (rt_thread_self())
 8001b0e:	f7ff f97f 	bl	8000e10 <rt_thread_self>
 8001b12:	b128      	cbz	r0, 8001b20 <_heap_lock+0x14>
        return rt_mutex_take(&_lock, RT_WAITING_FOREVER);
 8001b14:	f04f 31ff 	mov.w	r1, #4294967295	@ 0xffffffff
 8001b18:	4802      	ldr	r0, [pc, #8]	@ (8001b24 <_heap_lock+0x18>)
 8001b1a:	f000 fd17 	bl	800254c <rt_mutex_take>
        return RT_EOK;
#else
    rt_enter_critical();
    return RT_EOK;
#endif
}
 8001b1e:	bd08      	pop	{r3, pc}
        return RT_EOK;
 8001b20:	2000      	movs	r0, #0
 8001b22:	e7fc      	b.n	8001b1e <_heap_lock+0x12>
 8001b24:	200001e0 	.word	0x200001e0

08001b28 <rt_memset>:
    if (!TOO_SMALL(count) && !UNALIGNED(s))
 8001b28:	2a03      	cmp	r2, #3
 8001b2a:	d923      	bls.n	8001b74 <rt_memset+0x4c>
{
 8001b2c:	b410      	push	{r4}
 8001b2e:	b2cc      	uxtb	r4, r1
    if (!TOO_SMALL(count) && !UNALIGNED(s))
 8001b30:	f010 0f03 	tst.w	r0, #3
 8001b34:	d120      	bne.n	8001b78 <rt_memset+0x50>
            buffer = (d << 8) | d;
 8001b36:	ea44 2404 	orr.w	r4, r4, r4, lsl #8
            buffer |= (buffer << 16);
 8001b3a:	ea44 4404 	orr.w	r4, r4, r4, lsl #16
        aligned_addr = (unsigned long *)s;
 8001b3e:	4603      	mov	r3, r0
 8001b40:	e005      	b.n	8001b4e <rt_memset+0x26>
            *aligned_addr++ = buffer;
 8001b42:	601c      	str	r4, [r3, #0]
            *aligned_addr++ = buffer;
 8001b44:	605c      	str	r4, [r3, #4]
            *aligned_addr++ = buffer;
 8001b46:	609c      	str	r4, [r3, #8]
            *aligned_addr++ = buffer;
 8001b48:	60dc      	str	r4, [r3, #12]
            count -= 4 * LBLOCKSIZE;
 8001b4a:	3a10      	subs	r2, #16
            *aligned_addr++ = buffer;
 8001b4c:	3310      	adds	r3, #16
        while (count >= LBLOCKSIZE * 4)
 8001b4e:	2a0f      	cmp	r2, #15
 8001b50:	d8f7      	bhi.n	8001b42 <rt_memset+0x1a>
 8001b52:	e002      	b.n	8001b5a <rt_memset+0x32>
            *aligned_addr++ = buffer;
 8001b54:	f843 4b04 	str.w	r4, [r3], #4
            count -= LBLOCKSIZE;
 8001b58:	3a04      	subs	r2, #4
        while (count >= LBLOCKSIZE)
 8001b5a:	2a03      	cmp	r2, #3
 8001b5c:	d8fa      	bhi.n	8001b54 <rt_memset+0x2c>
 8001b5e:	e002      	b.n	8001b66 <rt_memset+0x3e>
        *m++ = (char)d;
 8001b60:	f803 1b01 	strb.w	r1, [r3], #1
    while (count--)
 8001b64:	4662      	mov	r2, ip
 8001b66:	f102 3cff 	add.w	ip, r2, #4294967295	@ 0xffffffff
 8001b6a:	2a00      	cmp	r2, #0
 8001b6c:	d1f8      	bne.n	8001b60 <rt_memset+0x38>
}
 8001b6e:	f85d 4b04 	ldr.w	r4, [sp], #4
 8001b72:	4770      	bx	lr
    char *m = (char *)s;
 8001b74:	4603      	mov	r3, r0
 8001b76:	e004      	b.n	8001b82 <rt_memset+0x5a>
 8001b78:	4603      	mov	r3, r0
 8001b7a:	e7f4      	b.n	8001b66 <rt_memset+0x3e>
        *m++ = (char)d;
 8001b7c:	f803 1b01 	strb.w	r1, [r3], #1
    while (count--)
 8001b80:	4662      	mov	r2, ip
 8001b82:	f102 3cff 	add.w	ip, r2, #4294967295	@ 0xffffffff
 8001b86:	2a00      	cmp	r2, #0
 8001b88:	d1f8      	bne.n	8001b7c <rt_memset+0x54>
 8001b8a:	4770      	bx	lr

08001b8c <rt_strncpy>:
    if (n != 0)
 8001b8c:	b19a      	cbz	r2, 8001bb6 <rt_strncpy+0x2a>
{
 8001b8e:	b510      	push	{r4, lr}
 8001b90:	4694      	mov	ip, r2
        char *d = dst;
 8001b92:	4603      	mov	r3, r0
            if ((*d++ = *s++) == 0)
 8001b94:	468e      	mov	lr, r1
 8001b96:	780c      	ldrb	r4, [r1, #0]
 8001b98:	3101      	adds	r1, #1
 8001b9a:	701c      	strb	r4, [r3, #0]
 8001b9c:	3301      	adds	r3, #1
 8001b9e:	b134      	cbz	r4, 8001bae <rt_strncpy+0x22>
        } while (--n != 0);
 8001ba0:	f1bc 0c01 	subs.w	ip, ip, #1
 8001ba4:	d1f6      	bne.n	8001b94 <rt_strncpy+0x8>
 8001ba6:	e005      	b.n	8001bb4 <rt_strncpy+0x28>
                    *d++ = 0;
 8001ba8:	2200      	movs	r2, #0
 8001baa:	f803 2b01 	strb.w	r2, [r3], #1
                while (--n != 0)
 8001bae:	f1bc 0c01 	subs.w	ip, ip, #1
 8001bb2:	d1f9      	bne.n	8001ba8 <rt_strncpy+0x1c>
}
 8001bb4:	bd10      	pop	{r4, pc}
 8001bb6:	4770      	bx	lr

08001bb8 <rt_strlen>:
    for (sc = s; *sc != '\0'; ++sc) /* nothing */
 8001bb8:	4603      	mov	r3, r0
 8001bba:	e000      	b.n	8001bbe <rt_strlen+0x6>
 8001bbc:	3301      	adds	r3, #1
 8001bbe:	781a      	ldrb	r2, [r3, #0]
 8001bc0:	2a00      	cmp	r2, #0
 8001bc2:	d1fb      	bne.n	8001bbc <rt_strlen+0x4>
}
 8001bc4:	1a18      	subs	r0, r3, r0
 8001bc6:	4770      	bx	lr

08001bc8 <rt_vsnprintf>:
{
 8001bc8:	e92d 43f0 	stmdb	sp!, {r4, r5, r6, r7, r8, r9, lr}
 8001bcc:	b087      	sub	sp, #28
 8001bce:	4607      	mov	r7, r0
 8001bd0:	4688      	mov	r8, r1
 8001bd2:	9205      	str	r2, [sp, #20]
 8001bd4:	9304      	str	r3, [sp, #16]
    if (end < buf)
 8001bd6:	1846      	adds	r6, r0, r1
 8001bd8:	d303      	bcc.n	8001be2 <rt_vsnprintf+0x1a>
        size = end - buf;
 8001bda:	ea6f 0800 	mvn.w	r8, r0
        end  = ((char *) - 1);
 8001bde:	f04f 36ff 	mov.w	r6, #4294967295	@ 0xffffffff
 8001be2:	463d      	mov	r5, r7
 8001be4:	e003      	b.n	8001bee <rt_vsnprintf+0x26>
            ++ str;
 8001be6:	3501      	adds	r5, #1
    for (; *fmt ; ++fmt)
 8001be8:	9b05      	ldr	r3, [sp, #20]
 8001bea:	3301      	adds	r3, #1
 8001bec:	9305      	str	r3, [sp, #20]
 8001bee:	9b05      	ldr	r3, [sp, #20]
 8001bf0:	781b      	ldrb	r3, [r3, #0]
 8001bf2:	2b00      	cmp	r3, #0
 8001bf4:	f000 8148 	beq.w	8001e88 <rt_vsnprintf+0x2c0>
        if (*fmt != '%')
 8001bf8:	2b25      	cmp	r3, #37	@ 0x25
 8001bfa:	d003      	beq.n	8001c04 <rt_vsnprintf+0x3c>
            if (str < end)
 8001bfc:	42b5      	cmp	r5, r6
 8001bfe:	d2f2      	bcs.n	8001be6 <rt_vsnprintf+0x1e>
                *str = *fmt;
 8001c00:	702b      	strb	r3, [r5, #0]
 8001c02:	e7f0      	b.n	8001be6 <rt_vsnprintf+0x1e>
        flags = 0;
 8001c04:	2400      	movs	r4, #0
 8001c06:	e001      	b.n	8001c0c <rt_vsnprintf+0x44>
            if (*fmt == '-') flags |= LEFT;
 8001c08:	f044 0410 	orr.w	r4, r4, #16
            ++ fmt;
 8001c0c:	9a05      	ldr	r2, [sp, #20]
 8001c0e:	1c53      	adds	r3, r2, #1
 8001c10:	9305      	str	r3, [sp, #20]
            if (*fmt == '-') flags |= LEFT;
 8001c12:	7853      	ldrb	r3, [r2, #1]
 8001c14:	2b2d      	cmp	r3, #45	@ 0x2d
 8001c16:	d0f7      	beq.n	8001c08 <rt_vsnprintf+0x40>
            else if (*fmt == '+') flags |= PLUS;
 8001c18:	2b2b      	cmp	r3, #43	@ 0x2b
 8001c1a:	d008      	beq.n	8001c2e <rt_vsnprintf+0x66>
            else if (*fmt == ' ') flags |= SPACE;
 8001c1c:	2b20      	cmp	r3, #32
 8001c1e:	d009      	beq.n	8001c34 <rt_vsnprintf+0x6c>
            else if (*fmt == '#') flags |= SPECIAL;
 8001c20:	2b23      	cmp	r3, #35	@ 0x23
 8001c22:	d00a      	beq.n	8001c3a <rt_vsnprintf+0x72>
            else if (*fmt == '0') flags |= ZEROPAD;
 8001c24:	2b30      	cmp	r3, #48	@ 0x30
 8001c26:	d10b      	bne.n	8001c40 <rt_vsnprintf+0x78>
 8001c28:	f044 0401 	orr.w	r4, r4, #1
 8001c2c:	e7ee      	b.n	8001c0c <rt_vsnprintf+0x44>
            else if (*fmt == '+') flags |= PLUS;
 8001c2e:	f044 0404 	orr.w	r4, r4, #4
 8001c32:	e7eb      	b.n	8001c0c <rt_vsnprintf+0x44>
            else if (*fmt == ' ') flags |= SPACE;
 8001c34:	f044 0408 	orr.w	r4, r4, #8
 8001c38:	e7e8      	b.n	8001c0c <rt_vsnprintf+0x44>
            else if (*fmt == '#') flags |= SPECIAL;
 8001c3a:	f044 0420 	orr.w	r4, r4, #32
 8001c3e:	e7e5      	b.n	8001c0c <rt_vsnprintf+0x44>
        if (_ISDIGIT(*fmt)) field_width = skip_atoi(&fmt);
 8001c40:	f1a3 0130 	sub.w	r1, r3, #48	@ 0x30
 8001c44:	2909      	cmp	r1, #9
 8001c46:	d911      	bls.n	8001c6c <rt_vsnprintf+0xa4>
        else if (*fmt == '*')
 8001c48:	2b2a      	cmp	r3, #42	@ 0x2a
 8001c4a:	d014      	beq.n	8001c76 <rt_vsnprintf+0xae>
        field_width = -1;
 8001c4c:	f04f 39ff 	mov.w	r9, #4294967295	@ 0xffffffff
        if (*fmt == '.')
 8001c50:	9b05      	ldr	r3, [sp, #20]
 8001c52:	781a      	ldrb	r2, [r3, #0]
 8001c54:	2a2e      	cmp	r2, #46	@ 0x2e
 8001c56:	d01d      	beq.n	8001c94 <rt_vsnprintf+0xcc>
        precision = -1;
 8001c58:	f04f 30ff 	mov.w	r0, #4294967295	@ 0xffffffff
        if (*fmt == 'h' || *fmt == 'l')
 8001c5c:	9b05      	ldr	r3, [sp, #20]
 8001c5e:	781a      	ldrb	r2, [r3, #0]
 8001c60:	2a68      	cmp	r2, #104	@ 0x68
 8001c62:	d030      	beq.n	8001cc6 <rt_vsnprintf+0xfe>
 8001c64:	2a6c      	cmp	r2, #108	@ 0x6c
 8001c66:	d02e      	beq.n	8001cc6 <rt_vsnprintf+0xfe>
        qualifier = 0;
 8001c68:	2200      	movs	r2, #0
 8001c6a:	e02e      	b.n	8001cca <rt_vsnprintf+0x102>
        if (_ISDIGIT(*fmt)) field_width = skip_atoi(&fmt);
 8001c6c:	a805      	add	r0, sp, #20
 8001c6e:	f7ff fe81 	bl	8001974 <skip_atoi>
 8001c72:	4681      	mov	r9, r0
 8001c74:	e7ec      	b.n	8001c50 <rt_vsnprintf+0x88>
            ++ fmt;
 8001c76:	3202      	adds	r2, #2
 8001c78:	9205      	str	r2, [sp, #20]
            field_width = va_arg(args, int);
 8001c7a:	9b04      	ldr	r3, [sp, #16]
 8001c7c:	1d1a      	adds	r2, r3, #4
 8001c7e:	9204      	str	r2, [sp, #16]
 8001c80:	f8d3 9000 	ldr.w	r9, [r3]
            if (field_width < 0)
 8001c84:	f1b9 0f00 	cmp.w	r9, #0
 8001c88:	dae2      	bge.n	8001c50 <rt_vsnprintf+0x88>
                field_width = -field_width;
 8001c8a:	f1c9 0900 	rsb	r9, r9, #0
                flags |= LEFT;
 8001c8e:	f044 0410 	orr.w	r4, r4, #16
 8001c92:	e7dd      	b.n	8001c50 <rt_vsnprintf+0x88>
            ++ fmt;
 8001c94:	1c5a      	adds	r2, r3, #1
 8001c96:	9205      	str	r2, [sp, #20]
            if (_ISDIGIT(*fmt)) precision = skip_atoi(&fmt);
 8001c98:	785a      	ldrb	r2, [r3, #1]
 8001c9a:	f1a2 0130 	sub.w	r1, r2, #48	@ 0x30
 8001c9e:	2909      	cmp	r1, #9
 8001ca0:	d903      	bls.n	8001caa <rt_vsnprintf+0xe2>
            else if (*fmt == '*')
 8001ca2:	2a2a      	cmp	r2, #42	@ 0x2a
 8001ca4:	d008      	beq.n	8001cb8 <rt_vsnprintf+0xf0>
            if (precision < 0) precision = 0;
 8001ca6:	2000      	movs	r0, #0
 8001ca8:	e7d8      	b.n	8001c5c <rt_vsnprintf+0x94>
            if (_ISDIGIT(*fmt)) precision = skip_atoi(&fmt);
 8001caa:	a805      	add	r0, sp, #20
 8001cac:	f7ff fe62 	bl	8001974 <skip_atoi>
            if (precision < 0) precision = 0;
 8001cb0:	2800      	cmp	r0, #0
 8001cb2:	dad3      	bge.n	8001c5c <rt_vsnprintf+0x94>
 8001cb4:	2000      	movs	r0, #0
 8001cb6:	e7d1      	b.n	8001c5c <rt_vsnprintf+0x94>
                ++ fmt;
 8001cb8:	3302      	adds	r3, #2
 8001cba:	9305      	str	r3, [sp, #20]
                precision = va_arg(args, int);
 8001cbc:	9b04      	ldr	r3, [sp, #16]
 8001cbe:	1d1a      	adds	r2, r3, #4
 8001cc0:	9204      	str	r2, [sp, #16]
 8001cc2:	6818      	ldr	r0, [r3, #0]
 8001cc4:	e7f4      	b.n	8001cb0 <rt_vsnprintf+0xe8>
            ++ fmt;
 8001cc6:	3301      	adds	r3, #1
 8001cc8:	9305      	str	r3, [sp, #20]
        switch (*fmt)
 8001cca:	9b05      	ldr	r3, [sp, #20]
 8001ccc:	781b      	ldrb	r3, [r3, #0]
 8001cce:	2b25      	cmp	r3, #37	@ 0x25
 8001cd0:	f000 8095 	beq.w	8001dfe <rt_vsnprintf+0x236>
 8001cd4:	f0c0 80b4 	bcc.w	8001e40 <rt_vsnprintf+0x278>
 8001cd8:	2b78      	cmp	r3, #120	@ 0x78
 8001cda:	f200 80b1 	bhi.w	8001e40 <rt_vsnprintf+0x278>
 8001cde:	2b58      	cmp	r3, #88	@ 0x58
 8001ce0:	f0c0 80ae 	bcc.w	8001e40 <rt_vsnprintf+0x278>
 8001ce4:	3b58      	subs	r3, #88	@ 0x58
 8001ce6:	2b20      	cmp	r3, #32
 8001ce8:	f200 80aa 	bhi.w	8001e40 <rt_vsnprintf+0x278>
 8001cec:	e8df f003 	tbb	[pc, r3]
 8001cf0:	a8a8a88f 	.word	0xa8a8a88f
 8001cf4:	a8a8a8a8 	.word	0xa8a8a8a8
 8001cf8:	11a8a8a8 	.word	0x11a8a8a8
 8001cfc:	a8a8a893 	.word	0xa8a8a893
 8001d00:	a8a893a8 	.word	0xa8a893a8
 8001d04:	8da8a8a8 	.word	0x8da8a8a8
 8001d08:	34a8a870 	.word	0x34a8a870
 8001d0c:	a8a8b9a8 	.word	0xa8a8b9a8
 8001d10:	bb          	.byte	0xbb
 8001d11:	00          	.byte	0x00
            if (!(flags & LEFT))
 8001d12:	f014 0f10 	tst.w	r4, #16
 8001d16:	d009      	beq.n	8001d2c <rt_vsnprintf+0x164>
            c = (rt_uint8_t)va_arg(args, int);
 8001d18:	9b04      	ldr	r3, [sp, #16]
 8001d1a:	1d1a      	adds	r2, r3, #4
 8001d1c:	9204      	str	r2, [sp, #16]
 8001d1e:	781b      	ldrb	r3, [r3, #0]
            if (str < end) *str = c;
 8001d20:	42b5      	cmp	r5, r6
 8001d22:	d200      	bcs.n	8001d26 <rt_vsnprintf+0x15e>
 8001d24:	702b      	strb	r3, [r5, #0]
            ++ str;
 8001d26:	3501      	adds	r5, #1
            while (--field_width > 0)
 8001d28:	e00b      	b.n	8001d42 <rt_vsnprintf+0x17a>
                    ++ str;
 8001d2a:	3501      	adds	r5, #1
                while (--field_width > 0)
 8001d2c:	f109 39ff 	add.w	r9, r9, #4294967295	@ 0xffffffff
 8001d30:	f1b9 0f00 	cmp.w	r9, #0
 8001d34:	ddf0      	ble.n	8001d18 <rt_vsnprintf+0x150>
                    if (str < end) *str = ' ';
 8001d36:	42b5      	cmp	r5, r6
 8001d38:	d2f7      	bcs.n	8001d2a <rt_vsnprintf+0x162>
 8001d3a:	2320      	movs	r3, #32
 8001d3c:	702b      	strb	r3, [r5, #0]
 8001d3e:	e7f4      	b.n	8001d2a <rt_vsnprintf+0x162>
                ++ str;
 8001d40:	3501      	adds	r5, #1
            while (--field_width > 0)
 8001d42:	f109 39ff 	add.w	r9, r9, #4294967295	@ 0xffffffff
 8001d46:	f1b9 0f00 	cmp.w	r9, #0
 8001d4a:	f77f af4d 	ble.w	8001be8 <rt_vsnprintf+0x20>
                if (str < end) *str = ' ';
 8001d4e:	42b5      	cmp	r5, r6
 8001d50:	d2f6      	bcs.n	8001d40 <rt_vsnprintf+0x178>
 8001d52:	2320      	movs	r3, #32
 8001d54:	702b      	strb	r3, [r5, #0]
 8001d56:	e7f3      	b.n	8001d40 <rt_vsnprintf+0x178>
            s = va_arg(args, char *);
 8001d58:	9b04      	ldr	r3, [sp, #16]
 8001d5a:	1d1a      	adds	r2, r3, #4
 8001d5c:	9204      	str	r2, [sp, #16]
 8001d5e:	681a      	ldr	r2, [r3, #0]
            if (!s) s = "(NULL)";
 8001d60:	b10a      	cbz	r2, 8001d66 <rt_vsnprintf+0x19e>
            for (len = 0; (len != field_width) && (s[len] != '\0'); len++);
 8001d62:	2300      	movs	r3, #0
 8001d64:	e002      	b.n	8001d6c <rt_vsnprintf+0x1a4>
            if (!s) s = "(NULL)";
 8001d66:	4a4f      	ldr	r2, [pc, #316]	@ (8001ea4 <rt_vsnprintf+0x2dc>)
 8001d68:	e7fb      	b.n	8001d62 <rt_vsnprintf+0x19a>
            for (len = 0; (len != field_width) && (s[len] != '\0'); len++);
 8001d6a:	3301      	adds	r3, #1
 8001d6c:	454b      	cmp	r3, r9
 8001d6e:	d002      	beq.n	8001d76 <rt_vsnprintf+0x1ae>
 8001d70:	5cd1      	ldrb	r1, [r2, r3]
 8001d72:	2900      	cmp	r1, #0
 8001d74:	d1f9      	bne.n	8001d6a <rt_vsnprintf+0x1a2>
            if (precision > 0 && len > precision) len = precision;
 8001d76:	2800      	cmp	r0, #0
 8001d78:	dd02      	ble.n	8001d80 <rt_vsnprintf+0x1b8>
 8001d7a:	4283      	cmp	r3, r0
 8001d7c:	dd00      	ble.n	8001d80 <rt_vsnprintf+0x1b8>
 8001d7e:	4603      	mov	r3, r0
            if (!(flags & LEFT))
 8001d80:	f014 0f10 	tst.w	r4, #16
 8001d84:	d003      	beq.n	8001d8e <rt_vsnprintf+0x1c6>
            for (i = 0; i < len; ++i)
 8001d86:	2100      	movs	r1, #0
 8001d88:	e00f      	b.n	8001daa <rt_vsnprintf+0x1e2>
                    ++ str;
 8001d8a:	3501      	adds	r5, #1
                while (len < field_width--)
 8001d8c:	4689      	mov	r9, r1
 8001d8e:	f109 31ff 	add.w	r1, r9, #4294967295	@ 0xffffffff
 8001d92:	454b      	cmp	r3, r9
 8001d94:	da04      	bge.n	8001da0 <rt_vsnprintf+0x1d8>
                    if (str < end) *str = ' ';
 8001d96:	42b5      	cmp	r5, r6
 8001d98:	d2f7      	bcs.n	8001d8a <rt_vsnprintf+0x1c2>
 8001d9a:	2020      	movs	r0, #32
 8001d9c:	7028      	strb	r0, [r5, #0]
 8001d9e:	e7f4      	b.n	8001d8a <rt_vsnprintf+0x1c2>
                while (len < field_width--)
 8001da0:	4689      	mov	r9, r1
 8001da2:	e7f0      	b.n	8001d86 <rt_vsnprintf+0x1be>
                ++ str;
 8001da4:	3501      	adds	r5, #1
                ++ s;
 8001da6:	3201      	adds	r2, #1
            for (i = 0; i < len; ++i)
 8001da8:	3101      	adds	r1, #1
 8001daa:	4299      	cmp	r1, r3
 8001dac:	da06      	bge.n	8001dbc <rt_vsnprintf+0x1f4>
                if (str < end) *str = *s;
 8001dae:	42b5      	cmp	r5, r6
 8001db0:	d2f8      	bcs.n	8001da4 <rt_vsnprintf+0x1dc>
 8001db2:	7810      	ldrb	r0, [r2, #0]
 8001db4:	7028      	strb	r0, [r5, #0]
 8001db6:	e7f5      	b.n	8001da4 <rt_vsnprintf+0x1dc>
                ++ str;
 8001db8:	3501      	adds	r5, #1
            while (len < field_width--)
 8001dba:	4691      	mov	r9, r2
 8001dbc:	f109 32ff 	add.w	r2, r9, #4294967295	@ 0xffffffff
 8001dc0:	454b      	cmp	r3, r9
 8001dc2:	f6bf af11 	bge.w	8001be8 <rt_vsnprintf+0x20>
                if (str < end) *str = ' ';
 8001dc6:	42b5      	cmp	r5, r6
 8001dc8:	d2f6      	bcs.n	8001db8 <rt_vsnprintf+0x1f0>
 8001dca:	2120      	movs	r1, #32
 8001dcc:	7029      	strb	r1, [r5, #0]
 8001dce:	e7f3      	b.n	8001db8 <rt_vsnprintf+0x1f0>
            if (field_width == -1)
 8001dd0:	f1b9 3fff 	cmp.w	r9, #4294967295	@ 0xffffffff
 8001dd4:	d00e      	beq.n	8001df4 <rt_vsnprintf+0x22c>
                               (long)va_arg(args, void *),
 8001dd6:	9b04      	ldr	r3, [sp, #16]
 8001dd8:	1d1a      	adds	r2, r3, #4
 8001dda:	9204      	str	r2, [sp, #16]
 8001ddc:	681a      	ldr	r2, [r3, #0]
            str = print_number(str, end,
 8001dde:	9402      	str	r4, [sp, #8]
 8001de0:	9001      	str	r0, [sp, #4]
 8001de2:	f8cd 9000 	str.w	r9, [sp]
 8001de6:	2310      	movs	r3, #16
 8001de8:	4631      	mov	r1, r6
 8001dea:	4628      	mov	r0, r5
 8001dec:	f7ff fdd4 	bl	8001998 <print_number>
 8001df0:	4605      	mov	r5, r0
            continue;
 8001df2:	e6f9      	b.n	8001be8 <rt_vsnprintf+0x20>
                flags |= ZEROPAD;
 8001df4:	f044 0401 	orr.w	r4, r4, #1
                field_width = sizeof(void *) << 1;
 8001df8:	f04f 0908 	mov.w	r9, #8
 8001dfc:	e7eb      	b.n	8001dd6 <rt_vsnprintf+0x20e>
            if (str < end) *str = '%';
 8001dfe:	42b5      	cmp	r5, r6
 8001e00:	d201      	bcs.n	8001e06 <rt_vsnprintf+0x23e>
 8001e02:	2325      	movs	r3, #37	@ 0x25
 8001e04:	702b      	strb	r3, [r5, #0]
            ++ str;
 8001e06:	3501      	adds	r5, #1
            continue;
 8001e08:	e6ee      	b.n	8001be8 <rt_vsnprintf+0x20>
            base = 8;
 8001e0a:	2308      	movs	r3, #8
            break;
 8001e0c:	e006      	b.n	8001e1c <rt_vsnprintf+0x254>
            flags |= LARGE;
 8001e0e:	f044 0440 	orr.w	r4, r4, #64	@ 0x40
            base = 16;
 8001e12:	2310      	movs	r3, #16
 8001e14:	e002      	b.n	8001e1c <rt_vsnprintf+0x254>
            flags |= SIGN;
 8001e16:	f044 0402 	orr.w	r4, r4, #2
        base = 10;
 8001e1a:	230a      	movs	r3, #10
        if (qualifier == 'l')
 8001e1c:	2a6c      	cmp	r2, #108	@ 0x6c
 8001e1e:	d024      	beq.n	8001e6a <rt_vsnprintf+0x2a2>
        else if (qualifier == 'h')
 8001e20:	2a68      	cmp	r2, #104	@ 0x68
 8001e22:	d027      	beq.n	8001e74 <rt_vsnprintf+0x2ac>
            num = va_arg(args, rt_uint32_t);
 8001e24:	9a04      	ldr	r2, [sp, #16]
 8001e26:	1d11      	adds	r1, r2, #4
 8001e28:	9104      	str	r1, [sp, #16]
 8001e2a:	6812      	ldr	r2, [r2, #0]
        str = print_number(str, end, num, base, field_width, precision, flags);
 8001e2c:	9402      	str	r4, [sp, #8]
 8001e2e:	9001      	str	r0, [sp, #4]
 8001e30:	f8cd 9000 	str.w	r9, [sp]
 8001e34:	4631      	mov	r1, r6
 8001e36:	4628      	mov	r0, r5
 8001e38:	f7ff fdae 	bl	8001998 <print_number>
 8001e3c:	4605      	mov	r5, r0
 8001e3e:	e6d3      	b.n	8001be8 <rt_vsnprintf+0x20>
            if (str < end) *str = '%';
 8001e40:	42b5      	cmp	r5, r6
 8001e42:	d201      	bcs.n	8001e48 <rt_vsnprintf+0x280>
 8001e44:	2325      	movs	r3, #37	@ 0x25
 8001e46:	702b      	strb	r3, [r5, #0]
            ++ str;
 8001e48:	1c69      	adds	r1, r5, #1
            if (*fmt)
 8001e4a:	9b05      	ldr	r3, [sp, #20]
 8001e4c:	781a      	ldrb	r2, [r3, #0]
 8001e4e:	b122      	cbz	r2, 8001e5a <rt_vsnprintf+0x292>
                if (str < end) *str = *fmt;
 8001e50:	42b1      	cmp	r1, r6
 8001e52:	d200      	bcs.n	8001e56 <rt_vsnprintf+0x28e>
 8001e54:	706a      	strb	r2, [r5, #1]
                ++ str;
 8001e56:	3502      	adds	r5, #2
 8001e58:	e6c6      	b.n	8001be8 <rt_vsnprintf+0x20>
                -- fmt;
 8001e5a:	3b01      	subs	r3, #1
 8001e5c:	9305      	str	r3, [sp, #20]
            ++ str;
 8001e5e:	460d      	mov	r5, r1
            continue;
 8001e60:	e6c2      	b.n	8001be8 <rt_vsnprintf+0x20>
        switch (*fmt)
 8001e62:	230a      	movs	r3, #10
 8001e64:	e7da      	b.n	8001e1c <rt_vsnprintf+0x254>
            base = 16;
 8001e66:	2310      	movs	r3, #16
 8001e68:	e7d8      	b.n	8001e1c <rt_vsnprintf+0x254>
            num = va_arg(args, rt_uint32_t);
 8001e6a:	9a04      	ldr	r2, [sp, #16]
 8001e6c:	1d11      	adds	r1, r2, #4
 8001e6e:	9104      	str	r1, [sp, #16]
 8001e70:	6812      	ldr	r2, [r2, #0]
            if (flags & SIGN) num = (rt_int32_t)num;
 8001e72:	e7db      	b.n	8001e2c <rt_vsnprintf+0x264>
            num = (rt_uint16_t)va_arg(args, rt_int32_t);
 8001e74:	9a04      	ldr	r2, [sp, #16]
 8001e76:	1d11      	adds	r1, r2, #4
 8001e78:	9104      	str	r1, [sp, #16]
 8001e7a:	6811      	ldr	r1, [r2, #0]
 8001e7c:	b28a      	uxth	r2, r1
            if (flags & SIGN) num = (rt_int16_t)num;
 8001e7e:	f014 0f02 	tst.w	r4, #2
 8001e82:	d0d3      	beq.n	8001e2c <rt_vsnprintf+0x264>
 8001e84:	b20a      	sxth	r2, r1
 8001e86:	e7d1      	b.n	8001e2c <rt_vsnprintf+0x264>
    if (size > 0)
 8001e88:	f1b8 0f00 	cmp.w	r8, #0
 8001e8c:	d002      	beq.n	8001e94 <rt_vsnprintf+0x2cc>
        if (str < end) *str = '\0';
 8001e8e:	42b5      	cmp	r5, r6
 8001e90:	d204      	bcs.n	8001e9c <rt_vsnprintf+0x2d4>
 8001e92:	702b      	strb	r3, [r5, #0]
}
 8001e94:	1be8      	subs	r0, r5, r7
 8001e96:	b007      	add	sp, #28
 8001e98:	e8bd 83f0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, pc}
            end[-1] = '\0';
 8001e9c:	2300      	movs	r3, #0
 8001e9e:	f806 3c01 	strb.w	r3, [r6, #-1]
 8001ea2:	e7f7      	b.n	8001e94 <rt_vsnprintf+0x2cc>
 8001ea4:	080087d4 	.word	0x080087d4

08001ea8 <rt_vsprintf>:
{
 8001ea8:	b508      	push	{r3, lr}
 8001eaa:	4613      	mov	r3, r2
    return rt_vsnprintf(buf, (rt_size_t) - 1, format, arg_ptr);
 8001eac:	460a      	mov	r2, r1
 8001eae:	f04f 31ff 	mov.w	r1, #4294967295	@ 0xffffffff
 8001eb2:	f7ff fe89 	bl	8001bc8 <rt_vsnprintf>
}
 8001eb6:	bd08      	pop	{r3, pc}

08001eb8 <rt_sprintf>:
{
 8001eb8:	b40e      	push	{r1, r2, r3}
 8001eba:	b500      	push	{lr}
 8001ebc:	b082      	sub	sp, #8
 8001ebe:	aa03      	add	r2, sp, #12
 8001ec0:	f852 1b04 	ldr.w	r1, [r2], #4
    va_start(arg_ptr, format);
 8001ec4:	9201      	str	r2, [sp, #4]
    n = rt_vsprintf(buf, format, arg_ptr);
 8001ec6:	f7ff ffef 	bl	8001ea8 <rt_vsprintf>
}
 8001eca:	b002      	add	sp, #8
 8001ecc:	f85d eb04 	ldr.w	lr, [sp], #4
 8001ed0:	b003      	add	sp, #12
 8001ed2:	4770      	bx	lr
}
 8001ed4:	4770      	bx	lr

08001ed6 <rt_hw_console_output>:
    return 0;
}
INIT_BOARD_EXPORT(uart_init);

void rt_hw_console_output(const char *str)
{
 8001ed6:	b510      	push	{r4, lr}
 8001ed8:	4604      	mov	r4, r0
    int i = 0, size = 0;
    char a = '\r';

    size = rt_strlen(str);
 8001eda:	f7ff fe6d 	bl	8001bb8 <rt_strlen>
 8001ede:	4601      	mov	r1, r0
    extern void tt(char *str, int size);

    tt(str, size);
 8001ee0:	4620      	mov	r0, r4
 8001ee2:	f005 fdcf 	bl	8007a84 <tt>
    //     }
    //     LL_USART_TransmitData8(USART1, *(str + i));
    //     while (!LL_USART_IsActiveFlag_TXE(USART3))
    //         ;
    // }
}
 8001ee6:	bd10      	pop	{r4, pc}

08001ee8 <rt_kprintf>:
{
 8001ee8:	b40f      	push	{r0, r1, r2, r3}
 8001eea:	b510      	push	{r4, lr}
 8001eec:	b082      	sub	sp, #8
 8001eee:	ab04      	add	r3, sp, #16
 8001ef0:	f853 2b04 	ldr.w	r2, [r3], #4
    va_start(args, fmt);
 8001ef4:	9301      	str	r3, [sp, #4]
    length = rt_vsnprintf(rt_log_buf, sizeof(rt_log_buf) - 1, fmt, args);
 8001ef6:	21ff      	movs	r1, #255	@ 0xff
 8001ef8:	4807      	ldr	r0, [pc, #28]	@ (8001f18 <rt_kprintf+0x30>)
 8001efa:	f7ff fe65 	bl	8001bc8 <rt_vsnprintf>
 8001efe:	4604      	mov	r4, r0
    if (length > RT_CONSOLEBUF_SIZE - 1)
 8001f00:	28ff      	cmp	r0, #255	@ 0xff
 8001f02:	d900      	bls.n	8001f06 <rt_kprintf+0x1e>
        length = RT_CONSOLEBUF_SIZE - 1;
 8001f04:	24ff      	movs	r4, #255	@ 0xff
    rt_hw_console_output(rt_log_buf);
 8001f06:	4804      	ldr	r0, [pc, #16]	@ (8001f18 <rt_kprintf+0x30>)
 8001f08:	f7ff ffe5 	bl	8001ed6 <rt_hw_console_output>
}
 8001f0c:	4620      	mov	r0, r4
 8001f0e:	b002      	add	sp, #8
 8001f10:	e8bd 4010 	ldmia.w	sp!, {r4, lr}
 8001f14:	b004      	add	sp, #16
 8001f16:	4770      	bx	lr
 8001f18:	200000d8 	.word	0x200000d8

08001f1c <rt_show_version>:
{
 8001f1c:	b500      	push	{lr}
 8001f1e:	b083      	sub	sp, #12
    rt_kprintf("\n \\ | /\n");
 8001f20:	480a      	ldr	r0, [pc, #40]	@ (8001f4c <rt_show_version+0x30>)
 8001f22:	f7ff ffe1 	bl	8001ee8 <rt_kprintf>
    rt_kprintf("- RT -     Thread Operating System\n");
 8001f26:	480a      	ldr	r0, [pc, #40]	@ (8001f50 <rt_show_version+0x34>)
 8001f28:	f7ff ffde 	bl	8001ee8 <rt_kprintf>
    rt_kprintf(" / | \\     %d.%d.%d build %s %s\n",
 8001f2c:	4b09      	ldr	r3, [pc, #36]	@ (8001f54 <rt_show_version+0x38>)
 8001f2e:	9301      	str	r3, [sp, #4]
 8001f30:	4b09      	ldr	r3, [pc, #36]	@ (8001f58 <rt_show_version+0x3c>)
 8001f32:	9300      	str	r3, [sp, #0]
 8001f34:	2301      	movs	r3, #1
 8001f36:	461a      	mov	r2, r3
 8001f38:	2104      	movs	r1, #4
 8001f3a:	4808      	ldr	r0, [pc, #32]	@ (8001f5c <rt_show_version+0x40>)
 8001f3c:	f7ff ffd4 	bl	8001ee8 <rt_kprintf>
    rt_kprintf(" 2006 - 2022 Copyright by RT-Thread team\n");
 8001f40:	4807      	ldr	r0, [pc, #28]	@ (8001f60 <rt_show_version+0x44>)
 8001f42:	f7ff ffd1 	bl	8001ee8 <rt_kprintf>
}
 8001f46:	b003      	add	sp, #12
 8001f48:	f85d fb04 	ldr.w	pc, [sp], #4
 8001f4c:	080087dc 	.word	0x080087dc
 8001f50:	080087e8 	.word	0x080087e8
 8001f54:	08008830 	.word	0x08008830
 8001f58:	0800883c 	.word	0x0800883c
 8001f5c:	0800880c 	.word	0x0800880c
 8001f60:	08008848 	.word	0x08008848

08001f64 <__rt_ffs>:
 * @return Return the index of the first bit set. If value is 0, then this function
 *         shall return 0.
 */
int __rt_ffs(int value)
{
    if (value == 0) return 0;
 8001f64:	b1e8      	cbz	r0, 8001fa2 <__rt_ffs+0x3e>

    if (value & 0xff)
 8001f66:	f010 02ff 	ands.w	r2, r0, #255	@ 0xff
 8001f6a:	d10a      	bne.n	8001f82 <__rt_ffs+0x1e>
        return __lowest_bit_bitmap[value & 0xff] + 1;

    if (value & 0xff00)
 8001f6c:	f410 4f7f 	tst.w	r0, #65280	@ 0xff00
 8001f70:	d10b      	bne.n	8001f8a <__rt_ffs+0x26>
        return __lowest_bit_bitmap[(value & 0xff00) >> 8] + 9;

    if (value & 0xff0000)
 8001f72:	f410 0f7f 	tst.w	r0, #16711680	@ 0xff0000
 8001f76:	d10e      	bne.n	8001f96 <__rt_ffs+0x32>
        return __lowest_bit_bitmap[(value & 0xff0000) >> 16] + 17;

    return __lowest_bit_bitmap[(value & 0xff000000) >> 24] + 25;
 8001f78:	0e03      	lsrs	r3, r0, #24
 8001f7a:	4a0a      	ldr	r2, [pc, #40]	@ (8001fa4 <__rt_ffs+0x40>)
 8001f7c:	5cd0      	ldrb	r0, [r2, r3]
 8001f7e:	3019      	adds	r0, #25
 8001f80:	4770      	bx	lr
        return __lowest_bit_bitmap[value & 0xff] + 1;
 8001f82:	4b08      	ldr	r3, [pc, #32]	@ (8001fa4 <__rt_ffs+0x40>)
 8001f84:	5c98      	ldrb	r0, [r3, r2]
 8001f86:	3001      	adds	r0, #1
 8001f88:	4770      	bx	lr
        return __lowest_bit_bitmap[(value & 0xff00) >> 8] + 9;
 8001f8a:	f3c0 2307 	ubfx	r3, r0, #8, #8
 8001f8e:	4a05      	ldr	r2, [pc, #20]	@ (8001fa4 <__rt_ffs+0x40>)
 8001f90:	5cd0      	ldrb	r0, [r2, r3]
 8001f92:	3009      	adds	r0, #9
 8001f94:	4770      	bx	lr
        return __lowest_bit_bitmap[(value & 0xff0000) >> 16] + 17;
 8001f96:	f3c0 4307 	ubfx	r3, r0, #16, #8
 8001f9a:	4a02      	ldr	r2, [pc, #8]	@ (8001fa4 <__rt_ffs+0x40>)
 8001f9c:	5cd0      	ldrb	r0, [r2, r3]
 8001f9e:	3011      	adds	r0, #17
 8001fa0:	4770      	bx	lr
}
 8001fa2:	4770      	bx	lr
 8001fa4:	08009110 	.word	0x08009110

08001fa8 <rt_assert_handler>:
 * @param func is the function name when assertion.
 *
 * @param line is the file line number when assertion.
 */
void rt_assert_handler(const char *ex_string, const char *func, rt_size_t line)
{
 8001fa8:	b500      	push	{lr}
 8001faa:	b083      	sub	sp, #12
    volatile char dummy = 0;
 8001fac:	2300      	movs	r3, #0
 8001fae:	f88d 3007 	strb.w	r3, [sp, #7]

    if (rt_assert_hook == RT_NULL)
 8001fb2:	4b09      	ldr	r3, [pc, #36]	@ (8001fd8 <rt_assert_handler+0x30>)
 8001fb4:	681b      	ldr	r3, [r3, #0]
 8001fb6:	b11b      	cbz	r3, 8001fc0 <rt_assert_handler+0x18>
            while (dummy == 0);
        }
    }
    else
    {
        rt_assert_hook(ex_string, func, line);
 8001fb8:	4798      	blx	r3
    }
}
 8001fba:	b003      	add	sp, #12
 8001fbc:	f85d fb04 	ldr.w	pc, [sp], #4
            rt_kprintf("(%s) assertion failed at function:%s, line number:%d \n", ex_string, func, line);
 8001fc0:	4613      	mov	r3, r2
 8001fc2:	460a      	mov	r2, r1
 8001fc4:	4601      	mov	r1, r0
 8001fc6:	4805      	ldr	r0, [pc, #20]	@ (8001fdc <rt_assert_handler+0x34>)
 8001fc8:	f7ff ff8e 	bl	8001ee8 <rt_kprintf>
            while (dummy == 0);
 8001fcc:	f89d 3007 	ldrb.w	r3, [sp, #7]
 8001fd0:	2b00      	cmp	r3, #0
 8001fd2:	d0fb      	beq.n	8001fcc <rt_assert_handler+0x24>
 8001fd4:	e7f1      	b.n	8001fba <rt_assert_handler+0x12>
 8001fd6:	bf00      	nop
 8001fd8:	200001d8 	.word	0x200001d8
 8001fdc:	08008874 	.word	0x08008874

08001fe0 <rt_system_heap_init>:
{
 8001fe0:	b5f8      	push	{r3, r4, r5, r6, r7, lr}
 8001fe2:	4604      	mov	r4, r0
    rt_ubase_t begin_align = RT_ALIGN((rt_ubase_t)begin_addr, RT_ALIGN_SIZE);
 8001fe4:	1cc5      	adds	r5, r0, #3
 8001fe6:	f025 0503 	bic.w	r5, r5, #3
    rt_ubase_t end_align   = RT_ALIGN_DOWN((rt_ubase_t)end_addr, RT_ALIGN_SIZE);
 8001fea:	f021 0603 	bic.w	r6, r1, #3
    RT_ASSERT(end_align > begin_align);
 8001fee:	42b5      	cmp	r5, r6
 8001ff0:	d20d      	bcs.n	800200e <rt_system_heap_init+0x2e>
    _MEM_INIT("heap", begin_addr, end_align - begin_align);
 8001ff2:	4f0a      	ldr	r7, [pc, #40]	@ (800201c <rt_system_heap_init+0x3c>)
 8001ff4:	1b72      	subs	r2, r6, r5
 8001ff6:	4621      	mov	r1, r4
 8001ff8:	4638      	mov	r0, r7
 8001ffa:	f000 f89b 	bl	8002134 <rt_smem_init>
 8001ffe:	4b08      	ldr	r3, [pc, #32]	@ (8002020 <rt_system_heap_init+0x40>)
 8002000:	6018      	str	r0, [r3, #0]
    rt_mutex_init(&_lock, "heap", RT_IPC_FLAG_PRIO);
 8002002:	2201      	movs	r2, #1
 8002004:	4639      	mov	r1, r7
 8002006:	4807      	ldr	r0, [pc, #28]	@ (8002024 <rt_system_heap_init+0x44>)
 8002008:	f000 fa7e 	bl	8002508 <rt_mutex_init>
}
 800200c:	bdf8      	pop	{r3, r4, r5, r6, r7, pc}
    RT_ASSERT(end_align > begin_align);
 800200e:	f240 52d4 	movw	r2, #1492	@ 0x5d4
 8002012:	4905      	ldr	r1, [pc, #20]	@ (8002028 <rt_system_heap_init+0x48>)
 8002014:	4805      	ldr	r0, [pc, #20]	@ (800202c <rt_system_heap_init+0x4c>)
 8002016:	f7ff ffc7 	bl	8001fa8 <rt_assert_handler>
 800201a:	e7ea      	b.n	8001ff2 <rt_system_heap_init+0x12>
 800201c:	080088c4 	.word	0x080088c4
 8002020:	200001dc 	.word	0x200001dc
 8002024:	200001e0 	.word	0x200001e0
 8002028:	08008e54 	.word	0x08008e54
 800202c:	080088ac 	.word	0x080088ac

08002030 <_heap_unlock>:
{
 8002030:	b508      	push	{r3, lr}
    RT_ASSERT(level == RT_EOK);
 8002032:	b930      	cbnz	r0, 8002042 <_heap_unlock+0x12>
    if (rt_thread_self())
 8002034:	f7fe feec 	bl	8000e10 <rt_thread_self>
 8002038:	b110      	cbz	r0, 8002040 <_heap_unlock+0x10>
        rt_mutex_release(&_lock);
 800203a:	4805      	ldr	r0, [pc, #20]	@ (8002050 <_heap_unlock+0x20>)
 800203c:	f000 fb5a 	bl	80026f4 <rt_mutex_release>
}
 8002040:	bd08      	pop	{r3, pc}
    RT_ASSERT(level == RT_EOK);
 8002042:	f240 527e 	movw	r2, #1406	@ 0x57e
 8002046:	4903      	ldr	r1, [pc, #12]	@ (8002054 <_heap_unlock+0x24>)
 8002048:	4803      	ldr	r0, [pc, #12]	@ (8002058 <_heap_unlock+0x28>)
 800204a:	f7ff ffad 	bl	8001fa8 <rt_assert_handler>
 800204e:	e7f1      	b.n	8002034 <_heap_unlock+0x4>
 8002050:	200001e0 	.word	0x200001e0
 8002054:	08008dd0 	.word	0x08008dd0
 8002058:	080088cc 	.word	0x080088cc

0800205c <rt_malloc>:
{
 800205c:	b538      	push	{r3, r4, r5, lr}
 800205e:	4604      	mov	r4, r0
    level = _heap_lock();
 8002060:	f7ff fd54 	bl	8001b0c <_heap_lock>
 8002064:	4605      	mov	r5, r0
    ptr = _MEM_MALLOC(size);
 8002066:	4621      	mov	r1, r4
 8002068:	4b04      	ldr	r3, [pc, #16]	@ (800207c <rt_malloc+0x20>)
 800206a:	6818      	ldr	r0, [r3, #0]
 800206c:	f000 f8a8 	bl	80021c0 <rt_smem_alloc>
 8002070:	4604      	mov	r4, r0
    _heap_unlock(level);
 8002072:	4628      	mov	r0, r5
 8002074:	f7ff ffdc 	bl	8002030 <_heap_unlock>
}
 8002078:	4620      	mov	r0, r4
 800207a:	bd38      	pop	{r3, r4, r5, pc}
 800207c:	200001dc 	.word	0x200001dc

08002080 <rt_free>:
    if (rmem == RT_NULL) return;
 8002080:	b158      	cbz	r0, 800209a <rt_free+0x1a>
{
 8002082:	b538      	push	{r3, r4, r5, lr}
 8002084:	4605      	mov	r5, r0
    level = _heap_lock();
 8002086:	f7ff fd41 	bl	8001b0c <_heap_lock>
 800208a:	4604      	mov	r4, r0
    _MEM_FREE(rmem);
 800208c:	4628      	mov	r0, r5
 800208e:	f000 f957 	bl	8002340 <rt_smem_free>
    _heap_unlock(level);
 8002092:	4620      	mov	r0, r4
 8002094:	f7ff ffcc 	bl	8002030 <_heap_unlock>
}
 8002098:	bd38      	pop	{r3, r4, r5, pc}
 800209a:	4770      	bx	lr

0800209c <plug_holes>:
    }
}
#endif /* RT_USING_MEMTRACE */

static void plug_holes(struct rt_small_mem *m, struct rt_small_mem_item *mem)
{
 800209c:	b538      	push	{r3, r4, r5, lr}
 800209e:	4605      	mov	r5, r0
 80020a0:	460c      	mov	r4, r1
    struct rt_small_mem_item *nmem;
    struct rt_small_mem_item *pmem;

    RT_ASSERT((rt_uint8_t *)mem >= m->heap_ptr);
 80020a2:	6a83      	ldr	r3, [r0, #40]	@ 0x28
 80020a4:	428b      	cmp	r3, r1
 80020a6:	d82e      	bhi.n	8002106 <plug_holes+0x6a>
    RT_ASSERT((rt_uint8_t *)mem < (rt_uint8_t *)m->heap_end);
 80020a8:	6aeb      	ldr	r3, [r5, #44]	@ 0x2c
 80020aa:	42a3      	cmp	r3, r4
 80020ac:	d931      	bls.n	8002112 <plug_holes+0x76>

    /* plug hole forward */
    nmem = (struct rt_small_mem_item *)&m->heap_ptr[mem->next];
 80020ae:	6aaa      	ldr	r2, [r5, #40]	@ 0x28
 80020b0:	6863      	ldr	r3, [r4, #4]
 80020b2:	18d1      	adds	r1, r2, r3
    if (mem != nmem && !MEM_ISUSED(nmem) &&
 80020b4:	428c      	cmp	r4, r1
 80020b6:	d011      	beq.n	80020dc <plug_holes+0x40>
 80020b8:	58d0      	ldr	r0, [r2, r3]
 80020ba:	f010 0f01 	tst.w	r0, #1
 80020be:	d10d      	bne.n	80020dc <plug_holes+0x40>
        (rt_uint8_t *)nmem != (rt_uint8_t *)m->heap_end)
 80020c0:	6ae8      	ldr	r0, [r5, #44]	@ 0x2c
    if (mem != nmem && !MEM_ISUSED(nmem) &&
 80020c2:	4288      	cmp	r0, r1
 80020c4:	d00a      	beq.n	80020dc <plug_holes+0x40>
    {
        /* if mem->next is unused and not end of m->heap_ptr,
         * combine mem and mem->next
         */
        if (m->lfree == nmem)
 80020c6:	6b28      	ldr	r0, [r5, #48]	@ 0x30
 80020c8:	4288      	cmp	r0, r1
 80020ca:	d028      	beq.n	800211e <plug_holes+0x82>
        {
            m->lfree = mem;
        }
        nmem->pool_ptr = 0;
 80020cc:	2000      	movs	r0, #0
 80020ce:	50d0      	str	r0, [r2, r3]
        mem->next = nmem->next;
 80020d0:	684b      	ldr	r3, [r1, #4]
 80020d2:	6063      	str	r3, [r4, #4]
        ((struct rt_small_mem_item *)&m->heap_ptr[nmem->next])->prev = (rt_uint8_t *)mem - m->heap_ptr;
 80020d4:	6aaa      	ldr	r2, [r5, #40]	@ 0x28
 80020d6:	4413      	add	r3, r2
 80020d8:	1aa2      	subs	r2, r4, r2
 80020da:	609a      	str	r2, [r3, #8]
    }

    /* plug hole backward */
    pmem = (struct rt_small_mem_item *)&m->heap_ptr[mem->prev];
 80020dc:	6aa9      	ldr	r1, [r5, #40]	@ 0x28
 80020de:	68a2      	ldr	r2, [r4, #8]
 80020e0:	188b      	adds	r3, r1, r2
    if (pmem != mem && !MEM_ISUSED(pmem))
 80020e2:	429c      	cmp	r4, r3
 80020e4:	d00e      	beq.n	8002104 <plug_holes+0x68>
 80020e6:	588a      	ldr	r2, [r1, r2]
 80020e8:	f012 0f01 	tst.w	r2, #1
 80020ec:	d10a      	bne.n	8002104 <plug_holes+0x68>
    {
        /* if mem->prev is unused, combine mem and mem->prev */
        if (m->lfree == mem)
 80020ee:	6b2a      	ldr	r2, [r5, #48]	@ 0x30
 80020f0:	42a2      	cmp	r2, r4
 80020f2:	d016      	beq.n	8002122 <plug_holes+0x86>
        {
            m->lfree = pmem;
        }
        mem->pool_ptr = 0;
 80020f4:	2200      	movs	r2, #0
 80020f6:	6022      	str	r2, [r4, #0]
        pmem->next = mem->next;
 80020f8:	6862      	ldr	r2, [r4, #4]
 80020fa:	605a      	str	r2, [r3, #4]
        ((struct rt_small_mem_item *)&m->heap_ptr[mem->next])->prev = (rt_uint8_t *)pmem - m->heap_ptr;
 80020fc:	6aa9      	ldr	r1, [r5, #40]	@ 0x28
 80020fe:	440a      	add	r2, r1
 8002100:	1a5b      	subs	r3, r3, r1
 8002102:	6093      	str	r3, [r2, #8]
    }
}
 8002104:	bd38      	pop	{r3, r4, r5, pc}
    RT_ASSERT((rt_uint8_t *)mem >= m->heap_ptr);
 8002106:	2282      	movs	r2, #130	@ 0x82
 8002108:	4907      	ldr	r1, [pc, #28]	@ (8002128 <plug_holes+0x8c>)
 800210a:	4808      	ldr	r0, [pc, #32]	@ (800212c <plug_holes+0x90>)
 800210c:	f7ff ff4c 	bl	8001fa8 <rt_assert_handler>
 8002110:	e7ca      	b.n	80020a8 <plug_holes+0xc>
    RT_ASSERT((rt_uint8_t *)mem < (rt_uint8_t *)m->heap_end);
 8002112:	2283      	movs	r2, #131	@ 0x83
 8002114:	4904      	ldr	r1, [pc, #16]	@ (8002128 <plug_holes+0x8c>)
 8002116:	4806      	ldr	r0, [pc, #24]	@ (8002130 <plug_holes+0x94>)
 8002118:	f7ff ff46 	bl	8001fa8 <rt_assert_handler>
 800211c:	e7c7      	b.n	80020ae <plug_holes+0x12>
            m->lfree = mem;
 800211e:	632c      	str	r4, [r5, #48]	@ 0x30
 8002120:	e7d4      	b.n	80020cc <plug_holes+0x30>
            m->lfree = pmem;
 8002122:	632b      	str	r3, [r5, #48]	@ 0x30
 8002124:	e7e6      	b.n	80020f4 <plug_holes+0x58>
 8002126:	bf00      	nop
 8002128:	08008e68 	.word	0x08008e68
 800212c:	080088dc 	.word	0x080088dc
 8002130:	08008900 	.word	0x08008900

08002134 <rt_smem_init>:
 * @return Return a pointer to the memory object. When the return value is RT_NULL, it means the init failed.
 */
rt_smem_t rt_smem_init(const char    *name,
                     void          *begin_addr,
                     rt_size_t      size)
{
 8002134:	b5f8      	push	{r3, r4, r5, r6, r7, lr}
    rt_ubase_t start_addr, begin_align, end_align, mem_size;

    small_mem = (struct rt_small_mem *)RT_ALIGN((rt_ubase_t)begin_addr, RT_ALIGN_SIZE);
    start_addr = (rt_ubase_t)small_mem + sizeof(*small_mem);
    begin_align = RT_ALIGN((rt_ubase_t)start_addr, RT_ALIGN_SIZE);
    end_align   = RT_ALIGN_DOWN((rt_ubase_t)begin_addr + size, RT_ALIGN_SIZE);
 8002136:	440a      	add	r2, r1
 8002138:	f022 0303 	bic.w	r3, r2, #3

    /* alignment addr */
    if ((end_align > (2 * SIZEOF_STRUCT_MEM)) &&
 800213c:	2b18      	cmp	r3, #24
 800213e:	d935      	bls.n	80021ac <rt_smem_init+0x78>
 8002140:	4607      	mov	r7, r0
 8002142:	1ccc      	adds	r4, r1, #3
 8002144:	f024 0403 	bic.w	r4, r4, #3
 8002148:	f104 0038 	add.w	r0, r4, #56	@ 0x38
 800214c:	4606      	mov	r6, r0
        ((end_align - 2 * SIZEOF_STRUCT_MEM) >= start_addr))
 800214e:	f1a3 0518 	sub.w	r5, r3, #24
    if ((end_align > (2 * SIZEOF_STRUCT_MEM)) &&
 8002152:	4285      	cmp	r5, r0
 8002154:	d32a      	bcc.n	80021ac <rt_smem_init+0x78>
    {
        /* calculate the aligned memory size */
        mem_size = end_align - begin_align - 2 * SIZEOF_STRUCT_MEM;
 8002156:	1a1b      	subs	r3, r3, r0
 8002158:	f1a3 0518 	sub.w	r5, r3, #24
                   (rt_ubase_t)begin_addr, (rt_ubase_t)begin_addr + size);

        return RT_NULL;
    }

    rt_memset(small_mem, 0, sizeof(*small_mem));
 800215c:	2238      	movs	r2, #56	@ 0x38
 800215e:	2100      	movs	r1, #0
 8002160:	4620      	mov	r0, r4
 8002162:	f7ff fce1 	bl	8001b28 <rt_memset>
    /* initialize small memory object */
    rt_object_init(&(small_mem->parent.parent), RT_Object_Class_Memory, name);
 8002166:	463a      	mov	r2, r7
 8002168:	210c      	movs	r1, #12
 800216a:	4620      	mov	r0, r4
 800216c:	f7ff fad6 	bl	800171c <rt_object_init>
    small_mem->parent.algorithm = "small";
 8002170:	4b11      	ldr	r3, [pc, #68]	@ (80021b8 <rt_smem_init+0x84>)
 8002172:	6163      	str	r3, [r4, #20]
    small_mem->parent.address = begin_align;
 8002174:	61a6      	str	r6, [r4, #24]
    small_mem->parent.total = mem_size;
 8002176:	61e5      	str	r5, [r4, #28]
    small_mem->mem_size_aligned = mem_size;
 8002178:	6365      	str	r5, [r4, #52]	@ 0x34

    /* point to begin address of heap */
    small_mem->heap_ptr = (rt_uint8_t *)begin_align;
 800217a:	62a6      	str	r6, [r4, #40]	@ 0x28
    RT_DEBUG_LOG(RT_DEBUG_MEM, ("mem init, heap begin address 0x%x, size %d\n",
                                (rt_ubase_t)small_mem->heap_ptr, small_mem->mem_size_aligned));

    /* initialize the start of the heap */
    mem        = (struct rt_small_mem_item *)small_mem->heap_ptr;
    mem->pool_ptr = MEM_FREED();
 800217c:	6034      	str	r4, [r6, #0]
    mem->next  = small_mem->mem_size_aligned + SIZEOF_STRUCT_MEM;
 800217e:	6b63      	ldr	r3, [r4, #52]	@ 0x34
 8002180:	330c      	adds	r3, #12
 8002182:	6073      	str	r3, [r6, #4]
    mem->prev  = 0;
 8002184:	2200      	movs	r2, #0
 8002186:	60b2      	str	r2, [r6, #8]
#ifdef RT_USING_MEMTRACE
    rt_smem_setname(mem, "INIT");
#endif /* RT_USING_MEMTRACE */

    /* initialize the end of the heap */
    small_mem->heap_end        = (struct rt_small_mem_item *)&small_mem->heap_ptr[mem->next];
 8002188:	6aa2      	ldr	r2, [r4, #40]	@ 0x28
 800218a:	18d1      	adds	r1, r2, r3
 800218c:	62e1      	str	r1, [r4, #44]	@ 0x2c
    small_mem->heap_end->pool_ptr = MEM_USED();
 800218e:	f044 0101 	orr.w	r1, r4, #1
 8002192:	50d1      	str	r1, [r2, r3]
    small_mem->heap_end->next  = small_mem->mem_size_aligned + SIZEOF_STRUCT_MEM;
 8002194:	6b63      	ldr	r3, [r4, #52]	@ 0x34
 8002196:	6ae2      	ldr	r2, [r4, #44]	@ 0x2c
 8002198:	330c      	adds	r3, #12
 800219a:	6053      	str	r3, [r2, #4]
    small_mem->heap_end->prev  = small_mem->mem_size_aligned + SIZEOF_STRUCT_MEM;
 800219c:	6b63      	ldr	r3, [r4, #52]	@ 0x34
 800219e:	6ae2      	ldr	r2, [r4, #44]	@ 0x2c
 80021a0:	330c      	adds	r3, #12
 80021a2:	6093      	str	r3, [r2, #8]
#ifdef RT_USING_MEMTRACE
    rt_smem_setname(small_mem->heap_end, "INIT");
#endif /* RT_USING_MEMTRACE */

    /* initialize the lowest-free pointer to the start of the heap */
    small_mem->lfree = (struct rt_small_mem_item *)small_mem->heap_ptr;
 80021a4:	6aa3      	ldr	r3, [r4, #40]	@ 0x28
 80021a6:	6323      	str	r3, [r4, #48]	@ 0x30

    return &small_mem->parent;
 80021a8:	4620      	mov	r0, r4
}
 80021aa:	bdf8      	pop	{r3, r4, r5, r6, r7, pc}
        rt_kprintf("mem init, error begin address 0x%x, and end address 0x%x\n",
 80021ac:	4803      	ldr	r0, [pc, #12]	@ (80021bc <rt_smem_init+0x88>)
 80021ae:	f7ff fe9b 	bl	8001ee8 <rt_kprintf>
        return RT_NULL;
 80021b2:	2000      	movs	r0, #0
 80021b4:	e7f9      	b.n	80021aa <rt_smem_init+0x76>
 80021b6:	bf00      	nop
 80021b8:	08008930 	.word	0x08008930
 80021bc:	08008938 	.word	0x08008938

080021c0 <rt_smem_alloc>:
 * @param size is the minimum size of the requested block in bytes.
 *
 * @return the pointer to allocated memory or NULL if no free memory was found.
 */
void *rt_smem_alloc(rt_smem_t m, rt_size_t size)
{
 80021c0:	b5f8      	push	{r3, r4, r5, r6, r7, lr}
    rt_size_t ptr, ptr2;
    struct rt_small_mem_item *mem, *mem2;
    struct rt_small_mem *small_mem;

    if (size == 0)
 80021c2:	2900      	cmp	r1, #0
 80021c4:	f000 80a7 	beq.w	8002316 <rt_smem_alloc+0x156>
 80021c8:	4606      	mov	r6, r0
 80021ca:	460d      	mov	r5, r1
        return RT_NULL;

    RT_ASSERT(m != RT_NULL);
 80021cc:	b1b0      	cbz	r0, 80021fc <rt_smem_alloc+0x3c>
    RT_ASSERT(rt_object_get_type(&m->parent) == RT_Object_Class_Memory);
 80021ce:	4630      	mov	r0, r6
 80021d0:	f7ff fb96 	bl	8001900 <rt_object_get_type>
 80021d4:	280c      	cmp	r0, #12
 80021d6:	d118      	bne.n	800220a <rt_smem_alloc+0x4a>
    RT_ASSERT(rt_object_is_systemobject(&m->parent));
 80021d8:	4630      	mov	r0, r6
 80021da:	f7ff fb7b 	bl	80018d4 <rt_object_is_systemobject>
 80021de:	b1d8      	cbz	r0, 8002218 <rt_smem_alloc+0x58>

    if (size != RT_ALIGN(size, RT_ALIGN_SIZE))
 80021e0:	3503      	adds	r5, #3
        RT_DEBUG_LOG(RT_DEBUG_MEM, ("malloc size %d\n", size));
    }

    small_mem = (struct rt_small_mem *)m;
    /* alignment size */
    size = RT_ALIGN(size, RT_ALIGN_SIZE);
 80021e2:	f025 0503 	bic.w	r5, r5, #3

    /* every data block must be at least MIN_SIZE_ALIGNED long */
    if (size < MIN_SIZE_ALIGNED)
 80021e6:	2d0b      	cmp	r5, #11
 80021e8:	d800      	bhi.n	80021ec <rt_smem_alloc+0x2c>
        size = MIN_SIZE_ALIGNED;
 80021ea:	250c      	movs	r5, #12

    if (size > small_mem->mem_size_aligned)
 80021ec:	6b71      	ldr	r1, [r6, #52]	@ 0x34
 80021ee:	42a9      	cmp	r1, r5
 80021f0:	f0c0 8093 	bcc.w	800231a <rt_smem_alloc+0x15a>
        RT_DEBUG_LOG(RT_DEBUG_MEM, ("no memory\n"));

        return RT_NULL;
    }

    for (ptr = (rt_uint8_t *)small_mem->lfree - small_mem->heap_ptr;
 80021f4:	6b33      	ldr	r3, [r6, #48]	@ 0x30
 80021f6:	6ab7      	ldr	r7, [r6, #40]	@ 0x28
 80021f8:	1bdb      	subs	r3, r3, r7
 80021fa:	e044      	b.n	8002286 <rt_smem_alloc+0xc6>
    RT_ASSERT(m != RT_NULL);
 80021fc:	f44f 7290 	mov.w	r2, #288	@ 0x120
 8002200:	4947      	ldr	r1, [pc, #284]	@ (8002320 <rt_smem_alloc+0x160>)
 8002202:	4848      	ldr	r0, [pc, #288]	@ (8002324 <rt_smem_alloc+0x164>)
 8002204:	f7ff fed0 	bl	8001fa8 <rt_assert_handler>
 8002208:	e7e1      	b.n	80021ce <rt_smem_alloc+0xe>
    RT_ASSERT(rt_object_get_type(&m->parent) == RT_Object_Class_Memory);
 800220a:	f240 1221 	movw	r2, #289	@ 0x121
 800220e:	4944      	ldr	r1, [pc, #272]	@ (8002320 <rt_smem_alloc+0x160>)
 8002210:	4845      	ldr	r0, [pc, #276]	@ (8002328 <rt_smem_alloc+0x168>)
 8002212:	f7ff fec9 	bl	8001fa8 <rt_assert_handler>
 8002216:	e7df      	b.n	80021d8 <rt_smem_alloc+0x18>
    RT_ASSERT(rt_object_is_systemobject(&m->parent));
 8002218:	f44f 7291 	mov.w	r2, #290	@ 0x122
 800221c:	4940      	ldr	r1, [pc, #256]	@ (8002320 <rt_smem_alloc+0x160>)
 800221e:	4843      	ldr	r0, [pc, #268]	@ (800232c <rt_smem_alloc+0x16c>)
 8002220:	f7ff fec2 	bl	8001fa8 <rt_assert_handler>
 8002224:	e7dc      	b.n	80021e0 <rt_smem_alloc+0x20>
                 * take care of this).
                 * -> near fit or excact fit: do not split, no mem2 creation
                 * also can't move mem->next directly behind mem, since mem->next
                 * will always be used at this point!
                 */
                small_mem->parent.used += mem->next - ((rt_uint8_t *)mem - small_mem->heap_ptr);
 8002226:	6a32      	ldr	r2, [r6, #32]
 8002228:	1ac0      	subs	r0, r0, r3
 800222a:	4402      	add	r2, r0
 800222c:	6232      	str	r2, [r6, #32]
                if (small_mem->parent.max < small_mem->parent.used)
 800222e:	6a73      	ldr	r3, [r6, #36]	@ 0x24
 8002230:	429a      	cmp	r2, r3
 8002232:	d953      	bls.n	80022dc <rt_smem_alloc+0x11c>
                    small_mem->parent.max = small_mem->parent.used;
 8002234:	6272      	str	r2, [r6, #36]	@ 0x24
 8002236:	e051      	b.n	80022dc <rt_smem_alloc+0x11c>

            if (mem == small_mem->lfree)
            {
                /* Find next free block after mem and update lowest free pointer */
                while (MEM_ISUSED(small_mem->lfree) && small_mem->lfree != small_mem->heap_end)
                    small_mem->lfree = (struct rt_small_mem_item *)&small_mem->heap_ptr[small_mem->lfree->next];
 8002238:	6ab3      	ldr	r3, [r6, #40]	@ 0x28
 800223a:	6852      	ldr	r2, [r2, #4]
 800223c:	4413      	add	r3, r2
 800223e:	6333      	str	r3, [r6, #48]	@ 0x30
                while (MEM_ISUSED(small_mem->lfree) && small_mem->lfree != small_mem->heap_end)
 8002240:	6b32      	ldr	r2, [r6, #48]	@ 0x30
 8002242:	6813      	ldr	r3, [r2, #0]
 8002244:	f013 0301 	ands.w	r3, r3, #1
 8002248:	d002      	beq.n	8002250 <rt_smem_alloc+0x90>
 800224a:	6af1      	ldr	r1, [r6, #44]	@ 0x2c
 800224c:	428a      	cmp	r2, r1
 800224e:	d1f3      	bne.n	8002238 <rt_smem_alloc+0x78>

                RT_ASSERT(((small_mem->lfree == small_mem->heap_end) || (!MEM_ISUSED(small_mem->lfree))));
 8002250:	6af1      	ldr	r1, [r6, #44]	@ 0x2c
 8002252:	428a      	cmp	r2, r1
 8002254:	d048      	beq.n	80022e8 <rt_smem_alloc+0x128>
 8002256:	2b00      	cmp	r3, #0
 8002258:	d046      	beq.n	80022e8 <rt_smem_alloc+0x128>
 800225a:	f240 1287 	movw	r2, #391	@ 0x187
 800225e:	4930      	ldr	r1, [pc, #192]	@ (8002320 <rt_smem_alloc+0x160>)
 8002260:	4833      	ldr	r0, [pc, #204]	@ (8002330 <rt_smem_alloc+0x170>)
 8002262:	f7ff fea1 	bl	8001fa8 <rt_assert_handler>
 8002266:	e03f      	b.n	80022e8 <rt_smem_alloc+0x128>
            }
            RT_ASSERT((rt_ubase_t)mem + SIZEOF_STRUCT_MEM + size <= (rt_ubase_t)small_mem->heap_end);
 8002268:	f240 1289 	movw	r2, #393	@ 0x189
 800226c:	492c      	ldr	r1, [pc, #176]	@ (8002320 <rt_smem_alloc+0x160>)
 800226e:	4831      	ldr	r0, [pc, #196]	@ (8002334 <rt_smem_alloc+0x174>)
 8002270:	f7ff fe9a 	bl	8001fa8 <rt_assert_handler>
 8002274:	e03d      	b.n	80022f2 <rt_smem_alloc+0x132>
            RT_ASSERT((rt_ubase_t)((rt_uint8_t *)mem + SIZEOF_STRUCT_MEM) % RT_ALIGN_SIZE == 0);
 8002276:	f44f 72c5 	mov.w	r2, #394	@ 0x18a
 800227a:	4929      	ldr	r1, [pc, #164]	@ (8002320 <rt_smem_alloc+0x160>)
 800227c:	482e      	ldr	r0, [pc, #184]	@ (8002338 <rt_smem_alloc+0x178>)
 800227e:	f7ff fe93 	bl	8001fa8 <rt_assert_handler>
 8002282:	e03b      	b.n	80022fc <rt_smem_alloc+0x13c>
         ptr = ((struct rt_small_mem_item *)&small_mem->heap_ptr[ptr])->next)
 8002284:	6863      	ldr	r3, [r4, #4]
         ptr <= small_mem->mem_size_aligned - size;
 8002286:	1b4a      	subs	r2, r1, r5
 8002288:	4293      	cmp	r3, r2
 800228a:	d841      	bhi.n	8002310 <rt_smem_alloc+0x150>
        mem = (struct rt_small_mem_item *)&small_mem->heap_ptr[ptr];
 800228c:	18fc      	adds	r4, r7, r3
        if ((!MEM_ISUSED(mem)) && (mem->next - (ptr + SIZEOF_STRUCT_MEM)) >= size)
 800228e:	58fa      	ldr	r2, [r7, r3]
 8002290:	f012 0f01 	tst.w	r2, #1
 8002294:	d1f6      	bne.n	8002284 <rt_smem_alloc+0xc4>
 8002296:	6860      	ldr	r0, [r4, #4]
 8002298:	1ac2      	subs	r2, r0, r3
 800229a:	3a0c      	subs	r2, #12
 800229c:	42aa      	cmp	r2, r5
 800229e:	d3f1      	bcc.n	8002284 <rt_smem_alloc+0xc4>
                (size + SIZEOF_STRUCT_MEM + MIN_SIZE_ALIGNED))
 80022a0:	f105 0118 	add.w	r1, r5, #24
            if (mem->next - (ptr + SIZEOF_STRUCT_MEM) >=
 80022a4:	428a      	cmp	r2, r1
 80022a6:	d3be      	bcc.n	8002226 <rt_smem_alloc+0x66>
                ptr2 = ptr + SIZEOF_STRUCT_MEM + size;
 80022a8:	18ea      	adds	r2, r5, r3
 80022aa:	320c      	adds	r2, #12
                mem2       = (struct rt_small_mem_item *)&small_mem->heap_ptr[ptr2];
 80022ac:	18b9      	adds	r1, r7, r2
                mem2->pool_ptr = MEM_FREED();
 80022ae:	f026 0001 	bic.w	r0, r6, #1
 80022b2:	50b8      	str	r0, [r7, r2]
                mem2->next = mem->next;
 80022b4:	6860      	ldr	r0, [r4, #4]
 80022b6:	6048      	str	r0, [r1, #4]
                mem2->prev = ptr;
 80022b8:	608b      	str	r3, [r1, #8]
                mem->next = ptr2;
 80022ba:	6062      	str	r2, [r4, #4]
                if (mem2->next != small_mem->mem_size_aligned + SIZEOF_STRUCT_MEM)
 80022bc:	6849      	ldr	r1, [r1, #4]
 80022be:	6b73      	ldr	r3, [r6, #52]	@ 0x34
 80022c0:	330c      	adds	r3, #12
 80022c2:	4299      	cmp	r1, r3
 80022c4:	d002      	beq.n	80022cc <rt_smem_alloc+0x10c>
                    ((struct rt_small_mem_item *)&small_mem->heap_ptr[mem2->next])->prev = ptr2;
 80022c6:	6ab3      	ldr	r3, [r6, #40]	@ 0x28
 80022c8:	440b      	add	r3, r1
 80022ca:	609a      	str	r2, [r3, #8]
                small_mem->parent.used += (size + SIZEOF_STRUCT_MEM);
 80022cc:	6a33      	ldr	r3, [r6, #32]
 80022ce:	442b      	add	r3, r5
 80022d0:	330c      	adds	r3, #12
 80022d2:	6233      	str	r3, [r6, #32]
                if (small_mem->parent.max < small_mem->parent.used)
 80022d4:	6a72      	ldr	r2, [r6, #36]	@ 0x24
 80022d6:	4293      	cmp	r3, r2
 80022d8:	d900      	bls.n	80022dc <rt_smem_alloc+0x11c>
                    small_mem->parent.max = small_mem->parent.used;
 80022da:	6273      	str	r3, [r6, #36]	@ 0x24
            mem->pool_ptr = MEM_USED();
 80022dc:	f046 0301 	orr.w	r3, r6, #1
 80022e0:	6023      	str	r3, [r4, #0]
            if (mem == small_mem->lfree)
 80022e2:	6b33      	ldr	r3, [r6, #48]	@ 0x30
 80022e4:	42a3      	cmp	r3, r4
 80022e6:	d0ab      	beq.n	8002240 <rt_smem_alloc+0x80>
            RT_ASSERT((rt_ubase_t)mem + SIZEOF_STRUCT_MEM + size <= (rt_ubase_t)small_mem->heap_end);
 80022e8:	4425      	add	r5, r4
 80022ea:	350c      	adds	r5, #12
 80022ec:	6af3      	ldr	r3, [r6, #44]	@ 0x2c
 80022ee:	429d      	cmp	r5, r3
 80022f0:	d8ba      	bhi.n	8002268 <rt_smem_alloc+0xa8>
            RT_ASSERT((rt_ubase_t)((rt_uint8_t *)mem + SIZEOF_STRUCT_MEM) % RT_ALIGN_SIZE == 0);
 80022f2:	f104 050c 	add.w	r5, r4, #12
 80022f6:	f014 0f03 	tst.w	r4, #3
 80022fa:	d1bc      	bne.n	8002276 <rt_smem_alloc+0xb6>
            RT_ASSERT((((rt_ubase_t)mem) & (RT_ALIGN_SIZE - 1)) == 0);
 80022fc:	f014 0f03 	tst.w	r4, #3
 8002300:	d007      	beq.n	8002312 <rt_smem_alloc+0x152>
 8002302:	f240 128b 	movw	r2, #395	@ 0x18b
 8002306:	4906      	ldr	r1, [pc, #24]	@ (8002320 <rt_smem_alloc+0x160>)
 8002308:	480c      	ldr	r0, [pc, #48]	@ (800233c <rt_smem_alloc+0x17c>)
 800230a:	f7ff fe4d 	bl	8001fa8 <rt_assert_handler>
                         ("allocate memory at 0x%x, size: %d\n",
                          (rt_ubase_t)((rt_uint8_t *)mem + SIZEOF_STRUCT_MEM),
                          (rt_ubase_t)(mem->next - ((rt_uint8_t *)mem - small_mem->heap_ptr))));

            /* return the memory data except mem struct */
            return (rt_uint8_t *)mem + SIZEOF_STRUCT_MEM;
 800230e:	e000      	b.n	8002312 <rt_smem_alloc+0x152>
        }
    }

    return RT_NULL;
 8002310:	2500      	movs	r5, #0
}
 8002312:	4628      	mov	r0, r5
 8002314:	bdf8      	pop	{r3, r4, r5, r6, r7, pc}
        return RT_NULL;
 8002316:	2500      	movs	r5, #0
 8002318:	e7fb      	b.n	8002312 <rt_smem_alloc+0x152>
        return RT_NULL;
 800231a:	2500      	movs	r5, #0
 800231c:	e7f9      	b.n	8002312 <rt_smem_alloc+0x152>
 800231e:	bf00      	nop
 8002320:	08008f28 	.word	0x08008f28
 8002324:	08008b2c 	.word	0x08008b2c
 8002328:	08008974 	.word	0x08008974
 800232c:	080089b0 	.word	0x080089b0
 8002330:	080089d8 	.word	0x080089d8
 8002334:	08008a28 	.word	0x08008a28
 8002338:	08008a78 	.word	0x08008a78
 800233c:	08008ac4 	.word	0x08008ac4

08002340 <rt_smem_free>:
void rt_smem_free(void *rmem)
{
    struct rt_small_mem_item *mem;
    struct rt_small_mem *small_mem;

    if (rmem == RT_NULL)
 8002340:	2800      	cmp	r0, #0
 8002342:	d06a      	beq.n	800241a <rt_smem_free+0xda>
{
 8002344:	b570      	push	{r4, r5, r6, lr}
 8002346:	4605      	mov	r5, r0
        return;

    RT_ASSERT((((rt_ubase_t)rmem) & (RT_ALIGN_SIZE - 1)) == 0);
 8002348:	f010 0f03 	tst.w	r0, #3
 800234c:	d142      	bne.n	80023d4 <rt_smem_free+0x94>

    /* Get the corresponding struct rt_small_mem_item ... */
    mem = (struct rt_small_mem_item *)((rt_uint8_t *)rmem - SIZEOF_STRUCT_MEM);
 800234e:	f1a5 060c 	sub.w	r6, r5, #12
                 ("release memory 0x%x, size: %d\n",
                  (rt_ubase_t)rmem,
                  (rt_ubase_t)(mem->next - ((rt_uint8_t *)mem - small_mem->heap_ptr))));

    /* ... which has to be in a used state ... */
    small_mem = MEM_POOL(mem);
 8002352:	f855 4c0c 	ldr.w	r4, [r5, #-12]
    RT_ASSERT(small_mem != RT_NULL);
 8002356:	f034 0401 	bics.w	r4, r4, #1
 800235a:	d042      	beq.n	80023e2 <rt_smem_free+0xa2>
    RT_ASSERT(MEM_ISUSED(mem));
 800235c:	f855 3c0c 	ldr.w	r3, [r5, #-12]
 8002360:	f013 0f01 	tst.w	r3, #1
 8002364:	d044      	beq.n	80023f0 <rt_smem_free+0xb0>
    RT_ASSERT(rt_object_get_type(&small_mem->parent.parent) == RT_Object_Class_Memory);
 8002366:	4620      	mov	r0, r4
 8002368:	f7ff faca 	bl	8001900 <rt_object_get_type>
 800236c:	280c      	cmp	r0, #12
 800236e:	d146      	bne.n	80023fe <rt_smem_free+0xbe>
    RT_ASSERT(rt_object_is_systemobject(&small_mem->parent.parent));
 8002370:	4620      	mov	r0, r4
 8002372:	f7ff faaf 	bl	80018d4 <rt_object_is_systemobject>
 8002376:	2800      	cmp	r0, #0
 8002378:	d048      	beq.n	800240c <rt_smem_free+0xcc>
    RT_ASSERT((rt_uint8_t *)rmem >= (rt_uint8_t *)small_mem->heap_ptr &&
 800237a:	6aa3      	ldr	r3, [r4, #40]	@ 0x28
 800237c:	42ab      	cmp	r3, r5
 800237e:	d802      	bhi.n	8002386 <rt_smem_free+0x46>
 8002380:	6ae3      	ldr	r3, [r4, #44]	@ 0x2c
 8002382:	42ab      	cmp	r3, r5
 8002384:	d805      	bhi.n	8002392 <rt_smem_free+0x52>
 8002386:	f44f 7207 	mov.w	r2, #540	@ 0x21c
 800238a:	4924      	ldr	r1, [pc, #144]	@ (800241c <rt_smem_free+0xdc>)
 800238c:	4824      	ldr	r0, [pc, #144]	@ (8002420 <rt_smem_free+0xe0>)
 800238e:	f7ff fe0b 	bl	8001fa8 <rt_assert_handler>
              (rt_uint8_t *)rmem < (rt_uint8_t *)small_mem->heap_end);
    RT_ASSERT(MEM_POOL(&small_mem->heap_ptr[mem->next]) == small_mem);
 8002392:	6aa2      	ldr	r2, [r4, #40]	@ 0x28
 8002394:	f855 3c08 	ldr.w	r3, [r5, #-8]
 8002398:	58d3      	ldr	r3, [r2, r3]
 800239a:	f023 0301 	bic.w	r3, r3, #1
 800239e:	42a3      	cmp	r3, r4
 80023a0:	d005      	beq.n	80023ae <rt_smem_free+0x6e>
 80023a2:	f240 221e 	movw	r2, #542	@ 0x21e
 80023a6:	491d      	ldr	r1, [pc, #116]	@ (800241c <rt_smem_free+0xdc>)
 80023a8:	481e      	ldr	r0, [pc, #120]	@ (8002424 <rt_smem_free+0xe4>)
 80023aa:	f7ff fdfd 	bl	8001fa8 <rt_assert_handler>

    /* ... and is now unused. */
    mem->pool_ptr = MEM_FREED();
 80023ae:	f845 4c0c 	str.w	r4, [r5, #-12]
#ifdef RT_USING_MEMTRACE
    rt_smem_setname(mem, "    ");
#endif /* RT_USING_MEMTRACE */

    if (mem < small_mem->lfree)
 80023b2:	6b23      	ldr	r3, [r4, #48]	@ 0x30
 80023b4:	42b3      	cmp	r3, r6
 80023b6:	d900      	bls.n	80023ba <rt_smem_free+0x7a>
    {
        /* the newly freed struct is now the lowest */
        small_mem->lfree = mem;
 80023b8:	6326      	str	r6, [r4, #48]	@ 0x30
    }

    small_mem->parent.used -= (mem->next - ((rt_uint8_t *)mem - small_mem->heap_ptr));
 80023ba:	6a22      	ldr	r2, [r4, #32]
 80023bc:	6aa3      	ldr	r3, [r4, #40]	@ 0x28
 80023be:	1af3      	subs	r3, r6, r3
 80023c0:	f855 1c08 	ldr.w	r1, [r5, #-8]
 80023c4:	1a5b      	subs	r3, r3, r1
 80023c6:	4413      	add	r3, r2
 80023c8:	6223      	str	r3, [r4, #32]

    /* finally, see if prev or next are free also */
    plug_holes(small_mem, mem);
 80023ca:	4631      	mov	r1, r6
 80023cc:	4620      	mov	r0, r4
 80023ce:	f7ff fe65 	bl	800209c <plug_holes>
}
 80023d2:	bd70      	pop	{r4, r5, r6, pc}
    RT_ASSERT((((rt_ubase_t)rmem) & (RT_ALIGN_SIZE - 1)) == 0);
 80023d4:	f44f 7203 	mov.w	r2, #524	@ 0x20c
 80023d8:	4910      	ldr	r1, [pc, #64]	@ (800241c <rt_smem_free+0xdc>)
 80023da:	4813      	ldr	r0, [pc, #76]	@ (8002428 <rt_smem_free+0xe8>)
 80023dc:	f7ff fde4 	bl	8001fa8 <rt_assert_handler>
 80023e0:	e7b5      	b.n	800234e <rt_smem_free+0xe>
    RT_ASSERT(small_mem != RT_NULL);
 80023e2:	f44f 7206 	mov.w	r2, #536	@ 0x218
 80023e6:	490d      	ldr	r1, [pc, #52]	@ (800241c <rt_smem_free+0xdc>)
 80023e8:	4810      	ldr	r0, [pc, #64]	@ (800242c <rt_smem_free+0xec>)
 80023ea:	f7ff fddd 	bl	8001fa8 <rt_assert_handler>
 80023ee:	e7b5      	b.n	800235c <rt_smem_free+0x1c>
    RT_ASSERT(MEM_ISUSED(mem));
 80023f0:	f240 2219 	movw	r2, #537	@ 0x219
 80023f4:	4909      	ldr	r1, [pc, #36]	@ (800241c <rt_smem_free+0xdc>)
 80023f6:	480e      	ldr	r0, [pc, #56]	@ (8002430 <rt_smem_free+0xf0>)
 80023f8:	f7ff fdd6 	bl	8001fa8 <rt_assert_handler>
 80023fc:	e7b3      	b.n	8002366 <rt_smem_free+0x26>
    RT_ASSERT(rt_object_get_type(&small_mem->parent.parent) == RT_Object_Class_Memory);
 80023fe:	f240 221a 	movw	r2, #538	@ 0x21a
 8002402:	4906      	ldr	r1, [pc, #24]	@ (800241c <rt_smem_free+0xdc>)
 8002404:	480b      	ldr	r0, [pc, #44]	@ (8002434 <rt_smem_free+0xf4>)
 8002406:	f7ff fdcf 	bl	8001fa8 <rt_assert_handler>
 800240a:	e7b1      	b.n	8002370 <rt_smem_free+0x30>
    RT_ASSERT(rt_object_is_systemobject(&small_mem->parent.parent));
 800240c:	f240 221b 	movw	r2, #539	@ 0x21b
 8002410:	4902      	ldr	r1, [pc, #8]	@ (800241c <rt_smem_free+0xdc>)
 8002412:	4809      	ldr	r0, [pc, #36]	@ (8002438 <rt_smem_free+0xf8>)
 8002414:	f7ff fdc8 	bl	8001fa8 <rt_assert_handler>
 8002418:	e7af      	b.n	800237a <rt_smem_free+0x3a>
 800241a:	4770      	bx	lr
 800241c:	08008de0 	.word	0x08008de0
 8002420:	08008bcc 	.word	0x08008bcc
 8002424:	08008c40 	.word	0x08008c40
 8002428:	08008af4 	.word	0x08008af4
 800242c:	08008b24 	.word	0x08008b24
 8002430:	08008b3c 	.word	0x08008b3c
 8002434:	08008b4c 	.word	0x08008b4c
 8002438:	08008b94 	.word	0x08008b94

0800243c <rt_tick_get>:
 * @return   Return current tick.
 */
rt_tick_t rt_tick_get(void)
{
    /* return the global tick */
    return rt_tick;
 800243c:	4b01      	ldr	r3, [pc, #4]	@ (8002444 <rt_tick_get+0x8>)
 800243e:	6818      	ldr	r0, [r3, #0]
}
 8002440:	4770      	bx	lr
 8002442:	bf00      	nop
 8002444:	20000204 	.word	0x20000204

08002448 <rt_tick_increase>:
/**
 * @brief    This function will notify kernel there is one tick passed.
 *           Normally, this function is invoked by clock ISR.
 */
void rt_tick_increase(void)
{
 8002448:	b510      	push	{r4, lr}
    struct rt_thread *thread;
    rt_base_t level;

    RT_OBJECT_HOOK_CALL(rt_tick_hook, ());

    level = rt_hw_interrupt_disable();
 800244a:	f7fd feff 	bl	800024c <rt_hw_interrupt_disable>
 800244e:	4604      	mov	r4, r0

    /* increase the global tick */
#ifdef RT_USING_SMP
    rt_cpu_self()->tick ++;
#else
    ++ rt_tick;
 8002450:	4a0e      	ldr	r2, [pc, #56]	@ (800248c <rt_tick_increase+0x44>)
 8002452:	6813      	ldr	r3, [r2, #0]
 8002454:	3301      	adds	r3, #1
 8002456:	6013      	str	r3, [r2, #0]
#endif /* RT_USING_SMP */

    /* check time slice */
    thread = rt_thread_self();
 8002458:	f7fe fcda 	bl	8000e10 <rt_thread_self>

    -- thread->remaining_tick;
 800245c:	6c83      	ldr	r3, [r0, #72]	@ 0x48
 800245e:	3b01      	subs	r3, #1
 8002460:	6483      	str	r3, [r0, #72]	@ 0x48
    if (thread->remaining_tick == 0)
 8002462:	b97b      	cbnz	r3, 8002484 <rt_tick_increase+0x3c>
    {
        /* change to initialized tick */
        thread->remaining_tick = thread->init_tick;
 8002464:	6c43      	ldr	r3, [r0, #68]	@ 0x44
 8002466:	6483      	str	r3, [r0, #72]	@ 0x48
        thread->stat |= RT_THREAD_STAT_YIELD;
 8002468:	f890 3034 	ldrb.w	r3, [r0, #52]	@ 0x34
 800246c:	f043 0308 	orr.w	r3, r3, #8
 8002470:	f880 3034 	strb.w	r3, [r0, #52]	@ 0x34

        rt_hw_interrupt_enable(level);
 8002474:	4620      	mov	r0, r4
 8002476:	f7fd feed 	bl	8000254 <rt_hw_interrupt_enable>
        rt_schedule();
 800247a:	f000 faa9 	bl	80029d0 <rt_schedule>
    {
        rt_hw_interrupt_enable(level);
    }

    /* check timer */
    rt_timer_check();
 800247e:	f7ff f8d9 	bl	8001634 <rt_timer_check>
}
 8002482:	bd10      	pop	{r4, pc}
        rt_hw_interrupt_enable(level);
 8002484:	4620      	mov	r0, r4
 8002486:	f7fd fee5 	bl	8000254 <rt_hw_interrupt_enable>
 800248a:	e7f8      	b.n	800247e <rt_tick_increase+0x36>
 800248c:	20000204 	.word	0x20000204

08002490 <_ipc_list_suspend>:
 *           rt_mb_recv(),   rt_mq_recv(),     rt_mq_send_wait()
 */
rt_inline rt_err_t _ipc_list_suspend(rt_list_t        *list,
                                     struct rt_thread *thread,
                                     rt_uint8_t        flag)
{
 8002490:	b570      	push	{r4, r5, r6, lr}
 8002492:	4606      	mov	r6, r0
 8002494:	460c      	mov	r4, r1
 8002496:	4615      	mov	r5, r2
    /* suspend thread */
    rt_thread_suspend(thread);
 8002498:	4608      	mov	r0, r1
 800249a:	f7fe fd8d 	bl	8000fb8 <rt_thread_suspend>

    switch (flag)
 800249e:	b13d      	cbz	r5, 80024b0 <_ipc_list_suspend+0x20>
 80024a0:	2d01      	cmp	r5, #1
 80024a2:	d00f      	beq.n	80024c4 <_ipc_list_suspend+0x34>
                rt_list_insert_before(list, &(thread->tlist));
        }
        break;/* RT_IPC_FLAG_PRIO */

    default:
        RT_ASSERT(0);
 80024a4:	22a4      	movs	r2, #164	@ 0xa4
 80024a6:	4916      	ldr	r1, [pc, #88]	@ (8002500 <_ipc_list_suspend+0x70>)
 80024a8:	4816      	ldr	r0, [pc, #88]	@ (8002504 <_ipc_list_suspend+0x74>)
 80024aa:	f7ff fd7d 	bl	8001fa8 <rt_assert_handler>
        break;
 80024ae:	e007      	b.n	80024c0 <_ipc_list_suspend+0x30>
        rt_list_insert_before(list, &(thread->tlist));
 80024b0:	f104 0314 	add.w	r3, r4, #20
    l->prev->next = n;
 80024b4:	6872      	ldr	r2, [r6, #4]
 80024b6:	6013      	str	r3, [r2, #0]
    n->prev = l->prev;
 80024b8:	6872      	ldr	r2, [r6, #4]
 80024ba:	61a2      	str	r2, [r4, #24]
    l->prev = n;
 80024bc:	6073      	str	r3, [r6, #4]
    n->next = l;
 80024be:	6166      	str	r6, [r4, #20]
    }

    return RT_EOK;
}
 80024c0:	2000      	movs	r0, #0
 80024c2:	bd70      	pop	{r4, r5, r6, pc}
            for (n = list->next; n != list; n = n->next)
 80024c4:	6833      	ldr	r3, [r6, #0]
 80024c6:	42b3      	cmp	r3, r6
 80024c8:	d00f      	beq.n	80024ea <_ipc_list_suspend+0x5a>
                if (thread->current_priority < sthread->current_priority)
 80024ca:	f894 1035 	ldrb.w	r1, [r4, #53]	@ 0x35
 80024ce:	f893 2021 	ldrb.w	r2, [r3, #33]	@ 0x21
 80024d2:	4291      	cmp	r1, r2
 80024d4:	d301      	bcc.n	80024da <_ipc_list_suspend+0x4a>
            for (n = list->next; n != list; n = n->next)
 80024d6:	681b      	ldr	r3, [r3, #0]
 80024d8:	e7f5      	b.n	80024c6 <_ipc_list_suspend+0x36>
                    rt_list_insert_before(&(sthread->tlist), &(thread->tlist));
 80024da:	f104 0214 	add.w	r2, r4, #20
    l->prev->next = n;
 80024de:	6859      	ldr	r1, [r3, #4]
 80024e0:	600a      	str	r2, [r1, #0]
    n->prev = l->prev;
 80024e2:	6859      	ldr	r1, [r3, #4]
 80024e4:	61a1      	str	r1, [r4, #24]
    l->prev = n;
 80024e6:	605a      	str	r2, [r3, #4]
    n->next = l;
 80024e8:	6163      	str	r3, [r4, #20]
            if (n == list)
 80024ea:	42b3      	cmp	r3, r6
 80024ec:	d1e8      	bne.n	80024c0 <_ipc_list_suspend+0x30>
                rt_list_insert_before(list, &(thread->tlist));
 80024ee:	f104 0314 	add.w	r3, r4, #20
    l->prev->next = n;
 80024f2:	6872      	ldr	r2, [r6, #4]
 80024f4:	6013      	str	r3, [r2, #0]
    n->prev = l->prev;
 80024f6:	6872      	ldr	r2, [r6, #4]
 80024f8:	61a2      	str	r2, [r4, #24]
    l->prev = n;
 80024fa:	6073      	str	r3, [r6, #4]
    n->next = l;
 80024fc:	6166      	str	r6, [r4, #20]
}
 80024fe:	e7df      	b.n	80024c0 <_ipc_list_suspend+0x30>
 8002500:	08009244 	.word	0x08009244
 8002504:	080087a4 	.word	0x080087a4

08002508 <rt_mutex_init>:
 *           If the return value is any other values, it represents the initialization failed.
 *
 * @warning  This function can ONLY be called from threads.
 */
rt_err_t rt_mutex_init(rt_mutex_t mutex, const char *name, rt_uint8_t flag)
{
 8002508:	b538      	push	{r3, r4, r5, lr}
 800250a:	460d      	mov	r5, r1
    /* flag parameter has been obsoleted */
    RT_UNUSED(flag);

    /* parameter check */
    RT_ASSERT(mutex != RT_NULL);
 800250c:	4604      	mov	r4, r0
 800250e:	b188      	cbz	r0, 8002534 <rt_mutex_init+0x2c>

    /* initialize object */
    rt_object_init(&(mutex->parent.parent), RT_Object_Class_Mutex, name);
 8002510:	462a      	mov	r2, r5
 8002512:	2103      	movs	r1, #3
 8002514:	4620      	mov	r0, r4
 8002516:	f7ff f901 	bl	800171c <rt_object_init>
    rt_list_init(&(ipc->suspend_thread));
 800251a:	f104 0314 	add.w	r3, r4, #20
    l->next = l->prev = l;
 800251e:	61a3      	str	r3, [r4, #24]
 8002520:	6163      	str	r3, [r4, #20]

    /* initialize ipc object */
    _ipc_object_init(&(mutex->parent));

    mutex->value = 1;
 8002522:	2301      	movs	r3, #1
 8002524:	83a3      	strh	r3, [r4, #28]
    mutex->owner = RT_NULL;
 8002526:	2000      	movs	r0, #0
 8002528:	6220      	str	r0, [r4, #32]
    mutex->original_priority = 0xFF;
 800252a:	22ff      	movs	r2, #255	@ 0xff
 800252c:	77a2      	strb	r2, [r4, #30]
    mutex->hold  = 0;
 800252e:	77e0      	strb	r0, [r4, #31]

    /* flag can only be RT_IPC_FLAG_PRIO. RT_IPC_FLAG_FIFO cannot solve the unbounded priority inversion problem */
    mutex->parent.parent.flag = RT_IPC_FLAG_PRIO;
 8002530:	7263      	strb	r3, [r4, #9]

    return RT_EOK;
}
 8002532:	bd38      	pop	{r3, r4, r5, pc}
    RT_ASSERT(mutex != RT_NULL);
 8002534:	f240 22eb 	movw	r2, #747	@ 0x2eb
 8002538:	4902      	ldr	r1, [pc, #8]	@ (8002544 <rt_mutex_init+0x3c>)
 800253a:	4803      	ldr	r0, [pc, #12]	@ (8002548 <rt_mutex_init+0x40>)
 800253c:	f7ff fd34 	bl	8001fa8 <rt_assert_handler>
 8002540:	e7e6      	b.n	8002510 <rt_mutex_init+0x8>
 8002542:	bf00      	nop
 8002544:	08009234 	.word	0x08009234
 8002548:	08008cdc 	.word	0x08008cdc

0800254c <rt_mutex_take>:
 *           If the return value is any other values, it means that the mutex take failed.
 *
 * @warning  This function can ONLY be called in the thread context. It MUST NOT BE called in interrupt context.
 */
rt_err_t rt_mutex_take(rt_mutex_t mutex, rt_int32_t timeout)
{
 800254c:	e92d 41f0 	stmdb	sp!, {r4, r5, r6, r7, r8, lr}
 8002550:	b082      	sub	sp, #8
 8002552:	4604      	mov	r4, r0
 8002554:	9101      	str	r1, [sp, #4]
    rt_base_t level;
    struct rt_thread *thread;

    /* this function must not be used in interrupt even if time = 0 */
    /* current context checking */
    RT_DEBUG_SCHEDULER_AVAILABLE(RT_TRUE);
 8002556:	f7fd fe79 	bl	800024c <rt_hw_interrupt_disable>
 800255a:	4607      	mov	r7, r0
 800255c:	f000 fadc 	bl	8002b18 <rt_critical_level>
 8002560:	2800      	cmp	r0, #0
 8002562:	d13d      	bne.n	80025e0 <rt_mutex_take+0x94>
 8002564:	f7fd fe72 	bl	800024c <rt_hw_interrupt_disable>
 8002568:	4605      	mov	r5, r0
 800256a:	f7fe fc51 	bl	8000e10 <rt_thread_self>
 800256e:	2800      	cmp	r0, #0
 8002570:	d042      	beq.n	80025f8 <rt_mutex_take+0xac>
 8002572:	f7fd fe6b 	bl	800024c <rt_hw_interrupt_disable>
 8002576:	4606      	mov	r6, r0
 8002578:	f7ff f9f0 	bl	800195c <rt_interrupt_get_nest>
 800257c:	2800      	cmp	r0, #0
 800257e:	d147      	bne.n	8002610 <rt_mutex_take+0xc4>
 8002580:	4630      	mov	r0, r6
 8002582:	f7fd fe67 	bl	8000254 <rt_hw_interrupt_enable>
 8002586:	4628      	mov	r0, r5
 8002588:	f7fd fe64 	bl	8000254 <rt_hw_interrupt_enable>
 800258c:	4638      	mov	r0, r7
 800258e:	f7fd fe61 	bl	8000254 <rt_hw_interrupt_enable>

    /* parameter check */
    RT_ASSERT(mutex != RT_NULL);
 8002592:	2c00      	cmp	r4, #0
 8002594:	d049      	beq.n	800262a <rt_mutex_take+0xde>
    RT_ASSERT(rt_object_get_type(&mutex->parent.parent) == RT_Object_Class_Mutex);
 8002596:	4620      	mov	r0, r4
 8002598:	f7ff f9b2 	bl	8001900 <rt_object_get_type>
 800259c:	2803      	cmp	r0, #3
 800259e:	d14b      	bne.n	8002638 <rt_mutex_take+0xec>

    /* get current thread */
    thread = rt_thread_self();
 80025a0:	f7fe fc36 	bl	8000e10 <rt_thread_self>
 80025a4:	4605      	mov	r5, r0

    /* disable interrupt */
    level = rt_hw_interrupt_disable();
 80025a6:	f7fd fe51 	bl	800024c <rt_hw_interrupt_disable>
 80025aa:	4606      	mov	r6, r0
    RT_DEBUG_LOG(RT_DEBUG_IPC,
                 ("mutex_take: current thread %s, mutex value: %d, hold: %d\n",
                  thread->name, mutex->value, mutex->hold));

    /* reset thread error */
    thread->error = RT_EOK;
 80025ac:	2300      	movs	r3, #0
 80025ae:	632b      	str	r3, [r5, #48]	@ 0x30

    if (mutex->owner == thread)
 80025b0:	6a20      	ldr	r0, [r4, #32]
 80025b2:	42a8      	cmp	r0, r5
 80025b4:	d047      	beq.n	8002646 <rt_mutex_take+0xfa>
    else
    {
        /* The value of mutex is 1 in initial status. Therefore, if the
         * value is great than 0, it indicates the mutex is avaible.
         */
        if (mutex->value > 0)
 80025b6:	8ba3      	ldrh	r3, [r4, #28]
 80025b8:	2b00      	cmp	r3, #0
 80025ba:	d056      	beq.n	800266a <rt_mutex_take+0x11e>
        {
            /* mutex is available */
            mutex->value --;
 80025bc:	3b01      	subs	r3, #1
 80025be:	83a3      	strh	r3, [r4, #28]

            /* set mutex owner and original priority */
            mutex->owner             = thread;
 80025c0:	6225      	str	r5, [r4, #32]
            mutex->original_priority = thread->current_priority;
 80025c2:	f895 3035 	ldrb.w	r3, [r5, #53]	@ 0x35
 80025c6:	77a3      	strb	r3, [r4, #30]
            if(mutex->hold < RT_MUTEX_HOLD_MAX)
 80025c8:	7fe3      	ldrb	r3, [r4, #31]
 80025ca:	2bff      	cmp	r3, #255	@ 0xff
 80025cc:	d047      	beq.n	800265e <rt_mutex_take+0x112>
            {
                mutex->hold ++;
 80025ce:	3301      	adds	r3, #1
 80025d0:	77e3      	strb	r3, [r4, #31]
            }
        }
    }

    /* enable interrupt */
    rt_hw_interrupt_enable(level);
 80025d2:	4630      	mov	r0, r6
 80025d4:	f7fd fe3e 	bl	8000254 <rt_hw_interrupt_enable>

    RT_OBJECT_HOOK_CALL(rt_object_take_hook, (&(mutex->parent.parent)));

    return RT_EOK;
 80025d8:	2000      	movs	r0, #0
}
 80025da:	b002      	add	sp, #8
 80025dc:	e8bd 81f0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, pc}
    RT_DEBUG_SCHEDULER_AVAILABLE(RT_TRUE);
 80025e0:	4d3d      	ldr	r5, [pc, #244]	@ (80026d8 <rt_mutex_take+0x18c>)
 80025e2:	4629      	mov	r1, r5
 80025e4:	483d      	ldr	r0, [pc, #244]	@ (80026dc <rt_mutex_take+0x190>)
 80025e6:	f7ff fc7f 	bl	8001ee8 <rt_kprintf>
 80025ea:	f240 3299 	movw	r2, #921	@ 0x399
 80025ee:	4629      	mov	r1, r5
 80025f0:	483b      	ldr	r0, [pc, #236]	@ (80026e0 <rt_mutex_take+0x194>)
 80025f2:	f7ff fcd9 	bl	8001fa8 <rt_assert_handler>
 80025f6:	e7b5      	b.n	8002564 <rt_mutex_take+0x18>
 80025f8:	4e37      	ldr	r6, [pc, #220]	@ (80026d8 <rt_mutex_take+0x18c>)
 80025fa:	4631      	mov	r1, r6
 80025fc:	4839      	ldr	r0, [pc, #228]	@ (80026e4 <rt_mutex_take+0x198>)
 80025fe:	f7ff fc73 	bl	8001ee8 <rt_kprintf>
 8002602:	f240 3299 	movw	r2, #921	@ 0x399
 8002606:	4631      	mov	r1, r6
 8002608:	4835      	ldr	r0, [pc, #212]	@ (80026e0 <rt_mutex_take+0x194>)
 800260a:	f7ff fccd 	bl	8001fa8 <rt_assert_handler>
 800260e:	e7b0      	b.n	8002572 <rt_mutex_take+0x26>
 8002610:	f8df 80c4 	ldr.w	r8, [pc, #196]	@ 80026d8 <rt_mutex_take+0x18c>
 8002614:	4641      	mov	r1, r8
 8002616:	4834      	ldr	r0, [pc, #208]	@ (80026e8 <rt_mutex_take+0x19c>)
 8002618:	f7ff fc66 	bl	8001ee8 <rt_kprintf>
 800261c:	f240 3299 	movw	r2, #921	@ 0x399
 8002620:	4641      	mov	r1, r8
 8002622:	482f      	ldr	r0, [pc, #188]	@ (80026e0 <rt_mutex_take+0x194>)
 8002624:	f7ff fcc0 	bl	8001fa8 <rt_assert_handler>
 8002628:	e7aa      	b.n	8002580 <rt_mutex_take+0x34>
    RT_ASSERT(mutex != RT_NULL);
 800262a:	f44f 7267 	mov.w	r2, #924	@ 0x39c
 800262e:	492a      	ldr	r1, [pc, #168]	@ (80026d8 <rt_mutex_take+0x18c>)
 8002630:	482e      	ldr	r0, [pc, #184]	@ (80026ec <rt_mutex_take+0x1a0>)
 8002632:	f7ff fcb9 	bl	8001fa8 <rt_assert_handler>
 8002636:	e7ae      	b.n	8002596 <rt_mutex_take+0x4a>
    RT_ASSERT(rt_object_get_type(&mutex->parent.parent) == RT_Object_Class_Mutex);
 8002638:	f240 329d 	movw	r2, #925	@ 0x39d
 800263c:	4926      	ldr	r1, [pc, #152]	@ (80026d8 <rt_mutex_take+0x18c>)
 800263e:	482c      	ldr	r0, [pc, #176]	@ (80026f0 <rt_mutex_take+0x1a4>)
 8002640:	f7ff fcb2 	bl	8001fa8 <rt_assert_handler>
 8002644:	e7ac      	b.n	80025a0 <rt_mutex_take+0x54>
        if(mutex->hold < RT_MUTEX_HOLD_MAX)
 8002646:	7fe3      	ldrb	r3, [r4, #31]
 8002648:	2bff      	cmp	r3, #255	@ 0xff
 800264a:	d002      	beq.n	8002652 <rt_mutex_take+0x106>
            mutex->hold ++;
 800264c:	3301      	adds	r3, #1
 800264e:	77e3      	strb	r3, [r4, #31]
 8002650:	e7bf      	b.n	80025d2 <rt_mutex_take+0x86>
            rt_hw_interrupt_enable(level); /* enable interrupt */
 8002652:	4630      	mov	r0, r6
 8002654:	f7fd fdfe 	bl	8000254 <rt_hw_interrupt_enable>
            return -RT_EFULL; /* value overflowed */
 8002658:	f06f 0002 	mvn.w	r0, #2
 800265c:	e7bd      	b.n	80025da <rt_mutex_take+0x8e>
                rt_hw_interrupt_enable(level); /* enable interrupt */
 800265e:	4630      	mov	r0, r6
 8002660:	f7fd fdf8 	bl	8000254 <rt_hw_interrupt_enable>
                return -RT_EFULL; /* value overflowed */
 8002664:	f06f 0002 	mvn.w	r0, #2
 8002668:	e7b7      	b.n	80025da <rt_mutex_take+0x8e>
            if (timeout == 0)
 800266a:	9b01      	ldr	r3, [sp, #4]
 800266c:	b1d3      	cbz	r3, 80026a4 <rt_mutex_take+0x158>
                if (thread->current_priority < mutex->owner->current_priority)
 800266e:	f895 2035 	ldrb.w	r2, [r5, #53]	@ 0x35
 8002672:	f890 3035 	ldrb.w	r3, [r0, #53]	@ 0x35
 8002676:	429a      	cmp	r2, r3
 8002678:	d31c      	bcc.n	80026b4 <rt_mutex_take+0x168>
                _ipc_list_suspend(&(mutex->parent.suspend_thread),
 800267a:	7a62      	ldrb	r2, [r4, #9]
 800267c:	4629      	mov	r1, r5
 800267e:	f104 0014 	add.w	r0, r4, #20
 8002682:	f7ff ff05 	bl	8002490 <_ipc_list_suspend>
                if (timeout > 0)
 8002686:	9b01      	ldr	r3, [sp, #4]
 8002688:	2b00      	cmp	r3, #0
 800268a:	dc19      	bgt.n	80026c0 <rt_mutex_take+0x174>
                rt_hw_interrupt_enable(level);
 800268c:	4630      	mov	r0, r6
 800268e:	f7fd fde1 	bl	8000254 <rt_hw_interrupt_enable>
                rt_schedule();
 8002692:	f000 f99d 	bl	80029d0 <rt_schedule>
                if (thread->error != RT_EOK)
 8002696:	6b28      	ldr	r0, [r5, #48]	@ 0x30
 8002698:	2800      	cmp	r0, #0
 800269a:	d19e      	bne.n	80025da <rt_mutex_take+0x8e>
                    level = rt_hw_interrupt_disable();
 800269c:	f7fd fdd6 	bl	800024c <rt_hw_interrupt_disable>
 80026a0:	4606      	mov	r6, r0
 80026a2:	e796      	b.n	80025d2 <rt_mutex_take+0x86>
                thread->error = -RT_ETIMEOUT;
 80026a4:	f06f 0401 	mvn.w	r4, #1
 80026a8:	632c      	str	r4, [r5, #48]	@ 0x30
                rt_hw_interrupt_enable(level);
 80026aa:	4630      	mov	r0, r6
 80026ac:	f7fd fdd2 	bl	8000254 <rt_hw_interrupt_enable>
                return -RT_ETIMEOUT;
 80026b0:	4620      	mov	r0, r4
 80026b2:	e792      	b.n	80025da <rt_mutex_take+0x8e>
                    rt_thread_control(mutex->owner,
 80026b4:	f105 0235 	add.w	r2, r5, #53	@ 0x35
 80026b8:	2102      	movs	r1, #2
 80026ba:	f7fe fd41 	bl	8001140 <rt_thread_control>
 80026be:	e7dc      	b.n	800267a <rt_mutex_take+0x12e>
                    rt_timer_control(&(thread->thread_timer),
 80026c0:	f105 044c 	add.w	r4, r5, #76	@ 0x4c
 80026c4:	aa01      	add	r2, sp, #4
 80026c6:	2100      	movs	r1, #0
 80026c8:	4620      	mov	r0, r4
 80026ca:	f7fe ff5b 	bl	8001584 <rt_timer_control>
                    rt_timer_start(&(thread->thread_timer));
 80026ce:	4620      	mov	r0, r4
 80026d0:	f7fe febc 	bl	800144c <rt_timer_start>
 80026d4:	e7da      	b.n	800268c <rt_mutex_take+0x140>
 80026d6:	bf00      	nop
 80026d8:	08009224 	.word	0x08009224
 80026dc:	08008c78 	.word	0x08008c78
 80026e0:	080087a4 	.word	0x080087a4
 80026e4:	08008ca4 	.word	0x08008ca4
 80026e8:	0800877c 	.word	0x0800877c
 80026ec:	08008cdc 	.word	0x08008cdc
 80026f0:	08008cf0 	.word	0x08008cf0

080026f4 <rt_mutex_release>:
 *
 * @return   Return the operation status. When the return value is RT_EOK, the operation is successful.
 *           If the return value is any other values, it means that the mutex release failed.
 */
rt_err_t rt_mutex_release(rt_mutex_t mutex)
{
 80026f4:	b5f8      	push	{r3, r4, r5, r6, r7, lr}
    rt_base_t level;
    struct rt_thread *thread;
    rt_bool_t need_schedule;

    /* parameter check */
    RT_ASSERT(mutex != RT_NULL);
 80026f6:	4604      	mov	r4, r0
 80026f8:	2800      	cmp	r0, #0
 80026fa:	d046      	beq.n	800278a <rt_mutex_release+0x96>
    RT_ASSERT(rt_object_get_type(&mutex->parent.parent) == RT_Object_Class_Mutex);
 80026fc:	4620      	mov	r0, r4
 80026fe:	f7ff f8ff 	bl	8001900 <rt_object_get_type>
 8002702:	2803      	cmp	r0, #3
 8002704:	d148      	bne.n	8002798 <rt_mutex_release+0xa4>

    need_schedule = RT_FALSE;

    /* only thread could release mutex because we need test the ownership */
    RT_DEBUG_IN_THREAD_CONTEXT;
 8002706:	f7fd fda1 	bl	800024c <rt_hw_interrupt_disable>
 800270a:	4605      	mov	r5, r0
 800270c:	f7fe fb80 	bl	8000e10 <rt_thread_self>
 8002710:	2800      	cmp	r0, #0
 8002712:	d048      	beq.n	80027a6 <rt_mutex_release+0xb2>
 8002714:	f7fd fd9a 	bl	800024c <rt_hw_interrupt_disable>
 8002718:	4606      	mov	r6, r0
 800271a:	f7ff f91f 	bl	800195c <rt_interrupt_get_nest>
 800271e:	2800      	cmp	r0, #0
 8002720:	d14d      	bne.n	80027be <rt_mutex_release+0xca>
 8002722:	4630      	mov	r0, r6
 8002724:	f7fd fd96 	bl	8000254 <rt_hw_interrupt_enable>
 8002728:	4628      	mov	r0, r5
 800272a:	f7fd fd93 	bl	8000254 <rt_hw_interrupt_enable>

    /* get current thread */
    thread = rt_thread_self();
 800272e:	f7fe fb6f 	bl	8000e10 <rt_thread_self>
 8002732:	4605      	mov	r5, r0

    /* disable interrupt */
    level = rt_hw_interrupt_disable();
 8002734:	f7fd fd8a 	bl	800024c <rt_hw_interrupt_disable>
 8002738:	4606      	mov	r6, r0
                  thread->name, mutex->value, mutex->hold));

    RT_OBJECT_HOOK_CALL(rt_object_put_hook, (&(mutex->parent.parent)));

    /* mutex only can be released by owner */
    if (thread != mutex->owner)
 800273a:	6a20      	ldr	r0, [r4, #32]
 800273c:	42a8      	cmp	r0, r5
 800273e:	d14a      	bne.n	80027d6 <rt_mutex_release+0xe2>

        return -RT_ERROR;
    }

    /* decrease hold */
    mutex->hold --;
 8002740:	7fe3      	ldrb	r3, [r4, #31]
 8002742:	3b01      	subs	r3, #1
 8002744:	b2db      	uxtb	r3, r3
 8002746:	77e3      	strb	r3, [r4, #31]
    /* if no hold */
    if (mutex->hold == 0)
 8002748:	2b00      	cmp	r3, #0
 800274a:	d16a      	bne.n	8002822 <rt_mutex_release+0x12e>
    {
        /* change the owner thread to original priority */
        if (mutex->original_priority != mutex->owner->current_priority)
 800274c:	7fa2      	ldrb	r2, [r4, #30]
 800274e:	f890 3035 	ldrb.w	r3, [r0, #53]	@ 0x35
 8002752:	429a      	cmp	r2, r3
 8002754:	d146      	bne.n	80027e4 <rt_mutex_release+0xf0>
                              RT_THREAD_CTRL_CHANGE_PRIORITY,
                              &(mutex->original_priority));
        }

        /* wakeup suspended thread */
        if (!rt_list_isempty(&mutex->parent.suspend_thread))
 8002756:	f104 0314 	add.w	r3, r4, #20
    return l->next == l;
 800275a:	6962      	ldr	r2, [r4, #20]
 800275c:	4293      	cmp	r3, r2
 800275e:	d04d      	beq.n	80027fc <rt_mutex_release+0x108>
        {
            /* get suspended thread */
            thread = rt_list_entry(mutex->parent.suspend_thread.next,
 8002760:	f1a2 0014 	sub.w	r0, r2, #20

            RT_DEBUG_LOG(RT_DEBUG_IPC, ("mutex_release: resume thread: %s\n",
                                        thread->name));

            /* set new owner and priority */
            mutex->owner             = thread;
 8002764:	6220      	str	r0, [r4, #32]
            mutex->original_priority = thread->current_priority;
 8002766:	f892 3021 	ldrb.w	r3, [r2, #33]	@ 0x21
 800276a:	77a3      	strb	r3, [r4, #30]

            if(mutex->hold < RT_MUTEX_HOLD_MAX)
 800276c:	7fe3      	ldrb	r3, [r4, #31]
 800276e:	2bff      	cmp	r3, #255	@ 0xff
 8002770:	d03e      	beq.n	80027f0 <rt_mutex_release+0xfc>
            {
                mutex->hold ++;
 8002772:	3301      	adds	r3, #1
 8002774:	77e3      	strb	r3, [r4, #31]
    rt_thread_resume(thread);
 8002776:	f7fe fc69 	bl	800104c <rt_thread_resume>
            }

            /* resume thread */
            _ipc_list_resume(&(mutex->parent.suspend_thread));

            need_schedule = RT_TRUE;
 800277a:	2401      	movs	r4, #1
            mutex->original_priority = 0xff;
        }
    }

    /* enable interrupt */
    rt_hw_interrupt_enable(level);
 800277c:	4630      	mov	r0, r6
 800277e:	f7fd fd69 	bl	8000254 <rt_hw_interrupt_enable>

    /* perform a schedule */
    if (need_schedule == RT_TRUE)
 8002782:	2c01      	cmp	r4, #1
 8002784:	d04f      	beq.n	8002826 <rt_mutex_release+0x132>
        rt_schedule();

    return RT_EOK;
}
 8002786:	4620      	mov	r0, r4
 8002788:	bdf8      	pop	{r3, r4, r5, r6, r7, pc}
    RT_ASSERT(mutex != RT_NULL);
 800278a:	f240 4249 	movw	r2, #1097	@ 0x449
 800278e:	4928      	ldr	r1, [pc, #160]	@ (8002830 <rt_mutex_release+0x13c>)
 8002790:	4828      	ldr	r0, [pc, #160]	@ (8002834 <rt_mutex_release+0x140>)
 8002792:	f7ff fc09 	bl	8001fa8 <rt_assert_handler>
 8002796:	e7b1      	b.n	80026fc <rt_mutex_release+0x8>
    RT_ASSERT(rt_object_get_type(&mutex->parent.parent) == RT_Object_Class_Mutex);
 8002798:	f240 424a 	movw	r2, #1098	@ 0x44a
 800279c:	4924      	ldr	r1, [pc, #144]	@ (8002830 <rt_mutex_release+0x13c>)
 800279e:	4826      	ldr	r0, [pc, #152]	@ (8002838 <rt_mutex_release+0x144>)
 80027a0:	f7ff fc02 	bl	8001fa8 <rt_assert_handler>
 80027a4:	e7af      	b.n	8002706 <rt_mutex_release+0x12>
    RT_DEBUG_IN_THREAD_CONTEXT;
 80027a6:	4e22      	ldr	r6, [pc, #136]	@ (8002830 <rt_mutex_release+0x13c>)
 80027a8:	4631      	mov	r1, r6
 80027aa:	4824      	ldr	r0, [pc, #144]	@ (800283c <rt_mutex_release+0x148>)
 80027ac:	f7ff fb9c 	bl	8001ee8 <rt_kprintf>
 80027b0:	f240 424f 	movw	r2, #1103	@ 0x44f
 80027b4:	4631      	mov	r1, r6
 80027b6:	4822      	ldr	r0, [pc, #136]	@ (8002840 <rt_mutex_release+0x14c>)
 80027b8:	f7ff fbf6 	bl	8001fa8 <rt_assert_handler>
 80027bc:	e7aa      	b.n	8002714 <rt_mutex_release+0x20>
 80027be:	4f1c      	ldr	r7, [pc, #112]	@ (8002830 <rt_mutex_release+0x13c>)
 80027c0:	4639      	mov	r1, r7
 80027c2:	4820      	ldr	r0, [pc, #128]	@ (8002844 <rt_mutex_release+0x150>)
 80027c4:	f7ff fb90 	bl	8001ee8 <rt_kprintf>
 80027c8:	f240 424f 	movw	r2, #1103	@ 0x44f
 80027cc:	4639      	mov	r1, r7
 80027ce:	481c      	ldr	r0, [pc, #112]	@ (8002840 <rt_mutex_release+0x14c>)
 80027d0:	f7ff fbea 	bl	8001fa8 <rt_assert_handler>
 80027d4:	e7a5      	b.n	8002722 <rt_mutex_release+0x2e>
        thread->error = -RT_ERROR;
 80027d6:	f04f 34ff 	mov.w	r4, #4294967295	@ 0xffffffff
 80027da:	632c      	str	r4, [r5, #48]	@ 0x30
        rt_hw_interrupt_enable(level);
 80027dc:	4630      	mov	r0, r6
 80027de:	f7fd fd39 	bl	8000254 <rt_hw_interrupt_enable>
        return -RT_ERROR;
 80027e2:	e7d0      	b.n	8002786 <rt_mutex_release+0x92>
            rt_thread_control(mutex->owner,
 80027e4:	f104 021e 	add.w	r2, r4, #30
 80027e8:	2102      	movs	r1, #2
 80027ea:	f7fe fca9 	bl	8001140 <rt_thread_control>
 80027ee:	e7b2      	b.n	8002756 <rt_mutex_release+0x62>
                rt_hw_interrupt_enable(level); /* enable interrupt */
 80027f0:	4630      	mov	r0, r6
 80027f2:	f7fd fd2f 	bl	8000254 <rt_hw_interrupt_enable>
                return -RT_EFULL; /* value overflowed */
 80027f6:	f06f 0402 	mvn.w	r4, #2
 80027fa:	e7c4      	b.n	8002786 <rt_mutex_release+0x92>
            if(mutex->value < RT_MUTEX_VALUE_MAX)
 80027fc:	8ba3      	ldrh	r3, [r4, #28]
 80027fe:	f64f 72ff 	movw	r2, #65535	@ 0xffff
 8002802:	4293      	cmp	r3, r2
 8002804:	d007      	beq.n	8002816 <rt_mutex_release+0x122>
                mutex->value ++;
 8002806:	3301      	adds	r3, #1
 8002808:	83a3      	strh	r3, [r4, #28]
            mutex->owner             = RT_NULL;
 800280a:	2300      	movs	r3, #0
 800280c:	6223      	str	r3, [r4, #32]
            mutex->original_priority = 0xff;
 800280e:	22ff      	movs	r2, #255	@ 0xff
 8002810:	77a2      	strb	r2, [r4, #30]
    need_schedule = RT_FALSE;
 8002812:	461c      	mov	r4, r3
 8002814:	e7b2      	b.n	800277c <rt_mutex_release+0x88>
                rt_hw_interrupt_enable(level); /* enable interrupt */
 8002816:	4630      	mov	r0, r6
 8002818:	f7fd fd1c 	bl	8000254 <rt_hw_interrupt_enable>
                return -RT_EFULL; /* value overflowed */
 800281c:	f06f 0402 	mvn.w	r4, #2
 8002820:	e7b1      	b.n	8002786 <rt_mutex_release+0x92>
    need_schedule = RT_FALSE;
 8002822:	2400      	movs	r4, #0
 8002824:	e7aa      	b.n	800277c <rt_mutex_release+0x88>
        rt_schedule();
 8002826:	f000 f8d3 	bl	80029d0 <rt_schedule>
    return RT_EOK;
 800282a:	2400      	movs	r4, #0
 800282c:	e7ab      	b.n	8002786 <rt_mutex_release+0x92>
 800282e:	bf00      	nop
 8002830:	08009210 	.word	0x08009210
 8002834:	08008cdc 	.word	0x08008cdc
 8002838:	08008cf0 	.word	0x08008cf0
 800283c:	08008ca4 	.word	0x08008ca4
 8002840:	080087a4 	.word	0x080087a4
 8002844:	0800877c 	.word	0x0800877c

08002848 <_scheduler_get_highest_priority_thread>:

    return highest_priority_thread;
}
#else
static struct rt_thread *_scheduler_get_highest_priority_thread(rt_ubase_t *highest_prio)
{
 8002848:	b510      	push	{r4, lr}
 800284a:	4604      	mov	r4, r0
    rt_ubase_t number;

    number = __rt_ffs(rt_thread_ready_priority_group) - 1;
    highest_ready_priority = (number << 3) + __rt_ffs(rt_thread_ready_table[number]) - 1;
#else
    highest_ready_priority = __rt_ffs(rt_thread_ready_priority_group) - 1;
 800284c:	4b05      	ldr	r3, [pc, #20]	@ (8002864 <_scheduler_get_highest_priority_thread+0x1c>)
 800284e:	6818      	ldr	r0, [r3, #0]
 8002850:	f7ff fb88 	bl	8001f64 <__rt_ffs>
 8002854:	1e43      	subs	r3, r0, #1
#endif /* RT_THREAD_PRIORITY_MAX > 32 */

    /* get highest ready priority thread */
    highest_priority_thread = rt_list_entry(rt_thread_priority_table[highest_ready_priority].next,
 8002856:	4a04      	ldr	r2, [pc, #16]	@ (8002868 <_scheduler_get_highest_priority_thread+0x20>)
 8002858:	f852 0033 	ldr.w	r0, [r2, r3, lsl #3]
                                            struct rt_thread,
                                            tlist);

    *highest_prio = highest_ready_priority;
 800285c:	6023      	str	r3, [r4, #0]

    return highest_priority_thread;
}
 800285e:	3814      	subs	r0, #20
 8002860:	bd10      	pop	{r4, pc}
 8002862:	bf00      	nop
 8002864:	20000214 	.word	0x20000214
 8002868:	20000218 	.word	0x20000218

0800286c <rt_system_scheduler_init>:
    int cpu;
#endif /* RT_USING_SMP */
    rt_base_t offset;

#ifndef RT_USING_SMP
    rt_scheduler_lock_nest = 0;
 800286c:	2300      	movs	r3, #0
 800286e:	4a08      	ldr	r2, [pc, #32]	@ (8002890 <rt_system_scheduler_init+0x24>)
 8002870:	8013      	strh	r3, [r2, #0]
#endif /* RT_USING_SMP */

    RT_DEBUG_LOG(RT_DEBUG_SCHEDULER, ("start scheduler: max priority 0x%02x\n",
                                      RT_THREAD_PRIORITY_MAX));

    for (offset = 0; offset < RT_THREAD_PRIORITY_MAX; offset++)
 8002872:	e006      	b.n	8002882 <rt_system_scheduler_init+0x16>
    {
        rt_list_init(&rt_thread_priority_table[offset]);
 8002874:	4907      	ldr	r1, [pc, #28]	@ (8002894 <rt_system_scheduler_init+0x28>)
 8002876:	eb01 02c3 	add.w	r2, r1, r3, lsl #3
    l->next = l->prev = l;
 800287a:	6052      	str	r2, [r2, #4]
 800287c:	f841 2033 	str.w	r2, [r1, r3, lsl #3]
    for (offset = 0; offset < RT_THREAD_PRIORITY_MAX; offset++)
 8002880:	3301      	adds	r3, #1
 8002882:	2b1f      	cmp	r3, #31
 8002884:	ddf6      	ble.n	8002874 <rt_system_scheduler_init+0x8>
#endif /* RT_THREAD_PRIORITY_MAX > 32 */
    }
#endif /* RT_USING_SMP */

    /* initialize ready priority group */
    rt_thread_ready_priority_group = 0;
 8002886:	4b04      	ldr	r3, [pc, #16]	@ (8002898 <rt_system_scheduler_init+0x2c>)
 8002888:	2200      	movs	r2, #0
 800288a:	601a      	str	r2, [r3, #0]

#if RT_THREAD_PRIORITY_MAX > 32
    /* initialize ready table */
    rt_memset(rt_thread_ready_table, 0, sizeof(rt_thread_ready_table));
#endif /* RT_THREAD_PRIORITY_MAX > 32 */
}
 800288c:	4770      	bx	lr
 800288e:	bf00      	nop
 8002890:	20000210 	.word	0x20000210
 8002894:	20000218 	.word	0x20000218
 8002898:	20000214 	.word	0x20000214

0800289c <rt_schedule_insert_thread>:
    /* enable interrupt */
    rt_hw_interrupt_enable(level);
}
#else
void rt_schedule_insert_thread(struct rt_thread *thread)
{
 800289c:	b570      	push	{r4, r5, r6, lr}
    rt_base_t level;

    RT_ASSERT(thread != RT_NULL);
 800289e:	4604      	mov	r4, r0
 80028a0:	b328      	cbz	r0, 80028ee <rt_schedule_insert_thread+0x52>

    /* disable interrupt */
    level = rt_hw_interrupt_disable();
 80028a2:	f7fd fcd3 	bl	800024c <rt_hw_interrupt_disable>

    /* it's current thread, it should be RUNNING thread */
    if (thread == rt_current_thread)
 80028a6:	4b22      	ldr	r3, [pc, #136]	@ (8002930 <rt_schedule_insert_thread+0x94>)
 80028a8:	681b      	ldr	r3, [r3, #0]
 80028aa:	42a3      	cmp	r3, r4
 80028ac:	d026      	beq.n	80028fc <rt_schedule_insert_thread+0x60>
        thread->stat = RT_THREAD_RUNNING | (thread->stat & ~RT_THREAD_STAT_MASK);
        goto __exit;
    }

    /* READY thread, insert to ready queue */
    thread->stat = RT_THREAD_READY | (thread->stat & ~RT_THREAD_STAT_MASK);
 80028ae:	f894 2034 	ldrb.w	r2, [r4, #52]	@ 0x34
 80028b2:	f022 0307 	bic.w	r3, r2, #7
 80028b6:	f043 0301 	orr.w	r3, r3, #1
 80028ba:	f884 3034 	strb.w	r3, [r4, #52]	@ 0x34
    /* there is no time slices left(YIELD), inserting thread before ready list*/
    if ((thread->stat & RT_THREAD_STAT_YIELD_MASK) != 0)
 80028be:	f012 0f08 	tst.w	r2, #8
 80028c2:	d024      	beq.n	800290e <rt_schedule_insert_thread+0x72>
    {
        rt_list_insert_before(&(rt_thread_priority_table[thread->current_priority]),
 80028c4:	f894 2035 	ldrb.w	r2, [r4, #53]	@ 0x35
 80028c8:	4b1a      	ldr	r3, [pc, #104]	@ (8002934 <rt_schedule_insert_thread+0x98>)
 80028ca:	eb03 03c2 	add.w	r3, r3, r2, lsl #3
 80028ce:	f104 0214 	add.w	r2, r4, #20
    l->prev->next = n;
 80028d2:	6859      	ldr	r1, [r3, #4]
 80028d4:	600a      	str	r2, [r1, #0]
    n->prev = l->prev;
 80028d6:	6859      	ldr	r1, [r3, #4]
 80028d8:	61a1      	str	r1, [r4, #24]
    l->prev = n;
 80028da:	605a      	str	r2, [r3, #4]
    n->next = l;
 80028dc:	6163      	str	r3, [r4, #20]

    /* set priority mask */
#if RT_THREAD_PRIORITY_MAX > 32
    rt_thread_ready_table[thread->number] |= thread->high_mask;
#endif /* RT_THREAD_PRIORITY_MAX > 32 */
    rt_thread_ready_priority_group |= thread->number_mask;
 80028de:	6ba1      	ldr	r1, [r4, #56]	@ 0x38
 80028e0:	4a15      	ldr	r2, [pc, #84]	@ (8002938 <rt_schedule_insert_thread+0x9c>)
 80028e2:	6813      	ldr	r3, [r2, #0]
 80028e4:	430b      	orrs	r3, r1
 80028e6:	6013      	str	r3, [r2, #0]

__exit:
    /* enable interrupt */
    rt_hw_interrupt_enable(level);
 80028e8:	f7fd fcb4 	bl	8000254 <rt_hw_interrupt_enable>
}
 80028ec:	bd70      	pop	{r4, r5, r6, pc}
    RT_ASSERT(thread != RT_NULL);
 80028ee:	f240 22e7 	movw	r2, #743	@ 0x2e7
 80028f2:	4912      	ldr	r1, [pc, #72]	@ (800293c <rt_schedule_insert_thread+0xa0>)
 80028f4:	4812      	ldr	r0, [pc, #72]	@ (8002940 <rt_schedule_insert_thread+0xa4>)
 80028f6:	f7ff fb57 	bl	8001fa8 <rt_assert_handler>
 80028fa:	e7d2      	b.n	80028a2 <rt_schedule_insert_thread+0x6>
        thread->stat = RT_THREAD_RUNNING | (thread->stat & ~RT_THREAD_STAT_MASK);
 80028fc:	f894 3034 	ldrb.w	r3, [r4, #52]	@ 0x34
 8002900:	f023 0307 	bic.w	r3, r3, #7
 8002904:	f043 0303 	orr.w	r3, r3, #3
 8002908:	f884 3034 	strb.w	r3, [r4, #52]	@ 0x34
        goto __exit;
 800290c:	e7ec      	b.n	80028e8 <rt_schedule_insert_thread+0x4c>
        rt_list_insert_after(&(rt_thread_priority_table[thread->current_priority]),
 800290e:	f894 2035 	ldrb.w	r2, [r4, #53]	@ 0x35
 8002912:	4b08      	ldr	r3, [pc, #32]	@ (8002934 <rt_schedule_insert_thread+0x98>)
 8002914:	eb03 05c2 	add.w	r5, r3, r2, lsl #3
 8002918:	f104 0114 	add.w	r1, r4, #20
    l->next->prev = n;
 800291c:	f853 6032 	ldr.w	r6, [r3, r2, lsl #3]
 8002920:	6071      	str	r1, [r6, #4]
    n->next = l->next;
 8002922:	f853 6032 	ldr.w	r6, [r3, r2, lsl #3]
 8002926:	6166      	str	r6, [r4, #20]
    l->next = n;
 8002928:	f843 1032 	str.w	r1, [r3, r2, lsl #3]
    n->prev = l;
 800292c:	61a5      	str	r5, [r4, #24]
}
 800292e:	e7d6      	b.n	80028de <rt_schedule_insert_thread+0x42>
 8002930:	2000020c 	.word	0x2000020c
 8002934:	20000218 	.word	0x20000218
 8002938:	20000214 	.word	0x20000214
 800293c:	08008e80 	.word	0x08008e80
 8002940:	080084b0 	.word	0x080084b0

08002944 <rt_schedule_remove_thread>:
    /* enable interrupt */
    rt_hw_interrupt_enable(level);
}
#else
void rt_schedule_remove_thread(struct rt_thread *thread)
{
 8002944:	b510      	push	{r4, lr}
    rt_base_t level;

    RT_ASSERT(thread != RT_NULL);
 8002946:	4604      	mov	r4, r0
 8002948:	b1b0      	cbz	r0, 8002978 <rt_schedule_remove_thread+0x34>

    /* disable interrupt */
    level = rt_hw_interrupt_disable();
 800294a:	f7fd fc7f 	bl	800024c <rt_hw_interrupt_disable>
    RT_DEBUG_LOG(RT_DEBUG_SCHEDULER, ("remove thread[%.*s], the priority: %d\n",
                                      RT_NAME_MAX, thread->name,
                                      thread->current_priority));

    /* remove thread from ready list */
    rt_list_remove(&(thread->tlist));
 800294e:	f104 0314 	add.w	r3, r4, #20
    n->next->prev = n->prev;
 8002952:	6961      	ldr	r1, [r4, #20]
 8002954:	69a2      	ldr	r2, [r4, #24]
 8002956:	604a      	str	r2, [r1, #4]
    n->prev->next = n->next;
 8002958:	6961      	ldr	r1, [r4, #20]
 800295a:	6011      	str	r1, [r2, #0]
    n->next = n->prev = n;
 800295c:	61a3      	str	r3, [r4, #24]
 800295e:	6163      	str	r3, [r4, #20]
    if (rt_list_isempty(&(rt_thread_priority_table[thread->current_priority])))
 8002960:	f894 2035 	ldrb.w	r2, [r4, #53]	@ 0x35
 8002964:	4b0b      	ldr	r3, [pc, #44]	@ (8002994 <rt_schedule_remove_thread+0x50>)
 8002966:	eb03 01c2 	add.w	r1, r3, r2, lsl #3
    return l->next == l;
 800296a:	f853 3032 	ldr.w	r3, [r3, r2, lsl #3]
 800296e:	4299      	cmp	r1, r3
 8002970:	d009      	beq.n	8002986 <rt_schedule_remove_thread+0x42>
        rt_thread_ready_priority_group &= ~thread->number_mask;
#endif /* RT_THREAD_PRIORITY_MAX > 32 */
    }

    /* enable interrupt */
    rt_hw_interrupt_enable(level);
 8002972:	f7fd fc6f 	bl	8000254 <rt_hw_interrupt_enable>
}
 8002976:	bd10      	pop	{r4, pc}
    RT_ASSERT(thread != RT_NULL);
 8002978:	f240 3251 	movw	r2, #849	@ 0x351
 800297c:	4906      	ldr	r1, [pc, #24]	@ (8002998 <rt_schedule_remove_thread+0x54>)
 800297e:	4807      	ldr	r0, [pc, #28]	@ (800299c <rt_schedule_remove_thread+0x58>)
 8002980:	f7ff fb12 	bl	8001fa8 <rt_assert_handler>
 8002984:	e7e1      	b.n	800294a <rt_schedule_remove_thread+0x6>
        rt_thread_ready_priority_group &= ~thread->number_mask;
 8002986:	6ba1      	ldr	r1, [r4, #56]	@ 0x38
 8002988:	4a05      	ldr	r2, [pc, #20]	@ (80029a0 <rt_schedule_remove_thread+0x5c>)
 800298a:	6813      	ldr	r3, [r2, #0]
 800298c:	ea23 0301 	bic.w	r3, r3, r1
 8002990:	6013      	str	r3, [r2, #0]
 8002992:	e7ee      	b.n	8002972 <rt_schedule_remove_thread+0x2e>
 8002994:	20000218 	.word	0x20000218
 8002998:	08008e00 	.word	0x08008e00
 800299c:	080084b0 	.word	0x080084b0
 80029a0:	20000214 	.word	0x20000214

080029a4 <rt_system_scheduler_start>:
{
 80029a4:	b510      	push	{r4, lr}
 80029a6:	b082      	sub	sp, #8
    to_thread = _scheduler_get_highest_priority_thread(&highest_ready_priority);
 80029a8:	a801      	add	r0, sp, #4
 80029aa:	f7ff ff4d 	bl	8002848 <_scheduler_get_highest_priority_thread>
 80029ae:	4604      	mov	r4, r0
    rt_current_thread = to_thread;
 80029b0:	4b06      	ldr	r3, [pc, #24]	@ (80029cc <rt_system_scheduler_start+0x28>)
 80029b2:	6018      	str	r0, [r3, #0]
    rt_schedule_remove_thread(to_thread);
 80029b4:	f7ff ffc6 	bl	8002944 <rt_schedule_remove_thread>
    to_thread->stat = RT_THREAD_RUNNING;
 80029b8:	2303      	movs	r3, #3
 80029ba:	f884 3034 	strb.w	r3, [r4, #52]	@ 0x34
    rt_hw_context_switch_to((rt_ubase_t)&to_thread->sp);
 80029be:	f104 001c 	add.w	r0, r4, #28
 80029c2:	f7fd fc90 	bl	80002e6 <rt_hw_context_switch_to>
}
 80029c6:	b002      	add	sp, #8
 80029c8:	bd10      	pop	{r4, pc}
 80029ca:	bf00      	nop
 80029cc:	2000020c 	.word	0x2000020c

080029d0 <rt_schedule>:
{
 80029d0:	b570      	push	{r4, r5, r6, lr}
 80029d2:	b082      	sub	sp, #8
    level = rt_hw_interrupt_disable();
 80029d4:	f7fd fc3a 	bl	800024c <rt_hw_interrupt_disable>
 80029d8:	4604      	mov	r4, r0
    if (rt_scheduler_lock_nest == 0)
 80029da:	4b35      	ldr	r3, [pc, #212]	@ (8002ab0 <rt_schedule+0xe0>)
 80029dc:	f9b3 3000 	ldrsh.w	r3, [r3]
 80029e0:	b913      	cbnz	r3, 80029e8 <rt_schedule+0x18>
        if (rt_thread_ready_priority_group != 0)
 80029e2:	4b34      	ldr	r3, [pc, #208]	@ (8002ab4 <rt_schedule+0xe4>)
 80029e4:	681b      	ldr	r3, [r3, #0]
 80029e6:	b923      	cbnz	r3, 80029f2 <rt_schedule+0x22>
    rt_hw_interrupt_enable(level);
 80029e8:	4620      	mov	r0, r4
 80029ea:	f7fd fc33 	bl	8000254 <rt_hw_interrupt_enable>
}
 80029ee:	b002      	add	sp, #8
 80029f0:	bd70      	pop	{r4, r5, r6, pc}
            to_thread = _scheduler_get_highest_priority_thread(&highest_ready_priority);
 80029f2:	a801      	add	r0, sp, #4
 80029f4:	f7ff ff28 	bl	8002848 <_scheduler_get_highest_priority_thread>
 80029f8:	4605      	mov	r5, r0
            if ((rt_current_thread->stat & RT_THREAD_STAT_MASK) == RT_THREAD_RUNNING)
 80029fa:	4b2f      	ldr	r3, [pc, #188]	@ (8002ab8 <rt_schedule+0xe8>)
 80029fc:	681e      	ldr	r6, [r3, #0]
 80029fe:	f896 3034 	ldrb.w	r3, [r6, #52]	@ 0x34
 8002a02:	f003 0207 	and.w	r2, r3, #7
 8002a06:	2a03      	cmp	r2, #3
 8002a08:	d01e      	beq.n	8002a48 <rt_schedule+0x78>
            int need_insert_from_thread = 0;
 8002a0a:	2200      	movs	r2, #0
            if (to_thread != rt_current_thread)
 8002a0c:	42ae      	cmp	r6, r5
 8002a0e:	d040      	beq.n	8002a92 <rt_schedule+0xc2>
                rt_current_priority = (rt_uint8_t)highest_ready_priority;
 8002a10:	f89d 1004 	ldrb.w	r1, [sp, #4]
 8002a14:	4b29      	ldr	r3, [pc, #164]	@ (8002abc <rt_schedule+0xec>)
 8002a16:	7019      	strb	r1, [r3, #0]
                rt_current_thread = to_thread;
 8002a18:	4b27      	ldr	r3, [pc, #156]	@ (8002ab8 <rt_schedule+0xe8>)
 8002a1a:	601d      	str	r5, [r3, #0]
                if (need_insert_from_thread)
 8002a1c:	bb5a      	cbnz	r2, 8002a76 <rt_schedule+0xa6>
                rt_schedule_remove_thread(to_thread);
 8002a1e:	4628      	mov	r0, r5
 8002a20:	f7ff ff90 	bl	8002944 <rt_schedule_remove_thread>
                to_thread->stat = RT_THREAD_RUNNING | (to_thread->stat & ~RT_THREAD_STAT_MASK);
 8002a24:	f895 3034 	ldrb.w	r3, [r5, #52]	@ 0x34
 8002a28:	f023 0307 	bic.w	r3, r3, #7
 8002a2c:	f043 0303 	orr.w	r3, r3, #3
 8002a30:	f885 3034 	strb.w	r3, [r5, #52]	@ 0x34
                if (rt_interrupt_nest == 0)
 8002a34:	4b22      	ldr	r3, [pc, #136]	@ (8002ac0 <rt_schedule+0xf0>)
 8002a36:	781b      	ldrb	r3, [r3, #0]
 8002a38:	b30b      	cbz	r3, 8002a7e <rt_schedule+0xae>
                    rt_hw_context_switch_interrupt((rt_ubase_t)&from_thread->sp,
 8002a3a:	f105 011c 	add.w	r1, r5, #28
 8002a3e:	f106 001c 	add.w	r0, r6, #28
 8002a42:	f7fd fc0a 	bl	800025a <rt_hw_context_switch>
 8002a46:	e7cf      	b.n	80029e8 <rt_schedule+0x18>
                if (rt_current_thread->current_priority < highest_ready_priority)
 8002a48:	f896 1035 	ldrb.w	r1, [r6, #53]	@ 0x35
 8002a4c:	9a01      	ldr	r2, [sp, #4]
 8002a4e:	4291      	cmp	r1, r2
 8002a50:	d307      	bcc.n	8002a62 <rt_schedule+0x92>
                else if (rt_current_thread->current_priority == highest_ready_priority && (rt_current_thread->stat & RT_THREAD_STAT_YIELD_MASK) == 0)
 8002a52:	d001      	beq.n	8002a58 <rt_schedule+0x88>
                    need_insert_from_thread = 1;
 8002a54:	2201      	movs	r2, #1
 8002a56:	e006      	b.n	8002a66 <rt_schedule+0x96>
                else if (rt_current_thread->current_priority == highest_ready_priority && (rt_current_thread->stat & RT_THREAD_STAT_YIELD_MASK) == 0)
 8002a58:	f013 0f08 	tst.w	r3, #8
 8002a5c:	d008      	beq.n	8002a70 <rt_schedule+0xa0>
                    need_insert_from_thread = 1;
 8002a5e:	2201      	movs	r2, #1
 8002a60:	e001      	b.n	8002a66 <rt_schedule+0x96>
                    to_thread = rt_current_thread;
 8002a62:	4635      	mov	r5, r6
            int need_insert_from_thread = 0;
 8002a64:	2200      	movs	r2, #0
                rt_current_thread->stat &= ~RT_THREAD_STAT_YIELD_MASK;
 8002a66:	f023 0308 	bic.w	r3, r3, #8
 8002a6a:	f886 3034 	strb.w	r3, [r6, #52]	@ 0x34
 8002a6e:	e7cd      	b.n	8002a0c <rt_schedule+0x3c>
                    to_thread = rt_current_thread;
 8002a70:	4635      	mov	r5, r6
            int need_insert_from_thread = 0;
 8002a72:	2200      	movs	r2, #0
 8002a74:	e7f7      	b.n	8002a66 <rt_schedule+0x96>
                    rt_schedule_insert_thread(from_thread);
 8002a76:	4630      	mov	r0, r6
 8002a78:	f7ff ff10 	bl	800289c <rt_schedule_insert_thread>
 8002a7c:	e7cf      	b.n	8002a1e <rt_schedule+0x4e>
                    rt_hw_context_switch((rt_ubase_t)&from_thread->sp,
 8002a7e:	f105 011c 	add.w	r1, r5, #28
 8002a82:	f106 001c 	add.w	r0, r6, #28
 8002a86:	f7fd fbe8 	bl	800025a <rt_hw_context_switch>
                    rt_hw_interrupt_enable(level);
 8002a8a:	4620      	mov	r0, r4
 8002a8c:	f7fd fbe2 	bl	8000254 <rt_hw_interrupt_enable>
                    goto __exit;
 8002a90:	e7ad      	b.n	80029ee <rt_schedule+0x1e>
                rt_schedule_remove_thread(rt_current_thread);
 8002a92:	4630      	mov	r0, r6
 8002a94:	f7ff ff56 	bl	8002944 <rt_schedule_remove_thread>
                rt_current_thread->stat = RT_THREAD_RUNNING | (rt_current_thread->stat & ~RT_THREAD_STAT_MASK);
 8002a98:	4b07      	ldr	r3, [pc, #28]	@ (8002ab8 <rt_schedule+0xe8>)
 8002a9a:	681a      	ldr	r2, [r3, #0]
 8002a9c:	f892 3034 	ldrb.w	r3, [r2, #52]	@ 0x34
 8002aa0:	f023 0307 	bic.w	r3, r3, #7
 8002aa4:	f043 0303 	orr.w	r3, r3, #3
 8002aa8:	f882 3034 	strb.w	r3, [r2, #52]	@ 0x34
 8002aac:	e79c      	b.n	80029e8 <rt_schedule+0x18>
 8002aae:	bf00      	nop
 8002ab0:	20000210 	.word	0x20000210
 8002ab4:	20000214 	.word	0x20000214
 8002ab8:	2000020c 	.word	0x2000020c
 8002abc:	20000208 	.word	0x20000208
 8002ac0:	200000d4 	.word	0x200000d4

08002ac4 <rt_enter_critical>:
    /* enable interrupt */
    rt_hw_local_irq_enable(level);
}
#else
void rt_enter_critical(void)
{
 8002ac4:	b508      	push	{r3, lr}
    rt_base_t level;

    /* disable interrupt */
    level = rt_hw_interrupt_disable();
 8002ac6:	f7fd fbc1 	bl	800024c <rt_hw_interrupt_disable>

    /*
     * the maximal number of nest is RT_UINT16_MAX, which is big
     * enough and does not check here
     */
    rt_scheduler_lock_nest++;
 8002aca:	4a03      	ldr	r2, [pc, #12]	@ (8002ad8 <rt_enter_critical+0x14>)
 8002acc:	8813      	ldrh	r3, [r2, #0]
 8002ace:	3301      	adds	r3, #1
 8002ad0:	8013      	strh	r3, [r2, #0]

    /* enable interrupt */
    rt_hw_interrupt_enable(level);
 8002ad2:	f7fd fbbf 	bl	8000254 <rt_hw_interrupt_enable>
}
 8002ad6:	bd08      	pop	{r3, pc}
 8002ad8:	20000210 	.word	0x20000210

08002adc <rt_exit_critical>:
        rt_hw_local_irq_enable(level);
    }
}
#else
void rt_exit_critical(void)
{
 8002adc:	b508      	push	{r3, lr}
    rt_base_t level;

    /* disable interrupt */
    level = rt_hw_interrupt_disable();
 8002ade:	f7fd fbb5 	bl	800024c <rt_hw_interrupt_disable>

    rt_scheduler_lock_nest--;
 8002ae2:	4a0b      	ldr	r2, [pc, #44]	@ (8002b10 <rt_exit_critical+0x34>)
 8002ae4:	8813      	ldrh	r3, [r2, #0]
 8002ae6:	3b01      	subs	r3, #1
 8002ae8:	b21b      	sxth	r3, r3
 8002aea:	8013      	strh	r3, [r2, #0]
    if (rt_scheduler_lock_nest <= 0)
 8002aec:	2b00      	cmp	r3, #0
 8002aee:	dd02      	ble.n	8002af6 <rt_exit_critical+0x1a>
        }
    }
    else
    {
        /* enable interrupt */
        rt_hw_interrupt_enable(level);
 8002af0:	f7fd fbb0 	bl	8000254 <rt_hw_interrupt_enable>
    }
}
 8002af4:	bd08      	pop	{r3, pc}
        rt_scheduler_lock_nest = 0;
 8002af6:	4613      	mov	r3, r2
 8002af8:	2200      	movs	r2, #0
 8002afa:	801a      	strh	r2, [r3, #0]
        rt_hw_interrupt_enable(level);
 8002afc:	f7fd fbaa 	bl	8000254 <rt_hw_interrupt_enable>
        if (rt_current_thread)
 8002b00:	4b04      	ldr	r3, [pc, #16]	@ (8002b14 <rt_exit_critical+0x38>)
 8002b02:	681b      	ldr	r3, [r3, #0]
 8002b04:	2b00      	cmp	r3, #0
 8002b06:	d0f5      	beq.n	8002af4 <rt_exit_critical+0x18>
            rt_schedule();
 8002b08:	f7ff ff62 	bl	80029d0 <rt_schedule>
 8002b0c:	e7f2      	b.n	8002af4 <rt_exit_critical+0x18>
 8002b0e:	bf00      	nop
 8002b10:	20000210 	.word	0x20000210
 8002b14:	2000020c 	.word	0x2000020c

08002b18 <rt_critical_level>:

    return current_thread->critical_lock_nest;
#else
    return rt_scheduler_lock_nest;
#endif /* RT_USING_SMP */
}
 8002b18:	4b01      	ldr	r3, [pc, #4]	@ (8002b20 <rt_critical_level+0x8>)
 8002b1a:	8818      	ldrh	r0, [r3, #0]
 8002b1c:	4770      	bx	lr
 8002b1e:	bf00      	nop
 8002b20:	20000210 	.word	0x20000210

08002b24 <rt_thread_defunct_enqueue>:
 *
 * @note It must be called between rt_hw_interrupt_disable and rt_hw_interrupt_enable
 */
void rt_thread_defunct_enqueue(rt_thread_t thread)
{
    rt_list_insert_after(&_rt_thread_defunct, &thread->tlist);
 8002b24:	f100 0214 	add.w	r2, r0, #20
    l->next->prev = n;
 8002b28:	4b03      	ldr	r3, [pc, #12]	@ (8002b38 <rt_thread_defunct_enqueue+0x14>)
 8002b2a:	6819      	ldr	r1, [r3, #0]
 8002b2c:	604a      	str	r2, [r1, #4]
    n->next = l->next;
 8002b2e:	6141      	str	r1, [r0, #20]
    l->next = n;
 8002b30:	601a      	str	r2, [r3, #0]
    n->prev = l;
 8002b32:	6183      	str	r3, [r0, #24]
#ifdef RT_USING_SMP
    rt_sem_release(&system_sem);
#endif
}
 8002b34:	4770      	bx	lr
 8002b36:	bf00      	nop
 8002b38:	20000084 	.word	0x20000084

08002b3c <rt_thread_defunct_dequeue>:

/**
 * @brief Dequeue a thread from defunct queue.
 */
rt_thread_t rt_thread_defunct_dequeue(void)
{
 8002b3c:	b538      	push	{r3, r4, r5, lr}
                tlist);
        rt_list_remove(&(thread->tlist));
    }
    rt_hw_interrupt_enable(level);
#else
    if (l->next != l)
 8002b3e:	4b0a      	ldr	r3, [pc, #40]	@ (8002b68 <rt_thread_defunct_dequeue+0x2c>)
 8002b40:	681c      	ldr	r4, [r3, #0]
 8002b42:	429c      	cmp	r4, r3
 8002b44:	d00e      	beq.n	8002b64 <rt_thread_defunct_dequeue+0x28>
    {
        thread = rt_list_entry(l->next,
 8002b46:	4625      	mov	r5, r4
                struct rt_thread,
                tlist);
        level = rt_hw_interrupt_disable();
 8002b48:	f7fd fb80 	bl	800024c <rt_hw_interrupt_disable>
    n->next->prev = n->prev;
 8002b4c:	f855 2914 	ldr.w	r2, [r5], #-20
 8002b50:	6863      	ldr	r3, [r4, #4]
 8002b52:	6053      	str	r3, [r2, #4]
    n->prev->next = n->next;
 8002b54:	6822      	ldr	r2, [r4, #0]
 8002b56:	601a      	str	r2, [r3, #0]
    n->next = n->prev = n;
 8002b58:	6064      	str	r4, [r4, #4]
 8002b5a:	6024      	str	r4, [r4, #0]
        rt_list_remove(&(thread->tlist));
        rt_hw_interrupt_enable(level);
 8002b5c:	f7fd fb7a 	bl	8000254 <rt_hw_interrupt_enable>
    }
#endif
    return thread;
}
 8002b60:	4628      	mov	r0, r5
 8002b62:	bd38      	pop	{r3, r4, r5, pc}
    rt_thread_t thread = RT_NULL;
 8002b64:	2500      	movs	r5, #0
    return thread;
 8002b66:	e7fb      	b.n	8002b60 <rt_thread_defunct_dequeue+0x24>
 8002b68:	20000084 	.word	0x20000084

08002b6c <rt_defunct_execute>:

/**
 * @brief This function will perform system background job when system idle.
 */
static void rt_defunct_execute(void)
{
 8002b6c:	b570      	push	{r4, r5, r6, lr}
 8002b6e:	e004      	b.n	8002b7a <rt_defunct_execute+0xe>
        /* if it's a system object, not delete it */
        object_is_systemobject = rt_object_is_systemobject((rt_object_t)thread);
        if (object_is_systemobject == RT_TRUE)
        {
            /* detach this object */
            rt_object_detach((rt_object_t)thread);
 8002b70:	4628      	mov	r0, r5
 8002b72:	f7fe fe17 	bl	80017a4 <rt_object_detach>
 8002b76:	e00a      	b.n	8002b8e <rt_defunct_execute+0x22>
            cleanup(thread);
        }

#ifdef RT_USING_HEAP
        /* if need free, delete it */
        if (object_is_systemobject == RT_FALSE)
 8002b78:	b174      	cbz	r4, 8002b98 <rt_defunct_execute+0x2c>
        thread = rt_thread_defunct_dequeue();
 8002b7a:	f7ff ffdf 	bl	8002b3c <rt_thread_defunct_dequeue>
        if (thread == RT_NULL)
 8002b7e:	b190      	cbz	r0, 8002ba6 <rt_defunct_execute+0x3a>
 8002b80:	4605      	mov	r5, r0
        cleanup = thread->cleanup;
 8002b82:	6f86      	ldr	r6, [r0, #120]	@ 0x78
        object_is_systemobject = rt_object_is_systemobject((rt_object_t)thread);
 8002b84:	f7fe fea6 	bl	80018d4 <rt_object_is_systemobject>
 8002b88:	4604      	mov	r4, r0
        if (object_is_systemobject == RT_TRUE)
 8002b8a:	2801      	cmp	r0, #1
 8002b8c:	d0f0      	beq.n	8002b70 <rt_defunct_execute+0x4>
        if (cleanup != RT_NULL)
 8002b8e:	2e00      	cmp	r6, #0
 8002b90:	d0f2      	beq.n	8002b78 <rt_defunct_execute+0xc>
            cleanup(thread);
 8002b92:	4628      	mov	r0, r5
 8002b94:	47b0      	blx	r6
 8002b96:	e7ef      	b.n	8002b78 <rt_defunct_execute+0xc>
        {
            /* release thread's stack */
            RT_KERNEL_FREE(thread->stack_addr);
 8002b98:	6aa8      	ldr	r0, [r5, #40]	@ 0x28
 8002b9a:	f7ff fa71 	bl	8002080 <rt_free>
            /* delete thread object */
            rt_object_delete((rt_object_t)thread);
 8002b9e:	4628      	mov	r0, r5
 8002ba0:	f7fe fe6a 	bl	8001878 <rt_object_delete>
 8002ba4:	e7e9      	b.n	8002b7a <rt_defunct_execute+0xe>
        }
#endif
    }
}
 8002ba6:	bd70      	pop	{r4, r5, r6, pc}

08002ba8 <rt_thread_idle_entry>:

static void rt_thread_idle_entry(void *parameter)
{
 8002ba8:	b508      	push	{r3, lr}
            }
        }
#endif /* RT_USING_IDLE_HOOK */

#ifndef RT_USING_SMP
        rt_defunct_execute();
 8002baa:	f7ff ffdf 	bl	8002b6c <rt_defunct_execute>
    while (1)
 8002bae:	e7fc      	b.n	8002baa <rt_thread_idle_entry+0x2>

08002bb0 <rt_thread_idle_init>:
 * @brief This function will initialize idle thread, then start it.
 *
 * @note this function must be invoked when system init.
 */
void rt_thread_idle_init(void)
{
 8002bb0:	b570      	push	{r4, r5, r6, lr}
 8002bb2:	b086      	sub	sp, #24
    rt_ubase_t i;
    char tidle_name[RT_NAME_MAX];

    for (i = 0; i < _CPUS_NR; i++)
 8002bb4:	2400      	movs	r4, #0
 8002bb6:	b10c      	cbz	r4, 8002bbc <rt_thread_idle_init+0xc>
            RT_THREAD_PRIORITY_MAX - 2,
            32);
    /* startup */
    rt_thread_startup(&rt_system_thread);
#endif
}
 8002bb8:	b006      	add	sp, #24
 8002bba:	bd70      	pop	{r4, r5, r6, pc}
        rt_sprintf(tidle_name, "tidle%d", i);
 8002bbc:	ae04      	add	r6, sp, #16
 8002bbe:	4622      	mov	r2, r4
 8002bc0:	490e      	ldr	r1, [pc, #56]	@ (8002bfc <rt_thread_idle_init+0x4c>)
 8002bc2:	4630      	mov	r0, r6
 8002bc4:	f7ff f978 	bl	8001eb8 <rt_sprintf>
        rt_thread_init(&idle[i],
 8002bc8:	4d0d      	ldr	r5, [pc, #52]	@ (8002c00 <rt_thread_idle_init+0x50>)
 8002bca:	eb05 15c4 	add.w	r5, r5, r4, lsl #7
                &rt_thread_stack[i][0],
 8002bce:	4b0d      	ldr	r3, [pc, #52]	@ (8002c04 <rt_thread_idle_init+0x54>)
 8002bd0:	eb03 2304 	add.w	r3, r3, r4, lsl #8
        rt_thread_init(&idle[i],
 8002bd4:	2220      	movs	r2, #32
 8002bd6:	9203      	str	r2, [sp, #12]
 8002bd8:	221f      	movs	r2, #31
 8002bda:	9202      	str	r2, [sp, #8]
 8002bdc:	f44f 7280 	mov.w	r2, #256	@ 0x100
 8002be0:	9201      	str	r2, [sp, #4]
 8002be2:	9300      	str	r3, [sp, #0]
 8002be4:	2300      	movs	r3, #0
 8002be6:	4a08      	ldr	r2, [pc, #32]	@ (8002c08 <rt_thread_idle_init+0x58>)
 8002be8:	4631      	mov	r1, r6
 8002bea:	4628      	mov	r0, r5
 8002bec:	f7fe f8d8 	bl	8000da0 <rt_thread_init>
        rt_thread_startup(&idle[i]);
 8002bf0:	4628      	mov	r0, r5
 8002bf2:	f7fe fa69 	bl	80010c8 <rt_thread_startup>
    for (i = 0; i < _CPUS_NR; i++)
 8002bf6:	3401      	adds	r4, #1
 8002bf8:	e7dd      	b.n	8002bb6 <rt_thread_idle_init+0x6>
 8002bfa:	bf00      	nop
 8002bfc:	08008d68 	.word	0x08008d68
 8002c00:	20000418 	.word	0x20000418
 8002c04:	20000318 	.word	0x20000318
 8002c08:	08002ba9 	.word	0x08002ba9

08002c0c <uart_init>:
}
 8002c0c:	2000      	movs	r0, #0
 8002c0e:	4770      	bx	lr

08002c10 <rt_heap_begin_get>:
}
 8002c10:	4800      	ldr	r0, [pc, #0]	@ (8002c14 <rt_heap_begin_get+0x4>)
 8002c12:	4770      	bx	lr
 8002c14:	2000049c 	.word	0x2000049c

08002c18 <rt_heap_end_get>:
}
 8002c18:	4800      	ldr	r0, [pc, #0]	@ (8002c1c <rt_heap_end_get+0x4>)
 8002c1a:	4770      	bx	lr
 8002c1c:	2000409c 	.word	0x2000409c

08002c20 <rt_os_tick_callback>:
{
 8002c20:	b508      	push	{r3, lr}
    rt_interrupt_enter();
 8002c22:	f7fe fe7f 	bl	8001924 <rt_interrupt_enter>
    rt_tick_increase();
 8002c26:	f7ff fc0f 	bl	8002448 <rt_tick_increase>
    rt_interrupt_leave();
 8002c2a:	f7fe fe89 	bl	8001940 <rt_interrupt_leave>
}
 8002c2e:	bd08      	pop	{r3, pc}

08002c30 <rt_register_callback>:
    if (register_callback == RT_NULL && callback != RT_NULL)
 8002c30:	4b04      	ldr	r3, [pc, #16]	@ (8002c44 <rt_register_callback+0x14>)
 8002c32:	681b      	ldr	r3, [r3, #0]
 8002c34:	b103      	cbz	r3, 8002c38 <rt_register_callback+0x8>
}
 8002c36:	4770      	bx	lr
    if (register_callback == RT_NULL && callback != RT_NULL)
 8002c38:	2800      	cmp	r0, #0
 8002c3a:	d0fc      	beq.n	8002c36 <rt_register_callback+0x6>
        register_callback = callback;
 8002c3c:	4b01      	ldr	r3, [pc, #4]	@ (8002c44 <rt_register_callback+0x14>)
 8002c3e:	6018      	str	r0, [r3, #0]
}
 8002c40:	e7f9      	b.n	8002c36 <rt_register_callback+0x6>
 8002c42:	bf00      	nop
 8002c44:	20000498 	.word	0x20000498

08002c48 <rt_hw_board_init>:
{
 8002c48:	b510      	push	{r4, lr}
    if (register_callback != RT_NULL)
 8002c4a:	4b08      	ldr	r3, [pc, #32]	@ (8002c6c <rt_hw_board_init+0x24>)
 8002c4c:	681b      	ldr	r3, [r3, #0]
 8002c4e:	b103      	cbz	r3, 8002c52 <rt_hw_board_init+0xa>
        register_callback();
 8002c50:	4798      	blx	r3
    rt_components_board_init();
 8002c52:	f7fe fadb 	bl	800120c <rt_components_board_init>
    rt_system_heap_init(rt_heap_begin_get(), rt_heap_end_get());
 8002c56:	f7ff ffdb 	bl	8002c10 <rt_heap_begin_get>
 8002c5a:	4604      	mov	r4, r0
 8002c5c:	f7ff ffdc 	bl	8002c18 <rt_heap_end_get>
 8002c60:	4601      	mov	r1, r0
 8002c62:	4620      	mov	r0, r4
 8002c64:	f7ff f9bc 	bl	8001fe0 <rt_system_heap_init>
}
 8002c68:	bd10      	pop	{r4, pc}
 8002c6a:	bf00      	nop
 8002c6c:	20000498 	.word	0x20000498

08002c70 <HAL_MspInit>:
__weak void HAL_MspInit(void)
{
  /* NOTE : This function Should not be modified, when the callback is needed,
            the HAL_MspInit could be implemented in the user file
   */
}
 8002c70:	4770      	bx	lr
	...

08002c74 <HAL_InitTick>:
  *       implementation  in user file.
  * @param TickPriority: Tick interrupt priority.
  * @retval HAL status
  */
__weak HAL_StatusTypeDef HAL_InitTick(uint32_t TickPriority)
{
 8002c74:	b538      	push	{r3, r4, r5, lr}
  uint32_t ticknumber = 0U;
  uint32_t systicksel;

  /* Check uwTickFreq for MisraC 2012 (even if uwTickFreq is a enum type that don't take the value zero)*/
  if ((uint32_t)uwTickFreq == 0UL)
 8002c76:	4b27      	ldr	r3, [pc, #156]	@ (8002d14 <HAL_InitTick+0xa0>)
 8002c78:	781a      	ldrb	r2, [r3, #0]
 8002c7a:	2a00      	cmp	r2, #0
 8002c7c:	d047      	beq.n	8002d0e <HAL_InitTick+0x9a>
 8002c7e:	4605      	mov	r5, r0
  {
    return HAL_ERROR;
  }

  /* Check Clock source to calculate the tickNumber */
  if (READ_BIT(SysTick->CTRL, SysTick_CTRL_CLKSOURCE_Msk) == SysTick_CTRL_CLKSOURCE_Msk)
 8002c80:	f04f 23e0 	mov.w	r3, #3758153728	@ 0xe000e000
 8002c84:	691c      	ldr	r4, [r3, #16]
 8002c86:	f014 0404 	ands.w	r4, r4, #4
 8002c8a:	d00d      	beq.n	8002ca8 <HAL_InitTick+0x34>
  {
    /* HCLK selected as SysTick clock source */
    ticknumber = SystemCoreClock / (1000UL / (uint32_t)uwTickFreq);
 8002c8c:	4b22      	ldr	r3, [pc, #136]	@ (8002d18 <HAL_InitTick+0xa4>)
 8002c8e:	681c      	ldr	r4, [r3, #0]
 8002c90:	f44f 717a 	mov.w	r1, #1000	@ 0x3e8
 8002c94:	fbb1 f2f2 	udiv	r2, r1, r2
 8002c98:	fbb4 f4f2 	udiv	r4, r4, r2
        break;
    }
  }

  /* Configure the SysTick to have interrupt in 1ms time basis*/
  if (HAL_SYSTICK_Config(ticknumber) > 0U)
 8002c9c:	4620      	mov	r0, r4
 8002c9e:	f004 fa53 	bl	8007148 <HAL_SYSTICK_Config>
 8002ca2:	b350      	cbz	r0, 8002cfa <HAL_InitTick+0x86>
  {
    return HAL_ERROR;
 8002ca4:	2001      	movs	r0, #1
 8002ca6:	e033      	b.n	8002d10 <HAL_InitTick+0x9c>
    systicksel = HAL_SYSTICK_GetCLKSourceConfig();
 8002ca8:	f004 fa9c 	bl	80071e4 <HAL_SYSTICK_GetCLKSourceConfig>
    switch (systicksel)
 8002cac:	2801      	cmp	r0, #1
 8002cae:	d00e      	beq.n	8002cce <HAL_InitTick+0x5a>
 8002cb0:	2802      	cmp	r0, #2
 8002cb2:	d017      	beq.n	8002ce4 <HAL_InitTick+0x70>
 8002cb4:	2800      	cmp	r0, #0
 8002cb6:	d1f1      	bne.n	8002c9c <HAL_InitTick+0x28>
        ticknumber = (SystemCoreClock / (8000UL / (uint32_t)uwTickFreq));
 8002cb8:	4b17      	ldr	r3, [pc, #92]	@ (8002d18 <HAL_InitTick+0xa4>)
 8002cba:	681c      	ldr	r4, [r3, #0]
 8002cbc:	4a15      	ldr	r2, [pc, #84]	@ (8002d14 <HAL_InitTick+0xa0>)
 8002cbe:	7811      	ldrb	r1, [r2, #0]
 8002cc0:	f44f 52fa 	mov.w	r2, #8000	@ 0x1f40
 8002cc4:	fbb2 f2f1 	udiv	r2, r2, r1
 8002cc8:	fbb4 f4f2 	udiv	r4, r4, r2
        break;
 8002ccc:	e7e6      	b.n	8002c9c <HAL_InitTick+0x28>
        ticknumber = (LSI_VALUE / (1000UL / (uint32_t)uwTickFreq));
 8002cce:	4b11      	ldr	r3, [pc, #68]	@ (8002d14 <HAL_InitTick+0xa0>)
 8002cd0:	781b      	ldrb	r3, [r3, #0]
 8002cd2:	f44f 727a 	mov.w	r2, #1000	@ 0x3e8
 8002cd6:	fbb2 f2f3 	udiv	r2, r2, r3
 8002cda:	f44f 43fa 	mov.w	r3, #32000	@ 0x7d00
 8002cde:	fbb3 f4f2 	udiv	r4, r3, r2
        break;
 8002ce2:	e7db      	b.n	8002c9c <HAL_InitTick+0x28>
        ticknumber = (LSE_VALUE / (1000UL / (uint32_t)uwTickFreq));
 8002ce4:	4b0b      	ldr	r3, [pc, #44]	@ (8002d14 <HAL_InitTick+0xa0>)
 8002ce6:	781b      	ldrb	r3, [r3, #0]
 8002ce8:	f44f 727a 	mov.w	r2, #1000	@ 0x3e8
 8002cec:	fbb2 f2f3 	udiv	r2, r2, r3
 8002cf0:	f44f 4300 	mov.w	r3, #32768	@ 0x8000
 8002cf4:	fbb3 f4f2 	udiv	r4, r3, r2
        break;
 8002cf8:	e7d0      	b.n	8002c9c <HAL_InitTick+0x28>
  }

  /* Configure the SysTick IRQ priority */
  HAL_NVIC_SetPriority(SysTick_IRQn, TickPriority, 0U);
 8002cfa:	2200      	movs	r2, #0
 8002cfc:	4629      	mov	r1, r5
 8002cfe:	f04f 30ff 	mov.w	r0, #4294967295	@ 0xffffffff
 8002d02:	f004 fa11 	bl	8007128 <HAL_NVIC_SetPriority>
  uwTickPrio = TickPriority;
 8002d06:	4b05      	ldr	r3, [pc, #20]	@ (8002d1c <HAL_InitTick+0xa8>)
 8002d08:	601d      	str	r5, [r3, #0]

  /* Return function status */
  return HAL_OK;
 8002d0a:	2000      	movs	r0, #0
 8002d0c:	e000      	b.n	8002d10 <HAL_InitTick+0x9c>
    return HAL_ERROR;
 8002d0e:	2001      	movs	r0, #1
}
 8002d10:	bd38      	pop	{r3, r4, r5, pc}
 8002d12:	bf00      	nop
 8002d14:	2000008c 	.word	0x2000008c
 8002d18:	20000000 	.word	0x20000000
 8002d1c:	20000090 	.word	0x20000090

08002d20 <HAL_Init>:
{
 8002d20:	b510      	push	{r4, lr}
  HAL_NVIC_SetPriorityGrouping(NVIC_PRIORITYGROUP_4);
 8002d22:	2003      	movs	r0, #3
 8002d24:	f004 f9ee 	bl	8007104 <HAL_NVIC_SetPriorityGrouping>
  SystemCoreClock = HAL_RCC_GetSysClockFreq() >> AHBPrescTable[(RCC->CFGR2 & RCC_CFGR2_HPRE) >> RCC_CFGR2_HPRE_Pos];
 8002d28:	f000 f830 	bl	8002d8c <HAL_RCC_GetSysClockFreq>
 8002d2c:	4b0b      	ldr	r3, [pc, #44]	@ (8002d5c <HAL_Init+0x3c>)
 8002d2e:	6a1b      	ldr	r3, [r3, #32]
 8002d30:	f003 030f 	and.w	r3, r3, #15
 8002d34:	4a0a      	ldr	r2, [pc, #40]	@ (8002d60 <HAL_Init+0x40>)
 8002d36:	5cd3      	ldrb	r3, [r2, r3]
 8002d38:	40d8      	lsrs	r0, r3
 8002d3a:	4b0a      	ldr	r3, [pc, #40]	@ (8002d64 <HAL_Init+0x44>)
 8002d3c:	6018      	str	r0, [r3, #0]
  HAL_SYSTICK_CLKSourceConfig(SYSTICK_CLKSOURCE_HCLK);
 8002d3e:	2004      	movs	r0, #4
 8002d40:	f004 fa12 	bl	8007168 <HAL_SYSTICK_CLKSourceConfig>
  if (HAL_InitTick(TICK_INT_PRIORITY) != HAL_OK)
 8002d44:	200f      	movs	r0, #15
 8002d46:	f7ff ff95 	bl	8002c74 <HAL_InitTick>
 8002d4a:	b110      	cbz	r0, 8002d52 <HAL_Init+0x32>
    return HAL_ERROR;
 8002d4c:	2401      	movs	r4, #1
}
 8002d4e:	4620      	mov	r0, r4
 8002d50:	bd10      	pop	{r4, pc}
 8002d52:	4604      	mov	r4, r0
  HAL_MspInit();
 8002d54:	f7ff ff8c 	bl	8002c70 <HAL_MspInit>
  return HAL_OK;
 8002d58:	e7f9      	b.n	8002d4e <HAL_Init+0x2e>
 8002d5a:	bf00      	nop
 8002d5c:	44020c00 	.word	0x44020c00
 8002d60:	080081e0 	.word	0x080081e0
 8002d64:	20000000 	.word	0x20000000

08002d68 <HAL_IncTick>:
  *      implementations in user file.
  * @retval None
  */
__weak void HAL_IncTick(void)
{
  uwTick += (uint32_t)uwTickFreq;
 8002d68:	4b03      	ldr	r3, [pc, #12]	@ (8002d78 <HAL_IncTick+0x10>)
 8002d6a:	781b      	ldrb	r3, [r3, #0]
 8002d6c:	4a03      	ldr	r2, [pc, #12]	@ (8002d7c <HAL_IncTick+0x14>)
 8002d6e:	6811      	ldr	r1, [r2, #0]
 8002d70:	440b      	add	r3, r1
 8002d72:	6013      	str	r3, [r2, #0]
}
 8002d74:	4770      	bx	lr
 8002d76:	bf00      	nop
 8002d78:	2000008c 	.word	0x2000008c
 8002d7c:	2000409c 	.word	0x2000409c

08002d80 <HAL_GetTick>:
  *       implementations in user file.
  * @retval tick value
  */
__weak uint32_t HAL_GetTick(void)
{
  return uwTick;
 8002d80:	4b01      	ldr	r3, [pc, #4]	@ (8002d88 <HAL_GetTick+0x8>)
 8002d82:	6818      	ldr	r0, [r3, #0]
}
 8002d84:	4770      	bx	lr
 8002d86:	bf00      	nop
 8002d88:	2000409c 	.word	0x2000409c

08002d8c <HAL_RCC_GetSysClockFreq>:
  uint32_t sysclockfreq;
  uint32_t hsivalue;
  float_t fracn1;
  float_t pllvco;

  if (__HAL_RCC_GET_SYSCLK_SOURCE() == RCC_SYSCLKSOURCE_STATUS_CSI)
 8002d8c:	4b6d      	ldr	r3, [pc, #436]	@ (8002f44 <HAL_RCC_GetSysClockFreq+0x1b8>)
 8002d8e:	69db      	ldr	r3, [r3, #28]
 8002d90:	f003 0318 	and.w	r3, r3, #24
 8002d94:	2b08      	cmp	r3, #8
 8002d96:	f000 80ce 	beq.w	8002f36 <HAL_RCC_GetSysClockFreq+0x1aa>
  {
    /* CSI used as system clock  source */
    sysclockfreq = CSI_VALUE;
  }
  else if (__HAL_RCC_GET_SYSCLK_SOURCE() == RCC_SYSCLKSOURCE_STATUS_HSI)
 8002d9a:	4b6a      	ldr	r3, [pc, #424]	@ (8002f44 <HAL_RCC_GetSysClockFreq+0x1b8>)
 8002d9c:	69db      	ldr	r3, [r3, #28]
 8002d9e:	f013 0f18 	tst.w	r3, #24
 8002da2:	d10c      	bne.n	8002dbe <HAL_RCC_GetSysClockFreq+0x32>
  {
    /* HSI used as system clock source */
    if (__HAL_RCC_GET_FLAG(RCC_FLAG_HSIDIVF) != 0U)
 8002da4:	4b67      	ldr	r3, [pc, #412]	@ (8002f44 <HAL_RCC_GetSysClockFreq+0x1b8>)
 8002da6:	681b      	ldr	r3, [r3, #0]
 8002da8:	f013 0f20 	tst.w	r3, #32
 8002dac:	f000 80c5 	beq.w	8002f3a <HAL_RCC_GetSysClockFreq+0x1ae>
    {
      sysclockfreq = (uint32_t)(HSI_VALUE >> (__HAL_RCC_GET_HSI_DIVIDER() >> RCC_CR_HSIDIV_Pos));
 8002db0:	4b64      	ldr	r3, [pc, #400]	@ (8002f44 <HAL_RCC_GetSysClockFreq+0x1b8>)
 8002db2:	681b      	ldr	r3, [r3, #0]
 8002db4:	f3c3 03c1 	ubfx	r3, r3, #3, #2
 8002db8:	4863      	ldr	r0, [pc, #396]	@ (8002f48 <HAL_RCC_GetSysClockFreq+0x1bc>)
 8002dba:	40d8      	lsrs	r0, r3
 8002dbc:	4770      	bx	lr
    else
    {
      sysclockfreq = (uint32_t) HSI_VALUE;
    }
  }
  else if (__HAL_RCC_GET_SYSCLK_SOURCE() == RCC_SYSCLKSOURCE_STATUS_HSE)
 8002dbe:	4b61      	ldr	r3, [pc, #388]	@ (8002f44 <HAL_RCC_GetSysClockFreq+0x1b8>)
 8002dc0:	69db      	ldr	r3, [r3, #28]
 8002dc2:	f003 0318 	and.w	r3, r3, #24
 8002dc6:	2b10      	cmp	r3, #16
 8002dc8:	f000 80b9 	beq.w	8002f3e <HAL_RCC_GetSysClockFreq+0x1b2>
  {
    /* HSE used as system clock source */
    sysclockfreq = HSE_VALUE;
  }

  else if (__HAL_RCC_GET_SYSCLK_SOURCE() == RCC_SYSCLKSOURCE_STATUS_PLLCLK)
 8002dcc:	4b5d      	ldr	r3, [pc, #372]	@ (8002f44 <HAL_RCC_GetSysClockFreq+0x1b8>)
 8002dce:	69db      	ldr	r3, [r3, #28]
 8002dd0:	f003 0318 	and.w	r3, r3, #24
 8002dd4:	2b18      	cmp	r3, #24
 8002dd6:	d001      	beq.n	8002ddc <HAL_RCC_GetSysClockFreq+0x50>
  }

  else
  {
    /* HSI is the default system clock source */
    sysclockfreq = (uint32_t) HSI_VALUE;
 8002dd8:	485b      	ldr	r0, [pc, #364]	@ (8002f48 <HAL_RCC_GetSysClockFreq+0x1bc>)
  }

  return sysclockfreq;
}
 8002dda:	4770      	bx	lr
{
 8002ddc:	b410      	push	{r4}
    pllsource = (RCC->PLL1CFGR & RCC_PLL1CFGR_PLL1SRC);
 8002dde:	4b59      	ldr	r3, [pc, #356]	@ (8002f44 <HAL_RCC_GetSysClockFreq+0x1b8>)
 8002de0:	6a99      	ldr	r1, [r3, #40]	@ 0x28
 8002de2:	f001 0103 	and.w	r1, r1, #3
    pllm = ((RCC->PLL1CFGR & RCC_PLL1CFGR_PLL1M) >> RCC_PLL1CFGR_PLL1M_Pos);
 8002de6:	6a9c      	ldr	r4, [r3, #40]	@ 0x28
 8002de8:	f3c4 2005 	ubfx	r0, r4, #8, #6
    pllfracen = ((RCC->PLL1CFGR & RCC_PLL1CFGR_PLL1FRACEN) >> RCC_PLL1CFGR_PLL1FRACEN_Pos);
 8002dec:	6a9a      	ldr	r2, [r3, #40]	@ 0x28
 8002dee:	f3c2 1200 	ubfx	r2, r2, #4, #1
    fracn1 = (float_t)(uint32_t)(pllfracen * ((RCC->PLL1FRACR & \
 8002df2:	6b9b      	ldr	r3, [r3, #56]	@ 0x38
                                               RCC_PLL1FRACR_PLL1FRACN) >> RCC_PLL1FRACR_PLL1FRACN_Pos));
 8002df4:	f3c3 03cc 	ubfx	r3, r3, #3, #13
    fracn1 = (float_t)(uint32_t)(pllfracen * ((RCC->PLL1FRACR & \
 8002df8:	fb02 f303 	mul.w	r3, r2, r3
 8002dfc:	ee07 3a90 	vmov	s15, r3
 8002e00:	eef8 7a67 	vcvt.f32.u32	s15, s15
    if (pllm != 0U)
 8002e04:	f414 5f7c 	tst.w	r4, #16128	@ 0x3f00
 8002e08:	f000 8092 	beq.w	8002f30 <HAL_RCC_GetSysClockFreq+0x1a4>
      switch (pllsource)
 8002e0c:	2901      	cmp	r1, #1
 8002e0e:	d01e      	beq.n	8002e4e <HAL_RCC_GetSysClockFreq+0xc2>
 8002e10:	2903      	cmp	r1, #3
 8002e12:	d062      	beq.n	8002eda <HAL_RCC_GetSysClockFreq+0x14e>
          pllvco = ((float_t)CSI_VALUE / (float_t)pllm) * ((float_t)(uint32_t)(RCC->PLL1DIVR & RCC_PLL1DIVR_PLL1N) + \
 8002e14:	ee07 0a10 	vmov	s14, r0
 8002e18:	eef8 6a47 	vcvt.f32.u32	s13, s14
 8002e1c:	ed9f 6a4b 	vldr	s12, [pc, #300]	@ 8002f4c <HAL_RCC_GetSysClockFreq+0x1c0>
 8002e20:	ee86 7a26 	vdiv.f32	s14, s12, s13
 8002e24:	4b47      	ldr	r3, [pc, #284]	@ (8002f44 <HAL_RCC_GetSysClockFreq+0x1b8>)
 8002e26:	6b5b      	ldr	r3, [r3, #52]	@ 0x34
 8002e28:	f3c3 0308 	ubfx	r3, r3, #0, #9
 8002e2c:	ee06 3a90 	vmov	s13, r3
 8002e30:	eef8 6a66 	vcvt.f32.u32	s13, s13
                                                           (fracn1 / (float_t)0x2000) + (float_t)1);
 8002e34:	ed9f 6a46 	vldr	s12, [pc, #280]	@ 8002f50 <HAL_RCC_GetSysClockFreq+0x1c4>
 8002e38:	ee67 7a86 	vmul.f32	s15, s15, s12
          pllvco = ((float_t)CSI_VALUE / (float_t)pllm) * ((float_t)(uint32_t)(RCC->PLL1DIVR & RCC_PLL1DIVR_PLL1N) + \
 8002e3c:	ee76 7aa7 	vadd.f32	s15, s13, s15
                                                           (fracn1 / (float_t)0x2000) + (float_t)1);
 8002e40:	eef7 6a00 	vmov.f32	s13, #112	@ 0x3f800000  1.0
 8002e44:	ee77 7aa6 	vadd.f32	s15, s15, s13
          pllvco = ((float_t)CSI_VALUE / (float_t)pllm) * ((float_t)(uint32_t)(RCC->PLL1DIVR & RCC_PLL1DIVR_PLL1N) + \
 8002e48:	ee27 7a27 	vmul.f32	s14, s14, s15
          break;
 8002e4c:	e061      	b.n	8002f12 <HAL_RCC_GetSysClockFreq+0x186>
          if (__HAL_RCC_GET_FLAG(RCC_FLAG_HSIDIVF) != 0U)
 8002e4e:	4b3d      	ldr	r3, [pc, #244]	@ (8002f44 <HAL_RCC_GetSysClockFreq+0x1b8>)
 8002e50:	681b      	ldr	r3, [r3, #0]
 8002e52:	f013 0f20 	tst.w	r3, #32
 8002e56:	d023      	beq.n	8002ea0 <HAL_RCC_GetSysClockFreq+0x114>
            hsivalue = (HSI_VALUE >> (__HAL_RCC_GET_HSI_DIVIDER() >> RCC_CR_HSIDIV_Pos));
 8002e58:	493a      	ldr	r1, [pc, #232]	@ (8002f44 <HAL_RCC_GetSysClockFreq+0x1b8>)
 8002e5a:	680a      	ldr	r2, [r1, #0]
 8002e5c:	f3c2 02c1 	ubfx	r2, r2, #3, #2
 8002e60:	4b39      	ldr	r3, [pc, #228]	@ (8002f48 <HAL_RCC_GetSysClockFreq+0x1bc>)
 8002e62:	40d3      	lsrs	r3, r2
            pllvco = ((float_t)hsivalue / (float_t)pllm) * ((float_t)(uint32_t)(RCC->PLL1DIVR & RCC_PLL1DIVR_PLL1N) + \
 8002e64:	ee07 3a10 	vmov	s14, r3
 8002e68:	eef8 6a47 	vcvt.f32.u32	s13, s14
 8002e6c:	ee07 0a10 	vmov	s14, r0
 8002e70:	eeb8 6a47 	vcvt.f32.u32	s12, s14
 8002e74:	ee86 7a86 	vdiv.f32	s14, s13, s12
 8002e78:	6b4b      	ldr	r3, [r1, #52]	@ 0x34
 8002e7a:	f3c3 0308 	ubfx	r3, r3, #0, #9
 8002e7e:	ee06 3a90 	vmov	s13, r3
 8002e82:	eef8 6a66 	vcvt.f32.u32	s13, s13
                                                            (fracn1 / (float_t)0x2000) + (float_t)1);
 8002e86:	ed9f 6a32 	vldr	s12, [pc, #200]	@ 8002f50 <HAL_RCC_GetSysClockFreq+0x1c4>
 8002e8a:	ee67 7a86 	vmul.f32	s15, s15, s12
            pllvco = ((float_t)hsivalue / (float_t)pllm) * ((float_t)(uint32_t)(RCC->PLL1DIVR & RCC_PLL1DIVR_PLL1N) + \
 8002e8e:	ee76 7aa7 	vadd.f32	s15, s13, s15
                                                            (fracn1 / (float_t)0x2000) + (float_t)1);
 8002e92:	eef7 6a00 	vmov.f32	s13, #112	@ 0x3f800000  1.0
 8002e96:	ee77 7aa6 	vadd.f32	s15, s15, s13
            pllvco = ((float_t)hsivalue / (float_t)pllm) * ((float_t)(uint32_t)(RCC->PLL1DIVR & RCC_PLL1DIVR_PLL1N) + \
 8002e9a:	ee27 7a27 	vmul.f32	s14, s14, s15
 8002e9e:	e038      	b.n	8002f12 <HAL_RCC_GetSysClockFreq+0x186>
            pllvco = ((float_t)HSI_VALUE / (float_t)pllm) * ((float_t)(uint32_t)(RCC->PLL1DIVR & RCC_PLL1DIVR_PLL1N) + \
 8002ea0:	ee07 0a10 	vmov	s14, r0
 8002ea4:	eef8 6a47 	vcvt.f32.u32	s13, s14
 8002ea8:	ed9f 6a2a 	vldr	s12, [pc, #168]	@ 8002f54 <HAL_RCC_GetSysClockFreq+0x1c8>
 8002eac:	ee86 7a26 	vdiv.f32	s14, s12, s13
 8002eb0:	4b24      	ldr	r3, [pc, #144]	@ (8002f44 <HAL_RCC_GetSysClockFreq+0x1b8>)
 8002eb2:	6b5b      	ldr	r3, [r3, #52]	@ 0x34
 8002eb4:	f3c3 0308 	ubfx	r3, r3, #0, #9
 8002eb8:	ee06 3a90 	vmov	s13, r3
 8002ebc:	eef8 6a66 	vcvt.f32.u32	s13, s13
                                                             (fracn1 / (float_t)0x2000) + (float_t)1);
 8002ec0:	ed9f 6a23 	vldr	s12, [pc, #140]	@ 8002f50 <HAL_RCC_GetSysClockFreq+0x1c4>
 8002ec4:	ee67 7a86 	vmul.f32	s15, s15, s12
            pllvco = ((float_t)HSI_VALUE / (float_t)pllm) * ((float_t)(uint32_t)(RCC->PLL1DIVR & RCC_PLL1DIVR_PLL1N) + \
 8002ec8:	ee76 7aa7 	vadd.f32	s15, s13, s15
                                                             (fracn1 / (float_t)0x2000) + (float_t)1);
 8002ecc:	eef7 6a00 	vmov.f32	s13, #112	@ 0x3f800000  1.0
 8002ed0:	ee77 7aa6 	vadd.f32	s15, s15, s13
            pllvco = ((float_t)HSI_VALUE / (float_t)pllm) * ((float_t)(uint32_t)(RCC->PLL1DIVR & RCC_PLL1DIVR_PLL1N) + \
 8002ed4:	ee27 7a27 	vmul.f32	s14, s14, s15
 8002ed8:	e01b      	b.n	8002f12 <HAL_RCC_GetSysClockFreq+0x186>
          pllvco = ((float_t)HSE_VALUE / (float_t)pllm) * ((float_t)(uint32_t)(RCC->PLL1DIVR & RCC_PLL1DIVR_PLL1N) + \
 8002eda:	ee07 0a10 	vmov	s14, r0
 8002ede:	eef8 6a47 	vcvt.f32.u32	s13, s14
 8002ee2:	ed9f 6a1d 	vldr	s12, [pc, #116]	@ 8002f58 <HAL_RCC_GetSysClockFreq+0x1cc>
 8002ee6:	ee86 7a26 	vdiv.f32	s14, s12, s13
 8002eea:	4b16      	ldr	r3, [pc, #88]	@ (8002f44 <HAL_RCC_GetSysClockFreq+0x1b8>)
 8002eec:	6b5b      	ldr	r3, [r3, #52]	@ 0x34
 8002eee:	f3c3 0308 	ubfx	r3, r3, #0, #9
 8002ef2:	ee06 3a90 	vmov	s13, r3
 8002ef6:	eef8 6a66 	vcvt.f32.u32	s13, s13
                                                           (fracn1 / (float_t)0x2000) + (float_t)1);
 8002efa:	ed9f 6a15 	vldr	s12, [pc, #84]	@ 8002f50 <HAL_RCC_GetSysClockFreq+0x1c4>
 8002efe:	ee67 7a86 	vmul.f32	s15, s15, s12
          pllvco = ((float_t)HSE_VALUE / (float_t)pllm) * ((float_t)(uint32_t)(RCC->PLL1DIVR & RCC_PLL1DIVR_PLL1N) + \
 8002f02:	ee76 7aa7 	vadd.f32	s15, s13, s15
                                                           (fracn1 / (float_t)0x2000) + (float_t)1);
 8002f06:	eef7 6a00 	vmov.f32	s13, #112	@ 0x3f800000  1.0
 8002f0a:	ee77 7aa6 	vadd.f32	s15, s15, s13
          pllvco = ((float_t)HSE_VALUE / (float_t)pllm) * ((float_t)(uint32_t)(RCC->PLL1DIVR & RCC_PLL1DIVR_PLL1N) + \
 8002f0e:	ee27 7a27 	vmul.f32	s14, s14, s15
      pllp = (((RCC->PLL1DIVR & RCC_PLL1DIVR_PLL1P) >> RCC_PLL1DIVR_PLL1P_Pos) + 1U) ;
 8002f12:	4b0c      	ldr	r3, [pc, #48]	@ (8002f44 <HAL_RCC_GetSysClockFreq+0x1b8>)
 8002f14:	6b5b      	ldr	r3, [r3, #52]	@ 0x34
 8002f16:	f3c3 2346 	ubfx	r3, r3, #9, #7
 8002f1a:	3301      	adds	r3, #1
      sysclockfreq = (uint32_t)(float_t)(pllvco / (float_t)pllp);
 8002f1c:	ee07 3a90 	vmov	s15, r3
 8002f20:	eef8 7a67 	vcvt.f32.u32	s15, s15
 8002f24:	eec7 6a27 	vdiv.f32	s13, s14, s15
 8002f28:	eefc 7ae6 	vcvt.u32.f32	s15, s13
 8002f2c:	ee17 0a90 	vmov	r0, s15
}
 8002f30:	f85d 4b04 	ldr.w	r4, [sp], #4
 8002f34:	4770      	bx	lr
    sysclockfreq = CSI_VALUE;
 8002f36:	4809      	ldr	r0, [pc, #36]	@ (8002f5c <HAL_RCC_GetSysClockFreq+0x1d0>)
 8002f38:	4770      	bx	lr
      sysclockfreq = (uint32_t) HSI_VALUE;
 8002f3a:	4803      	ldr	r0, [pc, #12]	@ (8002f48 <HAL_RCC_GetSysClockFreq+0x1bc>)
 8002f3c:	4770      	bx	lr
    sysclockfreq = HSE_VALUE;
 8002f3e:	4808      	ldr	r0, [pc, #32]	@ (8002f60 <HAL_RCC_GetSysClockFreq+0x1d4>)
 8002f40:	4770      	bx	lr
 8002f42:	bf00      	nop
 8002f44:	44020c00 	.word	0x44020c00
 8002f48:	03d09000 	.word	0x03d09000
 8002f4c:	4a742400 	.word	0x4a742400
 8002f50:	39000000 	.word	0x39000000
 8002f54:	4c742400 	.word	0x4c742400
 8002f58:	4bbebc20 	.word	0x4bbebc20
 8002f5c:	003d0900 	.word	0x003d0900
 8002f60:	017d7840 	.word	0x017d7840

08002f64 <HAL_RCC_ClockConfig>:
  if (pClkInitStruct == NULL)
 8002f64:	2800      	cmp	r0, #0
 8002f66:	f000 8137 	beq.w	80031d8 <HAL_RCC_ClockConfig+0x274>
{
 8002f6a:	b570      	push	{r4, r5, r6, lr}
 8002f6c:	460d      	mov	r5, r1
 8002f6e:	4604      	mov	r4, r0
  if (FLatency > __HAL_FLASH_GET_LATENCY())
 8002f70:	4b9d      	ldr	r3, [pc, #628]	@ (80031e8 <HAL_RCC_ClockConfig+0x284>)
 8002f72:	681b      	ldr	r3, [r3, #0]
 8002f74:	f003 030f 	and.w	r3, r3, #15
 8002f78:	428b      	cmp	r3, r1
 8002f7a:	d20b      	bcs.n	8002f94 <HAL_RCC_ClockConfig+0x30>
    __HAL_FLASH_SET_LATENCY(FLatency);
 8002f7c:	4a9a      	ldr	r2, [pc, #616]	@ (80031e8 <HAL_RCC_ClockConfig+0x284>)
 8002f7e:	6813      	ldr	r3, [r2, #0]
 8002f80:	f023 030f 	bic.w	r3, r3, #15
 8002f84:	430b      	orrs	r3, r1
 8002f86:	6013      	str	r3, [r2, #0]
    if (__HAL_FLASH_GET_LATENCY() != FLatency)
 8002f88:	6813      	ldr	r3, [r2, #0]
 8002f8a:	f003 030f 	and.w	r3, r3, #15
 8002f8e:	428b      	cmp	r3, r1
 8002f90:	f040 8124 	bne.w	80031dc <HAL_RCC_ClockConfig+0x278>
  if (((pClkInitStruct->ClockType) & RCC_CLOCKTYPE_PCLK3) == RCC_CLOCKTYPE_PCLK3)
 8002f94:	6823      	ldr	r3, [r4, #0]
 8002f96:	f013 0f10 	tst.w	r3, #16
 8002f9a:	d00e      	beq.n	8002fba <HAL_RCC_ClockConfig+0x56>
    if ((pClkInitStruct->APB3CLKDivider) > ((RCC->CFGR2 & RCC_CFGR2_PPRE3) >> 8))
 8002f9c:	6962      	ldr	r2, [r4, #20]
 8002f9e:	4b93      	ldr	r3, [pc, #588]	@ (80031ec <HAL_RCC_ClockConfig+0x288>)
 8002fa0:	6a1b      	ldr	r3, [r3, #32]
 8002fa2:	0a1b      	lsrs	r3, r3, #8
 8002fa4:	f003 0370 	and.w	r3, r3, #112	@ 0x70
 8002fa8:	429a      	cmp	r2, r3
 8002faa:	d906      	bls.n	8002fba <HAL_RCC_ClockConfig+0x56>
      MODIFY_REG(RCC->CFGR2, RCC_CFGR2_PPRE3, ((pClkInitStruct->APB3CLKDivider) << 8));
 8002fac:	498f      	ldr	r1, [pc, #572]	@ (80031ec <HAL_RCC_ClockConfig+0x288>)
 8002fae:	6a0b      	ldr	r3, [r1, #32]
 8002fb0:	f423 43e0 	bic.w	r3, r3, #28672	@ 0x7000
 8002fb4:	ea43 2302 	orr.w	r3, r3, r2, lsl #8
 8002fb8:	620b      	str	r3, [r1, #32]
  if (((pClkInitStruct->ClockType) & RCC_CLOCKTYPE_PCLK2) == RCC_CLOCKTYPE_PCLK2)
 8002fba:	6823      	ldr	r3, [r4, #0]
 8002fbc:	f013 0f08 	tst.w	r3, #8
 8002fc0:	d00e      	beq.n	8002fe0 <HAL_RCC_ClockConfig+0x7c>
    if ((pClkInitStruct->APB2CLKDivider) > ((RCC->CFGR2 & RCC_CFGR2_PPRE2) >> 4))
 8002fc2:	6922      	ldr	r2, [r4, #16]
 8002fc4:	4b89      	ldr	r3, [pc, #548]	@ (80031ec <HAL_RCC_ClockConfig+0x288>)
 8002fc6:	6a1b      	ldr	r3, [r3, #32]
 8002fc8:	091b      	lsrs	r3, r3, #4
 8002fca:	f003 0370 	and.w	r3, r3, #112	@ 0x70
 8002fce:	429a      	cmp	r2, r3
 8002fd0:	d906      	bls.n	8002fe0 <HAL_RCC_ClockConfig+0x7c>
      MODIFY_REG(RCC->CFGR2, RCC_CFGR2_PPRE2, ((pClkInitStruct->APB2CLKDivider) << 4));
 8002fd2:	4986      	ldr	r1, [pc, #536]	@ (80031ec <HAL_RCC_ClockConfig+0x288>)
 8002fd4:	6a0b      	ldr	r3, [r1, #32]
 8002fd6:	f423 63e0 	bic.w	r3, r3, #1792	@ 0x700
 8002fda:	ea43 1302 	orr.w	r3, r3, r2, lsl #4
 8002fde:	620b      	str	r3, [r1, #32]
  if (((pClkInitStruct->ClockType) & RCC_CLOCKTYPE_PCLK1) == RCC_CLOCKTYPE_PCLK1)
 8002fe0:	6823      	ldr	r3, [r4, #0]
 8002fe2:	f013 0f04 	tst.w	r3, #4
 8002fe6:	d00c      	beq.n	8003002 <HAL_RCC_ClockConfig+0x9e>
    if ((pClkInitStruct->APB1CLKDivider) > (RCC->CFGR2 & RCC_CFGR2_PPRE1))
 8002fe8:	68e2      	ldr	r2, [r4, #12]
 8002fea:	4b80      	ldr	r3, [pc, #512]	@ (80031ec <HAL_RCC_ClockConfig+0x288>)
 8002fec:	6a1b      	ldr	r3, [r3, #32]
 8002fee:	f003 0370 	and.w	r3, r3, #112	@ 0x70
 8002ff2:	429a      	cmp	r2, r3
 8002ff4:	d905      	bls.n	8003002 <HAL_RCC_ClockConfig+0x9e>
      MODIFY_REG(RCC->CFGR2, RCC_CFGR2_PPRE1, pClkInitStruct->APB1CLKDivider);
 8002ff6:	497d      	ldr	r1, [pc, #500]	@ (80031ec <HAL_RCC_ClockConfig+0x288>)
 8002ff8:	6a0b      	ldr	r3, [r1, #32]
 8002ffa:	f023 0370 	bic.w	r3, r3, #112	@ 0x70
 8002ffe:	431a      	orrs	r2, r3
 8003000:	620a      	str	r2, [r1, #32]
  if (((pClkInitStruct->ClockType) & RCC_CLOCKTYPE_HCLK) == RCC_CLOCKTYPE_HCLK)
 8003002:	6823      	ldr	r3, [r4, #0]
 8003004:	f013 0f02 	tst.w	r3, #2
 8003008:	d00c      	beq.n	8003024 <HAL_RCC_ClockConfig+0xc0>
    if ((pClkInitStruct->AHBCLKDivider) > (RCC->CFGR2 & RCC_CFGR2_HPRE))
 800300a:	68a2      	ldr	r2, [r4, #8]
 800300c:	4b77      	ldr	r3, [pc, #476]	@ (80031ec <HAL_RCC_ClockConfig+0x288>)
 800300e:	6a1b      	ldr	r3, [r3, #32]
 8003010:	f003 030f 	and.w	r3, r3, #15
 8003014:	429a      	cmp	r2, r3
 8003016:	d905      	bls.n	8003024 <HAL_RCC_ClockConfig+0xc0>
      MODIFY_REG(RCC->CFGR2, RCC_CFGR2_HPRE, pClkInitStruct->AHBCLKDivider);
 8003018:	4974      	ldr	r1, [pc, #464]	@ (80031ec <HAL_RCC_ClockConfig+0x288>)
 800301a:	6a0b      	ldr	r3, [r1, #32]
 800301c:	f023 030f 	bic.w	r3, r3, #15
 8003020:	431a      	orrs	r2, r3
 8003022:	620a      	str	r2, [r1, #32]
  if (((pClkInitStruct->ClockType) & RCC_CLOCKTYPE_SYSCLK) == RCC_CLOCKTYPE_SYSCLK)
 8003024:	6823      	ldr	r3, [r4, #0]
 8003026:	f013 0f01 	tst.w	r3, #1
 800302a:	d06c      	beq.n	8003106 <HAL_RCC_ClockConfig+0x1a2>
    if (pClkInitStruct->SYSCLKSource == RCC_SYSCLKSOURCE_PLLCLK)
 800302c:	6863      	ldr	r3, [r4, #4]
 800302e:	2b03      	cmp	r3, #3
 8003030:	d00a      	beq.n	8003048 <HAL_RCC_ClockConfig+0xe4>
      if (pClkInitStruct->SYSCLKSource == RCC_SYSCLKSOURCE_HSE)
 8003032:	2b02      	cmp	r3, #2
 8003034:	d02c      	beq.n	8003090 <HAL_RCC_ClockConfig+0x12c>
      else if (pClkInitStruct->SYSCLKSource == RCC_SYSCLKSOURCE_CSI)
 8003036:	2b01      	cmp	r3, #1
 8003038:	d031      	beq.n	800309e <HAL_RCC_ClockConfig+0x13a>
        if (READ_BIT(RCC->CR, RCC_CR_HSIRDY) == 0U)
 800303a:	4a6c      	ldr	r2, [pc, #432]	@ (80031ec <HAL_RCC_ClockConfig+0x288>)
 800303c:	6812      	ldr	r2, [r2, #0]
 800303e:	f012 0f02 	tst.w	r2, #2
 8003042:	d107      	bne.n	8003054 <HAL_RCC_ClockConfig+0xf0>
          return HAL_ERROR;
 8003044:	2001      	movs	r0, #1
 8003046:	e0c6      	b.n	80031d6 <HAL_RCC_ClockConfig+0x272>
      if (READ_BIT(RCC->CR, RCC_CR_PLL1RDY) == 0U)
 8003048:	4a68      	ldr	r2, [pc, #416]	@ (80031ec <HAL_RCC_ClockConfig+0x288>)
 800304a:	6812      	ldr	r2, [r2, #0]
 800304c:	f012 7f00 	tst.w	r2, #33554432	@ 0x2000000
 8003050:	f000 80c6 	beq.w	80031e0 <HAL_RCC_ClockConfig+0x27c>
    MODIFY_REG(RCC->CFGR1, RCC_CFGR1_SW, pClkInitStruct->SYSCLKSource);
 8003054:	4965      	ldr	r1, [pc, #404]	@ (80031ec <HAL_RCC_ClockConfig+0x288>)
 8003056:	69ca      	ldr	r2, [r1, #28]
 8003058:	f022 0203 	bic.w	r2, r2, #3
 800305c:	4313      	orrs	r3, r2
 800305e:	61cb      	str	r3, [r1, #28]
    tickstart = HAL_GetTick();
 8003060:	f7ff fe8e 	bl	8002d80 <HAL_GetTick>
 8003064:	4606      	mov	r6, r0
    if (pClkInitStruct->SYSCLKSource == RCC_SYSCLKSOURCE_PLLCLK)
 8003066:	6863      	ldr	r3, [r4, #4]
 8003068:	2b03      	cmp	r3, #3
 800306a:	d01f      	beq.n	80030ac <HAL_RCC_ClockConfig+0x148>
      if (pClkInitStruct->SYSCLKSource == RCC_SYSCLKSOURCE_HSE)
 800306c:	2b02      	cmp	r3, #2
 800306e:	d02c      	beq.n	80030ca <HAL_RCC_ClockConfig+0x166>
      else if (pClkInitStruct->SYSCLKSource == RCC_SYSCLKSOURCE_CSI)
 8003070:	2b01      	cmp	r3, #1
 8003072:	d039      	beq.n	80030e8 <HAL_RCC_ClockConfig+0x184>
        while (__HAL_RCC_GET_SYSCLK_SOURCE() != RCC_SYSCLKSOURCE_STATUS_HSI)
 8003074:	4b5d      	ldr	r3, [pc, #372]	@ (80031ec <HAL_RCC_ClockConfig+0x288>)
 8003076:	69db      	ldr	r3, [r3, #28]
 8003078:	f013 0f18 	tst.w	r3, #24
 800307c:	d043      	beq.n	8003106 <HAL_RCC_ClockConfig+0x1a2>
          if ((HAL_GetTick() - tickstart) > RCC_CLOCKSWITCH_TIMEOUT_VALUE)
 800307e:	f7ff fe7f 	bl	8002d80 <HAL_GetTick>
 8003082:	1b80      	subs	r0, r0, r6
 8003084:	f241 3388 	movw	r3, #5000	@ 0x1388
 8003088:	4298      	cmp	r0, r3
 800308a:	d9f3      	bls.n	8003074 <HAL_RCC_ClockConfig+0x110>
            return HAL_TIMEOUT;
 800308c:	2003      	movs	r0, #3
 800308e:	e0a2      	b.n	80031d6 <HAL_RCC_ClockConfig+0x272>
        if (READ_BIT(RCC->CR, RCC_CR_HSERDY) == 0U)
 8003090:	4a56      	ldr	r2, [pc, #344]	@ (80031ec <HAL_RCC_ClockConfig+0x288>)
 8003092:	6812      	ldr	r2, [r2, #0]
 8003094:	f412 3f00 	tst.w	r2, #131072	@ 0x20000
 8003098:	d1dc      	bne.n	8003054 <HAL_RCC_ClockConfig+0xf0>
          return HAL_ERROR;
 800309a:	2001      	movs	r0, #1
 800309c:	e09b      	b.n	80031d6 <HAL_RCC_ClockConfig+0x272>
        if (READ_BIT(RCC->CR, RCC_CR_CSIRDY) == 0U)
 800309e:	4a53      	ldr	r2, [pc, #332]	@ (80031ec <HAL_RCC_ClockConfig+0x288>)
 80030a0:	6812      	ldr	r2, [r2, #0]
 80030a2:	f412 7f00 	tst.w	r2, #512	@ 0x200
 80030a6:	d1d5      	bne.n	8003054 <HAL_RCC_ClockConfig+0xf0>
          return HAL_ERROR;
 80030a8:	2001      	movs	r0, #1
 80030aa:	e094      	b.n	80031d6 <HAL_RCC_ClockConfig+0x272>
      while (__HAL_RCC_GET_SYSCLK_SOURCE() != RCC_SYSCLKSOURCE_STATUS_PLLCLK)
 80030ac:	4b4f      	ldr	r3, [pc, #316]	@ (80031ec <HAL_RCC_ClockConfig+0x288>)
 80030ae:	69db      	ldr	r3, [r3, #28]
 80030b0:	f003 0318 	and.w	r3, r3, #24
 80030b4:	2b18      	cmp	r3, #24
 80030b6:	d026      	beq.n	8003106 <HAL_RCC_ClockConfig+0x1a2>
        if ((HAL_GetTick() - tickstart) > RCC_CLOCKSWITCH_TIMEOUT_VALUE)
 80030b8:	f7ff fe62 	bl	8002d80 <HAL_GetTick>
 80030bc:	1b83      	subs	r3, r0, r6
 80030be:	f241 3288 	movw	r2, #5000	@ 0x1388
 80030c2:	4293      	cmp	r3, r2
 80030c4:	d9f2      	bls.n	80030ac <HAL_RCC_ClockConfig+0x148>
          return HAL_TIMEOUT;
 80030c6:	2003      	movs	r0, #3
 80030c8:	e085      	b.n	80031d6 <HAL_RCC_ClockConfig+0x272>
        while (__HAL_RCC_GET_SYSCLK_SOURCE() != RCC_SYSCLKSOURCE_STATUS_HSE)
 80030ca:	4b48      	ldr	r3, [pc, #288]	@ (80031ec <HAL_RCC_ClockConfig+0x288>)
 80030cc:	69db      	ldr	r3, [r3, #28]
 80030ce:	f003 0318 	and.w	r3, r3, #24
 80030d2:	2b10      	cmp	r3, #16
 80030d4:	d017      	beq.n	8003106 <HAL_RCC_ClockConfig+0x1a2>
          if ((HAL_GetTick() - tickstart) > RCC_CLOCKSWITCH_TIMEOUT_VALUE)
 80030d6:	f7ff fe53 	bl	8002d80 <HAL_GetTick>
 80030da:	1b80      	subs	r0, r0, r6
 80030dc:	f241 3388 	movw	r3, #5000	@ 0x1388
 80030e0:	4298      	cmp	r0, r3
 80030e2:	d9f2      	bls.n	80030ca <HAL_RCC_ClockConfig+0x166>
            return HAL_TIMEOUT;
 80030e4:	2003      	movs	r0, #3
 80030e6:	e076      	b.n	80031d6 <HAL_RCC_ClockConfig+0x272>
        while (__HAL_RCC_GET_SYSCLK_SOURCE() != RCC_SYSCLKSOURCE_STATUS_CSI)
 80030e8:	4b40      	ldr	r3, [pc, #256]	@ (80031ec <HAL_RCC_ClockConfig+0x288>)
 80030ea:	69db      	ldr	r3, [r3, #28]
 80030ec:	f003 0318 	and.w	r3, r3, #24
 80030f0:	2b08      	cmp	r3, #8
 80030f2:	d008      	beq.n	8003106 <HAL_RCC_ClockConfig+0x1a2>
          if ((HAL_GetTick() - tickstart) > RCC_CLOCKSWITCH_TIMEOUT_VALUE)
 80030f4:	f7ff fe44 	bl	8002d80 <HAL_GetTick>
 80030f8:	1b80      	subs	r0, r0, r6
 80030fa:	f241 3388 	movw	r3, #5000	@ 0x1388
 80030fe:	4298      	cmp	r0, r3
 8003100:	d9f2      	bls.n	80030e8 <HAL_RCC_ClockConfig+0x184>
            return HAL_TIMEOUT;
 8003102:	2003      	movs	r0, #3
 8003104:	e067      	b.n	80031d6 <HAL_RCC_ClockConfig+0x272>
  if (((pClkInitStruct->ClockType) & RCC_CLOCKTYPE_HCLK) == RCC_CLOCKTYPE_HCLK)
 8003106:	6823      	ldr	r3, [r4, #0]
 8003108:	f013 0f02 	tst.w	r3, #2
 800310c:	d00c      	beq.n	8003128 <HAL_RCC_ClockConfig+0x1c4>
    if ((pClkInitStruct->AHBCLKDivider) < (RCC->CFGR2 & RCC_CFGR2_HPRE))
 800310e:	68a2      	ldr	r2, [r4, #8]
 8003110:	4b36      	ldr	r3, [pc, #216]	@ (80031ec <HAL_RCC_ClockConfig+0x288>)
 8003112:	6a1b      	ldr	r3, [r3, #32]
 8003114:	f003 030f 	and.w	r3, r3, #15
 8003118:	429a      	cmp	r2, r3
 800311a:	d205      	bcs.n	8003128 <HAL_RCC_ClockConfig+0x1c4>
      MODIFY_REG(RCC->CFGR2, RCC_CFGR2_HPRE, pClkInitStruct->AHBCLKDivider);
 800311c:	4933      	ldr	r1, [pc, #204]	@ (80031ec <HAL_RCC_ClockConfig+0x288>)
 800311e:	6a0b      	ldr	r3, [r1, #32]
 8003120:	f023 030f 	bic.w	r3, r3, #15
 8003124:	431a      	orrs	r2, r3
 8003126:	620a      	str	r2, [r1, #32]
  if (FLatency < __HAL_FLASH_GET_LATENCY())
 8003128:	4b2f      	ldr	r3, [pc, #188]	@ (80031e8 <HAL_RCC_ClockConfig+0x284>)
 800312a:	681b      	ldr	r3, [r3, #0]
 800312c:	f003 030f 	and.w	r3, r3, #15
 8003130:	42ab      	cmp	r3, r5
 8003132:	d90a      	bls.n	800314a <HAL_RCC_ClockConfig+0x1e6>
    __HAL_FLASH_SET_LATENCY(FLatency);
 8003134:	4a2c      	ldr	r2, [pc, #176]	@ (80031e8 <HAL_RCC_ClockConfig+0x284>)
 8003136:	6813      	ldr	r3, [r2, #0]
 8003138:	f023 030f 	bic.w	r3, r3, #15
 800313c:	432b      	orrs	r3, r5
 800313e:	6013      	str	r3, [r2, #0]
    if (__HAL_FLASH_GET_LATENCY() != FLatency)
 8003140:	6813      	ldr	r3, [r2, #0]
 8003142:	f003 030f 	and.w	r3, r3, #15
 8003146:	42ab      	cmp	r3, r5
 8003148:	d14c      	bne.n	80031e4 <HAL_RCC_ClockConfig+0x280>
  if (((pClkInitStruct->ClockType) & RCC_CLOCKTYPE_PCLK1) == RCC_CLOCKTYPE_PCLK1)
 800314a:	6823      	ldr	r3, [r4, #0]
 800314c:	f013 0f04 	tst.w	r3, #4
 8003150:	d00c      	beq.n	800316c <HAL_RCC_ClockConfig+0x208>
    if ((pClkInitStruct->APB1CLKDivider) < (RCC->CFGR2 & RCC_CFGR2_PPRE1))
 8003152:	68e2      	ldr	r2, [r4, #12]
 8003154:	4b25      	ldr	r3, [pc, #148]	@ (80031ec <HAL_RCC_ClockConfig+0x288>)
 8003156:	6a1b      	ldr	r3, [r3, #32]
 8003158:	f003 0370 	and.w	r3, r3, #112	@ 0x70
 800315c:	429a      	cmp	r2, r3
 800315e:	d205      	bcs.n	800316c <HAL_RCC_ClockConfig+0x208>
      MODIFY_REG(RCC->CFGR2, RCC_CFGR2_PPRE1, pClkInitStruct->APB1CLKDivider);
 8003160:	4922      	ldr	r1, [pc, #136]	@ (80031ec <HAL_RCC_ClockConfig+0x288>)
 8003162:	6a0b      	ldr	r3, [r1, #32]
 8003164:	f023 0370 	bic.w	r3, r3, #112	@ 0x70
 8003168:	431a      	orrs	r2, r3
 800316a:	620a      	str	r2, [r1, #32]
  if (((pClkInitStruct->ClockType) & RCC_CLOCKTYPE_PCLK2) == RCC_CLOCKTYPE_PCLK2)
 800316c:	6823      	ldr	r3, [r4, #0]
 800316e:	f013 0f08 	tst.w	r3, #8
 8003172:	d00e      	beq.n	8003192 <HAL_RCC_ClockConfig+0x22e>
    if ((pClkInitStruct->APB2CLKDivider) < ((RCC->CFGR2 & RCC_CFGR2_PPRE2) >> 4))
 8003174:	6922      	ldr	r2, [r4, #16]
 8003176:	4b1d      	ldr	r3, [pc, #116]	@ (80031ec <HAL_RCC_ClockConfig+0x288>)
 8003178:	6a1b      	ldr	r3, [r3, #32]
 800317a:	091b      	lsrs	r3, r3, #4
 800317c:	f003 0370 	and.w	r3, r3, #112	@ 0x70
 8003180:	429a      	cmp	r2, r3
 8003182:	d206      	bcs.n	8003192 <HAL_RCC_ClockConfig+0x22e>
      MODIFY_REG(RCC->CFGR2, RCC_CFGR2_PPRE2, ((pClkInitStruct->APB2CLKDivider) << 4));
 8003184:	4919      	ldr	r1, [pc, #100]	@ (80031ec <HAL_RCC_ClockConfig+0x288>)
 8003186:	6a0b      	ldr	r3, [r1, #32]
 8003188:	f423 63e0 	bic.w	r3, r3, #1792	@ 0x700
 800318c:	ea43 1302 	orr.w	r3, r3, r2, lsl #4
 8003190:	620b      	str	r3, [r1, #32]
  if (((pClkInitStruct->ClockType) & RCC_CLOCKTYPE_PCLK3) == RCC_CLOCKTYPE_PCLK3)
 8003192:	6823      	ldr	r3, [r4, #0]
 8003194:	f013 0f10 	tst.w	r3, #16
 8003198:	d00e      	beq.n	80031b8 <HAL_RCC_ClockConfig+0x254>
    if ((pClkInitStruct->APB3CLKDivider) < ((RCC->CFGR2 & RCC_CFGR2_PPRE3) >> 8))
 800319a:	6962      	ldr	r2, [r4, #20]
 800319c:	4b13      	ldr	r3, [pc, #76]	@ (80031ec <HAL_RCC_ClockConfig+0x288>)
 800319e:	6a1b      	ldr	r3, [r3, #32]
 80031a0:	0a1b      	lsrs	r3, r3, #8
 80031a2:	f003 0370 	and.w	r3, r3, #112	@ 0x70
 80031a6:	429a      	cmp	r2, r3
 80031a8:	d206      	bcs.n	80031b8 <HAL_RCC_ClockConfig+0x254>
      MODIFY_REG(RCC->CFGR2, RCC_CFGR2_PPRE3, ((pClkInitStruct->APB3CLKDivider) << 8));
 80031aa:	4910      	ldr	r1, [pc, #64]	@ (80031ec <HAL_RCC_ClockConfig+0x288>)
 80031ac:	6a0b      	ldr	r3, [r1, #32]
 80031ae:	f423 43e0 	bic.w	r3, r3, #28672	@ 0x7000
 80031b2:	ea43 2302 	orr.w	r3, r3, r2, lsl #8
 80031b6:	620b      	str	r3, [r1, #32]
  SystemCoreClock = HAL_RCC_GetSysClockFreq() >> AHBPrescTable[(RCC->CFGR2 & RCC_CFGR2_HPRE) >> RCC_CFGR2_HPRE_Pos];
 80031b8:	f7ff fde8 	bl	8002d8c <HAL_RCC_GetSysClockFreq>
 80031bc:	4b0b      	ldr	r3, [pc, #44]	@ (80031ec <HAL_RCC_ClockConfig+0x288>)
 80031be:	6a1b      	ldr	r3, [r3, #32]
 80031c0:	f003 030f 	and.w	r3, r3, #15
 80031c4:	4a0a      	ldr	r2, [pc, #40]	@ (80031f0 <HAL_RCC_ClockConfig+0x28c>)
 80031c6:	5cd3      	ldrb	r3, [r2, r3]
 80031c8:	40d8      	lsrs	r0, r3
 80031ca:	4b0a      	ldr	r3, [pc, #40]	@ (80031f4 <HAL_RCC_ClockConfig+0x290>)
 80031cc:	6018      	str	r0, [r3, #0]
  halstatus = HAL_InitTick(uwTickPrio);
 80031ce:	4b0a      	ldr	r3, [pc, #40]	@ (80031f8 <HAL_RCC_ClockConfig+0x294>)
 80031d0:	6818      	ldr	r0, [r3, #0]
 80031d2:	f7ff fd4f 	bl	8002c74 <HAL_InitTick>
}
 80031d6:	bd70      	pop	{r4, r5, r6, pc}
    return HAL_ERROR;
 80031d8:	2001      	movs	r0, #1
}
 80031da:	4770      	bx	lr
      return HAL_ERROR;
 80031dc:	2001      	movs	r0, #1
 80031de:	e7fa      	b.n	80031d6 <HAL_RCC_ClockConfig+0x272>
        return HAL_ERROR;
 80031e0:	2001      	movs	r0, #1
 80031e2:	e7f8      	b.n	80031d6 <HAL_RCC_ClockConfig+0x272>
      return HAL_ERROR;
 80031e4:	2001      	movs	r0, #1
 80031e6:	e7f6      	b.n	80031d6 <HAL_RCC_ClockConfig+0x272>
 80031e8:	40022000 	.word	0x40022000
 80031ec:	44020c00 	.word	0x44020c00
 80031f0:	080081e0 	.word	0x080081e0
 80031f4:	20000000 	.word	0x20000000
 80031f8:	20000090 	.word	0x20000090

080031fc <HAL_RCC_GetHCLKFreq>:
  *
  * @note   The SystemCoreClock CMSIS variable is used to store System Clock Frequency.
  * @retval HCLK frequency in Hz
  */
uint32_t HAL_RCC_GetHCLKFreq(void)
{
 80031fc:	b508      	push	{r3, lr}

  SystemCoreClock = HAL_RCC_GetSysClockFreq() >> (AHBPrescTable[(RCC->CFGR2 & RCC_CFGR2_HPRE) \
 80031fe:	f7ff fdc5 	bl	8002d8c <HAL_RCC_GetSysClockFreq>
 8003202:	4b06      	ldr	r3, [pc, #24]	@ (800321c <HAL_RCC_GetHCLKFreq+0x20>)
 8003204:	6a1b      	ldr	r3, [r3, #32]
                                                                >> RCC_CFGR2_HPRE_Pos] & 0x1FU);
 8003206:	f003 030f 	and.w	r3, r3, #15
  SystemCoreClock = HAL_RCC_GetSysClockFreq() >> (AHBPrescTable[(RCC->CFGR2 & RCC_CFGR2_HPRE) \
 800320a:	4a05      	ldr	r2, [pc, #20]	@ (8003220 <HAL_RCC_GetHCLKFreq+0x24>)
 800320c:	5cd3      	ldrb	r3, [r2, r3]
                                                                >> RCC_CFGR2_HPRE_Pos] & 0x1FU);
 800320e:	f003 031f 	and.w	r3, r3, #31
  SystemCoreClock = HAL_RCC_GetSysClockFreq() >> (AHBPrescTable[(RCC->CFGR2 & RCC_CFGR2_HPRE) \
 8003212:	40d8      	lsrs	r0, r3
 8003214:	4b03      	ldr	r3, [pc, #12]	@ (8003224 <HAL_RCC_GetHCLKFreq+0x28>)
 8003216:	6018      	str	r0, [r3, #0]

  return SystemCoreClock;
}
 8003218:	bd08      	pop	{r3, pc}
 800321a:	bf00      	nop
 800321c:	44020c00 	.word	0x44020c00
 8003220:	080081e0 	.word	0x080081e0
 8003224:	20000000 	.word	0x20000000

08003228 <HAL_RCC_OscConfig>:
  if (pOscInitStruct == NULL)
 8003228:	2800      	cmp	r0, #0
 800322a:	f000 8328 	beq.w	800387e <HAL_RCC_OscConfig+0x656>
{
 800322e:	b5f8      	push	{r3, r4, r5, r6, r7, lr}
 8003230:	4604      	mov	r4, r0
  temp_sysclksrc = __HAL_RCC_GET_SYSCLK_SOURCE();
 8003232:	4ba2      	ldr	r3, [pc, #648]	@ (80034bc <HAL_RCC_OscConfig+0x294>)
 8003234:	69dd      	ldr	r5, [r3, #28]
 8003236:	f005 0518 	and.w	r5, r5, #24
  temp_pllckselr = __HAL_RCC_GET_PLL1_OSCSOURCE();
 800323a:	6a9e      	ldr	r6, [r3, #40]	@ 0x28
 800323c:	f006 0603 	and.w	r6, r6, #3
  if (((pOscInitStruct->OscillatorType) & RCC_OSCILLATORTYPE_CSI) == RCC_OSCILLATORTYPE_CSI)
 8003240:	6803      	ldr	r3, [r0, #0]
 8003242:	f013 0f10 	tst.w	r3, #16
 8003246:	d028      	beq.n	800329a <HAL_RCC_OscConfig+0x72>
    if ((temp_sysclksrc == RCC_SYSCLKSOURCE_STATUS_CSI) ||
 8003248:	2d08      	cmp	r5, #8
 800324a:	d01a      	beq.n	8003282 <HAL_RCC_OscConfig+0x5a>
 800324c:	2d18      	cmp	r5, #24
 800324e:	d016      	beq.n	800327e <HAL_RCC_OscConfig+0x56>
      if ((pOscInitStruct->CSIState) != RCC_CSI_OFF)
 8003250:	69e3      	ldr	r3, [r4, #28]
 8003252:	2b00      	cmp	r3, #0
 8003254:	d046      	beq.n	80032e4 <HAL_RCC_OscConfig+0xbc>
        __HAL_RCC_CSI_ENABLE();
 8003256:	4a99      	ldr	r2, [pc, #612]	@ (80034bc <HAL_RCC_OscConfig+0x294>)
 8003258:	6813      	ldr	r3, [r2, #0]
 800325a:	f443 7380 	orr.w	r3, r3, #256	@ 0x100
 800325e:	6013      	str	r3, [r2, #0]
        tickstart = HAL_GetTick();
 8003260:	f7ff fd8e 	bl	8002d80 <HAL_GetTick>
 8003264:	4607      	mov	r7, r0
        while (READ_BIT(RCC->CR, RCC_CR_CSIRDY) == 0U)
 8003266:	4b95      	ldr	r3, [pc, #596]	@ (80034bc <HAL_RCC_OscConfig+0x294>)
 8003268:	681b      	ldr	r3, [r3, #0]
 800326a:	f413 7f00 	tst.w	r3, #512	@ 0x200
 800326e:	d130      	bne.n	80032d2 <HAL_RCC_OscConfig+0xaa>
          if ((HAL_GetTick() - tickstart) > RCC_CSI_TIMEOUT_VALUE)
 8003270:	f7ff fd86 	bl	8002d80 <HAL_GetTick>
 8003274:	1bc0      	subs	r0, r0, r7
 8003276:	2802      	cmp	r0, #2
 8003278:	d9f5      	bls.n	8003266 <HAL_RCC_OscConfig+0x3e>
            return HAL_TIMEOUT;
 800327a:	2003      	movs	r0, #3
 800327c:	e308      	b.n	8003890 <HAL_RCC_OscConfig+0x668>
        ((temp_sysclksrc == RCC_SYSCLKSOURCE_STATUS_PLLCLK) && (temp_pllckselr == RCC_PLL1_SOURCE_CSI)))
 800327e:	2e02      	cmp	r6, #2
 8003280:	d1e6      	bne.n	8003250 <HAL_RCC_OscConfig+0x28>
      if (pOscInitStruct->CSIState == RCC_CSI_OFF)
 8003282:	69e3      	ldr	r3, [r4, #28]
 8003284:	2b00      	cmp	r3, #0
 8003286:	f000 82fc 	beq.w	8003882 <HAL_RCC_OscConfig+0x65a>
        __HAL_RCC_CSI_CALIBRATIONVALUE_ADJUST(pOscInitStruct->CSICalibrationValue);
 800328a:	4a8c      	ldr	r2, [pc, #560]	@ (80034bc <HAL_RCC_OscConfig+0x294>)
 800328c:	6993      	ldr	r3, [r2, #24]
 800328e:	f423 137c 	bic.w	r3, r3, #4128768	@ 0x3f0000
 8003292:	6a21      	ldr	r1, [r4, #32]
 8003294:	ea43 4301 	orr.w	r3, r3, r1, lsl #16
 8003298:	6193      	str	r3, [r2, #24]
  if (((pOscInitStruct->OscillatorType) & RCC_OSCILLATORTYPE_HSE) == RCC_OSCILLATORTYPE_HSE)
 800329a:	6823      	ldr	r3, [r4, #0]
 800329c:	f013 0f01 	tst.w	r3, #1
 80032a0:	d03a      	beq.n	8003318 <HAL_RCC_OscConfig+0xf0>
    if ((temp_sysclksrc == RCC_SYSCLKSOURCE_STATUS_HSE) ||
 80032a2:	2d10      	cmp	r5, #16
 80032a4:	d034      	beq.n	8003310 <HAL_RCC_OscConfig+0xe8>
 80032a6:	2d18      	cmp	r5, #24
 80032a8:	d030      	beq.n	800330c <HAL_RCC_OscConfig+0xe4>
      __HAL_RCC_HSE_CONFIG(pOscInitStruct->HSEState);
 80032aa:	6863      	ldr	r3, [r4, #4]
 80032ac:	f5b3 3f80 	cmp.w	r3, #65536	@ 0x10000
 80032b0:	d05a      	beq.n	8003368 <HAL_RCC_OscConfig+0x140>
 80032b2:	2b00      	cmp	r3, #0
 80032b4:	d16f      	bne.n	8003396 <HAL_RCC_OscConfig+0x16e>
 80032b6:	4b81      	ldr	r3, [pc, #516]	@ (80034bc <HAL_RCC_OscConfig+0x294>)
 80032b8:	681a      	ldr	r2, [r3, #0]
 80032ba:	f422 3280 	bic.w	r2, r2, #65536	@ 0x10000
 80032be:	601a      	str	r2, [r3, #0]
 80032c0:	681a      	ldr	r2, [r3, #0]
 80032c2:	f422 1280 	bic.w	r2, r2, #1048576	@ 0x100000
 80032c6:	601a      	str	r2, [r3, #0]
 80032c8:	681a      	ldr	r2, [r3, #0]
 80032ca:	f422 2280 	bic.w	r2, r2, #262144	@ 0x40000
 80032ce:	601a      	str	r2, [r3, #0]
 80032d0:	e04f      	b.n	8003372 <HAL_RCC_OscConfig+0x14a>
        __HAL_RCC_CSI_CALIBRATIONVALUE_ADJUST(pOscInitStruct->CSICalibrationValue);
 80032d2:	4a7a      	ldr	r2, [pc, #488]	@ (80034bc <HAL_RCC_OscConfig+0x294>)
 80032d4:	6993      	ldr	r3, [r2, #24]
 80032d6:	f423 137c 	bic.w	r3, r3, #4128768	@ 0x3f0000
 80032da:	6a21      	ldr	r1, [r4, #32]
 80032dc:	ea43 4301 	orr.w	r3, r3, r1, lsl #16
 80032e0:	6193      	str	r3, [r2, #24]
 80032e2:	e7da      	b.n	800329a <HAL_RCC_OscConfig+0x72>
        __HAL_RCC_CSI_DISABLE();
 80032e4:	4a75      	ldr	r2, [pc, #468]	@ (80034bc <HAL_RCC_OscConfig+0x294>)
 80032e6:	6813      	ldr	r3, [r2, #0]
 80032e8:	f423 7380 	bic.w	r3, r3, #256	@ 0x100
 80032ec:	6013      	str	r3, [r2, #0]
        tickstart = HAL_GetTick();
 80032ee:	f7ff fd47 	bl	8002d80 <HAL_GetTick>
 80032f2:	4607      	mov	r7, r0
        while (READ_BIT(RCC->CR, RCC_CR_CSIRDY) != 0U)
 80032f4:	4b71      	ldr	r3, [pc, #452]	@ (80034bc <HAL_RCC_OscConfig+0x294>)
 80032f6:	681b      	ldr	r3, [r3, #0]
 80032f8:	f413 7f00 	tst.w	r3, #512	@ 0x200
 80032fc:	d0cd      	beq.n	800329a <HAL_RCC_OscConfig+0x72>
          if ((HAL_GetTick() - tickstart) > RCC_CSI_TIMEOUT_VALUE)
 80032fe:	f7ff fd3f 	bl	8002d80 <HAL_GetTick>
 8003302:	1bc0      	subs	r0, r0, r7
 8003304:	2802      	cmp	r0, #2
 8003306:	d9f5      	bls.n	80032f4 <HAL_RCC_OscConfig+0xcc>
            return HAL_TIMEOUT;
 8003308:	2003      	movs	r0, #3
 800330a:	e2c1      	b.n	8003890 <HAL_RCC_OscConfig+0x668>
        ((temp_sysclksrc == RCC_SYSCLKSOURCE_STATUS_PLLCLK) && (temp_pllckselr == RCC_PLL1_SOURCE_HSE)))
 800330c:	2e03      	cmp	r6, #3
 800330e:	d1cc      	bne.n	80032aa <HAL_RCC_OscConfig+0x82>
      if (pOscInitStruct->HSEState == RCC_HSE_OFF)
 8003310:	6863      	ldr	r3, [r4, #4]
 8003312:	2b00      	cmp	r3, #0
 8003314:	f000 82b7 	beq.w	8003886 <HAL_RCC_OscConfig+0x65e>
  if (((pOscInitStruct->OscillatorType) & RCC_OSCILLATORTYPE_HSI) == RCC_OSCILLATORTYPE_HSI)
 8003318:	6823      	ldr	r3, [r4, #0]
 800331a:	f013 0f02 	tst.w	r3, #2
 800331e:	f000 80ae 	beq.w	800347e <HAL_RCC_OscConfig+0x256>
    if ((temp_sysclksrc == RCC_SYSCLKSOURCE_STATUS_HSI) ||
 8003322:	2d00      	cmp	r5, #0
 8003324:	d078      	beq.n	8003418 <HAL_RCC_OscConfig+0x1f0>
 8003326:	2d18      	cmp	r5, #24
 8003328:	d074      	beq.n	8003414 <HAL_RCC_OscConfig+0x1ec>
      if (pOscInitStruct->HSIState != RCC_HSI_OFF)
 800332a:	68e3      	ldr	r3, [r4, #12]
 800332c:	2b00      	cmp	r3, #0
 800332e:	f000 80d2 	beq.w	80034d6 <HAL_RCC_OscConfig+0x2ae>
        __HAL_RCC_HSI_DIVIDER_CONFIG(pOscInitStruct->HSIDiv);
 8003332:	4a62      	ldr	r2, [pc, #392]	@ (80034bc <HAL_RCC_OscConfig+0x294>)
 8003334:	6813      	ldr	r3, [r2, #0]
 8003336:	f023 0318 	bic.w	r3, r3, #24
 800333a:	6921      	ldr	r1, [r4, #16]
 800333c:	430b      	orrs	r3, r1
 800333e:	6013      	str	r3, [r2, #0]
        __HAL_RCC_HSI_ENABLE();
 8003340:	6813      	ldr	r3, [r2, #0]
 8003342:	f043 0301 	orr.w	r3, r3, #1
 8003346:	6013      	str	r3, [r2, #0]
        tickstart = HAL_GetTick();
 8003348:	f7ff fd1a 	bl	8002d80 <HAL_GetTick>
 800334c:	4606      	mov	r6, r0
        while (READ_BIT(RCC->CR, RCC_CR_HSIRDY) == 0U)
 800334e:	4b5b      	ldr	r3, [pc, #364]	@ (80034bc <HAL_RCC_OscConfig+0x294>)
 8003350:	681b      	ldr	r3, [r3, #0]
 8003352:	f013 0f02 	tst.w	r3, #2
 8003356:	f040 80b5 	bne.w	80034c4 <HAL_RCC_OscConfig+0x29c>
          if ((HAL_GetTick() - tickstart) > RCC_HSI_TIMEOUT_VALUE)
 800335a:	f7ff fd11 	bl	8002d80 <HAL_GetTick>
 800335e:	1b80      	subs	r0, r0, r6
 8003360:	2802      	cmp	r0, #2
 8003362:	d9f4      	bls.n	800334e <HAL_RCC_OscConfig+0x126>
            return HAL_TIMEOUT;
 8003364:	2003      	movs	r0, #3
 8003366:	e293      	b.n	8003890 <HAL_RCC_OscConfig+0x668>
      __HAL_RCC_HSE_CONFIG(pOscInitStruct->HSEState);
 8003368:	4a54      	ldr	r2, [pc, #336]	@ (80034bc <HAL_RCC_OscConfig+0x294>)
 800336a:	6813      	ldr	r3, [r2, #0]
 800336c:	f443 3380 	orr.w	r3, r3, #65536	@ 0x10000
 8003370:	6013      	str	r3, [r2, #0]
      if (pOscInitStruct->HSEState != RCC_HSE_OFF)
 8003372:	6863      	ldr	r3, [r4, #4]
 8003374:	2b00      	cmp	r3, #0
 8003376:	d03e      	beq.n	80033f6 <HAL_RCC_OscConfig+0x1ce>
        tickstart = HAL_GetTick();
 8003378:	f7ff fd02 	bl	8002d80 <HAL_GetTick>
 800337c:	4607      	mov	r7, r0
        while (READ_BIT(RCC->CR, RCC_CR_HSERDY) == 0U)
 800337e:	4b4f      	ldr	r3, [pc, #316]	@ (80034bc <HAL_RCC_OscConfig+0x294>)
 8003380:	681b      	ldr	r3, [r3, #0]
 8003382:	f413 3f00 	tst.w	r3, #131072	@ 0x20000
 8003386:	d1c7      	bne.n	8003318 <HAL_RCC_OscConfig+0xf0>
          if ((HAL_GetTick() - tickstart) > RCC_HSE_TIMEOUT_VALUE)
 8003388:	f7ff fcfa 	bl	8002d80 <HAL_GetTick>
 800338c:	1bc0      	subs	r0, r0, r7
 800338e:	2864      	cmp	r0, #100	@ 0x64
 8003390:	d9f5      	bls.n	800337e <HAL_RCC_OscConfig+0x156>
            return HAL_TIMEOUT;
 8003392:	2003      	movs	r0, #3
 8003394:	e27c      	b.n	8003890 <HAL_RCC_OscConfig+0x668>
      __HAL_RCC_HSE_CONFIG(pOscInitStruct->HSEState);
 8003396:	f5b3 2fa0 	cmp.w	r3, #327680	@ 0x50000
 800339a:	d010      	beq.n	80033be <HAL_RCC_OscConfig+0x196>
 800339c:	f5b3 1fa8 	cmp.w	r3, #1376256	@ 0x150000
 80033a0:	d01b      	beq.n	80033da <HAL_RCC_OscConfig+0x1b2>
 80033a2:	4b46      	ldr	r3, [pc, #280]	@ (80034bc <HAL_RCC_OscConfig+0x294>)
 80033a4:	681a      	ldr	r2, [r3, #0]
 80033a6:	f422 3280 	bic.w	r2, r2, #65536	@ 0x10000
 80033aa:	601a      	str	r2, [r3, #0]
 80033ac:	681a      	ldr	r2, [r3, #0]
 80033ae:	f422 2280 	bic.w	r2, r2, #262144	@ 0x40000
 80033b2:	601a      	str	r2, [r3, #0]
 80033b4:	681a      	ldr	r2, [r3, #0]
 80033b6:	f422 1280 	bic.w	r2, r2, #1048576	@ 0x100000
 80033ba:	601a      	str	r2, [r3, #0]
 80033bc:	e7d9      	b.n	8003372 <HAL_RCC_OscConfig+0x14a>
 80033be:	4b3f      	ldr	r3, [pc, #252]	@ (80034bc <HAL_RCC_OscConfig+0x294>)
 80033c0:	681a      	ldr	r2, [r3, #0]
 80033c2:	f442 2280 	orr.w	r2, r2, #262144	@ 0x40000
 80033c6:	601a      	str	r2, [r3, #0]
 80033c8:	681a      	ldr	r2, [r3, #0]
 80033ca:	f422 1280 	bic.w	r2, r2, #1048576	@ 0x100000
 80033ce:	601a      	str	r2, [r3, #0]
 80033d0:	681a      	ldr	r2, [r3, #0]
 80033d2:	f442 3280 	orr.w	r2, r2, #65536	@ 0x10000
 80033d6:	601a      	str	r2, [r3, #0]
 80033d8:	e7cb      	b.n	8003372 <HAL_RCC_OscConfig+0x14a>
 80033da:	4b38      	ldr	r3, [pc, #224]	@ (80034bc <HAL_RCC_OscConfig+0x294>)
 80033dc:	681a      	ldr	r2, [r3, #0]
 80033de:	f442 2280 	orr.w	r2, r2, #262144	@ 0x40000
 80033e2:	601a      	str	r2, [r3, #0]
 80033e4:	681a      	ldr	r2, [r3, #0]
 80033e6:	f442 1280 	orr.w	r2, r2, #1048576	@ 0x100000
 80033ea:	601a      	str	r2, [r3, #0]
 80033ec:	681a      	ldr	r2, [r3, #0]
 80033ee:	f442 3280 	orr.w	r2, r2, #65536	@ 0x10000
 80033f2:	601a      	str	r2, [r3, #0]
 80033f4:	e7bd      	b.n	8003372 <HAL_RCC_OscConfig+0x14a>
        tickstart = HAL_GetTick();
 80033f6:	f7ff fcc3 	bl	8002d80 <HAL_GetTick>
 80033fa:	4607      	mov	r7, r0
        while (READ_BIT(RCC->CR, RCC_CR_HSERDY) != 0U)
 80033fc:	4b2f      	ldr	r3, [pc, #188]	@ (80034bc <HAL_RCC_OscConfig+0x294>)
 80033fe:	681b      	ldr	r3, [r3, #0]
 8003400:	f413 3f00 	tst.w	r3, #131072	@ 0x20000
 8003404:	d088      	beq.n	8003318 <HAL_RCC_OscConfig+0xf0>
          if ((HAL_GetTick() - tickstart) > RCC_HSE_TIMEOUT_VALUE)
 8003406:	f7ff fcbb 	bl	8002d80 <HAL_GetTick>
 800340a:	1bc0      	subs	r0, r0, r7
 800340c:	2864      	cmp	r0, #100	@ 0x64
 800340e:	d9f5      	bls.n	80033fc <HAL_RCC_OscConfig+0x1d4>
            return HAL_TIMEOUT;
 8003410:	2003      	movs	r0, #3
 8003412:	e23d      	b.n	8003890 <HAL_RCC_OscConfig+0x668>
        ((temp_sysclksrc == RCC_SYSCLKSOURCE_STATUS_PLLCLK) && (temp_pllckselr == RCC_PLL1_SOURCE_HSI)))
 8003414:	2e01      	cmp	r6, #1
 8003416:	d188      	bne.n	800332a <HAL_RCC_OscConfig+0x102>
      if (pOscInitStruct->HSIState == RCC_HSI_OFF)
 8003418:	68e3      	ldr	r3, [r4, #12]
 800341a:	2b00      	cmp	r3, #0
 800341c:	f000 8235 	beq.w	800388a <HAL_RCC_OscConfig+0x662>
        if (temp_sysclksrc == RCC_SYSCLKSOURCE_STATUS_HSI)
 8003420:	b935      	cbnz	r5, 8003430 <HAL_RCC_OscConfig+0x208>
          if (__HAL_RCC_GET_HSI_DIVIDER() != (pOscInitStruct->HSIDiv))
 8003422:	4b26      	ldr	r3, [pc, #152]	@ (80034bc <HAL_RCC_OscConfig+0x294>)
 8003424:	681b      	ldr	r3, [r3, #0]
 8003426:	f003 0318 	and.w	r3, r3, #24
 800342a:	6922      	ldr	r2, [r4, #16]
 800342c:	4293      	cmp	r3, r2
 800342e:	d10e      	bne.n	800344e <HAL_RCC_OscConfig+0x226>
        tickstart = HAL_GetTick();
 8003430:	f7ff fca6 	bl	8002d80 <HAL_GetTick>
 8003434:	4606      	mov	r6, r0
        while (READ_BIT(RCC->CR, RCC_CR_HSIRDY) == 0U)
 8003436:	4b21      	ldr	r3, [pc, #132]	@ (80034bc <HAL_RCC_OscConfig+0x294>)
 8003438:	681b      	ldr	r3, [r3, #0]
 800343a:	f013 0f02 	tst.w	r3, #2
 800343e:	d116      	bne.n	800346e <HAL_RCC_OscConfig+0x246>
          if ((HAL_GetTick() - tickstart) > RCC_HSI_TIMEOUT_VALUE)
 8003440:	f7ff fc9e 	bl	8002d80 <HAL_GetTick>
 8003444:	1b80      	subs	r0, r0, r6
 8003446:	2802      	cmp	r0, #2
 8003448:	d9f5      	bls.n	8003436 <HAL_RCC_OscConfig+0x20e>
            return HAL_TIMEOUT;
 800344a:	2003      	movs	r0, #3
 800344c:	e220      	b.n	8003890 <HAL_RCC_OscConfig+0x668>
            __HAL_RCC_HSI_DIVIDER_CONFIG(pOscInitStruct->HSIDiv);
 800344e:	491b      	ldr	r1, [pc, #108]	@ (80034bc <HAL_RCC_OscConfig+0x294>)
 8003450:	680b      	ldr	r3, [r1, #0]
 8003452:	f023 0318 	bic.w	r3, r3, #24
 8003456:	431a      	orrs	r2, r3
 8003458:	600a      	str	r2, [r1, #0]
            (void) HAL_RCC_GetHCLKFreq();
 800345a:	f7ff fecf 	bl	80031fc <HAL_RCC_GetHCLKFreq>
            if (HAL_InitTick(uwTickPrio) != HAL_OK)
 800345e:	4b18      	ldr	r3, [pc, #96]	@ (80034c0 <HAL_RCC_OscConfig+0x298>)
 8003460:	6818      	ldr	r0, [r3, #0]
 8003462:	f7ff fc07 	bl	8002c74 <HAL_InitTick>
 8003466:	2800      	cmp	r0, #0
 8003468:	d0e2      	beq.n	8003430 <HAL_RCC_OscConfig+0x208>
              return HAL_ERROR;
 800346a:	2001      	movs	r0, #1
 800346c:	e210      	b.n	8003890 <HAL_RCC_OscConfig+0x668>
        __HAL_RCC_HSI_CALIBRATIONVALUE_ADJUST(pOscInitStruct->HSICalibrationValue);
 800346e:	4a13      	ldr	r2, [pc, #76]	@ (80034bc <HAL_RCC_OscConfig+0x294>)
 8003470:	6913      	ldr	r3, [r2, #16]
 8003472:	f423 03fe 	bic.w	r3, r3, #8323072	@ 0x7f0000
 8003476:	6961      	ldr	r1, [r4, #20]
 8003478:	ea43 4301 	orr.w	r3, r3, r1, lsl #16
 800347c:	6113      	str	r3, [r2, #16]
  if (((pOscInitStruct->OscillatorType) & RCC_OSCILLATORTYPE_LSI) == RCC_OSCILLATORTYPE_LSI)
 800347e:	6823      	ldr	r3, [r4, #0]
 8003480:	f013 0f08 	tst.w	r3, #8
 8003484:	d052      	beq.n	800352c <HAL_RCC_OscConfig+0x304>
    if (pOscInitStruct->LSIState != RCC_LSI_OFF)
 8003486:	69a3      	ldr	r3, [r4, #24]
 8003488:	2b00      	cmp	r3, #0
 800348a:	d038      	beq.n	80034fe <HAL_RCC_OscConfig+0x2d6>
      __HAL_RCC_LSI_ENABLE();
 800348c:	4a0b      	ldr	r2, [pc, #44]	@ (80034bc <HAL_RCC_OscConfig+0x294>)
 800348e:	f8d2 30f0 	ldr.w	r3, [r2, #240]	@ 0xf0
 8003492:	f043 6380 	orr.w	r3, r3, #67108864	@ 0x4000000
 8003496:	f8c2 30f0 	str.w	r3, [r2, #240]	@ 0xf0
      tickstart = HAL_GetTick();
 800349a:	f7ff fc71 	bl	8002d80 <HAL_GetTick>
 800349e:	4606      	mov	r6, r0
      while (READ_BIT(RCC->BDCR, RCC_BDCR_LSIRDY) == 0U)
 80034a0:	4b06      	ldr	r3, [pc, #24]	@ (80034bc <HAL_RCC_OscConfig+0x294>)
 80034a2:	f8d3 30f0 	ldr.w	r3, [r3, #240]	@ 0xf0
 80034a6:	f013 6f00 	tst.w	r3, #134217728	@ 0x8000000
 80034aa:	d13f      	bne.n	800352c <HAL_RCC_OscConfig+0x304>
        if ((HAL_GetTick() - tickstart) > RCC_LSI_TIMEOUT_VALUE)
 80034ac:	f7ff fc68 	bl	8002d80 <HAL_GetTick>
 80034b0:	1b80      	subs	r0, r0, r6
 80034b2:	2802      	cmp	r0, #2
 80034b4:	d9f4      	bls.n	80034a0 <HAL_RCC_OscConfig+0x278>
          return HAL_TIMEOUT;
 80034b6:	2003      	movs	r0, #3
 80034b8:	e1ea      	b.n	8003890 <HAL_RCC_OscConfig+0x668>
 80034ba:	bf00      	nop
 80034bc:	44020c00 	.word	0x44020c00
 80034c0:	20000090 	.word	0x20000090
        __HAL_RCC_HSI_CALIBRATIONVALUE_ADJUST(pOscInitStruct->HSICalibrationValue);
 80034c4:	4a9b      	ldr	r2, [pc, #620]	@ (8003734 <HAL_RCC_OscConfig+0x50c>)
 80034c6:	6913      	ldr	r3, [r2, #16]
 80034c8:	f423 03fe 	bic.w	r3, r3, #8323072	@ 0x7f0000
 80034cc:	6961      	ldr	r1, [r4, #20]
 80034ce:	ea43 4301 	orr.w	r3, r3, r1, lsl #16
 80034d2:	6113      	str	r3, [r2, #16]
 80034d4:	e7d3      	b.n	800347e <HAL_RCC_OscConfig+0x256>
        __HAL_RCC_HSI_DISABLE();
 80034d6:	4a97      	ldr	r2, [pc, #604]	@ (8003734 <HAL_RCC_OscConfig+0x50c>)
 80034d8:	6813      	ldr	r3, [r2, #0]
 80034da:	f023 0301 	bic.w	r3, r3, #1
 80034de:	6013      	str	r3, [r2, #0]
        tickstart = HAL_GetTick();
 80034e0:	f7ff fc4e 	bl	8002d80 <HAL_GetTick>
 80034e4:	4606      	mov	r6, r0
        while (READ_BIT(RCC->CR, RCC_CR_HSIRDY) != 0U)
 80034e6:	4b93      	ldr	r3, [pc, #588]	@ (8003734 <HAL_RCC_OscConfig+0x50c>)
 80034e8:	681b      	ldr	r3, [r3, #0]
 80034ea:	f013 0f02 	tst.w	r3, #2
 80034ee:	d0c6      	beq.n	800347e <HAL_RCC_OscConfig+0x256>
          if ((HAL_GetTick() - tickstart) > RCC_HSI_TIMEOUT_VALUE)
 80034f0:	f7ff fc46 	bl	8002d80 <HAL_GetTick>
 80034f4:	1b80      	subs	r0, r0, r6
 80034f6:	2802      	cmp	r0, #2
 80034f8:	d9f5      	bls.n	80034e6 <HAL_RCC_OscConfig+0x2be>
            return HAL_TIMEOUT;
 80034fa:	2003      	movs	r0, #3
 80034fc:	e1c8      	b.n	8003890 <HAL_RCC_OscConfig+0x668>
      __HAL_RCC_LSI_DISABLE();
 80034fe:	4a8d      	ldr	r2, [pc, #564]	@ (8003734 <HAL_RCC_OscConfig+0x50c>)
 8003500:	f8d2 30f0 	ldr.w	r3, [r2, #240]	@ 0xf0
 8003504:	f023 6380 	bic.w	r3, r3, #67108864	@ 0x4000000
 8003508:	f8c2 30f0 	str.w	r3, [r2, #240]	@ 0xf0
      tickstart = HAL_GetTick();
 800350c:	f7ff fc38 	bl	8002d80 <HAL_GetTick>
 8003510:	4606      	mov	r6, r0
      while (READ_BIT(RCC->BDCR, RCC_BDCR_LSIRDY) != 0U)
 8003512:	4b88      	ldr	r3, [pc, #544]	@ (8003734 <HAL_RCC_OscConfig+0x50c>)
 8003514:	f8d3 30f0 	ldr.w	r3, [r3, #240]	@ 0xf0
 8003518:	f013 6f00 	tst.w	r3, #134217728	@ 0x8000000
 800351c:	d006      	beq.n	800352c <HAL_RCC_OscConfig+0x304>
        if ((HAL_GetTick() - tickstart) > RCC_LSI_TIMEOUT_VALUE)
 800351e:	f7ff fc2f 	bl	8002d80 <HAL_GetTick>
 8003522:	1b80      	subs	r0, r0, r6
 8003524:	2802      	cmp	r0, #2
 8003526:	d9f4      	bls.n	8003512 <HAL_RCC_OscConfig+0x2ea>
          return HAL_TIMEOUT;
 8003528:	2003      	movs	r0, #3
 800352a:	e1b1      	b.n	8003890 <HAL_RCC_OscConfig+0x668>
  if (((pOscInitStruct->OscillatorType) & RCC_OSCILLATORTYPE_LSE) == RCC_OSCILLATORTYPE_LSE)
 800352c:	6823      	ldr	r3, [r4, #0]
 800352e:	f013 0f04 	tst.w	r3, #4
 8003532:	f000 80a0 	beq.w	8003676 <HAL_RCC_OscConfig+0x44e>
    if (HAL_IS_BIT_CLR(PWR->DBPCR, PWR_DBPCR_DBP))
 8003536:	4b80      	ldr	r3, [pc, #512]	@ (8003738 <HAL_RCC_OscConfig+0x510>)
 8003538:	6a5b      	ldr	r3, [r3, #36]	@ 0x24
 800353a:	f013 0f01 	tst.w	r3, #1
 800353e:	d018      	beq.n	8003572 <HAL_RCC_OscConfig+0x34a>
    __HAL_RCC_LSE_CONFIG(pOscInitStruct->LSEState);
 8003540:	68a3      	ldr	r3, [r4, #8]
 8003542:	2b01      	cmp	r3, #1
 8003544:	d029      	beq.n	800359a <HAL_RCC_OscConfig+0x372>
 8003546:	2b00      	cmp	r3, #0
 8003548:	d143      	bne.n	80035d2 <HAL_RCC_OscConfig+0x3aa>
 800354a:	4b7a      	ldr	r3, [pc, #488]	@ (8003734 <HAL_RCC_OscConfig+0x50c>)
 800354c:	f8d3 20f0 	ldr.w	r2, [r3, #240]	@ 0xf0
 8003550:	f022 0201 	bic.w	r2, r2, #1
 8003554:	f8c3 20f0 	str.w	r2, [r3, #240]	@ 0xf0
 8003558:	f8d3 20f0 	ldr.w	r2, [r3, #240]	@ 0xf0
 800355c:	f022 0280 	bic.w	r2, r2, #128	@ 0x80
 8003560:	f8c3 20f0 	str.w	r2, [r3, #240]	@ 0xf0
 8003564:	f8d3 20f0 	ldr.w	r2, [r3, #240]	@ 0xf0
 8003568:	f022 0204 	bic.w	r2, r2, #4
 800356c:	f8c3 20f0 	str.w	r2, [r3, #240]	@ 0xf0
 8003570:	e01a      	b.n	80035a8 <HAL_RCC_OscConfig+0x380>
      SET_BIT(PWR->DBPCR, PWR_DBPCR_DBP);
 8003572:	4a71      	ldr	r2, [pc, #452]	@ (8003738 <HAL_RCC_OscConfig+0x510>)
 8003574:	6a53      	ldr	r3, [r2, #36]	@ 0x24
 8003576:	f043 0301 	orr.w	r3, r3, #1
 800357a:	6253      	str	r3, [r2, #36]	@ 0x24
      tickstart = HAL_GetTick();
 800357c:	f7ff fc00 	bl	8002d80 <HAL_GetTick>
 8003580:	4606      	mov	r6, r0
      while (HAL_IS_BIT_CLR(PWR->DBPCR, PWR_DBPCR_DBP))
 8003582:	4b6d      	ldr	r3, [pc, #436]	@ (8003738 <HAL_RCC_OscConfig+0x510>)
 8003584:	6a5b      	ldr	r3, [r3, #36]	@ 0x24
 8003586:	f013 0f01 	tst.w	r3, #1
 800358a:	d1d9      	bne.n	8003540 <HAL_RCC_OscConfig+0x318>
        if ((HAL_GetTick() - tickstart) > RCC_DBP_TIMEOUT_VALUE)
 800358c:	f7ff fbf8 	bl	8002d80 <HAL_GetTick>
 8003590:	1b80      	subs	r0, r0, r6
 8003592:	2802      	cmp	r0, #2
 8003594:	d9f5      	bls.n	8003582 <HAL_RCC_OscConfig+0x35a>
          return HAL_TIMEOUT;
 8003596:	2003      	movs	r0, #3
 8003598:	e17a      	b.n	8003890 <HAL_RCC_OscConfig+0x668>
    __HAL_RCC_LSE_CONFIG(pOscInitStruct->LSEState);
 800359a:	4a66      	ldr	r2, [pc, #408]	@ (8003734 <HAL_RCC_OscConfig+0x50c>)
 800359c:	f8d2 30f0 	ldr.w	r3, [r2, #240]	@ 0xf0
 80035a0:	f043 0301 	orr.w	r3, r3, #1
 80035a4:	f8c2 30f0 	str.w	r3, [r2, #240]	@ 0xf0
    if (pOscInitStruct->LSEState != RCC_LSE_OFF)
 80035a8:	68a3      	ldr	r3, [r4, #8]
 80035aa:	2b00      	cmp	r3, #0
 80035ac:	d051      	beq.n	8003652 <HAL_RCC_OscConfig+0x42a>
      tickstart = HAL_GetTick();
 80035ae:	f7ff fbe7 	bl	8002d80 <HAL_GetTick>
 80035b2:	4606      	mov	r6, r0
      while (READ_BIT(RCC->BDCR, RCC_BDCR_LSERDY) == 0U)
 80035b4:	4b5f      	ldr	r3, [pc, #380]	@ (8003734 <HAL_RCC_OscConfig+0x50c>)
 80035b6:	f8d3 30f0 	ldr.w	r3, [r3, #240]	@ 0xf0
 80035ba:	f013 0f02 	tst.w	r3, #2
 80035be:	d15a      	bne.n	8003676 <HAL_RCC_OscConfig+0x44e>
        if ((HAL_GetTick() - tickstart) > RCC_LSE_TIMEOUT_VALUE)
 80035c0:	f7ff fbde 	bl	8002d80 <HAL_GetTick>
 80035c4:	1b80      	subs	r0, r0, r6
 80035c6:	f241 3388 	movw	r3, #5000	@ 0x1388
 80035ca:	4298      	cmp	r0, r3
 80035cc:	d9f2      	bls.n	80035b4 <HAL_RCC_OscConfig+0x38c>
          return HAL_TIMEOUT;
 80035ce:	2003      	movs	r0, #3
 80035d0:	e15e      	b.n	8003890 <HAL_RCC_OscConfig+0x668>
    __HAL_RCC_LSE_CONFIG(pOscInitStruct->LSEState);
 80035d2:	2b05      	cmp	r3, #5
 80035d4:	d015      	beq.n	8003602 <HAL_RCC_OscConfig+0x3da>
 80035d6:	2b85      	cmp	r3, #133	@ 0x85
 80035d8:	d027      	beq.n	800362a <HAL_RCC_OscConfig+0x402>
 80035da:	4b56      	ldr	r3, [pc, #344]	@ (8003734 <HAL_RCC_OscConfig+0x50c>)
 80035dc:	f8d3 20f0 	ldr.w	r2, [r3, #240]	@ 0xf0
 80035e0:	f022 0201 	bic.w	r2, r2, #1
 80035e4:	f8c3 20f0 	str.w	r2, [r3, #240]	@ 0xf0
 80035e8:	f8d3 20f0 	ldr.w	r2, [r3, #240]	@ 0xf0
 80035ec:	f022 0204 	bic.w	r2, r2, #4
 80035f0:	f8c3 20f0 	str.w	r2, [r3, #240]	@ 0xf0
 80035f4:	f8d3 20f0 	ldr.w	r2, [r3, #240]	@ 0xf0
 80035f8:	f022 0280 	bic.w	r2, r2, #128	@ 0x80
 80035fc:	f8c3 20f0 	str.w	r2, [r3, #240]	@ 0xf0
 8003600:	e7d2      	b.n	80035a8 <HAL_RCC_OscConfig+0x380>
 8003602:	4b4c      	ldr	r3, [pc, #304]	@ (8003734 <HAL_RCC_OscConfig+0x50c>)
 8003604:	f8d3 20f0 	ldr.w	r2, [r3, #240]	@ 0xf0
 8003608:	f042 0204 	orr.w	r2, r2, #4
 800360c:	f8c3 20f0 	str.w	r2, [r3, #240]	@ 0xf0
 8003610:	f8d3 20f0 	ldr.w	r2, [r3, #240]	@ 0xf0
 8003614:	f022 0280 	bic.w	r2, r2, #128	@ 0x80
 8003618:	f8c3 20f0 	str.w	r2, [r3, #240]	@ 0xf0
 800361c:	f8d3 20f0 	ldr.w	r2, [r3, #240]	@ 0xf0
 8003620:	f042 0201 	orr.w	r2, r2, #1
 8003624:	f8c3 20f0 	str.w	r2, [r3, #240]	@ 0xf0
 8003628:	e7be      	b.n	80035a8 <HAL_RCC_OscConfig+0x380>
 800362a:	4b42      	ldr	r3, [pc, #264]	@ (8003734 <HAL_RCC_OscConfig+0x50c>)
 800362c:	f8d3 20f0 	ldr.w	r2, [r3, #240]	@ 0xf0
 8003630:	f042 0204 	orr.w	r2, r2, #4
 8003634:	f8c3 20f0 	str.w	r2, [r3, #240]	@ 0xf0
 8003638:	f8d3 20f0 	ldr.w	r2, [r3, #240]	@ 0xf0
 800363c:	f042 0280 	orr.w	r2, r2, #128	@ 0x80
 8003640:	f8c3 20f0 	str.w	r2, [r3, #240]	@ 0xf0
 8003644:	f8d3 20f0 	ldr.w	r2, [r3, #240]	@ 0xf0
 8003648:	f042 0201 	orr.w	r2, r2, #1
 800364c:	f8c3 20f0 	str.w	r2, [r3, #240]	@ 0xf0
 8003650:	e7aa      	b.n	80035a8 <HAL_RCC_OscConfig+0x380>
      tickstart = HAL_GetTick();
 8003652:	f7ff fb95 	bl	8002d80 <HAL_GetTick>
 8003656:	4606      	mov	r6, r0
      while (READ_BIT(RCC->BDCR, RCC_BDCR_LSERDY) != 0U)
 8003658:	4b36      	ldr	r3, [pc, #216]	@ (8003734 <HAL_RCC_OscConfig+0x50c>)
 800365a:	f8d3 30f0 	ldr.w	r3, [r3, #240]	@ 0xf0
 800365e:	f013 0f02 	tst.w	r3, #2
 8003662:	d008      	beq.n	8003676 <HAL_RCC_OscConfig+0x44e>
        if ((HAL_GetTick() - tickstart) > RCC_LSE_TIMEOUT_VALUE)
 8003664:	f7ff fb8c 	bl	8002d80 <HAL_GetTick>
 8003668:	1b80      	subs	r0, r0, r6
 800366a:	f241 3388 	movw	r3, #5000	@ 0x1388
 800366e:	4298      	cmp	r0, r3
 8003670:	d9f2      	bls.n	8003658 <HAL_RCC_OscConfig+0x430>
          return HAL_TIMEOUT;
 8003672:	2003      	movs	r0, #3
 8003674:	e10c      	b.n	8003890 <HAL_RCC_OscConfig+0x668>
  if (((pOscInitStruct->OscillatorType) & RCC_OSCILLATORTYPE_HSI48) == RCC_OSCILLATORTYPE_HSI48)
 8003676:	6823      	ldr	r3, [r4, #0]
 8003678:	f013 0f20 	tst.w	r3, #32
 800367c:	d029      	beq.n	80036d2 <HAL_RCC_OscConfig+0x4aa>
    if (pOscInitStruct->HSI48State != RCC_HSI48_OFF)
 800367e:	6a63      	ldr	r3, [r4, #36]	@ 0x24
 8003680:	b19b      	cbz	r3, 80036aa <HAL_RCC_OscConfig+0x482>
      __HAL_RCC_HSI48_ENABLE();
 8003682:	4a2c      	ldr	r2, [pc, #176]	@ (8003734 <HAL_RCC_OscConfig+0x50c>)
 8003684:	6813      	ldr	r3, [r2, #0]
 8003686:	f443 5380 	orr.w	r3, r3, #4096	@ 0x1000
 800368a:	6013      	str	r3, [r2, #0]
      tickstart = HAL_GetTick();
 800368c:	f7ff fb78 	bl	8002d80 <HAL_GetTick>
 8003690:	4606      	mov	r6, r0
      while (READ_BIT(RCC->CR, RCC_CR_HSI48RDY) == 0U)
 8003692:	4b28      	ldr	r3, [pc, #160]	@ (8003734 <HAL_RCC_OscConfig+0x50c>)
 8003694:	681b      	ldr	r3, [r3, #0]
 8003696:	f413 5f00 	tst.w	r3, #8192	@ 0x2000
 800369a:	d11a      	bne.n	80036d2 <HAL_RCC_OscConfig+0x4aa>
        if ((HAL_GetTick() - tickstart) > RCC_HSI48_TIMEOUT_VALUE)
 800369c:	f7ff fb70 	bl	8002d80 <HAL_GetTick>
 80036a0:	1b80      	subs	r0, r0, r6
 80036a2:	2802      	cmp	r0, #2
 80036a4:	d9f5      	bls.n	8003692 <HAL_RCC_OscConfig+0x46a>
          return HAL_TIMEOUT;
 80036a6:	2003      	movs	r0, #3
 80036a8:	e0f2      	b.n	8003890 <HAL_RCC_OscConfig+0x668>
      __HAL_RCC_HSI48_DISABLE();
 80036aa:	4a22      	ldr	r2, [pc, #136]	@ (8003734 <HAL_RCC_OscConfig+0x50c>)
 80036ac:	6813      	ldr	r3, [r2, #0]
 80036ae:	f423 5380 	bic.w	r3, r3, #4096	@ 0x1000
 80036b2:	6013      	str	r3, [r2, #0]
      tickstart = HAL_GetTick();
 80036b4:	f7ff fb64 	bl	8002d80 <HAL_GetTick>
 80036b8:	4606      	mov	r6, r0
      while (READ_BIT(RCC->CR, RCC_CR_HSI48RDY) != 0U)
 80036ba:	4b1e      	ldr	r3, [pc, #120]	@ (8003734 <HAL_RCC_OscConfig+0x50c>)
 80036bc:	681b      	ldr	r3, [r3, #0]
 80036be:	f413 5f00 	tst.w	r3, #8192	@ 0x2000
 80036c2:	d006      	beq.n	80036d2 <HAL_RCC_OscConfig+0x4aa>
        if ((HAL_GetTick() - tickstart) > RCC_HSI48_TIMEOUT_VALUE)
 80036c4:	f7ff fb5c 	bl	8002d80 <HAL_GetTick>
 80036c8:	1b80      	subs	r0, r0, r6
 80036ca:	2802      	cmp	r0, #2
 80036cc:	d9f5      	bls.n	80036ba <HAL_RCC_OscConfig+0x492>
          return HAL_TIMEOUT;
 80036ce:	2003      	movs	r0, #3
 80036d0:	e0de      	b.n	8003890 <HAL_RCC_OscConfig+0x668>
  if ((pOscInitStruct->PLL.PLLState) != RCC_PLL_NONE)
 80036d2:	6aa3      	ldr	r3, [r4, #40]	@ 0x28
 80036d4:	2b00      	cmp	r3, #0
 80036d6:	f000 80da 	beq.w	800388e <HAL_RCC_OscConfig+0x666>
    if (temp_sysclksrc != RCC_SYSCLKSOURCE_STATUS_PLLCLK)
 80036da:	2d18      	cmp	r5, #24
 80036dc:	f000 8089 	beq.w	80037f2 <HAL_RCC_OscConfig+0x5ca>
      if ((pOscInitStruct->PLL.PLLState) == RCC_PLL_ON)
 80036e0:	2b02      	cmp	r3, #2
 80036e2:	d013      	beq.n	800370c <HAL_RCC_OscConfig+0x4e4>
        __HAL_RCC_PLL1_DISABLE();
 80036e4:	4a13      	ldr	r2, [pc, #76]	@ (8003734 <HAL_RCC_OscConfig+0x50c>)
 80036e6:	6813      	ldr	r3, [r2, #0]
 80036e8:	f023 7380 	bic.w	r3, r3, #16777216	@ 0x1000000
 80036ec:	6013      	str	r3, [r2, #0]
        tickstart = HAL_GetTick();
 80036ee:	f7ff fb47 	bl	8002d80 <HAL_GetTick>
 80036f2:	4604      	mov	r4, r0
        while (READ_BIT(RCC->CR, RCC_CR_PLL1RDY) != 0U)
 80036f4:	4b0f      	ldr	r3, [pc, #60]	@ (8003734 <HAL_RCC_OscConfig+0x50c>)
 80036f6:	681b      	ldr	r3, [r3, #0]
 80036f8:	f013 7f00 	tst.w	r3, #33554432	@ 0x2000000
 80036fc:	d070      	beq.n	80037e0 <HAL_RCC_OscConfig+0x5b8>
          if ((HAL_GetTick() - tickstart) > RCC_PLL_TIMEOUT_VALUE)
 80036fe:	f7ff fb3f 	bl	8002d80 <HAL_GetTick>
 8003702:	1b00      	subs	r0, r0, r4
 8003704:	2802      	cmp	r0, #2
 8003706:	d9f5      	bls.n	80036f4 <HAL_RCC_OscConfig+0x4cc>
            return HAL_TIMEOUT;
 8003708:	2003      	movs	r0, #3
 800370a:	e0c1      	b.n	8003890 <HAL_RCC_OscConfig+0x668>
        __HAL_RCC_PLL1_DISABLE();
 800370c:	4a09      	ldr	r2, [pc, #36]	@ (8003734 <HAL_RCC_OscConfig+0x50c>)
 800370e:	6813      	ldr	r3, [r2, #0]
 8003710:	f023 7380 	bic.w	r3, r3, #16777216	@ 0x1000000
 8003714:	6013      	str	r3, [r2, #0]
        tickstart = HAL_GetTick();
 8003716:	f7ff fb33 	bl	8002d80 <HAL_GetTick>
 800371a:	4605      	mov	r5, r0
        while (READ_BIT(RCC->CR, RCC_CR_PLL1RDY) != 0U)
 800371c:	4b05      	ldr	r3, [pc, #20]	@ (8003734 <HAL_RCC_OscConfig+0x50c>)
 800371e:	681b      	ldr	r3, [r3, #0]
 8003720:	f013 7f00 	tst.w	r3, #33554432	@ 0x2000000
 8003724:	d00a      	beq.n	800373c <HAL_RCC_OscConfig+0x514>
          if ((HAL_GetTick() - tickstart) > RCC_PLL_TIMEOUT_VALUE)
 8003726:	f7ff fb2b 	bl	8002d80 <HAL_GetTick>
 800372a:	1b40      	subs	r0, r0, r5
 800372c:	2802      	cmp	r0, #2
 800372e:	d9f5      	bls.n	800371c <HAL_RCC_OscConfig+0x4f4>
            return HAL_TIMEOUT;
 8003730:	2003      	movs	r0, #3
 8003732:	e0ad      	b.n	8003890 <HAL_RCC_OscConfig+0x668>
 8003734:	44020c00 	.word	0x44020c00
 8003738:	44020800 	.word	0x44020800
        __HAL_RCC_PLL1_CONFIG(pOscInitStruct->PLL.PLLSource,
 800373c:	4b5c      	ldr	r3, [pc, #368]	@ (80038b0 <HAL_RCC_OscConfig+0x688>)
 800373e:	6a9a      	ldr	r2, [r3, #40]	@ 0x28
 8003740:	f422 527c 	bic.w	r2, r2, #16128	@ 0x3f00
 8003744:	f022 0203 	bic.w	r2, r2, #3
 8003748:	6ae1      	ldr	r1, [r4, #44]	@ 0x2c
 800374a:	6b20      	ldr	r0, [r4, #48]	@ 0x30
 800374c:	ea41 2100 	orr.w	r1, r1, r0, lsl #8
 8003750:	430a      	orrs	r2, r1
 8003752:	629a      	str	r2, [r3, #40]	@ 0x28
 8003754:	6b62      	ldr	r2, [r4, #52]	@ 0x34
 8003756:	3a01      	subs	r2, #1
 8003758:	f3c2 0208 	ubfx	r2, r2, #0, #9
 800375c:	6ba1      	ldr	r1, [r4, #56]	@ 0x38
 800375e:	3901      	subs	r1, #1
 8003760:	0249      	lsls	r1, r1, #9
 8003762:	b289      	uxth	r1, r1
 8003764:	430a      	orrs	r2, r1
 8003766:	6be1      	ldr	r1, [r4, #60]	@ 0x3c
 8003768:	3901      	subs	r1, #1
 800376a:	0409      	lsls	r1, r1, #16
 800376c:	f401 01fe 	and.w	r1, r1, #8323072	@ 0x7f0000
 8003770:	430a      	orrs	r2, r1
 8003772:	6c21      	ldr	r1, [r4, #64]	@ 0x40
 8003774:	3901      	subs	r1, #1
 8003776:	0609      	lsls	r1, r1, #24
 8003778:	f001 41fe 	and.w	r1, r1, #2130706432	@ 0x7f000000
 800377c:	430a      	orrs	r2, r1
 800377e:	635a      	str	r2, [r3, #52]	@ 0x34
        __HAL_RCC_PLL1_FRACN_DISABLE();
 8003780:	6a9a      	ldr	r2, [r3, #40]	@ 0x28
 8003782:	f022 0210 	bic.w	r2, r2, #16
 8003786:	629a      	str	r2, [r3, #40]	@ 0x28
        __HAL_RCC_PLL1_FRACN_CONFIG(pOscInitStruct->PLL.PLLFRACN);
 8003788:	6ce2      	ldr	r2, [r4, #76]	@ 0x4c
 800378a:	00d2      	lsls	r2, r2, #3
 800378c:	639a      	str	r2, [r3, #56]	@ 0x38
        __HAL_RCC_PLL1_FRACN_ENABLE();
 800378e:	6a9a      	ldr	r2, [r3, #40]	@ 0x28
 8003790:	f042 0210 	orr.w	r2, r2, #16
 8003794:	629a      	str	r2, [r3, #40]	@ 0x28
        __HAL_RCC_PLL1_VCIRANGE(pOscInitStruct->PLL.PLLRGE) ;
 8003796:	6a9a      	ldr	r2, [r3, #40]	@ 0x28
 8003798:	f022 020c 	bic.w	r2, r2, #12
 800379c:	6c61      	ldr	r1, [r4, #68]	@ 0x44
 800379e:	430a      	orrs	r2, r1
 80037a0:	629a      	str	r2, [r3, #40]	@ 0x28
        __HAL_RCC_PLL1_VCORANGE(pOscInitStruct->PLL.PLLVCOSEL) ;
 80037a2:	6a9a      	ldr	r2, [r3, #40]	@ 0x28
 80037a4:	f022 0220 	bic.w	r2, r2, #32
 80037a8:	6ca1      	ldr	r1, [r4, #72]	@ 0x48
 80037aa:	430a      	orrs	r2, r1
 80037ac:	629a      	str	r2, [r3, #40]	@ 0x28
        __HAL_RCC_PLL1_CLKOUT_ENABLE(RCC_PLL1_DIVP);
 80037ae:	6a9a      	ldr	r2, [r3, #40]	@ 0x28
 80037b0:	f442 3280 	orr.w	r2, r2, #65536	@ 0x10000
 80037b4:	629a      	str	r2, [r3, #40]	@ 0x28
        __HAL_RCC_PLL1_ENABLE();
 80037b6:	681a      	ldr	r2, [r3, #0]
 80037b8:	f042 7280 	orr.w	r2, r2, #16777216	@ 0x1000000
 80037bc:	601a      	str	r2, [r3, #0]
        tickstart = HAL_GetTick();
 80037be:	f7ff fadf 	bl	8002d80 <HAL_GetTick>
 80037c2:	4604      	mov	r4, r0
        while (READ_BIT(RCC->CR, RCC_CR_PLL1RDY) == 0U)
 80037c4:	4b3a      	ldr	r3, [pc, #232]	@ (80038b0 <HAL_RCC_OscConfig+0x688>)
 80037c6:	681b      	ldr	r3, [r3, #0]
 80037c8:	f013 7f00 	tst.w	r3, #33554432	@ 0x2000000
 80037cc:	d106      	bne.n	80037dc <HAL_RCC_OscConfig+0x5b4>
          if ((HAL_GetTick() - tickstart) > RCC_PLL_TIMEOUT_VALUE)
 80037ce:	f7ff fad7 	bl	8002d80 <HAL_GetTick>
 80037d2:	1b00      	subs	r0, r0, r4
 80037d4:	2802      	cmp	r0, #2
 80037d6:	d9f5      	bls.n	80037c4 <HAL_RCC_OscConfig+0x59c>
            return HAL_TIMEOUT;
 80037d8:	2003      	movs	r0, #3
 80037da:	e059      	b.n	8003890 <HAL_RCC_OscConfig+0x668>
  return HAL_OK;
 80037dc:	2000      	movs	r0, #0
 80037de:	e057      	b.n	8003890 <HAL_RCC_OscConfig+0x668>
        RCC->PLL1CFGR &= ~(RCC_PLL1CFGR_PLL1SRC | RCC_PLL1CFGR_PLL1PEN | RCC_PLL1CFGR_PLL1QEN | RCC_PLL1CFGR_PLL1REN);
 80037e0:	4a33      	ldr	r2, [pc, #204]	@ (80038b0 <HAL_RCC_OscConfig+0x688>)
 80037e2:	6a93      	ldr	r3, [r2, #40]	@ 0x28
 80037e4:	f423 23e0 	bic.w	r3, r3, #458752	@ 0x70000
 80037e8:	f023 0303 	bic.w	r3, r3, #3
 80037ec:	6293      	str	r3, [r2, #40]	@ 0x28
  return HAL_OK;
 80037ee:	2000      	movs	r0, #0
 80037f0:	e04e      	b.n	8003890 <HAL_RCC_OscConfig+0x668>
      temp1_pllckcfg = RCC->PLL1CFGR;
 80037f2:	4a2f      	ldr	r2, [pc, #188]	@ (80038b0 <HAL_RCC_OscConfig+0x688>)
 80037f4:	6a91      	ldr	r1, [r2, #40]	@ 0x28
      temp2_pllckcfg = RCC->PLL1DIVR;
 80037f6:	6b50      	ldr	r0, [r2, #52]	@ 0x34
      if (((pOscInitStruct->PLL.PLLState) == RCC_PLL_OFF) ||
 80037f8:	2b01      	cmp	r3, #1
 80037fa:	d04a      	beq.n	8003892 <HAL_RCC_OscConfig+0x66a>
          (READ_BIT(temp1_pllckcfg, RCC_PLL1CFGR_PLL1SRC) != pOscInitStruct->PLL.PLLSource) ||
 80037fc:	f001 0303 	and.w	r3, r1, #3
 8003800:	6ae2      	ldr	r2, [r4, #44]	@ 0x2c
      if (((pOscInitStruct->PLL.PLLState) == RCC_PLL_OFF) ||
 8003802:	4293      	cmp	r3, r2
 8003804:	d147      	bne.n	8003896 <HAL_RCC_OscConfig+0x66e>
          ((READ_BIT(temp1_pllckcfg, RCC_PLL1CFGR_PLL1M) >> \
 8003806:	f3c1 2105 	ubfx	r1, r1, #8, #6
            RCC_PLL1CFGR_PLL1M_Pos) != (pOscInitStruct->PLL.PLLM)) ||
 800380a:	6b23      	ldr	r3, [r4, #48]	@ 0x30
          (READ_BIT(temp1_pllckcfg, RCC_PLL1CFGR_PLL1SRC) != pOscInitStruct->PLL.PLLSource) ||
 800380c:	4299      	cmp	r1, r3
 800380e:	d144      	bne.n	800389a <HAL_RCC_OscConfig+0x672>
          (READ_BIT(temp2_pllckcfg, RCC_PLL1DIVR_PLL1N) != (pOscInitStruct->PLL.PLLN - 1U)) ||
 8003810:	f3c0 0208 	ubfx	r2, r0, #0, #9
 8003814:	6b63      	ldr	r3, [r4, #52]	@ 0x34
 8003816:	3b01      	subs	r3, #1
            RCC_PLL1CFGR_PLL1M_Pos) != (pOscInitStruct->PLL.PLLM)) ||
 8003818:	429a      	cmp	r2, r3
 800381a:	d140      	bne.n	800389e <HAL_RCC_OscConfig+0x676>
          ((READ_BIT(temp2_pllckcfg, RCC_PLL1DIVR_PLL1P) >> \
 800381c:	f3c0 2246 	ubfx	r2, r0, #9, #7
            RCC_PLL1DIVR_PLL1P_Pos) != (pOscInitStruct->PLL.PLLP - 1U)) ||
 8003820:	6ba3      	ldr	r3, [r4, #56]	@ 0x38
 8003822:	3b01      	subs	r3, #1
          (READ_BIT(temp2_pllckcfg, RCC_PLL1DIVR_PLL1N) != (pOscInitStruct->PLL.PLLN - 1U)) ||
 8003824:	429a      	cmp	r2, r3
 8003826:	d13c      	bne.n	80038a2 <HAL_RCC_OscConfig+0x67a>
          ((READ_BIT(temp2_pllckcfg, RCC_PLL1DIVR_PLL1Q) >> \
 8003828:	f3c0 4206 	ubfx	r2, r0, #16, #7
            RCC_PLL1DIVR_PLL1Q_Pos) != (pOscInitStruct->PLL.PLLQ - 1U)) ||
 800382c:	6be3      	ldr	r3, [r4, #60]	@ 0x3c
 800382e:	3b01      	subs	r3, #1
            RCC_PLL1DIVR_PLL1P_Pos) != (pOscInitStruct->PLL.PLLP - 1U)) ||
 8003830:	429a      	cmp	r2, r3
 8003832:	d138      	bne.n	80038a6 <HAL_RCC_OscConfig+0x67e>
          ((READ_BIT(temp2_pllckcfg, RCC_PLL1DIVR_PLL1R) >> \
 8003834:	f3c0 6006 	ubfx	r0, r0, #24, #7
            RCC_PLL1DIVR_PLL1R_Pos) != (pOscInitStruct->PLL.PLLR - 1U)))
 8003838:	6c23      	ldr	r3, [r4, #64]	@ 0x40
 800383a:	3b01      	subs	r3, #1
            RCC_PLL1DIVR_PLL1Q_Pos) != (pOscInitStruct->PLL.PLLQ - 1U)) ||
 800383c:	4298      	cmp	r0, r3
 800383e:	d134      	bne.n	80038aa <HAL_RCC_OscConfig+0x682>
      if ((READ_BIT(RCC->PLL1FRACR, RCC_PLL1FRACR_PLL1FRACN) >> \
 8003840:	4b1b      	ldr	r3, [pc, #108]	@ (80038b0 <HAL_RCC_OscConfig+0x688>)
 8003842:	6b9b      	ldr	r3, [r3, #56]	@ 0x38
 8003844:	f3c3 03cc 	ubfx	r3, r3, #3, #13
           RCC_PLL1FRACR_PLL1FRACN_Pos) != (pOscInitStruct->PLL.PLLFRACN))
 8003848:	6ce2      	ldr	r2, [r4, #76]	@ 0x4c
      if ((READ_BIT(RCC->PLL1FRACR, RCC_PLL1FRACR_PLL1FRACN) >> \
 800384a:	4293      	cmp	r3, r2
 800384c:	d101      	bne.n	8003852 <HAL_RCC_OscConfig+0x62a>
  return HAL_OK;
 800384e:	2000      	movs	r0, #0
 8003850:	e01e      	b.n	8003890 <HAL_RCC_OscConfig+0x668>
        __HAL_RCC_PLL1_FRACN_DISABLE();
 8003852:	4a17      	ldr	r2, [pc, #92]	@ (80038b0 <HAL_RCC_OscConfig+0x688>)
 8003854:	6a93      	ldr	r3, [r2, #40]	@ 0x28
 8003856:	f023 0310 	bic.w	r3, r3, #16
 800385a:	6293      	str	r3, [r2, #40]	@ 0x28
        tickstart = HAL_GetTick();
 800385c:	f7ff fa90 	bl	8002d80 <HAL_GetTick>
 8003860:	4605      	mov	r5, r0
        while ((HAL_GetTick() - tickstart) < RCC_PLL_FRAC_WAIT_VALUE)
 8003862:	f7ff fa8d 	bl	8002d80 <HAL_GetTick>
 8003866:	42a8      	cmp	r0, r5
 8003868:	d0fb      	beq.n	8003862 <HAL_RCC_OscConfig+0x63a>
        __HAL_RCC_PLL1_FRACN_CONFIG(pOscInitStruct->PLL.PLLFRACN);
 800386a:	6ce2      	ldr	r2, [r4, #76]	@ 0x4c
 800386c:	00d2      	lsls	r2, r2, #3
 800386e:	4b10      	ldr	r3, [pc, #64]	@ (80038b0 <HAL_RCC_OscConfig+0x688>)
 8003870:	639a      	str	r2, [r3, #56]	@ 0x38
        __HAL_RCC_PLL1_FRACN_ENABLE();
 8003872:	6a9a      	ldr	r2, [r3, #40]	@ 0x28
 8003874:	f042 0210 	orr.w	r2, r2, #16
 8003878:	629a      	str	r2, [r3, #40]	@ 0x28
  return HAL_OK;
 800387a:	2000      	movs	r0, #0
 800387c:	e008      	b.n	8003890 <HAL_RCC_OscConfig+0x668>
    return HAL_ERROR;
 800387e:	2001      	movs	r0, #1
}
 8003880:	4770      	bx	lr
        return HAL_ERROR;
 8003882:	2001      	movs	r0, #1
 8003884:	e004      	b.n	8003890 <HAL_RCC_OscConfig+0x668>
        return HAL_ERROR;
 8003886:	2001      	movs	r0, #1
 8003888:	e002      	b.n	8003890 <HAL_RCC_OscConfig+0x668>
        return HAL_ERROR;
 800388a:	2001      	movs	r0, #1
 800388c:	e000      	b.n	8003890 <HAL_RCC_OscConfig+0x668>
  return HAL_OK;
 800388e:	2000      	movs	r0, #0
}
 8003890:	bdf8      	pop	{r3, r4, r5, r6, r7, pc}
        return HAL_ERROR;
 8003892:	2001      	movs	r0, #1
 8003894:	e7fc      	b.n	8003890 <HAL_RCC_OscConfig+0x668>
 8003896:	2001      	movs	r0, #1
 8003898:	e7fa      	b.n	8003890 <HAL_RCC_OscConfig+0x668>
 800389a:	2001      	movs	r0, #1
 800389c:	e7f8      	b.n	8003890 <HAL_RCC_OscConfig+0x668>
 800389e:	2001      	movs	r0, #1
 80038a0:	e7f6      	b.n	8003890 <HAL_RCC_OscConfig+0x668>
 80038a2:	2001      	movs	r0, #1
 80038a4:	e7f4      	b.n	8003890 <HAL_RCC_OscConfig+0x668>
 80038a6:	2001      	movs	r0, #1
 80038a8:	e7f2      	b.n	8003890 <HAL_RCC_OscConfig+0x668>
 80038aa:	2001      	movs	r0, #1
 80038ac:	e7f0      	b.n	8003890 <HAL_RCC_OscConfig+0x668>
 80038ae:	bf00      	nop
 80038b0:	44020c00 	.word	0x44020c00

080038b4 <HAL_RCC_GetPCLK1Freq>:
  * @note   Each time PCLK1 changes, this function must be called to update the
  *         right PCLK1 value. Otherwise, any configuration based on this function will be incorrect.
  * @retval PCLK1 frequency in Hz
  */
uint32_t HAL_RCC_GetPCLK1Freq(void)
{
 80038b4:	b508      	push	{r3, lr}
  /* Get HCLK source and Compute PCLK1 frequency ---------------------------*/
  return (HAL_RCC_GetHCLKFreq() >> ((APBPrescTable[(RCC->CFGR2 & RCC_CFGR2_PPRE1) >> RCC_CFGR2_PPRE1_Pos]) & 0x1FU));
 80038b6:	f7ff fca1 	bl	80031fc <HAL_RCC_GetHCLKFreq>
 80038ba:	4b05      	ldr	r3, [pc, #20]	@ (80038d0 <HAL_RCC_GetPCLK1Freq+0x1c>)
 80038bc:	6a1b      	ldr	r3, [r3, #32]
 80038be:	f3c3 1302 	ubfx	r3, r3, #4, #3
 80038c2:	4a04      	ldr	r2, [pc, #16]	@ (80038d4 <HAL_RCC_GetPCLK1Freq+0x20>)
 80038c4:	5cd3      	ldrb	r3, [r2, r3]
 80038c6:	f003 031f 	and.w	r3, r3, #31
}
 80038ca:	40d8      	lsrs	r0, r3
 80038cc:	bd08      	pop	{r3, pc}
 80038ce:	bf00      	nop
 80038d0:	44020c00 	.word	0x44020c00
 80038d4:	080081d8 	.word	0x080081d8

080038d8 <HAL_RCC_GetPCLK2Freq>:
  * @note   Each time PCLK2 changes, this function must be called to update the
  *         right PCLK2 value. Otherwise, any configuration based on this function will be incorrect.
  * @retval PCLK2 frequency in Hz
  */
uint32_t HAL_RCC_GetPCLK2Freq(void)
{
 80038d8:	b508      	push	{r3, lr}
  /* Get HCLK source and Compute PCLK2 frequency ---------------------------*/
  return (HAL_RCC_GetHCLKFreq() >> ((APBPrescTable[(RCC->CFGR2 & RCC_CFGR2_PPRE2) >> RCC_CFGR2_PPRE2_Pos]) & 0x1FU));
 80038da:	f7ff fc8f 	bl	80031fc <HAL_RCC_GetHCLKFreq>
 80038de:	4b05      	ldr	r3, [pc, #20]	@ (80038f4 <HAL_RCC_GetPCLK2Freq+0x1c>)
 80038e0:	6a1b      	ldr	r3, [r3, #32]
 80038e2:	f3c3 2302 	ubfx	r3, r3, #8, #3
 80038e6:	4a04      	ldr	r2, [pc, #16]	@ (80038f8 <HAL_RCC_GetPCLK2Freq+0x20>)
 80038e8:	5cd3      	ldrb	r3, [r2, r3]
 80038ea:	f003 031f 	and.w	r3, r3, #31
}
 80038ee:	40d8      	lsrs	r0, r3
 80038f0:	bd08      	pop	{r3, pc}
 80038f2:	bf00      	nop
 80038f4:	44020c00 	.word	0x44020c00
 80038f8:	080081d8 	.word	0x080081d8

080038fc <HAL_RCC_GetPCLK3Freq>:
  * @note   Each time PCLK3 changes, this function must be called to update the
  *         right PCLK3 value. Otherwise, any configuration based on this function will be incorrect.
  * @retval PCLK3 frequency in Hz
  */
uint32_t HAL_RCC_GetPCLK3Freq(void)
{
 80038fc:	b508      	push	{r3, lr}
  /* Get HCLK source and Compute PCLK3 frequency ---------------------------*/
  return (HAL_RCC_GetHCLKFreq() >> ((APBPrescTable[(RCC->CFGR2 & RCC_CFGR2_PPRE3) >> RCC_CFGR2_PPRE3_Pos]) & 0x1FU));
 80038fe:	f7ff fc7d 	bl	80031fc <HAL_RCC_GetHCLKFreq>
 8003902:	4b05      	ldr	r3, [pc, #20]	@ (8003918 <HAL_RCC_GetPCLK3Freq+0x1c>)
 8003904:	6a1b      	ldr	r3, [r3, #32]
 8003906:	f3c3 3302 	ubfx	r3, r3, #12, #3
 800390a:	4a04      	ldr	r2, [pc, #16]	@ (800391c <HAL_RCC_GetPCLK3Freq+0x20>)
 800390c:	5cd3      	ldrb	r3, [r2, r3]
 800390e:	f003 031f 	and.w	r3, r3, #31
}
 8003912:	40d8      	lsrs	r0, r3
 8003914:	bd08      	pop	{r3, pc}
 8003916:	bf00      	nop
 8003918:	44020c00 	.word	0x44020c00
 800391c:	080081d8 	.word	0x080081d8

08003920 <RCCEx_PLL2_Config>:
  *         contains the configuration parameters M, N, FRACN, VCI/VCO ranges as well as PLL2 output clocks dividers
  * @note   PLL2 is temporary disabled to apply new parameters
  * @retval HAL status
  */
static HAL_StatusTypeDef RCCEx_PLL2_Config(const RCC_PLL2InitTypeDef *pll2)
{
 8003920:	b538      	push	{r3, r4, r5, lr}
 8003922:	4605      	mov	r5, r0
  assert_param(IS_RCC_PLL2_VCIRGE_VALUE(pll2->PLL2RGE));
  assert_param(IS_RCC_PLL2_VCORGE_VALUE(pll2->PLL2VCOSEL));
  assert_param(IS_RCC_PLL2_FRACN_VALUE(pll2->PLL2FRACN));

  /* Disable  PLL2. */
  __HAL_RCC_PLL2_DISABLE();
 8003924:	4a34      	ldr	r2, [pc, #208]	@ (80039f8 <RCCEx_PLL2_Config+0xd8>)
 8003926:	6813      	ldr	r3, [r2, #0]
 8003928:	f023 6380 	bic.w	r3, r3, #67108864	@ 0x4000000
 800392c:	6013      	str	r3, [r2, #0]

  /* Get Start Tick*/
  tickstart = HAL_GetTick();
 800392e:	f7ff fa27 	bl	8002d80 <HAL_GetTick>
 8003932:	4604      	mov	r4, r0

  /* Wait till PLL2 is disabled */
  while (__HAL_RCC_GET_FLAG(RCC_FLAG_PLL2RDY) != 0U)
 8003934:	4b30      	ldr	r3, [pc, #192]	@ (80039f8 <RCCEx_PLL2_Config+0xd8>)
 8003936:	681b      	ldr	r3, [r3, #0]
 8003938:	f013 6f00 	tst.w	r3, #134217728	@ 0x8000000
 800393c:	d006      	beq.n	800394c <RCCEx_PLL2_Config+0x2c>
  {
    if ((HAL_GetTick() - tickstart) > PLL2_TIMEOUT_VALUE)
 800393e:	f7ff fa1f 	bl	8002d80 <HAL_GetTick>
 8003942:	1b00      	subs	r0, r0, r4
 8003944:	2802      	cmp	r0, #2
 8003946:	d9f5      	bls.n	8003934 <RCCEx_PLL2_Config+0x14>
    {
      return HAL_TIMEOUT;
 8003948:	2003      	movs	r0, #3
      return HAL_TIMEOUT;
    }
  }
  return HAL_OK;

}
 800394a:	bd38      	pop	{r3, r4, r5, pc}
  __HAL_RCC_PLL2_CONFIG(pll2->PLL2Source,
 800394c:	4b2a      	ldr	r3, [pc, #168]	@ (80039f8 <RCCEx_PLL2_Config+0xd8>)
 800394e:	6ada      	ldr	r2, [r3, #44]	@ 0x2c
 8003950:	f422 527c 	bic.w	r2, r2, #16128	@ 0x3f00
 8003954:	f022 0203 	bic.w	r2, r2, #3
 8003958:	6829      	ldr	r1, [r5, #0]
 800395a:	6868      	ldr	r0, [r5, #4]
 800395c:	ea41 2100 	orr.w	r1, r1, r0, lsl #8
 8003960:	430a      	orrs	r2, r1
 8003962:	62da      	str	r2, [r3, #44]	@ 0x2c
 8003964:	68aa      	ldr	r2, [r5, #8]
 8003966:	3a01      	subs	r2, #1
 8003968:	f3c2 0208 	ubfx	r2, r2, #0, #9
 800396c:	68e9      	ldr	r1, [r5, #12]
 800396e:	3901      	subs	r1, #1
 8003970:	0249      	lsls	r1, r1, #9
 8003972:	b289      	uxth	r1, r1
 8003974:	430a      	orrs	r2, r1
 8003976:	6929      	ldr	r1, [r5, #16]
 8003978:	3901      	subs	r1, #1
 800397a:	0409      	lsls	r1, r1, #16
 800397c:	f401 01fe 	and.w	r1, r1, #8323072	@ 0x7f0000
 8003980:	430a      	orrs	r2, r1
 8003982:	6969      	ldr	r1, [r5, #20]
 8003984:	3901      	subs	r1, #1
 8003986:	0609      	lsls	r1, r1, #24
 8003988:	f001 41fe 	and.w	r1, r1, #2130706432	@ 0x7f000000
 800398c:	430a      	orrs	r2, r1
 800398e:	63da      	str	r2, [r3, #60]	@ 0x3c
  __HAL_RCC_PLL2_VCIRANGE(pll2->PLL2RGE);
 8003990:	6ada      	ldr	r2, [r3, #44]	@ 0x2c
 8003992:	f022 020c 	bic.w	r2, r2, #12
 8003996:	69a9      	ldr	r1, [r5, #24]
 8003998:	430a      	orrs	r2, r1
 800399a:	62da      	str	r2, [r3, #44]	@ 0x2c
  __HAL_RCC_PLL2_VCORANGE(pll2->PLL2VCOSEL);
 800399c:	6ada      	ldr	r2, [r3, #44]	@ 0x2c
 800399e:	f022 0220 	bic.w	r2, r2, #32
 80039a2:	69e9      	ldr	r1, [r5, #28]
 80039a4:	430a      	orrs	r2, r1
 80039a6:	62da      	str	r2, [r3, #44]	@ 0x2c
  __HAL_RCC_PLL2_CLKOUT_ENABLE(pll2->PLL2ClockOut);
 80039a8:	6ada      	ldr	r2, [r3, #44]	@ 0x2c
 80039aa:	6a69      	ldr	r1, [r5, #36]	@ 0x24
 80039ac:	430a      	orrs	r2, r1
 80039ae:	62da      	str	r2, [r3, #44]	@ 0x2c
  __HAL_RCC_PLL2_FRACN_DISABLE();
 80039b0:	6ada      	ldr	r2, [r3, #44]	@ 0x2c
 80039b2:	f022 0210 	bic.w	r2, r2, #16
 80039b6:	62da      	str	r2, [r3, #44]	@ 0x2c
  __HAL_RCC_PLL2_FRACN_CONFIG(pll2->PLL2FRACN);
 80039b8:	6c1a      	ldr	r2, [r3, #64]	@ 0x40
 80039ba:	f36f 02cf 	bfc	r2, #3, #13
 80039be:	6a29      	ldr	r1, [r5, #32]
 80039c0:	ea42 02c1 	orr.w	r2, r2, r1, lsl #3
 80039c4:	641a      	str	r2, [r3, #64]	@ 0x40
  __HAL_RCC_PLL2_FRACN_ENABLE();
 80039c6:	6ada      	ldr	r2, [r3, #44]	@ 0x2c
 80039c8:	f042 0210 	orr.w	r2, r2, #16
 80039cc:	62da      	str	r2, [r3, #44]	@ 0x2c
  __HAL_RCC_PLL2_ENABLE();
 80039ce:	681a      	ldr	r2, [r3, #0]
 80039d0:	f042 6280 	orr.w	r2, r2, #67108864	@ 0x4000000
 80039d4:	601a      	str	r2, [r3, #0]
  tickstart = HAL_GetTick();
 80039d6:	f7ff f9d3 	bl	8002d80 <HAL_GetTick>
 80039da:	4604      	mov	r4, r0
  while (__HAL_RCC_GET_FLAG(RCC_FLAG_PLL2RDY) == 0U)
 80039dc:	4b06      	ldr	r3, [pc, #24]	@ (80039f8 <RCCEx_PLL2_Config+0xd8>)
 80039de:	681b      	ldr	r3, [r3, #0]
 80039e0:	f013 6f00 	tst.w	r3, #134217728	@ 0x8000000
 80039e4:	d106      	bne.n	80039f4 <RCCEx_PLL2_Config+0xd4>
    if ((HAL_GetTick() - tickstart) > PLL2_TIMEOUT_VALUE)
 80039e6:	f7ff f9cb 	bl	8002d80 <HAL_GetTick>
 80039ea:	1b00      	subs	r0, r0, r4
 80039ec:	2802      	cmp	r0, #2
 80039ee:	d9f5      	bls.n	80039dc <RCCEx_PLL2_Config+0xbc>
      return HAL_TIMEOUT;
 80039f0:	2003      	movs	r0, #3
 80039f2:	e7aa      	b.n	800394a <RCCEx_PLL2_Config+0x2a>
  return HAL_OK;
 80039f4:	2000      	movs	r0, #0
 80039f6:	e7a8      	b.n	800394a <RCCEx_PLL2_Config+0x2a>
 80039f8:	44020c00 	.word	0x44020c00

080039fc <RCCEx_PLL3_Config>:
  *         contains the configuration parameters M, N, FRACN, VCI/VCO ranges as well as PLL3 output clocks dividers
  * @note   PLL3 is temporary disabled to apply new parameters
  * @retval HAL status.
  */
static HAL_StatusTypeDef RCCEx_PLL3_Config(const RCC_PLL3InitTypeDef *pll3)
{
 80039fc:	b538      	push	{r3, r4, r5, lr}
 80039fe:	4605      	mov	r5, r0
  assert_param(IS_RCC_PLL3_VCIRGE_VALUE(pll3->PLL3RGE));
  assert_param(IS_RCC_PLL3_VCORGE_VALUE(pll3->PLL3VCOSEL));
  assert_param(IS_RCC_PLL3_FRACN_VALUE(pll3->PLL3FRACN));

  /* Disable  PLL3. */
  __HAL_RCC_PLL3_DISABLE();
 8003a00:	4a34      	ldr	r2, [pc, #208]	@ (8003ad4 <RCCEx_PLL3_Config+0xd8>)
 8003a02:	6813      	ldr	r3, [r2, #0]
 8003a04:	f023 5380 	bic.w	r3, r3, #268435456	@ 0x10000000
 8003a08:	6013      	str	r3, [r2, #0]

  /* Get Start Tick*/
  tickstart = HAL_GetTick();
 8003a0a:	f7ff f9b9 	bl	8002d80 <HAL_GetTick>
 8003a0e:	4604      	mov	r4, r0

  /* Wait till PLL3 is disabled */
  while (__HAL_RCC_GET_FLAG(RCC_FLAG_PLL3RDY) != 0U)
 8003a10:	4b30      	ldr	r3, [pc, #192]	@ (8003ad4 <RCCEx_PLL3_Config+0xd8>)
 8003a12:	681b      	ldr	r3, [r3, #0]
 8003a14:	f013 5f00 	tst.w	r3, #536870912	@ 0x20000000
 8003a18:	d006      	beq.n	8003a28 <RCCEx_PLL3_Config+0x2c>
  {
    if ((HAL_GetTick() - tickstart) > PLL3_TIMEOUT_VALUE)
 8003a1a:	f7ff f9b1 	bl	8002d80 <HAL_GetTick>
 8003a1e:	1b00      	subs	r0, r0, r4
 8003a20:	2802      	cmp	r0, #2
 8003a22:	d9f5      	bls.n	8003a10 <RCCEx_PLL3_Config+0x14>
    {
      return HAL_TIMEOUT;
 8003a24:	2003      	movs	r0, #3
    {
      return HAL_TIMEOUT;
    }
  }
  return HAL_OK;
}
 8003a26:	bd38      	pop	{r3, r4, r5, pc}
  __HAL_RCC_PLL3_CONFIG(pll3->PLL3Source,
 8003a28:	4b2a      	ldr	r3, [pc, #168]	@ (8003ad4 <RCCEx_PLL3_Config+0xd8>)
 8003a2a:	6b1a      	ldr	r2, [r3, #48]	@ 0x30
 8003a2c:	f422 527c 	bic.w	r2, r2, #16128	@ 0x3f00
 8003a30:	f022 0203 	bic.w	r2, r2, #3
 8003a34:	6829      	ldr	r1, [r5, #0]
 8003a36:	6868      	ldr	r0, [r5, #4]
 8003a38:	ea41 2100 	orr.w	r1, r1, r0, lsl #8
 8003a3c:	430a      	orrs	r2, r1
 8003a3e:	631a      	str	r2, [r3, #48]	@ 0x30
 8003a40:	68aa      	ldr	r2, [r5, #8]
 8003a42:	3a01      	subs	r2, #1
 8003a44:	f3c2 0208 	ubfx	r2, r2, #0, #9
 8003a48:	68e9      	ldr	r1, [r5, #12]
 8003a4a:	3901      	subs	r1, #1
 8003a4c:	0249      	lsls	r1, r1, #9
 8003a4e:	b289      	uxth	r1, r1
 8003a50:	430a      	orrs	r2, r1
 8003a52:	6929      	ldr	r1, [r5, #16]
 8003a54:	3901      	subs	r1, #1
 8003a56:	0409      	lsls	r1, r1, #16
 8003a58:	f401 01fe 	and.w	r1, r1, #8323072	@ 0x7f0000
 8003a5c:	430a      	orrs	r2, r1
 8003a5e:	6969      	ldr	r1, [r5, #20]
 8003a60:	3901      	subs	r1, #1
 8003a62:	0609      	lsls	r1, r1, #24
 8003a64:	f001 41fe 	and.w	r1, r1, #2130706432	@ 0x7f000000
 8003a68:	430a      	orrs	r2, r1
 8003a6a:	645a      	str	r2, [r3, #68]	@ 0x44
  __HAL_RCC_PLL3_VCIRANGE(pll3->PLL3RGE) ;
 8003a6c:	6b1a      	ldr	r2, [r3, #48]	@ 0x30
 8003a6e:	f022 020c 	bic.w	r2, r2, #12
 8003a72:	69a9      	ldr	r1, [r5, #24]
 8003a74:	430a      	orrs	r2, r1
 8003a76:	631a      	str	r2, [r3, #48]	@ 0x30
  __HAL_RCC_PLL3_VCORANGE(pll3->PLL3VCOSEL);
 8003a78:	6b1a      	ldr	r2, [r3, #48]	@ 0x30
 8003a7a:	f022 0220 	bic.w	r2, r2, #32
 8003a7e:	69e9      	ldr	r1, [r5, #28]
 8003a80:	430a      	orrs	r2, r1
 8003a82:	631a      	str	r2, [r3, #48]	@ 0x30
  __HAL_RCC_PLL3_CLKOUT_ENABLE(pll3->PLL3ClockOut);
 8003a84:	6b1a      	ldr	r2, [r3, #48]	@ 0x30
 8003a86:	6a69      	ldr	r1, [r5, #36]	@ 0x24
 8003a88:	430a      	orrs	r2, r1
 8003a8a:	631a      	str	r2, [r3, #48]	@ 0x30
  __HAL_RCC_PLL3_FRACN_DISABLE();
 8003a8c:	6b1a      	ldr	r2, [r3, #48]	@ 0x30
 8003a8e:	f022 0210 	bic.w	r2, r2, #16
 8003a92:	631a      	str	r2, [r3, #48]	@ 0x30
  __HAL_RCC_PLL3_FRACN_CONFIG(pll3->PLL3FRACN);
 8003a94:	6c9a      	ldr	r2, [r3, #72]	@ 0x48
 8003a96:	f36f 02cf 	bfc	r2, #3, #13
 8003a9a:	6a29      	ldr	r1, [r5, #32]
 8003a9c:	ea42 02c1 	orr.w	r2, r2, r1, lsl #3
 8003aa0:	649a      	str	r2, [r3, #72]	@ 0x48
  __HAL_RCC_PLL3_FRACN_ENABLE();
 8003aa2:	6b1a      	ldr	r2, [r3, #48]	@ 0x30
 8003aa4:	f042 0210 	orr.w	r2, r2, #16
 8003aa8:	631a      	str	r2, [r3, #48]	@ 0x30
  __HAL_RCC_PLL3_ENABLE();
 8003aaa:	681a      	ldr	r2, [r3, #0]
 8003aac:	f042 5280 	orr.w	r2, r2, #268435456	@ 0x10000000
 8003ab0:	601a      	str	r2, [r3, #0]
  tickstart = HAL_GetTick();
 8003ab2:	f7ff f965 	bl	8002d80 <HAL_GetTick>
 8003ab6:	4604      	mov	r4, r0
  while (__HAL_RCC_GET_FLAG(RCC_FLAG_PLL3RDY) == 0U)
 8003ab8:	4b06      	ldr	r3, [pc, #24]	@ (8003ad4 <RCCEx_PLL3_Config+0xd8>)
 8003aba:	681b      	ldr	r3, [r3, #0]
 8003abc:	f013 5f00 	tst.w	r3, #536870912	@ 0x20000000
 8003ac0:	d106      	bne.n	8003ad0 <RCCEx_PLL3_Config+0xd4>
    if ((HAL_GetTick() - tickstart) > PLL3_TIMEOUT_VALUE)
 8003ac2:	f7ff f95d 	bl	8002d80 <HAL_GetTick>
 8003ac6:	1b00      	subs	r0, r0, r4
 8003ac8:	2802      	cmp	r0, #2
 8003aca:	d9f5      	bls.n	8003ab8 <RCCEx_PLL3_Config+0xbc>
      return HAL_TIMEOUT;
 8003acc:	2003      	movs	r0, #3
 8003ace:	e7aa      	b.n	8003a26 <RCCEx_PLL3_Config+0x2a>
  return HAL_OK;
 8003ad0:	2000      	movs	r0, #0
 8003ad2:	e7a8      	b.n	8003a26 <RCCEx_PLL3_Config+0x2a>
 8003ad4:	44020c00 	.word	0x44020c00

08003ad8 <HAL_RCCEx_PeriphCLKConfig>:
{
 8003ad8:	b5f8      	push	{r3, r4, r5, r6, r7, lr}
 8003ada:	4604      	mov	r4, r0
  if (((pPeriphClkInit->PeriphClockSelection) & RCC_PERIPHCLK_CKPER) == RCC_PERIPHCLK_CKPER)
 8003adc:	6803      	ldr	r3, [r0, #0]
 8003ade:	f013 7f80 	tst.w	r3, #16777216	@ 0x1000000
 8003ae2:	d008      	beq.n	8003af6 <HAL_RCCEx_PeriphCLKConfig+0x1e>
    __HAL_RCC_CLKP_CONFIG(pPeriphClkInit->CkperClockSelection);
 8003ae4:	4a9b      	ldr	r2, [pc, #620]	@ (8003d54 <HAL_RCCEx_PeriphCLKConfig+0x27c>)
 8003ae6:	f8d2 30e8 	ldr.w	r3, [r2, #232]	@ 0xe8
 8003aea:	f023 4340 	bic.w	r3, r3, #3221225472	@ 0xc0000000
 8003aee:	6d81      	ldr	r1, [r0, #88]	@ 0x58
 8003af0:	430b      	orrs	r3, r1
 8003af2:	f8c2 30e8 	str.w	r3, [r2, #232]	@ 0xe8
  if (((pPeriphClkInit->PeriphClockSelection) & RCC_PERIPHCLK_USART1) == RCC_PERIPHCLK_USART1)
 8003af6:	6823      	ldr	r3, [r4, #0]
 8003af8:	f013 0f01 	tst.w	r3, #1
 8003afc:	d021      	beq.n	8003b42 <HAL_RCCEx_PeriphCLKConfig+0x6a>
    switch (pPeriphClkInit->Usart1ClockSelection)
 8003afe:	6de3      	ldr	r3, [r4, #92]	@ 0x5c
 8003b00:	2b05      	cmp	r3, #5
 8003b02:	d83e      	bhi.n	8003b82 <HAL_RCCEx_PeriphCLKConfig+0xaa>
 8003b04:	e8df f003 	tbb	[pc, r3]
 8003b08:	110b0311 	.word	0x110b0311
 8003b0c:	1111      	.short	0x1111
        ret = RCCEx_PLL2_Config(&(pPeriphClkInit->PLL2));
 8003b0e:	f104 0008 	add.w	r0, r4, #8
 8003b12:	f7ff ff05 	bl	8003920 <RCCEx_PLL2_Config>
 8003b16:	4605      	mov	r5, r0
    if (ret == HAL_OK)
 8003b18:	b145      	cbz	r5, 8003b2c <HAL_RCCEx_PeriphCLKConfig+0x54>
      status = ret;
 8003b1a:	462e      	mov	r6, r5
 8003b1c:	e013      	b.n	8003b46 <HAL_RCCEx_PeriphCLKConfig+0x6e>
        ret = RCCEx_PLL3_Config(&(pPeriphClkInit->PLL3));
 8003b1e:	f104 0030 	add.w	r0, r4, #48	@ 0x30
 8003b22:	f7ff ff6b 	bl	80039fc <RCCEx_PLL3_Config>
 8003b26:	4605      	mov	r5, r0
        break;
 8003b28:	e7f6      	b.n	8003b18 <HAL_RCCEx_PeriphCLKConfig+0x40>
    switch (pPeriphClkInit->Usart1ClockSelection)
 8003b2a:	2500      	movs	r5, #0
      __HAL_RCC_USART1_CONFIG(pPeriphClkInit->Usart1ClockSelection);
 8003b2c:	4a89      	ldr	r2, [pc, #548]	@ (8003d54 <HAL_RCCEx_PeriphCLKConfig+0x27c>)
 8003b2e:	f8d2 30d8 	ldr.w	r3, [r2, #216]	@ 0xd8
 8003b32:	f023 0307 	bic.w	r3, r3, #7
 8003b36:	6de1      	ldr	r1, [r4, #92]	@ 0x5c
 8003b38:	430b      	orrs	r3, r1
 8003b3a:	f8c2 30d8 	str.w	r3, [r2, #216]	@ 0xd8
  HAL_StatusTypeDef status = HAL_OK;   /* Final status */
 8003b3e:	2600      	movs	r6, #0
 8003b40:	e001      	b.n	8003b46 <HAL_RCCEx_PeriphCLKConfig+0x6e>
 8003b42:	2600      	movs	r6, #0
  HAL_StatusTypeDef ret = HAL_OK;      /* Intermediate status */
 8003b44:	4635      	mov	r5, r6
  if (((pPeriphClkInit->PeriphClockSelection) & RCC_PERIPHCLK_USART2) == RCC_PERIPHCLK_USART2)
 8003b46:	6823      	ldr	r3, [r4, #0]
 8003b48:	f013 0f02 	tst.w	r3, #2
 8003b4c:	d036      	beq.n	8003bbc <HAL_RCCEx_PeriphCLKConfig+0xe4>
    switch (pPeriphClkInit->Usart2ClockSelection)
 8003b4e:	6e23      	ldr	r3, [r4, #96]	@ 0x60
 8003b50:	2b28      	cmp	r3, #40	@ 0x28
 8003b52:	d831      	bhi.n	8003bb8 <HAL_RCCEx_PeriphCLKConfig+0xe0>
 8003b54:	e8df f003 	tbb	[pc, r3]
 8003b58:	3030301d 	.word	0x3030301d
 8003b5c:	30303030 	.word	0x30303030
 8003b60:	30303018 	.word	0x30303018
 8003b64:	30303030 	.word	0x30303030
 8003b68:	3030302a 	.word	0x3030302a
 8003b6c:	30303030 	.word	0x30303030
 8003b70:	3030301d 	.word	0x3030301d
 8003b74:	30303030 	.word	0x30303030
 8003b78:	3030301d 	.word	0x3030301d
 8003b7c:	30303030 	.word	0x30303030
 8003b80:	1d          	.byte	0x1d
 8003b81:	00          	.byte	0x00
    switch (pPeriphClkInit->Usart1ClockSelection)
 8003b82:	2601      	movs	r6, #1
 8003b84:	4635      	mov	r5, r6
 8003b86:	e7de      	b.n	8003b46 <HAL_RCCEx_PeriphCLKConfig+0x6e>
        ret = RCCEx_PLL2_Config(&(pPeriphClkInit->PLL2));
 8003b88:	f104 0008 	add.w	r0, r4, #8
 8003b8c:	f7ff fec8 	bl	8003920 <RCCEx_PLL2_Config>
 8003b90:	4605      	mov	r5, r0
    if (ret == HAL_OK)
 8003b92:	2d00      	cmp	r5, #0
 8003b94:	f040 80d8 	bne.w	8003d48 <HAL_RCCEx_PeriphCLKConfig+0x270>
      __HAL_RCC_USART2_CONFIG(pPeriphClkInit->Usart2ClockSelection);
 8003b98:	4a6e      	ldr	r2, [pc, #440]	@ (8003d54 <HAL_RCCEx_PeriphCLKConfig+0x27c>)
 8003b9a:	f8d2 30d8 	ldr.w	r3, [r2, #216]	@ 0xd8
 8003b9e:	f023 0338 	bic.w	r3, r3, #56	@ 0x38
 8003ba2:	6e21      	ldr	r1, [r4, #96]	@ 0x60
 8003ba4:	430b      	orrs	r3, r1
 8003ba6:	f8c2 30d8 	str.w	r3, [r2, #216]	@ 0xd8
 8003baa:	e007      	b.n	8003bbc <HAL_RCCEx_PeriphCLKConfig+0xe4>
        ret = RCCEx_PLL3_Config(&(pPeriphClkInit->PLL3));
 8003bac:	f104 0030 	add.w	r0, r4, #48	@ 0x30
 8003bb0:	f7ff ff24 	bl	80039fc <RCCEx_PLL3_Config>
 8003bb4:	4605      	mov	r5, r0
        break;
 8003bb6:	e7ec      	b.n	8003b92 <HAL_RCCEx_PeriphCLKConfig+0xba>
    switch (pPeriphClkInit->Usart2ClockSelection)
 8003bb8:	2601      	movs	r6, #1
 8003bba:	4635      	mov	r5, r6
  if (((pPeriphClkInit->PeriphClockSelection) & RCC_PERIPHCLK_USART3) == RCC_PERIPHCLK_USART3)
 8003bbc:	6823      	ldr	r3, [r4, #0]
 8003bbe:	f013 0f04 	tst.w	r3, #4
 8003bc2:	d01a      	beq.n	8003bfa <HAL_RCCEx_PeriphCLKConfig+0x122>
    switch (pPeriphClkInit->Usart3ClockSelection)
 8003bc4:	6e63      	ldr	r3, [r4, #100]	@ 0x64
 8003bc6:	2b80      	cmp	r3, #128	@ 0x80
 8003bc8:	f000 80d4 	beq.w	8003d74 <HAL_RCCEx_PeriphCLKConfig+0x29c>
 8003bcc:	f200 80c4 	bhi.w	8003d58 <HAL_RCCEx_PeriphCLKConfig+0x280>
 8003bd0:	b13b      	cbz	r3, 8003be2 <HAL_RCCEx_PeriphCLKConfig+0x10a>
 8003bd2:	2b40      	cmp	r3, #64	@ 0x40
 8003bd4:	f040 80ba 	bne.w	8003d4c <HAL_RCCEx_PeriphCLKConfig+0x274>
        ret = RCCEx_PLL2_Config(&(pPeriphClkInit->PLL2));
 8003bd8:	f104 0008 	add.w	r0, r4, #8
 8003bdc:	f7ff fea0 	bl	8003920 <RCCEx_PLL2_Config>
 8003be0:	4605      	mov	r5, r0
    if (ret == HAL_OK)
 8003be2:	2d00      	cmp	r5, #0
 8003be4:	f040 80cc 	bne.w	8003d80 <HAL_RCCEx_PeriphCLKConfig+0x2a8>
      __HAL_RCC_USART3_CONFIG(pPeriphClkInit->Usart3ClockSelection);
 8003be8:	4a5a      	ldr	r2, [pc, #360]	@ (8003d54 <HAL_RCCEx_PeriphCLKConfig+0x27c>)
 8003bea:	f8d2 30d8 	ldr.w	r3, [r2, #216]	@ 0xd8
 8003bee:	f423 73e0 	bic.w	r3, r3, #448	@ 0x1c0
 8003bf2:	6e61      	ldr	r1, [r4, #100]	@ 0x64
 8003bf4:	430b      	orrs	r3, r1
 8003bf6:	f8c2 30d8 	str.w	r3, [r2, #216]	@ 0xd8
  if (((pPeriphClkInit->PeriphClockSelection) & RCC_PERIPHCLK_UART4) == RCC_PERIPHCLK_UART4)
 8003bfa:	6823      	ldr	r3, [r4, #0]
 8003bfc:	f013 0f08 	tst.w	r3, #8
 8003c00:	d01c      	beq.n	8003c3c <HAL_RCCEx_PeriphCLKConfig+0x164>
    switch (pPeriphClkInit->Uart4ClockSelection)
 8003c02:	6ea3      	ldr	r3, [r4, #104]	@ 0x68
 8003c04:	f5b3 6f80 	cmp.w	r3, #1024	@ 0x400
 8003c08:	f000 80ce 	beq.w	8003da8 <HAL_RCCEx_PeriphCLKConfig+0x2d0>
 8003c0c:	f200 80bd 	bhi.w	8003d8a <HAL_RCCEx_PeriphCLKConfig+0x2b2>
 8003c10:	b143      	cbz	r3, 8003c24 <HAL_RCCEx_PeriphCLKConfig+0x14c>
 8003c12:	f5b3 7f00 	cmp.w	r3, #512	@ 0x200
 8003c16:	f040 80b5 	bne.w	8003d84 <HAL_RCCEx_PeriphCLKConfig+0x2ac>
        ret = RCCEx_PLL2_Config(&(pPeriphClkInit->PLL2));
 8003c1a:	f104 0008 	add.w	r0, r4, #8
 8003c1e:	f7ff fe7f 	bl	8003920 <RCCEx_PLL2_Config>
 8003c22:	4605      	mov	r5, r0
    if (ret == HAL_OK)
 8003c24:	2d00      	cmp	r5, #0
 8003c26:	f040 80c5 	bne.w	8003db4 <HAL_RCCEx_PeriphCLKConfig+0x2dc>
      __HAL_RCC_UART4_CONFIG(pPeriphClkInit->Uart4ClockSelection);
 8003c2a:	4a4a      	ldr	r2, [pc, #296]	@ (8003d54 <HAL_RCCEx_PeriphCLKConfig+0x27c>)
 8003c2c:	f8d2 30d8 	ldr.w	r3, [r2, #216]	@ 0xd8
 8003c30:	f423 6360 	bic.w	r3, r3, #3584	@ 0xe00
 8003c34:	6ea1      	ldr	r1, [r4, #104]	@ 0x68
 8003c36:	430b      	orrs	r3, r1
 8003c38:	f8c2 30d8 	str.w	r3, [r2, #216]	@ 0xd8
  if (((pPeriphClkInit->PeriphClockSelection) & RCC_PERIPHCLK_UART5) == RCC_PERIPHCLK_UART5)
 8003c3c:	6823      	ldr	r3, [r4, #0]
 8003c3e:	f013 0f10 	tst.w	r3, #16
 8003c42:	d01c      	beq.n	8003c7e <HAL_RCCEx_PeriphCLKConfig+0x1a6>
    switch (pPeriphClkInit->Uart5ClockSelection)
 8003c44:	6ee3      	ldr	r3, [r4, #108]	@ 0x6c
 8003c46:	f5b3 5f00 	cmp.w	r3, #8192	@ 0x2000
 8003c4a:	f000 80c7 	beq.w	8003ddc <HAL_RCCEx_PeriphCLKConfig+0x304>
 8003c4e:	f200 80b6 	bhi.w	8003dbe <HAL_RCCEx_PeriphCLKConfig+0x2e6>
 8003c52:	b143      	cbz	r3, 8003c66 <HAL_RCCEx_PeriphCLKConfig+0x18e>
 8003c54:	f5b3 5f80 	cmp.w	r3, #4096	@ 0x1000
 8003c58:	f040 80ae 	bne.w	8003db8 <HAL_RCCEx_PeriphCLKConfig+0x2e0>
        ret = RCCEx_PLL2_Config(&(pPeriphClkInit->PLL2));
 8003c5c:	f104 0008 	add.w	r0, r4, #8
 8003c60:	f7ff fe5e 	bl	8003920 <RCCEx_PLL2_Config>
 8003c64:	4605      	mov	r5, r0
    if (ret == HAL_OK)
 8003c66:	2d00      	cmp	r5, #0
 8003c68:	f040 80be 	bne.w	8003de8 <HAL_RCCEx_PeriphCLKConfig+0x310>
      __HAL_RCC_UART5_CONFIG(pPeriphClkInit->Uart5ClockSelection);
 8003c6c:	4a39      	ldr	r2, [pc, #228]	@ (8003d54 <HAL_RCCEx_PeriphCLKConfig+0x27c>)
 8003c6e:	f8d2 30d8 	ldr.w	r3, [r2, #216]	@ 0xd8
 8003c72:	f423 43e0 	bic.w	r3, r3, #28672	@ 0x7000
 8003c76:	6ee1      	ldr	r1, [r4, #108]	@ 0x6c
 8003c78:	430b      	orrs	r3, r1
 8003c7a:	f8c2 30d8 	str.w	r3, [r2, #216]	@ 0xd8
  if (((pPeriphClkInit->PeriphClockSelection) & RCC_PERIPHCLK_USART6) == RCC_PERIPHCLK_USART6)
 8003c7e:	6823      	ldr	r3, [r4, #0]
 8003c80:	f013 0f20 	tst.w	r3, #32
 8003c84:	d01c      	beq.n	8003cc0 <HAL_RCCEx_PeriphCLKConfig+0x1e8>
    switch (pPeriphClkInit->Usart6ClockSelection)
 8003c86:	6f23      	ldr	r3, [r4, #112]	@ 0x70
 8003c88:	f5b3 3f80 	cmp.w	r3, #65536	@ 0x10000
 8003c8c:	f000 80c0 	beq.w	8003e10 <HAL_RCCEx_PeriphCLKConfig+0x338>
 8003c90:	f200 80af 	bhi.w	8003df2 <HAL_RCCEx_PeriphCLKConfig+0x31a>
 8003c94:	b143      	cbz	r3, 8003ca8 <HAL_RCCEx_PeriphCLKConfig+0x1d0>
 8003c96:	f5b3 4f00 	cmp.w	r3, #32768	@ 0x8000
 8003c9a:	f040 80a7 	bne.w	8003dec <HAL_RCCEx_PeriphCLKConfig+0x314>
        ret = RCCEx_PLL2_Config(&(pPeriphClkInit->PLL2));
 8003c9e:	f104 0008 	add.w	r0, r4, #8
 8003ca2:	f7ff fe3d 	bl	8003920 <RCCEx_PLL2_Config>
 8003ca6:	4605      	mov	r5, r0
    if (ret == HAL_OK)
 8003ca8:	2d00      	cmp	r5, #0
 8003caa:	f040 80b7 	bne.w	8003e1c <HAL_RCCEx_PeriphCLKConfig+0x344>
      __HAL_RCC_USART6_CONFIG(pPeriphClkInit->Usart6ClockSelection);
 8003cae:	4a29      	ldr	r2, [pc, #164]	@ (8003d54 <HAL_RCCEx_PeriphCLKConfig+0x27c>)
 8003cb0:	f8d2 30d8 	ldr.w	r3, [r2, #216]	@ 0xd8
 8003cb4:	f423 3360 	bic.w	r3, r3, #229376	@ 0x38000
 8003cb8:	6f21      	ldr	r1, [r4, #112]	@ 0x70
 8003cba:	430b      	orrs	r3, r1
 8003cbc:	f8c2 30d8 	str.w	r3, [r2, #216]	@ 0xd8
  if (((pPeriphClkInit->PeriphClockSelection) & RCC_PERIPHCLK_UART7) == RCC_PERIPHCLK_UART7)
 8003cc0:	6823      	ldr	r3, [r4, #0]
 8003cc2:	f013 0f40 	tst.w	r3, #64	@ 0x40
 8003cc6:	d01c      	beq.n	8003d02 <HAL_RCCEx_PeriphCLKConfig+0x22a>
    switch (pPeriphClkInit->Uart7ClockSelection)
 8003cc8:	6f63      	ldr	r3, [r4, #116]	@ 0x74
 8003cca:	f5b3 2f00 	cmp.w	r3, #524288	@ 0x80000
 8003cce:	f000 80b9 	beq.w	8003e44 <HAL_RCCEx_PeriphCLKConfig+0x36c>
 8003cd2:	f200 80a8 	bhi.w	8003e26 <HAL_RCCEx_PeriphCLKConfig+0x34e>
 8003cd6:	b143      	cbz	r3, 8003cea <HAL_RCCEx_PeriphCLKConfig+0x212>
 8003cd8:	f5b3 2f80 	cmp.w	r3, #262144	@ 0x40000
 8003cdc:	f040 80a0 	bne.w	8003e20 <HAL_RCCEx_PeriphCLKConfig+0x348>
        ret = RCCEx_PLL2_Config(&(pPeriphClkInit->PLL2));
 8003ce0:	f104 0008 	add.w	r0, r4, #8
 8003ce4:	f7ff fe1c 	bl	8003920 <RCCEx_PLL2_Config>
 8003ce8:	4605      	mov	r5, r0
    if (ret == HAL_OK)
 8003cea:	2d00      	cmp	r5, #0
 8003cec:	f040 80b0 	bne.w	8003e50 <HAL_RCCEx_PeriphCLKConfig+0x378>
      __HAL_RCC_UART7_CONFIG(pPeriphClkInit->Uart7ClockSelection);
 8003cf0:	4a18      	ldr	r2, [pc, #96]	@ (8003d54 <HAL_RCCEx_PeriphCLKConfig+0x27c>)
 8003cf2:	f8d2 30d8 	ldr.w	r3, [r2, #216]	@ 0xd8
 8003cf6:	f423 13e0 	bic.w	r3, r3, #1835008	@ 0x1c0000
 8003cfa:	6f61      	ldr	r1, [r4, #116]	@ 0x74
 8003cfc:	430b      	orrs	r3, r1
 8003cfe:	f8c2 30d8 	str.w	r3, [r2, #216]	@ 0xd8
  if (((pPeriphClkInit->PeriphClockSelection) & RCC_PERIPHCLK_UART8) == RCC_PERIPHCLK_UART8)
 8003d02:	6823      	ldr	r3, [r4, #0]
 8003d04:	f013 0f80 	tst.w	r3, #128	@ 0x80
 8003d08:	f000 80bd 	beq.w	8003e86 <HAL_RCCEx_PeriphCLKConfig+0x3ae>
    switch (pPeriphClkInit->Uart8ClockSelection)
 8003d0c:	6fa3      	ldr	r3, [r4, #120]	@ 0x78
 8003d0e:	f5b3 0f80 	cmp.w	r3, #4194304	@ 0x400000
 8003d12:	f000 80b1 	beq.w	8003e78 <HAL_RCCEx_PeriphCLKConfig+0x3a0>
 8003d16:	f200 80a0 	bhi.w	8003e5a <HAL_RCCEx_PeriphCLKConfig+0x382>
 8003d1a:	b143      	cbz	r3, 8003d2e <HAL_RCCEx_PeriphCLKConfig+0x256>
 8003d1c:	f5b3 1f00 	cmp.w	r3, #2097152	@ 0x200000
 8003d20:	f040 8098 	bne.w	8003e54 <HAL_RCCEx_PeriphCLKConfig+0x37c>
        ret = RCCEx_PLL2_Config(&(pPeriphClkInit->PLL2));
 8003d24:	f104 0008 	add.w	r0, r4, #8
 8003d28:	f7ff fdfa 	bl	8003920 <RCCEx_PLL2_Config>
 8003d2c:	4605      	mov	r5, r0
    if (ret == HAL_OK)
 8003d2e:	2d00      	cmp	r5, #0
 8003d30:	f040 80a8 	bne.w	8003e84 <HAL_RCCEx_PeriphCLKConfig+0x3ac>
      __HAL_RCC_UART8_CONFIG(pPeriphClkInit->Uart8ClockSelection);
 8003d34:	4a07      	ldr	r2, [pc, #28]	@ (8003d54 <HAL_RCCEx_PeriphCLKConfig+0x27c>)
 8003d36:	f8d2 30d8 	ldr.w	r3, [r2, #216]	@ 0xd8
 8003d3a:	f423 0360 	bic.w	r3, r3, #14680064	@ 0xe00000
 8003d3e:	6fa1      	ldr	r1, [r4, #120]	@ 0x78
 8003d40:	430b      	orrs	r3, r1
 8003d42:	f8c2 30d8 	str.w	r3, [r2, #216]	@ 0xd8
 8003d46:	e09e      	b.n	8003e86 <HAL_RCCEx_PeriphCLKConfig+0x3ae>
      status = ret;
 8003d48:	462e      	mov	r6, r5
 8003d4a:	e737      	b.n	8003bbc <HAL_RCCEx_PeriphCLKConfig+0xe4>
    switch (pPeriphClkInit->Usart3ClockSelection)
 8003d4c:	2601      	movs	r6, #1
 8003d4e:	4635      	mov	r5, r6
 8003d50:	e753      	b.n	8003bfa <HAL_RCCEx_PeriphCLKConfig+0x122>
 8003d52:	bf00      	nop
 8003d54:	44020c00 	.word	0x44020c00
 8003d58:	f5b3 7f80 	cmp.w	r3, #256	@ 0x100
 8003d5c:	f43f af41 	beq.w	8003be2 <HAL_RCCEx_PeriphCLKConfig+0x10a>
 8003d60:	f5b3 7fa0 	cmp.w	r3, #320	@ 0x140
 8003d64:	f43f af3d 	beq.w	8003be2 <HAL_RCCEx_PeriphCLKConfig+0x10a>
 8003d68:	2bc0      	cmp	r3, #192	@ 0xc0
 8003d6a:	f43f af3a 	beq.w	8003be2 <HAL_RCCEx_PeriphCLKConfig+0x10a>
 8003d6e:	2601      	movs	r6, #1
 8003d70:	4635      	mov	r5, r6
 8003d72:	e742      	b.n	8003bfa <HAL_RCCEx_PeriphCLKConfig+0x122>
        ret = RCCEx_PLL3_Config(&(pPeriphClkInit->PLL3));
 8003d74:	f104 0030 	add.w	r0, r4, #48	@ 0x30
 8003d78:	f7ff fe40 	bl	80039fc <RCCEx_PLL3_Config>
 8003d7c:	4605      	mov	r5, r0
        break;
 8003d7e:	e730      	b.n	8003be2 <HAL_RCCEx_PeriphCLKConfig+0x10a>
      status = ret;
 8003d80:	462e      	mov	r6, r5
 8003d82:	e73a      	b.n	8003bfa <HAL_RCCEx_PeriphCLKConfig+0x122>
    switch (pPeriphClkInit->Uart4ClockSelection)
 8003d84:	2601      	movs	r6, #1
 8003d86:	4635      	mov	r5, r6
 8003d88:	e758      	b.n	8003c3c <HAL_RCCEx_PeriphCLKConfig+0x164>
 8003d8a:	f5b3 6f00 	cmp.w	r3, #2048	@ 0x800
 8003d8e:	f43f af49 	beq.w	8003c24 <HAL_RCCEx_PeriphCLKConfig+0x14c>
 8003d92:	f5b3 6f20 	cmp.w	r3, #2560	@ 0xa00
 8003d96:	f43f af45 	beq.w	8003c24 <HAL_RCCEx_PeriphCLKConfig+0x14c>
 8003d9a:	f5b3 6fc0 	cmp.w	r3, #1536	@ 0x600
 8003d9e:	f43f af41 	beq.w	8003c24 <HAL_RCCEx_PeriphCLKConfig+0x14c>
 8003da2:	2601      	movs	r6, #1
 8003da4:	4635      	mov	r5, r6
 8003da6:	e749      	b.n	8003c3c <HAL_RCCEx_PeriphCLKConfig+0x164>
        ret = RCCEx_PLL3_Config(&(pPeriphClkInit->PLL3));
 8003da8:	f104 0030 	add.w	r0, r4, #48	@ 0x30
 8003dac:	f7ff fe26 	bl	80039fc <RCCEx_PLL3_Config>
 8003db0:	4605      	mov	r5, r0
        break;
 8003db2:	e737      	b.n	8003c24 <HAL_RCCEx_PeriphCLKConfig+0x14c>
      status = ret;
 8003db4:	462e      	mov	r6, r5
 8003db6:	e741      	b.n	8003c3c <HAL_RCCEx_PeriphCLKConfig+0x164>
    switch (pPeriphClkInit->Uart5ClockSelection)
 8003db8:	2601      	movs	r6, #1
 8003dba:	4635      	mov	r5, r6
 8003dbc:	e75f      	b.n	8003c7e <HAL_RCCEx_PeriphCLKConfig+0x1a6>
 8003dbe:	f5b3 4f80 	cmp.w	r3, #16384	@ 0x4000
 8003dc2:	f43f af50 	beq.w	8003c66 <HAL_RCCEx_PeriphCLKConfig+0x18e>
 8003dc6:	f5b3 4fa0 	cmp.w	r3, #20480	@ 0x5000
 8003dca:	f43f af4c 	beq.w	8003c66 <HAL_RCCEx_PeriphCLKConfig+0x18e>
 8003dce:	f5b3 5f40 	cmp.w	r3, #12288	@ 0x3000
 8003dd2:	f43f af48 	beq.w	8003c66 <HAL_RCCEx_PeriphCLKConfig+0x18e>
 8003dd6:	2601      	movs	r6, #1
 8003dd8:	4635      	mov	r5, r6
 8003dda:	e750      	b.n	8003c7e <HAL_RCCEx_PeriphCLKConfig+0x1a6>
        ret = RCCEx_PLL3_Config(&(pPeriphClkInit->PLL3));
 8003ddc:	f104 0030 	add.w	r0, r4, #48	@ 0x30
 8003de0:	f7ff fe0c 	bl	80039fc <RCCEx_PLL3_Config>
 8003de4:	4605      	mov	r5, r0
        break;
 8003de6:	e73e      	b.n	8003c66 <HAL_RCCEx_PeriphCLKConfig+0x18e>
      status = ret;
 8003de8:	462e      	mov	r6, r5
 8003dea:	e748      	b.n	8003c7e <HAL_RCCEx_PeriphCLKConfig+0x1a6>
    switch (pPeriphClkInit->Usart6ClockSelection)
 8003dec:	2601      	movs	r6, #1
 8003dee:	4635      	mov	r5, r6
 8003df0:	e766      	b.n	8003cc0 <HAL_RCCEx_PeriphCLKConfig+0x1e8>
 8003df2:	f5b3 3f00 	cmp.w	r3, #131072	@ 0x20000
 8003df6:	f43f af57 	beq.w	8003ca8 <HAL_RCCEx_PeriphCLKConfig+0x1d0>
 8003dfa:	f5b3 3f20 	cmp.w	r3, #163840	@ 0x28000
 8003dfe:	f43f af53 	beq.w	8003ca8 <HAL_RCCEx_PeriphCLKConfig+0x1d0>
 8003e02:	f5b3 3fc0 	cmp.w	r3, #98304	@ 0x18000
 8003e06:	f43f af4f 	beq.w	8003ca8 <HAL_RCCEx_PeriphCLKConfig+0x1d0>
 8003e0a:	2601      	movs	r6, #1
 8003e0c:	4635      	mov	r5, r6
 8003e0e:	e757      	b.n	8003cc0 <HAL_RCCEx_PeriphCLKConfig+0x1e8>
        ret = RCCEx_PLL3_Config(&(pPeriphClkInit->PLL3));
 8003e10:	f104 0030 	add.w	r0, r4, #48	@ 0x30
 8003e14:	f7ff fdf2 	bl	80039fc <RCCEx_PLL3_Config>
 8003e18:	4605      	mov	r5, r0
        break;
 8003e1a:	e745      	b.n	8003ca8 <HAL_RCCEx_PeriphCLKConfig+0x1d0>
      status = ret;
 8003e1c:	462e      	mov	r6, r5
 8003e1e:	e74f      	b.n	8003cc0 <HAL_RCCEx_PeriphCLKConfig+0x1e8>
    switch (pPeriphClkInit->Uart7ClockSelection)
 8003e20:	2601      	movs	r6, #1
 8003e22:	4635      	mov	r5, r6
 8003e24:	e76d      	b.n	8003d02 <HAL_RCCEx_PeriphCLKConfig+0x22a>
 8003e26:	f5b3 1f80 	cmp.w	r3, #1048576	@ 0x100000
 8003e2a:	f43f af5e 	beq.w	8003cea <HAL_RCCEx_PeriphCLKConfig+0x212>
 8003e2e:	f5b3 1fa0 	cmp.w	r3, #1310720	@ 0x140000
 8003e32:	f43f af5a 	beq.w	8003cea <HAL_RCCEx_PeriphCLKConfig+0x212>
 8003e36:	f5b3 2f40 	cmp.w	r3, #786432	@ 0xc0000
 8003e3a:	f43f af56 	beq.w	8003cea <HAL_RCCEx_PeriphCLKConfig+0x212>
 8003e3e:	2601      	movs	r6, #1
 8003e40:	4635      	mov	r5, r6
 8003e42:	e75e      	b.n	8003d02 <HAL_RCCEx_PeriphCLKConfig+0x22a>
        ret = RCCEx_PLL3_Config(&(pPeriphClkInit->PLL3));
 8003e44:	f104 0030 	add.w	r0, r4, #48	@ 0x30
 8003e48:	f7ff fdd8 	bl	80039fc <RCCEx_PLL3_Config>
 8003e4c:	4605      	mov	r5, r0
        break;
 8003e4e:	e74c      	b.n	8003cea <HAL_RCCEx_PeriphCLKConfig+0x212>
      status = ret;
 8003e50:	462e      	mov	r6, r5
 8003e52:	e756      	b.n	8003d02 <HAL_RCCEx_PeriphCLKConfig+0x22a>
    switch (pPeriphClkInit->Uart8ClockSelection)
 8003e54:	2601      	movs	r6, #1
 8003e56:	4635      	mov	r5, r6
 8003e58:	e015      	b.n	8003e86 <HAL_RCCEx_PeriphCLKConfig+0x3ae>
 8003e5a:	f5b3 0f00 	cmp.w	r3, #8388608	@ 0x800000
 8003e5e:	f43f af66 	beq.w	8003d2e <HAL_RCCEx_PeriphCLKConfig+0x256>
 8003e62:	f5b3 0f20 	cmp.w	r3, #10485760	@ 0xa00000
 8003e66:	f43f af62 	beq.w	8003d2e <HAL_RCCEx_PeriphCLKConfig+0x256>
 8003e6a:	f5b3 0fc0 	cmp.w	r3, #6291456	@ 0x600000
 8003e6e:	f43f af5e 	beq.w	8003d2e <HAL_RCCEx_PeriphCLKConfig+0x256>
 8003e72:	2601      	movs	r6, #1
 8003e74:	4635      	mov	r5, r6
 8003e76:	e006      	b.n	8003e86 <HAL_RCCEx_PeriphCLKConfig+0x3ae>
        ret = RCCEx_PLL3_Config(&(pPeriphClkInit->PLL3));
 8003e78:	f104 0030 	add.w	r0, r4, #48	@ 0x30
 8003e7c:	f7ff fdbe 	bl	80039fc <RCCEx_PLL3_Config>
 8003e80:	4605      	mov	r5, r0
        break;
 8003e82:	e754      	b.n	8003d2e <HAL_RCCEx_PeriphCLKConfig+0x256>
      status = ret;
 8003e84:	462e      	mov	r6, r5
  if (((pPeriphClkInit->PeriphClockSelection) & RCC_PERIPHCLK_UART9) == RCC_PERIPHCLK_UART9)
 8003e86:	6823      	ldr	r3, [r4, #0]
 8003e88:	f413 7f80 	tst.w	r3, #256	@ 0x100
 8003e8c:	d02e      	beq.n	8003eec <HAL_RCCEx_PeriphCLKConfig+0x414>
    switch (pPeriphClkInit->Uart9ClockSelection)
 8003e8e:	6fe3      	ldr	r3, [r4, #124]	@ 0x7c
 8003e90:	f1b3 7f00 	cmp.w	r3, #33554432	@ 0x2000000
 8003e94:	d023      	beq.n	8003ede <HAL_RCCEx_PeriphCLKConfig+0x406>
 8003e96:	d816      	bhi.n	8003ec6 <HAL_RCCEx_PeriphCLKConfig+0x3ee>
 8003e98:	b13b      	cbz	r3, 8003eaa <HAL_RCCEx_PeriphCLKConfig+0x3d2>
 8003e9a:	f1b3 7f80 	cmp.w	r3, #16777216	@ 0x1000000
 8003e9e:	d10f      	bne.n	8003ec0 <HAL_RCCEx_PeriphCLKConfig+0x3e8>
        ret = RCCEx_PLL2_Config(&(pPeriphClkInit->PLL2));
 8003ea0:	f104 0008 	add.w	r0, r4, #8
 8003ea4:	f7ff fd3c 	bl	8003920 <RCCEx_PLL2_Config>
 8003ea8:	4605      	mov	r5, r0
    if (ret == HAL_OK)
 8003eaa:	b9f5      	cbnz	r5, 8003eea <HAL_RCCEx_PeriphCLKConfig+0x412>
      __HAL_RCC_UART9_CONFIG(pPeriphClkInit->Uart9ClockSelection);
 8003eac:	4aa6      	ldr	r2, [pc, #664]	@ (8004148 <HAL_RCCEx_PeriphCLKConfig+0x670>)
 8003eae:	f8d2 30d8 	ldr.w	r3, [r2, #216]	@ 0xd8
 8003eb2:	f023 63e0 	bic.w	r3, r3, #117440512	@ 0x7000000
 8003eb6:	6fe1      	ldr	r1, [r4, #124]	@ 0x7c
 8003eb8:	430b      	orrs	r3, r1
 8003eba:	f8c2 30d8 	str.w	r3, [r2, #216]	@ 0xd8
 8003ebe:	e015      	b.n	8003eec <HAL_RCCEx_PeriphCLKConfig+0x414>
    switch (pPeriphClkInit->Uart9ClockSelection)
 8003ec0:	2601      	movs	r6, #1
 8003ec2:	4635      	mov	r5, r6
 8003ec4:	e012      	b.n	8003eec <HAL_RCCEx_PeriphCLKConfig+0x414>
 8003ec6:	f1b3 6f80 	cmp.w	r3, #67108864	@ 0x4000000
 8003eca:	d0ee      	beq.n	8003eaa <HAL_RCCEx_PeriphCLKConfig+0x3d2>
 8003ecc:	f1b3 6fa0 	cmp.w	r3, #83886080	@ 0x5000000
 8003ed0:	d0eb      	beq.n	8003eaa <HAL_RCCEx_PeriphCLKConfig+0x3d2>
 8003ed2:	f1b3 7f40 	cmp.w	r3, #50331648	@ 0x3000000
 8003ed6:	d0e8      	beq.n	8003eaa <HAL_RCCEx_PeriphCLKConfig+0x3d2>
 8003ed8:	2601      	movs	r6, #1
 8003eda:	4635      	mov	r5, r6
 8003edc:	e006      	b.n	8003eec <HAL_RCCEx_PeriphCLKConfig+0x414>
        ret = RCCEx_PLL3_Config(&(pPeriphClkInit->PLL3));
 8003ede:	f104 0030 	add.w	r0, r4, #48	@ 0x30
 8003ee2:	f7ff fd8b 	bl	80039fc <RCCEx_PLL3_Config>
 8003ee6:	4605      	mov	r5, r0
        break;
 8003ee8:	e7df      	b.n	8003eaa <HAL_RCCEx_PeriphCLKConfig+0x3d2>
      status = ret;
 8003eea:	462e      	mov	r6, r5
  if (((pPeriphClkInit->PeriphClockSelection) & RCC_PERIPHCLK_USART10) == RCC_PERIPHCLK_USART10)
 8003eec:	6823      	ldr	r3, [r4, #0]
 8003eee:	f413 7f00 	tst.w	r3, #512	@ 0x200
 8003ef2:	d030      	beq.n	8003f56 <HAL_RCCEx_PeriphCLKConfig+0x47e>
    switch (pPeriphClkInit->Usart10ClockSelection)
 8003ef4:	f8d4 3080 	ldr.w	r3, [r4, #128]	@ 0x80
 8003ef8:	f1b3 5f80 	cmp.w	r3, #268435456	@ 0x10000000
 8003efc:	d024      	beq.n	8003f48 <HAL_RCCEx_PeriphCLKConfig+0x470>
 8003efe:	d817      	bhi.n	8003f30 <HAL_RCCEx_PeriphCLKConfig+0x458>
 8003f00:	b13b      	cbz	r3, 8003f12 <HAL_RCCEx_PeriphCLKConfig+0x43a>
 8003f02:	f1b3 6f00 	cmp.w	r3, #134217728	@ 0x8000000
 8003f06:	d110      	bne.n	8003f2a <HAL_RCCEx_PeriphCLKConfig+0x452>
        ret = RCCEx_PLL2_Config(&(pPeriphClkInit->PLL2));
 8003f08:	f104 0008 	add.w	r0, r4, #8
 8003f0c:	f7ff fd08 	bl	8003920 <RCCEx_PLL2_Config>
 8003f10:	4605      	mov	r5, r0
    if (ret == HAL_OK)
 8003f12:	b9fd      	cbnz	r5, 8003f54 <HAL_RCCEx_PeriphCLKConfig+0x47c>
      __HAL_RCC_USART10_CONFIG(pPeriphClkInit->Usart10ClockSelection);
 8003f14:	4a8c      	ldr	r2, [pc, #560]	@ (8004148 <HAL_RCCEx_PeriphCLKConfig+0x670>)
 8003f16:	f8d2 30d8 	ldr.w	r3, [r2, #216]	@ 0xd8
 8003f1a:	f023 5360 	bic.w	r3, r3, #939524096	@ 0x38000000
 8003f1e:	f8d4 1080 	ldr.w	r1, [r4, #128]	@ 0x80
 8003f22:	430b      	orrs	r3, r1
 8003f24:	f8c2 30d8 	str.w	r3, [r2, #216]	@ 0xd8
 8003f28:	e015      	b.n	8003f56 <HAL_RCCEx_PeriphCLKConfig+0x47e>
    switch (pPeriphClkInit->Usart10ClockSelection)
 8003f2a:	2601      	movs	r6, #1
 8003f2c:	4635      	mov	r5, r6
 8003f2e:	e012      	b.n	8003f56 <HAL_RCCEx_PeriphCLKConfig+0x47e>
 8003f30:	f1b3 5f00 	cmp.w	r3, #536870912	@ 0x20000000
 8003f34:	d0ed      	beq.n	8003f12 <HAL_RCCEx_PeriphCLKConfig+0x43a>
 8003f36:	f1b3 5f20 	cmp.w	r3, #671088640	@ 0x28000000
 8003f3a:	d0ea      	beq.n	8003f12 <HAL_RCCEx_PeriphCLKConfig+0x43a>
 8003f3c:	f1b3 5fc0 	cmp.w	r3, #402653184	@ 0x18000000
 8003f40:	d0e7      	beq.n	8003f12 <HAL_RCCEx_PeriphCLKConfig+0x43a>
 8003f42:	2601      	movs	r6, #1
 8003f44:	4635      	mov	r5, r6
 8003f46:	e006      	b.n	8003f56 <HAL_RCCEx_PeriphCLKConfig+0x47e>
        ret = RCCEx_PLL3_Config(&(pPeriphClkInit->PLL3));
 8003f48:	f104 0030 	add.w	r0, r4, #48	@ 0x30
 8003f4c:	f7ff fd56 	bl	80039fc <RCCEx_PLL3_Config>
 8003f50:	4605      	mov	r5, r0
        break;
 8003f52:	e7de      	b.n	8003f12 <HAL_RCCEx_PeriphCLKConfig+0x43a>
      status = ret;
 8003f54:	462e      	mov	r6, r5
  if (((pPeriphClkInit->PeriphClockSelection) & RCC_PERIPHCLK_USART11) == RCC_PERIPHCLK_USART11)
 8003f56:	6823      	ldr	r3, [r4, #0]
 8003f58:	f413 6f80 	tst.w	r3, #1024	@ 0x400
 8003f5c:	d019      	beq.n	8003f92 <HAL_RCCEx_PeriphCLKConfig+0x4ba>
    switch (pPeriphClkInit->Usart11ClockSelection)
 8003f5e:	f8d4 3084 	ldr.w	r3, [r4, #132]	@ 0x84
 8003f62:	2b05      	cmp	r3, #5
 8003f64:	d86a      	bhi.n	800403c <HAL_RCCEx_PeriphCLKConfig+0x564>
 8003f66:	e8df f003 	tbb	[pc, r3]
 8003f6a:	0308      	.short	0x0308
 8003f6c:	08080863 	.word	0x08080863
        ret = RCCEx_PLL2_Config(&(pPeriphClkInit->PLL2));
 8003f70:	f104 0008 	add.w	r0, r4, #8
 8003f74:	f7ff fcd4 	bl	8003920 <RCCEx_PLL2_Config>
 8003f78:	4605      	mov	r5, r0
    if (ret == HAL_OK)
 8003f7a:	2d00      	cmp	r5, #0
 8003f7c:	d161      	bne.n	8004042 <HAL_RCCEx_PeriphCLKConfig+0x56a>
      __HAL_RCC_USART11_CONFIG(pPeriphClkInit->Usart11ClockSelection);
 8003f7e:	4a72      	ldr	r2, [pc, #456]	@ (8004148 <HAL_RCCEx_PeriphCLKConfig+0x670>)
 8003f80:	f8d2 30dc 	ldr.w	r3, [r2, #220]	@ 0xdc
 8003f84:	f023 0307 	bic.w	r3, r3, #7
 8003f88:	f8d4 1084 	ldr.w	r1, [r4, #132]	@ 0x84
 8003f8c:	430b      	orrs	r3, r1
 8003f8e:	f8c2 30dc 	str.w	r3, [r2, #220]	@ 0xdc
  if (((pPeriphClkInit->PeriphClockSelection) & RCC_PERIPHCLK_UART12) == RCC_PERIPHCLK_UART12)
 8003f92:	6823      	ldr	r3, [r4, #0]
 8003f94:	f413 6f00 	tst.w	r3, #2048	@ 0x800
 8003f98:	d018      	beq.n	8003fcc <HAL_RCCEx_PeriphCLKConfig+0x4f4>
    switch (pPeriphClkInit->Uart12ClockSelection)
 8003f9a:	f8d4 3088 	ldr.w	r3, [r4, #136]	@ 0x88
 8003f9e:	2b20      	cmp	r3, #32
 8003fa0:	d05d      	beq.n	800405e <HAL_RCCEx_PeriphCLKConfig+0x586>
 8003fa2:	d853      	bhi.n	800404c <HAL_RCCEx_PeriphCLKConfig+0x574>
 8003fa4:	b133      	cbz	r3, 8003fb4 <HAL_RCCEx_PeriphCLKConfig+0x4dc>
 8003fa6:	2b10      	cmp	r3, #16
 8003fa8:	d14d      	bne.n	8004046 <HAL_RCCEx_PeriphCLKConfig+0x56e>
        ret = RCCEx_PLL2_Config(&(pPeriphClkInit->PLL2));
 8003faa:	f104 0008 	add.w	r0, r4, #8
 8003fae:	f7ff fcb7 	bl	8003920 <RCCEx_PLL2_Config>
 8003fb2:	4605      	mov	r5, r0
    if (ret == HAL_OK)
 8003fb4:	2d00      	cmp	r5, #0
 8003fb6:	d158      	bne.n	800406a <HAL_RCCEx_PeriphCLKConfig+0x592>
      __HAL_RCC_UART12_CONFIG(pPeriphClkInit->Uart12ClockSelection);
 8003fb8:	4a63      	ldr	r2, [pc, #396]	@ (8004148 <HAL_RCCEx_PeriphCLKConfig+0x670>)
 8003fba:	f8d2 30dc 	ldr.w	r3, [r2, #220]	@ 0xdc
 8003fbe:	f023 0370 	bic.w	r3, r3, #112	@ 0x70
 8003fc2:	f8d4 1088 	ldr.w	r1, [r4, #136]	@ 0x88
 8003fc6:	430b      	orrs	r3, r1
 8003fc8:	f8c2 30dc 	str.w	r3, [r2, #220]	@ 0xdc
  if (((pPeriphClkInit->PeriphClockSelection) & RCC_PERIPHCLK_LPUART1) == RCC_PERIPHCLK_LPUART1)
 8003fcc:	6823      	ldr	r3, [r4, #0]
 8003fce:	f413 5f80 	tst.w	r3, #4096	@ 0x1000
 8003fd2:	d01a      	beq.n	800400a <HAL_RCCEx_PeriphCLKConfig+0x532>
    switch (pPeriphClkInit->Lpuart1ClockSelection)
 8003fd4:	f8d4 308c 	ldr.w	r3, [r4, #140]	@ 0x8c
 8003fd8:	f1b3 7f00 	cmp.w	r3, #33554432	@ 0x2000000
 8003fdc:	d056      	beq.n	800408c <HAL_RCCEx_PeriphCLKConfig+0x5b4>
 8003fde:	d849      	bhi.n	8004074 <HAL_RCCEx_PeriphCLKConfig+0x59c>
 8003fe0:	b13b      	cbz	r3, 8003ff2 <HAL_RCCEx_PeriphCLKConfig+0x51a>
 8003fe2:	f1b3 7f80 	cmp.w	r3, #16777216	@ 0x1000000
 8003fe6:	d142      	bne.n	800406e <HAL_RCCEx_PeriphCLKConfig+0x596>
        ret = RCCEx_PLL2_Config(&(pPeriphClkInit->PLL2));
 8003fe8:	f104 0008 	add.w	r0, r4, #8
 8003fec:	f7ff fc98 	bl	8003920 <RCCEx_PLL2_Config>
 8003ff0:	4605      	mov	r5, r0
    if (ret == HAL_OK)
 8003ff2:	2d00      	cmp	r5, #0
 8003ff4:	d150      	bne.n	8004098 <HAL_RCCEx_PeriphCLKConfig+0x5c0>
      __HAL_RCC_LPUART1_CONFIG(pPeriphClkInit->Lpuart1ClockSelection);
 8003ff6:	4a54      	ldr	r2, [pc, #336]	@ (8004148 <HAL_RCCEx_PeriphCLKConfig+0x670>)
 8003ff8:	f8d2 30e0 	ldr.w	r3, [r2, #224]	@ 0xe0
 8003ffc:	f023 63e0 	bic.w	r3, r3, #117440512	@ 0x7000000
 8004000:	f8d4 108c 	ldr.w	r1, [r4, #140]	@ 0x8c
 8004004:	430b      	orrs	r3, r1
 8004006:	f8c2 30e0 	str.w	r3, [r2, #224]	@ 0xe0
  if (((pPeriphClkInit->PeriphClockSelection) & RCC_PERIPHCLK_I2C1) == RCC_PERIPHCLK_I2C1)
 800400a:	6823      	ldr	r3, [r4, #0]
 800400c:	f413 5f00 	tst.w	r3, #8192	@ 0x2000
 8004010:	d05a      	beq.n	80040c8 <HAL_RCCEx_PeriphCLKConfig+0x5f0>
    switch (pPeriphClkInit->I2c1ClockSelection)
 8004012:	f8d4 3090 	ldr.w	r3, [r4, #144]	@ 0x90
 8004016:	f5b3 3f80 	cmp.w	r3, #65536	@ 0x10000
 800401a:	d043      	beq.n	80040a4 <HAL_RCCEx_PeriphCLKConfig+0x5cc>
 800401c:	d93e      	bls.n	800409c <HAL_RCCEx_PeriphCLKConfig+0x5c4>
 800401e:	f5b3 3f00 	cmp.w	r3, #131072	@ 0x20000
 8004022:	d044      	beq.n	80040ae <HAL_RCCEx_PeriphCLKConfig+0x5d6>
 8004024:	f5b3 3f40 	cmp.w	r3, #196608	@ 0x30000
 8004028:	d041      	beq.n	80040ae <HAL_RCCEx_PeriphCLKConfig+0x5d6>
 800402a:	2601      	movs	r6, #1
 800402c:	4635      	mov	r5, r6
 800402e:	e04b      	b.n	80040c8 <HAL_RCCEx_PeriphCLKConfig+0x5f0>
        ret = RCCEx_PLL3_Config(&(pPeriphClkInit->PLL3));
 8004030:	f104 0030 	add.w	r0, r4, #48	@ 0x30
 8004034:	f7ff fce2 	bl	80039fc <RCCEx_PLL3_Config>
 8004038:	4605      	mov	r5, r0
        break;
 800403a:	e79e      	b.n	8003f7a <HAL_RCCEx_PeriphCLKConfig+0x4a2>
    switch (pPeriphClkInit->Usart11ClockSelection)
 800403c:	2601      	movs	r6, #1
 800403e:	4635      	mov	r5, r6
 8004040:	e7a7      	b.n	8003f92 <HAL_RCCEx_PeriphCLKConfig+0x4ba>
      status = ret;
 8004042:	462e      	mov	r6, r5
 8004044:	e7a5      	b.n	8003f92 <HAL_RCCEx_PeriphCLKConfig+0x4ba>
    switch (pPeriphClkInit->Uart12ClockSelection)
 8004046:	2601      	movs	r6, #1
 8004048:	4635      	mov	r5, r6
 800404a:	e7bf      	b.n	8003fcc <HAL_RCCEx_PeriphCLKConfig+0x4f4>
 800404c:	2b40      	cmp	r3, #64	@ 0x40
 800404e:	d0b1      	beq.n	8003fb4 <HAL_RCCEx_PeriphCLKConfig+0x4dc>
 8004050:	2b50      	cmp	r3, #80	@ 0x50
 8004052:	d0af      	beq.n	8003fb4 <HAL_RCCEx_PeriphCLKConfig+0x4dc>
 8004054:	2b30      	cmp	r3, #48	@ 0x30
 8004056:	d0ad      	beq.n	8003fb4 <HAL_RCCEx_PeriphCLKConfig+0x4dc>
 8004058:	2601      	movs	r6, #1
 800405a:	4635      	mov	r5, r6
 800405c:	e7b6      	b.n	8003fcc <HAL_RCCEx_PeriphCLKConfig+0x4f4>
        ret = RCCEx_PLL3_Config(&(pPeriphClkInit->PLL3));
 800405e:	f104 0030 	add.w	r0, r4, #48	@ 0x30
 8004062:	f7ff fccb 	bl	80039fc <RCCEx_PLL3_Config>
 8004066:	4605      	mov	r5, r0
        break;
 8004068:	e7a4      	b.n	8003fb4 <HAL_RCCEx_PeriphCLKConfig+0x4dc>
      status = ret;
 800406a:	462e      	mov	r6, r5
 800406c:	e7ae      	b.n	8003fcc <HAL_RCCEx_PeriphCLKConfig+0x4f4>
    switch (pPeriphClkInit->Lpuart1ClockSelection)
 800406e:	2601      	movs	r6, #1
 8004070:	4635      	mov	r5, r6
 8004072:	e7ca      	b.n	800400a <HAL_RCCEx_PeriphCLKConfig+0x532>
 8004074:	f1b3 6f80 	cmp.w	r3, #67108864	@ 0x4000000
 8004078:	d0bb      	beq.n	8003ff2 <HAL_RCCEx_PeriphCLKConfig+0x51a>
 800407a:	f1b3 6fa0 	cmp.w	r3, #83886080	@ 0x5000000
 800407e:	d0b8      	beq.n	8003ff2 <HAL_RCCEx_PeriphCLKConfig+0x51a>
 8004080:	f1b3 7f40 	cmp.w	r3, #50331648	@ 0x3000000
 8004084:	d0b5      	beq.n	8003ff2 <HAL_RCCEx_PeriphCLKConfig+0x51a>
 8004086:	2601      	movs	r6, #1
 8004088:	4635      	mov	r5, r6
 800408a:	e7be      	b.n	800400a <HAL_RCCEx_PeriphCLKConfig+0x532>
        ret = RCCEx_PLL3_Config(&(pPeriphClkInit->PLL3));
 800408c:	f104 0030 	add.w	r0, r4, #48	@ 0x30
 8004090:	f7ff fcb4 	bl	80039fc <RCCEx_PLL3_Config>
 8004094:	4605      	mov	r5, r0
        break;
 8004096:	e7ac      	b.n	8003ff2 <HAL_RCCEx_PeriphCLKConfig+0x51a>
      status = ret;
 8004098:	462e      	mov	r6, r5
 800409a:	e7b6      	b.n	800400a <HAL_RCCEx_PeriphCLKConfig+0x532>
    switch (pPeriphClkInit->I2c1ClockSelection)
 800409c:	b13b      	cbz	r3, 80040ae <HAL_RCCEx_PeriphCLKConfig+0x5d6>
 800409e:	2601      	movs	r6, #1
 80040a0:	4635      	mov	r5, r6
 80040a2:	e011      	b.n	80040c8 <HAL_RCCEx_PeriphCLKConfig+0x5f0>
        ret = RCCEx_PLL3_Config(&(pPeriphClkInit->PLL3));
 80040a4:	f104 0030 	add.w	r0, r4, #48	@ 0x30
 80040a8:	f7ff fca8 	bl	80039fc <RCCEx_PLL3_Config>
 80040ac:	4605      	mov	r5, r0
    if (ret == HAL_OK)
 80040ae:	b955      	cbnz	r5, 80040c6 <HAL_RCCEx_PeriphCLKConfig+0x5ee>
      __HAL_RCC_I2C1_CONFIG(pPeriphClkInit->I2c1ClockSelection);
 80040b0:	4a25      	ldr	r2, [pc, #148]	@ (8004148 <HAL_RCCEx_PeriphCLKConfig+0x670>)
 80040b2:	f8d2 30e4 	ldr.w	r3, [r2, #228]	@ 0xe4
 80040b6:	f423 3340 	bic.w	r3, r3, #196608	@ 0x30000
 80040ba:	f8d4 1090 	ldr.w	r1, [r4, #144]	@ 0x90
 80040be:	430b      	orrs	r3, r1
 80040c0:	f8c2 30e4 	str.w	r3, [r2, #228]	@ 0xe4
 80040c4:	e000      	b.n	80040c8 <HAL_RCCEx_PeriphCLKConfig+0x5f0>
      status = ret;
 80040c6:	462e      	mov	r6, r5
  if (((pPeriphClkInit->PeriphClockSelection) & RCC_PERIPHCLK_I2C2) == RCC_PERIPHCLK_I2C2)
 80040c8:	6823      	ldr	r3, [r4, #0]
 80040ca:	f413 4f80 	tst.w	r3, #16384	@ 0x4000
 80040ce:	d022      	beq.n	8004116 <HAL_RCCEx_PeriphCLKConfig+0x63e>
    switch (pPeriphClkInit->I2c2ClockSelection)
 80040d0:	f8d4 3094 	ldr.w	r3, [r4, #148]	@ 0x94
 80040d4:	f5b3 2f80 	cmp.w	r3, #262144	@ 0x40000
 80040d8:	d00d      	beq.n	80040f6 <HAL_RCCEx_PeriphCLKConfig+0x61e>
 80040da:	d908      	bls.n	80040ee <HAL_RCCEx_PeriphCLKConfig+0x616>
 80040dc:	f5b3 2f00 	cmp.w	r3, #524288	@ 0x80000
 80040e0:	d00e      	beq.n	8004100 <HAL_RCCEx_PeriphCLKConfig+0x628>
 80040e2:	f5b3 2f40 	cmp.w	r3, #786432	@ 0xc0000
 80040e6:	d00b      	beq.n	8004100 <HAL_RCCEx_PeriphCLKConfig+0x628>
 80040e8:	2601      	movs	r6, #1
 80040ea:	4635      	mov	r5, r6
 80040ec:	e013      	b.n	8004116 <HAL_RCCEx_PeriphCLKConfig+0x63e>
 80040ee:	b13b      	cbz	r3, 8004100 <HAL_RCCEx_PeriphCLKConfig+0x628>
 80040f0:	2601      	movs	r6, #1
 80040f2:	4635      	mov	r5, r6
 80040f4:	e00f      	b.n	8004116 <HAL_RCCEx_PeriphCLKConfig+0x63e>
        ret = RCCEx_PLL3_Config(&(pPeriphClkInit->PLL3));
 80040f6:	f104 0030 	add.w	r0, r4, #48	@ 0x30
 80040fa:	f7ff fc7f 	bl	80039fc <RCCEx_PLL3_Config>
 80040fe:	4605      	mov	r5, r0
    if (ret == HAL_OK)
 8004100:	b9e5      	cbnz	r5, 800413c <HAL_RCCEx_PeriphCLKConfig+0x664>
      __HAL_RCC_I2C2_CONFIG(pPeriphClkInit->I2c2ClockSelection);
 8004102:	4a11      	ldr	r2, [pc, #68]	@ (8004148 <HAL_RCCEx_PeriphCLKConfig+0x670>)
 8004104:	f8d2 30e4 	ldr.w	r3, [r2, #228]	@ 0xe4
 8004108:	f423 2340 	bic.w	r3, r3, #786432	@ 0xc0000
 800410c:	f8d4 1094 	ldr.w	r1, [r4, #148]	@ 0x94
 8004110:	430b      	orrs	r3, r1
 8004112:	f8c2 30e4 	str.w	r3, [r2, #228]	@ 0xe4
  if (((pPeriphClkInit->PeriphClockSelection) & RCC_PERIPHCLK_I2C3) == RCC_PERIPHCLK_I2C3)
 8004116:	6823      	ldr	r3, [r4, #0]
 8004118:	f413 4f00 	tst.w	r3, #32768	@ 0x8000
 800411c:	d026      	beq.n	800416c <HAL_RCCEx_PeriphCLKConfig+0x694>
    switch (pPeriphClkInit->I2c3ClockSelection)
 800411e:	f8d4 3098 	ldr.w	r3, [r4, #152]	@ 0x98
 8004122:	f5b3 1f80 	cmp.w	r3, #1048576	@ 0x100000
 8004126:	d011      	beq.n	800414c <HAL_RCCEx_PeriphCLKConfig+0x674>
 8004128:	d90a      	bls.n	8004140 <HAL_RCCEx_PeriphCLKConfig+0x668>
 800412a:	f5b3 1f00 	cmp.w	r3, #2097152	@ 0x200000
 800412e:	d012      	beq.n	8004156 <HAL_RCCEx_PeriphCLKConfig+0x67e>
 8004130:	f5b3 1f40 	cmp.w	r3, #3145728	@ 0x300000
 8004134:	d00f      	beq.n	8004156 <HAL_RCCEx_PeriphCLKConfig+0x67e>
 8004136:	2601      	movs	r6, #1
 8004138:	4635      	mov	r5, r6
 800413a:	e017      	b.n	800416c <HAL_RCCEx_PeriphCLKConfig+0x694>
      status = ret;
 800413c:	462e      	mov	r6, r5
 800413e:	e7ea      	b.n	8004116 <HAL_RCCEx_PeriphCLKConfig+0x63e>
    switch (pPeriphClkInit->I2c3ClockSelection)
 8004140:	b14b      	cbz	r3, 8004156 <HAL_RCCEx_PeriphCLKConfig+0x67e>
 8004142:	2601      	movs	r6, #1
 8004144:	4635      	mov	r5, r6
 8004146:	e011      	b.n	800416c <HAL_RCCEx_PeriphCLKConfig+0x694>
 8004148:	44020c00 	.word	0x44020c00
        ret = RCCEx_PLL3_Config(&(pPeriphClkInit->PLL3));
 800414c:	f104 0030 	add.w	r0, r4, #48	@ 0x30
 8004150:	f7ff fc54 	bl	80039fc <RCCEx_PLL3_Config>
 8004154:	4605      	mov	r5, r0
    if (ret == HAL_OK)
 8004156:	b9e5      	cbnz	r5, 8004192 <HAL_RCCEx_PeriphCLKConfig+0x6ba>
      __HAL_RCC_I2C3_CONFIG(pPeriphClkInit->I2c3ClockSelection);
 8004158:	4ab6      	ldr	r2, [pc, #728]	@ (8004434 <HAL_RCCEx_PeriphCLKConfig+0x95c>)
 800415a:	f8d2 30e4 	ldr.w	r3, [r2, #228]	@ 0xe4
 800415e:	f423 1340 	bic.w	r3, r3, #3145728	@ 0x300000
 8004162:	f8d4 1098 	ldr.w	r1, [r4, #152]	@ 0x98
 8004166:	430b      	orrs	r3, r1
 8004168:	f8c2 30e4 	str.w	r3, [r2, #228]	@ 0xe4
  if (((pPeriphClkInit->PeriphClockSelection) & RCC_PERIPHCLK_I2C4) == RCC_PERIPHCLK_I2C4)
 800416c:	6863      	ldr	r3, [r4, #4]
 800416e:	f413 6f80 	tst.w	r3, #1024	@ 0x400
 8004172:	d024      	beq.n	80041be <HAL_RCCEx_PeriphCLKConfig+0x6e6>
    switch (pPeriphClkInit->I2c4ClockSelection)
 8004174:	f8d4 309c 	ldr.w	r3, [r4, #156]	@ 0x9c
 8004178:	f5b3 0f80 	cmp.w	r3, #4194304	@ 0x400000
 800417c:	d00f      	beq.n	800419e <HAL_RCCEx_PeriphCLKConfig+0x6c6>
 800417e:	d90a      	bls.n	8004196 <HAL_RCCEx_PeriphCLKConfig+0x6be>
 8004180:	f5b3 0f00 	cmp.w	r3, #8388608	@ 0x800000
 8004184:	d010      	beq.n	80041a8 <HAL_RCCEx_PeriphCLKConfig+0x6d0>
 8004186:	f5b3 0f40 	cmp.w	r3, #12582912	@ 0xc00000
 800418a:	d00d      	beq.n	80041a8 <HAL_RCCEx_PeriphCLKConfig+0x6d0>
 800418c:	2601      	movs	r6, #1
 800418e:	4635      	mov	r5, r6
 8004190:	e015      	b.n	80041be <HAL_RCCEx_PeriphCLKConfig+0x6e6>
      status = ret;
 8004192:	462e      	mov	r6, r5
 8004194:	e7ea      	b.n	800416c <HAL_RCCEx_PeriphCLKConfig+0x694>
    switch (pPeriphClkInit->I2c4ClockSelection)
 8004196:	b13b      	cbz	r3, 80041a8 <HAL_RCCEx_PeriphCLKConfig+0x6d0>
 8004198:	2601      	movs	r6, #1
 800419a:	4635      	mov	r5, r6
 800419c:	e00f      	b.n	80041be <HAL_RCCEx_PeriphCLKConfig+0x6e6>
        ret = RCCEx_PLL3_Config(&(pPeriphClkInit->PLL3));
 800419e:	f104 0030 	add.w	r0, r4, #48	@ 0x30
 80041a2:	f7ff fc2b 	bl	80039fc <RCCEx_PLL3_Config>
 80041a6:	4605      	mov	r5, r0
    if (ret == HAL_OK)
 80041a8:	b9cd      	cbnz	r5, 80041de <HAL_RCCEx_PeriphCLKConfig+0x706>
      __HAL_RCC_I2C4_CONFIG(pPeriphClkInit->I2c4ClockSelection);
 80041aa:	4aa2      	ldr	r2, [pc, #648]	@ (8004434 <HAL_RCCEx_PeriphCLKConfig+0x95c>)
 80041ac:	f8d2 30e4 	ldr.w	r3, [r2, #228]	@ 0xe4
 80041b0:	f423 0340 	bic.w	r3, r3, #12582912	@ 0xc00000
 80041b4:	f8d4 109c 	ldr.w	r1, [r4, #156]	@ 0x9c
 80041b8:	430b      	orrs	r3, r1
 80041ba:	f8c2 30e4 	str.w	r3, [r2, #228]	@ 0xe4
  if (((pPeriphClkInit->PeriphClockSelection) & RCC_PERIPHCLK_I3C1) == RCC_PERIPHCLK_I3C1)
 80041be:	6823      	ldr	r3, [r4, #0]
 80041c0:	f413 3f80 	tst.w	r3, #65536	@ 0x10000
 80041c4:	d01f      	beq.n	8004206 <HAL_RCCEx_PeriphCLKConfig+0x72e>
    switch (pPeriphClkInit->I3c1ClockSelection)
 80041c6:	f8d4 30a0 	ldr.w	r3, [r4, #160]	@ 0xa0
 80041ca:	f1b3 7f80 	cmp.w	r3, #16777216	@ 0x1000000
 80041ce:	d008      	beq.n	80041e2 <HAL_RCCEx_PeriphCLKConfig+0x70a>
 80041d0:	f1b3 7f00 	cmp.w	r3, #33554432	@ 0x2000000
 80041d4:	d00a      	beq.n	80041ec <HAL_RCCEx_PeriphCLKConfig+0x714>
 80041d6:	b14b      	cbz	r3, 80041ec <HAL_RCCEx_PeriphCLKConfig+0x714>
 80041d8:	2601      	movs	r6, #1
 80041da:	4635      	mov	r5, r6
 80041dc:	e013      	b.n	8004206 <HAL_RCCEx_PeriphCLKConfig+0x72e>
      status = ret;
 80041de:	462e      	mov	r6, r5
 80041e0:	e7ed      	b.n	80041be <HAL_RCCEx_PeriphCLKConfig+0x6e6>
        ret = RCCEx_PLL3_Config(&(pPeriphClkInit->PLL3));
 80041e2:	f104 0030 	add.w	r0, r4, #48	@ 0x30
 80041e6:	f7ff fc09 	bl	80039fc <RCCEx_PLL3_Config>
 80041ea:	4605      	mov	r5, r0
    if (ret == HAL_OK)
 80041ec:	b955      	cbnz	r5, 8004204 <HAL_RCCEx_PeriphCLKConfig+0x72c>
      __HAL_RCC_I3C1_CONFIG(pPeriphClkInit->I3c1ClockSelection);
 80041ee:	4a91      	ldr	r2, [pc, #580]	@ (8004434 <HAL_RCCEx_PeriphCLKConfig+0x95c>)
 80041f0:	f8d2 30e4 	ldr.w	r3, [r2, #228]	@ 0xe4
 80041f4:	f023 7340 	bic.w	r3, r3, #50331648	@ 0x3000000
 80041f8:	f8d4 10a0 	ldr.w	r1, [r4, #160]	@ 0xa0
 80041fc:	430b      	orrs	r3, r1
 80041fe:	f8c2 30e4 	str.w	r3, [r2, #228]	@ 0xe4
 8004202:	e000      	b.n	8004206 <HAL_RCCEx_PeriphCLKConfig+0x72e>
      status = ret;
 8004204:	462e      	mov	r6, r5
  if (((pPeriphClkInit->PeriphClockSelection) & RCC_PERIPHCLK_TIM) == RCC_PERIPHCLK_TIM)
 8004206:	6863      	ldr	r3, [r4, #4]
 8004208:	f413 6f00 	tst.w	r3, #2048	@ 0x800
 800420c:	d009      	beq.n	8004222 <HAL_RCCEx_PeriphCLKConfig+0x74a>
    __HAL_RCC_TIMCLKPRESCALER(pPeriphClkInit->TimPresSelection);
 800420e:	4b89      	ldr	r3, [pc, #548]	@ (8004434 <HAL_RCCEx_PeriphCLKConfig+0x95c>)
 8004210:	69da      	ldr	r2, [r3, #28]
 8004212:	f422 4200 	bic.w	r2, r2, #32768	@ 0x8000
 8004216:	61da      	str	r2, [r3, #28]
 8004218:	69da      	ldr	r2, [r3, #28]
 800421a:	f8d4 1104 	ldr.w	r1, [r4, #260]	@ 0x104
 800421e:	430a      	orrs	r2, r1
 8004220:	61da      	str	r2, [r3, #28]
  if (((pPeriphClkInit->PeriphClockSelection) & RCC_PERIPHCLK_LPTIM1) == RCC_PERIPHCLK_LPTIM1)
 8004222:	6823      	ldr	r3, [r4, #0]
 8004224:	f413 3f00 	tst.w	r3, #131072	@ 0x20000
 8004228:	d01e      	beq.n	8004268 <HAL_RCCEx_PeriphCLKConfig+0x790>
    switch (pPeriphClkInit->Lptim1ClockSelection)
 800422a:	f8d4 30a4 	ldr.w	r3, [r4, #164]	@ 0xa4
 800422e:	f5b3 7f00 	cmp.w	r3, #512	@ 0x200
 8004232:	f000 80f4 	beq.w	800441e <HAL_RCCEx_PeriphCLKConfig+0x946>
 8004236:	f200 80e3 	bhi.w	8004400 <HAL_RCCEx_PeriphCLKConfig+0x928>
 800423a:	b143      	cbz	r3, 800424e <HAL_RCCEx_PeriphCLKConfig+0x776>
 800423c:	f5b3 7f80 	cmp.w	r3, #256	@ 0x100
 8004240:	f040 80db 	bne.w	80043fa <HAL_RCCEx_PeriphCLKConfig+0x922>
        ret = RCCEx_PLL2_Config(&(pPeriphClkInit->PLL2));
 8004244:	f104 0008 	add.w	r0, r4, #8
 8004248:	f7ff fb6a 	bl	8003920 <RCCEx_PLL2_Config>
 800424c:	4605      	mov	r5, r0
    if (ret == HAL_OK)
 800424e:	2d00      	cmp	r5, #0
 8004250:	f040 80eb 	bne.w	800442a <HAL_RCCEx_PeriphCLKConfig+0x952>
      __HAL_RCC_LPTIM1_CONFIG(pPeriphClkInit->Lptim1ClockSelection);
 8004254:	4a77      	ldr	r2, [pc, #476]	@ (8004434 <HAL_RCCEx_PeriphCLKConfig+0x95c>)
 8004256:	f8d2 30dc 	ldr.w	r3, [r2, #220]	@ 0xdc
 800425a:	f423 63e0 	bic.w	r3, r3, #1792	@ 0x700
 800425e:	f8d4 10a4 	ldr.w	r1, [r4, #164]	@ 0xa4
 8004262:	430b      	orrs	r3, r1
 8004264:	f8c2 30dc 	str.w	r3, [r2, #220]	@ 0xdc
  if (((pPeriphClkInit->PeriphClockSelection) & RCC_PERIPHCLK_LPTIM2) == RCC_PERIPHCLK_LPTIM2)
 8004268:	6823      	ldr	r3, [r4, #0]
 800426a:	f413 2f80 	tst.w	r3, #262144	@ 0x40000
 800426e:	d01e      	beq.n	80042ae <HAL_RCCEx_PeriphCLKConfig+0x7d6>
    switch (pPeriphClkInit->Lptim2ClockSelection)
 8004270:	f8d4 30a8 	ldr.w	r3, [r4, #168]	@ 0xa8
 8004274:	f5b3 5f00 	cmp.w	r3, #8192	@ 0x2000
 8004278:	f000 80ed 	beq.w	8004456 <HAL_RCCEx_PeriphCLKConfig+0x97e>
 800427c:	f200 80dc 	bhi.w	8004438 <HAL_RCCEx_PeriphCLKConfig+0x960>
 8004280:	b143      	cbz	r3, 8004294 <HAL_RCCEx_PeriphCLKConfig+0x7bc>
 8004282:	f5b3 5f80 	cmp.w	r3, #4096	@ 0x1000
 8004286:	f040 80d2 	bne.w	800442e <HAL_RCCEx_PeriphCLKConfig+0x956>
        ret = RCCEx_PLL2_Config(&(pPeriphClkInit->PLL2));
 800428a:	f104 0008 	add.w	r0, r4, #8
 800428e:	f7ff fb47 	bl	8003920 <RCCEx_PLL2_Config>
 8004292:	4605      	mov	r5, r0
    if (ret == HAL_OK)
 8004294:	2d00      	cmp	r5, #0
 8004296:	f040 80e4 	bne.w	8004462 <HAL_RCCEx_PeriphCLKConfig+0x98a>
      __HAL_RCC_LPTIM2_CONFIG(pPeriphClkInit->Lptim2ClockSelection);
 800429a:	4a66      	ldr	r2, [pc, #408]	@ (8004434 <HAL_RCCEx_PeriphCLKConfig+0x95c>)
 800429c:	f8d2 30dc 	ldr.w	r3, [r2, #220]	@ 0xdc
 80042a0:	f423 43e0 	bic.w	r3, r3, #28672	@ 0x7000
 80042a4:	f8d4 10a8 	ldr.w	r1, [r4, #168]	@ 0xa8
 80042a8:	430b      	orrs	r3, r1
 80042aa:	f8c2 30dc 	str.w	r3, [r2, #220]	@ 0xdc
  if (((pPeriphClkInit->PeriphClockSelection) & RCC_PERIPHCLK_LPTIM3) == RCC_PERIPHCLK_LPTIM3)
 80042ae:	6863      	ldr	r3, [r4, #4]
 80042b0:	f013 0f20 	tst.w	r3, #32
 80042b4:	d01e      	beq.n	80042f4 <HAL_RCCEx_PeriphCLKConfig+0x81c>
    switch (pPeriphClkInit->Lptim3ClockSelection)
 80042b6:	f8d4 30ac 	ldr.w	r3, [r4, #172]	@ 0xac
 80042ba:	f5b3 3f00 	cmp.w	r3, #131072	@ 0x20000
 80042be:	f000 80e4 	beq.w	800448a <HAL_RCCEx_PeriphCLKConfig+0x9b2>
 80042c2:	f200 80d3 	bhi.w	800446c <HAL_RCCEx_PeriphCLKConfig+0x994>
 80042c6:	b143      	cbz	r3, 80042da <HAL_RCCEx_PeriphCLKConfig+0x802>
 80042c8:	f5b3 3f80 	cmp.w	r3, #65536	@ 0x10000
 80042cc:	f040 80cb 	bne.w	8004466 <HAL_RCCEx_PeriphCLKConfig+0x98e>
        ret = RCCEx_PLL2_Config(&(pPeriphClkInit->PLL2));
 80042d0:	f104 0008 	add.w	r0, r4, #8
 80042d4:	f7ff fb24 	bl	8003920 <RCCEx_PLL2_Config>
 80042d8:	4605      	mov	r5, r0
    if (ret == HAL_OK)
 80042da:	2d00      	cmp	r5, #0
 80042dc:	f040 80db 	bne.w	8004496 <HAL_RCCEx_PeriphCLKConfig+0x9be>
      __HAL_RCC_LPTIM3_CONFIG(pPeriphClkInit->Lptim3ClockSelection);
 80042e0:	4a54      	ldr	r2, [pc, #336]	@ (8004434 <HAL_RCCEx_PeriphCLKConfig+0x95c>)
 80042e2:	f8d2 30dc 	ldr.w	r3, [r2, #220]	@ 0xdc
 80042e6:	f423 23e0 	bic.w	r3, r3, #458752	@ 0x70000
 80042ea:	f8d4 10ac 	ldr.w	r1, [r4, #172]	@ 0xac
 80042ee:	430b      	orrs	r3, r1
 80042f0:	f8c2 30dc 	str.w	r3, [r2, #220]	@ 0xdc
  if (((pPeriphClkInit->PeriphClockSelection) & RCC_PERIPHCLK_LPTIM4) == RCC_PERIPHCLK_LPTIM4)
 80042f4:	6863      	ldr	r3, [r4, #4]
 80042f6:	f013 0f40 	tst.w	r3, #64	@ 0x40
 80042fa:	d01e      	beq.n	800433a <HAL_RCCEx_PeriphCLKConfig+0x862>
    switch (pPeriphClkInit->Lptim4ClockSelection)
 80042fc:	f8d4 30b0 	ldr.w	r3, [r4, #176]	@ 0xb0
 8004300:	f5b3 1f00 	cmp.w	r3, #2097152	@ 0x200000
 8004304:	f000 80db 	beq.w	80044be <HAL_RCCEx_PeriphCLKConfig+0x9e6>
 8004308:	f200 80ca 	bhi.w	80044a0 <HAL_RCCEx_PeriphCLKConfig+0x9c8>
 800430c:	b143      	cbz	r3, 8004320 <HAL_RCCEx_PeriphCLKConfig+0x848>
 800430e:	f5b3 1f80 	cmp.w	r3, #1048576	@ 0x100000
 8004312:	f040 80c2 	bne.w	800449a <HAL_RCCEx_PeriphCLKConfig+0x9c2>
        ret = RCCEx_PLL2_Config(&(pPeriphClkInit->PLL2));
 8004316:	f104 0008 	add.w	r0, r4, #8
 800431a:	f7ff fb01 	bl	8003920 <RCCEx_PLL2_Config>
 800431e:	4605      	mov	r5, r0
    if (ret == HAL_OK)
 8004320:	2d00      	cmp	r5, #0
 8004322:	f040 80d2 	bne.w	80044ca <HAL_RCCEx_PeriphCLKConfig+0x9f2>
      __HAL_RCC_LPTIM4_CONFIG(pPeriphClkInit->Lptim4ClockSelection);
 8004326:	4a43      	ldr	r2, [pc, #268]	@ (8004434 <HAL_RCCEx_PeriphCLKConfig+0x95c>)
 8004328:	f8d2 30dc 	ldr.w	r3, [r2, #220]	@ 0xdc
 800432c:	f423 03e0 	bic.w	r3, r3, #7340032	@ 0x700000
 8004330:	f8d4 10b0 	ldr.w	r1, [r4, #176]	@ 0xb0
 8004334:	430b      	orrs	r3, r1
 8004336:	f8c2 30dc 	str.w	r3, [r2, #220]	@ 0xdc
  if (((pPeriphClkInit->PeriphClockSelection) & RCC_PERIPHCLK_LPTIM5) == RCC_PERIPHCLK_LPTIM5)
 800433a:	6863      	ldr	r3, [r4, #4]
 800433c:	f013 0f80 	tst.w	r3, #128	@ 0x80
 8004340:	d01e      	beq.n	8004380 <HAL_RCCEx_PeriphCLKConfig+0x8a8>
    switch (pPeriphClkInit->Lptim5ClockSelection)
 8004342:	f8d4 30b4 	ldr.w	r3, [r4, #180]	@ 0xb4
 8004346:	f1b3 7f00 	cmp.w	r3, #33554432	@ 0x2000000
 800434a:	f000 80d2 	beq.w	80044f2 <HAL_RCCEx_PeriphCLKConfig+0xa1a>
 800434e:	f200 80c1 	bhi.w	80044d4 <HAL_RCCEx_PeriphCLKConfig+0x9fc>
 8004352:	b143      	cbz	r3, 8004366 <HAL_RCCEx_PeriphCLKConfig+0x88e>
 8004354:	f1b3 7f80 	cmp.w	r3, #16777216	@ 0x1000000
 8004358:	f040 80b9 	bne.w	80044ce <HAL_RCCEx_PeriphCLKConfig+0x9f6>
        ret = RCCEx_PLL2_Config(&(pPeriphClkInit->PLL2));
 800435c:	f104 0008 	add.w	r0, r4, #8
 8004360:	f7ff fade 	bl	8003920 <RCCEx_PLL2_Config>
 8004364:	4605      	mov	r5, r0
    if (ret == HAL_OK)
 8004366:	2d00      	cmp	r5, #0
 8004368:	f040 80c9 	bne.w	80044fe <HAL_RCCEx_PeriphCLKConfig+0xa26>
      __HAL_RCC_LPTIM5_CONFIG(pPeriphClkInit->Lptim5ClockSelection);
 800436c:	4a31      	ldr	r2, [pc, #196]	@ (8004434 <HAL_RCCEx_PeriphCLKConfig+0x95c>)
 800436e:	f8d2 30dc 	ldr.w	r3, [r2, #220]	@ 0xdc
 8004372:	f023 63e0 	bic.w	r3, r3, #117440512	@ 0x7000000
 8004376:	f8d4 10b4 	ldr.w	r1, [r4, #180]	@ 0xb4
 800437a:	430b      	orrs	r3, r1
 800437c:	f8c2 30dc 	str.w	r3, [r2, #220]	@ 0xdc
  if (((pPeriphClkInit->PeriphClockSelection) & RCC_PERIPHCLK_LPTIM6) == RCC_PERIPHCLK_LPTIM6)
 8004380:	6863      	ldr	r3, [r4, #4]
 8004382:	f413 7f80 	tst.w	r3, #256	@ 0x100
 8004386:	d01e      	beq.n	80043c6 <HAL_RCCEx_PeriphCLKConfig+0x8ee>
    switch (pPeriphClkInit->Lptim6ClockSelection)
 8004388:	f8d4 30b8 	ldr.w	r3, [r4, #184]	@ 0xb8
 800438c:	f1b3 5f00 	cmp.w	r3, #536870912	@ 0x20000000
 8004390:	f000 80c9 	beq.w	8004526 <HAL_RCCEx_PeriphCLKConfig+0xa4e>
 8004394:	f200 80b8 	bhi.w	8004508 <HAL_RCCEx_PeriphCLKConfig+0xa30>
 8004398:	b143      	cbz	r3, 80043ac <HAL_RCCEx_PeriphCLKConfig+0x8d4>
 800439a:	f1b3 5f80 	cmp.w	r3, #268435456	@ 0x10000000
 800439e:	f040 80b0 	bne.w	8004502 <HAL_RCCEx_PeriphCLKConfig+0xa2a>
        ret = RCCEx_PLL2_Config(&(pPeriphClkInit->PLL2));
 80043a2:	f104 0008 	add.w	r0, r4, #8
 80043a6:	f7ff fabb 	bl	8003920 <RCCEx_PLL2_Config>
 80043aa:	4605      	mov	r5, r0
    if (ret == HAL_OK)
 80043ac:	2d00      	cmp	r5, #0
 80043ae:	f040 80c0 	bne.w	8004532 <HAL_RCCEx_PeriphCLKConfig+0xa5a>
      __HAL_RCC_LPTIM6_CONFIG(pPeriphClkInit->Lptim6ClockSelection);
 80043b2:	4a20      	ldr	r2, [pc, #128]	@ (8004434 <HAL_RCCEx_PeriphCLKConfig+0x95c>)
 80043b4:	f8d2 30dc 	ldr.w	r3, [r2, #220]	@ 0xdc
 80043b8:	f023 43e0 	bic.w	r3, r3, #1879048192	@ 0x70000000
 80043bc:	f8d4 10b8 	ldr.w	r1, [r4, #184]	@ 0xb8
 80043c0:	430b      	orrs	r3, r1
 80043c2:	f8c2 30dc 	str.w	r3, [r2, #220]	@ 0xdc
  if (((pPeriphClkInit->PeriphClockSelection) & RCC_PERIPHCLK_SAI1) == RCC_PERIPHCLK_SAI1)
 80043c6:	6823      	ldr	r3, [r4, #0]
 80043c8:	f413 2f00 	tst.w	r3, #524288	@ 0x80000
 80043cc:	f000 80d5 	beq.w	800457a <HAL_RCCEx_PeriphCLKConfig+0xaa2>
    switch (pPeriphClkInit->Sai1ClockSelection)
 80043d0:	f8d4 30c0 	ldr.w	r3, [r4, #192]	@ 0xc0
 80043d4:	f5b3 3f00 	cmp.w	r3, #131072	@ 0x20000
 80043d8:	f000 80bf 	beq.w	800455a <HAL_RCCEx_PeriphCLKConfig+0xa82>
 80043dc:	f200 80ae 	bhi.w	800453c <HAL_RCCEx_PeriphCLKConfig+0xa64>
 80043e0:	2b00      	cmp	r3, #0
 80043e2:	f000 80b4 	beq.w	800454e <HAL_RCCEx_PeriphCLKConfig+0xa76>
 80043e6:	f5b3 3f80 	cmp.w	r3, #65536	@ 0x10000
 80043ea:	f040 80a4 	bne.w	8004536 <HAL_RCCEx_PeriphCLKConfig+0xa5e>
        ret = RCCEx_PLL2_Config(&(pPeriphClkInit->PLL2));
 80043ee:	f104 0008 	add.w	r0, r4, #8
 80043f2:	f7ff fa95 	bl	8003920 <RCCEx_PLL2_Config>
 80043f6:	4605      	mov	r5, r0
        break;
 80043f8:	e0b4      	b.n	8004564 <HAL_RCCEx_PeriphCLKConfig+0xa8c>
    switch (pPeriphClkInit->Lptim1ClockSelection)
 80043fa:	2601      	movs	r6, #1
 80043fc:	4635      	mov	r5, r6
 80043fe:	e733      	b.n	8004268 <HAL_RCCEx_PeriphCLKConfig+0x790>
 8004400:	f5b3 6f80 	cmp.w	r3, #1024	@ 0x400
 8004404:	f43f af23 	beq.w	800424e <HAL_RCCEx_PeriphCLKConfig+0x776>
 8004408:	f5b3 6fa0 	cmp.w	r3, #1280	@ 0x500
 800440c:	f43f af1f 	beq.w	800424e <HAL_RCCEx_PeriphCLKConfig+0x776>
 8004410:	f5b3 7f40 	cmp.w	r3, #768	@ 0x300
 8004414:	f43f af1b 	beq.w	800424e <HAL_RCCEx_PeriphCLKConfig+0x776>
 8004418:	2601      	movs	r6, #1
 800441a:	4635      	mov	r5, r6
 800441c:	e724      	b.n	8004268 <HAL_RCCEx_PeriphCLKConfig+0x790>
        ret = RCCEx_PLL3_Config(&(pPeriphClkInit->PLL3));
 800441e:	f104 0030 	add.w	r0, r4, #48	@ 0x30
 8004422:	f7ff faeb 	bl	80039fc <RCCEx_PLL3_Config>
 8004426:	4605      	mov	r5, r0
        break;
 8004428:	e711      	b.n	800424e <HAL_RCCEx_PeriphCLKConfig+0x776>
      status = ret;
 800442a:	462e      	mov	r6, r5
 800442c:	e71c      	b.n	8004268 <HAL_RCCEx_PeriphCLKConfig+0x790>
    switch (pPeriphClkInit->Lptim2ClockSelection)
 800442e:	2601      	movs	r6, #1
 8004430:	4635      	mov	r5, r6
 8004432:	e73c      	b.n	80042ae <HAL_RCCEx_PeriphCLKConfig+0x7d6>
 8004434:	44020c00 	.word	0x44020c00
 8004438:	f5b3 4f80 	cmp.w	r3, #16384	@ 0x4000
 800443c:	f43f af2a 	beq.w	8004294 <HAL_RCCEx_PeriphCLKConfig+0x7bc>
 8004440:	f5b3 4fa0 	cmp.w	r3, #20480	@ 0x5000
 8004444:	f43f af26 	beq.w	8004294 <HAL_RCCEx_PeriphCLKConfig+0x7bc>
 8004448:	f5b3 5f40 	cmp.w	r3, #12288	@ 0x3000
 800444c:	f43f af22 	beq.w	8004294 <HAL_RCCEx_PeriphCLKConfig+0x7bc>
 8004450:	2601      	movs	r6, #1
 8004452:	4635      	mov	r5, r6
 8004454:	e72b      	b.n	80042ae <HAL_RCCEx_PeriphCLKConfig+0x7d6>
        ret = RCCEx_PLL3_Config(&(pPeriphClkInit->PLL3));
 8004456:	f104 0030 	add.w	r0, r4, #48	@ 0x30
 800445a:	f7ff facf 	bl	80039fc <RCCEx_PLL3_Config>
 800445e:	4605      	mov	r5, r0
        break;
 8004460:	e718      	b.n	8004294 <HAL_RCCEx_PeriphCLKConfig+0x7bc>
      status = ret;
 8004462:	462e      	mov	r6, r5
 8004464:	e723      	b.n	80042ae <HAL_RCCEx_PeriphCLKConfig+0x7d6>
    switch (pPeriphClkInit->Lptim3ClockSelection)
 8004466:	2601      	movs	r6, #1
 8004468:	4635      	mov	r5, r6
 800446a:	e743      	b.n	80042f4 <HAL_RCCEx_PeriphCLKConfig+0x81c>
 800446c:	f5b3 2f80 	cmp.w	r3, #262144	@ 0x40000
 8004470:	f43f af33 	beq.w	80042da <HAL_RCCEx_PeriphCLKConfig+0x802>
 8004474:	f5b3 2fa0 	cmp.w	r3, #327680	@ 0x50000
 8004478:	f43f af2f 	beq.w	80042da <HAL_RCCEx_PeriphCLKConfig+0x802>
 800447c:	f5b3 3f40 	cmp.w	r3, #196608	@ 0x30000
 8004480:	f43f af2b 	beq.w	80042da <HAL_RCCEx_PeriphCLKConfig+0x802>
 8004484:	2601      	movs	r6, #1
 8004486:	4635      	mov	r5, r6
 8004488:	e734      	b.n	80042f4 <HAL_RCCEx_PeriphCLKConfig+0x81c>
        ret = RCCEx_PLL3_Config(&(pPeriphClkInit->PLL3));
 800448a:	f104 0030 	add.w	r0, r4, #48	@ 0x30
 800448e:	f7ff fab5 	bl	80039fc <RCCEx_PLL3_Config>
 8004492:	4605      	mov	r5, r0
        break;
 8004494:	e721      	b.n	80042da <HAL_RCCEx_PeriphCLKConfig+0x802>
      status = ret;
 8004496:	462e      	mov	r6, r5
 8004498:	e72c      	b.n	80042f4 <HAL_RCCEx_PeriphCLKConfig+0x81c>
    switch (pPeriphClkInit->Lptim4ClockSelection)
 800449a:	2601      	movs	r6, #1
 800449c:	4635      	mov	r5, r6
 800449e:	e74c      	b.n	800433a <HAL_RCCEx_PeriphCLKConfig+0x862>
 80044a0:	f5b3 0f80 	cmp.w	r3, #4194304	@ 0x400000
 80044a4:	f43f af3c 	beq.w	8004320 <HAL_RCCEx_PeriphCLKConfig+0x848>
 80044a8:	f5b3 0fa0 	cmp.w	r3, #5242880	@ 0x500000
 80044ac:	f43f af38 	beq.w	8004320 <HAL_RCCEx_PeriphCLKConfig+0x848>
 80044b0:	f5b3 1f40 	cmp.w	r3, #3145728	@ 0x300000
 80044b4:	f43f af34 	beq.w	8004320 <HAL_RCCEx_PeriphCLKConfig+0x848>
 80044b8:	2601      	movs	r6, #1
 80044ba:	4635      	mov	r5, r6
 80044bc:	e73d      	b.n	800433a <HAL_RCCEx_PeriphCLKConfig+0x862>
        ret = RCCEx_PLL3_Config(&(pPeriphClkInit->PLL3));
 80044be:	f104 0030 	add.w	r0, r4, #48	@ 0x30
 80044c2:	f7ff fa9b 	bl	80039fc <RCCEx_PLL3_Config>
 80044c6:	4605      	mov	r5, r0
        break;
 80044c8:	e72a      	b.n	8004320 <HAL_RCCEx_PeriphCLKConfig+0x848>
      status = ret;
 80044ca:	462e      	mov	r6, r5
 80044cc:	e735      	b.n	800433a <HAL_RCCEx_PeriphCLKConfig+0x862>
    switch (pPeriphClkInit->Lptim5ClockSelection)
 80044ce:	2601      	movs	r6, #1
 80044d0:	4635      	mov	r5, r6
 80044d2:	e755      	b.n	8004380 <HAL_RCCEx_PeriphCLKConfig+0x8a8>
 80044d4:	f1b3 6f80 	cmp.w	r3, #67108864	@ 0x4000000
 80044d8:	f43f af45 	beq.w	8004366 <HAL_RCCEx_PeriphCLKConfig+0x88e>
 80044dc:	f1b3 6fa0 	cmp.w	r3, #83886080	@ 0x5000000
 80044e0:	f43f af41 	beq.w	8004366 <HAL_RCCEx_PeriphCLKConfig+0x88e>
 80044e4:	f1b3 7f40 	cmp.w	r3, #50331648	@ 0x3000000
 80044e8:	f43f af3d 	beq.w	8004366 <HAL_RCCEx_PeriphCLKConfig+0x88e>
 80044ec:	2601      	movs	r6, #1
 80044ee:	4635      	mov	r5, r6
 80044f0:	e746      	b.n	8004380 <HAL_RCCEx_PeriphCLKConfig+0x8a8>
        ret = RCCEx_PLL3_Config(&(pPeriphClkInit->PLL3));
 80044f2:	f104 0030 	add.w	r0, r4, #48	@ 0x30
 80044f6:	f7ff fa81 	bl	80039fc <RCCEx_PLL3_Config>
 80044fa:	4605      	mov	r5, r0
        break;
 80044fc:	e733      	b.n	8004366 <HAL_RCCEx_PeriphCLKConfig+0x88e>
      status = ret;
 80044fe:	462e      	mov	r6, r5
 8004500:	e73e      	b.n	8004380 <HAL_RCCEx_PeriphCLKConfig+0x8a8>
    switch (pPeriphClkInit->Lptim6ClockSelection)
 8004502:	2601      	movs	r6, #1
 8004504:	4635      	mov	r5, r6
 8004506:	e75e      	b.n	80043c6 <HAL_RCCEx_PeriphCLKConfig+0x8ee>
 8004508:	f1b3 4f80 	cmp.w	r3, #1073741824	@ 0x40000000
 800450c:	f43f af4e 	beq.w	80043ac <HAL_RCCEx_PeriphCLKConfig+0x8d4>
 8004510:	f1b3 4fa0 	cmp.w	r3, #1342177280	@ 0x50000000
 8004514:	f43f af4a 	beq.w	80043ac <HAL_RCCEx_PeriphCLKConfig+0x8d4>
 8004518:	f1b3 5f40 	cmp.w	r3, #805306368	@ 0x30000000
 800451c:	f43f af46 	beq.w	80043ac <HAL_RCCEx_PeriphCLKConfig+0x8d4>
 8004520:	2601      	movs	r6, #1
 8004522:	4635      	mov	r5, r6
 8004524:	e74f      	b.n	80043c6 <HAL_RCCEx_PeriphCLKConfig+0x8ee>
        ret = RCCEx_PLL3_Config(&(pPeriphClkInit->PLL3));
 8004526:	f104 0030 	add.w	r0, r4, #48	@ 0x30
 800452a:	f7ff fa67 	bl	80039fc <RCCEx_PLL3_Config>
 800452e:	4605      	mov	r5, r0
        break;
 8004530:	e73c      	b.n	80043ac <HAL_RCCEx_PeriphCLKConfig+0x8d4>
      status = ret;
 8004532:	462e      	mov	r6, r5
 8004534:	e747      	b.n	80043c6 <HAL_RCCEx_PeriphCLKConfig+0x8ee>
    switch (pPeriphClkInit->Sai1ClockSelection)
 8004536:	2601      	movs	r6, #1
 8004538:	4635      	mov	r5, r6
 800453a:	e01e      	b.n	800457a <HAL_RCCEx_PeriphCLKConfig+0xaa2>
 800453c:	f5b3 3f40 	cmp.w	r3, #196608	@ 0x30000
 8004540:	d010      	beq.n	8004564 <HAL_RCCEx_PeriphCLKConfig+0xa8c>
 8004542:	f5b3 2f80 	cmp.w	r3, #262144	@ 0x40000
 8004546:	d00d      	beq.n	8004564 <HAL_RCCEx_PeriphCLKConfig+0xa8c>
 8004548:	2601      	movs	r6, #1
 800454a:	4635      	mov	r5, r6
 800454c:	e015      	b.n	800457a <HAL_RCCEx_PeriphCLKConfig+0xaa2>
        __HAL_RCC_PLL1_CLKOUT_ENABLE(RCC_PLL1_DIVQ);
 800454e:	4aaa      	ldr	r2, [pc, #680]	@ (80047f8 <HAL_RCCEx_PeriphCLKConfig+0xd20>)
 8004550:	6a93      	ldr	r3, [r2, #40]	@ 0x28
 8004552:	f443 3300 	orr.w	r3, r3, #131072	@ 0x20000
 8004556:	6293      	str	r3, [r2, #40]	@ 0x28
        break;
 8004558:	e004      	b.n	8004564 <HAL_RCCEx_PeriphCLKConfig+0xa8c>
        ret = RCCEx_PLL3_Config(&(pPeriphClkInit->PLL3));
 800455a:	f104 0030 	add.w	r0, r4, #48	@ 0x30
 800455e:	f7ff fa4d 	bl	80039fc <RCCEx_PLL3_Config>
 8004562:	4605      	mov	r5, r0
    if (ret == HAL_OK)
 8004564:	b9ed      	cbnz	r5, 80045a2 <HAL_RCCEx_PeriphCLKConfig+0xaca>
      __HAL_RCC_SAI1_CONFIG(pPeriphClkInit->Sai1ClockSelection);
 8004566:	4aa4      	ldr	r2, [pc, #656]	@ (80047f8 <HAL_RCCEx_PeriphCLKConfig+0xd20>)
 8004568:	f8d2 30e8 	ldr.w	r3, [r2, #232]	@ 0xe8
 800456c:	f423 23e0 	bic.w	r3, r3, #458752	@ 0x70000
 8004570:	f8d4 10c0 	ldr.w	r1, [r4, #192]	@ 0xc0
 8004574:	430b      	orrs	r3, r1
 8004576:	f8c2 30e8 	str.w	r3, [r2, #232]	@ 0xe8
  if (((pPeriphClkInit->PeriphClockSelection) & RCC_PERIPHCLK_SAI2) == RCC_PERIPHCLK_SAI2)
 800457a:	6823      	ldr	r3, [r4, #0]
 800457c:	f413 1f80 	tst.w	r3, #1048576	@ 0x100000
 8004580:	d033      	beq.n	80045ea <HAL_RCCEx_PeriphCLKConfig+0xb12>
    switch (pPeriphClkInit->Sai2ClockSelection)
 8004582:	f8d4 30c4 	ldr.w	r3, [r4, #196]	@ 0xc4
 8004586:	f5b3 1f80 	cmp.w	r3, #1048576	@ 0x100000
 800458a:	d01e      	beq.n	80045ca <HAL_RCCEx_PeriphCLKConfig+0xaf2>
 800458c:	d80e      	bhi.n	80045ac <HAL_RCCEx_PeriphCLKConfig+0xad4>
 800458e:	b1b3      	cbz	r3, 80045be <HAL_RCCEx_PeriphCLKConfig+0xae6>
 8004590:	f5b3 2f00 	cmp.w	r3, #524288	@ 0x80000
 8004594:	d107      	bne.n	80045a6 <HAL_RCCEx_PeriphCLKConfig+0xace>
        ret = RCCEx_PLL2_Config(&(pPeriphClkInit->PLL2));
 8004596:	f104 0008 	add.w	r0, r4, #8
 800459a:	f7ff f9c1 	bl	8003920 <RCCEx_PLL2_Config>
 800459e:	4605      	mov	r5, r0
        break;
 80045a0:	e018      	b.n	80045d4 <HAL_RCCEx_PeriphCLKConfig+0xafc>
      status = ret;
 80045a2:	462e      	mov	r6, r5
 80045a4:	e7e9      	b.n	800457a <HAL_RCCEx_PeriphCLKConfig+0xaa2>
    switch (pPeriphClkInit->Sai2ClockSelection)
 80045a6:	2601      	movs	r6, #1
 80045a8:	4635      	mov	r5, r6
 80045aa:	e01e      	b.n	80045ea <HAL_RCCEx_PeriphCLKConfig+0xb12>
 80045ac:	f5b3 1fc0 	cmp.w	r3, #1572864	@ 0x180000
 80045b0:	d010      	beq.n	80045d4 <HAL_RCCEx_PeriphCLKConfig+0xafc>
 80045b2:	f5b3 1f00 	cmp.w	r3, #2097152	@ 0x200000
 80045b6:	d00d      	beq.n	80045d4 <HAL_RCCEx_PeriphCLKConfig+0xafc>
 80045b8:	2601      	movs	r6, #1
 80045ba:	4635      	mov	r5, r6
 80045bc:	e015      	b.n	80045ea <HAL_RCCEx_PeriphCLKConfig+0xb12>
        __HAL_RCC_PLL1_CLKOUT_ENABLE(RCC_PLL1_DIVQ);
 80045be:	4a8e      	ldr	r2, [pc, #568]	@ (80047f8 <HAL_RCCEx_PeriphCLKConfig+0xd20>)
 80045c0:	6a93      	ldr	r3, [r2, #40]	@ 0x28
 80045c2:	f443 3300 	orr.w	r3, r3, #131072	@ 0x20000
 80045c6:	6293      	str	r3, [r2, #40]	@ 0x28
        break;
 80045c8:	e004      	b.n	80045d4 <HAL_RCCEx_PeriphCLKConfig+0xafc>
        ret = RCCEx_PLL3_Config(&(pPeriphClkInit->PLL3));
 80045ca:	f104 0030 	add.w	r0, r4, #48	@ 0x30
 80045ce:	f7ff fa15 	bl	80039fc <RCCEx_PLL3_Config>
 80045d2:	4605      	mov	r5, r0
    if (ret == HAL_OK)
 80045d4:	b9c5      	cbnz	r5, 8004608 <HAL_RCCEx_PeriphCLKConfig+0xb30>
      __HAL_RCC_SAI2_CONFIG(pPeriphClkInit->Sai2ClockSelection);
 80045d6:	4a88      	ldr	r2, [pc, #544]	@ (80047f8 <HAL_RCCEx_PeriphCLKConfig+0xd20>)
 80045d8:	f8d2 30e8 	ldr.w	r3, [r2, #232]	@ 0xe8
 80045dc:	f423 1360 	bic.w	r3, r3, #3670016	@ 0x380000
 80045e0:	f8d4 10c4 	ldr.w	r1, [r4, #196]	@ 0xc4
 80045e4:	430b      	orrs	r3, r1
 80045e6:	f8c2 30e8 	str.w	r3, [r2, #232]	@ 0xe8
  if (((pPeriphClkInit->PeriphClockSelection) & RCC_PERIPHCLK_ADCDAC) == RCC_PERIPHCLK_ADCDAC)
 80045ea:	6823      	ldr	r3, [r4, #0]
 80045ec:	f413 1f00 	tst.w	r3, #2097152	@ 0x200000
 80045f0:	d023      	beq.n	800463a <HAL_RCCEx_PeriphCLKConfig+0xb62>
    switch (pPeriphClkInit->AdcDacClockSelection)
 80045f2:	f8d4 30d4 	ldr.w	r3, [r4, #212]	@ 0xd4
 80045f6:	2b02      	cmp	r3, #2
 80045f8:	d00d      	beq.n	8004616 <HAL_RCCEx_PeriphCLKConfig+0xb3e>
 80045fa:	d907      	bls.n	800460c <HAL_RCCEx_PeriphCLKConfig+0xb34>
 80045fc:	3b03      	subs	r3, #3
 80045fe:	2b02      	cmp	r3, #2
 8004600:	d90e      	bls.n	8004620 <HAL_RCCEx_PeriphCLKConfig+0xb48>
 8004602:	2601      	movs	r6, #1
 8004604:	4635      	mov	r5, r6
 8004606:	e018      	b.n	800463a <HAL_RCCEx_PeriphCLKConfig+0xb62>
      status = ret;
 8004608:	462e      	mov	r6, r5
 800460a:	e7ee      	b.n	80045ea <HAL_RCCEx_PeriphCLKConfig+0xb12>
    switch (pPeriphClkInit->AdcDacClockSelection)
 800460c:	2b01      	cmp	r3, #1
 800460e:	d907      	bls.n	8004620 <HAL_RCCEx_PeriphCLKConfig+0xb48>
 8004610:	2601      	movs	r6, #1
 8004612:	4635      	mov	r5, r6
 8004614:	e011      	b.n	800463a <HAL_RCCEx_PeriphCLKConfig+0xb62>
        ret = RCCEx_PLL2_Config(&(pPeriphClkInit->PLL2));
 8004616:	f104 0008 	add.w	r0, r4, #8
 800461a:	f7ff f981 	bl	8003920 <RCCEx_PLL2_Config>
 800461e:	4605      	mov	r5, r0
    if (ret == HAL_OK)
 8004620:	b955      	cbnz	r5, 8004638 <HAL_RCCEx_PeriphCLKConfig+0xb60>
      __HAL_RCC_ADCDAC_CONFIG(pPeriphClkInit->AdcDacClockSelection);
 8004622:	4a75      	ldr	r2, [pc, #468]	@ (80047f8 <HAL_RCCEx_PeriphCLKConfig+0xd20>)
 8004624:	f8d2 30e8 	ldr.w	r3, [r2, #232]	@ 0xe8
 8004628:	f023 0307 	bic.w	r3, r3, #7
 800462c:	f8d4 10d4 	ldr.w	r1, [r4, #212]	@ 0xd4
 8004630:	430b      	orrs	r3, r1
 8004632:	f8c2 30e8 	str.w	r3, [r2, #232]	@ 0xe8
 8004636:	e000      	b.n	800463a <HAL_RCCEx_PeriphCLKConfig+0xb62>
      status = ret;
 8004638:	462e      	mov	r6, r5
  if (((pPeriphClkInit->PeriphClockSelection) & RCC_PERIPHCLK_DAC_LP) == RCC_PERIPHCLK_DAC_LP)
 800463a:	6863      	ldr	r3, [r4, #4]
 800463c:	f413 7f00 	tst.w	r3, #512	@ 0x200
 8004640:	d006      	beq.n	8004650 <HAL_RCCEx_PeriphCLKConfig+0xb78>
    switch (pPeriphClkInit->DacLowPowerClockSelection)
 8004642:	f8d4 30d8 	ldr.w	r3, [r4, #216]	@ 0xd8
 8004646:	b1e3      	cbz	r3, 8004682 <HAL_RCCEx_PeriphCLKConfig+0xbaa>
 8004648:	2b08      	cmp	r3, #8
 800464a:	d01a      	beq.n	8004682 <HAL_RCCEx_PeriphCLKConfig+0xbaa>
 800464c:	2601      	movs	r6, #1
 800464e:	4635      	mov	r5, r6
  if (((pPeriphClkInit->PeriphClockSelection) & RCC_PERIPHCLK_RTC) == RCC_PERIPHCLK_RTC)
 8004650:	6823      	ldr	r3, [r4, #0]
 8004652:	f013 7f00 	tst.w	r3, #33554432	@ 0x2000000
 8004656:	d120      	bne.n	800469a <HAL_RCCEx_PeriphCLKConfig+0xbc2>
  if (((pPeriphClkInit->PeriphClockSelection) & RCC_PERIPHCLK_RNG) == RCC_PERIPHCLK_RNG)
 8004658:	6823      	ldr	r3, [r4, #0]
 800465a:	f013 6f80 	tst.w	r3, #67108864	@ 0x4000000
 800465e:	f000 80a7 	beq.w	80047b0 <HAL_RCCEx_PeriphCLKConfig+0xcd8>
    switch (pPeriphClkInit->RngClockSelection)
 8004662:	f8d4 30c8 	ldr.w	r3, [r4, #200]	@ 0xc8
 8004666:	2b10      	cmp	r3, #16
 8004668:	f000 8090 	beq.w	800478c <HAL_RCCEx_PeriphCLKConfig+0xcb4>
 800466c:	f240 808a 	bls.w	8004784 <HAL_RCCEx_PeriphCLKConfig+0xcac>
 8004670:	2b20      	cmp	r3, #32
 8004672:	f000 8090 	beq.w	8004796 <HAL_RCCEx_PeriphCLKConfig+0xcbe>
 8004676:	2b30      	cmp	r3, #48	@ 0x30
 8004678:	f000 808d 	beq.w	8004796 <HAL_RCCEx_PeriphCLKConfig+0xcbe>
 800467c:	2601      	movs	r6, #1
 800467e:	4635      	mov	r5, r6
 8004680:	e096      	b.n	80047b0 <HAL_RCCEx_PeriphCLKConfig+0xcd8>
    if (ret == HAL_OK)
 8004682:	b945      	cbnz	r5, 8004696 <HAL_RCCEx_PeriphCLKConfig+0xbbe>
      __HAL_RCC_DAC_LP_CONFIG(pPeriphClkInit->DacLowPowerClockSelection);
 8004684:	495c      	ldr	r1, [pc, #368]	@ (80047f8 <HAL_RCCEx_PeriphCLKConfig+0xd20>)
 8004686:	f8d1 20e8 	ldr.w	r2, [r1, #232]	@ 0xe8
 800468a:	f022 0208 	bic.w	r2, r2, #8
 800468e:	4313      	orrs	r3, r2
 8004690:	f8c1 30e8 	str.w	r3, [r1, #232]	@ 0xe8
 8004694:	e7dc      	b.n	8004650 <HAL_RCCEx_PeriphCLKConfig+0xb78>
      status = ret;
 8004696:	462e      	mov	r6, r5
 8004698:	e7da      	b.n	8004650 <HAL_RCCEx_PeriphCLKConfig+0xb78>
    SET_BIT(PWR->DBPCR, PWR_DBPCR_DBP);
 800469a:	4a58      	ldr	r2, [pc, #352]	@ (80047fc <HAL_RCCEx_PeriphCLKConfig+0xd24>)
 800469c:	6a53      	ldr	r3, [r2, #36]	@ 0x24
 800469e:	f043 0301 	orr.w	r3, r3, #1
 80046a2:	6253      	str	r3, [r2, #36]	@ 0x24
    tickstart = HAL_GetTick();
 80046a4:	f7fe fb6c 	bl	8002d80 <HAL_GetTick>
 80046a8:	4607      	mov	r7, r0
    while (HAL_IS_BIT_CLR(PWR->DBPCR, PWR_DBPCR_DBP))
 80046aa:	4b54      	ldr	r3, [pc, #336]	@ (80047fc <HAL_RCCEx_PeriphCLKConfig+0xd24>)
 80046ac:	6a5b      	ldr	r3, [r3, #36]	@ 0x24
 80046ae:	f013 0f01 	tst.w	r3, #1
 80046b2:	d105      	bne.n	80046c0 <HAL_RCCEx_PeriphCLKConfig+0xbe8>
      if ((HAL_GetTick() - tickstart) > RCC_DBP_TIMEOUT_VALUE)
 80046b4:	f7fe fb64 	bl	8002d80 <HAL_GetTick>
 80046b8:	1bc0      	subs	r0, r0, r7
 80046ba:	2802      	cmp	r0, #2
 80046bc:	d9f5      	bls.n	80046aa <HAL_RCCEx_PeriphCLKConfig+0xbd2>
        ret = HAL_TIMEOUT;
 80046be:	2503      	movs	r5, #3
    if (ret == HAL_OK)
 80046c0:	2d00      	cmp	r5, #0
 80046c2:	d15b      	bne.n	800477c <HAL_RCCEx_PeriphCLKConfig+0xca4>
      tmpregister = READ_BIT(RCC->BDCR, RCC_BDCR_RTCSEL);
 80046c4:	4b4c      	ldr	r3, [pc, #304]	@ (80047f8 <HAL_RCCEx_PeriphCLKConfig+0xd20>)
 80046c6:	f8d3 30f0 	ldr.w	r3, [r3, #240]	@ 0xf0
      if ((tmpregister != RCC_RTCCLKSOURCE_NO_CLK) && (tmpregister != pPeriphClkInit->RTCClockSelection))
 80046ca:	f413 7340 	ands.w	r3, r3, #768	@ 0x300
 80046ce:	d019      	beq.n	8004704 <HAL_RCCEx_PeriphCLKConfig+0xc2c>
 80046d0:	f8d4 20f8 	ldr.w	r2, [r4, #248]	@ 0xf8
 80046d4:	429a      	cmp	r2, r3
 80046d6:	d012      	beq.n	80046fe <HAL_RCCEx_PeriphCLKConfig+0xc26>
        tmpregister = READ_BIT(RCC->BDCR, ~(RCC_BDCR_RTCSEL));
 80046d8:	4a47      	ldr	r2, [pc, #284]	@ (80047f8 <HAL_RCCEx_PeriphCLKConfig+0xd20>)
 80046da:	f8d2 30f0 	ldr.w	r3, [r2, #240]	@ 0xf0
 80046de:	f423 7340 	bic.w	r3, r3, #768	@ 0x300
        __HAL_RCC_BACKUPRESET_FORCE();
 80046e2:	f8d2 10f0 	ldr.w	r1, [r2, #240]	@ 0xf0
 80046e6:	f441 3180 	orr.w	r1, r1, #65536	@ 0x10000
 80046ea:	f8c2 10f0 	str.w	r1, [r2, #240]	@ 0xf0
        __HAL_RCC_BACKUPRESET_RELEASE();
 80046ee:	f8d2 10f0 	ldr.w	r1, [r2, #240]	@ 0xf0
 80046f2:	f421 3180 	bic.w	r1, r1, #65536	@ 0x10000
 80046f6:	f8c2 10f0 	str.w	r1, [r2, #240]	@ 0xf0
        RCC->BDCR = tmpregister;
 80046fa:	f8c2 30f0 	str.w	r3, [r2, #240]	@ 0xf0
      if (HAL_IS_BIT_SET(tmpregister, RCC_BDCR_LSEON))
 80046fe:	f013 0f01 	tst.w	r3, #1
 8004702:	d11e      	bne.n	8004742 <HAL_RCCEx_PeriphCLKConfig+0xc6a>
      if (ret == HAL_OK)
 8004704:	2d00      	cmp	r5, #0
 8004706:	d13b      	bne.n	8004780 <HAL_RCCEx_PeriphCLKConfig+0xca8>
        __HAL_RCC_RTC_CONFIG(pPeriphClkInit->RTCClockSelection);
 8004708:	f8d4 30f8 	ldr.w	r3, [r4, #248]	@ 0xf8
 800470c:	f403 7240 	and.w	r2, r3, #768	@ 0x300
 8004710:	f5b2 7f40 	cmp.w	r2, #768	@ 0x300
 8004714:	d027      	beq.n	8004766 <HAL_RCCEx_PeriphCLKConfig+0xc8e>
 8004716:	4a38      	ldr	r2, [pc, #224]	@ (80047f8 <HAL_RCCEx_PeriphCLKConfig+0xd20>)
 8004718:	69d3      	ldr	r3, [r2, #28]
 800471a:	f423 537c 	bic.w	r3, r3, #16128	@ 0x3f00
 800471e:	61d3      	str	r3, [r2, #28]
 8004720:	4b35      	ldr	r3, [pc, #212]	@ (80047f8 <HAL_RCCEx_PeriphCLKConfig+0xd20>)
 8004722:	f8d3 20f0 	ldr.w	r2, [r3, #240]	@ 0xf0
 8004726:	f422 7240 	bic.w	r2, r2, #768	@ 0x300
 800472a:	f8c3 20f0 	str.w	r2, [r3, #240]	@ 0xf0
 800472e:	f8d3 20f0 	ldr.w	r2, [r3, #240]	@ 0xf0
 8004732:	f8d4 10f8 	ldr.w	r1, [r4, #248]	@ 0xf8
 8004736:	f3c1 010b 	ubfx	r1, r1, #0, #12
 800473a:	430a      	orrs	r2, r1
 800473c:	f8c3 20f0 	str.w	r2, [r3, #240]	@ 0xf0
 8004740:	e78a      	b.n	8004658 <HAL_RCCEx_PeriphCLKConfig+0xb80>
        tickstart = HAL_GetTick();
 8004742:	f7fe fb1d 	bl	8002d80 <HAL_GetTick>
 8004746:	4607      	mov	r7, r0
        while (READ_BIT(RCC->BDCR, RCC_BDCR_LSERDY) == 0U)
 8004748:	4b2b      	ldr	r3, [pc, #172]	@ (80047f8 <HAL_RCCEx_PeriphCLKConfig+0xd20>)
 800474a:	f8d3 30f0 	ldr.w	r3, [r3, #240]	@ 0xf0
 800474e:	f013 0f02 	tst.w	r3, #2
 8004752:	d1d7      	bne.n	8004704 <HAL_RCCEx_PeriphCLKConfig+0xc2c>
          if ((HAL_GetTick() - tickstart) > RCC_LSE_TIMEOUT_VALUE)
 8004754:	f7fe fb14 	bl	8002d80 <HAL_GetTick>
 8004758:	1bc0      	subs	r0, r0, r7
 800475a:	f241 3388 	movw	r3, #5000	@ 0x1388
 800475e:	4298      	cmp	r0, r3
 8004760:	d9f2      	bls.n	8004748 <HAL_RCCEx_PeriphCLKConfig+0xc70>
            ret = HAL_TIMEOUT;
 8004762:	2503      	movs	r5, #3
 8004764:	e7ce      	b.n	8004704 <HAL_RCCEx_PeriphCLKConfig+0xc2c>
        __HAL_RCC_RTC_CONFIG(pPeriphClkInit->RTCClockSelection);
 8004766:	4924      	ldr	r1, [pc, #144]	@ (80047f8 <HAL_RCCEx_PeriphCLKConfig+0xd20>)
 8004768:	69ca      	ldr	r2, [r1, #28]
 800476a:	f422 527c 	bic.w	r2, r2, #16128	@ 0x3f00
 800476e:	f3c3 1317 	ubfx	r3, r3, #4, #24
 8004772:	f023 0330 	bic.w	r3, r3, #48	@ 0x30
 8004776:	4313      	orrs	r3, r2
 8004778:	61cb      	str	r3, [r1, #28]
 800477a:	e7d1      	b.n	8004720 <HAL_RCCEx_PeriphCLKConfig+0xc48>
      status = ret;
 800477c:	462e      	mov	r6, r5
 800477e:	e76b      	b.n	8004658 <HAL_RCCEx_PeriphCLKConfig+0xb80>
        status = ret;
 8004780:	462e      	mov	r6, r5
 8004782:	e769      	b.n	8004658 <HAL_RCCEx_PeriphCLKConfig+0xb80>
    switch (pPeriphClkInit->RngClockSelection)
 8004784:	b13b      	cbz	r3, 8004796 <HAL_RCCEx_PeriphCLKConfig+0xcbe>
 8004786:	2601      	movs	r6, #1
 8004788:	4635      	mov	r5, r6
 800478a:	e011      	b.n	80047b0 <HAL_RCCEx_PeriphCLKConfig+0xcd8>
        __HAL_RCC_PLL1_CLKOUT_ENABLE(RCC_PLL1_DIVQ);
 800478c:	4a1a      	ldr	r2, [pc, #104]	@ (80047f8 <HAL_RCCEx_PeriphCLKConfig+0xd20>)
 800478e:	6a93      	ldr	r3, [r2, #40]	@ 0x28
 8004790:	f443 3300 	orr.w	r3, r3, #131072	@ 0x20000
 8004794:	6293      	str	r3, [r2, #40]	@ 0x28
    if (ret == HAL_OK)
 8004796:	b955      	cbnz	r5, 80047ae <HAL_RCCEx_PeriphCLKConfig+0xcd6>
      __HAL_RCC_RNG_CONFIG(pPeriphClkInit->RngClockSelection);
 8004798:	4a17      	ldr	r2, [pc, #92]	@ (80047f8 <HAL_RCCEx_PeriphCLKConfig+0xd20>)
 800479a:	f8d2 30e8 	ldr.w	r3, [r2, #232]	@ 0xe8
 800479e:	f023 0330 	bic.w	r3, r3, #48	@ 0x30
 80047a2:	f8d4 10c8 	ldr.w	r1, [r4, #200]	@ 0xc8
 80047a6:	430b      	orrs	r3, r1
 80047a8:	f8c2 30e8 	str.w	r3, [r2, #232]	@ 0xe8
 80047ac:	e000      	b.n	80047b0 <HAL_RCCEx_PeriphCLKConfig+0xcd8>
      status = ret;
 80047ae:	462e      	mov	r6, r5
  if (((pPeriphClkInit->PeriphClockSelection) & RCC_PERIPHCLK_SDMMC1) == RCC_PERIPHCLK_SDMMC1)
 80047b0:	6823      	ldr	r3, [r4, #0]
 80047b2:	f413 0f80 	tst.w	r3, #4194304	@ 0x400000
 80047b6:	d006      	beq.n	80047c6 <HAL_RCCEx_PeriphCLKConfig+0xcee>
    switch (pPeriphClkInit->Sdmmc1ClockSelection)
 80047b8:	f8d4 30cc 	ldr.w	r3, [r4, #204]	@ 0xcc
 80047bc:	b303      	cbz	r3, 8004800 <HAL_RCCEx_PeriphCLKConfig+0xd28>
 80047be:	2b40      	cmp	r3, #64	@ 0x40
 80047c0:	d02f      	beq.n	8004822 <HAL_RCCEx_PeriphCLKConfig+0xd4a>
 80047c2:	2601      	movs	r6, #1
 80047c4:	4635      	mov	r5, r6
  if (((pPeriphClkInit->PeriphClockSelection) & RCC_PERIPHCLK_SDMMC2) == RCC_PERIPHCLK_SDMMC2)
 80047c6:	6823      	ldr	r3, [r4, #0]
 80047c8:	f413 0f00 	tst.w	r3, #8388608	@ 0x800000
 80047cc:	d006      	beq.n	80047dc <HAL_RCCEx_PeriphCLKConfig+0xd04>
    switch (pPeriphClkInit->Sdmmc2ClockSelection)
 80047ce:	f8d4 30d0 	ldr.w	r3, [r4, #208]	@ 0xd0
 80047d2:	b373      	cbz	r3, 8004832 <HAL_RCCEx_PeriphCLKConfig+0xd5a>
 80047d4:	2b80      	cmp	r3, #128	@ 0x80
 80047d6:	d03d      	beq.n	8004854 <HAL_RCCEx_PeriphCLKConfig+0xd7c>
 80047d8:	2601      	movs	r6, #1
 80047da:	4635      	mov	r5, r6
  if (((pPeriphClkInit->PeriphClockSelection) & RCC_PERIPHCLK_SPI1) == RCC_PERIPHCLK_SPI1)
 80047dc:	6823      	ldr	r3, [r4, #0]
 80047de:	f013 6f00 	tst.w	r3, #134217728	@ 0x8000000
 80047e2:	d04f      	beq.n	8004884 <HAL_RCCEx_PeriphCLKConfig+0xdac>
    switch (pPeriphClkInit->Spi1ClockSelection)
 80047e4:	f8d4 30e0 	ldr.w	r3, [r4, #224]	@ 0xe0
 80047e8:	2b04      	cmp	r3, #4
 80047ea:	d872      	bhi.n	80048d2 <HAL_RCCEx_PeriphCLKConfig+0xdfa>
 80047ec:	e8df f003 	tbb	[pc, r3]
 80047f0:	3f6b653a 	.word	0x3f6b653a
 80047f4:	3f          	.byte	0x3f
 80047f5:	00          	.byte	0x00
 80047f6:	bf00      	nop
 80047f8:	44020c00 	.word	0x44020c00
 80047fc:	44020800 	.word	0x44020800
        __HAL_RCC_PLL1_CLKOUT_ENABLE(RCC_PLL1_DIVQ);
 8004800:	4a97      	ldr	r2, [pc, #604]	@ (8004a60 <HAL_RCCEx_PeriphCLKConfig+0xf88>)
 8004802:	6a93      	ldr	r3, [r2, #40]	@ 0x28
 8004804:	f443 3300 	orr.w	r3, r3, #131072	@ 0x20000
 8004808:	6293      	str	r3, [r2, #40]	@ 0x28
    if (ret == HAL_OK)
 800480a:	b985      	cbnz	r5, 800482e <HAL_RCCEx_PeriphCLKConfig+0xd56>
      __HAL_RCC_SDMMC1_CONFIG(pPeriphClkInit->Sdmmc1ClockSelection);
 800480c:	4a94      	ldr	r2, [pc, #592]	@ (8004a60 <HAL_RCCEx_PeriphCLKConfig+0xf88>)
 800480e:	f8d2 30e4 	ldr.w	r3, [r2, #228]	@ 0xe4
 8004812:	f023 0340 	bic.w	r3, r3, #64	@ 0x40
 8004816:	f8d4 10cc 	ldr.w	r1, [r4, #204]	@ 0xcc
 800481a:	430b      	orrs	r3, r1
 800481c:	f8c2 30e4 	str.w	r3, [r2, #228]	@ 0xe4
 8004820:	e7d1      	b.n	80047c6 <HAL_RCCEx_PeriphCLKConfig+0xcee>
        ret = RCCEx_PLL2_Config(&(pPeriphClkInit->PLL2));
 8004822:	f104 0008 	add.w	r0, r4, #8
 8004826:	f7ff f87b 	bl	8003920 <RCCEx_PLL2_Config>
 800482a:	4605      	mov	r5, r0
        break;
 800482c:	e7ed      	b.n	800480a <HAL_RCCEx_PeriphCLKConfig+0xd32>
      status = ret;
 800482e:	462e      	mov	r6, r5
 8004830:	e7c9      	b.n	80047c6 <HAL_RCCEx_PeriphCLKConfig+0xcee>
        __HAL_RCC_PLL1_CLKOUT_ENABLE(RCC_PLL1_DIVQ);
 8004832:	4a8b      	ldr	r2, [pc, #556]	@ (8004a60 <HAL_RCCEx_PeriphCLKConfig+0xf88>)
 8004834:	6a93      	ldr	r3, [r2, #40]	@ 0x28
 8004836:	f443 3300 	orr.w	r3, r3, #131072	@ 0x20000
 800483a:	6293      	str	r3, [r2, #40]	@ 0x28
    if (ret == HAL_OK)
 800483c:	b985      	cbnz	r5, 8004860 <HAL_RCCEx_PeriphCLKConfig+0xd88>
      __HAL_RCC_SDMMC2_CONFIG(pPeriphClkInit->Sdmmc2ClockSelection);
 800483e:	4a88      	ldr	r2, [pc, #544]	@ (8004a60 <HAL_RCCEx_PeriphCLKConfig+0xf88>)
 8004840:	f8d2 30e4 	ldr.w	r3, [r2, #228]	@ 0xe4
 8004844:	f023 0380 	bic.w	r3, r3, #128	@ 0x80
 8004848:	f8d4 10d0 	ldr.w	r1, [r4, #208]	@ 0xd0
 800484c:	430b      	orrs	r3, r1
 800484e:	f8c2 30e4 	str.w	r3, [r2, #228]	@ 0xe4
 8004852:	e7c3      	b.n	80047dc <HAL_RCCEx_PeriphCLKConfig+0xd04>
        ret = RCCEx_PLL2_Config(&(pPeriphClkInit->PLL2));
 8004854:	f104 0008 	add.w	r0, r4, #8
 8004858:	f7ff f862 	bl	8003920 <RCCEx_PLL2_Config>
 800485c:	4605      	mov	r5, r0
        break;
 800485e:	e7ed      	b.n	800483c <HAL_RCCEx_PeriphCLKConfig+0xd64>
      status = ret;
 8004860:	462e      	mov	r6, r5
 8004862:	e7bb      	b.n	80047dc <HAL_RCCEx_PeriphCLKConfig+0xd04>
        __HAL_RCC_PLL1_CLKOUT_ENABLE(RCC_PLL1_DIVQ);
 8004864:	4a7e      	ldr	r2, [pc, #504]	@ (8004a60 <HAL_RCCEx_PeriphCLKConfig+0xf88>)
 8004866:	6a93      	ldr	r3, [r2, #40]	@ 0x28
 8004868:	f443 3300 	orr.w	r3, r3, #131072	@ 0x20000
 800486c:	6293      	str	r3, [r2, #40]	@ 0x28
    if (ret == HAL_OK)
 800486e:	bb9d      	cbnz	r5, 80048d8 <HAL_RCCEx_PeriphCLKConfig+0xe00>
      __HAL_RCC_SPI1_CONFIG(pPeriphClkInit->Spi1ClockSelection);
 8004870:	4a7b      	ldr	r2, [pc, #492]	@ (8004a60 <HAL_RCCEx_PeriphCLKConfig+0xf88>)
 8004872:	f8d2 30e0 	ldr.w	r3, [r2, #224]	@ 0xe0
 8004876:	f023 0307 	bic.w	r3, r3, #7
 800487a:	f8d4 10e0 	ldr.w	r1, [r4, #224]	@ 0xe0
 800487e:	430b      	orrs	r3, r1
 8004880:	f8c2 30e0 	str.w	r3, [r2, #224]	@ 0xe0
  if (((pPeriphClkInit->PeriphClockSelection) & RCC_PERIPHCLK_SPI2) == RCC_PERIPHCLK_SPI2)
 8004884:	6823      	ldr	r3, [r4, #0]
 8004886:	f013 5f80 	tst.w	r3, #268435456	@ 0x10000000
 800488a:	d046      	beq.n	800491a <HAL_RCCEx_PeriphCLKConfig+0xe42>
    switch (pPeriphClkInit->Spi2ClockSelection)
 800488c:	f8d4 30e4 	ldr.w	r3, [r4, #228]	@ 0xe4
 8004890:	2b20      	cmp	r3, #32
 8004892:	d840      	bhi.n	8004916 <HAL_RCCEx_PeriphCLKConfig+0xe3e>
 8004894:	e8df f003 	tbb	[pc, r3]
 8004898:	3f3f3f22 	.word	0x3f3f3f22
 800489c:	3f3f3f3f 	.word	0x3f3f3f3f
 80048a0:	3f3f3f33 	.word	0x3f3f3f33
 80048a4:	3f3f3f3f 	.word	0x3f3f3f3f
 80048a8:	3f3f3f39 	.word	0x3f3f3f39
 80048ac:	3f3f3f3f 	.word	0x3f3f3f3f
 80048b0:	3f3f3f27 	.word	0x3f3f3f27
 80048b4:	3f3f3f3f 	.word	0x3f3f3f3f
 80048b8:	27          	.byte	0x27
 80048b9:	00          	.byte	0x00
        ret = RCCEx_PLL2_Config(&(pPeriphClkInit->PLL2));
 80048ba:	f104 0008 	add.w	r0, r4, #8
 80048be:	f7ff f82f 	bl	8003920 <RCCEx_PLL2_Config>
 80048c2:	4605      	mov	r5, r0
        break;
 80048c4:	e7d3      	b.n	800486e <HAL_RCCEx_PeriphCLKConfig+0xd96>
        ret = RCCEx_PLL3_Config(&(pPeriphClkInit->PLL3));
 80048c6:	f104 0030 	add.w	r0, r4, #48	@ 0x30
 80048ca:	f7ff f897 	bl	80039fc <RCCEx_PLL3_Config>
 80048ce:	4605      	mov	r5, r0
        break;
 80048d0:	e7cd      	b.n	800486e <HAL_RCCEx_PeriphCLKConfig+0xd96>
    switch (pPeriphClkInit->Spi1ClockSelection)
 80048d2:	2601      	movs	r6, #1
 80048d4:	4635      	mov	r5, r6
 80048d6:	e7d5      	b.n	8004884 <HAL_RCCEx_PeriphCLKConfig+0xdac>
      status = ret;
 80048d8:	462e      	mov	r6, r5
 80048da:	e7d3      	b.n	8004884 <HAL_RCCEx_PeriphCLKConfig+0xdac>
        __HAL_RCC_PLL1_CLKOUT_ENABLE(RCC_PLL1_DIVQ);
 80048dc:	4a60      	ldr	r2, [pc, #384]	@ (8004a60 <HAL_RCCEx_PeriphCLKConfig+0xf88>)
 80048de:	6a93      	ldr	r3, [r2, #40]	@ 0x28
 80048e0:	f443 3300 	orr.w	r3, r3, #131072	@ 0x20000
 80048e4:	6293      	str	r3, [r2, #40]	@ 0x28
    if (ret == HAL_OK)
 80048e6:	bb55      	cbnz	r5, 800493e <HAL_RCCEx_PeriphCLKConfig+0xe66>
      __HAL_RCC_SPI2_CONFIG(pPeriphClkInit->Spi2ClockSelection);
 80048e8:	4a5d      	ldr	r2, [pc, #372]	@ (8004a60 <HAL_RCCEx_PeriphCLKConfig+0xf88>)
 80048ea:	f8d2 30e0 	ldr.w	r3, [r2, #224]	@ 0xe0
 80048ee:	f023 0338 	bic.w	r3, r3, #56	@ 0x38
 80048f2:	f8d4 10e4 	ldr.w	r1, [r4, #228]	@ 0xe4
 80048f6:	430b      	orrs	r3, r1
 80048f8:	f8c2 30e0 	str.w	r3, [r2, #224]	@ 0xe0
 80048fc:	e00d      	b.n	800491a <HAL_RCCEx_PeriphCLKConfig+0xe42>
        ret = RCCEx_PLL2_Config(&(pPeriphClkInit->PLL2));
 80048fe:	f104 0008 	add.w	r0, r4, #8
 8004902:	f7ff f80d 	bl	8003920 <RCCEx_PLL2_Config>
 8004906:	4605      	mov	r5, r0
        break;
 8004908:	e7ed      	b.n	80048e6 <HAL_RCCEx_PeriphCLKConfig+0xe0e>
        ret = RCCEx_PLL3_Config(&(pPeriphClkInit->PLL3));
 800490a:	f104 0030 	add.w	r0, r4, #48	@ 0x30
 800490e:	f7ff f875 	bl	80039fc <RCCEx_PLL3_Config>
 8004912:	4605      	mov	r5, r0
        break;
 8004914:	e7e7      	b.n	80048e6 <HAL_RCCEx_PeriphCLKConfig+0xe0e>
    switch (pPeriphClkInit->Spi2ClockSelection)
 8004916:	2601      	movs	r6, #1
 8004918:	4635      	mov	r5, r6
  if (((pPeriphClkInit->PeriphClockSelection) & RCC_PERIPHCLK_SPI3) == RCC_PERIPHCLK_SPI3)
 800491a:	6823      	ldr	r3, [r4, #0]
 800491c:	f013 5f00 	tst.w	r3, #536870912	@ 0x20000000
 8004920:	d032      	beq.n	8004988 <HAL_RCCEx_PeriphCLKConfig+0xeb0>
    switch (pPeriphClkInit->Spi3ClockSelection)
 8004922:	f8d4 30e8 	ldr.w	r3, [r4, #232]	@ 0xe8
 8004926:	2b80      	cmp	r3, #128	@ 0x80
 8004928:	d01c      	beq.n	8004964 <HAL_RCCEx_PeriphCLKConfig+0xe8c>
 800492a:	d80d      	bhi.n	8004948 <HAL_RCCEx_PeriphCLKConfig+0xe70>
 800492c:	b1a3      	cbz	r3, 8004958 <HAL_RCCEx_PeriphCLKConfig+0xe80>
 800492e:	2b40      	cmp	r3, #64	@ 0x40
 8004930:	d107      	bne.n	8004942 <HAL_RCCEx_PeriphCLKConfig+0xe6a>
        ret = RCCEx_PLL2_Config(&(pPeriphClkInit->PLL2));
 8004932:	f104 0008 	add.w	r0, r4, #8
 8004936:	f7fe fff3 	bl	8003920 <RCCEx_PLL2_Config>
 800493a:	4605      	mov	r5, r0
        break;
 800493c:	e017      	b.n	800496e <HAL_RCCEx_PeriphCLKConfig+0xe96>
      status = ret;
 800493e:	462e      	mov	r6, r5
 8004940:	e7eb      	b.n	800491a <HAL_RCCEx_PeriphCLKConfig+0xe42>
    switch (pPeriphClkInit->Spi3ClockSelection)
 8004942:	2601      	movs	r6, #1
 8004944:	4635      	mov	r5, r6
 8004946:	e01f      	b.n	8004988 <HAL_RCCEx_PeriphCLKConfig+0xeb0>
 8004948:	2bc0      	cmp	r3, #192	@ 0xc0
 800494a:	d010      	beq.n	800496e <HAL_RCCEx_PeriphCLKConfig+0xe96>
 800494c:	f5b3 7f80 	cmp.w	r3, #256	@ 0x100
 8004950:	d00d      	beq.n	800496e <HAL_RCCEx_PeriphCLKConfig+0xe96>
 8004952:	2601      	movs	r6, #1
 8004954:	4635      	mov	r5, r6
 8004956:	e017      	b.n	8004988 <HAL_RCCEx_PeriphCLKConfig+0xeb0>
        __HAL_RCC_PLL1_CLKOUT_ENABLE(RCC_PLL1_DIVQ);
 8004958:	4a41      	ldr	r2, [pc, #260]	@ (8004a60 <HAL_RCCEx_PeriphCLKConfig+0xf88>)
 800495a:	6a93      	ldr	r3, [r2, #40]	@ 0x28
 800495c:	f443 3300 	orr.w	r3, r3, #131072	@ 0x20000
 8004960:	6293      	str	r3, [r2, #40]	@ 0x28
        break;
 8004962:	e004      	b.n	800496e <HAL_RCCEx_PeriphCLKConfig+0xe96>
        ret = RCCEx_PLL3_Config(&(pPeriphClkInit->PLL3));
 8004964:	f104 0030 	add.w	r0, r4, #48	@ 0x30
 8004968:	f7ff f848 	bl	80039fc <RCCEx_PLL3_Config>
 800496c:	4605      	mov	r5, r0
    if (ret == HAL_OK)
 800496e:	b955      	cbnz	r5, 8004986 <HAL_RCCEx_PeriphCLKConfig+0xeae>
      __HAL_RCC_SPI3_CONFIG(pPeriphClkInit->Spi3ClockSelection);
 8004970:	4a3b      	ldr	r2, [pc, #236]	@ (8004a60 <HAL_RCCEx_PeriphCLKConfig+0xf88>)
 8004972:	f8d2 30e0 	ldr.w	r3, [r2, #224]	@ 0xe0
 8004976:	f423 73e0 	bic.w	r3, r3, #448	@ 0x1c0
 800497a:	f8d4 10e8 	ldr.w	r1, [r4, #232]	@ 0xe8
 800497e:	430b      	orrs	r3, r1
 8004980:	f8c2 30e0 	str.w	r3, [r2, #224]	@ 0xe0
 8004984:	e000      	b.n	8004988 <HAL_RCCEx_PeriphCLKConfig+0xeb0>
      status = ret;
 8004986:	462e      	mov	r6, r5
  if (((pPeriphClkInit->PeriphClockSelection) & RCC_PERIPHCLK_SPI4) == RCC_PERIPHCLK_SPI4)
 8004988:	6823      	ldr	r3, [r4, #0]
 800498a:	f013 4f80 	tst.w	r3, #1073741824	@ 0x40000000
 800498e:	d01a      	beq.n	80049c6 <HAL_RCCEx_PeriphCLKConfig+0xeee>
    switch (pPeriphClkInit->Spi4ClockSelection)
 8004990:	f8d4 30ec 	ldr.w	r3, [r4, #236]	@ 0xec
 8004994:	f5b3 6f80 	cmp.w	r3, #1024	@ 0x400
 8004998:	d070      	beq.n	8004a7c <HAL_RCCEx_PeriphCLKConfig+0xfa4>
 800499a:	d863      	bhi.n	8004a64 <HAL_RCCEx_PeriphCLKConfig+0xf8c>
 800499c:	b13b      	cbz	r3, 80049ae <HAL_RCCEx_PeriphCLKConfig+0xed6>
 800499e:	f5b3 7f00 	cmp.w	r3, #512	@ 0x200
 80049a2:	d159      	bne.n	8004a58 <HAL_RCCEx_PeriphCLKConfig+0xf80>
        ret = RCCEx_PLL2_Config(&(pPeriphClkInit->PLL2));
 80049a4:	f104 0008 	add.w	r0, r4, #8
 80049a8:	f7fe ffba 	bl	8003920 <RCCEx_PLL2_Config>
 80049ac:	4605      	mov	r5, r0
    if (ret == HAL_OK)
 80049ae:	2d00      	cmp	r5, #0
 80049b0:	d16a      	bne.n	8004a88 <HAL_RCCEx_PeriphCLKConfig+0xfb0>
      __HAL_RCC_SPI4_CONFIG(pPeriphClkInit->Spi4ClockSelection);
 80049b2:	4a2b      	ldr	r2, [pc, #172]	@ (8004a60 <HAL_RCCEx_PeriphCLKConfig+0xf88>)
 80049b4:	f8d2 30e0 	ldr.w	r3, [r2, #224]	@ 0xe0
 80049b8:	f423 6360 	bic.w	r3, r3, #3584	@ 0xe00
 80049bc:	f8d4 10ec 	ldr.w	r1, [r4, #236]	@ 0xec
 80049c0:	430b      	orrs	r3, r1
 80049c2:	f8c2 30e0 	str.w	r3, [r2, #224]	@ 0xe0
  if (((pPeriphClkInit->PeriphClockSelection) & RCC_PERIPHCLK_SPI5) == RCC_PERIPHCLK_SPI5)
 80049c6:	6823      	ldr	r3, [r4, #0]
 80049c8:	2b00      	cmp	r3, #0
 80049ca:	da1a      	bge.n	8004a02 <HAL_RCCEx_PeriphCLKConfig+0xf2a>
    switch (pPeriphClkInit->Spi5ClockSelection)
 80049cc:	f8d4 30f0 	ldr.w	r3, [r4, #240]	@ 0xf0
 80049d0:	f5b3 5f00 	cmp.w	r3, #8192	@ 0x2000
 80049d4:	d069      	beq.n	8004aaa <HAL_RCCEx_PeriphCLKConfig+0xfd2>
 80049d6:	d85c      	bhi.n	8004a92 <HAL_RCCEx_PeriphCLKConfig+0xfba>
 80049d8:	b13b      	cbz	r3, 80049ea <HAL_RCCEx_PeriphCLKConfig+0xf12>
 80049da:	f5b3 5f80 	cmp.w	r3, #4096	@ 0x1000
 80049de:	d155      	bne.n	8004a8c <HAL_RCCEx_PeriphCLKConfig+0xfb4>
        ret = RCCEx_PLL2_Config(&(pPeriphClkInit->PLL2));
 80049e0:	f104 0008 	add.w	r0, r4, #8
 80049e4:	f7fe ff9c 	bl	8003920 <RCCEx_PLL2_Config>
 80049e8:	4605      	mov	r5, r0
    if (ret == HAL_OK)
 80049ea:	2d00      	cmp	r5, #0
 80049ec:	d163      	bne.n	8004ab6 <HAL_RCCEx_PeriphCLKConfig+0xfde>
      __HAL_RCC_SPI5_CONFIG(pPeriphClkInit->Spi5ClockSelection);
 80049ee:	4a1c      	ldr	r2, [pc, #112]	@ (8004a60 <HAL_RCCEx_PeriphCLKConfig+0xf88>)
 80049f0:	f8d2 30e0 	ldr.w	r3, [r2, #224]	@ 0xe0
 80049f4:	f423 43e0 	bic.w	r3, r3, #28672	@ 0x7000
 80049f8:	f8d4 10f0 	ldr.w	r1, [r4, #240]	@ 0xf0
 80049fc:	430b      	orrs	r3, r1
 80049fe:	f8c2 30e0 	str.w	r3, [r2, #224]	@ 0xe0
  if (((pPeriphClkInit->PeriphClockSelection) & RCC_PERIPHCLK_SPI6) == RCC_PERIPHCLK_SPI6)
 8004a02:	6863      	ldr	r3, [r4, #4]
 8004a04:	f013 0f01 	tst.w	r3, #1
 8004a08:	d01a      	beq.n	8004a40 <HAL_RCCEx_PeriphCLKConfig+0xf68>
    switch (pPeriphClkInit->Spi6ClockSelection)
 8004a0a:	f8d4 30f4 	ldr.w	r3, [r4, #244]	@ 0xf4
 8004a0e:	f5b3 3f80 	cmp.w	r3, #65536	@ 0x10000
 8004a12:	d061      	beq.n	8004ad8 <HAL_RCCEx_PeriphCLKConfig+0x1000>
 8004a14:	d854      	bhi.n	8004ac0 <HAL_RCCEx_PeriphCLKConfig+0xfe8>
 8004a16:	b13b      	cbz	r3, 8004a28 <HAL_RCCEx_PeriphCLKConfig+0xf50>
 8004a18:	f5b3 4f00 	cmp.w	r3, #32768	@ 0x8000
 8004a1c:	d14d      	bne.n	8004aba <HAL_RCCEx_PeriphCLKConfig+0xfe2>
        ret = RCCEx_PLL2_Config(&(pPeriphClkInit->PLL2));
 8004a1e:	f104 0008 	add.w	r0, r4, #8
 8004a22:	f7fe ff7d 	bl	8003920 <RCCEx_PLL2_Config>
 8004a26:	4605      	mov	r5, r0
    if (ret == HAL_OK)
 8004a28:	2d00      	cmp	r5, #0
 8004a2a:	d15b      	bne.n	8004ae4 <HAL_RCCEx_PeriphCLKConfig+0x100c>
      __HAL_RCC_SPI6_CONFIG(pPeriphClkInit->Spi6ClockSelection);
 8004a2c:	4a0c      	ldr	r2, [pc, #48]	@ (8004a60 <HAL_RCCEx_PeriphCLKConfig+0xf88>)
 8004a2e:	f8d2 30e0 	ldr.w	r3, [r2, #224]	@ 0xe0
 8004a32:	f423 3360 	bic.w	r3, r3, #229376	@ 0x38000
 8004a36:	f8d4 10f4 	ldr.w	r1, [r4, #244]	@ 0xf4
 8004a3a:	430b      	orrs	r3, r1
 8004a3c:	f8c2 30e0 	str.w	r3, [r2, #224]	@ 0xe0
  if (((pPeriphClkInit->PeriphClockSelection) & RCC_PERIPHCLK_OSPI) == RCC_PERIPHCLK_OSPI)
 8004a40:	6863      	ldr	r3, [r4, #4]
 8004a42:	f013 0f02 	tst.w	r3, #2
 8004a46:	d05f      	beq.n	8004b08 <HAL_RCCEx_PeriphCLKConfig+0x1030>
    switch (pPeriphClkInit->OspiClockSelection)
 8004a48:	f8d4 30dc 	ldr.w	r3, [r4, #220]	@ 0xdc
 8004a4c:	2b03      	cmp	r3, #3
 8004a4e:	d871      	bhi.n	8004b34 <HAL_RCCEx_PeriphCLKConfig+0x105c>
 8004a50:	e8df f003 	tbb	[pc, r3]
 8004a54:	4f6a4a4f 	.word	0x4f6a4a4f
    switch (pPeriphClkInit->Spi4ClockSelection)
 8004a58:	2601      	movs	r6, #1
 8004a5a:	4635      	mov	r5, r6
 8004a5c:	e7b3      	b.n	80049c6 <HAL_RCCEx_PeriphCLKConfig+0xeee>
 8004a5e:	bf00      	nop
 8004a60:	44020c00 	.word	0x44020c00
 8004a64:	f5b3 6f00 	cmp.w	r3, #2048	@ 0x800
 8004a68:	d0a1      	beq.n	80049ae <HAL_RCCEx_PeriphCLKConfig+0xed6>
 8004a6a:	f5b3 6f20 	cmp.w	r3, #2560	@ 0xa00
 8004a6e:	d09e      	beq.n	80049ae <HAL_RCCEx_PeriphCLKConfig+0xed6>
 8004a70:	f5b3 6fc0 	cmp.w	r3, #1536	@ 0x600
 8004a74:	d09b      	beq.n	80049ae <HAL_RCCEx_PeriphCLKConfig+0xed6>
 8004a76:	2601      	movs	r6, #1
 8004a78:	4635      	mov	r5, r6
 8004a7a:	e7a4      	b.n	80049c6 <HAL_RCCEx_PeriphCLKConfig+0xeee>
        ret = RCCEx_PLL3_Config(&(pPeriphClkInit->PLL3));
 8004a7c:	f104 0030 	add.w	r0, r4, #48	@ 0x30
 8004a80:	f7fe ffbc 	bl	80039fc <RCCEx_PLL3_Config>
 8004a84:	4605      	mov	r5, r0
        break;
 8004a86:	e792      	b.n	80049ae <HAL_RCCEx_PeriphCLKConfig+0xed6>
      status = ret;
 8004a88:	462e      	mov	r6, r5
 8004a8a:	e79c      	b.n	80049c6 <HAL_RCCEx_PeriphCLKConfig+0xeee>
    switch (pPeriphClkInit->Spi5ClockSelection)
 8004a8c:	2601      	movs	r6, #1
 8004a8e:	4635      	mov	r5, r6
 8004a90:	e7b7      	b.n	8004a02 <HAL_RCCEx_PeriphCLKConfig+0xf2a>
 8004a92:	f5b3 4f80 	cmp.w	r3, #16384	@ 0x4000
 8004a96:	d0a8      	beq.n	80049ea <HAL_RCCEx_PeriphCLKConfig+0xf12>
 8004a98:	f5b3 4fa0 	cmp.w	r3, #20480	@ 0x5000
 8004a9c:	d0a5      	beq.n	80049ea <HAL_RCCEx_PeriphCLKConfig+0xf12>
 8004a9e:	f5b3 5f40 	cmp.w	r3, #12288	@ 0x3000
 8004aa2:	d0a2      	beq.n	80049ea <HAL_RCCEx_PeriphCLKConfig+0xf12>
 8004aa4:	2601      	movs	r6, #1
 8004aa6:	4635      	mov	r5, r6
 8004aa8:	e7ab      	b.n	8004a02 <HAL_RCCEx_PeriphCLKConfig+0xf2a>
        ret = RCCEx_PLL3_Config(&(pPeriphClkInit->PLL3));
 8004aaa:	f104 0030 	add.w	r0, r4, #48	@ 0x30
 8004aae:	f7fe ffa5 	bl	80039fc <RCCEx_PLL3_Config>
 8004ab2:	4605      	mov	r5, r0
        break;
 8004ab4:	e799      	b.n	80049ea <HAL_RCCEx_PeriphCLKConfig+0xf12>
      status = ret;
 8004ab6:	462e      	mov	r6, r5
 8004ab8:	e7a3      	b.n	8004a02 <HAL_RCCEx_PeriphCLKConfig+0xf2a>
    switch (pPeriphClkInit->Spi6ClockSelection)
 8004aba:	2601      	movs	r6, #1
 8004abc:	4635      	mov	r5, r6
 8004abe:	e7bf      	b.n	8004a40 <HAL_RCCEx_PeriphCLKConfig+0xf68>
 8004ac0:	f5b3 3f00 	cmp.w	r3, #131072	@ 0x20000
 8004ac4:	d0b0      	beq.n	8004a28 <HAL_RCCEx_PeriphCLKConfig+0xf50>
 8004ac6:	f5b3 3f20 	cmp.w	r3, #163840	@ 0x28000
 8004aca:	d0ad      	beq.n	8004a28 <HAL_RCCEx_PeriphCLKConfig+0xf50>
 8004acc:	f5b3 3fc0 	cmp.w	r3, #98304	@ 0x18000
 8004ad0:	d0aa      	beq.n	8004a28 <HAL_RCCEx_PeriphCLKConfig+0xf50>
 8004ad2:	2601      	movs	r6, #1
 8004ad4:	4635      	mov	r5, r6
 8004ad6:	e7b3      	b.n	8004a40 <HAL_RCCEx_PeriphCLKConfig+0xf68>
        ret = RCCEx_PLL3_Config(&(pPeriphClkInit->PLL3));
 8004ad8:	f104 0030 	add.w	r0, r4, #48	@ 0x30
 8004adc:	f7fe ff8e 	bl	80039fc <RCCEx_PLL3_Config>
 8004ae0:	4605      	mov	r5, r0
        break;
 8004ae2:	e7a1      	b.n	8004a28 <HAL_RCCEx_PeriphCLKConfig+0xf50>
      status = ret;
 8004ae4:	462e      	mov	r6, r5
 8004ae6:	e7ab      	b.n	8004a40 <HAL_RCCEx_PeriphCLKConfig+0xf68>
        __HAL_RCC_PLL1_CLKOUT_ENABLE(RCC_PLL1_DIVQ);
 8004ae8:	4a3c      	ldr	r2, [pc, #240]	@ (8004bdc <HAL_RCCEx_PeriphCLKConfig+0x1104>)
 8004aea:	6a93      	ldr	r3, [r2, #40]	@ 0x28
 8004aec:	f443 3300 	orr.w	r3, r3, #131072	@ 0x20000
 8004af0:	6293      	str	r3, [r2, #40]	@ 0x28
    if (ret == HAL_OK)
 8004af2:	bb15      	cbnz	r5, 8004b3a <HAL_RCCEx_PeriphCLKConfig+0x1062>
      __HAL_RCC_OSPI_CONFIG(pPeriphClkInit->OspiClockSelection);
 8004af4:	4a39      	ldr	r2, [pc, #228]	@ (8004bdc <HAL_RCCEx_PeriphCLKConfig+0x1104>)
 8004af6:	f8d2 30e4 	ldr.w	r3, [r2, #228]	@ 0xe4
 8004afa:	f023 0303 	bic.w	r3, r3, #3
 8004afe:	f8d4 10dc 	ldr.w	r1, [r4, #220]	@ 0xdc
 8004b02:	430b      	orrs	r3, r1
 8004b04:	f8c2 30e4 	str.w	r3, [r2, #228]	@ 0xe4
  if (((pPeriphClkInit->PeriphClockSelection) & RCC_PERIPHCLK_FDCAN) == RCC_PERIPHCLK_FDCAN)
 8004b08:	6863      	ldr	r3, [r4, #4]
 8004b0a:	f013 0f04 	tst.w	r3, #4
 8004b0e:	d026      	beq.n	8004b5e <HAL_RCCEx_PeriphCLKConfig+0x1086>
    switch (pPeriphClkInit->FdcanClockSelection)
 8004b10:	f8d4 30bc 	ldr.w	r3, [r4, #188]	@ 0xbc
 8004b14:	f5b3 7f80 	cmp.w	r3, #256	@ 0x100
 8004b18:	d011      	beq.n	8004b3e <HAL_RCCEx_PeriphCLKConfig+0x1066>
 8004b1a:	f5b3 7f00 	cmp.w	r3, #512	@ 0x200
 8004b1e:	d03b      	beq.n	8004b98 <HAL_RCCEx_PeriphCLKConfig+0x10c0>
 8004b20:	b193      	cbz	r3, 8004b48 <HAL_RCCEx_PeriphCLKConfig+0x1070>
 8004b22:	2601      	movs	r6, #1
 8004b24:	4635      	mov	r5, r6
 8004b26:	e01a      	b.n	8004b5e <HAL_RCCEx_PeriphCLKConfig+0x1086>
        ret = RCCEx_PLL2_Config(&(pPeriphClkInit->PLL2));
 8004b28:	f104 0008 	add.w	r0, r4, #8
 8004b2c:	f7fe fef8 	bl	8003920 <RCCEx_PLL2_Config>
 8004b30:	4605      	mov	r5, r0
        break;
 8004b32:	e7de      	b.n	8004af2 <HAL_RCCEx_PeriphCLKConfig+0x101a>
    switch (pPeriphClkInit->OspiClockSelection)
 8004b34:	2601      	movs	r6, #1
 8004b36:	4635      	mov	r5, r6
 8004b38:	e7e6      	b.n	8004b08 <HAL_RCCEx_PeriphCLKConfig+0x1030>
      status = ret;
 8004b3a:	462e      	mov	r6, r5
 8004b3c:	e7e4      	b.n	8004b08 <HAL_RCCEx_PeriphCLKConfig+0x1030>
        __HAL_RCC_PLL1_CLKOUT_ENABLE(RCC_PLL1_DIVQ);
 8004b3e:	4a27      	ldr	r2, [pc, #156]	@ (8004bdc <HAL_RCCEx_PeriphCLKConfig+0x1104>)
 8004b40:	6a93      	ldr	r3, [r2, #40]	@ 0x28
 8004b42:	f443 3300 	orr.w	r3, r3, #131072	@ 0x20000
 8004b46:	6293      	str	r3, [r2, #40]	@ 0x28
    if (ret == HAL_OK)
 8004b48:	bb65      	cbnz	r5, 8004ba4 <HAL_RCCEx_PeriphCLKConfig+0x10cc>
      __HAL_RCC_FDCAN_CONFIG(pPeriphClkInit->FdcanClockSelection);
 8004b4a:	4a24      	ldr	r2, [pc, #144]	@ (8004bdc <HAL_RCCEx_PeriphCLKConfig+0x1104>)
 8004b4c:	f8d2 30e8 	ldr.w	r3, [r2, #232]	@ 0xe8
 8004b50:	f423 7340 	bic.w	r3, r3, #768	@ 0x300
 8004b54:	f8d4 10bc 	ldr.w	r1, [r4, #188]	@ 0xbc
 8004b58:	430b      	orrs	r3, r1
 8004b5a:	f8c2 30e8 	str.w	r3, [r2, #232]	@ 0xe8
  if (((pPeriphClkInit->PeriphClockSelection) & RCC_PERIPHCLK_USB) == RCC_PERIPHCLK_USB)
 8004b5e:	6863      	ldr	r3, [r4, #4]
 8004b60:	f013 0f10 	tst.w	r3, #16
 8004b64:	d029      	beq.n	8004bba <HAL_RCCEx_PeriphCLKConfig+0x10e2>
    switch (pPeriphClkInit->UsbClockSelection)
 8004b66:	f8d4 3100 	ldr.w	r3, [r4, #256]	@ 0x100
 8004b6a:	2b20      	cmp	r3, #32
 8004b6c:	d01c      	beq.n	8004ba8 <HAL_RCCEx_PeriphCLKConfig+0x10d0>
 8004b6e:	2b30      	cmp	r3, #48	@ 0x30
 8004b70:	d006      	beq.n	8004b80 <HAL_RCCEx_PeriphCLKConfig+0x10a8>
 8004b72:	2b10      	cmp	r3, #16
 8004b74:	d11e      	bne.n	8004bb4 <HAL_RCCEx_PeriphCLKConfig+0x10dc>
        __HAL_RCC_PLL1_CLKOUT_ENABLE(RCC_PLL1_DIVQ);
 8004b76:	4a19      	ldr	r2, [pc, #100]	@ (8004bdc <HAL_RCCEx_PeriphCLKConfig+0x1104>)
 8004b78:	6a93      	ldr	r3, [r2, #40]	@ 0x28
 8004b7a:	f443 3300 	orr.w	r3, r3, #131072	@ 0x20000
 8004b7e:	6293      	str	r3, [r2, #40]	@ 0x28
    if (ret == HAL_OK)
 8004b80:	b9d5      	cbnz	r5, 8004bb8 <HAL_RCCEx_PeriphCLKConfig+0x10e0>
      __HAL_RCC_USB_CONFIG(pPeriphClkInit->UsbClockSelection);
 8004b82:	4a16      	ldr	r2, [pc, #88]	@ (8004bdc <HAL_RCCEx_PeriphCLKConfig+0x1104>)
 8004b84:	f8d2 30e4 	ldr.w	r3, [r2, #228]	@ 0xe4
 8004b88:	f023 0330 	bic.w	r3, r3, #48	@ 0x30
 8004b8c:	f8d4 1100 	ldr.w	r1, [r4, #256]	@ 0x100
 8004b90:	430b      	orrs	r3, r1
 8004b92:	f8c2 30e4 	str.w	r3, [r2, #228]	@ 0xe4
 8004b96:	e010      	b.n	8004bba <HAL_RCCEx_PeriphCLKConfig+0x10e2>
        ret = RCCEx_PLL2_Config(&(pPeriphClkInit->PLL2));
 8004b98:	f104 0008 	add.w	r0, r4, #8
 8004b9c:	f7fe fec0 	bl	8003920 <RCCEx_PLL2_Config>
 8004ba0:	4605      	mov	r5, r0
        break;
 8004ba2:	e7d1      	b.n	8004b48 <HAL_RCCEx_PeriphCLKConfig+0x1070>
      status = ret;
 8004ba4:	462e      	mov	r6, r5
 8004ba6:	e7da      	b.n	8004b5e <HAL_RCCEx_PeriphCLKConfig+0x1086>
        ret = RCCEx_PLL3_Config(&(pPeriphClkInit->PLL3));
 8004ba8:	f104 0030 	add.w	r0, r4, #48	@ 0x30
 8004bac:	f7fe ff26 	bl	80039fc <RCCEx_PLL3_Config>
 8004bb0:	4605      	mov	r5, r0
        break;
 8004bb2:	e7e5      	b.n	8004b80 <HAL_RCCEx_PeriphCLKConfig+0x10a8>
    switch (pPeriphClkInit->UsbClockSelection)
 8004bb4:	2601      	movs	r6, #1
 8004bb6:	e000      	b.n	8004bba <HAL_RCCEx_PeriphCLKConfig+0x10e2>
      status = ret;
 8004bb8:	462e      	mov	r6, r5
  if (((pPeriphClkInit->PeriphClockSelection) & RCC_PERIPHCLK_CEC) == RCC_PERIPHCLK_CEC)
 8004bba:	6863      	ldr	r3, [r4, #4]
 8004bbc:	f013 0f08 	tst.w	r3, #8
 8004bc0:	d009      	beq.n	8004bd6 <HAL_RCCEx_PeriphCLKConfig+0x10fe>
    __HAL_RCC_CEC_CONFIG(pPeriphClkInit->CecClockSelection);
 8004bc2:	4a06      	ldr	r2, [pc, #24]	@ (8004bdc <HAL_RCCEx_PeriphCLKConfig+0x1104>)
 8004bc4:	f8d2 30e8 	ldr.w	r3, [r2, #232]	@ 0xe8
 8004bc8:	f023 03c0 	bic.w	r3, r3, #192	@ 0xc0
 8004bcc:	f8d4 10fc 	ldr.w	r1, [r4, #252]	@ 0xfc
 8004bd0:	430b      	orrs	r3, r1
 8004bd2:	f8c2 30e8 	str.w	r3, [r2, #232]	@ 0xe8
}
 8004bd6:	4630      	mov	r0, r6
 8004bd8:	bdf8      	pop	{r3, r4, r5, r6, r7, pc}
 8004bda:	bf00      	nop
 8004bdc:	44020c00 	.word	0x44020c00

08004be0 <HAL_RCCEx_GetPLL1ClockFreq>:
{
 8004be0:	b530      	push	{r4, r5, lr}
  pll1n = (RCC->PLL1DIVR & RCC_PLL1DIVR_PLL1N);
 8004be2:	4980      	ldr	r1, [pc, #512]	@ (8004de4 <HAL_RCCEx_GetPLL1ClockFreq+0x204>)
 8004be4:	6b4a      	ldr	r2, [r1, #52]	@ 0x34
 8004be6:	f3c2 0208 	ubfx	r2, r2, #0, #9
  pll1source = (RCC->PLL1CFGR & RCC_PLL1CFGR_PLL1SRC);
 8004bea:	6a8b      	ldr	r3, [r1, #40]	@ 0x28
 8004bec:	f003 0c03 	and.w	ip, r3, #3
  pll1m = ((RCC->PLL1CFGR & RCC_PLL1CFGR_PLL1M) >> RCC_PLL1CFGR_PLL1M_Pos);
 8004bf0:	6a8c      	ldr	r4, [r1, #40]	@ 0x28
 8004bf2:	f3c4 2505 	ubfx	r5, r4, #8, #6
  pll1fracen = ((RCC->PLL1CFGR & RCC_PLL1CFGR_PLL1FRACEN) >> RCC_PLL1CFGR_PLL1FRACEN_Pos);
 8004bf6:	6a8b      	ldr	r3, [r1, #40]	@ 0x28
 8004bf8:	f3c3 1e00 	ubfx	lr, r3, #4, #1
  fracn1 = (float_t)(uint32_t)(pll1fracen * ((RCC->PLL1FRACR & RCC_PLL1FRACR_PLL1FRACN) >> \
 8004bfc:	6b8b      	ldr	r3, [r1, #56]	@ 0x38
 8004bfe:	f3c3 03cc 	ubfx	r3, r3, #3, #13
 8004c02:	fb0e f303 	mul.w	r3, lr, r3
  if (pll1m != 0U)
 8004c06:	f414 5f7c 	tst.w	r4, #16128	@ 0x3f00
 8004c0a:	f000 80e6 	beq.w	8004dda <HAL_RCCEx_GetPLL1ClockFreq+0x1fa>
 8004c0e:	ee07 3a90 	vmov	s15, r3
 8004c12:	eef8 7a67 	vcvt.f32.u32	s15, s15
    switch (pll1source)
 8004c16:	f1bc 0f02 	cmp.w	ip, #2
 8004c1a:	d041      	beq.n	8004ca0 <HAL_RCCEx_GetPLL1ClockFreq+0xc0>
 8004c1c:	f1bc 0f03 	cmp.w	ip, #3
 8004c20:	d057      	beq.n	8004cd2 <HAL_RCCEx_GetPLL1ClockFreq+0xf2>
 8004c22:	f1bc 0f01 	cmp.w	ip, #1
 8004c26:	d16d      	bne.n	8004d04 <HAL_RCCEx_GetPLL1ClockFreq+0x124>
        hsivalue = (HSI_VALUE >> (__HAL_RCC_GET_HSI_DIVIDER() >> RCC_CR_HSIDIV_Pos));
 8004c28:	6809      	ldr	r1, [r1, #0]
 8004c2a:	f3c1 01c1 	ubfx	r1, r1, #3, #2
 8004c2e:	4b6e      	ldr	r3, [pc, #440]	@ (8004de8 <HAL_RCCEx_GetPLL1ClockFreq+0x208>)
 8004c30:	40cb      	lsrs	r3, r1
        pll1vco = ((float_t)hsivalue / (float_t)pll1m) * ((float_t)(uint32_t)pll1n + (fracn1 / (float_t)0x2000) + \
 8004c32:	ee07 3a10 	vmov	s14, r3
 8004c36:	eeb8 6a47 	vcvt.f32.u32	s12, s14
 8004c3a:	ee07 5a10 	vmov	s14, r5
 8004c3e:	eeb8 7a47 	vcvt.f32.u32	s14, s14
 8004c42:	eec6 6a07 	vdiv.f32	s13, s12, s14
 8004c46:	ee07 2a10 	vmov	s14, r2
 8004c4a:	eeb8 7a47 	vcvt.f32.u32	s14, s14
 8004c4e:	ed9f 6a67 	vldr	s12, [pc, #412]	@ 8004dec <HAL_RCCEx_GetPLL1ClockFreq+0x20c>
 8004c52:	ee67 7a86 	vmul.f32	s15, s15, s12
 8004c56:	ee77 7a27 	vadd.f32	s15, s14, s15
 8004c5a:	eeb7 7a00 	vmov.f32	s14, #112	@ 0x3f800000  1.0
 8004c5e:	ee77 7a87 	vadd.f32	s15, s15, s14
 8004c62:	ee66 7aa7 	vmul.f32	s15, s13, s15
    if (HAL_IS_BIT_SET(RCC->CR, RCC_CR_PLL1RDY))
 8004c66:	4b5f      	ldr	r3, [pc, #380]	@ (8004de4 <HAL_RCCEx_GetPLL1ClockFreq+0x204>)
 8004c68:	681b      	ldr	r3, [r3, #0]
 8004c6a:	f013 7f00 	tst.w	r3, #33554432	@ 0x2000000
 8004c6e:	d06d      	beq.n	8004d4c <HAL_RCCEx_GetPLL1ClockFreq+0x16c>
      if (__HAL_RCC_GET_PLL1_CLKOUT_CONFIG(RCC_PLL1_DIVP) != 0U)
 8004c70:	4b5c      	ldr	r3, [pc, #368]	@ (8004de4 <HAL_RCCEx_GetPLL1ClockFreq+0x204>)
 8004c72:	6a9b      	ldr	r3, [r3, #40]	@ 0x28
 8004c74:	f413 3f80 	tst.w	r3, #65536	@ 0x10000
 8004c78:	d065      	beq.n	8004d46 <HAL_RCCEx_GetPLL1ClockFreq+0x166>
                                                             ((float_t)(uint32_t)((RCC->PLL1DIVR & \
 8004c7a:	4b5a      	ldr	r3, [pc, #360]	@ (8004de4 <HAL_RCCEx_GetPLL1ClockFreq+0x204>)
 8004c7c:	6b5b      	ldr	r3, [r3, #52]	@ 0x34
 8004c7e:	f3c3 2346 	ubfx	r3, r3, #9, #7
 8004c82:	ee07 3a10 	vmov	s14, r3
 8004c86:	eeb8 7a47 	vcvt.f32.u32	s14, s14
                                                                                  RCC_PLL1DIVR_PLL1P_Pos) + \
 8004c8a:	eef7 6a00 	vmov.f32	s13, #112	@ 0x3f800000  1.0
 8004c8e:	ee37 7a26 	vadd.f32	s14, s14, s13
                                         (uint32_t)(float_t)(pll1vco / \
 8004c92:	eec7 6a87 	vdiv.f32	s13, s15, s14
 8004c96:	eefc 6ae6 	vcvt.u32.f32	s13, s13
        pPLL1_Clocks->PLL1_P_Frequency = \
 8004c9a:	edc0 6a00 	vstr	s13, [r0]
 8004c9e:	e057      	b.n	8004d50 <HAL_RCCEx_GetPLL1ClockFreq+0x170>
        pll1vco = ((float_t)CSI_VALUE / (float_t)pll1m) * ((float_t)(uint32_t)pll1n + (fracn1 / (float_t)0x2000) + \
 8004ca0:	ee07 5a10 	vmov	s14, r5
 8004ca4:	eeb8 7a47 	vcvt.f32.u32	s14, s14
 8004ca8:	ed9f 6a51 	vldr	s12, [pc, #324]	@ 8004df0 <HAL_RCCEx_GetPLL1ClockFreq+0x210>
 8004cac:	eec6 6a07 	vdiv.f32	s13, s12, s14
 8004cb0:	ee07 2a10 	vmov	s14, r2
 8004cb4:	eeb8 7a47 	vcvt.f32.u32	s14, s14
 8004cb8:	ed9f 6a4c 	vldr	s12, [pc, #304]	@ 8004dec <HAL_RCCEx_GetPLL1ClockFreq+0x20c>
 8004cbc:	ee67 7a86 	vmul.f32	s15, s15, s12
 8004cc0:	ee77 7a27 	vadd.f32	s15, s14, s15
 8004cc4:	eeb7 7a00 	vmov.f32	s14, #112	@ 0x3f800000  1.0
 8004cc8:	ee77 7a87 	vadd.f32	s15, s15, s14
 8004ccc:	ee66 7aa7 	vmul.f32	s15, s13, s15
        break;
 8004cd0:	e7c9      	b.n	8004c66 <HAL_RCCEx_GetPLL1ClockFreq+0x86>
        pll1vco = ((float_t)HSE_VALUE / (float_t)pll1m) * ((float_t)(uint32_t)pll1n + (fracn1 / (float_t)0x2000) + \
 8004cd2:	ee07 5a10 	vmov	s14, r5
 8004cd6:	eeb8 7a47 	vcvt.f32.u32	s14, s14
 8004cda:	ed9f 6a46 	vldr	s12, [pc, #280]	@ 8004df4 <HAL_RCCEx_GetPLL1ClockFreq+0x214>
 8004cde:	eec6 6a07 	vdiv.f32	s13, s12, s14
 8004ce2:	ee07 2a10 	vmov	s14, r2
 8004ce6:	eeb8 7a47 	vcvt.f32.u32	s14, s14
 8004cea:	ed9f 6a40 	vldr	s12, [pc, #256]	@ 8004dec <HAL_RCCEx_GetPLL1ClockFreq+0x20c>
 8004cee:	ee67 7a86 	vmul.f32	s15, s15, s12
 8004cf2:	ee77 7a27 	vadd.f32	s15, s14, s15
 8004cf6:	eeb7 7a00 	vmov.f32	s14, #112	@ 0x3f800000  1.0
 8004cfa:	ee77 7a87 	vadd.f32	s15, s15, s14
 8004cfe:	ee66 7aa7 	vmul.f32	s15, s13, s15
        break;
 8004d02:	e7b0      	b.n	8004c66 <HAL_RCCEx_GetPLL1ClockFreq+0x86>
        hsivalue = (HSI_VALUE >> (__HAL_RCC_GET_HSI_DIVIDER() >> RCC_CR_HSIDIV_Pos));
 8004d04:	4b37      	ldr	r3, [pc, #220]	@ (8004de4 <HAL_RCCEx_GetPLL1ClockFreq+0x204>)
 8004d06:	6819      	ldr	r1, [r3, #0]
 8004d08:	f3c1 01c1 	ubfx	r1, r1, #3, #2
 8004d0c:	4b36      	ldr	r3, [pc, #216]	@ (8004de8 <HAL_RCCEx_GetPLL1ClockFreq+0x208>)
 8004d0e:	40cb      	lsrs	r3, r1
        pll1vco = ((float_t)hsivalue / (float_t)pll1m) * ((float_t)(uint32_t)pll1n + (fracn1 / (float_t)0x2000) + \
 8004d10:	ee07 3a10 	vmov	s14, r3
 8004d14:	eeb8 6a47 	vcvt.f32.u32	s12, s14
 8004d18:	ee07 5a10 	vmov	s14, r5
 8004d1c:	eeb8 7a47 	vcvt.f32.u32	s14, s14
 8004d20:	eec6 6a07 	vdiv.f32	s13, s12, s14
 8004d24:	ee07 2a10 	vmov	s14, r2
 8004d28:	eeb8 7a47 	vcvt.f32.u32	s14, s14
 8004d2c:	ed9f 6a2f 	vldr	s12, [pc, #188]	@ 8004dec <HAL_RCCEx_GetPLL1ClockFreq+0x20c>
 8004d30:	ee67 7a86 	vmul.f32	s15, s15, s12
 8004d34:	ee77 7a27 	vadd.f32	s15, s14, s15
 8004d38:	eeb7 7a00 	vmov.f32	s14, #112	@ 0x3f800000  1.0
 8004d3c:	ee77 7a87 	vadd.f32	s15, s15, s14
 8004d40:	ee66 7aa7 	vmul.f32	s15, s13, s15
        break;
 8004d44:	e78f      	b.n	8004c66 <HAL_RCCEx_GetPLL1ClockFreq+0x86>
        pPLL1_Clocks->PLL1_P_Frequency = 0U;
 8004d46:	2300      	movs	r3, #0
 8004d48:	6003      	str	r3, [r0, #0]
 8004d4a:	e001      	b.n	8004d50 <HAL_RCCEx_GetPLL1ClockFreq+0x170>
      pPLL1_Clocks->PLL1_P_Frequency = 0U;
 8004d4c:	2300      	movs	r3, #0
 8004d4e:	6003      	str	r3, [r0, #0]
    if (HAL_IS_BIT_SET(RCC->CR, RCC_CR_PLL1RDY))
 8004d50:	4b24      	ldr	r3, [pc, #144]	@ (8004de4 <HAL_RCCEx_GetPLL1ClockFreq+0x204>)
 8004d52:	681b      	ldr	r3, [r3, #0]
 8004d54:	f013 7f00 	tst.w	r3, #33554432	@ 0x2000000
 8004d58:	d01a      	beq.n	8004d90 <HAL_RCCEx_GetPLL1ClockFreq+0x1b0>
      if (__HAL_RCC_GET_PLL1_CLKOUT_CONFIG(RCC_PLL1_DIVQ) != 0U)
 8004d5a:	4b22      	ldr	r3, [pc, #136]	@ (8004de4 <HAL_RCCEx_GetPLL1ClockFreq+0x204>)
 8004d5c:	6a9b      	ldr	r3, [r3, #40]	@ 0x28
 8004d5e:	f413 3f00 	tst.w	r3, #131072	@ 0x20000
 8004d62:	d012      	beq.n	8004d8a <HAL_RCCEx_GetPLL1ClockFreq+0x1aa>
                                                             ((float_t)(uint32_t)((RCC->PLL1DIVR & \
 8004d64:	4b1f      	ldr	r3, [pc, #124]	@ (8004de4 <HAL_RCCEx_GetPLL1ClockFreq+0x204>)
 8004d66:	6b5b      	ldr	r3, [r3, #52]	@ 0x34
 8004d68:	f3c3 4306 	ubfx	r3, r3, #16, #7
 8004d6c:	ee07 3a10 	vmov	s14, r3
 8004d70:	eeb8 7a47 	vcvt.f32.u32	s14, s14
                                                                                  RCC_PLL1DIVR_PLL1Q_Pos) + \
 8004d74:	eef7 6a00 	vmov.f32	s13, #112	@ 0x3f800000  1.0
 8004d78:	ee37 7a26 	vadd.f32	s14, s14, s13
                                         (uint32_t)(float_t)(pll1vco / \
 8004d7c:	eec7 6a87 	vdiv.f32	s13, s15, s14
 8004d80:	eefc 6ae6 	vcvt.u32.f32	s13, s13
        pPLL1_Clocks->PLL1_Q_Frequency = \
 8004d84:	edc0 6a01 	vstr	s13, [r0, #4]
 8004d88:	e004      	b.n	8004d94 <HAL_RCCEx_GetPLL1ClockFreq+0x1b4>
        pPLL1_Clocks->PLL1_Q_Frequency = 0U;
 8004d8a:	2300      	movs	r3, #0
 8004d8c:	6043      	str	r3, [r0, #4]
 8004d8e:	e001      	b.n	8004d94 <HAL_RCCEx_GetPLL1ClockFreq+0x1b4>
      pPLL1_Clocks->PLL1_Q_Frequency = 0U;
 8004d90:	2300      	movs	r3, #0
 8004d92:	6043      	str	r3, [r0, #4]
    if (HAL_IS_BIT_SET(RCC->CR, RCC_CR_PLL1RDY))
 8004d94:	4b13      	ldr	r3, [pc, #76]	@ (8004de4 <HAL_RCCEx_GetPLL1ClockFreq+0x204>)
 8004d96:	681b      	ldr	r3, [r3, #0]
 8004d98:	f013 7f00 	tst.w	r3, #33554432	@ 0x2000000
 8004d9c:	d01a      	beq.n	8004dd4 <HAL_RCCEx_GetPLL1ClockFreq+0x1f4>
      if (__HAL_RCC_GET_PLL1_CLKOUT_CONFIG(RCC_PLL1_DIVR) != 0U)
 8004d9e:	4b11      	ldr	r3, [pc, #68]	@ (8004de4 <HAL_RCCEx_GetPLL1ClockFreq+0x204>)
 8004da0:	6a9b      	ldr	r3, [r3, #40]	@ 0x28
 8004da2:	f413 2f80 	tst.w	r3, #262144	@ 0x40000
 8004da6:	d012      	beq.n	8004dce <HAL_RCCEx_GetPLL1ClockFreq+0x1ee>
                                                             ((float_t)(uint32_t)((RCC->PLL1DIVR & \
 8004da8:	4b0e      	ldr	r3, [pc, #56]	@ (8004de4 <HAL_RCCEx_GetPLL1ClockFreq+0x204>)
 8004daa:	6b5b      	ldr	r3, [r3, #52]	@ 0x34
 8004dac:	f3c3 6306 	ubfx	r3, r3, #24, #7
 8004db0:	ee07 3a10 	vmov	s14, r3
 8004db4:	eeb8 7a47 	vcvt.f32.u32	s14, s14
                                                                                  RCC_PLL1DIVR_PLL1R_Pos) + \
 8004db8:	eef7 6a00 	vmov.f32	s13, #112	@ 0x3f800000  1.0
 8004dbc:	ee37 7a26 	vadd.f32	s14, s14, s13
                                         (uint32_t)(float_t)(pll1vco / \
 8004dc0:	eec7 6a87 	vdiv.f32	s13, s15, s14
 8004dc4:	eefc 6ae6 	vcvt.u32.f32	s13, s13
        pPLL1_Clocks->PLL1_R_Frequency = \
 8004dc8:	edc0 6a02 	vstr	s13, [r0, #8]
 8004dcc:	e009      	b.n	8004de2 <HAL_RCCEx_GetPLL1ClockFreq+0x202>
        pPLL1_Clocks->PLL1_R_Frequency = 0U;
 8004dce:	2300      	movs	r3, #0
 8004dd0:	6083      	str	r3, [r0, #8]
 8004dd2:	e006      	b.n	8004de2 <HAL_RCCEx_GetPLL1ClockFreq+0x202>
      pPLL1_Clocks->PLL1_R_Frequency = 0U;
 8004dd4:	2300      	movs	r3, #0
 8004dd6:	6083      	str	r3, [r0, #8]
 8004dd8:	e003      	b.n	8004de2 <HAL_RCCEx_GetPLL1ClockFreq+0x202>
    pPLL1_Clocks->PLL1_P_Frequency = 0U;
 8004dda:	2300      	movs	r3, #0
 8004ddc:	6003      	str	r3, [r0, #0]
    pPLL1_Clocks->PLL1_Q_Frequency = 0U;
 8004dde:	6043      	str	r3, [r0, #4]
    pPLL1_Clocks->PLL1_R_Frequency = 0U;
 8004de0:	6083      	str	r3, [r0, #8]
}
 8004de2:	bd30      	pop	{r4, r5, pc}
 8004de4:	44020c00 	.word	0x44020c00
 8004de8:	03d09000 	.word	0x03d09000
 8004dec:	39000000 	.word	0x39000000
 8004df0:	4a742400 	.word	0x4a742400
 8004df4:	4bbebc20 	.word	0x4bbebc20

08004df8 <HAL_RCCEx_GetPLL2ClockFreq>:
{
 8004df8:	b530      	push	{r4, r5, lr}
  pll2n = (RCC->PLL2DIVR & RCC_PLL2DIVR_PLL2N);
 8004dfa:	4980      	ldr	r1, [pc, #512]	@ (8004ffc <HAL_RCCEx_GetPLL2ClockFreq+0x204>)
 8004dfc:	6bca      	ldr	r2, [r1, #60]	@ 0x3c
 8004dfe:	f3c2 0208 	ubfx	r2, r2, #0, #9
  pll2source = (RCC->PLL2CFGR & RCC_PLL2CFGR_PLL2SRC);
 8004e02:	6acb      	ldr	r3, [r1, #44]	@ 0x2c
 8004e04:	f003 0c03 	and.w	ip, r3, #3
  pll2m = ((RCC->PLL2CFGR & RCC_PLL2CFGR_PLL2M) >> RCC_PLL2CFGR_PLL2M_Pos);
 8004e08:	6acc      	ldr	r4, [r1, #44]	@ 0x2c
 8004e0a:	f3c4 2505 	ubfx	r5, r4, #8, #6
  pll2fracen = ((RCC->PLL2CFGR & RCC_PLL2CFGR_PLL2FRACEN) >> RCC_PLL2CFGR_PLL2FRACEN_Pos);
 8004e0e:	6acb      	ldr	r3, [r1, #44]	@ 0x2c
 8004e10:	f3c3 1e00 	ubfx	lr, r3, #4, #1
  fracn2 = (float_t)(uint32_t)(pll2fracen * ((RCC->PLL2FRACR & RCC_PLL2FRACR_PLL2FRACN) >> \
 8004e14:	6c0b      	ldr	r3, [r1, #64]	@ 0x40
 8004e16:	f3c3 03cc 	ubfx	r3, r3, #3, #13
 8004e1a:	fb0e f303 	mul.w	r3, lr, r3
  if (pll2m != 0U)
 8004e1e:	f414 5f7c 	tst.w	r4, #16128	@ 0x3f00
 8004e22:	f000 80e6 	beq.w	8004ff2 <HAL_RCCEx_GetPLL2ClockFreq+0x1fa>
 8004e26:	ee07 3a90 	vmov	s15, r3
 8004e2a:	eef8 7a67 	vcvt.f32.u32	s15, s15
    switch (pll2source)
 8004e2e:	f1bc 0f02 	cmp.w	ip, #2
 8004e32:	d041      	beq.n	8004eb8 <HAL_RCCEx_GetPLL2ClockFreq+0xc0>
 8004e34:	f1bc 0f03 	cmp.w	ip, #3
 8004e38:	d057      	beq.n	8004eea <HAL_RCCEx_GetPLL2ClockFreq+0xf2>
 8004e3a:	f1bc 0f01 	cmp.w	ip, #1
 8004e3e:	d16d      	bne.n	8004f1c <HAL_RCCEx_GetPLL2ClockFreq+0x124>
        hsivalue = (HSI_VALUE >> (__HAL_RCC_GET_HSI_DIVIDER() >> RCC_CR_HSIDIV_Pos));
 8004e40:	6809      	ldr	r1, [r1, #0]
 8004e42:	f3c1 01c1 	ubfx	r1, r1, #3, #2
 8004e46:	4b6e      	ldr	r3, [pc, #440]	@ (8005000 <HAL_RCCEx_GetPLL2ClockFreq+0x208>)
 8004e48:	40cb      	lsrs	r3, r1
        pll2vco = ((float_t)hsivalue / (float_t)pll2m) * ((float_t)(uint32_t)pll2n + (fracn2 / (float_t)0x2000) + \
 8004e4a:	ee07 3a10 	vmov	s14, r3
 8004e4e:	eeb8 6a47 	vcvt.f32.u32	s12, s14
 8004e52:	ee07 5a10 	vmov	s14, r5
 8004e56:	eeb8 7a47 	vcvt.f32.u32	s14, s14
 8004e5a:	eec6 6a07 	vdiv.f32	s13, s12, s14
 8004e5e:	ee07 2a10 	vmov	s14, r2
 8004e62:	eeb8 7a47 	vcvt.f32.u32	s14, s14
 8004e66:	ed9f 6a67 	vldr	s12, [pc, #412]	@ 8005004 <HAL_RCCEx_GetPLL2ClockFreq+0x20c>
 8004e6a:	ee67 7a86 	vmul.f32	s15, s15, s12
 8004e6e:	ee77 7a27 	vadd.f32	s15, s14, s15
 8004e72:	eeb7 7a00 	vmov.f32	s14, #112	@ 0x3f800000  1.0
 8004e76:	ee77 7a87 	vadd.f32	s15, s15, s14
 8004e7a:	ee66 7aa7 	vmul.f32	s15, s13, s15
    if (HAL_IS_BIT_SET(RCC->CR, RCC_CR_PLL2RDY))
 8004e7e:	4b5f      	ldr	r3, [pc, #380]	@ (8004ffc <HAL_RCCEx_GetPLL2ClockFreq+0x204>)
 8004e80:	681b      	ldr	r3, [r3, #0]
 8004e82:	f013 6f00 	tst.w	r3, #134217728	@ 0x8000000
 8004e86:	d06d      	beq.n	8004f64 <HAL_RCCEx_GetPLL2ClockFreq+0x16c>
      if (__HAL_RCC_GET_PLL2_CLKOUT_CONFIG(RCC_PLL2_DIVP) != 0U)
 8004e88:	4b5c      	ldr	r3, [pc, #368]	@ (8004ffc <HAL_RCCEx_GetPLL2ClockFreq+0x204>)
 8004e8a:	6adb      	ldr	r3, [r3, #44]	@ 0x2c
 8004e8c:	f413 3f80 	tst.w	r3, #65536	@ 0x10000
 8004e90:	d065      	beq.n	8004f5e <HAL_RCCEx_GetPLL2ClockFreq+0x166>
                                                             ((float_t)(uint32_t)((RCC->PLL2DIVR & \
 8004e92:	4b5a      	ldr	r3, [pc, #360]	@ (8004ffc <HAL_RCCEx_GetPLL2ClockFreq+0x204>)
 8004e94:	6bdb      	ldr	r3, [r3, #60]	@ 0x3c
 8004e96:	f3c3 2346 	ubfx	r3, r3, #9, #7
 8004e9a:	ee07 3a10 	vmov	s14, r3
 8004e9e:	eeb8 7a47 	vcvt.f32.u32	s14, s14
                                                                                  RCC_PLL2DIVR_PLL2P_Pos) + \
 8004ea2:	eef7 6a00 	vmov.f32	s13, #112	@ 0x3f800000  1.0
 8004ea6:	ee37 7a26 	vadd.f32	s14, s14, s13
                                         (uint32_t)(float_t)(pll2vco / \
 8004eaa:	eec7 6a87 	vdiv.f32	s13, s15, s14
 8004eae:	eefc 6ae6 	vcvt.u32.f32	s13, s13
        pPLL2_Clocks->PLL2_P_Frequency = \
 8004eb2:	edc0 6a00 	vstr	s13, [r0]
 8004eb6:	e057      	b.n	8004f68 <HAL_RCCEx_GetPLL2ClockFreq+0x170>
        pll2vco = ((float_t)CSI_VALUE / (float_t)pll2m) * ((float_t)(uint32_t)pll2n + (fracn2 / (float_t)0x2000) + \
 8004eb8:	ee07 5a10 	vmov	s14, r5
 8004ebc:	eeb8 7a47 	vcvt.f32.u32	s14, s14
 8004ec0:	ed9f 6a51 	vldr	s12, [pc, #324]	@ 8005008 <HAL_RCCEx_GetPLL2ClockFreq+0x210>
 8004ec4:	eec6 6a07 	vdiv.f32	s13, s12, s14
 8004ec8:	ee07 2a10 	vmov	s14, r2
 8004ecc:	eeb8 7a47 	vcvt.f32.u32	s14, s14
 8004ed0:	ed9f 6a4c 	vldr	s12, [pc, #304]	@ 8005004 <HAL_RCCEx_GetPLL2ClockFreq+0x20c>
 8004ed4:	ee67 7a86 	vmul.f32	s15, s15, s12
 8004ed8:	ee77 7a27 	vadd.f32	s15, s14, s15
 8004edc:	eeb7 7a00 	vmov.f32	s14, #112	@ 0x3f800000  1.0
 8004ee0:	ee77 7a87 	vadd.f32	s15, s15, s14
 8004ee4:	ee66 7aa7 	vmul.f32	s15, s13, s15
        break;
 8004ee8:	e7c9      	b.n	8004e7e <HAL_RCCEx_GetPLL2ClockFreq+0x86>
        pll2vco = ((float_t)HSE_VALUE / (float_t)pll2m) * ((float_t)(uint32_t)pll2n + (fracn2 / (float_t)0x2000) + \
 8004eea:	ee07 5a10 	vmov	s14, r5
 8004eee:	eeb8 7a47 	vcvt.f32.u32	s14, s14
 8004ef2:	ed9f 6a46 	vldr	s12, [pc, #280]	@ 800500c <HAL_RCCEx_GetPLL2ClockFreq+0x214>
 8004ef6:	eec6 6a07 	vdiv.f32	s13, s12, s14
 8004efa:	ee07 2a10 	vmov	s14, r2
 8004efe:	eeb8 7a47 	vcvt.f32.u32	s14, s14
 8004f02:	ed9f 6a40 	vldr	s12, [pc, #256]	@ 8005004 <HAL_RCCEx_GetPLL2ClockFreq+0x20c>
 8004f06:	ee67 7a86 	vmul.f32	s15, s15, s12
 8004f0a:	ee77 7a27 	vadd.f32	s15, s14, s15
 8004f0e:	eeb7 7a00 	vmov.f32	s14, #112	@ 0x3f800000  1.0
 8004f12:	ee77 7a87 	vadd.f32	s15, s15, s14
 8004f16:	ee66 7aa7 	vmul.f32	s15, s13, s15
        break;
 8004f1a:	e7b0      	b.n	8004e7e <HAL_RCCEx_GetPLL2ClockFreq+0x86>
        hsivalue = (HSI_VALUE >> (__HAL_RCC_GET_HSI_DIVIDER() >> RCC_CR_HSIDIV_Pos));
 8004f1c:	4b37      	ldr	r3, [pc, #220]	@ (8004ffc <HAL_RCCEx_GetPLL2ClockFreq+0x204>)
 8004f1e:	6819      	ldr	r1, [r3, #0]
 8004f20:	f3c1 01c1 	ubfx	r1, r1, #3, #2
 8004f24:	4b36      	ldr	r3, [pc, #216]	@ (8005000 <HAL_RCCEx_GetPLL2ClockFreq+0x208>)
 8004f26:	40cb      	lsrs	r3, r1
        pll2vco = ((float_t)hsivalue / (float_t)pll2m) * ((float_t)(uint32_t)pll2n + (fracn2 / (float_t)0x2000) + \
 8004f28:	ee07 3a10 	vmov	s14, r3
 8004f2c:	eeb8 6a47 	vcvt.f32.u32	s12, s14
 8004f30:	ee07 5a10 	vmov	s14, r5
 8004f34:	eeb8 7a47 	vcvt.f32.u32	s14, s14
 8004f38:	eec6 6a07 	vdiv.f32	s13, s12, s14
 8004f3c:	ee07 2a10 	vmov	s14, r2
 8004f40:	eeb8 7a47 	vcvt.f32.u32	s14, s14
 8004f44:	ed9f 6a2f 	vldr	s12, [pc, #188]	@ 8005004 <HAL_RCCEx_GetPLL2ClockFreq+0x20c>
 8004f48:	ee67 7a86 	vmul.f32	s15, s15, s12
 8004f4c:	ee77 7a27 	vadd.f32	s15, s14, s15
 8004f50:	eeb7 7a00 	vmov.f32	s14, #112	@ 0x3f800000  1.0
 8004f54:	ee77 7a87 	vadd.f32	s15, s15, s14
 8004f58:	ee66 7aa7 	vmul.f32	s15, s13, s15
        break;
 8004f5c:	e78f      	b.n	8004e7e <HAL_RCCEx_GetPLL2ClockFreq+0x86>
        pPLL2_Clocks->PLL2_P_Frequency = 0U;
 8004f5e:	2300      	movs	r3, #0
 8004f60:	6003      	str	r3, [r0, #0]
 8004f62:	e001      	b.n	8004f68 <HAL_RCCEx_GetPLL2ClockFreq+0x170>
      pPLL2_Clocks->PLL2_P_Frequency = 0U;
 8004f64:	2300      	movs	r3, #0
 8004f66:	6003      	str	r3, [r0, #0]
    if (HAL_IS_BIT_SET(RCC->CR, RCC_CR_PLL2RDY))
 8004f68:	4b24      	ldr	r3, [pc, #144]	@ (8004ffc <HAL_RCCEx_GetPLL2ClockFreq+0x204>)
 8004f6a:	681b      	ldr	r3, [r3, #0]
 8004f6c:	f013 6f00 	tst.w	r3, #134217728	@ 0x8000000
 8004f70:	d01a      	beq.n	8004fa8 <HAL_RCCEx_GetPLL2ClockFreq+0x1b0>
      if (__HAL_RCC_GET_PLL2_CLKOUT_CONFIG(RCC_PLL2_DIVQ) != 0U)
 8004f72:	4b22      	ldr	r3, [pc, #136]	@ (8004ffc <HAL_RCCEx_GetPLL2ClockFreq+0x204>)
 8004f74:	6adb      	ldr	r3, [r3, #44]	@ 0x2c
 8004f76:	f413 3f00 	tst.w	r3, #131072	@ 0x20000
 8004f7a:	d012      	beq.n	8004fa2 <HAL_RCCEx_GetPLL2ClockFreq+0x1aa>
                                                             ((float_t)(uint32_t)((RCC->PLL2DIVR & \
 8004f7c:	4b1f      	ldr	r3, [pc, #124]	@ (8004ffc <HAL_RCCEx_GetPLL2ClockFreq+0x204>)
 8004f7e:	6bdb      	ldr	r3, [r3, #60]	@ 0x3c
 8004f80:	f3c3 4306 	ubfx	r3, r3, #16, #7
 8004f84:	ee07 3a10 	vmov	s14, r3
 8004f88:	eeb8 7a47 	vcvt.f32.u32	s14, s14
                                                                                  RCC_PLL2DIVR_PLL2Q_Pos) + \
 8004f8c:	eef7 6a00 	vmov.f32	s13, #112	@ 0x3f800000  1.0
 8004f90:	ee37 7a26 	vadd.f32	s14, s14, s13
                                         (uint32_t)(float_t)(pll2vco / \
 8004f94:	eec7 6a87 	vdiv.f32	s13, s15, s14
 8004f98:	eefc 6ae6 	vcvt.u32.f32	s13, s13
        pPLL2_Clocks->PLL2_Q_Frequency = \
 8004f9c:	edc0 6a01 	vstr	s13, [r0, #4]
 8004fa0:	e004      	b.n	8004fac <HAL_RCCEx_GetPLL2ClockFreq+0x1b4>
        pPLL2_Clocks->PLL2_Q_Frequency = 0U;
 8004fa2:	2300      	movs	r3, #0
 8004fa4:	6043      	str	r3, [r0, #4]
 8004fa6:	e001      	b.n	8004fac <HAL_RCCEx_GetPLL2ClockFreq+0x1b4>
      pPLL2_Clocks->PLL2_Q_Frequency = 0U;
 8004fa8:	2300      	movs	r3, #0
 8004faa:	6043      	str	r3, [r0, #4]
    if (HAL_IS_BIT_SET(RCC->CR, RCC_CR_PLL2RDY))
 8004fac:	4b13      	ldr	r3, [pc, #76]	@ (8004ffc <HAL_RCCEx_GetPLL2ClockFreq+0x204>)
 8004fae:	681b      	ldr	r3, [r3, #0]
 8004fb0:	f013 6f00 	tst.w	r3, #134217728	@ 0x8000000
 8004fb4:	d01a      	beq.n	8004fec <HAL_RCCEx_GetPLL2ClockFreq+0x1f4>
      if (__HAL_RCC_GET_PLL2_CLKOUT_CONFIG(RCC_PLL2_DIVR) != 0U)
 8004fb6:	4b11      	ldr	r3, [pc, #68]	@ (8004ffc <HAL_RCCEx_GetPLL2ClockFreq+0x204>)
 8004fb8:	6adb      	ldr	r3, [r3, #44]	@ 0x2c
 8004fba:	f413 2f80 	tst.w	r3, #262144	@ 0x40000
 8004fbe:	d012      	beq.n	8004fe6 <HAL_RCCEx_GetPLL2ClockFreq+0x1ee>
                                                             ((float_t)(uint32_t)((RCC->PLL2DIVR & \
 8004fc0:	4b0e      	ldr	r3, [pc, #56]	@ (8004ffc <HAL_RCCEx_GetPLL2ClockFreq+0x204>)
 8004fc2:	6bdb      	ldr	r3, [r3, #60]	@ 0x3c
 8004fc4:	f3c3 6306 	ubfx	r3, r3, #24, #7
 8004fc8:	ee07 3a10 	vmov	s14, r3
 8004fcc:	eeb8 7a47 	vcvt.f32.u32	s14, s14
                                                                                  RCC_PLL2DIVR_PLL2R_Pos) + \
 8004fd0:	eef7 6a00 	vmov.f32	s13, #112	@ 0x3f800000  1.0
 8004fd4:	ee37 7a26 	vadd.f32	s14, s14, s13
                                         (uint32_t)(float_t)(pll2vco / \
 8004fd8:	eec7 6a87 	vdiv.f32	s13, s15, s14
 8004fdc:	eefc 6ae6 	vcvt.u32.f32	s13, s13
        pPLL2_Clocks->PLL2_R_Frequency = \
 8004fe0:	edc0 6a02 	vstr	s13, [r0, #8]
 8004fe4:	e009      	b.n	8004ffa <HAL_RCCEx_GetPLL2ClockFreq+0x202>
        pPLL2_Clocks->PLL2_R_Frequency = 0U;
 8004fe6:	2300      	movs	r3, #0
 8004fe8:	6083      	str	r3, [r0, #8]
 8004fea:	e006      	b.n	8004ffa <HAL_RCCEx_GetPLL2ClockFreq+0x202>
      pPLL2_Clocks->PLL2_R_Frequency = 0U;
 8004fec:	2300      	movs	r3, #0
 8004fee:	6083      	str	r3, [r0, #8]
 8004ff0:	e003      	b.n	8004ffa <HAL_RCCEx_GetPLL2ClockFreq+0x202>
    pPLL2_Clocks->PLL2_P_Frequency = 0U;
 8004ff2:	2300      	movs	r3, #0
 8004ff4:	6003      	str	r3, [r0, #0]
    pPLL2_Clocks->PLL2_Q_Frequency = 0U;
 8004ff6:	6043      	str	r3, [r0, #4]
    pPLL2_Clocks->PLL2_R_Frequency = 0U;
 8004ff8:	6083      	str	r3, [r0, #8]
}
 8004ffa:	bd30      	pop	{r4, r5, pc}
 8004ffc:	44020c00 	.word	0x44020c00
 8005000:	03d09000 	.word	0x03d09000
 8005004:	39000000 	.word	0x39000000
 8005008:	4a742400 	.word	0x4a742400
 800500c:	4bbebc20 	.word	0x4bbebc20

08005010 <HAL_RCCEx_GetPLL3ClockFreq>:
{
 8005010:	b530      	push	{r4, r5, lr}
  pll3n = (RCC->PLL3DIVR & RCC_PLL3DIVR_PLL3N);
 8005012:	4980      	ldr	r1, [pc, #512]	@ (8005214 <HAL_RCCEx_GetPLL3ClockFreq+0x204>)
 8005014:	6c4a      	ldr	r2, [r1, #68]	@ 0x44
 8005016:	f3c2 0208 	ubfx	r2, r2, #0, #9
  pll3source = (RCC->PLL3CFGR & RCC_PLL3CFGR_PLL3SRC);
 800501a:	6b0b      	ldr	r3, [r1, #48]	@ 0x30
 800501c:	f003 0c03 	and.w	ip, r3, #3
  pll3m = ((RCC->PLL3CFGR & RCC_PLL3CFGR_PLL3M) >> RCC_PLL3CFGR_PLL3M_Pos);
 8005020:	6b0c      	ldr	r4, [r1, #48]	@ 0x30
 8005022:	f3c4 2505 	ubfx	r5, r4, #8, #6
  pll3fracen = ((RCC->PLL3CFGR & RCC_PLL3CFGR_PLL3FRACEN) >> RCC_PLL3CFGR_PLL3FRACEN_Pos);
 8005026:	6b0b      	ldr	r3, [r1, #48]	@ 0x30
 8005028:	f3c3 1e00 	ubfx	lr, r3, #4, #1
  fracn3 = (float_t)(uint32_t)(pll3fracen * ((RCC->PLL3FRACR & RCC_PLL3FRACR_PLL3FRACN) >> \
 800502c:	6c8b      	ldr	r3, [r1, #72]	@ 0x48
 800502e:	f3c3 03cc 	ubfx	r3, r3, #3, #13
 8005032:	fb0e f303 	mul.w	r3, lr, r3
  if (pll3m != 0U)
 8005036:	f414 5f7c 	tst.w	r4, #16128	@ 0x3f00
 800503a:	f000 80e6 	beq.w	800520a <HAL_RCCEx_GetPLL3ClockFreq+0x1fa>
 800503e:	ee07 3a90 	vmov	s15, r3
 8005042:	eef8 7a67 	vcvt.f32.u32	s15, s15
    switch (pll3source)
 8005046:	f1bc 0f02 	cmp.w	ip, #2
 800504a:	d041      	beq.n	80050d0 <HAL_RCCEx_GetPLL3ClockFreq+0xc0>
 800504c:	f1bc 0f03 	cmp.w	ip, #3
 8005050:	d057      	beq.n	8005102 <HAL_RCCEx_GetPLL3ClockFreq+0xf2>
 8005052:	f1bc 0f01 	cmp.w	ip, #1
 8005056:	d16d      	bne.n	8005134 <HAL_RCCEx_GetPLL3ClockFreq+0x124>
        hsivalue = (HSI_VALUE >> (__HAL_RCC_GET_HSI_DIVIDER() >> RCC_CR_HSIDIV_Pos));
 8005058:	6809      	ldr	r1, [r1, #0]
 800505a:	f3c1 01c1 	ubfx	r1, r1, #3, #2
 800505e:	4b6e      	ldr	r3, [pc, #440]	@ (8005218 <HAL_RCCEx_GetPLL3ClockFreq+0x208>)
 8005060:	40cb      	lsrs	r3, r1
        pll3vco = ((float_t)hsivalue / (float_t)pll3m) * ((float_t)(uint32_t)pll3n + (fracn3 / (float_t)0x2000) + \
 8005062:	ee07 3a10 	vmov	s14, r3
 8005066:	eeb8 6a47 	vcvt.f32.u32	s12, s14
 800506a:	ee07 5a10 	vmov	s14, r5
 800506e:	eeb8 7a47 	vcvt.f32.u32	s14, s14
 8005072:	eec6 6a07 	vdiv.f32	s13, s12, s14
 8005076:	ee07 2a10 	vmov	s14, r2
 800507a:	eeb8 7a47 	vcvt.f32.u32	s14, s14
 800507e:	ed9f 6a67 	vldr	s12, [pc, #412]	@ 800521c <HAL_RCCEx_GetPLL3ClockFreq+0x20c>
 8005082:	ee67 7a86 	vmul.f32	s15, s15, s12
 8005086:	ee77 7a27 	vadd.f32	s15, s14, s15
 800508a:	eeb7 7a00 	vmov.f32	s14, #112	@ 0x3f800000  1.0
 800508e:	ee77 7a87 	vadd.f32	s15, s15, s14
 8005092:	ee66 7aa7 	vmul.f32	s15, s13, s15
    if (HAL_IS_BIT_SET(RCC->CR, RCC_CR_PLL3RDY))
 8005096:	4b5f      	ldr	r3, [pc, #380]	@ (8005214 <HAL_RCCEx_GetPLL3ClockFreq+0x204>)
 8005098:	681b      	ldr	r3, [r3, #0]
 800509a:	f013 5f00 	tst.w	r3, #536870912	@ 0x20000000
 800509e:	d06d      	beq.n	800517c <HAL_RCCEx_GetPLL3ClockFreq+0x16c>
      if (__HAL_RCC_GET_PLL3_CLKOUT_CONFIG(RCC_PLL3_DIVP) != 0U)
 80050a0:	4b5c      	ldr	r3, [pc, #368]	@ (8005214 <HAL_RCCEx_GetPLL3ClockFreq+0x204>)
 80050a2:	6b1b      	ldr	r3, [r3, #48]	@ 0x30
 80050a4:	f413 3f80 	tst.w	r3, #65536	@ 0x10000
 80050a8:	d065      	beq.n	8005176 <HAL_RCCEx_GetPLL3ClockFreq+0x166>
                                                             ((float_t)(uint32_t)((RCC->PLL3DIVR & \
 80050aa:	4b5a      	ldr	r3, [pc, #360]	@ (8005214 <HAL_RCCEx_GetPLL3ClockFreq+0x204>)
 80050ac:	6c5b      	ldr	r3, [r3, #68]	@ 0x44
 80050ae:	f3c3 2346 	ubfx	r3, r3, #9, #7
 80050b2:	ee07 3a10 	vmov	s14, r3
 80050b6:	eeb8 7a47 	vcvt.f32.u32	s14, s14
                                                                                  RCC_PLL3DIVR_PLL3P_Pos) + \
 80050ba:	eef7 6a00 	vmov.f32	s13, #112	@ 0x3f800000  1.0
 80050be:	ee37 7a26 	vadd.f32	s14, s14, s13
                                         (uint32_t)(float_t)(pll3vco / \
 80050c2:	eec7 6a87 	vdiv.f32	s13, s15, s14
 80050c6:	eefc 6ae6 	vcvt.u32.f32	s13, s13
        pPLL3_Clocks->PLL3_P_Frequency = \
 80050ca:	edc0 6a00 	vstr	s13, [r0]
 80050ce:	e057      	b.n	8005180 <HAL_RCCEx_GetPLL3ClockFreq+0x170>
        pll3vco = ((float_t)CSI_VALUE / (float_t)pll3m) * ((float_t)(uint32_t)pll3n + (fracn3 / (float_t)0x2000) + \
 80050d0:	ee07 5a10 	vmov	s14, r5
 80050d4:	eeb8 7a47 	vcvt.f32.u32	s14, s14
 80050d8:	ed9f 6a51 	vldr	s12, [pc, #324]	@ 8005220 <HAL_RCCEx_GetPLL3ClockFreq+0x210>
 80050dc:	eec6 6a07 	vdiv.f32	s13, s12, s14
 80050e0:	ee07 2a10 	vmov	s14, r2
 80050e4:	eeb8 7a47 	vcvt.f32.u32	s14, s14
 80050e8:	ed9f 6a4c 	vldr	s12, [pc, #304]	@ 800521c <HAL_RCCEx_GetPLL3ClockFreq+0x20c>
 80050ec:	ee67 7a86 	vmul.f32	s15, s15, s12
 80050f0:	ee77 7a27 	vadd.f32	s15, s14, s15
 80050f4:	eeb7 7a00 	vmov.f32	s14, #112	@ 0x3f800000  1.0
 80050f8:	ee77 7a87 	vadd.f32	s15, s15, s14
 80050fc:	ee66 7aa7 	vmul.f32	s15, s13, s15
        break;
 8005100:	e7c9      	b.n	8005096 <HAL_RCCEx_GetPLL3ClockFreq+0x86>
        pll3vco = ((float_t)HSE_VALUE / (float_t)pll3m) * ((float_t)(uint32_t)pll3n + (fracn3 / (float_t)0x2000) + \
 8005102:	ee07 5a10 	vmov	s14, r5
 8005106:	eeb8 7a47 	vcvt.f32.u32	s14, s14
 800510a:	ed9f 6a46 	vldr	s12, [pc, #280]	@ 8005224 <HAL_RCCEx_GetPLL3ClockFreq+0x214>
 800510e:	eec6 6a07 	vdiv.f32	s13, s12, s14
 8005112:	ee07 2a10 	vmov	s14, r2
 8005116:	eeb8 7a47 	vcvt.f32.u32	s14, s14
 800511a:	ed9f 6a40 	vldr	s12, [pc, #256]	@ 800521c <HAL_RCCEx_GetPLL3ClockFreq+0x20c>
 800511e:	ee67 7a86 	vmul.f32	s15, s15, s12
 8005122:	ee77 7a27 	vadd.f32	s15, s14, s15
 8005126:	eeb7 7a00 	vmov.f32	s14, #112	@ 0x3f800000  1.0
 800512a:	ee77 7a87 	vadd.f32	s15, s15, s14
 800512e:	ee66 7aa7 	vmul.f32	s15, s13, s15
        break;
 8005132:	e7b0      	b.n	8005096 <HAL_RCCEx_GetPLL3ClockFreq+0x86>
        hsivalue = (HSI_VALUE >> (__HAL_RCC_GET_HSI_DIVIDER() >> RCC_CR_HSIDIV_Pos));
 8005134:	4b37      	ldr	r3, [pc, #220]	@ (8005214 <HAL_RCCEx_GetPLL3ClockFreq+0x204>)
 8005136:	6819      	ldr	r1, [r3, #0]
 8005138:	f3c1 01c1 	ubfx	r1, r1, #3, #2
 800513c:	4b36      	ldr	r3, [pc, #216]	@ (8005218 <HAL_RCCEx_GetPLL3ClockFreq+0x208>)
 800513e:	40cb      	lsrs	r3, r1
        pll3vco = ((float_t)hsivalue / (float_t)pll3m) * ((float_t)(uint32_t)pll3n + (fracn3 / (float_t)0x2000) + \
 8005140:	ee07 3a10 	vmov	s14, r3
 8005144:	eeb8 6a47 	vcvt.f32.u32	s12, s14
 8005148:	ee07 5a10 	vmov	s14, r5
 800514c:	eeb8 7a47 	vcvt.f32.u32	s14, s14
 8005150:	eec6 6a07 	vdiv.f32	s13, s12, s14
 8005154:	ee07 2a10 	vmov	s14, r2
 8005158:	eeb8 7a47 	vcvt.f32.u32	s14, s14
 800515c:	ed9f 6a2f 	vldr	s12, [pc, #188]	@ 800521c <HAL_RCCEx_GetPLL3ClockFreq+0x20c>
 8005160:	ee67 7a86 	vmul.f32	s15, s15, s12
 8005164:	ee77 7a27 	vadd.f32	s15, s14, s15
 8005168:	eeb7 7a00 	vmov.f32	s14, #112	@ 0x3f800000  1.0
 800516c:	ee77 7a87 	vadd.f32	s15, s15, s14
 8005170:	ee66 7aa7 	vmul.f32	s15, s13, s15
        break;
 8005174:	e78f      	b.n	8005096 <HAL_RCCEx_GetPLL3ClockFreq+0x86>
        pPLL3_Clocks->PLL3_P_Frequency = 0U;
 8005176:	2300      	movs	r3, #0
 8005178:	6003      	str	r3, [r0, #0]
 800517a:	e001      	b.n	8005180 <HAL_RCCEx_GetPLL3ClockFreq+0x170>
      pPLL3_Clocks->PLL3_P_Frequency = 0U;
 800517c:	2300      	movs	r3, #0
 800517e:	6003      	str	r3, [r0, #0]
    if (HAL_IS_BIT_SET(RCC->CR, RCC_CR_PLL3RDY))
 8005180:	4b24      	ldr	r3, [pc, #144]	@ (8005214 <HAL_RCCEx_GetPLL3ClockFreq+0x204>)
 8005182:	681b      	ldr	r3, [r3, #0]
 8005184:	f013 5f00 	tst.w	r3, #536870912	@ 0x20000000
 8005188:	d01a      	beq.n	80051c0 <HAL_RCCEx_GetPLL3ClockFreq+0x1b0>
      if (__HAL_RCC_GET_PLL3_CLKOUT_CONFIG(RCC_PLL3_DIVQ) != 0U)
 800518a:	4b22      	ldr	r3, [pc, #136]	@ (8005214 <HAL_RCCEx_GetPLL3ClockFreq+0x204>)
 800518c:	6b1b      	ldr	r3, [r3, #48]	@ 0x30
 800518e:	f413 3f00 	tst.w	r3, #131072	@ 0x20000
 8005192:	d012      	beq.n	80051ba <HAL_RCCEx_GetPLL3ClockFreq+0x1aa>
                                                             ((float_t)(uint32_t)((RCC->PLL3DIVR & \
 8005194:	4b1f      	ldr	r3, [pc, #124]	@ (8005214 <HAL_RCCEx_GetPLL3ClockFreq+0x204>)
 8005196:	6c5b      	ldr	r3, [r3, #68]	@ 0x44
 8005198:	f3c3 4306 	ubfx	r3, r3, #16, #7
 800519c:	ee07 3a10 	vmov	s14, r3
 80051a0:	eeb8 7a47 	vcvt.f32.u32	s14, s14
                                                                                  RCC_PLL3DIVR_PLL3Q_Pos) + \
 80051a4:	eef7 6a00 	vmov.f32	s13, #112	@ 0x3f800000  1.0
 80051a8:	ee37 7a26 	vadd.f32	s14, s14, s13
                                         (uint32_t)(float_t)(pll3vco / \
 80051ac:	eec7 6a87 	vdiv.f32	s13, s15, s14
 80051b0:	eefc 6ae6 	vcvt.u32.f32	s13, s13
        pPLL3_Clocks->PLL3_Q_Frequency = \
 80051b4:	edc0 6a01 	vstr	s13, [r0, #4]
 80051b8:	e004      	b.n	80051c4 <HAL_RCCEx_GetPLL3ClockFreq+0x1b4>
        pPLL3_Clocks->PLL3_Q_Frequency = 0U;
 80051ba:	2300      	movs	r3, #0
 80051bc:	6043      	str	r3, [r0, #4]
 80051be:	e001      	b.n	80051c4 <HAL_RCCEx_GetPLL3ClockFreq+0x1b4>
      pPLL3_Clocks->PLL3_Q_Frequency = 0U;
 80051c0:	2300      	movs	r3, #0
 80051c2:	6043      	str	r3, [r0, #4]
    if (HAL_IS_BIT_SET(RCC->CR, RCC_CR_PLL3RDY))
 80051c4:	4b13      	ldr	r3, [pc, #76]	@ (8005214 <HAL_RCCEx_GetPLL3ClockFreq+0x204>)
 80051c6:	681b      	ldr	r3, [r3, #0]
 80051c8:	f013 5f00 	tst.w	r3, #536870912	@ 0x20000000
 80051cc:	d01a      	beq.n	8005204 <HAL_RCCEx_GetPLL3ClockFreq+0x1f4>
      if (__HAL_RCC_GET_PLL3_CLKOUT_CONFIG(RCC_PLL3_DIVR) != 0U)
 80051ce:	4b11      	ldr	r3, [pc, #68]	@ (8005214 <HAL_RCCEx_GetPLL3ClockFreq+0x204>)
 80051d0:	6b1b      	ldr	r3, [r3, #48]	@ 0x30
 80051d2:	f413 2f80 	tst.w	r3, #262144	@ 0x40000
 80051d6:	d012      	beq.n	80051fe <HAL_RCCEx_GetPLL3ClockFreq+0x1ee>
                                                             ((float_t)(uint32_t)((RCC->PLL3DIVR & \
 80051d8:	4b0e      	ldr	r3, [pc, #56]	@ (8005214 <HAL_RCCEx_GetPLL3ClockFreq+0x204>)
 80051da:	6c5b      	ldr	r3, [r3, #68]	@ 0x44
 80051dc:	f3c3 6306 	ubfx	r3, r3, #24, #7
 80051e0:	ee07 3a10 	vmov	s14, r3
 80051e4:	eeb8 7a47 	vcvt.f32.u32	s14, s14
                                                                                  RCC_PLL3DIVR_PLL3R_Pos) + \
 80051e8:	eef7 6a00 	vmov.f32	s13, #112	@ 0x3f800000  1.0
 80051ec:	ee37 7a26 	vadd.f32	s14, s14, s13
                                         (uint32_t)(float_t)(pll3vco / \
 80051f0:	eec7 6a87 	vdiv.f32	s13, s15, s14
 80051f4:	eefc 6ae6 	vcvt.u32.f32	s13, s13
        pPLL3_Clocks->PLL3_R_Frequency = \
 80051f8:	edc0 6a02 	vstr	s13, [r0, #8]
 80051fc:	e009      	b.n	8005212 <HAL_RCCEx_GetPLL3ClockFreq+0x202>
        pPLL3_Clocks->PLL3_R_Frequency = 0U;
 80051fe:	2300      	movs	r3, #0
 8005200:	6083      	str	r3, [r0, #8]
 8005202:	e006      	b.n	8005212 <HAL_RCCEx_GetPLL3ClockFreq+0x202>
      pPLL3_Clocks->PLL3_R_Frequency = 0U;
 8005204:	2300      	movs	r3, #0
 8005206:	6083      	str	r3, [r0, #8]
 8005208:	e003      	b.n	8005212 <HAL_RCCEx_GetPLL3ClockFreq+0x202>
    pPLL3_Clocks->PLL3_P_Frequency = 0U;
 800520a:	2300      	movs	r3, #0
 800520c:	6003      	str	r3, [r0, #0]
    pPLL3_Clocks->PLL3_Q_Frequency = 0U;
 800520e:	6043      	str	r3, [r0, #4]
    pPLL3_Clocks->PLL3_R_Frequency = 0U;
 8005210:	6083      	str	r3, [r0, #8]
}
 8005212:	bd30      	pop	{r4, r5, pc}
 8005214:	44020c00 	.word	0x44020c00
 8005218:	03d09000 	.word	0x03d09000
 800521c:	39000000 	.word	0x39000000
 8005220:	4a742400 	.word	0x4a742400
 8005224:	4bbebc20 	.word	0x4bbebc20

08005228 <HAL_RCCEx_GetPeriphCLKFreq>:
  if (PeriphClk == RCC_PERIPHCLK_RTC)
 8005228:	f100 437e 	add.w	r3, r0, #4261412864	@ 0xfe000000
 800522c:	430b      	orrs	r3, r1
 800522e:	d02c      	beq.n	800528a <HAL_RCCEx_GetPeriphCLKFreq+0x62>
{
 8005230:	b500      	push	{lr}
 8005232:	b08b      	sub	sp, #44	@ 0x2c
    switch (PeriphClk)
 8005234:	f5a0 1380 	sub.w	r3, r0, #1048576	@ 0x100000
 8005238:	430b      	orrs	r3, r1
 800523a:	f000 83cc 	beq.w	80059d6 <HAL_RCCEx_GetPeriphCLKFreq+0x7ae>
 800523e:	4bb0      	ldr	r3, [pc, #704]	@ (8005500 <HAL_RCCEx_GetPeriphCLKFreq+0x2d8>)
 8005240:	4298      	cmp	r0, r3
 8005242:	f171 0300 	sbcs.w	r3, r1, #0
 8005246:	f080 81fc 	bcs.w	8005642 <HAL_RCCEx_GetPeriphCLKFreq+0x41a>
 800524a:	f5a0 6380 	sub.w	r3, r0, #1024	@ 0x400
 800524e:	430b      	orrs	r3, r1
 8005250:	f000 86b5 	beq.w	8005fbe <HAL_RCCEx_GetPeriphCLKFreq+0xd96>
 8005254:	f240 4301 	movw	r3, #1025	@ 0x401
 8005258:	4298      	cmp	r0, r3
 800525a:	f171 0300 	sbcs.w	r3, r1, #0
 800525e:	f080 8116 	bcs.w	800548e <HAL_RCCEx_GetPeriphCLKFreq+0x266>
 8005262:	2821      	cmp	r0, #33	@ 0x21
 8005264:	f171 0300 	sbcs.w	r3, r1, #0
 8005268:	f080 8086 	bcs.w	8005378 <HAL_RCCEx_GetPeriphCLKFreq+0x150>
 800526c:	ea50 0301 	orrs.w	r3, r0, r1
 8005270:	f001 84db 	beq.w	8006c2a <HAL_RCCEx_GetPeriphCLKFreq+0x1a02>
 8005274:	3801      	subs	r0, #1
 8005276:	f141 31ff 	adc.w	r1, r1, #4294967295	@ 0xffffffff
 800527a:	2820      	cmp	r0, #32
 800527c:	f171 0100 	sbcs.w	r1, r1, #0
 8005280:	d334      	bcc.n	80052ec <HAL_RCCEx_GetPeriphCLKFreq+0xc4>
 8005282:	2000      	movs	r0, #0
}
 8005284:	b00b      	add	sp, #44	@ 0x2c
 8005286:	f85d fb04 	ldr.w	pc, [sp], #4
    srcclk = __HAL_RCC_GET_RTC_SOURCE();
 800528a:	4a9e      	ldr	r2, [pc, #632]	@ (8005504 <HAL_RCCEx_GetPeriphCLKFreq+0x2dc>)
 800528c:	f8d2 30f0 	ldr.w	r3, [r2, #240]	@ 0xf0
 8005290:	f403 7340 	and.w	r3, r3, #768	@ 0x300
    if ((HAL_IS_BIT_SET(RCC->BDCR, RCC_BDCR_LSERDY)) && (srcclk == RCC_RTCCLKSOURCE_LSE))
 8005294:	f8d2 20f0 	ldr.w	r2, [r2, #240]	@ 0xf0
 8005298:	f012 0f02 	tst.w	r2, #2
 800529c:	d003      	beq.n	80052a6 <HAL_RCCEx_GetPeriphCLKFreq+0x7e>
 800529e:	f5b3 7f80 	cmp.w	r3, #256	@ 0x100
 80052a2:	f001 84ba 	beq.w	8006c1a <HAL_RCCEx_GetPeriphCLKFreq+0x19f2>
    else if ((HAL_IS_BIT_SET(RCC->BDCR, RCC_BDCR_LSIRDY)) && (srcclk == RCC_RTCCLKSOURCE_LSI))
 80052a6:	4a97      	ldr	r2, [pc, #604]	@ (8005504 <HAL_RCCEx_GetPeriphCLKFreq+0x2dc>)
 80052a8:	f8d2 20f0 	ldr.w	r2, [r2, #240]	@ 0xf0
 80052ac:	f012 6f00 	tst.w	r2, #134217728	@ 0x8000000
 80052b0:	d003      	beq.n	80052ba <HAL_RCCEx_GetPeriphCLKFreq+0x92>
 80052b2:	f5b3 7f00 	cmp.w	r3, #512	@ 0x200
 80052b6:	f001 84b3 	beq.w	8006c20 <HAL_RCCEx_GetPeriphCLKFreq+0x19f8>
    else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_HSERDY)) && (srcclk == RCC_RTCCLKSOURCE_HSE_DIVx))
 80052ba:	4a92      	ldr	r2, [pc, #584]	@ (8005504 <HAL_RCCEx_GetPeriphCLKFreq+0x2dc>)
 80052bc:	6810      	ldr	r0, [r2, #0]
 80052be:	f410 3000 	ands.w	r0, r0, #131072	@ 0x20000
 80052c2:	f001 862c 	beq.w	8006f1e <HAL_RCCEx_GetPeriphCLKFreq+0x1cf6>
 80052c6:	f5b3 7f40 	cmp.w	r3, #768	@ 0x300
 80052ca:	d001      	beq.n	80052d0 <HAL_RCCEx_GetPeriphCLKFreq+0xa8>
      frequency = 0U;
 80052cc:	2000      	movs	r0, #0
 80052ce:	4770      	bx	lr
      if (__HAL_RCC_GET_RTC_HSE_PRESCALER() >= RCC_RTC_HSE_DIV2)
 80052d0:	69d3      	ldr	r3, [r2, #28]
 80052d2:	f403 537c 	and.w	r3, r3, #16128	@ 0x3f00
 80052d6:	f5b3 7f00 	cmp.w	r3, #512	@ 0x200
 80052da:	f0c1 84a4 	bcc.w	8006c26 <HAL_RCCEx_GetPeriphCLKFreq+0x19fe>
        frequency = (HSE_VALUE / ((uint32_t)(__HAL_RCC_GET_RTC_HSE_PRESCALER() >> RCC_CFGR1_RTCPRE_Pos)));
 80052de:	69d3      	ldr	r3, [r2, #28]
 80052e0:	f3c3 2305 	ubfx	r3, r3, #8, #6
 80052e4:	4888      	ldr	r0, [pc, #544]	@ (8005508 <HAL_RCCEx_GetPeriphCLKFreq+0x2e0>)
 80052e6:	fbb0 f0f3 	udiv	r0, r0, r3
 80052ea:	4770      	bx	lr
    switch (PeriphClk)
 80052ec:	281f      	cmp	r0, #31
 80052ee:	d8c8      	bhi.n	8005282 <HAL_RCCEx_GetPeriphCLKFreq+0x5a>
 80052f0:	a301      	add	r3, pc, #4	@ (adr r3, 80052f8 <HAL_RCCEx_GetPeriphCLKFreq+0xd0>)
 80052f2:	f853 f020 	ldr.w	pc, [r3, r0, lsl #2]
 80052f6:	bf00      	nop
 80052f8:	08005a9f 	.word	0x08005a9f
 80052fc:	08005b39 	.word	0x08005b39
 8005300:	08005283 	.word	0x08005283
 8005304:	08005bbf 	.word	0x08005bbf
 8005308:	08005283 	.word	0x08005283
 800530c:	08005283 	.word	0x08005283
 8005310:	08005283 	.word	0x08005283
 8005314:	08005c53 	.word	0x08005c53
 8005318:	08005283 	.word	0x08005283
 800531c:	08005283 	.word	0x08005283
 8005320:	08005283 	.word	0x08005283
 8005324:	08005283 	.word	0x08005283
 8005328:	08005283 	.word	0x08005283
 800532c:	08005283 	.word	0x08005283
 8005330:	08005283 	.word	0x08005283
 8005334:	08005ced 	.word	0x08005ced
 8005338:	08005283 	.word	0x08005283
 800533c:	08005283 	.word	0x08005283
 8005340:	08005283 	.word	0x08005283
 8005344:	08005283 	.word	0x08005283
 8005348:	08005283 	.word	0x08005283
 800534c:	08005283 	.word	0x08005283
 8005350:	08005283 	.word	0x08005283
 8005354:	08005283 	.word	0x08005283
 8005358:	08005283 	.word	0x08005283
 800535c:	08005283 	.word	0x08005283
 8005360:	08005283 	.word	0x08005283
 8005364:	08005283 	.word	0x08005283
 8005368:	08005283 	.word	0x08005283
 800536c:	08005283 	.word	0x08005283
 8005370:	08005283 	.word	0x08005283
 8005374:	08005d91 	.word	0x08005d91
 8005378:	f5a0 7380 	sub.w	r3, r0, #256	@ 0x100
 800537c:	430b      	orrs	r3, r1
 800537e:	f000 85b9 	beq.w	8005ef4 <HAL_RCCEx_GetPeriphCLKFreq+0xccc>
 8005382:	f240 1301 	movw	r3, #257	@ 0x101
 8005386:	4298      	cmp	r0, r3
 8005388:	f171 0300 	sbcs.w	r3, r1, #0
 800538c:	d241      	bcs.n	8005412 <HAL_RCCEx_GetPeriphCLKFreq+0x1ea>
 800538e:	f1a0 0340 	sub.w	r3, r0, #64	@ 0x40
 8005392:	430b      	orrs	r3, r1
 8005394:	f000 8549 	beq.w	8005e2a <HAL_RCCEx_GetPeriphCLKFreq+0xc02>
 8005398:	3880      	subs	r0, #128	@ 0x80
 800539a:	4308      	orrs	r0, r1
 800539c:	d137      	bne.n	800540e <HAL_RCCEx_GetPeriphCLKFreq+0x1e6>
        srcclk = __HAL_RCC_GET_UART8_SOURCE();
 800539e:	4b59      	ldr	r3, [pc, #356]	@ (8005504 <HAL_RCCEx_GetPeriphCLKFreq+0x2dc>)
 80053a0:	f8d3 30d8 	ldr.w	r3, [r3, #216]	@ 0xd8
        if (srcclk == RCC_UART8CLKSOURCE_PCLK1)
 80053a4:	f413 0360 	ands.w	r3, r3, #14680064	@ 0xe00000
 80053a8:	f000 858c 	beq.w	8005ec4 <HAL_RCCEx_GetPeriphCLKFreq+0xc9c>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_PLL2RDY)) && (srcclk == RCC_UART8CLKSOURCE_PLL2Q))
 80053ac:	4a55      	ldr	r2, [pc, #340]	@ (8005504 <HAL_RCCEx_GetPeriphCLKFreq+0x2dc>)
 80053ae:	6812      	ldr	r2, [r2, #0]
 80053b0:	f012 6f00 	tst.w	r2, #134217728	@ 0x8000000
 80053b4:	d003      	beq.n	80053be <HAL_RCCEx_GetPeriphCLKFreq+0x196>
 80053b6:	f5b3 1f00 	cmp.w	r3, #2097152	@ 0x200000
 80053ba:	f000 8587 	beq.w	8005ecc <HAL_RCCEx_GetPeriphCLKFreq+0xca4>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_PLL3RDY)) && (srcclk == RCC_UART8CLKSOURCE_PLL3Q))
 80053be:	4a51      	ldr	r2, [pc, #324]	@ (8005504 <HAL_RCCEx_GetPeriphCLKFreq+0x2dc>)
 80053c0:	6812      	ldr	r2, [r2, #0]
 80053c2:	f012 5f00 	tst.w	r2, #536870912	@ 0x20000000
 80053c6:	d003      	beq.n	80053d0 <HAL_RCCEx_GetPeriphCLKFreq+0x1a8>
 80053c8:	f5b3 0f80 	cmp.w	r3, #4194304	@ 0x400000
 80053cc:	f000 8584 	beq.w	8005ed8 <HAL_RCCEx_GetPeriphCLKFreq+0xcb0>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_HSIRDY)) && (srcclk == RCC_UART8CLKSOURCE_HSI))
 80053d0:	4a4c      	ldr	r2, [pc, #304]	@ (8005504 <HAL_RCCEx_GetPeriphCLKFreq+0x2dc>)
 80053d2:	6812      	ldr	r2, [r2, #0]
 80053d4:	f012 0f02 	tst.w	r2, #2
 80053d8:	d003      	beq.n	80053e2 <HAL_RCCEx_GetPeriphCLKFreq+0x1ba>
 80053da:	f5b3 0fc0 	cmp.w	r3, #6291456	@ 0x600000
 80053de:	f000 8581 	beq.w	8005ee4 <HAL_RCCEx_GetPeriphCLKFreq+0xcbc>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_CSIRDY)) && (srcclk == RCC_UART8CLKSOURCE_CSI))
 80053e2:	4a48      	ldr	r2, [pc, #288]	@ (8005504 <HAL_RCCEx_GetPeriphCLKFreq+0x2dc>)
 80053e4:	6812      	ldr	r2, [r2, #0]
 80053e6:	f412 7f00 	tst.w	r2, #512	@ 0x200
 80053ea:	d003      	beq.n	80053f4 <HAL_RCCEx_GetPeriphCLKFreq+0x1cc>
 80053ec:	f5b3 0f00 	cmp.w	r3, #8388608	@ 0x800000
 80053f0:	f001 847c 	beq.w	8006cec <HAL_RCCEx_GetPeriphCLKFreq+0x1ac4>
        else if ((HAL_IS_BIT_SET(RCC->BDCR, RCC_BDCR_LSERDY)) && (srcclk == RCC_UART8CLKSOURCE_LSE))
 80053f4:	4a43      	ldr	r2, [pc, #268]	@ (8005504 <HAL_RCCEx_GetPeriphCLKFreq+0x2dc>)
 80053f6:	f8d2 20f0 	ldr.w	r2, [r2, #240]	@ 0xf0
 80053fa:	f012 0f02 	tst.w	r2, #2
 80053fe:	f001 8478 	beq.w	8006cf2 <HAL_RCCEx_GetPeriphCLKFreq+0x1aca>
 8005402:	f5b3 0f20 	cmp.w	r3, #10485760	@ 0xa00000
 8005406:	f001 8477 	beq.w	8006cf8 <HAL_RCCEx_GetPeriphCLKFreq+0x1ad0>
          frequency = 0U;
 800540a:	2000      	movs	r0, #0
 800540c:	e73a      	b.n	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
    switch (PeriphClk)
 800540e:	2000      	movs	r0, #0
 8005410:	e738      	b.n	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
 8005412:	f5a0 7000 	sub.w	r0, r0, #512	@ 0x200
 8005416:	4308      	orrs	r0, r1
 8005418:	d137      	bne.n	800548a <HAL_RCCEx_GetPeriphCLKFreq+0x262>
        srcclk = __HAL_RCC_GET_USART10_SOURCE();
 800541a:	4b3a      	ldr	r3, [pc, #232]	@ (8005504 <HAL_RCCEx_GetPeriphCLKFreq+0x2dc>)
 800541c:	f8d3 30d8 	ldr.w	r3, [r3, #216]	@ 0xd8
        if (srcclk == RCC_USART10CLKSOURCE_PCLK1)
 8005420:	f013 5360 	ands.w	r3, r3, #939524096	@ 0x38000000
 8005424:	f000 85b3 	beq.w	8005f8e <HAL_RCCEx_GetPeriphCLKFreq+0xd66>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_PLL2RDY)) && (srcclk == RCC_USART10CLKSOURCE_PLL2Q))
 8005428:	4a36      	ldr	r2, [pc, #216]	@ (8005504 <HAL_RCCEx_GetPeriphCLKFreq+0x2dc>)
 800542a:	6812      	ldr	r2, [r2, #0]
 800542c:	f012 6f00 	tst.w	r2, #134217728	@ 0x8000000
 8005430:	d003      	beq.n	800543a <HAL_RCCEx_GetPeriphCLKFreq+0x212>
 8005432:	f1b3 6f00 	cmp.w	r3, #134217728	@ 0x8000000
 8005436:	f000 85ae 	beq.w	8005f96 <HAL_RCCEx_GetPeriphCLKFreq+0xd6e>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_PLL3RDY)) && (srcclk == RCC_USART10CLKSOURCE_PLL3Q))
 800543a:	4a32      	ldr	r2, [pc, #200]	@ (8005504 <HAL_RCCEx_GetPeriphCLKFreq+0x2dc>)
 800543c:	6812      	ldr	r2, [r2, #0]
 800543e:	f012 5f00 	tst.w	r2, #536870912	@ 0x20000000
 8005442:	d003      	beq.n	800544c <HAL_RCCEx_GetPeriphCLKFreq+0x224>
 8005444:	f1b3 5f80 	cmp.w	r3, #268435456	@ 0x10000000
 8005448:	f000 85ab 	beq.w	8005fa2 <HAL_RCCEx_GetPeriphCLKFreq+0xd7a>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_HSIRDY)) && (srcclk == RCC_USART10CLKSOURCE_HSI))
 800544c:	4a2d      	ldr	r2, [pc, #180]	@ (8005504 <HAL_RCCEx_GetPeriphCLKFreq+0x2dc>)
 800544e:	6812      	ldr	r2, [r2, #0]
 8005450:	f012 0f02 	tst.w	r2, #2
 8005454:	d003      	beq.n	800545e <HAL_RCCEx_GetPeriphCLKFreq+0x236>
 8005456:	f1b3 5fc0 	cmp.w	r3, #402653184	@ 0x18000000
 800545a:	f000 85a8 	beq.w	8005fae <HAL_RCCEx_GetPeriphCLKFreq+0xd86>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_CSIRDY)) && (srcclk == RCC_USART10CLKSOURCE_CSI))
 800545e:	4a29      	ldr	r2, [pc, #164]	@ (8005504 <HAL_RCCEx_GetPeriphCLKFreq+0x2dc>)
 8005460:	6812      	ldr	r2, [r2, #0]
 8005462:	f412 7f00 	tst.w	r2, #512	@ 0x200
 8005466:	d003      	beq.n	8005470 <HAL_RCCEx_GetPeriphCLKFreq+0x248>
 8005468:	f1b3 5f00 	cmp.w	r3, #536870912	@ 0x20000000
 800546c:	f001 8452 	beq.w	8006d14 <HAL_RCCEx_GetPeriphCLKFreq+0x1aec>
        else if ((HAL_IS_BIT_SET(RCC->BDCR, RCC_BDCR_LSERDY)) && (srcclk == RCC_USART10CLKSOURCE_LSE))
 8005470:	4a24      	ldr	r2, [pc, #144]	@ (8005504 <HAL_RCCEx_GetPeriphCLKFreq+0x2dc>)
 8005472:	f8d2 20f0 	ldr.w	r2, [r2, #240]	@ 0xf0
 8005476:	f012 0f02 	tst.w	r2, #2
 800547a:	f001 844e 	beq.w	8006d1a <HAL_RCCEx_GetPeriphCLKFreq+0x1af2>
 800547e:	f1b3 5f20 	cmp.w	r3, #671088640	@ 0x28000000
 8005482:	f001 844d 	beq.w	8006d20 <HAL_RCCEx_GetPeriphCLKFreq+0x1af8>
          frequency = 0U;
 8005486:	2000      	movs	r0, #0
 8005488:	e6fc      	b.n	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
    switch (PeriphClk)
 800548a:	2000      	movs	r0, #0
 800548c:	e6fa      	b.n	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
 800548e:	f5a0 4300 	sub.w	r3, r0, #32768	@ 0x8000
 8005492:	430b      	orrs	r3, r1
 8005494:	f000 86d7 	beq.w	8006246 <HAL_RCCEx_GetPeriphCLKFreq+0x101e>
 8005498:	f248 0301 	movw	r3, #32769	@ 0x8001
 800549c:	4298      	cmp	r0, r3
 800549e:	f171 0300 	sbcs.w	r3, r1, #0
 80054a2:	d335      	bcc.n	8005510 <HAL_RCCEx_GetPeriphCLKFreq+0x2e8>
 80054a4:	f5a0 2380 	sub.w	r3, r0, #262144	@ 0x40000
 80054a8:	430b      	orrs	r3, r1
 80054aa:	f000 878e 	beq.w	80063ca <HAL_RCCEx_GetPeriphCLKFreq+0x11a2>
 80054ae:	4b17      	ldr	r3, [pc, #92]	@ (800550c <HAL_RCCEx_GetPeriphCLKFreq+0x2e4>)
 80054b0:	4298      	cmp	r0, r3
 80054b2:	f171 0300 	sbcs.w	r3, r1, #0
 80054b6:	f080 8097 	bcs.w	80055e8 <HAL_RCCEx_GetPeriphCLKFreq+0x3c0>
 80054ba:	f5a0 3380 	sub.w	r3, r0, #65536	@ 0x10000
 80054be:	430b      	orrs	r3, r1
 80054c0:	f000 8703 	beq.w	80062ca <HAL_RCCEx_GetPeriphCLKFreq+0x10a2>
 80054c4:	f5a0 3000 	sub.w	r0, r0, #131072	@ 0x20000
 80054c8:	4308      	orrs	r0, r1
 80054ca:	f040 808b 	bne.w	80055e4 <HAL_RCCEx_GetPeriphCLKFreq+0x3bc>
        srcclk = __HAL_RCC_GET_LPTIM1_SOURCE();
 80054ce:	4b0d      	ldr	r3, [pc, #52]	@ (8005504 <HAL_RCCEx_GetPeriphCLKFreq+0x2dc>)
 80054d0:	f8d3 30dc 	ldr.w	r3, [r3, #220]	@ 0xdc
 80054d4:	f403 63e0 	and.w	r3, r3, #1792	@ 0x700
        switch (srcclk)
 80054d8:	f5b3 7f40 	cmp.w	r3, #768	@ 0x300
 80054dc:	f000 8749 	beq.w	8006372 <HAL_RCCEx_GetPeriphCLKFreq+0x114a>
 80054e0:	f200 8720 	bhi.w	8006324 <HAL_RCCEx_GetPeriphCLKFreq+0x10fc>
 80054e4:	f5b3 7f80 	cmp.w	r3, #256	@ 0x100
 80054e8:	f000 8737 	beq.w	800635a <HAL_RCCEx_GetPeriphCLKFreq+0x1132>
 80054ec:	f5b3 7f00 	cmp.w	r3, #512	@ 0x200
 80054f0:	f000 8739 	beq.w	8006366 <HAL_RCCEx_GetPeriphCLKFreq+0x113e>
 80054f4:	2b00      	cmp	r3, #0
 80054f6:	f040 870e 	bne.w	8006316 <HAL_RCCEx_GetPeriphCLKFreq+0x10ee>
            frequency = HAL_RCC_GetPCLK3Freq();
 80054fa:	f7fe f9ff 	bl	80038fc <HAL_RCC_GetPCLK3Freq>
            break;
 80054fe:	e6c1      	b.n	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
 8005500:	00100001 	.word	0x00100001
 8005504:	44020c00 	.word	0x44020c00
 8005508:	017d7840 	.word	0x017d7840
 800550c:	00040001 	.word	0x00040001
    switch (PeriphClk)
 8005510:	f5a0 5300 	sub.w	r3, r0, #8192	@ 0x2000
 8005514:	430b      	orrs	r3, r1
 8005516:	f000 8654 	beq.w	80061c2 <HAL_RCCEx_GetPeriphCLKFreq+0xf9a>
 800551a:	f242 0301 	movw	r3, #8193	@ 0x2001
 800551e:	4298      	cmp	r0, r3
 8005520:	f171 0300 	sbcs.w	r3, r1, #0
 8005524:	d238      	bcs.n	8005598 <HAL_RCCEx_GetPeriphCLKFreq+0x370>
 8005526:	f5a0 6300 	sub.w	r3, r0, #2048	@ 0x800
 800552a:	430b      	orrs	r3, r1
 800552c:	f000 8594 	beq.w	8006058 <HAL_RCCEx_GetPeriphCLKFreq+0xe30>
 8005530:	f5a0 5080 	sub.w	r0, r0, #4096	@ 0x1000
 8005534:	4308      	orrs	r0, r1
 8005536:	d12d      	bne.n	8005594 <HAL_RCCEx_GetPeriphCLKFreq+0x36c>
        srcclk = __HAL_RCC_GET_LPUART1_SOURCE();
 8005538:	4bb0      	ldr	r3, [pc, #704]	@ (80057fc <HAL_RCCEx_GetPeriphCLKFreq+0x5d4>)
 800553a:	f8d3 30e0 	ldr.w	r3, [r3, #224]	@ 0xe0
        if (srcclk == RCC_LPUART1CLKSOURCE_PCLK3)
 800553e:	f013 63e0 	ands.w	r3, r3, #117440512	@ 0x7000000
 8005542:	f000 85d1 	beq.w	80060e8 <HAL_RCCEx_GetPeriphCLKFreq+0xec0>
        else if (srcclk == RCC_LPUART1CLKSOURCE_PLL2Q)
 8005546:	f1b3 7f80 	cmp.w	r3, #16777216	@ 0x1000000
 800554a:	f000 85d1 	beq.w	80060f0 <HAL_RCCEx_GetPeriphCLKFreq+0xec8>
        else if (srcclk == RCC_LPUART1CLKSOURCE_PLL3Q)
 800554e:	f1b3 7f00 	cmp.w	r3, #33554432	@ 0x2000000
 8005552:	f000 85d3 	beq.w	80060fc <HAL_RCCEx_GetPeriphCLKFreq+0xed4>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_HSIRDY)) && (srcclk == RCC_LPUART1CLKSOURCE_HSI))
 8005556:	4aa9      	ldr	r2, [pc, #676]	@ (80057fc <HAL_RCCEx_GetPeriphCLKFreq+0x5d4>)
 8005558:	6812      	ldr	r2, [r2, #0]
 800555a:	f012 0f02 	tst.w	r2, #2
 800555e:	d003      	beq.n	8005568 <HAL_RCCEx_GetPeriphCLKFreq+0x340>
 8005560:	f1b3 7f40 	cmp.w	r3, #50331648	@ 0x3000000
 8005564:	f000 85d0 	beq.w	8006108 <HAL_RCCEx_GetPeriphCLKFreq+0xee0>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_CSIRDY)) && (srcclk == RCC_LPUART1CLKSOURCE_CSI))
 8005568:	4aa4      	ldr	r2, [pc, #656]	@ (80057fc <HAL_RCCEx_GetPeriphCLKFreq+0x5d4>)
 800556a:	6812      	ldr	r2, [r2, #0]
 800556c:	f412 7f00 	tst.w	r2, #512	@ 0x200
 8005570:	d003      	beq.n	800557a <HAL_RCCEx_GetPeriphCLKFreq+0x352>
 8005572:	f1b3 6f80 	cmp.w	r3, #67108864	@ 0x4000000
 8005576:	f001 83eb 	beq.w	8006d50 <HAL_RCCEx_GetPeriphCLKFreq+0x1b28>
        else if ((HAL_IS_BIT_SET(RCC->BDCR, RCC_BDCR_LSERDY)) && (srcclk == RCC_LPUART1CLKSOURCE_LSE))
 800557a:	4aa0      	ldr	r2, [pc, #640]	@ (80057fc <HAL_RCCEx_GetPeriphCLKFreq+0x5d4>)
 800557c:	f8d2 20f0 	ldr.w	r2, [r2, #240]	@ 0xf0
 8005580:	f012 0f02 	tst.w	r2, #2
 8005584:	f001 83e7 	beq.w	8006d56 <HAL_RCCEx_GetPeriphCLKFreq+0x1b2e>
 8005588:	f1b3 6fa0 	cmp.w	r3, #83886080	@ 0x5000000
 800558c:	f001 83e6 	beq.w	8006d5c <HAL_RCCEx_GetPeriphCLKFreq+0x1b34>
          frequency = 0U;
 8005590:	2000      	movs	r0, #0
 8005592:	e677      	b.n	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
    switch (PeriphClk)
 8005594:	2000      	movs	r0, #0
 8005596:	e675      	b.n	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
 8005598:	f5a0 4080 	sub.w	r0, r0, #16384	@ 0x4000
 800559c:	4308      	orrs	r0, r1
 800559e:	d11f      	bne.n	80055e0 <HAL_RCCEx_GetPeriphCLKFreq+0x3b8>
        srcclk = __HAL_RCC_GET_I2C2_SOURCE();
 80055a0:	4b96      	ldr	r3, [pc, #600]	@ (80057fc <HAL_RCCEx_GetPeriphCLKFreq+0x5d4>)
 80055a2:	f8d3 30e4 	ldr.w	r3, [r3, #228]	@ 0xe4
        if (srcclk == RCC_I2C2CLKSOURCE_PCLK1)
 80055a6:	f413 2340 	ands.w	r3, r3, #786432	@ 0xc0000
 80055aa:	f000 863a 	beq.w	8006222 <HAL_RCCEx_GetPeriphCLKFreq+0xffa>
        else if (srcclk ==  RCC_I2C2CLKSOURCE_PLL3R)
 80055ae:	f5b3 2f80 	cmp.w	r3, #262144	@ 0x40000
 80055b2:	f000 863a 	beq.w	800622a <HAL_RCCEx_GetPeriphCLKFreq+0x1002>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_HSIRDY)) && (srcclk == RCC_I2C2CLKSOURCE_HSI))
 80055b6:	4a91      	ldr	r2, [pc, #580]	@ (80057fc <HAL_RCCEx_GetPeriphCLKFreq+0x5d4>)
 80055b8:	6812      	ldr	r2, [r2, #0]
 80055ba:	f012 0f02 	tst.w	r2, #2
 80055be:	d003      	beq.n	80055c8 <HAL_RCCEx_GetPeriphCLKFreq+0x3a0>
 80055c0:	f5b3 2f00 	cmp.w	r3, #524288	@ 0x80000
 80055c4:	f000 8637 	beq.w	8006236 <HAL_RCCEx_GetPeriphCLKFreq+0x100e>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_CSIRDY)) && (srcclk ==  RCC_I2C2CLKSOURCE_CSI))
 80055c8:	4a8c      	ldr	r2, [pc, #560]	@ (80057fc <HAL_RCCEx_GetPeriphCLKFreq+0x5d4>)
 80055ca:	6812      	ldr	r2, [r2, #0]
 80055cc:	f412 7f00 	tst.w	r2, #512	@ 0x200
 80055d0:	f001 83e2 	beq.w	8006d98 <HAL_RCCEx_GetPeriphCLKFreq+0x1b70>
 80055d4:	f5b3 2f40 	cmp.w	r3, #786432	@ 0xc0000
 80055d8:	f001 83e1 	beq.w	8006d9e <HAL_RCCEx_GetPeriphCLKFreq+0x1b76>
          frequency = 0U;
 80055dc:	2000      	movs	r0, #0
 80055de:	e651      	b.n	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
    switch (PeriphClk)
 80055e0:	2000      	movs	r0, #0
 80055e2:	e64f      	b.n	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
 80055e4:	2000      	movs	r0, #0
 80055e6:	e64d      	b.n	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
 80055e8:	f5a0 2000 	sub.w	r0, r0, #524288	@ 0x80000
 80055ec:	4308      	orrs	r0, r1
 80055ee:	d126      	bne.n	800563e <HAL_RCCEx_GetPeriphCLKFreq+0x416>
        srcclk = __HAL_RCC_GET_SAI1_SOURCE();
 80055f0:	4b82      	ldr	r3, [pc, #520]	@ (80057fc <HAL_RCCEx_GetPeriphCLKFreq+0x5d4>)
 80055f2:	f8d3 30e8 	ldr.w	r3, [r3, #232]	@ 0xe8
 80055f6:	f403 23e0 	and.w	r3, r3, #458752	@ 0x70000
        switch (srcclk)
 80055fa:	f5b3 3f00 	cmp.w	r3, #131072	@ 0x20000
 80055fe:	f000 81d0 	beq.w	80059a2 <HAL_RCCEx_GetPeriphCLKFreq+0x77a>
 8005602:	f240 81bc 	bls.w	800597e <HAL_RCCEx_GetPeriphCLKFreq+0x756>
 8005606:	f5b3 3f40 	cmp.w	r3, #196608	@ 0x30000
 800560a:	f001 8311 	beq.w	8006c30 <HAL_RCCEx_GetPeriphCLKFreq+0x1a08>
 800560e:	f5b3 2f80 	cmp.w	r3, #262144	@ 0x40000
 8005612:	f040 81bf 	bne.w	8005994 <HAL_RCCEx_GetPeriphCLKFreq+0x76c>
            ckpclocksource = __HAL_RCC_GET_CLKP_SOURCE();
 8005616:	4a79      	ldr	r2, [pc, #484]	@ (80057fc <HAL_RCCEx_GetPeriphCLKFreq+0x5d4>)
 8005618:	f8d2 30e8 	ldr.w	r3, [r2, #232]	@ 0xe8
 800561c:	f003 4340 	and.w	r3, r3, #3221225472	@ 0xc0000000
            if (HAL_IS_BIT_SET(RCC->CR, RCC_CR_HSIRDY) && (ckpclocksource == RCC_CLKPSOURCE_HSI))
 8005620:	6812      	ldr	r2, [r2, #0]
 8005622:	f012 0f02 	tst.w	r2, #2
 8005626:	f000 81c1 	beq.w	80059ac <HAL_RCCEx_GetPeriphCLKFreq+0x784>
 800562a:	2b00      	cmp	r3, #0
 800562c:	f040 81be 	bne.w	80059ac <HAL_RCCEx_GetPeriphCLKFreq+0x784>
              frequency = (HSI_VALUE >> (__HAL_RCC_GET_HSI_DIVIDER() >> RCC_CR_HSIDIV_Pos));
 8005630:	4b72      	ldr	r3, [pc, #456]	@ (80057fc <HAL_RCCEx_GetPeriphCLKFreq+0x5d4>)
 8005632:	681b      	ldr	r3, [r3, #0]
 8005634:	f3c3 03c1 	ubfx	r3, r3, #3, #2
 8005638:	4871      	ldr	r0, [pc, #452]	@ (8005800 <HAL_RCCEx_GetPeriphCLKFreq+0x5d8>)
 800563a:	40d8      	lsrs	r0, r3
 800563c:	e622      	b.n	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
    switch (PeriphClk)
 800563e:	2000      	movs	r0, #0
 8005640:	e620      	b.n	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
 8005642:	2902      	cmp	r1, #2
 8005644:	bf08      	it	eq
 8005646:	2800      	cmpeq	r0, #0
 8005648:	f001 8247 	beq.w	8006ada <HAL_RCCEx_GetPeriphCLKFreq+0x18b2>
 800564c:	2300      	movs	r3, #0
 800564e:	4283      	cmp	r3, r0
 8005650:	f04f 0302 	mov.w	r3, #2
 8005654:	418b      	sbcs	r3, r1
 8005656:	f0c0 80d9 	bcc.w	800580c <HAL_RCCEx_GetPeriphCLKFreq+0x5e4>
 800565a:	f100 4370 	add.w	r3, r0, #4026531840	@ 0xf0000000
 800565e:	430b      	orrs	r3, r1
 8005660:	f001 8106 	beq.w	8006870 <HAL_RCCEx_GetPeriphCLKFreq+0x1648>
 8005664:	4b67      	ldr	r3, [pc, #412]	@ (8005804 <HAL_RCCEx_GetPeriphCLKFreq+0x5dc>)
 8005666:	4298      	cmp	r0, r3
 8005668:	f171 0300 	sbcs.w	r3, r1, #0
 800566c:	d23a      	bcs.n	80056e4 <HAL_RCCEx_GetPeriphCLKFreq+0x4bc>
 800566e:	f5a0 0300 	sub.w	r3, r0, #8388608	@ 0x800000
 8005672:	430b      	orrs	r3, r1
 8005674:	f000 8201 	beq.w	8005a7a <HAL_RCCEx_GetPeriphCLKFreq+0x852>
 8005678:	4b63      	ldr	r3, [pc, #396]	@ (8005808 <HAL_RCCEx_GetPeriphCLKFreq+0x5e0>)
 800567a:	4298      	cmp	r0, r3
 800567c:	f171 0300 	sbcs.w	r3, r1, #0
 8005680:	d216      	bcs.n	80056b0 <HAL_RCCEx_GetPeriphCLKFreq+0x488>
 8005682:	f5a0 1300 	sub.w	r3, r0, #2097152	@ 0x200000
 8005686:	430b      	orrs	r3, r1
 8005688:	f000 8546 	beq.w	8006118 <HAL_RCCEx_GetPeriphCLKFreq+0xef0>
 800568c:	f5a0 0080 	sub.w	r0, r0, #4194304	@ 0x400000
 8005690:	4308      	orrs	r0, r1
 8005692:	d10b      	bne.n	80056ac <HAL_RCCEx_GetPeriphCLKFreq+0x484>
        srcclk = __HAL_RCC_GET_SDMMC1_SOURCE();
 8005694:	4b59      	ldr	r3, [pc, #356]	@ (80057fc <HAL_RCCEx_GetPeriphCLKFreq+0x5d4>)
 8005696:	f8d3 30e4 	ldr.w	r3, [r3, #228]	@ 0xe4
        if (srcclk == RCC_SDMMC1CLKSOURCE_PLL1Q)
 800569a:	f013 0f40 	tst.w	r3, #64	@ 0x40
 800569e:	f040 81e7 	bne.w	8005a70 <HAL_RCCEx_GetPeriphCLKFreq+0x848>
          HAL_RCCEx_GetPLL1ClockFreq(&pll1_clocks);
 80056a2:	a807      	add	r0, sp, #28
 80056a4:	f7ff fa9c 	bl	8004be0 <HAL_RCCEx_GetPLL1ClockFreq>
          frequency = pll1_clocks.PLL1_Q_Frequency;
 80056a8:	9808      	ldr	r0, [sp, #32]
 80056aa:	e5eb      	b.n	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
    switch (PeriphClk)
 80056ac:	2000      	movs	r0, #0
 80056ae:	e5e9      	b.n	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
 80056b0:	f100 437c 	add.w	r3, r0, #4227858432	@ 0xfc000000
 80056b4:	430b      	orrs	r3, r1
 80056b6:	f001 825b 	beq.w	8006b70 <HAL_RCCEx_GetPeriphCLKFreq+0x1948>
 80056ba:	f100 4078 	add.w	r0, r0, #4160749568	@ 0xf8000000
 80056be:	4308      	orrs	r0, r1
 80056c0:	d10e      	bne.n	80056e0 <HAL_RCCEx_GetPeriphCLKFreq+0x4b8>
        srcclk = __HAL_RCC_GET_SPI1_SOURCE();
 80056c2:	4b4e      	ldr	r3, [pc, #312]	@ (80057fc <HAL_RCCEx_GetPeriphCLKFreq+0x5d4>)
 80056c4:	f8d3 30e0 	ldr.w	r3, [r3, #224]	@ 0xe0
 80056c8:	f003 0307 	and.w	r3, r3, #7
        switch (srcclk)
 80056cc:	2b04      	cmp	r3, #4
 80056ce:	f201 83ae 	bhi.w	8006e2e <HAL_RCCEx_GetPeriphCLKFreq+0x1c06>
 80056d2:	e8df f013 	tbh	[pc, r3, lsl #1]
 80056d6:	088d      	.short	0x088d
 80056d8:	08990893 	.word	0x08990893
 80056dc:	089f088a 	.word	0x089f088a
    switch (PeriphClk)
 80056e0:	2000      	movs	r0, #0
 80056e2:	e5cf      	b.n	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
 80056e4:	2900      	cmp	r1, #0
 80056e6:	bf08      	it	eq
 80056e8:	f1b0 4f00 	cmpeq.w	r0, #2147483648	@ 0x80000000
 80056ec:	f001 8191 	beq.w	8006a12 <HAL_RCCEx_GetPeriphCLKFreq+0x17ea>
 80056f0:	f04f 4300 	mov.w	r3, #2147483648	@ 0x80000000
 80056f4:	4283      	cmp	r3, r0
 80056f6:	f04f 0300 	mov.w	r3, #0
 80056fa:	418b      	sbcs	r3, r1
 80056fc:	d341      	bcc.n	8005782 <HAL_RCCEx_GetPeriphCLKFreq+0x55a>
 80056fe:	f100 4360 	add.w	r3, r0, #3758096384	@ 0xe0000000
 8005702:	430b      	orrs	r3, r1
 8005704:	f001 811c 	beq.w	8006940 <HAL_RCCEx_GetPeriphCLKFreq+0x1718>
 8005708:	f100 4040 	add.w	r0, r0, #3221225472	@ 0xc0000000
 800570c:	4308      	orrs	r0, r1
 800570e:	d136      	bne.n	800577e <HAL_RCCEx_GetPeriphCLKFreq+0x556>
        srcclk = __HAL_RCC_GET_SPI4_SOURCE();
 8005710:	4b3a      	ldr	r3, [pc, #232]	@ (80057fc <HAL_RCCEx_GetPeriphCLKFreq+0x5d4>)
 8005712:	f8d3 30e0 	ldr.w	r3, [r3, #224]	@ 0xe0
        if (srcclk == RCC_SPI4CLKSOURCE_PCLK2)
 8005716:	f413 6360 	ands.w	r3, r3, #3584	@ 0xe00
 800571a:	f001 8162 	beq.w	80069e2 <HAL_RCCEx_GetPeriphCLKFreq+0x17ba>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_PLL2RDY)) && (srcclk == RCC_SPI4CLKSOURCE_PLL2Q))
 800571e:	4a37      	ldr	r2, [pc, #220]	@ (80057fc <HAL_RCCEx_GetPeriphCLKFreq+0x5d4>)
 8005720:	6812      	ldr	r2, [r2, #0]
 8005722:	f012 6f00 	tst.w	r2, #134217728	@ 0x8000000
 8005726:	d003      	beq.n	8005730 <HAL_RCCEx_GetPeriphCLKFreq+0x508>
 8005728:	f5b3 7f00 	cmp.w	r3, #512	@ 0x200
 800572c:	f001 815d 	beq.w	80069ea <HAL_RCCEx_GetPeriphCLKFreq+0x17c2>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_PLL3RDY)) && (srcclk == RCC_SPI4CLKSOURCE_PLL3Q))
 8005730:	4a32      	ldr	r2, [pc, #200]	@ (80057fc <HAL_RCCEx_GetPeriphCLKFreq+0x5d4>)
 8005732:	6812      	ldr	r2, [r2, #0]
 8005734:	f012 5f00 	tst.w	r2, #536870912	@ 0x20000000
 8005738:	d003      	beq.n	8005742 <HAL_RCCEx_GetPeriphCLKFreq+0x51a>
 800573a:	f5b3 6f80 	cmp.w	r3, #1024	@ 0x400
 800573e:	f001 815a 	beq.w	80069f6 <HAL_RCCEx_GetPeriphCLKFreq+0x17ce>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_HSIRDY)) && (srcclk == RCC_SPI4CLKSOURCE_HSI))
 8005742:	4a2e      	ldr	r2, [pc, #184]	@ (80057fc <HAL_RCCEx_GetPeriphCLKFreq+0x5d4>)
 8005744:	6812      	ldr	r2, [r2, #0]
 8005746:	f012 0f02 	tst.w	r2, #2
 800574a:	d003      	beq.n	8005754 <HAL_RCCEx_GetPeriphCLKFreq+0x52c>
 800574c:	f5b3 6fc0 	cmp.w	r3, #1536	@ 0x600
 8005750:	f001 8157 	beq.w	8006a02 <HAL_RCCEx_GetPeriphCLKFreq+0x17da>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_CSIRDY)) && (srcclk == RCC_SPI4CLKSOURCE_CSI))
 8005754:	4a29      	ldr	r2, [pc, #164]	@ (80057fc <HAL_RCCEx_GetPeriphCLKFreq+0x5d4>)
 8005756:	6812      	ldr	r2, [r2, #0]
 8005758:	f412 7f00 	tst.w	r2, #512	@ 0x200
 800575c:	d003      	beq.n	8005766 <HAL_RCCEx_GetPeriphCLKFreq+0x53e>
 800575e:	f5b3 6f00 	cmp.w	r3, #2048	@ 0x800
 8005762:	f001 8392 	beq.w	8006e8a <HAL_RCCEx_GetPeriphCLKFreq+0x1c62>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_HSERDY)) && (srcclk == RCC_SPI4CLKSOURCE_HSE))
 8005766:	4a25      	ldr	r2, [pc, #148]	@ (80057fc <HAL_RCCEx_GetPeriphCLKFreq+0x5d4>)
 8005768:	6812      	ldr	r2, [r2, #0]
 800576a:	f412 3f00 	tst.w	r2, #131072	@ 0x20000
 800576e:	f001 838f 	beq.w	8006e90 <HAL_RCCEx_GetPeriphCLKFreq+0x1c68>
 8005772:	f5b3 6f20 	cmp.w	r3, #2560	@ 0xa00
 8005776:	f001 838e 	beq.w	8006e96 <HAL_RCCEx_GetPeriphCLKFreq+0x1c6e>
          frequency = 0U;
 800577a:	2000      	movs	r0, #0
 800577c:	e582      	b.n	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
    switch (PeriphClk)
 800577e:	2000      	movs	r0, #0
 8005780:	e580      	b.n	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
 8005782:	2901      	cmp	r1, #1
 8005784:	bf08      	it	eq
 8005786:	2800      	cmpeq	r0, #0
 8005788:	d136      	bne.n	80057f8 <HAL_RCCEx_GetPeriphCLKFreq+0x5d0>
        srcclk = __HAL_RCC_GET_SPI6_SOURCE();
 800578a:	4b1c      	ldr	r3, [pc, #112]	@ (80057fc <HAL_RCCEx_GetPeriphCLKFreq+0x5d4>)
 800578c:	f8d3 30e0 	ldr.w	r3, [r3, #224]	@ 0xe0
        if (srcclk == RCC_SPI6CLKSOURCE_PCLK2)
 8005790:	f413 3360 	ands.w	r3, r3, #229376	@ 0x38000
 8005794:	f001 8189 	beq.w	8006aaa <HAL_RCCEx_GetPeriphCLKFreq+0x1882>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_PLL2RDY)) && (srcclk == RCC_SPI6CLKSOURCE_PLL2Q))
 8005798:	4a18      	ldr	r2, [pc, #96]	@ (80057fc <HAL_RCCEx_GetPeriphCLKFreq+0x5d4>)
 800579a:	6812      	ldr	r2, [r2, #0]
 800579c:	f012 6f00 	tst.w	r2, #134217728	@ 0x8000000
 80057a0:	d003      	beq.n	80057aa <HAL_RCCEx_GetPeriphCLKFreq+0x582>
 80057a2:	f5b3 4f00 	cmp.w	r3, #32768	@ 0x8000
 80057a6:	f001 8184 	beq.w	8006ab2 <HAL_RCCEx_GetPeriphCLKFreq+0x188a>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_PLL3RDY)) && (srcclk == RCC_SPI6CLKSOURCE_PLL3Q))
 80057aa:	4a14      	ldr	r2, [pc, #80]	@ (80057fc <HAL_RCCEx_GetPeriphCLKFreq+0x5d4>)
 80057ac:	6812      	ldr	r2, [r2, #0]
 80057ae:	f012 5f00 	tst.w	r2, #536870912	@ 0x20000000
 80057b2:	d003      	beq.n	80057bc <HAL_RCCEx_GetPeriphCLKFreq+0x594>
 80057b4:	f5b3 3f80 	cmp.w	r3, #65536	@ 0x10000
 80057b8:	f001 8181 	beq.w	8006abe <HAL_RCCEx_GetPeriphCLKFreq+0x1896>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_HSIRDY)) && (srcclk == RCC_SPI6CLKSOURCE_HSI))
 80057bc:	4a0f      	ldr	r2, [pc, #60]	@ (80057fc <HAL_RCCEx_GetPeriphCLKFreq+0x5d4>)
 80057be:	6812      	ldr	r2, [r2, #0]
 80057c0:	f012 0f02 	tst.w	r2, #2
 80057c4:	d003      	beq.n	80057ce <HAL_RCCEx_GetPeriphCLKFreq+0x5a6>
 80057c6:	f5b3 3fc0 	cmp.w	r3, #98304	@ 0x18000
 80057ca:	f001 817e 	beq.w	8006aca <HAL_RCCEx_GetPeriphCLKFreq+0x18a2>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_CSIRDY)) && (srcclk == RCC_SPI6CLKSOURCE_CSI))
 80057ce:	4a0b      	ldr	r2, [pc, #44]	@ (80057fc <HAL_RCCEx_GetPeriphCLKFreq+0x5d4>)
 80057d0:	6812      	ldr	r2, [r2, #0]
 80057d2:	f412 7f00 	tst.w	r2, #512	@ 0x200
 80057d6:	d003      	beq.n	80057e0 <HAL_RCCEx_GetPeriphCLKFreq+0x5b8>
 80057d8:	f5b3 3f00 	cmp.w	r3, #131072	@ 0x20000
 80057dc:	f001 8367 	beq.w	8006eae <HAL_RCCEx_GetPeriphCLKFreq+0x1c86>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_HSERDY)) && (srcclk == RCC_SPI6CLKSOURCE_HSE))
 80057e0:	4a06      	ldr	r2, [pc, #24]	@ (80057fc <HAL_RCCEx_GetPeriphCLKFreq+0x5d4>)
 80057e2:	6812      	ldr	r2, [r2, #0]
 80057e4:	f412 3f00 	tst.w	r2, #131072	@ 0x20000
 80057e8:	f001 8364 	beq.w	8006eb4 <HAL_RCCEx_GetPeriphCLKFreq+0x1c8c>
 80057ec:	f5b3 3f20 	cmp.w	r3, #163840	@ 0x28000
 80057f0:	f001 8363 	beq.w	8006eba <HAL_RCCEx_GetPeriphCLKFreq+0x1c92>
          frequency = 0U;
 80057f4:	2000      	movs	r0, #0
 80057f6:	e545      	b.n	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
    switch (PeriphClk)
 80057f8:	2000      	movs	r0, #0
 80057fa:	e543      	b.n	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
 80057fc:	44020c00 	.word	0x44020c00
 8005800:	03d09000 	.word	0x03d09000
 8005804:	10000001 	.word	0x10000001
 8005808:	00800001 	.word	0x00800001
 800580c:	2940      	cmp	r1, #64	@ 0x40
 800580e:	bf08      	it	eq
 8005810:	2800      	cmpeq	r0, #0
 8005812:	f000 869a 	beq.w	800654a <HAL_RCCEx_GetPeriphCLKFreq+0x1322>
 8005816:	2300      	movs	r3, #0
 8005818:	4283      	cmp	r3, r0
 800581a:	f04f 0340 	mov.w	r3, #64	@ 0x40
 800581e:	418b      	sbcs	r3, r1
 8005820:	d22e      	bcs.n	8005880 <HAL_RCCEx_GetPeriphCLKFreq+0x658>
 8005822:	f5b1 7f00 	cmp.w	r1, #512	@ 0x200
 8005826:	bf08      	it	eq
 8005828:	2800      	cmpeq	r0, #0
 800582a:	f000 84b0 	beq.w	800618e <HAL_RCCEx_GetPeriphCLKFreq+0xf66>
 800582e:	2300      	movs	r3, #0
 8005830:	4283      	cmp	r3, r0
 8005832:	f44f 7300 	mov.w	r3, #512	@ 0x200
 8005836:	418b      	sbcs	r3, r1
 8005838:	d37a      	bcc.n	8005930 <HAL_RCCEx_GetPeriphCLKFreq+0x708>
 800583a:	2980      	cmp	r1, #128	@ 0x80
 800583c:	bf08      	it	eq
 800583e:	2800      	cmpeq	r0, #0
 8005840:	f000 86f2 	beq.w	8006628 <HAL_RCCEx_GetPeriphCLKFreq+0x1400>
 8005844:	f5b1 7f80 	cmp.w	r1, #256	@ 0x100
 8005848:	bf08      	it	eq
 800584a:	2800      	cmpeq	r0, #0
 800584c:	d16e      	bne.n	800592c <HAL_RCCEx_GetPeriphCLKFreq+0x704>
        srcclk = __HAL_RCC_GET_LPTIM6_SOURCE();
 800584e:	4bac      	ldr	r3, [pc, #688]	@ (8005b00 <HAL_RCCEx_GetPeriphCLKFreq+0x8d8>)
 8005850:	f8d3 30dc 	ldr.w	r3, [r3, #220]	@ 0xdc
 8005854:	f003 43e0 	and.w	r3, r3, #1879048192	@ 0x70000000
        switch (srcclk)
 8005858:	f1b3 5f40 	cmp.w	r3, #805306368	@ 0x30000000
 800585c:	f000 8778 	beq.w	8006750 <HAL_RCCEx_GetPeriphCLKFreq+0x1528>
 8005860:	f200 874f 	bhi.w	8006702 <HAL_RCCEx_GetPeriphCLKFreq+0x14da>
 8005864:	f1b3 5f80 	cmp.w	r3, #268435456	@ 0x10000000
 8005868:	f000 8766 	beq.w	8006738 <HAL_RCCEx_GetPeriphCLKFreq+0x1510>
 800586c:	f1b3 5f00 	cmp.w	r3, #536870912	@ 0x20000000
 8005870:	f000 8768 	beq.w	8006744 <HAL_RCCEx_GetPeriphCLKFreq+0x151c>
 8005874:	2b00      	cmp	r3, #0
 8005876:	f040 8741 	bne.w	80066fc <HAL_RCCEx_GetPeriphCLKFreq+0x14d4>
            frequency = HAL_RCC_GetPCLK3Freq();
 800587a:	f7fe f83f 	bl	80038fc <HAL_RCC_GetPCLK3Freq>
            break;
 800587e:	e501      	b.n	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
    switch (PeriphClk)
 8005880:	2910      	cmp	r1, #16
 8005882:	bf08      	it	eq
 8005884:	2800      	cmpeq	r0, #0
 8005886:	f001 81a2 	beq.w	8006bce <HAL_RCCEx_GetPeriphCLKFreq+0x19a6>
 800588a:	2300      	movs	r3, #0
 800588c:	4283      	cmp	r3, r0
 800588e:	f04f 0310 	mov.w	r3, #16
 8005892:	418b      	sbcs	r3, r1
 8005894:	d32b      	bcc.n	80058ee <HAL_RCCEx_GetPeriphCLKFreq+0x6c6>
 8005896:	2904      	cmp	r1, #4
 8005898:	bf08      	it	eq
 800589a:	2800      	cmpeq	r0, #0
 800589c:	f000 8784 	beq.w	80067a8 <HAL_RCCEx_GetPeriphCLKFreq+0x1580>
 80058a0:	2908      	cmp	r1, #8
 80058a2:	bf08      	it	eq
 80058a4:	2800      	cmpeq	r0, #0
 80058a6:	d120      	bne.n	80058ea <HAL_RCCEx_GetPeriphCLKFreq+0x6c2>
        srcclk = __HAL_RCC_GET_CEC_SOURCE();
 80058a8:	4a95      	ldr	r2, [pc, #596]	@ (8005b00 <HAL_RCCEx_GetPeriphCLKFreq+0x8d8>)
 80058aa:	f8d2 30e8 	ldr.w	r3, [r2, #232]	@ 0xe8
 80058ae:	f003 03c0 	and.w	r3, r3, #192	@ 0xc0
        if ((HAL_IS_BIT_SET(RCC->BDCR, RCC_BDCR_LSERDY)) && (srcclk == RCC_CECCLKSOURCE_LSE))
 80058b2:	f8d2 20f0 	ldr.w	r2, [r2, #240]	@ 0xf0
 80058b6:	f012 0f02 	tst.w	r2, #2
 80058ba:	d002      	beq.n	80058c2 <HAL_RCCEx_GetPeriphCLKFreq+0x69a>
 80058bc:	2b00      	cmp	r3, #0
 80058be:	f001 830b 	beq.w	8006ed8 <HAL_RCCEx_GetPeriphCLKFreq+0x1cb0>
        else if ((HAL_IS_BIT_SET(RCC->BDCR, RCC_BDCR_LSIRDY)) && (srcclk == RCC_CECCLKSOURCE_LSI))
 80058c2:	4a8f      	ldr	r2, [pc, #572]	@ (8005b00 <HAL_RCCEx_GetPeriphCLKFreq+0x8d8>)
 80058c4:	f8d2 20f0 	ldr.w	r2, [r2, #240]	@ 0xf0
 80058c8:	f012 6f00 	tst.w	r2, #134217728	@ 0x8000000
 80058cc:	d002      	beq.n	80058d4 <HAL_RCCEx_GetPeriphCLKFreq+0x6ac>
 80058ce:	2b40      	cmp	r3, #64	@ 0x40
 80058d0:	f001 8306 	beq.w	8006ee0 <HAL_RCCEx_GetPeriphCLKFreq+0x1cb8>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_CSIRDY)) && (srcclk == RCC_CECCLKSOURCE_CSI_DIV122))
 80058d4:	4a8a      	ldr	r2, [pc, #552]	@ (8005b00 <HAL_RCCEx_GetPeriphCLKFreq+0x8d8>)
 80058d6:	6812      	ldr	r2, [r2, #0]
 80058d8:	f412 7f00 	tst.w	r2, #512	@ 0x200
 80058dc:	f001 8304 	beq.w	8006ee8 <HAL_RCCEx_GetPeriphCLKFreq+0x1cc0>
 80058e0:	2b80      	cmp	r3, #128	@ 0x80
 80058e2:	f001 8304 	beq.w	8006eee <HAL_RCCEx_GetPeriphCLKFreq+0x1cc6>
          frequency = 0U;
 80058e6:	2000      	movs	r0, #0
 80058e8:	e4cc      	b.n	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
    switch (PeriphClk)
 80058ea:	2000      	movs	r0, #0
 80058ec:	e4ca      	b.n	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
 80058ee:	2920      	cmp	r1, #32
 80058f0:	bf08      	it	eq
 80058f2:	2800      	cmpeq	r0, #0
 80058f4:	d118      	bne.n	8005928 <HAL_RCCEx_GetPeriphCLKFreq+0x700>
        srcclk = __HAL_RCC_GET_LPTIM3_SOURCE();
 80058f6:	4b82      	ldr	r3, [pc, #520]	@ (8005b00 <HAL_RCCEx_GetPeriphCLKFreq+0x8d8>)
 80058f8:	f8d3 30dc 	ldr.w	r3, [r3, #220]	@ 0xdc
 80058fc:	f403 23e0 	and.w	r3, r3, #458752	@ 0x70000
        switch (srcclk)
 8005900:	f5b3 3f40 	cmp.w	r3, #196608	@ 0x30000
 8005904:	f000 85f5 	beq.w	80064f2 <HAL_RCCEx_GetPeriphCLKFreq+0x12ca>
 8005908:	f200 85cc 	bhi.w	80064a4 <HAL_RCCEx_GetPeriphCLKFreq+0x127c>
 800590c:	f5b3 3f80 	cmp.w	r3, #65536	@ 0x10000
 8005910:	f000 85e3 	beq.w	80064da <HAL_RCCEx_GetPeriphCLKFreq+0x12b2>
 8005914:	f5b3 3f00 	cmp.w	r3, #131072	@ 0x20000
 8005918:	f000 85e5 	beq.w	80064e6 <HAL_RCCEx_GetPeriphCLKFreq+0x12be>
 800591c:	2b00      	cmp	r3, #0
 800591e:	f040 85be 	bne.w	800649e <HAL_RCCEx_GetPeriphCLKFreq+0x1276>
            frequency = HAL_RCC_GetPCLK3Freq();
 8005922:	f7fd ffeb 	bl	80038fc <HAL_RCC_GetPCLK3Freq>
            break;
 8005926:	e4ad      	b.n	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
    switch (PeriphClk)
 8005928:	2000      	movs	r0, #0
 800592a:	e4ab      	b.n	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
 800592c:	2000      	movs	r0, #0
 800592e:	e4a9      	b.n	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
 8005930:	f5b1 6f80 	cmp.w	r1, #1024	@ 0x400
 8005934:	bf08      	it	eq
 8005936:	2800      	cmpeq	r0, #0
 8005938:	d11f      	bne.n	800597a <HAL_RCCEx_GetPeriphCLKFreq+0x752>
        srcclk = __HAL_RCC_GET_I2C4_SOURCE();
 800593a:	4b71      	ldr	r3, [pc, #452]	@ (8005b00 <HAL_RCCEx_GetPeriphCLKFreq+0x8d8>)
 800593c:	f8d3 30e4 	ldr.w	r3, [r3, #228]	@ 0xe4
        if (srcclk == RCC_I2C4CLKSOURCE_PCLK3)
 8005940:	f413 0340 	ands.w	r3, r3, #12582912	@ 0xc00000
 8005944:	f000 84af 	beq.w	80062a6 <HAL_RCCEx_GetPeriphCLKFreq+0x107e>
        else if (srcclk ==  RCC_I2C4CLKSOURCE_PLL3R)
 8005948:	f5b3 0f80 	cmp.w	r3, #4194304	@ 0x400000
 800594c:	f000 84af 	beq.w	80062ae <HAL_RCCEx_GetPeriphCLKFreq+0x1086>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_HSIRDY)) && (srcclk == RCC_I2C4CLKSOURCE_HSI))
 8005950:	4a6b      	ldr	r2, [pc, #428]	@ (8005b00 <HAL_RCCEx_GetPeriphCLKFreq+0x8d8>)
 8005952:	6812      	ldr	r2, [r2, #0]
 8005954:	f012 0f02 	tst.w	r2, #2
 8005958:	d003      	beq.n	8005962 <HAL_RCCEx_GetPeriphCLKFreq+0x73a>
 800595a:	f5b3 0f00 	cmp.w	r3, #8388608	@ 0x800000
 800595e:	f000 84ac 	beq.w	80062ba <HAL_RCCEx_GetPeriphCLKFreq+0x1092>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_CSIRDY)) && (srcclk ==  RCC_I2C4CLKSOURCE_CSI))
 8005962:	4a67      	ldr	r2, [pc, #412]	@ (8005b00 <HAL_RCCEx_GetPeriphCLKFreq+0x8d8>)
 8005964:	6812      	ldr	r2, [r2, #0]
 8005966:	f412 7f00 	tst.w	r2, #512	@ 0x200
 800596a:	f001 8221 	beq.w	8006db0 <HAL_RCCEx_GetPeriphCLKFreq+0x1b88>
 800596e:	f5b3 0f40 	cmp.w	r3, #12582912	@ 0xc00000
 8005972:	f001 8220 	beq.w	8006db6 <HAL_RCCEx_GetPeriphCLKFreq+0x1b8e>
          frequency = 0U;
 8005976:	2000      	movs	r0, #0
 8005978:	e484      	b.n	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
    switch (PeriphClk)
 800597a:	2000      	movs	r0, #0
 800597c:	e482      	b.n	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
        switch (srcclk)
 800597e:	b15b      	cbz	r3, 8005998 <HAL_RCCEx_GetPeriphCLKFreq+0x770>
 8005980:	f5b3 3f80 	cmp.w	r3, #65536	@ 0x10000
 8005984:	d104      	bne.n	8005990 <HAL_RCCEx_GetPeriphCLKFreq+0x768>
            HAL_RCCEx_GetPLL2ClockFreq(&pll2_clocks);
 8005986:	a804      	add	r0, sp, #16
 8005988:	f7ff fa36 	bl	8004df8 <HAL_RCCEx_GetPLL2ClockFreq>
            frequency = pll2_clocks.PLL2_P_Frequency;
 800598c:	9804      	ldr	r0, [sp, #16]
            break;
 800598e:	e479      	b.n	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
            frequency = 0U;
 8005990:	2000      	movs	r0, #0
 8005992:	e477      	b.n	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
 8005994:	2000      	movs	r0, #0
 8005996:	e475      	b.n	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
            HAL_RCCEx_GetPLL1ClockFreq(&pll1_clocks);
 8005998:	a807      	add	r0, sp, #28
 800599a:	f7ff f921 	bl	8004be0 <HAL_RCCEx_GetPLL1ClockFreq>
            frequency = pll1_clocks.PLL1_Q_Frequency;
 800599e:	9808      	ldr	r0, [sp, #32]
            break;
 80059a0:	e470      	b.n	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
            HAL_RCCEx_GetPLL3ClockFreq(&pll3_clocks);
 80059a2:	a801      	add	r0, sp, #4
 80059a4:	f7ff fb34 	bl	8005010 <HAL_RCCEx_GetPLL3ClockFreq>
            frequency = pll3_clocks.PLL3_P_Frequency;
 80059a8:	9801      	ldr	r0, [sp, #4]
            break;
 80059aa:	e46b      	b.n	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
            else if (HAL_IS_BIT_SET(RCC->CR, RCC_CR_CSIRDY) && (ckpclocksource == RCC_CLKPSOURCE_CSI))
 80059ac:	4a54      	ldr	r2, [pc, #336]	@ (8005b00 <HAL_RCCEx_GetPeriphCLKFreq+0x8d8>)
 80059ae:	6812      	ldr	r2, [r2, #0]
 80059b0:	f412 7f00 	tst.w	r2, #512	@ 0x200
 80059b4:	d003      	beq.n	80059be <HAL_RCCEx_GetPeriphCLKFreq+0x796>
 80059b6:	f1b3 4f80 	cmp.w	r3, #1073741824	@ 0x40000000
 80059ba:	f001 813c 	beq.w	8006c36 <HAL_RCCEx_GetPeriphCLKFreq+0x1a0e>
            else if (HAL_IS_BIT_SET(RCC->CR, RCC_CR_HSERDY) && (ckpclocksource == RCC_CLKPSOURCE_HSE))
 80059be:	4a50      	ldr	r2, [pc, #320]	@ (8005b00 <HAL_RCCEx_GetPeriphCLKFreq+0x8d8>)
 80059c0:	6812      	ldr	r2, [r2, #0]
 80059c2:	f412 3f00 	tst.w	r2, #131072	@ 0x20000
 80059c6:	f001 8139 	beq.w	8006c3c <HAL_RCCEx_GetPeriphCLKFreq+0x1a14>
 80059ca:	f1b3 4f00 	cmp.w	r3, #2147483648	@ 0x80000000
 80059ce:	f001 8138 	beq.w	8006c42 <HAL_RCCEx_GetPeriphCLKFreq+0x1a1a>
              frequency = 0U;
 80059d2:	2000      	movs	r0, #0
 80059d4:	e456      	b.n	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
        srcclk = __HAL_RCC_GET_SAI2_SOURCE();
 80059d6:	4b4a      	ldr	r3, [pc, #296]	@ (8005b00 <HAL_RCCEx_GetPeriphCLKFreq+0x8d8>)
 80059d8:	f8d3 30e8 	ldr.w	r3, [r3, #232]	@ 0xe8
 80059dc:	f403 1360 	and.w	r3, r3, #3670016	@ 0x380000
        switch (srcclk)
 80059e0:	f5b3 1f80 	cmp.w	r3, #1048576	@ 0x100000
 80059e4:	d02a      	beq.n	8005a3c <HAL_RCCEx_GetPeriphCLKFreq+0x814>
 80059e6:	d80a      	bhi.n	80059fe <HAL_RCCEx_GetPeriphCLKFreq+0x7d6>
 80059e8:	b31b      	cbz	r3, 8005a32 <HAL_RCCEx_GetPeriphCLKFreq+0x80a>
 80059ea:	f5b3 2f00 	cmp.w	r3, #524288	@ 0x80000
 80059ee:	d104      	bne.n	80059fa <HAL_RCCEx_GetPeriphCLKFreq+0x7d2>
            HAL_RCCEx_GetPLL2ClockFreq(&pll2_clocks);
 80059f0:	a804      	add	r0, sp, #16
 80059f2:	f7ff fa01 	bl	8004df8 <HAL_RCCEx_GetPLL2ClockFreq>
            frequency = pll2_clocks.PLL2_P_Frequency;
 80059f6:	9804      	ldr	r0, [sp, #16]
            break;
 80059f8:	e444      	b.n	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
            frequency = 0U;
 80059fa:	2000      	movs	r0, #0
 80059fc:	e442      	b.n	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
        switch (srcclk)
 80059fe:	f5b3 1fc0 	cmp.w	r3, #1572864	@ 0x180000
 8005a02:	f001 8121 	beq.w	8006c48 <HAL_RCCEx_GetPeriphCLKFreq+0x1a20>
 8005a06:	f5b3 1f00 	cmp.w	r3, #2097152	@ 0x200000
 8005a0a:	d110      	bne.n	8005a2e <HAL_RCCEx_GetPeriphCLKFreq+0x806>
            ckpclocksource = __HAL_RCC_GET_CLKP_SOURCE();
 8005a0c:	4a3c      	ldr	r2, [pc, #240]	@ (8005b00 <HAL_RCCEx_GetPeriphCLKFreq+0x8d8>)
 8005a0e:	f8d2 30e8 	ldr.w	r3, [r2, #232]	@ 0xe8
 8005a12:	f003 4340 	and.w	r3, r3, #3221225472	@ 0xc0000000
            if (HAL_IS_BIT_SET(RCC->CR, RCC_CR_HSIRDY) && (ckpclocksource == RCC_CLKPSOURCE_HSI))
 8005a16:	6812      	ldr	r2, [r2, #0]
 8005a18:	f012 0f02 	tst.w	r2, #2
 8005a1c:	d013      	beq.n	8005a46 <HAL_RCCEx_GetPeriphCLKFreq+0x81e>
 8005a1e:	b993      	cbnz	r3, 8005a46 <HAL_RCCEx_GetPeriphCLKFreq+0x81e>
              frequency = (HSI_VALUE >> (__HAL_RCC_GET_HSI_DIVIDER() >> RCC_CR_HSIDIV_Pos));
 8005a20:	4b37      	ldr	r3, [pc, #220]	@ (8005b00 <HAL_RCCEx_GetPeriphCLKFreq+0x8d8>)
 8005a22:	681b      	ldr	r3, [r3, #0]
 8005a24:	f3c3 03c1 	ubfx	r3, r3, #3, #2
 8005a28:	4836      	ldr	r0, [pc, #216]	@ (8005b04 <HAL_RCCEx_GetPeriphCLKFreq+0x8dc>)
 8005a2a:	40d8      	lsrs	r0, r3
 8005a2c:	e42a      	b.n	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
            frequency = 0U;
 8005a2e:	2000      	movs	r0, #0
 8005a30:	e428      	b.n	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
            HAL_RCCEx_GetPLL1ClockFreq(&pll1_clocks);
 8005a32:	a807      	add	r0, sp, #28
 8005a34:	f7ff f8d4 	bl	8004be0 <HAL_RCCEx_GetPLL1ClockFreq>
            frequency = pll1_clocks.PLL1_Q_Frequency;
 8005a38:	9808      	ldr	r0, [sp, #32]
            break;
 8005a3a:	e423      	b.n	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
            HAL_RCCEx_GetPLL3ClockFreq(&pll3_clocks);
 8005a3c:	a801      	add	r0, sp, #4
 8005a3e:	f7ff fae7 	bl	8005010 <HAL_RCCEx_GetPLL3ClockFreq>
            frequency = pll3_clocks.PLL3_P_Frequency;
 8005a42:	9801      	ldr	r0, [sp, #4]
            break;
 8005a44:	e41e      	b.n	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
            else if (HAL_IS_BIT_SET(RCC->CR, RCC_CR_CSIRDY) && (ckpclocksource == RCC_CLKPSOURCE_CSI))
 8005a46:	4a2e      	ldr	r2, [pc, #184]	@ (8005b00 <HAL_RCCEx_GetPeriphCLKFreq+0x8d8>)
 8005a48:	6812      	ldr	r2, [r2, #0]
 8005a4a:	f412 7f00 	tst.w	r2, #512	@ 0x200
 8005a4e:	d003      	beq.n	8005a58 <HAL_RCCEx_GetPeriphCLKFreq+0x830>
 8005a50:	f1b3 4f80 	cmp.w	r3, #1073741824	@ 0x40000000
 8005a54:	f001 80fb 	beq.w	8006c4e <HAL_RCCEx_GetPeriphCLKFreq+0x1a26>
            else if (HAL_IS_BIT_SET(RCC->CR, RCC_CR_HSERDY) && (ckpclocksource == RCC_CLKPSOURCE_HSE))
 8005a58:	4a29      	ldr	r2, [pc, #164]	@ (8005b00 <HAL_RCCEx_GetPeriphCLKFreq+0x8d8>)
 8005a5a:	6812      	ldr	r2, [r2, #0]
 8005a5c:	f412 3f00 	tst.w	r2, #131072	@ 0x20000
 8005a60:	f001 80f8 	beq.w	8006c54 <HAL_RCCEx_GetPeriphCLKFreq+0x1a2c>
 8005a64:	f1b3 4f00 	cmp.w	r3, #2147483648	@ 0x80000000
 8005a68:	f001 80f7 	beq.w	8006c5a <HAL_RCCEx_GetPeriphCLKFreq+0x1a32>
              frequency = 0U;
 8005a6c:	2000      	movs	r0, #0
 8005a6e:	e409      	b.n	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          HAL_RCCEx_GetPLL2ClockFreq(&pll2_clocks);
 8005a70:	a804      	add	r0, sp, #16
 8005a72:	f7ff f9c1 	bl	8004df8 <HAL_RCCEx_GetPLL2ClockFreq>
          frequency = pll2_clocks.PLL2_R_Frequency;
 8005a76:	9806      	ldr	r0, [sp, #24]
 8005a78:	e404      	b.n	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
        srcclk = __HAL_RCC_GET_SDMMC2_SOURCE();
 8005a7a:	4b21      	ldr	r3, [pc, #132]	@ (8005b00 <HAL_RCCEx_GetPeriphCLKFreq+0x8d8>)
 8005a7c:	f8d3 30e4 	ldr.w	r3, [r3, #228]	@ 0xe4
        if (srcclk == RCC_SDMMC2CLKSOURCE_PLL1Q)
 8005a80:	f013 0f80 	tst.w	r3, #128	@ 0x80
 8005a84:	d105      	bne.n	8005a92 <HAL_RCCEx_GetPeriphCLKFreq+0x86a>
          HAL_RCCEx_GetPLL1ClockFreq(&pll1_clocks);
 8005a86:	a807      	add	r0, sp, #28
 8005a88:	f7ff f8aa 	bl	8004be0 <HAL_RCCEx_GetPLL1ClockFreq>
          frequency = pll1_clocks.PLL1_Q_Frequency;
 8005a8c:	9808      	ldr	r0, [sp, #32]
 8005a8e:	f7ff bbf9 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          HAL_RCCEx_GetPLL2ClockFreq(&pll2_clocks);
 8005a92:	a804      	add	r0, sp, #16
 8005a94:	f7ff f9b0 	bl	8004df8 <HAL_RCCEx_GetPLL2ClockFreq>
          frequency = pll2_clocks.PLL2_R_Frequency;
 8005a98:	9806      	ldr	r0, [sp, #24]
 8005a9a:	f7ff bbf3 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
        srcclk = __HAL_RCC_GET_USART1_SOURCE();
 8005a9e:	4b18      	ldr	r3, [pc, #96]	@ (8005b00 <HAL_RCCEx_GetPeriphCLKFreq+0x8d8>)
 8005aa0:	f8d3 30d8 	ldr.w	r3, [r3, #216]	@ 0xd8
        if (srcclk == RCC_USART1CLKSOURCE_PCLK2)
 8005aa4:	f013 0307 	ands.w	r3, r3, #7
 8005aa8:	d02e      	beq.n	8005b08 <HAL_RCCEx_GetPeriphCLKFreq+0x8e0>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_PLL2RDY)) && (srcclk == RCC_USART1CLKSOURCE_PLL2Q))
 8005aaa:	4a15      	ldr	r2, [pc, #84]	@ (8005b00 <HAL_RCCEx_GetPeriphCLKFreq+0x8d8>)
 8005aac:	6812      	ldr	r2, [r2, #0]
 8005aae:	f012 6f00 	tst.w	r2, #134217728	@ 0x8000000
 8005ab2:	d001      	beq.n	8005ab8 <HAL_RCCEx_GetPeriphCLKFreq+0x890>
 8005ab4:	2b01      	cmp	r3, #1
 8005ab6:	d02b      	beq.n	8005b10 <HAL_RCCEx_GetPeriphCLKFreq+0x8e8>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_PLL3RDY)) && (srcclk == RCC_USART1CLKSOURCE_PLL3Q))
 8005ab8:	4a11      	ldr	r2, [pc, #68]	@ (8005b00 <HAL_RCCEx_GetPeriphCLKFreq+0x8d8>)
 8005aba:	6812      	ldr	r2, [r2, #0]
 8005abc:	f012 5f00 	tst.w	r2, #536870912	@ 0x20000000
 8005ac0:	d001      	beq.n	8005ac6 <HAL_RCCEx_GetPeriphCLKFreq+0x89e>
 8005ac2:	2b02      	cmp	r3, #2
 8005ac4:	d02a      	beq.n	8005b1c <HAL_RCCEx_GetPeriphCLKFreq+0x8f4>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_HSIRDY)) && (srcclk == RCC_USART1CLKSOURCE_HSI))
 8005ac6:	4a0e      	ldr	r2, [pc, #56]	@ (8005b00 <HAL_RCCEx_GetPeriphCLKFreq+0x8d8>)
 8005ac8:	6812      	ldr	r2, [r2, #0]
 8005aca:	f012 0f02 	tst.w	r2, #2
 8005ace:	d001      	beq.n	8005ad4 <HAL_RCCEx_GetPeriphCLKFreq+0x8ac>
 8005ad0:	2b03      	cmp	r3, #3
 8005ad2:	d029      	beq.n	8005b28 <HAL_RCCEx_GetPeriphCLKFreq+0x900>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_CSIRDY)) && (srcclk == RCC_USART1CLKSOURCE_CSI))
 8005ad4:	4a0a      	ldr	r2, [pc, #40]	@ (8005b00 <HAL_RCCEx_GetPeriphCLKFreq+0x8d8>)
 8005ad6:	6812      	ldr	r2, [r2, #0]
 8005ad8:	f412 7f00 	tst.w	r2, #512	@ 0x200
 8005adc:	d002      	beq.n	8005ae4 <HAL_RCCEx_GetPeriphCLKFreq+0x8bc>
 8005ade:	2b04      	cmp	r3, #4
 8005ae0:	f001 80be 	beq.w	8006c60 <HAL_RCCEx_GetPeriphCLKFreq+0x1a38>
        else if ((HAL_IS_BIT_SET(RCC->BDCR, RCC_BDCR_LSERDY)) && (srcclk == RCC_USART1CLKSOURCE_LSE))
 8005ae4:	4a06      	ldr	r2, [pc, #24]	@ (8005b00 <HAL_RCCEx_GetPeriphCLKFreq+0x8d8>)
 8005ae6:	f8d2 20f0 	ldr.w	r2, [r2, #240]	@ 0xf0
 8005aea:	f012 0f02 	tst.w	r2, #2
 8005aee:	f001 80ba 	beq.w	8006c66 <HAL_RCCEx_GetPeriphCLKFreq+0x1a3e>
 8005af2:	2b05      	cmp	r3, #5
 8005af4:	f001 80ba 	beq.w	8006c6c <HAL_RCCEx_GetPeriphCLKFreq+0x1a44>
          frequency = 0U;
 8005af8:	2000      	movs	r0, #0
 8005afa:	f7ff bbc3 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
 8005afe:	bf00      	nop
 8005b00:	44020c00 	.word	0x44020c00
 8005b04:	03d09000 	.word	0x03d09000
          frequency = HAL_RCC_GetPCLK2Freq();
 8005b08:	f7fd fee6 	bl	80038d8 <HAL_RCC_GetPCLK2Freq>
 8005b0c:	f7ff bbba 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          HAL_RCCEx_GetPLL2ClockFreq(&pll2_clocks);
 8005b10:	a804      	add	r0, sp, #16
 8005b12:	f7ff f971 	bl	8004df8 <HAL_RCCEx_GetPLL2ClockFreq>
          frequency = pll2_clocks.PLL2_Q_Frequency;
 8005b16:	9805      	ldr	r0, [sp, #20]
 8005b18:	f7ff bbb4 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          HAL_RCCEx_GetPLL3ClockFreq(&pll3_clocks);
 8005b1c:	a801      	add	r0, sp, #4
 8005b1e:	f7ff fa77 	bl	8005010 <HAL_RCCEx_GetPLL3ClockFreq>
          frequency = pll3_clocks.PLL3_Q_Frequency;
 8005b22:	9802      	ldr	r0, [sp, #8]
 8005b24:	f7ff bbae 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = (HSI_VALUE >> (__HAL_RCC_GET_HSI_DIVIDER() >> RCC_CR_HSIDIV_Pos));
 8005b28:	4b97      	ldr	r3, [pc, #604]	@ (8005d88 <HAL_RCCEx_GetPeriphCLKFreq+0xb60>)
 8005b2a:	681b      	ldr	r3, [r3, #0]
 8005b2c:	f3c3 03c1 	ubfx	r3, r3, #3, #2
 8005b30:	4896      	ldr	r0, [pc, #600]	@ (8005d8c <HAL_RCCEx_GetPeriphCLKFreq+0xb64>)
 8005b32:	40d8      	lsrs	r0, r3
 8005b34:	f7ff bba6 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
        srcclk = __HAL_RCC_GET_USART2_SOURCE();
 8005b38:	4b93      	ldr	r3, [pc, #588]	@ (8005d88 <HAL_RCCEx_GetPeriphCLKFreq+0xb60>)
 8005b3a:	f8d3 30d8 	ldr.w	r3, [r3, #216]	@ 0xd8
        if (srcclk == RCC_USART2CLKSOURCE_PCLK1)
 8005b3e:	f013 0338 	ands.w	r3, r3, #56	@ 0x38
 8005b42:	d024      	beq.n	8005b8e <HAL_RCCEx_GetPeriphCLKFreq+0x966>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_PLL2RDY)) && (srcclk == RCC_USART2CLKSOURCE_PLL2Q))
 8005b44:	4a90      	ldr	r2, [pc, #576]	@ (8005d88 <HAL_RCCEx_GetPeriphCLKFreq+0xb60>)
 8005b46:	6812      	ldr	r2, [r2, #0]
 8005b48:	f012 6f00 	tst.w	r2, #134217728	@ 0x8000000
 8005b4c:	d001      	beq.n	8005b52 <HAL_RCCEx_GetPeriphCLKFreq+0x92a>
 8005b4e:	2b08      	cmp	r3, #8
 8005b50:	d021      	beq.n	8005b96 <HAL_RCCEx_GetPeriphCLKFreq+0x96e>
        else if ((srcclk == RCC_USART2CLKSOURCE_PLL3Q))
 8005b52:	2b10      	cmp	r3, #16
 8005b54:	d025      	beq.n	8005ba2 <HAL_RCCEx_GetPeriphCLKFreq+0x97a>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_HSIRDY)) && (srcclk == RCC_USART2CLKSOURCE_HSI))
 8005b56:	4a8c      	ldr	r2, [pc, #560]	@ (8005d88 <HAL_RCCEx_GetPeriphCLKFreq+0xb60>)
 8005b58:	6812      	ldr	r2, [r2, #0]
 8005b5a:	f012 0f02 	tst.w	r2, #2
 8005b5e:	d001      	beq.n	8005b64 <HAL_RCCEx_GetPeriphCLKFreq+0x93c>
 8005b60:	2b18      	cmp	r3, #24
 8005b62:	d024      	beq.n	8005bae <HAL_RCCEx_GetPeriphCLKFreq+0x986>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_CSIRDY)) && (srcclk == RCC_USART2CLKSOURCE_CSI))
 8005b64:	4a88      	ldr	r2, [pc, #544]	@ (8005d88 <HAL_RCCEx_GetPeriphCLKFreq+0xb60>)
 8005b66:	6812      	ldr	r2, [r2, #0]
 8005b68:	f412 7f00 	tst.w	r2, #512	@ 0x200
 8005b6c:	d002      	beq.n	8005b74 <HAL_RCCEx_GetPeriphCLKFreq+0x94c>
 8005b6e:	2b20      	cmp	r3, #32
 8005b70:	f001 8080 	beq.w	8006c74 <HAL_RCCEx_GetPeriphCLKFreq+0x1a4c>
        else if ((HAL_IS_BIT_SET(RCC->BDCR, RCC_BDCR_LSERDY)) && (srcclk == RCC_USART2CLKSOURCE_LSE))
 8005b74:	4a84      	ldr	r2, [pc, #528]	@ (8005d88 <HAL_RCCEx_GetPeriphCLKFreq+0xb60>)
 8005b76:	f8d2 20f0 	ldr.w	r2, [r2, #240]	@ 0xf0
 8005b7a:	f012 0f02 	tst.w	r2, #2
 8005b7e:	f001 807c 	beq.w	8006c7a <HAL_RCCEx_GetPeriphCLKFreq+0x1a52>
 8005b82:	2b28      	cmp	r3, #40	@ 0x28
 8005b84:	f001 807c 	beq.w	8006c80 <HAL_RCCEx_GetPeriphCLKFreq+0x1a58>
          frequency = 0U;
 8005b88:	2000      	movs	r0, #0
 8005b8a:	f7ff bb7b 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = HAL_RCC_GetPCLK1Freq();
 8005b8e:	f7fd fe91 	bl	80038b4 <HAL_RCC_GetPCLK1Freq>
 8005b92:	f7ff bb77 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          HAL_RCCEx_GetPLL2ClockFreq(&pll2_clocks);
 8005b96:	a804      	add	r0, sp, #16
 8005b98:	f7ff f92e 	bl	8004df8 <HAL_RCCEx_GetPLL2ClockFreq>
          frequency = pll2_clocks.PLL2_Q_Frequency;
 8005b9c:	9805      	ldr	r0, [sp, #20]
 8005b9e:	f7ff bb71 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          HAL_RCCEx_GetPLL3ClockFreq(&pll3_clocks);
 8005ba2:	a801      	add	r0, sp, #4
 8005ba4:	f7ff fa34 	bl	8005010 <HAL_RCCEx_GetPLL3ClockFreq>
          frequency = pll3_clocks.PLL3_Q_Frequency;
 8005ba8:	9802      	ldr	r0, [sp, #8]
 8005baa:	f7ff bb6b 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = (HSI_VALUE >> (__HAL_RCC_GET_HSI_DIVIDER() >> RCC_CR_HSIDIV_Pos));
 8005bae:	4b76      	ldr	r3, [pc, #472]	@ (8005d88 <HAL_RCCEx_GetPeriphCLKFreq+0xb60>)
 8005bb0:	681b      	ldr	r3, [r3, #0]
 8005bb2:	f3c3 03c1 	ubfx	r3, r3, #3, #2
 8005bb6:	4875      	ldr	r0, [pc, #468]	@ (8005d8c <HAL_RCCEx_GetPeriphCLKFreq+0xb64>)
 8005bb8:	40d8      	lsrs	r0, r3
 8005bba:	f7ff bb63 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
        srcclk = __HAL_RCC_GET_USART3_SOURCE();
 8005bbe:	4b72      	ldr	r3, [pc, #456]	@ (8005d88 <HAL_RCCEx_GetPeriphCLKFreq+0xb60>)
 8005bc0:	f8d3 30d8 	ldr.w	r3, [r3, #216]	@ 0xd8
        if (srcclk == RCC_USART3CLKSOURCE_PCLK1)
 8005bc4:	f413 73e0 	ands.w	r3, r3, #448	@ 0x1c0
 8005bc8:	d02b      	beq.n	8005c22 <HAL_RCCEx_GetPeriphCLKFreq+0x9fa>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_PLL2RDY)) && (srcclk == RCC_USART3CLKSOURCE_PLL2Q))
 8005bca:	4a6f      	ldr	r2, [pc, #444]	@ (8005d88 <HAL_RCCEx_GetPeriphCLKFreq+0xb60>)
 8005bcc:	6812      	ldr	r2, [r2, #0]
 8005bce:	f012 6f00 	tst.w	r2, #134217728	@ 0x8000000
 8005bd2:	d001      	beq.n	8005bd8 <HAL_RCCEx_GetPeriphCLKFreq+0x9b0>
 8005bd4:	2b40      	cmp	r3, #64	@ 0x40
 8005bd6:	d028      	beq.n	8005c2a <HAL_RCCEx_GetPeriphCLKFreq+0xa02>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_PLL3RDY)) && (srcclk == RCC_USART3CLKSOURCE_PLL3Q))
 8005bd8:	4a6b      	ldr	r2, [pc, #428]	@ (8005d88 <HAL_RCCEx_GetPeriphCLKFreq+0xb60>)
 8005bda:	6812      	ldr	r2, [r2, #0]
 8005bdc:	f012 5f00 	tst.w	r2, #536870912	@ 0x20000000
 8005be0:	d001      	beq.n	8005be6 <HAL_RCCEx_GetPeriphCLKFreq+0x9be>
 8005be2:	2b80      	cmp	r3, #128	@ 0x80
 8005be4:	d027      	beq.n	8005c36 <HAL_RCCEx_GetPeriphCLKFreq+0xa0e>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_HSIRDY)) && (srcclk == RCC_USART3CLKSOURCE_HSI))
 8005be6:	4a68      	ldr	r2, [pc, #416]	@ (8005d88 <HAL_RCCEx_GetPeriphCLKFreq+0xb60>)
 8005be8:	6812      	ldr	r2, [r2, #0]
 8005bea:	f012 0f02 	tst.w	r2, #2
 8005bee:	d001      	beq.n	8005bf4 <HAL_RCCEx_GetPeriphCLKFreq+0x9cc>
 8005bf0:	2bc0      	cmp	r3, #192	@ 0xc0
 8005bf2:	d026      	beq.n	8005c42 <HAL_RCCEx_GetPeriphCLKFreq+0xa1a>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_CSIRDY)) && (srcclk == RCC_USART3CLKSOURCE_CSI))
 8005bf4:	4a64      	ldr	r2, [pc, #400]	@ (8005d88 <HAL_RCCEx_GetPeriphCLKFreq+0xb60>)
 8005bf6:	6812      	ldr	r2, [r2, #0]
 8005bf8:	f412 7f00 	tst.w	r2, #512	@ 0x200
 8005bfc:	d003      	beq.n	8005c06 <HAL_RCCEx_GetPeriphCLKFreq+0x9de>
 8005bfe:	f5b3 7f80 	cmp.w	r3, #256	@ 0x100
 8005c02:	f001 8041 	beq.w	8006c88 <HAL_RCCEx_GetPeriphCLKFreq+0x1a60>
        else if ((HAL_IS_BIT_SET(RCC->BDCR, RCC_BDCR_LSERDY)) && (srcclk == RCC_USART3CLKSOURCE_LSE))
 8005c06:	4a60      	ldr	r2, [pc, #384]	@ (8005d88 <HAL_RCCEx_GetPeriphCLKFreq+0xb60>)
 8005c08:	f8d2 20f0 	ldr.w	r2, [r2, #240]	@ 0xf0
 8005c0c:	f012 0f02 	tst.w	r2, #2
 8005c10:	f001 803d 	beq.w	8006c8e <HAL_RCCEx_GetPeriphCLKFreq+0x1a66>
 8005c14:	f5b3 7fa0 	cmp.w	r3, #320	@ 0x140
 8005c18:	f001 803c 	beq.w	8006c94 <HAL_RCCEx_GetPeriphCLKFreq+0x1a6c>
          frequency = 0U;
 8005c1c:	2000      	movs	r0, #0
 8005c1e:	f7ff bb31 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = HAL_RCC_GetPCLK1Freq();
 8005c22:	f7fd fe47 	bl	80038b4 <HAL_RCC_GetPCLK1Freq>
 8005c26:	f7ff bb2d 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          HAL_RCCEx_GetPLL2ClockFreq(&pll2_clocks);
 8005c2a:	a804      	add	r0, sp, #16
 8005c2c:	f7ff f8e4 	bl	8004df8 <HAL_RCCEx_GetPLL2ClockFreq>
          frequency = pll2_clocks.PLL2_Q_Frequency;
 8005c30:	9805      	ldr	r0, [sp, #20]
 8005c32:	f7ff bb27 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          HAL_RCCEx_GetPLL3ClockFreq(&pll3_clocks);
 8005c36:	a801      	add	r0, sp, #4
 8005c38:	f7ff f9ea 	bl	8005010 <HAL_RCCEx_GetPLL3ClockFreq>
          frequency = pll3_clocks.PLL3_Q_Frequency;
 8005c3c:	9802      	ldr	r0, [sp, #8]
 8005c3e:	f7ff bb21 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = (HSI_VALUE >> (__HAL_RCC_GET_HSI_DIVIDER() >> RCC_CR_HSIDIV_Pos));
 8005c42:	4b51      	ldr	r3, [pc, #324]	@ (8005d88 <HAL_RCCEx_GetPeriphCLKFreq+0xb60>)
 8005c44:	681b      	ldr	r3, [r3, #0]
 8005c46:	f3c3 03c1 	ubfx	r3, r3, #3, #2
 8005c4a:	4850      	ldr	r0, [pc, #320]	@ (8005d8c <HAL_RCCEx_GetPeriphCLKFreq+0xb64>)
 8005c4c:	40d8      	lsrs	r0, r3
 8005c4e:	f7ff bb19 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
        srcclk = __HAL_RCC_GET_UART4_SOURCE();
 8005c52:	4b4d      	ldr	r3, [pc, #308]	@ (8005d88 <HAL_RCCEx_GetPeriphCLKFreq+0xb60>)
 8005c54:	f8d3 30d8 	ldr.w	r3, [r3, #216]	@ 0xd8
        if (srcclk == RCC_UART4CLKSOURCE_PCLK1)
 8005c58:	f413 6360 	ands.w	r3, r3, #3584	@ 0xe00
 8005c5c:	d02e      	beq.n	8005cbc <HAL_RCCEx_GetPeriphCLKFreq+0xa94>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_PLL2RDY)) && (srcclk == RCC_UART4CLKSOURCE_PLL2Q))
 8005c5e:	4a4a      	ldr	r2, [pc, #296]	@ (8005d88 <HAL_RCCEx_GetPeriphCLKFreq+0xb60>)
 8005c60:	6812      	ldr	r2, [r2, #0]
 8005c62:	f012 6f00 	tst.w	r2, #134217728	@ 0x8000000
 8005c66:	d002      	beq.n	8005c6e <HAL_RCCEx_GetPeriphCLKFreq+0xa46>
 8005c68:	f5b3 7f00 	cmp.w	r3, #512	@ 0x200
 8005c6c:	d02a      	beq.n	8005cc4 <HAL_RCCEx_GetPeriphCLKFreq+0xa9c>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_PLL3RDY)) && (srcclk == RCC_UART4CLKSOURCE_PLL3Q))
 8005c6e:	4a46      	ldr	r2, [pc, #280]	@ (8005d88 <HAL_RCCEx_GetPeriphCLKFreq+0xb60>)
 8005c70:	6812      	ldr	r2, [r2, #0]
 8005c72:	f012 5f00 	tst.w	r2, #536870912	@ 0x20000000
 8005c76:	d002      	beq.n	8005c7e <HAL_RCCEx_GetPeriphCLKFreq+0xa56>
 8005c78:	f5b3 6f80 	cmp.w	r3, #1024	@ 0x400
 8005c7c:	d028      	beq.n	8005cd0 <HAL_RCCEx_GetPeriphCLKFreq+0xaa8>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_HSIRDY)) && (srcclk == RCC_UART4CLKSOURCE_HSI))
 8005c7e:	4a42      	ldr	r2, [pc, #264]	@ (8005d88 <HAL_RCCEx_GetPeriphCLKFreq+0xb60>)
 8005c80:	6812      	ldr	r2, [r2, #0]
 8005c82:	f012 0f02 	tst.w	r2, #2
 8005c86:	d002      	beq.n	8005c8e <HAL_RCCEx_GetPeriphCLKFreq+0xa66>
 8005c88:	f5b3 6fc0 	cmp.w	r3, #1536	@ 0x600
 8005c8c:	d026      	beq.n	8005cdc <HAL_RCCEx_GetPeriphCLKFreq+0xab4>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_CSIRDY)) && (srcclk == RCC_UART4CLKSOURCE_CSI))
 8005c8e:	4a3e      	ldr	r2, [pc, #248]	@ (8005d88 <HAL_RCCEx_GetPeriphCLKFreq+0xb60>)
 8005c90:	6812      	ldr	r2, [r2, #0]
 8005c92:	f412 7f00 	tst.w	r2, #512	@ 0x200
 8005c96:	d003      	beq.n	8005ca0 <HAL_RCCEx_GetPeriphCLKFreq+0xa78>
 8005c98:	f5b3 6f00 	cmp.w	r3, #2048	@ 0x800
 8005c9c:	f000 87fe 	beq.w	8006c9c <HAL_RCCEx_GetPeriphCLKFreq+0x1a74>
        else if ((HAL_IS_BIT_SET(RCC->BDCR, RCC_BDCR_LSERDY)) && (srcclk == RCC_UART4CLKSOURCE_LSE))
 8005ca0:	4a39      	ldr	r2, [pc, #228]	@ (8005d88 <HAL_RCCEx_GetPeriphCLKFreq+0xb60>)
 8005ca2:	f8d2 20f0 	ldr.w	r2, [r2, #240]	@ 0xf0
 8005ca6:	f012 0f02 	tst.w	r2, #2
 8005caa:	f000 87fa 	beq.w	8006ca2 <HAL_RCCEx_GetPeriphCLKFreq+0x1a7a>
 8005cae:	f5b3 6f20 	cmp.w	r3, #2560	@ 0xa00
 8005cb2:	f000 87f9 	beq.w	8006ca8 <HAL_RCCEx_GetPeriphCLKFreq+0x1a80>
          frequency = 0U;
 8005cb6:	2000      	movs	r0, #0
 8005cb8:	f7ff bae4 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = HAL_RCC_GetPCLK1Freq();
 8005cbc:	f7fd fdfa 	bl	80038b4 <HAL_RCC_GetPCLK1Freq>
 8005cc0:	f7ff bae0 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          HAL_RCCEx_GetPLL2ClockFreq(&pll2_clocks);
 8005cc4:	a804      	add	r0, sp, #16
 8005cc6:	f7ff f897 	bl	8004df8 <HAL_RCCEx_GetPLL2ClockFreq>
          frequency = pll2_clocks.PLL2_Q_Frequency;
 8005cca:	9805      	ldr	r0, [sp, #20]
 8005ccc:	f7ff bada 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          HAL_RCCEx_GetPLL3ClockFreq(&pll3_clocks);
 8005cd0:	a801      	add	r0, sp, #4
 8005cd2:	f7ff f99d 	bl	8005010 <HAL_RCCEx_GetPLL3ClockFreq>
          frequency = pll3_clocks.PLL3_Q_Frequency;
 8005cd6:	9802      	ldr	r0, [sp, #8]
 8005cd8:	f7ff bad4 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = (HSI_VALUE >> (__HAL_RCC_GET_HSI_DIVIDER() >> RCC_CR_HSIDIV_Pos));
 8005cdc:	4b2a      	ldr	r3, [pc, #168]	@ (8005d88 <HAL_RCCEx_GetPeriphCLKFreq+0xb60>)
 8005cde:	681b      	ldr	r3, [r3, #0]
 8005ce0:	f3c3 03c1 	ubfx	r3, r3, #3, #2
 8005ce4:	4829      	ldr	r0, [pc, #164]	@ (8005d8c <HAL_RCCEx_GetPeriphCLKFreq+0xb64>)
 8005ce6:	40d8      	lsrs	r0, r3
 8005ce8:	f7ff bacc 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
        srcclk = __HAL_RCC_GET_UART5_SOURCE();
 8005cec:	4b26      	ldr	r3, [pc, #152]	@ (8005d88 <HAL_RCCEx_GetPeriphCLKFreq+0xb60>)
 8005cee:	f8d3 30d8 	ldr.w	r3, [r3, #216]	@ 0xd8
        if (srcclk == RCC_UART5CLKSOURCE_PCLK1)
 8005cf2:	f413 43e0 	ands.w	r3, r3, #28672	@ 0x7000
 8005cf6:	d02e      	beq.n	8005d56 <HAL_RCCEx_GetPeriphCLKFreq+0xb2e>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_PLL2RDY)) && (srcclk == RCC_UART5CLKSOURCE_PLL2Q))
 8005cf8:	4a23      	ldr	r2, [pc, #140]	@ (8005d88 <HAL_RCCEx_GetPeriphCLKFreq+0xb60>)
 8005cfa:	6812      	ldr	r2, [r2, #0]
 8005cfc:	f012 6f00 	tst.w	r2, #134217728	@ 0x8000000
 8005d00:	d002      	beq.n	8005d08 <HAL_RCCEx_GetPeriphCLKFreq+0xae0>
 8005d02:	f5b3 5f80 	cmp.w	r3, #4096	@ 0x1000
 8005d06:	d02a      	beq.n	8005d5e <HAL_RCCEx_GetPeriphCLKFreq+0xb36>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_PLL3RDY)) && (srcclk == RCC_UART5CLKSOURCE_PLL3Q))
 8005d08:	4a1f      	ldr	r2, [pc, #124]	@ (8005d88 <HAL_RCCEx_GetPeriphCLKFreq+0xb60>)
 8005d0a:	6812      	ldr	r2, [r2, #0]
 8005d0c:	f012 5f00 	tst.w	r2, #536870912	@ 0x20000000
 8005d10:	d002      	beq.n	8005d18 <HAL_RCCEx_GetPeriphCLKFreq+0xaf0>
 8005d12:	f5b3 5f00 	cmp.w	r3, #8192	@ 0x2000
 8005d16:	d028      	beq.n	8005d6a <HAL_RCCEx_GetPeriphCLKFreq+0xb42>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_HSIRDY)) && (srcclk == RCC_UART5CLKSOURCE_HSI))
 8005d18:	4a1b      	ldr	r2, [pc, #108]	@ (8005d88 <HAL_RCCEx_GetPeriphCLKFreq+0xb60>)
 8005d1a:	6812      	ldr	r2, [r2, #0]
 8005d1c:	f012 0f02 	tst.w	r2, #2
 8005d20:	d002      	beq.n	8005d28 <HAL_RCCEx_GetPeriphCLKFreq+0xb00>
 8005d22:	f5b3 5f40 	cmp.w	r3, #12288	@ 0x3000
 8005d26:	d026      	beq.n	8005d76 <HAL_RCCEx_GetPeriphCLKFreq+0xb4e>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_CSIRDY)) && (srcclk == RCC_UART5CLKSOURCE_CSI))
 8005d28:	4a17      	ldr	r2, [pc, #92]	@ (8005d88 <HAL_RCCEx_GetPeriphCLKFreq+0xb60>)
 8005d2a:	6812      	ldr	r2, [r2, #0]
 8005d2c:	f412 7f00 	tst.w	r2, #512	@ 0x200
 8005d30:	d003      	beq.n	8005d3a <HAL_RCCEx_GetPeriphCLKFreq+0xb12>
 8005d32:	f5b3 4f80 	cmp.w	r3, #16384	@ 0x4000
 8005d36:	f000 87bb 	beq.w	8006cb0 <HAL_RCCEx_GetPeriphCLKFreq+0x1a88>
        else if ((HAL_IS_BIT_SET(RCC->BDCR, RCC_BDCR_LSERDY)) && (srcclk == RCC_UART5CLKSOURCE_LSE))
 8005d3a:	4a13      	ldr	r2, [pc, #76]	@ (8005d88 <HAL_RCCEx_GetPeriphCLKFreq+0xb60>)
 8005d3c:	f8d2 20f0 	ldr.w	r2, [r2, #240]	@ 0xf0
 8005d40:	f012 0f02 	tst.w	r2, #2
 8005d44:	f000 87b7 	beq.w	8006cb6 <HAL_RCCEx_GetPeriphCLKFreq+0x1a8e>
 8005d48:	f5b3 4fa0 	cmp.w	r3, #20480	@ 0x5000
 8005d4c:	f000 87b6 	beq.w	8006cbc <HAL_RCCEx_GetPeriphCLKFreq+0x1a94>
          frequency = 0U;
 8005d50:	2000      	movs	r0, #0
 8005d52:	f7ff ba97 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = HAL_RCC_GetPCLK1Freq();
 8005d56:	f7fd fdad 	bl	80038b4 <HAL_RCC_GetPCLK1Freq>
 8005d5a:	f7ff ba93 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          HAL_RCCEx_GetPLL2ClockFreq(&pll2_clocks);
 8005d5e:	a804      	add	r0, sp, #16
 8005d60:	f7ff f84a 	bl	8004df8 <HAL_RCCEx_GetPLL2ClockFreq>
          frequency = pll2_clocks.PLL2_Q_Frequency;
 8005d64:	9805      	ldr	r0, [sp, #20]
 8005d66:	f7ff ba8d 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          HAL_RCCEx_GetPLL3ClockFreq(&pll3_clocks);
 8005d6a:	a801      	add	r0, sp, #4
 8005d6c:	f7ff f950 	bl	8005010 <HAL_RCCEx_GetPLL3ClockFreq>
          frequency = pll3_clocks.PLL3_Q_Frequency;
 8005d70:	9802      	ldr	r0, [sp, #8]
 8005d72:	f7ff ba87 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = (HSI_VALUE >> (__HAL_RCC_GET_HSI_DIVIDER() >> RCC_CR_HSIDIV_Pos));
 8005d76:	4b04      	ldr	r3, [pc, #16]	@ (8005d88 <HAL_RCCEx_GetPeriphCLKFreq+0xb60>)
 8005d78:	681b      	ldr	r3, [r3, #0]
 8005d7a:	f3c3 03c1 	ubfx	r3, r3, #3, #2
 8005d7e:	4803      	ldr	r0, [pc, #12]	@ (8005d8c <HAL_RCCEx_GetPeriphCLKFreq+0xb64>)
 8005d80:	40d8      	lsrs	r0, r3
 8005d82:	f7ff ba7f 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
 8005d86:	bf00      	nop
 8005d88:	44020c00 	.word	0x44020c00
 8005d8c:	03d09000 	.word	0x03d09000
        srcclk = __HAL_RCC_GET_USART6_SOURCE();
 8005d90:	4bab      	ldr	r3, [pc, #684]	@ (8006040 <HAL_RCCEx_GetPeriphCLKFreq+0xe18>)
 8005d92:	f8d3 30d8 	ldr.w	r3, [r3, #216]	@ 0xd8
        if (srcclk == RCC_USART6CLKSOURCE_PCLK1)
 8005d96:	f413 3360 	ands.w	r3, r3, #229376	@ 0x38000
 8005d9a:	d02e      	beq.n	8005dfa <HAL_RCCEx_GetPeriphCLKFreq+0xbd2>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_PLL2RDY)) && (srcclk == RCC_USART6CLKSOURCE_PLL2Q))
 8005d9c:	4aa8      	ldr	r2, [pc, #672]	@ (8006040 <HAL_RCCEx_GetPeriphCLKFreq+0xe18>)
 8005d9e:	6812      	ldr	r2, [r2, #0]
 8005da0:	f012 6f00 	tst.w	r2, #134217728	@ 0x8000000
 8005da4:	d002      	beq.n	8005dac <HAL_RCCEx_GetPeriphCLKFreq+0xb84>
 8005da6:	f5b3 4f00 	cmp.w	r3, #32768	@ 0x8000
 8005daa:	d02a      	beq.n	8005e02 <HAL_RCCEx_GetPeriphCLKFreq+0xbda>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_PLL3RDY)) && (srcclk == RCC_USART6CLKSOURCE_PLL3Q))
 8005dac:	4aa4      	ldr	r2, [pc, #656]	@ (8006040 <HAL_RCCEx_GetPeriphCLKFreq+0xe18>)
 8005dae:	6812      	ldr	r2, [r2, #0]
 8005db0:	f012 5f00 	tst.w	r2, #536870912	@ 0x20000000
 8005db4:	d002      	beq.n	8005dbc <HAL_RCCEx_GetPeriphCLKFreq+0xb94>
 8005db6:	f5b3 3f80 	cmp.w	r3, #65536	@ 0x10000
 8005dba:	d028      	beq.n	8005e0e <HAL_RCCEx_GetPeriphCLKFreq+0xbe6>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_HSIRDY)) && (srcclk == RCC_USART6CLKSOURCE_HSI))
 8005dbc:	4aa0      	ldr	r2, [pc, #640]	@ (8006040 <HAL_RCCEx_GetPeriphCLKFreq+0xe18>)
 8005dbe:	6812      	ldr	r2, [r2, #0]
 8005dc0:	f012 0f02 	tst.w	r2, #2
 8005dc4:	d002      	beq.n	8005dcc <HAL_RCCEx_GetPeriphCLKFreq+0xba4>
 8005dc6:	f5b3 3fc0 	cmp.w	r3, #98304	@ 0x18000
 8005dca:	d026      	beq.n	8005e1a <HAL_RCCEx_GetPeriphCLKFreq+0xbf2>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_CSIRDY)) && (srcclk == RCC_USART6CLKSOURCE_CSI))
 8005dcc:	4a9c      	ldr	r2, [pc, #624]	@ (8006040 <HAL_RCCEx_GetPeriphCLKFreq+0xe18>)
 8005dce:	6812      	ldr	r2, [r2, #0]
 8005dd0:	f412 7f00 	tst.w	r2, #512	@ 0x200
 8005dd4:	d003      	beq.n	8005dde <HAL_RCCEx_GetPeriphCLKFreq+0xbb6>
 8005dd6:	f5b3 3f00 	cmp.w	r3, #131072	@ 0x20000
 8005dda:	f000 8773 	beq.w	8006cc4 <HAL_RCCEx_GetPeriphCLKFreq+0x1a9c>
        else if ((HAL_IS_BIT_SET(RCC->BDCR, RCC_BDCR_LSERDY)) && (srcclk == RCC_USART6CLKSOURCE_LSE))
 8005dde:	4a98      	ldr	r2, [pc, #608]	@ (8006040 <HAL_RCCEx_GetPeriphCLKFreq+0xe18>)
 8005de0:	f8d2 20f0 	ldr.w	r2, [r2, #240]	@ 0xf0
 8005de4:	f012 0f02 	tst.w	r2, #2
 8005de8:	f000 876f 	beq.w	8006cca <HAL_RCCEx_GetPeriphCLKFreq+0x1aa2>
 8005dec:	f5b3 3f20 	cmp.w	r3, #163840	@ 0x28000
 8005df0:	f000 876e 	beq.w	8006cd0 <HAL_RCCEx_GetPeriphCLKFreq+0x1aa8>
          frequency = 0U;
 8005df4:	2000      	movs	r0, #0
 8005df6:	f7ff ba45 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = HAL_RCC_GetPCLK1Freq();
 8005dfa:	f7fd fd5b 	bl	80038b4 <HAL_RCC_GetPCLK1Freq>
 8005dfe:	f7ff ba41 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          HAL_RCCEx_GetPLL2ClockFreq(&pll2_clocks);
 8005e02:	a804      	add	r0, sp, #16
 8005e04:	f7fe fff8 	bl	8004df8 <HAL_RCCEx_GetPLL2ClockFreq>
          frequency = pll2_clocks.PLL2_Q_Frequency;
 8005e08:	9805      	ldr	r0, [sp, #20]
 8005e0a:	f7ff ba3b 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          HAL_RCCEx_GetPLL3ClockFreq(&pll3_clocks);
 8005e0e:	a801      	add	r0, sp, #4
 8005e10:	f7ff f8fe 	bl	8005010 <HAL_RCCEx_GetPLL3ClockFreq>
          frequency = pll3_clocks.PLL3_Q_Frequency;
 8005e14:	9802      	ldr	r0, [sp, #8]
 8005e16:	f7ff ba35 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = (HSI_VALUE >> (__HAL_RCC_GET_HSI_DIVIDER() >> RCC_CR_HSIDIV_Pos));
 8005e1a:	4b89      	ldr	r3, [pc, #548]	@ (8006040 <HAL_RCCEx_GetPeriphCLKFreq+0xe18>)
 8005e1c:	681b      	ldr	r3, [r3, #0]
 8005e1e:	f3c3 03c1 	ubfx	r3, r3, #3, #2
 8005e22:	4888      	ldr	r0, [pc, #544]	@ (8006044 <HAL_RCCEx_GetPeriphCLKFreq+0xe1c>)
 8005e24:	40d8      	lsrs	r0, r3
 8005e26:	f7ff ba2d 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
        srcclk = __HAL_RCC_GET_UART7_SOURCE();
 8005e2a:	4b85      	ldr	r3, [pc, #532]	@ (8006040 <HAL_RCCEx_GetPeriphCLKFreq+0xe18>)
 8005e2c:	f8d3 30d8 	ldr.w	r3, [r3, #216]	@ 0xd8
        if (srcclk == RCC_UART7CLKSOURCE_PCLK1)
 8005e30:	f413 13e0 	ands.w	r3, r3, #1835008	@ 0x1c0000
 8005e34:	d02e      	beq.n	8005e94 <HAL_RCCEx_GetPeriphCLKFreq+0xc6c>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_PLL2RDY)) && (srcclk == RCC_UART7CLKSOURCE_PLL2Q))
 8005e36:	4a82      	ldr	r2, [pc, #520]	@ (8006040 <HAL_RCCEx_GetPeriphCLKFreq+0xe18>)
 8005e38:	6812      	ldr	r2, [r2, #0]
 8005e3a:	f012 6f00 	tst.w	r2, #134217728	@ 0x8000000
 8005e3e:	d002      	beq.n	8005e46 <HAL_RCCEx_GetPeriphCLKFreq+0xc1e>
 8005e40:	f5b3 2f80 	cmp.w	r3, #262144	@ 0x40000
 8005e44:	d02a      	beq.n	8005e9c <HAL_RCCEx_GetPeriphCLKFreq+0xc74>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_PLL3RDY)) && (srcclk == RCC_UART7CLKSOURCE_PLL3Q))
 8005e46:	4a7e      	ldr	r2, [pc, #504]	@ (8006040 <HAL_RCCEx_GetPeriphCLKFreq+0xe18>)
 8005e48:	6812      	ldr	r2, [r2, #0]
 8005e4a:	f012 5f00 	tst.w	r2, #536870912	@ 0x20000000
 8005e4e:	d002      	beq.n	8005e56 <HAL_RCCEx_GetPeriphCLKFreq+0xc2e>
 8005e50:	f5b3 2f00 	cmp.w	r3, #524288	@ 0x80000
 8005e54:	d028      	beq.n	8005ea8 <HAL_RCCEx_GetPeriphCLKFreq+0xc80>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_HSIRDY)) && (srcclk == RCC_UART7CLKSOURCE_HSI))
 8005e56:	4a7a      	ldr	r2, [pc, #488]	@ (8006040 <HAL_RCCEx_GetPeriphCLKFreq+0xe18>)
 8005e58:	6812      	ldr	r2, [r2, #0]
 8005e5a:	f012 0f02 	tst.w	r2, #2
 8005e5e:	d002      	beq.n	8005e66 <HAL_RCCEx_GetPeriphCLKFreq+0xc3e>
 8005e60:	f5b3 2f40 	cmp.w	r3, #786432	@ 0xc0000
 8005e64:	d026      	beq.n	8005eb4 <HAL_RCCEx_GetPeriphCLKFreq+0xc8c>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_CSIRDY)) && (srcclk == RCC_UART7CLKSOURCE_CSI))
 8005e66:	4a76      	ldr	r2, [pc, #472]	@ (8006040 <HAL_RCCEx_GetPeriphCLKFreq+0xe18>)
 8005e68:	6812      	ldr	r2, [r2, #0]
 8005e6a:	f412 7f00 	tst.w	r2, #512	@ 0x200
 8005e6e:	d003      	beq.n	8005e78 <HAL_RCCEx_GetPeriphCLKFreq+0xc50>
 8005e70:	f5b3 1f80 	cmp.w	r3, #1048576	@ 0x100000
 8005e74:	f000 8730 	beq.w	8006cd8 <HAL_RCCEx_GetPeriphCLKFreq+0x1ab0>
        else if ((HAL_IS_BIT_SET(RCC->BDCR, RCC_BDCR_LSERDY)) && (srcclk == RCC_UART7CLKSOURCE_LSE))
 8005e78:	4a71      	ldr	r2, [pc, #452]	@ (8006040 <HAL_RCCEx_GetPeriphCLKFreq+0xe18>)
 8005e7a:	f8d2 20f0 	ldr.w	r2, [r2, #240]	@ 0xf0
 8005e7e:	f012 0f02 	tst.w	r2, #2
 8005e82:	f000 872c 	beq.w	8006cde <HAL_RCCEx_GetPeriphCLKFreq+0x1ab6>
 8005e86:	f5b3 1fa0 	cmp.w	r3, #1310720	@ 0x140000
 8005e8a:	f000 872b 	beq.w	8006ce4 <HAL_RCCEx_GetPeriphCLKFreq+0x1abc>
          frequency = 0U;
 8005e8e:	2000      	movs	r0, #0
 8005e90:	f7ff b9f8 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = HAL_RCC_GetPCLK1Freq();
 8005e94:	f7fd fd0e 	bl	80038b4 <HAL_RCC_GetPCLK1Freq>
 8005e98:	f7ff b9f4 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          HAL_RCCEx_GetPLL2ClockFreq(&pll2_clocks);
 8005e9c:	a804      	add	r0, sp, #16
 8005e9e:	f7fe ffab 	bl	8004df8 <HAL_RCCEx_GetPLL2ClockFreq>
          frequency = pll2_clocks.PLL2_Q_Frequency;
 8005ea2:	9805      	ldr	r0, [sp, #20]
 8005ea4:	f7ff b9ee 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          HAL_RCCEx_GetPLL3ClockFreq(&pll3_clocks);
 8005ea8:	a801      	add	r0, sp, #4
 8005eaa:	f7ff f8b1 	bl	8005010 <HAL_RCCEx_GetPLL3ClockFreq>
          frequency = pll3_clocks.PLL3_Q_Frequency;
 8005eae:	9802      	ldr	r0, [sp, #8]
 8005eb0:	f7ff b9e8 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = (HSI_VALUE >> (__HAL_RCC_GET_HSI_DIVIDER() >> RCC_CR_HSIDIV_Pos));
 8005eb4:	4b62      	ldr	r3, [pc, #392]	@ (8006040 <HAL_RCCEx_GetPeriphCLKFreq+0xe18>)
 8005eb6:	681b      	ldr	r3, [r3, #0]
 8005eb8:	f3c3 03c1 	ubfx	r3, r3, #3, #2
 8005ebc:	4861      	ldr	r0, [pc, #388]	@ (8006044 <HAL_RCCEx_GetPeriphCLKFreq+0xe1c>)
 8005ebe:	40d8      	lsrs	r0, r3
 8005ec0:	f7ff b9e0 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = HAL_RCC_GetPCLK1Freq();
 8005ec4:	f7fd fcf6 	bl	80038b4 <HAL_RCC_GetPCLK1Freq>
 8005ec8:	f7ff b9dc 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          HAL_RCCEx_GetPLL2ClockFreq(&pll2_clocks);
 8005ecc:	a804      	add	r0, sp, #16
 8005ece:	f7fe ff93 	bl	8004df8 <HAL_RCCEx_GetPLL2ClockFreq>
          frequency = pll2_clocks.PLL2_Q_Frequency;
 8005ed2:	9805      	ldr	r0, [sp, #20]
 8005ed4:	f7ff b9d6 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          HAL_RCCEx_GetPLL3ClockFreq(&pll3_clocks);
 8005ed8:	a801      	add	r0, sp, #4
 8005eda:	f7ff f899 	bl	8005010 <HAL_RCCEx_GetPLL3ClockFreq>
          frequency = pll3_clocks.PLL3_Q_Frequency;
 8005ede:	9802      	ldr	r0, [sp, #8]
 8005ee0:	f7ff b9d0 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = (HSI_VALUE >> (__HAL_RCC_GET_HSI_DIVIDER() >> RCC_CR_HSIDIV_Pos));
 8005ee4:	4b56      	ldr	r3, [pc, #344]	@ (8006040 <HAL_RCCEx_GetPeriphCLKFreq+0xe18>)
 8005ee6:	681b      	ldr	r3, [r3, #0]
 8005ee8:	f3c3 03c1 	ubfx	r3, r3, #3, #2
 8005eec:	4855      	ldr	r0, [pc, #340]	@ (8006044 <HAL_RCCEx_GetPeriphCLKFreq+0xe1c>)
 8005eee:	40d8      	lsrs	r0, r3
 8005ef0:	f7ff b9c8 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
        srcclk = __HAL_RCC_GET_UART9_SOURCE();
 8005ef4:	4b52      	ldr	r3, [pc, #328]	@ (8006040 <HAL_RCCEx_GetPeriphCLKFreq+0xe18>)
 8005ef6:	f8d3 30d8 	ldr.w	r3, [r3, #216]	@ 0xd8
        if (srcclk == RCC_UART9CLKSOURCE_PCLK1)
 8005efa:	f013 63e0 	ands.w	r3, r3, #117440512	@ 0x7000000
 8005efe:	d02e      	beq.n	8005f5e <HAL_RCCEx_GetPeriphCLKFreq+0xd36>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_PLL2RDY)) && (srcclk == RCC_UART9CLKSOURCE_PLL2Q))
 8005f00:	4a4f      	ldr	r2, [pc, #316]	@ (8006040 <HAL_RCCEx_GetPeriphCLKFreq+0xe18>)
 8005f02:	6812      	ldr	r2, [r2, #0]
 8005f04:	f012 6f00 	tst.w	r2, #134217728	@ 0x8000000
 8005f08:	d002      	beq.n	8005f10 <HAL_RCCEx_GetPeriphCLKFreq+0xce8>
 8005f0a:	f1b3 7f80 	cmp.w	r3, #16777216	@ 0x1000000
 8005f0e:	d02a      	beq.n	8005f66 <HAL_RCCEx_GetPeriphCLKFreq+0xd3e>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_PLL3RDY)) && (srcclk == RCC_UART9CLKSOURCE_PLL3Q))
 8005f10:	4a4b      	ldr	r2, [pc, #300]	@ (8006040 <HAL_RCCEx_GetPeriphCLKFreq+0xe18>)
 8005f12:	6812      	ldr	r2, [r2, #0]
 8005f14:	f012 5f00 	tst.w	r2, #536870912	@ 0x20000000
 8005f18:	d002      	beq.n	8005f20 <HAL_RCCEx_GetPeriphCLKFreq+0xcf8>
 8005f1a:	f1b3 7f00 	cmp.w	r3, #33554432	@ 0x2000000
 8005f1e:	d028      	beq.n	8005f72 <HAL_RCCEx_GetPeriphCLKFreq+0xd4a>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_HSIRDY)) && (srcclk == RCC_UART9CLKSOURCE_HSI))
 8005f20:	4a47      	ldr	r2, [pc, #284]	@ (8006040 <HAL_RCCEx_GetPeriphCLKFreq+0xe18>)
 8005f22:	6812      	ldr	r2, [r2, #0]
 8005f24:	f012 0f02 	tst.w	r2, #2
 8005f28:	d002      	beq.n	8005f30 <HAL_RCCEx_GetPeriphCLKFreq+0xd08>
 8005f2a:	f1b3 7f40 	cmp.w	r3, #50331648	@ 0x3000000
 8005f2e:	d026      	beq.n	8005f7e <HAL_RCCEx_GetPeriphCLKFreq+0xd56>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_CSIRDY)) && (srcclk == RCC_UART9CLKSOURCE_CSI))
 8005f30:	4a43      	ldr	r2, [pc, #268]	@ (8006040 <HAL_RCCEx_GetPeriphCLKFreq+0xe18>)
 8005f32:	6812      	ldr	r2, [r2, #0]
 8005f34:	f412 7f00 	tst.w	r2, #512	@ 0x200
 8005f38:	d003      	beq.n	8005f42 <HAL_RCCEx_GetPeriphCLKFreq+0xd1a>
 8005f3a:	f1b3 6f80 	cmp.w	r3, #67108864	@ 0x4000000
 8005f3e:	f000 86df 	beq.w	8006d00 <HAL_RCCEx_GetPeriphCLKFreq+0x1ad8>
        else if ((HAL_IS_BIT_SET(RCC->BDCR, RCC_BDCR_LSERDY)) && (srcclk == RCC_UART9CLKSOURCE_LSE))
 8005f42:	4a3f      	ldr	r2, [pc, #252]	@ (8006040 <HAL_RCCEx_GetPeriphCLKFreq+0xe18>)
 8005f44:	f8d2 20f0 	ldr.w	r2, [r2, #240]	@ 0xf0
 8005f48:	f012 0f02 	tst.w	r2, #2
 8005f4c:	f000 86db 	beq.w	8006d06 <HAL_RCCEx_GetPeriphCLKFreq+0x1ade>
 8005f50:	f1b3 6fa0 	cmp.w	r3, #83886080	@ 0x5000000
 8005f54:	f000 86da 	beq.w	8006d0c <HAL_RCCEx_GetPeriphCLKFreq+0x1ae4>
          frequency = 0U;
 8005f58:	2000      	movs	r0, #0
 8005f5a:	f7ff b993 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = HAL_RCC_GetPCLK1Freq();
 8005f5e:	f7fd fca9 	bl	80038b4 <HAL_RCC_GetPCLK1Freq>
 8005f62:	f7ff b98f 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          HAL_RCCEx_GetPLL2ClockFreq(&pll2_clocks);
 8005f66:	a804      	add	r0, sp, #16
 8005f68:	f7fe ff46 	bl	8004df8 <HAL_RCCEx_GetPLL2ClockFreq>
          frequency = pll2_clocks.PLL2_Q_Frequency;
 8005f6c:	9805      	ldr	r0, [sp, #20]
 8005f6e:	f7ff b989 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          HAL_RCCEx_GetPLL3ClockFreq(&pll3_clocks);
 8005f72:	a801      	add	r0, sp, #4
 8005f74:	f7ff f84c 	bl	8005010 <HAL_RCCEx_GetPLL3ClockFreq>
          frequency = pll3_clocks.PLL3_Q_Frequency;
 8005f78:	9802      	ldr	r0, [sp, #8]
 8005f7a:	f7ff b983 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = (HSI_VALUE >> (__HAL_RCC_GET_HSI_DIVIDER() >> RCC_CR_HSIDIV_Pos));
 8005f7e:	4b30      	ldr	r3, [pc, #192]	@ (8006040 <HAL_RCCEx_GetPeriphCLKFreq+0xe18>)
 8005f80:	681b      	ldr	r3, [r3, #0]
 8005f82:	f3c3 03c1 	ubfx	r3, r3, #3, #2
 8005f86:	482f      	ldr	r0, [pc, #188]	@ (8006044 <HAL_RCCEx_GetPeriphCLKFreq+0xe1c>)
 8005f88:	40d8      	lsrs	r0, r3
 8005f8a:	f7ff b97b 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = HAL_RCC_GetPCLK1Freq();
 8005f8e:	f7fd fc91 	bl	80038b4 <HAL_RCC_GetPCLK1Freq>
 8005f92:	f7ff b977 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          HAL_RCCEx_GetPLL2ClockFreq(&pll2_clocks);
 8005f96:	a804      	add	r0, sp, #16
 8005f98:	f7fe ff2e 	bl	8004df8 <HAL_RCCEx_GetPLL2ClockFreq>
          frequency = pll2_clocks.PLL2_Q_Frequency;
 8005f9c:	9805      	ldr	r0, [sp, #20]
 8005f9e:	f7ff b971 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          HAL_RCCEx_GetPLL3ClockFreq(&pll3_clocks);
 8005fa2:	a801      	add	r0, sp, #4
 8005fa4:	f7ff f834 	bl	8005010 <HAL_RCCEx_GetPLL3ClockFreq>
          frequency = pll3_clocks.PLL3_Q_Frequency;
 8005fa8:	9802      	ldr	r0, [sp, #8]
 8005faa:	f7ff b96b 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = (HSI_VALUE >> (__HAL_RCC_GET_HSI_DIVIDER() >> RCC_CR_HSIDIV_Pos));
 8005fae:	4b24      	ldr	r3, [pc, #144]	@ (8006040 <HAL_RCCEx_GetPeriphCLKFreq+0xe18>)
 8005fb0:	681b      	ldr	r3, [r3, #0]
 8005fb2:	f3c3 03c1 	ubfx	r3, r3, #3, #2
 8005fb6:	4823      	ldr	r0, [pc, #140]	@ (8006044 <HAL_RCCEx_GetPeriphCLKFreq+0xe1c>)
 8005fb8:	40d8      	lsrs	r0, r3
 8005fba:	f7ff b963 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
        srcclk = __HAL_RCC_GET_USART11_SOURCE();
 8005fbe:	4b20      	ldr	r3, [pc, #128]	@ (8006040 <HAL_RCCEx_GetPeriphCLKFreq+0xe18>)
 8005fc0:	f8d3 30dc 	ldr.w	r3, [r3, #220]	@ 0xdc
        if (srcclk == RCC_USART11CLKSOURCE_PCLK1)
 8005fc4:	f013 0307 	ands.w	r3, r3, #7
 8005fc8:	d029      	beq.n	800601e <HAL_RCCEx_GetPeriphCLKFreq+0xdf6>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_PLL2RDY)) && (srcclk == RCC_USART11CLKSOURCE_PLL2Q))
 8005fca:	4a1d      	ldr	r2, [pc, #116]	@ (8006040 <HAL_RCCEx_GetPeriphCLKFreq+0xe18>)
 8005fcc:	6812      	ldr	r2, [r2, #0]
 8005fce:	f012 6f00 	tst.w	r2, #134217728	@ 0x8000000
 8005fd2:	d001      	beq.n	8005fd8 <HAL_RCCEx_GetPeriphCLKFreq+0xdb0>
 8005fd4:	2b01      	cmp	r3, #1
 8005fd6:	d026      	beq.n	8006026 <HAL_RCCEx_GetPeriphCLKFreq+0xdfe>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_PLL3RDY)) && (srcclk == RCC_USART11CLKSOURCE_PLL3Q))
 8005fd8:	4a19      	ldr	r2, [pc, #100]	@ (8006040 <HAL_RCCEx_GetPeriphCLKFreq+0xe18>)
 8005fda:	6812      	ldr	r2, [r2, #0]
 8005fdc:	f012 5f00 	tst.w	r2, #536870912	@ 0x20000000
 8005fe0:	d001      	beq.n	8005fe6 <HAL_RCCEx_GetPeriphCLKFreq+0xdbe>
 8005fe2:	2b02      	cmp	r3, #2
 8005fe4:	d025      	beq.n	8006032 <HAL_RCCEx_GetPeriphCLKFreq+0xe0a>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_HSIRDY)) && (srcclk == RCC_USART11CLKSOURCE_HSI))
 8005fe6:	4a16      	ldr	r2, [pc, #88]	@ (8006040 <HAL_RCCEx_GetPeriphCLKFreq+0xe18>)
 8005fe8:	6812      	ldr	r2, [r2, #0]
 8005fea:	f012 0f02 	tst.w	r2, #2
 8005fee:	d001      	beq.n	8005ff4 <HAL_RCCEx_GetPeriphCLKFreq+0xdcc>
 8005ff0:	2b03      	cmp	r3, #3
 8005ff2:	d029      	beq.n	8006048 <HAL_RCCEx_GetPeriphCLKFreq+0xe20>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_CSIRDY)) && (srcclk == RCC_USART11CLKSOURCE_CSI))
 8005ff4:	4a12      	ldr	r2, [pc, #72]	@ (8006040 <HAL_RCCEx_GetPeriphCLKFreq+0xe18>)
 8005ff6:	6812      	ldr	r2, [r2, #0]
 8005ff8:	f412 7f00 	tst.w	r2, #512	@ 0x200
 8005ffc:	d002      	beq.n	8006004 <HAL_RCCEx_GetPeriphCLKFreq+0xddc>
 8005ffe:	2b04      	cmp	r3, #4
 8006000:	f000 8692 	beq.w	8006d28 <HAL_RCCEx_GetPeriphCLKFreq+0x1b00>
        else if ((HAL_IS_BIT_SET(RCC->BDCR, RCC_BDCR_LSERDY)) && (srcclk == RCC_USART11CLKSOURCE_LSE))
 8006004:	4a0e      	ldr	r2, [pc, #56]	@ (8006040 <HAL_RCCEx_GetPeriphCLKFreq+0xe18>)
 8006006:	f8d2 20f0 	ldr.w	r2, [r2, #240]	@ 0xf0
 800600a:	f012 0f02 	tst.w	r2, #2
 800600e:	f000 868e 	beq.w	8006d2e <HAL_RCCEx_GetPeriphCLKFreq+0x1b06>
 8006012:	2b05      	cmp	r3, #5
 8006014:	f000 868e 	beq.w	8006d34 <HAL_RCCEx_GetPeriphCLKFreq+0x1b0c>
          frequency = 0U;
 8006018:	2000      	movs	r0, #0
 800601a:	f7ff b933 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = HAL_RCC_GetPCLK1Freq();
 800601e:	f7fd fc49 	bl	80038b4 <HAL_RCC_GetPCLK1Freq>
 8006022:	f7ff b92f 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          HAL_RCCEx_GetPLL2ClockFreq(&pll2_clocks);
 8006026:	a804      	add	r0, sp, #16
 8006028:	f7fe fee6 	bl	8004df8 <HAL_RCCEx_GetPLL2ClockFreq>
          frequency = pll2_clocks.PLL2_Q_Frequency;
 800602c:	9805      	ldr	r0, [sp, #20]
 800602e:	f7ff b929 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          HAL_RCCEx_GetPLL3ClockFreq(&pll3_clocks);
 8006032:	a801      	add	r0, sp, #4
 8006034:	f7fe ffec 	bl	8005010 <HAL_RCCEx_GetPLL3ClockFreq>
          frequency = pll3_clocks.PLL3_Q_Frequency;
 8006038:	9802      	ldr	r0, [sp, #8]
 800603a:	f7ff b923 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
 800603e:	bf00      	nop
 8006040:	44020c00 	.word	0x44020c00
 8006044:	03d09000 	.word	0x03d09000
          frequency = (HSI_VALUE >> (__HAL_RCC_GET_HSI_DIVIDER() >> RCC_CR_HSIDIV_Pos));
 8006048:	4bb4      	ldr	r3, [pc, #720]	@ (800631c <HAL_RCCEx_GetPeriphCLKFreq+0x10f4>)
 800604a:	681b      	ldr	r3, [r3, #0]
 800604c:	f3c3 03c1 	ubfx	r3, r3, #3, #2
 8006050:	48b3      	ldr	r0, [pc, #716]	@ (8006320 <HAL_RCCEx_GetPeriphCLKFreq+0x10f8>)
 8006052:	40d8      	lsrs	r0, r3
 8006054:	f7ff b916 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
        srcclk = __HAL_RCC_GET_UART12_SOURCE();
 8006058:	4bb0      	ldr	r3, [pc, #704]	@ (800631c <HAL_RCCEx_GetPeriphCLKFreq+0x10f4>)
 800605a:	f8d3 30dc 	ldr.w	r3, [r3, #220]	@ 0xdc
        if (srcclk == RCC_UART12CLKSOURCE_PCLK1)
 800605e:	f013 0370 	ands.w	r3, r3, #112	@ 0x70
 8006062:	d029      	beq.n	80060b8 <HAL_RCCEx_GetPeriphCLKFreq+0xe90>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_PLL2RDY)) && (srcclk == RCC_UART12CLKSOURCE_PLL2Q))
 8006064:	4aad      	ldr	r2, [pc, #692]	@ (800631c <HAL_RCCEx_GetPeriphCLKFreq+0x10f4>)
 8006066:	6812      	ldr	r2, [r2, #0]
 8006068:	f012 6f00 	tst.w	r2, #134217728	@ 0x8000000
 800606c:	d001      	beq.n	8006072 <HAL_RCCEx_GetPeriphCLKFreq+0xe4a>
 800606e:	2b10      	cmp	r3, #16
 8006070:	d026      	beq.n	80060c0 <HAL_RCCEx_GetPeriphCLKFreq+0xe98>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_PLL3RDY)) && (srcclk == RCC_UART12CLKSOURCE_PLL3Q))
 8006072:	4aaa      	ldr	r2, [pc, #680]	@ (800631c <HAL_RCCEx_GetPeriphCLKFreq+0x10f4>)
 8006074:	6812      	ldr	r2, [r2, #0]
 8006076:	f012 5f00 	tst.w	r2, #536870912	@ 0x20000000
 800607a:	d001      	beq.n	8006080 <HAL_RCCEx_GetPeriphCLKFreq+0xe58>
 800607c:	2b20      	cmp	r3, #32
 800607e:	d025      	beq.n	80060cc <HAL_RCCEx_GetPeriphCLKFreq+0xea4>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_HSIRDY)) && (srcclk == RCC_UART12CLKSOURCE_HSI))
 8006080:	4aa6      	ldr	r2, [pc, #664]	@ (800631c <HAL_RCCEx_GetPeriphCLKFreq+0x10f4>)
 8006082:	6812      	ldr	r2, [r2, #0]
 8006084:	f012 0f02 	tst.w	r2, #2
 8006088:	d001      	beq.n	800608e <HAL_RCCEx_GetPeriphCLKFreq+0xe66>
 800608a:	2b30      	cmp	r3, #48	@ 0x30
 800608c:	d024      	beq.n	80060d8 <HAL_RCCEx_GetPeriphCLKFreq+0xeb0>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_CSIRDY)) && (srcclk == RCC_UART12CLKSOURCE_CSI))
 800608e:	4aa3      	ldr	r2, [pc, #652]	@ (800631c <HAL_RCCEx_GetPeriphCLKFreq+0x10f4>)
 8006090:	6812      	ldr	r2, [r2, #0]
 8006092:	f412 7f00 	tst.w	r2, #512	@ 0x200
 8006096:	d002      	beq.n	800609e <HAL_RCCEx_GetPeriphCLKFreq+0xe76>
 8006098:	2b40      	cmp	r3, #64	@ 0x40
 800609a:	f000 864f 	beq.w	8006d3c <HAL_RCCEx_GetPeriphCLKFreq+0x1b14>
        else if ((HAL_IS_BIT_SET(RCC->BDCR, RCC_BDCR_LSERDY)) && (srcclk == RCC_UART12CLKSOURCE_LSE))
 800609e:	4a9f      	ldr	r2, [pc, #636]	@ (800631c <HAL_RCCEx_GetPeriphCLKFreq+0x10f4>)
 80060a0:	f8d2 20f0 	ldr.w	r2, [r2, #240]	@ 0xf0
 80060a4:	f012 0f02 	tst.w	r2, #2
 80060a8:	f000 864b 	beq.w	8006d42 <HAL_RCCEx_GetPeriphCLKFreq+0x1b1a>
 80060ac:	2b50      	cmp	r3, #80	@ 0x50
 80060ae:	f000 864b 	beq.w	8006d48 <HAL_RCCEx_GetPeriphCLKFreq+0x1b20>
          frequency = 0U;
 80060b2:	2000      	movs	r0, #0
 80060b4:	f7ff b8e6 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = HAL_RCC_GetPCLK1Freq();
 80060b8:	f7fd fbfc 	bl	80038b4 <HAL_RCC_GetPCLK1Freq>
 80060bc:	f7ff b8e2 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          HAL_RCCEx_GetPLL2ClockFreq(&pll2_clocks);
 80060c0:	a804      	add	r0, sp, #16
 80060c2:	f7fe fe99 	bl	8004df8 <HAL_RCCEx_GetPLL2ClockFreq>
          frequency = pll2_clocks.PLL2_Q_Frequency;
 80060c6:	9805      	ldr	r0, [sp, #20]
 80060c8:	f7ff b8dc 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          HAL_RCCEx_GetPLL3ClockFreq(&pll3_clocks);
 80060cc:	a801      	add	r0, sp, #4
 80060ce:	f7fe ff9f 	bl	8005010 <HAL_RCCEx_GetPLL3ClockFreq>
          frequency = pll3_clocks.PLL3_Q_Frequency;
 80060d2:	9802      	ldr	r0, [sp, #8]
 80060d4:	f7ff b8d6 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = (HSI_VALUE >> (__HAL_RCC_GET_HSI_DIVIDER() >> RCC_CR_HSIDIV_Pos));
 80060d8:	4b90      	ldr	r3, [pc, #576]	@ (800631c <HAL_RCCEx_GetPeriphCLKFreq+0x10f4>)
 80060da:	681b      	ldr	r3, [r3, #0]
 80060dc:	f3c3 03c1 	ubfx	r3, r3, #3, #2
 80060e0:	488f      	ldr	r0, [pc, #572]	@ (8006320 <HAL_RCCEx_GetPeriphCLKFreq+0x10f8>)
 80060e2:	40d8      	lsrs	r0, r3
 80060e4:	f7ff b8ce 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = HAL_RCC_GetPCLK3Freq();
 80060e8:	f7fd fc08 	bl	80038fc <HAL_RCC_GetPCLK3Freq>
 80060ec:	f7ff b8ca 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          HAL_RCCEx_GetPLL2ClockFreq(&pll2_clocks);
 80060f0:	a804      	add	r0, sp, #16
 80060f2:	f7fe fe81 	bl	8004df8 <HAL_RCCEx_GetPLL2ClockFreq>
          frequency = pll2_clocks.PLL2_Q_Frequency;
 80060f6:	9805      	ldr	r0, [sp, #20]
 80060f8:	f7ff b8c4 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          HAL_RCCEx_GetPLL3ClockFreq(&pll3_clocks);
 80060fc:	a801      	add	r0, sp, #4
 80060fe:	f7fe ff87 	bl	8005010 <HAL_RCCEx_GetPLL3ClockFreq>
          frequency = pll3_clocks.PLL3_Q_Frequency;
 8006102:	9802      	ldr	r0, [sp, #8]
 8006104:	f7ff b8be 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = (HSI_VALUE >> (__HAL_RCC_GET_HSI_DIVIDER() >> RCC_CR_HSIDIV_Pos));
 8006108:	4b84      	ldr	r3, [pc, #528]	@ (800631c <HAL_RCCEx_GetPeriphCLKFreq+0x10f4>)
 800610a:	681b      	ldr	r3, [r3, #0]
 800610c:	f3c3 03c1 	ubfx	r3, r3, #3, #2
 8006110:	4883      	ldr	r0, [pc, #524]	@ (8006320 <HAL_RCCEx_GetPeriphCLKFreq+0x10f8>)
 8006112:	40d8      	lsrs	r0, r3
 8006114:	f7ff b8b6 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
        srcclk = __HAL_RCC_GET_ADCDAC_SOURCE();
 8006118:	4b80      	ldr	r3, [pc, #512]	@ (800631c <HAL_RCCEx_GetPeriphCLKFreq+0x10f4>)
 800611a:	f8d3 30e8 	ldr.w	r3, [r3, #232]	@ 0xe8
        if (srcclk == RCC_ADCDACCLKSOURCE_HCLK)
 800611e:	f013 0307 	ands.w	r3, r3, #7
 8006122:	d01e      	beq.n	8006162 <HAL_RCCEx_GetPeriphCLKFreq+0xf3a>
        else if (srcclk == RCC_ADCDACCLKSOURCE_SYSCLK)
 8006124:	2b01      	cmp	r3, #1
 8006126:	d020      	beq.n	800616a <HAL_RCCEx_GetPeriphCLKFreq+0xf42>
        else if (srcclk == RCC_ADCDACCLKSOURCE_PLL2R)
 8006128:	2b02      	cmp	r3, #2
 800612a:	d022      	beq.n	8006172 <HAL_RCCEx_GetPeriphCLKFreq+0xf4a>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_HSERDY)) && (srcclk == RCC_ADCDACCLKSOURCE_HSE))
 800612c:	4a7b      	ldr	r2, [pc, #492]	@ (800631c <HAL_RCCEx_GetPeriphCLKFreq+0x10f4>)
 800612e:	6812      	ldr	r2, [r2, #0]
 8006130:	f412 3f00 	tst.w	r2, #131072	@ 0x20000
 8006134:	d002      	beq.n	800613c <HAL_RCCEx_GetPeriphCLKFreq+0xf14>
 8006136:	2b03      	cmp	r3, #3
 8006138:	f000 8614 	beq.w	8006d64 <HAL_RCCEx_GetPeriphCLKFreq+0x1b3c>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_HSIRDY)) && (srcclk == RCC_ADCDACCLKSOURCE_HSI))
 800613c:	4a77      	ldr	r2, [pc, #476]	@ (800631c <HAL_RCCEx_GetPeriphCLKFreq+0x10f4>)
 800613e:	6812      	ldr	r2, [r2, #0]
 8006140:	f012 0f02 	tst.w	r2, #2
 8006144:	d001      	beq.n	800614a <HAL_RCCEx_GetPeriphCLKFreq+0xf22>
 8006146:	2b04      	cmp	r3, #4
 8006148:	d019      	beq.n	800617e <HAL_RCCEx_GetPeriphCLKFreq+0xf56>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_CSIRDY)) && (srcclk == RCC_ADCDACCLKSOURCE_CSI))
 800614a:	4a74      	ldr	r2, [pc, #464]	@ (800631c <HAL_RCCEx_GetPeriphCLKFreq+0x10f4>)
 800614c:	6812      	ldr	r2, [r2, #0]
 800614e:	f412 7f00 	tst.w	r2, #512	@ 0x200
 8006152:	f000 860a 	beq.w	8006d6a <HAL_RCCEx_GetPeriphCLKFreq+0x1b42>
 8006156:	2b05      	cmp	r3, #5
 8006158:	f000 860a 	beq.w	8006d70 <HAL_RCCEx_GetPeriphCLKFreq+0x1b48>
          frequency = 0U;
 800615c:	2000      	movs	r0, #0
 800615e:	f7ff b891 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = HAL_RCC_GetHCLKFreq();
 8006162:	f7fd f84b 	bl	80031fc <HAL_RCC_GetHCLKFreq>
 8006166:	f7ff b88d 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = HAL_RCC_GetSysClockFreq();
 800616a:	f7fc fe0f 	bl	8002d8c <HAL_RCC_GetSysClockFreq>
 800616e:	f7ff b889 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          HAL_RCCEx_GetPLL2ClockFreq(&pll2_clocks);
 8006172:	a804      	add	r0, sp, #16
 8006174:	f7fe fe40 	bl	8004df8 <HAL_RCCEx_GetPLL2ClockFreq>
          frequency = pll2_clocks.PLL2_R_Frequency;
 8006178:	9806      	ldr	r0, [sp, #24]
 800617a:	f7ff b883 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = (HSI_VALUE >> (__HAL_RCC_GET_HSI_DIVIDER() >> RCC_CR_HSIDIV_Pos));
 800617e:	4b67      	ldr	r3, [pc, #412]	@ (800631c <HAL_RCCEx_GetPeriphCLKFreq+0x10f4>)
 8006180:	681b      	ldr	r3, [r3, #0]
 8006182:	f3c3 03c1 	ubfx	r3, r3, #3, #2
 8006186:	4866      	ldr	r0, [pc, #408]	@ (8006320 <HAL_RCCEx_GetPeriphCLKFreq+0x10f8>)
 8006188:	40d8      	lsrs	r0, r3
 800618a:	f7ff b87b 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
        srcclk = __HAL_RCC_GET_DAC_LP_SOURCE();
 800618e:	4a63      	ldr	r2, [pc, #396]	@ (800631c <HAL_RCCEx_GetPeriphCLKFreq+0x10f4>)
 8006190:	f8d2 30e8 	ldr.w	r3, [r2, #232]	@ 0xe8
 8006194:	f003 0308 	and.w	r3, r3, #8
        if ((HAL_IS_BIT_SET(RCC->BDCR, RCC_BDCR_LSERDY)) && (srcclk == RCC_DACLPCLKSOURCE_LSE))
 8006198:	f8d2 20f0 	ldr.w	r2, [r2, #240]	@ 0xf0
 800619c:	f012 0f02 	tst.w	r2, #2
 80061a0:	d002      	beq.n	80061a8 <HAL_RCCEx_GetPeriphCLKFreq+0xf80>
 80061a2:	2b00      	cmp	r3, #0
 80061a4:	f000 85e7 	beq.w	8006d76 <HAL_RCCEx_GetPeriphCLKFreq+0x1b4e>
        else if ((HAL_IS_BIT_SET(RCC->BDCR, RCC_BDCR_LSIRDY)) && (srcclk == RCC_DACLPCLKSOURCE_LSI))
 80061a8:	4a5c      	ldr	r2, [pc, #368]	@ (800631c <HAL_RCCEx_GetPeriphCLKFreq+0x10f4>)
 80061aa:	f8d2 20f0 	ldr.w	r2, [r2, #240]	@ 0xf0
 80061ae:	f012 6f00 	tst.w	r2, #134217728	@ 0x8000000
 80061b2:	f000 85e4 	beq.w	8006d7e <HAL_RCCEx_GetPeriphCLKFreq+0x1b56>
 80061b6:	2b00      	cmp	r3, #0
 80061b8:	f040 85e4 	bne.w	8006d84 <HAL_RCCEx_GetPeriphCLKFreq+0x1b5c>
          frequency = 0U;
 80061bc:	2000      	movs	r0, #0
 80061be:	f7ff b861 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
        srcclk = __HAL_RCC_GET_I2C1_SOURCE();
 80061c2:	4b56      	ldr	r3, [pc, #344]	@ (800631c <HAL_RCCEx_GetPeriphCLKFreq+0x10f4>)
 80061c4:	f8d3 30e4 	ldr.w	r3, [r3, #228]	@ 0xe4
        if (srcclk == RCC_I2C1CLKSOURCE_PCLK1)
 80061c8:	f413 3340 	ands.w	r3, r3, #196608	@ 0x30000
 80061cc:	d017      	beq.n	80061fe <HAL_RCCEx_GetPeriphCLKFreq+0xfd6>
        else if (srcclk ==  RCC_I2C1CLKSOURCE_PLL3R)
 80061ce:	f5b3 3f80 	cmp.w	r3, #65536	@ 0x10000
 80061d2:	d018      	beq.n	8006206 <HAL_RCCEx_GetPeriphCLKFreq+0xfde>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_HSIRDY)) && (srcclk == RCC_I2C1CLKSOURCE_HSI))
 80061d4:	4a51      	ldr	r2, [pc, #324]	@ (800631c <HAL_RCCEx_GetPeriphCLKFreq+0x10f4>)
 80061d6:	6812      	ldr	r2, [r2, #0]
 80061d8:	f012 0f02 	tst.w	r2, #2
 80061dc:	d002      	beq.n	80061e4 <HAL_RCCEx_GetPeriphCLKFreq+0xfbc>
 80061de:	f5b3 3f00 	cmp.w	r3, #131072	@ 0x20000
 80061e2:	d016      	beq.n	8006212 <HAL_RCCEx_GetPeriphCLKFreq+0xfea>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_CSIRDY)) && (srcclk ==  RCC_I2C1CLKSOURCE_CSI))
 80061e4:	4a4d      	ldr	r2, [pc, #308]	@ (800631c <HAL_RCCEx_GetPeriphCLKFreq+0x10f4>)
 80061e6:	6812      	ldr	r2, [r2, #0]
 80061e8:	f412 7f00 	tst.w	r2, #512	@ 0x200
 80061ec:	f000 85ce 	beq.w	8006d8c <HAL_RCCEx_GetPeriphCLKFreq+0x1b64>
 80061f0:	f5b3 3f40 	cmp.w	r3, #196608	@ 0x30000
 80061f4:	f000 85cd 	beq.w	8006d92 <HAL_RCCEx_GetPeriphCLKFreq+0x1b6a>
          frequency = 0U;
 80061f8:	2000      	movs	r0, #0
 80061fa:	f7ff b843 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = HAL_RCC_GetPCLK1Freq();
 80061fe:	f7fd fb59 	bl	80038b4 <HAL_RCC_GetPCLK1Freq>
 8006202:	f7ff b83f 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          HAL_RCCEx_GetPLL3ClockFreq(&pll3_clocks);
 8006206:	a801      	add	r0, sp, #4
 8006208:	f7fe ff02 	bl	8005010 <HAL_RCCEx_GetPLL3ClockFreq>
          frequency = pll3_clocks.PLL3_R_Frequency;
 800620c:	9803      	ldr	r0, [sp, #12]
 800620e:	f7ff b839 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = (HSI_VALUE >> (__HAL_RCC_GET_HSI_DIVIDER() >> RCC_CR_HSIDIV_Pos));
 8006212:	4b42      	ldr	r3, [pc, #264]	@ (800631c <HAL_RCCEx_GetPeriphCLKFreq+0x10f4>)
 8006214:	681b      	ldr	r3, [r3, #0]
 8006216:	f3c3 03c1 	ubfx	r3, r3, #3, #2
 800621a:	4841      	ldr	r0, [pc, #260]	@ (8006320 <HAL_RCCEx_GetPeriphCLKFreq+0x10f8>)
 800621c:	40d8      	lsrs	r0, r3
 800621e:	f7ff b831 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = HAL_RCC_GetPCLK1Freq();
 8006222:	f7fd fb47 	bl	80038b4 <HAL_RCC_GetPCLK1Freq>
 8006226:	f7ff b82d 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          HAL_RCCEx_GetPLL3ClockFreq(&pll3_clocks);
 800622a:	a801      	add	r0, sp, #4
 800622c:	f7fe fef0 	bl	8005010 <HAL_RCCEx_GetPLL3ClockFreq>
          frequency = pll3_clocks.PLL3_R_Frequency;
 8006230:	9803      	ldr	r0, [sp, #12]
 8006232:	f7ff b827 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = (HSI_VALUE >> (__HAL_RCC_GET_HSI_DIVIDER() >> RCC_CR_HSIDIV_Pos));
 8006236:	4b39      	ldr	r3, [pc, #228]	@ (800631c <HAL_RCCEx_GetPeriphCLKFreq+0x10f4>)
 8006238:	681b      	ldr	r3, [r3, #0]
 800623a:	f3c3 03c1 	ubfx	r3, r3, #3, #2
 800623e:	4838      	ldr	r0, [pc, #224]	@ (8006320 <HAL_RCCEx_GetPeriphCLKFreq+0x10f8>)
 8006240:	40d8      	lsrs	r0, r3
 8006242:	f7ff b81f 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
        srcclk = __HAL_RCC_GET_I2C3_SOURCE();
 8006246:	4b35      	ldr	r3, [pc, #212]	@ (800631c <HAL_RCCEx_GetPeriphCLKFreq+0x10f4>)
 8006248:	f8d3 30e4 	ldr.w	r3, [r3, #228]	@ 0xe4
        if (srcclk == RCC_I2C3CLKSOURCE_PCLK3)
 800624c:	f413 1340 	ands.w	r3, r3, #3145728	@ 0x300000
 8006250:	d017      	beq.n	8006282 <HAL_RCCEx_GetPeriphCLKFreq+0x105a>
        else if (srcclk ==  RCC_I2C3CLKSOURCE_PLL3R)
 8006252:	f5b3 1f80 	cmp.w	r3, #1048576	@ 0x100000
 8006256:	d018      	beq.n	800628a <HAL_RCCEx_GetPeriphCLKFreq+0x1062>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_HSIRDY)) && (srcclk == RCC_I2C3CLKSOURCE_HSI))
 8006258:	4a30      	ldr	r2, [pc, #192]	@ (800631c <HAL_RCCEx_GetPeriphCLKFreq+0x10f4>)
 800625a:	6812      	ldr	r2, [r2, #0]
 800625c:	f012 0f02 	tst.w	r2, #2
 8006260:	d002      	beq.n	8006268 <HAL_RCCEx_GetPeriphCLKFreq+0x1040>
 8006262:	f5b3 1f00 	cmp.w	r3, #2097152	@ 0x200000
 8006266:	d016      	beq.n	8006296 <HAL_RCCEx_GetPeriphCLKFreq+0x106e>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_CSIRDY)) && (srcclk ==  RCC_I2C3CLKSOURCE_CSI))
 8006268:	4a2c      	ldr	r2, [pc, #176]	@ (800631c <HAL_RCCEx_GetPeriphCLKFreq+0x10f4>)
 800626a:	6812      	ldr	r2, [r2, #0]
 800626c:	f412 7f00 	tst.w	r2, #512	@ 0x200
 8006270:	f000 8598 	beq.w	8006da4 <HAL_RCCEx_GetPeriphCLKFreq+0x1b7c>
 8006274:	f5b3 1f40 	cmp.w	r3, #3145728	@ 0x300000
 8006278:	f000 8597 	beq.w	8006daa <HAL_RCCEx_GetPeriphCLKFreq+0x1b82>
          frequency = 0U;
 800627c:	2000      	movs	r0, #0
 800627e:	f7ff b801 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = HAL_RCC_GetPCLK3Freq();
 8006282:	f7fd fb3b 	bl	80038fc <HAL_RCC_GetPCLK3Freq>
 8006286:	f7fe bffd 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          HAL_RCCEx_GetPLL3ClockFreq(&pll3_clocks);
 800628a:	a801      	add	r0, sp, #4
 800628c:	f7fe fec0 	bl	8005010 <HAL_RCCEx_GetPLL3ClockFreq>
          frequency = pll3_clocks.PLL3_R_Frequency;
 8006290:	9803      	ldr	r0, [sp, #12]
 8006292:	f7fe bff7 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = (HSI_VALUE >> (__HAL_RCC_GET_HSI_DIVIDER() >> RCC_CR_HSIDIV_Pos));
 8006296:	4b21      	ldr	r3, [pc, #132]	@ (800631c <HAL_RCCEx_GetPeriphCLKFreq+0x10f4>)
 8006298:	681b      	ldr	r3, [r3, #0]
 800629a:	f3c3 03c1 	ubfx	r3, r3, #3, #2
 800629e:	4820      	ldr	r0, [pc, #128]	@ (8006320 <HAL_RCCEx_GetPeriphCLKFreq+0x10f8>)
 80062a0:	40d8      	lsrs	r0, r3
 80062a2:	f7fe bfef 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = HAL_RCC_GetPCLK3Freq();
 80062a6:	f7fd fb29 	bl	80038fc <HAL_RCC_GetPCLK3Freq>
 80062aa:	f7fe bfeb 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          HAL_RCCEx_GetPLL3ClockFreq(&pll3_clocks);
 80062ae:	a801      	add	r0, sp, #4
 80062b0:	f7fe feae 	bl	8005010 <HAL_RCCEx_GetPLL3ClockFreq>
          frequency = pll3_clocks.PLL3_R_Frequency;
 80062b4:	9803      	ldr	r0, [sp, #12]
 80062b6:	f7fe bfe5 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = (HSI_VALUE >> (__HAL_RCC_GET_HSI_DIVIDER() >> RCC_CR_HSIDIV_Pos));
 80062ba:	4b18      	ldr	r3, [pc, #96]	@ (800631c <HAL_RCCEx_GetPeriphCLKFreq+0x10f4>)
 80062bc:	681b      	ldr	r3, [r3, #0]
 80062be:	f3c3 03c1 	ubfx	r3, r3, #3, #2
 80062c2:	4817      	ldr	r0, [pc, #92]	@ (8006320 <HAL_RCCEx_GetPeriphCLKFreq+0x10f8>)
 80062c4:	40d8      	lsrs	r0, r3
 80062c6:	f7fe bfdd 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
        srcclk = __HAL_RCC_GET_I3C1_SOURCE();
 80062ca:	4b14      	ldr	r3, [pc, #80]	@ (800631c <HAL_RCCEx_GetPeriphCLKFreq+0x10f4>)
 80062cc:	f8d3 30e4 	ldr.w	r3, [r3, #228]	@ 0xe4
        if (srcclk == RCC_I3C1CLKSOURCE_PCLK1)
 80062d0:	f013 7340 	ands.w	r3, r3, #50331648	@ 0x3000000
 80062d4:	d00e      	beq.n	80062f4 <HAL_RCCEx_GetPeriphCLKFreq+0x10cc>
        else if (srcclk ==  RCC_I3C1CLKSOURCE_PLL3R)
 80062d6:	f1b3 7f80 	cmp.w	r3, #16777216	@ 0x1000000
 80062da:	d00f      	beq.n	80062fc <HAL_RCCEx_GetPeriphCLKFreq+0x10d4>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_HSIRDY)) && (srcclk == RCC_I3C1CLKSOURCE_HSI))
 80062dc:	4a0f      	ldr	r2, [pc, #60]	@ (800631c <HAL_RCCEx_GetPeriphCLKFreq+0x10f4>)
 80062de:	6810      	ldr	r0, [r2, #0]
 80062e0:	f010 0002 	ands.w	r0, r0, #2
 80062e4:	f43e afce 	beq.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
 80062e8:	f1b3 7f00 	cmp.w	r3, #33554432	@ 0x2000000
 80062ec:	d00c      	beq.n	8006308 <HAL_RCCEx_GetPeriphCLKFreq+0x10e0>
          frequency = 0U;
 80062ee:	2000      	movs	r0, #0
 80062f0:	f7fe bfc8 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = HAL_RCC_GetPCLK1Freq();
 80062f4:	f7fd fade 	bl	80038b4 <HAL_RCC_GetPCLK1Freq>
 80062f8:	f7fe bfc4 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          HAL_RCCEx_GetPLL3ClockFreq(&pll3_clocks);
 80062fc:	a801      	add	r0, sp, #4
 80062fe:	f7fe fe87 	bl	8005010 <HAL_RCCEx_GetPLL3ClockFreq>
          frequency = pll3_clocks.PLL3_R_Frequency;
 8006302:	9803      	ldr	r0, [sp, #12]
 8006304:	f7fe bfbe 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = (HSI_VALUE >> (__HAL_RCC_GET_HSI_DIVIDER() >> RCC_CR_HSIDIV_Pos));
 8006308:	6813      	ldr	r3, [r2, #0]
 800630a:	f3c3 03c1 	ubfx	r3, r3, #3, #2
 800630e:	4804      	ldr	r0, [pc, #16]	@ (8006320 <HAL_RCCEx_GetPeriphCLKFreq+0x10f8>)
 8006310:	40d8      	lsrs	r0, r3
 8006312:	f7fe bfb7 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
        switch (srcclk)
 8006316:	2000      	movs	r0, #0
 8006318:	f7fe bfb4 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
 800631c:	44020c00 	.word	0x44020c00
 8006320:	03d09000 	.word	0x03d09000
 8006324:	f5b3 6f80 	cmp.w	r3, #1024	@ 0x400
 8006328:	d02e      	beq.n	8006388 <HAL_RCCEx_GetPeriphCLKFreq+0x1160>
 800632a:	f5b3 6fa0 	cmp.w	r3, #1280	@ 0x500
 800632e:	d111      	bne.n	8006354 <HAL_RCCEx_GetPeriphCLKFreq+0x112c>
            ckpclocksource = __HAL_RCC_GET_CLKP_SOURCE();
 8006330:	4ab0      	ldr	r2, [pc, #704]	@ (80065f4 <HAL_RCCEx_GetPeriphCLKFreq+0x13cc>)
 8006332:	f8d2 30e8 	ldr.w	r3, [r2, #232]	@ 0xe8
 8006336:	f003 4340 	and.w	r3, r3, #3221225472	@ 0xc0000000
            if (HAL_IS_BIT_SET(RCC->CR, RCC_CR_HSIRDY) && (ckpclocksource == RCC_CLKPSOURCE_HSI))
 800633a:	6812      	ldr	r2, [r2, #0]
 800633c:	f012 0f02 	tst.w	r2, #2
 8006340:	d02d      	beq.n	800639e <HAL_RCCEx_GetPeriphCLKFreq+0x1176>
 8006342:	bb63      	cbnz	r3, 800639e <HAL_RCCEx_GetPeriphCLKFreq+0x1176>
              frequency = (HSI_VALUE >> (__HAL_RCC_GET_HSI_DIVIDER() >> RCC_CR_HSIDIV_Pos));
 8006344:	4bab      	ldr	r3, [pc, #684]	@ (80065f4 <HAL_RCCEx_GetPeriphCLKFreq+0x13cc>)
 8006346:	681b      	ldr	r3, [r3, #0]
 8006348:	f3c3 03c1 	ubfx	r3, r3, #3, #2
 800634c:	48aa      	ldr	r0, [pc, #680]	@ (80065f8 <HAL_RCCEx_GetPeriphCLKFreq+0x13d0>)
 800634e:	40d8      	lsrs	r0, r3
 8006350:	f7fe bf98 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
        switch (srcclk)
 8006354:	2000      	movs	r0, #0
 8006356:	f7fe bf95 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
            HAL_RCCEx_GetPLL2ClockFreq(&pll2_clocks);
 800635a:	a804      	add	r0, sp, #16
 800635c:	f7fe fd4c 	bl	8004df8 <HAL_RCCEx_GetPLL2ClockFreq>
            frequency = pll2_clocks.PLL2_P_Frequency;
 8006360:	9804      	ldr	r0, [sp, #16]
            break;
 8006362:	f7fe bf8f 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
            HAL_RCCEx_GetPLL3ClockFreq(&pll3_clocks);
 8006366:	a801      	add	r0, sp, #4
 8006368:	f7fe fe52 	bl	8005010 <HAL_RCCEx_GetPLL3ClockFreq>
            frequency = pll3_clocks.PLL3_R_Frequency;
 800636c:	9803      	ldr	r0, [sp, #12]
            break;
 800636e:	f7fe bf89 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
            if (HAL_IS_BIT_SET(RCC->BDCR, RCC_BDCR_LSERDY))
 8006372:	4ba0      	ldr	r3, [pc, #640]	@ (80065f4 <HAL_RCCEx_GetPeriphCLKFreq+0x13cc>)
 8006374:	f8d3 00f0 	ldr.w	r0, [r3, #240]	@ 0xf0
 8006378:	f010 0002 	ands.w	r0, r0, #2
 800637c:	f43e af82 	beq.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
              frequency = LSE_VALUE;
 8006380:	f44f 4000 	mov.w	r0, #32768	@ 0x8000
 8006384:	f7fe bf7e 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
            if (HAL_IS_BIT_SET(RCC->BDCR, RCC_BDCR_LSIRDY))
 8006388:	4b9a      	ldr	r3, [pc, #616]	@ (80065f4 <HAL_RCCEx_GetPeriphCLKFreq+0x13cc>)
 800638a:	f8d3 00f0 	ldr.w	r0, [r3, #240]	@ 0xf0
 800638e:	f010 6000 	ands.w	r0, r0, #134217728	@ 0x8000000
 8006392:	f43e af77 	beq.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
              frequency = LSI_VALUE;
 8006396:	f44f 40fa 	mov.w	r0, #32000	@ 0x7d00
 800639a:	f7fe bf73 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
            else if (HAL_IS_BIT_SET(RCC->CR, RCC_CR_CSIRDY) && (ckpclocksource == RCC_CLKPSOURCE_CSI))
 800639e:	4a95      	ldr	r2, [pc, #596]	@ (80065f4 <HAL_RCCEx_GetPeriphCLKFreq+0x13cc>)
 80063a0:	6812      	ldr	r2, [r2, #0]
 80063a2:	f412 7f00 	tst.w	r2, #512	@ 0x200
 80063a6:	d003      	beq.n	80063b0 <HAL_RCCEx_GetPeriphCLKFreq+0x1188>
 80063a8:	f1b3 4f80 	cmp.w	r3, #1073741824	@ 0x40000000
 80063ac:	f000 8506 	beq.w	8006dbc <HAL_RCCEx_GetPeriphCLKFreq+0x1b94>
            else if (HAL_IS_BIT_SET(RCC->CR, RCC_CR_HSERDY) && (ckpclocksource == RCC_CLKPSOURCE_HSE))
 80063b0:	4a90      	ldr	r2, [pc, #576]	@ (80065f4 <HAL_RCCEx_GetPeriphCLKFreq+0x13cc>)
 80063b2:	6812      	ldr	r2, [r2, #0]
 80063b4:	f412 3f00 	tst.w	r2, #131072	@ 0x20000
 80063b8:	f000 8503 	beq.w	8006dc2 <HAL_RCCEx_GetPeriphCLKFreq+0x1b9a>
 80063bc:	f1b3 4f00 	cmp.w	r3, #2147483648	@ 0x80000000
 80063c0:	f000 8502 	beq.w	8006dc8 <HAL_RCCEx_GetPeriphCLKFreq+0x1ba0>
              frequency = 0;
 80063c4:	2000      	movs	r0, #0
 80063c6:	f7fe bf5d 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
        srcclk = __HAL_RCC_GET_LPTIM2_SOURCE();
 80063ca:	4b8a      	ldr	r3, [pc, #552]	@ (80065f4 <HAL_RCCEx_GetPeriphCLKFreq+0x13cc>)
 80063cc:	f8d3 30dc 	ldr.w	r3, [r3, #220]	@ 0xdc
 80063d0:	f403 43e0 	and.w	r3, r3, #28672	@ 0x7000
        switch (srcclk)
 80063d4:	f5b3 5f40 	cmp.w	r3, #12288	@ 0x3000
 80063d8:	d035      	beq.n	8006446 <HAL_RCCEx_GetPeriphCLKFreq+0x121e>
 80063da:	d80d      	bhi.n	80063f8 <HAL_RCCEx_GetPeriphCLKFreq+0x11d0>
 80063dc:	f5b3 5f80 	cmp.w	r3, #4096	@ 0x1000
 80063e0:	d025      	beq.n	800642e <HAL_RCCEx_GetPeriphCLKFreq+0x1206>
 80063e2:	f5b3 5f00 	cmp.w	r3, #8192	@ 0x2000
 80063e6:	d028      	beq.n	800643a <HAL_RCCEx_GetPeriphCLKFreq+0x1212>
 80063e8:	b91b      	cbnz	r3, 80063f2 <HAL_RCCEx_GetPeriphCLKFreq+0x11ca>
            frequency = HAL_RCC_GetPCLK1Freq();
 80063ea:	f7fd fa63 	bl	80038b4 <HAL_RCC_GetPCLK1Freq>
            break;
 80063ee:	f7fe bf49 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
        switch (srcclk)
 80063f2:	2000      	movs	r0, #0
 80063f4:	f7fe bf46 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
 80063f8:	f5b3 4f80 	cmp.w	r3, #16384	@ 0x4000
 80063fc:	d02e      	beq.n	800645c <HAL_RCCEx_GetPeriphCLKFreq+0x1234>
 80063fe:	f5b3 4fa0 	cmp.w	r3, #20480	@ 0x5000
 8006402:	d111      	bne.n	8006428 <HAL_RCCEx_GetPeriphCLKFreq+0x1200>
            ckpclocksource = __HAL_RCC_GET_CLKP_SOURCE();
 8006404:	4a7b      	ldr	r2, [pc, #492]	@ (80065f4 <HAL_RCCEx_GetPeriphCLKFreq+0x13cc>)
 8006406:	f8d2 30e8 	ldr.w	r3, [r2, #232]	@ 0xe8
 800640a:	f003 4340 	and.w	r3, r3, #3221225472	@ 0xc0000000
            if (HAL_IS_BIT_SET(RCC->CR, RCC_CR_HSIRDY) && (ckpclocksource == RCC_CLKPSOURCE_HSI))
 800640e:	6812      	ldr	r2, [r2, #0]
 8006410:	f012 0f02 	tst.w	r2, #2
 8006414:	d02d      	beq.n	8006472 <HAL_RCCEx_GetPeriphCLKFreq+0x124a>
 8006416:	bb63      	cbnz	r3, 8006472 <HAL_RCCEx_GetPeriphCLKFreq+0x124a>
              frequency = (HSI_VALUE >> (__HAL_RCC_GET_HSI_DIVIDER() >> RCC_CR_HSIDIV_Pos));
 8006418:	4b76      	ldr	r3, [pc, #472]	@ (80065f4 <HAL_RCCEx_GetPeriphCLKFreq+0x13cc>)
 800641a:	681b      	ldr	r3, [r3, #0]
 800641c:	f3c3 03c1 	ubfx	r3, r3, #3, #2
 8006420:	4875      	ldr	r0, [pc, #468]	@ (80065f8 <HAL_RCCEx_GetPeriphCLKFreq+0x13d0>)
 8006422:	40d8      	lsrs	r0, r3
 8006424:	f7fe bf2e 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
        switch (srcclk)
 8006428:	2000      	movs	r0, #0
 800642a:	f7fe bf2b 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
            HAL_RCCEx_GetPLL2ClockFreq(&pll2_clocks);
 800642e:	a804      	add	r0, sp, #16
 8006430:	f7fe fce2 	bl	8004df8 <HAL_RCCEx_GetPLL2ClockFreq>
            frequency = pll2_clocks.PLL2_P_Frequency;
 8006434:	9804      	ldr	r0, [sp, #16]
            break;
 8006436:	f7fe bf25 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
            HAL_RCCEx_GetPLL3ClockFreq(&pll3_clocks);
 800643a:	a801      	add	r0, sp, #4
 800643c:	f7fe fde8 	bl	8005010 <HAL_RCCEx_GetPLL3ClockFreq>
            frequency = pll3_clocks.PLL3_R_Frequency;
 8006440:	9803      	ldr	r0, [sp, #12]
            break;
 8006442:	f7fe bf1f 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
            if (HAL_IS_BIT_SET(RCC->BDCR, RCC_BDCR_LSERDY))
 8006446:	4b6b      	ldr	r3, [pc, #428]	@ (80065f4 <HAL_RCCEx_GetPeriphCLKFreq+0x13cc>)
 8006448:	f8d3 00f0 	ldr.w	r0, [r3, #240]	@ 0xf0
 800644c:	f010 0002 	ands.w	r0, r0, #2
 8006450:	f43e af18 	beq.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
              frequency = LSE_VALUE;
 8006454:	f44f 4000 	mov.w	r0, #32768	@ 0x8000
 8006458:	f7fe bf14 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
            if (HAL_IS_BIT_SET(RCC->BDCR, RCC_BDCR_LSIRDY))
 800645c:	4b65      	ldr	r3, [pc, #404]	@ (80065f4 <HAL_RCCEx_GetPeriphCLKFreq+0x13cc>)
 800645e:	f8d3 00f0 	ldr.w	r0, [r3, #240]	@ 0xf0
 8006462:	f010 6000 	ands.w	r0, r0, #134217728	@ 0x8000000
 8006466:	f43e af0d 	beq.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
              frequency = LSI_VALUE;
 800646a:	f44f 40fa 	mov.w	r0, #32000	@ 0x7d00
 800646e:	f7fe bf09 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
            else if (HAL_IS_BIT_SET(RCC->CR, RCC_CR_CSIRDY) && (ckpclocksource == RCC_CLKPSOURCE_CSI))
 8006472:	4a60      	ldr	r2, [pc, #384]	@ (80065f4 <HAL_RCCEx_GetPeriphCLKFreq+0x13cc>)
 8006474:	6812      	ldr	r2, [r2, #0]
 8006476:	f412 7f00 	tst.w	r2, #512	@ 0x200
 800647a:	d003      	beq.n	8006484 <HAL_RCCEx_GetPeriphCLKFreq+0x125c>
 800647c:	f1b3 4f80 	cmp.w	r3, #1073741824	@ 0x40000000
 8006480:	f000 84a5 	beq.w	8006dce <HAL_RCCEx_GetPeriphCLKFreq+0x1ba6>
            else if (HAL_IS_BIT_SET(RCC->CR, RCC_CR_HSERDY) && (ckpclocksource == RCC_CLKPSOURCE_HSE))
 8006484:	4a5b      	ldr	r2, [pc, #364]	@ (80065f4 <HAL_RCCEx_GetPeriphCLKFreq+0x13cc>)
 8006486:	6812      	ldr	r2, [r2, #0]
 8006488:	f412 3f00 	tst.w	r2, #131072	@ 0x20000
 800648c:	f000 84a2 	beq.w	8006dd4 <HAL_RCCEx_GetPeriphCLKFreq+0x1bac>
 8006490:	f1b3 4f00 	cmp.w	r3, #2147483648	@ 0x80000000
 8006494:	f000 84a1 	beq.w	8006dda <HAL_RCCEx_GetPeriphCLKFreq+0x1bb2>
              frequency = 0;
 8006498:	2000      	movs	r0, #0
 800649a:	f7fe bef3 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
        switch (srcclk)
 800649e:	2000      	movs	r0, #0
 80064a0:	f7fe bef0 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
 80064a4:	f5b3 2f80 	cmp.w	r3, #262144	@ 0x40000
 80064a8:	d02e      	beq.n	8006508 <HAL_RCCEx_GetPeriphCLKFreq+0x12e0>
 80064aa:	f5b3 2fa0 	cmp.w	r3, #327680	@ 0x50000
 80064ae:	d111      	bne.n	80064d4 <HAL_RCCEx_GetPeriphCLKFreq+0x12ac>
            ckpclocksource = __HAL_RCC_GET_CLKP_SOURCE();
 80064b0:	4a50      	ldr	r2, [pc, #320]	@ (80065f4 <HAL_RCCEx_GetPeriphCLKFreq+0x13cc>)
 80064b2:	f8d2 30e8 	ldr.w	r3, [r2, #232]	@ 0xe8
 80064b6:	f003 4340 	and.w	r3, r3, #3221225472	@ 0xc0000000
            if (HAL_IS_BIT_SET(RCC->CR, RCC_CR_HSIRDY) && (ckpclocksource == RCC_CLKPSOURCE_HSI))
 80064ba:	6812      	ldr	r2, [r2, #0]
 80064bc:	f012 0f02 	tst.w	r2, #2
 80064c0:	d02d      	beq.n	800651e <HAL_RCCEx_GetPeriphCLKFreq+0x12f6>
 80064c2:	bb63      	cbnz	r3, 800651e <HAL_RCCEx_GetPeriphCLKFreq+0x12f6>
              frequency = (HSI_VALUE >> (__HAL_RCC_GET_HSI_DIVIDER() >> RCC_CR_HSIDIV_Pos));
 80064c4:	4b4b      	ldr	r3, [pc, #300]	@ (80065f4 <HAL_RCCEx_GetPeriphCLKFreq+0x13cc>)
 80064c6:	681b      	ldr	r3, [r3, #0]
 80064c8:	f3c3 03c1 	ubfx	r3, r3, #3, #2
 80064cc:	484a      	ldr	r0, [pc, #296]	@ (80065f8 <HAL_RCCEx_GetPeriphCLKFreq+0x13d0>)
 80064ce:	40d8      	lsrs	r0, r3
 80064d0:	f7fe bed8 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
        switch (srcclk)
 80064d4:	2000      	movs	r0, #0
 80064d6:	f7fe bed5 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
            HAL_RCCEx_GetPLL2ClockFreq(&pll2_clocks);
 80064da:	a804      	add	r0, sp, #16
 80064dc:	f7fe fc8c 	bl	8004df8 <HAL_RCCEx_GetPLL2ClockFreq>
            frequency = pll2_clocks.PLL2_P_Frequency;
 80064e0:	9804      	ldr	r0, [sp, #16]
            break;
 80064e2:	f7fe becf 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
            HAL_RCCEx_GetPLL3ClockFreq(&pll3_clocks);
 80064e6:	a801      	add	r0, sp, #4
 80064e8:	f7fe fd92 	bl	8005010 <HAL_RCCEx_GetPLL3ClockFreq>
            frequency = pll3_clocks.PLL3_R_Frequency;
 80064ec:	9803      	ldr	r0, [sp, #12]
            break;
 80064ee:	f7fe bec9 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
            if (HAL_IS_BIT_SET(RCC->BDCR, RCC_BDCR_LSERDY))
 80064f2:	4b40      	ldr	r3, [pc, #256]	@ (80065f4 <HAL_RCCEx_GetPeriphCLKFreq+0x13cc>)
 80064f4:	f8d3 00f0 	ldr.w	r0, [r3, #240]	@ 0xf0
 80064f8:	f010 0002 	ands.w	r0, r0, #2
 80064fc:	f43e aec2 	beq.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
              frequency = LSE_VALUE;
 8006500:	f44f 4000 	mov.w	r0, #32768	@ 0x8000
 8006504:	f7fe bebe 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
            if (HAL_IS_BIT_SET(RCC->BDCR, RCC_BDCR_LSIRDY))
 8006508:	4b3a      	ldr	r3, [pc, #232]	@ (80065f4 <HAL_RCCEx_GetPeriphCLKFreq+0x13cc>)
 800650a:	f8d3 00f0 	ldr.w	r0, [r3, #240]	@ 0xf0
 800650e:	f010 6000 	ands.w	r0, r0, #134217728	@ 0x8000000
 8006512:	f43e aeb7 	beq.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
              frequency = LSI_VALUE;
 8006516:	f44f 40fa 	mov.w	r0, #32000	@ 0x7d00
 800651a:	f7fe beb3 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
            else if (HAL_IS_BIT_SET(RCC->CR, RCC_CR_CSIRDY) && (ckpclocksource == RCC_CLKPSOURCE_CSI))
 800651e:	4a35      	ldr	r2, [pc, #212]	@ (80065f4 <HAL_RCCEx_GetPeriphCLKFreq+0x13cc>)
 8006520:	6812      	ldr	r2, [r2, #0]
 8006522:	f412 7f00 	tst.w	r2, #512	@ 0x200
 8006526:	d003      	beq.n	8006530 <HAL_RCCEx_GetPeriphCLKFreq+0x1308>
 8006528:	f1b3 4f80 	cmp.w	r3, #1073741824	@ 0x40000000
 800652c:	f000 8458 	beq.w	8006de0 <HAL_RCCEx_GetPeriphCLKFreq+0x1bb8>
            else if (HAL_IS_BIT_SET(RCC->CR, RCC_CR_HSERDY) && (ckpclocksource == RCC_CLKPSOURCE_HSE))
 8006530:	4a30      	ldr	r2, [pc, #192]	@ (80065f4 <HAL_RCCEx_GetPeriphCLKFreq+0x13cc>)
 8006532:	6812      	ldr	r2, [r2, #0]
 8006534:	f412 3f00 	tst.w	r2, #131072	@ 0x20000
 8006538:	f000 8455 	beq.w	8006de6 <HAL_RCCEx_GetPeriphCLKFreq+0x1bbe>
 800653c:	f1b3 4f00 	cmp.w	r3, #2147483648	@ 0x80000000
 8006540:	f000 8454 	beq.w	8006dec <HAL_RCCEx_GetPeriphCLKFreq+0x1bc4>
              frequency = 0;
 8006544:	2000      	movs	r0, #0
 8006546:	f7fe be9d 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
        srcclk = __HAL_RCC_GET_LPTIM4_SOURCE();
 800654a:	4b2a      	ldr	r3, [pc, #168]	@ (80065f4 <HAL_RCCEx_GetPeriphCLKFreq+0x13cc>)
 800654c:	f8d3 30dc 	ldr.w	r3, [r3, #220]	@ 0xdc
 8006550:	f403 03e0 	and.w	r3, r3, #7340032	@ 0x700000
        switch (srcclk)
 8006554:	f5b3 1f40 	cmp.w	r3, #3145728	@ 0x300000
 8006558:	d035      	beq.n	80065c6 <HAL_RCCEx_GetPeriphCLKFreq+0x139e>
 800655a:	d80d      	bhi.n	8006578 <HAL_RCCEx_GetPeriphCLKFreq+0x1350>
 800655c:	f5b3 1f80 	cmp.w	r3, #1048576	@ 0x100000
 8006560:	d025      	beq.n	80065ae <HAL_RCCEx_GetPeriphCLKFreq+0x1386>
 8006562:	f5b3 1f00 	cmp.w	r3, #2097152	@ 0x200000
 8006566:	d028      	beq.n	80065ba <HAL_RCCEx_GetPeriphCLKFreq+0x1392>
 8006568:	b91b      	cbnz	r3, 8006572 <HAL_RCCEx_GetPeriphCLKFreq+0x134a>
            frequency = HAL_RCC_GetPCLK3Freq();
 800656a:	f7fd f9c7 	bl	80038fc <HAL_RCC_GetPCLK3Freq>
            break;
 800656e:	f7fe be89 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
        switch (srcclk)
 8006572:	2000      	movs	r0, #0
 8006574:	f7fe be86 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
 8006578:	f5b3 0f80 	cmp.w	r3, #4194304	@ 0x400000
 800657c:	d02e      	beq.n	80065dc <HAL_RCCEx_GetPeriphCLKFreq+0x13b4>
 800657e:	f5b3 0fa0 	cmp.w	r3, #5242880	@ 0x500000
 8006582:	d111      	bne.n	80065a8 <HAL_RCCEx_GetPeriphCLKFreq+0x1380>
            ckpclocksource = __HAL_RCC_GET_CLKP_SOURCE();
 8006584:	4a1b      	ldr	r2, [pc, #108]	@ (80065f4 <HAL_RCCEx_GetPeriphCLKFreq+0x13cc>)
 8006586:	f8d2 30e8 	ldr.w	r3, [r2, #232]	@ 0xe8
 800658a:	f003 4340 	and.w	r3, r3, #3221225472	@ 0xc0000000
            if (HAL_IS_BIT_SET(RCC->CR, RCC_CR_HSIRDY) && (ckpclocksource == RCC_CLKPSOURCE_HSI))
 800658e:	6812      	ldr	r2, [r2, #0]
 8006590:	f012 0f02 	tst.w	r2, #2
 8006594:	d032      	beq.n	80065fc <HAL_RCCEx_GetPeriphCLKFreq+0x13d4>
 8006596:	bb8b      	cbnz	r3, 80065fc <HAL_RCCEx_GetPeriphCLKFreq+0x13d4>
              frequency = (HSI_VALUE >> (__HAL_RCC_GET_HSI_DIVIDER() >> RCC_CR_HSIDIV_Pos));
 8006598:	4b16      	ldr	r3, [pc, #88]	@ (80065f4 <HAL_RCCEx_GetPeriphCLKFreq+0x13cc>)
 800659a:	681b      	ldr	r3, [r3, #0]
 800659c:	f3c3 03c1 	ubfx	r3, r3, #3, #2
 80065a0:	4815      	ldr	r0, [pc, #84]	@ (80065f8 <HAL_RCCEx_GetPeriphCLKFreq+0x13d0>)
 80065a2:	40d8      	lsrs	r0, r3
 80065a4:	f7fe be6e 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
        switch (srcclk)
 80065a8:	2000      	movs	r0, #0
 80065aa:	f7fe be6b 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
            HAL_RCCEx_GetPLL2ClockFreq(&pll2_clocks);
 80065ae:	a804      	add	r0, sp, #16
 80065b0:	f7fe fc22 	bl	8004df8 <HAL_RCCEx_GetPLL2ClockFreq>
            frequency = pll2_clocks.PLL2_P_Frequency;
 80065b4:	9804      	ldr	r0, [sp, #16]
            break;
 80065b6:	f7fe be65 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
            HAL_RCCEx_GetPLL3ClockFreq(&pll3_clocks);
 80065ba:	a801      	add	r0, sp, #4
 80065bc:	f7fe fd28 	bl	8005010 <HAL_RCCEx_GetPLL3ClockFreq>
            frequency = pll3_clocks.PLL3_R_Frequency;
 80065c0:	9803      	ldr	r0, [sp, #12]
            break;
 80065c2:	f7fe be5f 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
            if (HAL_IS_BIT_SET(RCC->BDCR, RCC_BDCR_LSERDY))
 80065c6:	4b0b      	ldr	r3, [pc, #44]	@ (80065f4 <HAL_RCCEx_GetPeriphCLKFreq+0x13cc>)
 80065c8:	f8d3 00f0 	ldr.w	r0, [r3, #240]	@ 0xf0
 80065cc:	f010 0002 	ands.w	r0, r0, #2
 80065d0:	f43e ae58 	beq.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
              frequency = LSE_VALUE;
 80065d4:	f44f 4000 	mov.w	r0, #32768	@ 0x8000
 80065d8:	f7fe be54 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
            if (HAL_IS_BIT_SET(RCC->BDCR, RCC_BDCR_LSIRDY))
 80065dc:	4b05      	ldr	r3, [pc, #20]	@ (80065f4 <HAL_RCCEx_GetPeriphCLKFreq+0x13cc>)
 80065de:	f8d3 00f0 	ldr.w	r0, [r3, #240]	@ 0xf0
 80065e2:	f010 6000 	ands.w	r0, r0, #134217728	@ 0x8000000
 80065e6:	f43e ae4d 	beq.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
              frequency = LSI_VALUE;
 80065ea:	f44f 40fa 	mov.w	r0, #32000	@ 0x7d00
 80065ee:	f7fe be49 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
 80065f2:	bf00      	nop
 80065f4:	44020c00 	.word	0x44020c00
 80065f8:	03d09000 	.word	0x03d09000
            else if (HAL_IS_BIT_SET(RCC->CR, RCC_CR_CSIRDY) && (ckpclocksource == RCC_CLKPSOURCE_CSI))
 80065fc:	4a99      	ldr	r2, [pc, #612]	@ (8006864 <HAL_RCCEx_GetPeriphCLKFreq+0x163c>)
 80065fe:	6812      	ldr	r2, [r2, #0]
 8006600:	f412 7f00 	tst.w	r2, #512	@ 0x200
 8006604:	d003      	beq.n	800660e <HAL_RCCEx_GetPeriphCLKFreq+0x13e6>
 8006606:	f1b3 4f80 	cmp.w	r3, #1073741824	@ 0x40000000
 800660a:	f000 83f2 	beq.w	8006df2 <HAL_RCCEx_GetPeriphCLKFreq+0x1bca>
            else if (HAL_IS_BIT_SET(RCC->CR, RCC_CR_HSERDY) && (ckpclocksource == RCC_CLKPSOURCE_HSE))
 800660e:	4a95      	ldr	r2, [pc, #596]	@ (8006864 <HAL_RCCEx_GetPeriphCLKFreq+0x163c>)
 8006610:	6812      	ldr	r2, [r2, #0]
 8006612:	f412 3f00 	tst.w	r2, #131072	@ 0x20000
 8006616:	f000 83ef 	beq.w	8006df8 <HAL_RCCEx_GetPeriphCLKFreq+0x1bd0>
 800661a:	f1b3 4f00 	cmp.w	r3, #2147483648	@ 0x80000000
 800661e:	f000 83ee 	beq.w	8006dfe <HAL_RCCEx_GetPeriphCLKFreq+0x1bd6>
              frequency = 0;
 8006622:	2000      	movs	r0, #0
 8006624:	f7fe be2e 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
        srcclk = __HAL_RCC_GET_LPTIM5_SOURCE();
 8006628:	4b8e      	ldr	r3, [pc, #568]	@ (8006864 <HAL_RCCEx_GetPeriphCLKFreq+0x163c>)
 800662a:	f8d3 30dc 	ldr.w	r3, [r3, #220]	@ 0xdc
 800662e:	f003 63e0 	and.w	r3, r3, #117440512	@ 0x7000000
        switch (srcclk)
 8006632:	f1b3 7f40 	cmp.w	r3, #50331648	@ 0x3000000
 8006636:	d035      	beq.n	80066a4 <HAL_RCCEx_GetPeriphCLKFreq+0x147c>
 8006638:	d80d      	bhi.n	8006656 <HAL_RCCEx_GetPeriphCLKFreq+0x142e>
 800663a:	f1b3 7f80 	cmp.w	r3, #16777216	@ 0x1000000
 800663e:	d025      	beq.n	800668c <HAL_RCCEx_GetPeriphCLKFreq+0x1464>
 8006640:	f1b3 7f00 	cmp.w	r3, #33554432	@ 0x2000000
 8006644:	d028      	beq.n	8006698 <HAL_RCCEx_GetPeriphCLKFreq+0x1470>
 8006646:	b91b      	cbnz	r3, 8006650 <HAL_RCCEx_GetPeriphCLKFreq+0x1428>
            frequency = HAL_RCC_GetPCLK3Freq();
 8006648:	f7fd f958 	bl	80038fc <HAL_RCC_GetPCLK3Freq>
            break;
 800664c:	f7fe be1a 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
        switch (srcclk)
 8006650:	2000      	movs	r0, #0
 8006652:	f7fe be17 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
 8006656:	f1b3 6f80 	cmp.w	r3, #67108864	@ 0x4000000
 800665a:	d02e      	beq.n	80066ba <HAL_RCCEx_GetPeriphCLKFreq+0x1492>
 800665c:	f1b3 6fa0 	cmp.w	r3, #83886080	@ 0x5000000
 8006660:	d111      	bne.n	8006686 <HAL_RCCEx_GetPeriphCLKFreq+0x145e>
            ckpclocksource = __HAL_RCC_GET_CLKP_SOURCE();
 8006662:	4a80      	ldr	r2, [pc, #512]	@ (8006864 <HAL_RCCEx_GetPeriphCLKFreq+0x163c>)
 8006664:	f8d2 30e8 	ldr.w	r3, [r2, #232]	@ 0xe8
 8006668:	f003 4340 	and.w	r3, r3, #3221225472	@ 0xc0000000
            if (HAL_IS_BIT_SET(RCC->CR, RCC_CR_HSIRDY) && (ckpclocksource == RCC_CLKPSOURCE_HSI))
 800666c:	6812      	ldr	r2, [r2, #0]
 800666e:	f012 0f02 	tst.w	r2, #2
 8006672:	d02d      	beq.n	80066d0 <HAL_RCCEx_GetPeriphCLKFreq+0x14a8>
 8006674:	bb63      	cbnz	r3, 80066d0 <HAL_RCCEx_GetPeriphCLKFreq+0x14a8>
              frequency = (HSI_VALUE >> (__HAL_RCC_GET_HSI_DIVIDER() >> RCC_CR_HSIDIV_Pos));
 8006676:	4b7b      	ldr	r3, [pc, #492]	@ (8006864 <HAL_RCCEx_GetPeriphCLKFreq+0x163c>)
 8006678:	681b      	ldr	r3, [r3, #0]
 800667a:	f3c3 03c1 	ubfx	r3, r3, #3, #2
 800667e:	487a      	ldr	r0, [pc, #488]	@ (8006868 <HAL_RCCEx_GetPeriphCLKFreq+0x1640>)
 8006680:	40d8      	lsrs	r0, r3
 8006682:	f7fe bdff 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
        switch (srcclk)
 8006686:	2000      	movs	r0, #0
 8006688:	f7fe bdfc 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
            HAL_RCCEx_GetPLL2ClockFreq(&pll2_clocks);
 800668c:	a804      	add	r0, sp, #16
 800668e:	f7fe fbb3 	bl	8004df8 <HAL_RCCEx_GetPLL2ClockFreq>
            frequency = pll2_clocks.PLL2_P_Frequency;
 8006692:	9804      	ldr	r0, [sp, #16]
            break;
 8006694:	f7fe bdf6 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
            HAL_RCCEx_GetPLL3ClockFreq(&pll3_clocks);
 8006698:	a801      	add	r0, sp, #4
 800669a:	f7fe fcb9 	bl	8005010 <HAL_RCCEx_GetPLL3ClockFreq>
            frequency = pll3_clocks.PLL3_R_Frequency;
 800669e:	9803      	ldr	r0, [sp, #12]
            break;
 80066a0:	f7fe bdf0 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
            if (HAL_IS_BIT_SET(RCC->BDCR, RCC_BDCR_LSERDY))
 80066a4:	4b6f      	ldr	r3, [pc, #444]	@ (8006864 <HAL_RCCEx_GetPeriphCLKFreq+0x163c>)
 80066a6:	f8d3 00f0 	ldr.w	r0, [r3, #240]	@ 0xf0
 80066aa:	f010 0002 	ands.w	r0, r0, #2
 80066ae:	f43e ade9 	beq.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
              frequency = LSE_VALUE;
 80066b2:	f44f 4000 	mov.w	r0, #32768	@ 0x8000
 80066b6:	f7fe bde5 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
            if (HAL_IS_BIT_SET(RCC->BDCR, RCC_BDCR_LSIRDY))
 80066ba:	4b6a      	ldr	r3, [pc, #424]	@ (8006864 <HAL_RCCEx_GetPeriphCLKFreq+0x163c>)
 80066bc:	f8d3 00f0 	ldr.w	r0, [r3, #240]	@ 0xf0
 80066c0:	f010 6000 	ands.w	r0, r0, #134217728	@ 0x8000000
 80066c4:	f43e adde 	beq.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
              frequency = LSI_VALUE;
 80066c8:	f44f 40fa 	mov.w	r0, #32000	@ 0x7d00
 80066cc:	f7fe bdda 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
            else if (HAL_IS_BIT_SET(RCC->CR, RCC_CR_CSIRDY) && (ckpclocksource == RCC_CLKPSOURCE_CSI))
 80066d0:	4a64      	ldr	r2, [pc, #400]	@ (8006864 <HAL_RCCEx_GetPeriphCLKFreq+0x163c>)
 80066d2:	6812      	ldr	r2, [r2, #0]
 80066d4:	f412 7f00 	tst.w	r2, #512	@ 0x200
 80066d8:	d003      	beq.n	80066e2 <HAL_RCCEx_GetPeriphCLKFreq+0x14ba>
 80066da:	f1b3 4f80 	cmp.w	r3, #1073741824	@ 0x40000000
 80066de:	f000 8391 	beq.w	8006e04 <HAL_RCCEx_GetPeriphCLKFreq+0x1bdc>
            else if (HAL_IS_BIT_SET(RCC->CR, RCC_CR_HSERDY) && (ckpclocksource == RCC_CLKPSOURCE_HSE))
 80066e2:	4a60      	ldr	r2, [pc, #384]	@ (8006864 <HAL_RCCEx_GetPeriphCLKFreq+0x163c>)
 80066e4:	6812      	ldr	r2, [r2, #0]
 80066e6:	f412 3f00 	tst.w	r2, #131072	@ 0x20000
 80066ea:	f000 838e 	beq.w	8006e0a <HAL_RCCEx_GetPeriphCLKFreq+0x1be2>
 80066ee:	f1b3 4f00 	cmp.w	r3, #2147483648	@ 0x80000000
 80066f2:	f000 838d 	beq.w	8006e10 <HAL_RCCEx_GetPeriphCLKFreq+0x1be8>
              frequency = 0;
 80066f6:	2000      	movs	r0, #0
 80066f8:	f7fe bdc4 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
        switch (srcclk)
 80066fc:	2000      	movs	r0, #0
 80066fe:	f7fe bdc1 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
 8006702:	f1b3 4f80 	cmp.w	r3, #1073741824	@ 0x40000000
 8006706:	d02e      	beq.n	8006766 <HAL_RCCEx_GetPeriphCLKFreq+0x153e>
 8006708:	f1b3 4fa0 	cmp.w	r3, #1342177280	@ 0x50000000
 800670c:	d111      	bne.n	8006732 <HAL_RCCEx_GetPeriphCLKFreq+0x150a>
            ckpclocksource = __HAL_RCC_GET_CLKP_SOURCE();
 800670e:	4a55      	ldr	r2, [pc, #340]	@ (8006864 <HAL_RCCEx_GetPeriphCLKFreq+0x163c>)
 8006710:	f8d2 30e8 	ldr.w	r3, [r2, #232]	@ 0xe8
 8006714:	f003 4340 	and.w	r3, r3, #3221225472	@ 0xc0000000
            if (HAL_IS_BIT_SET(RCC->CR, RCC_CR_HSIRDY) && (ckpclocksource == RCC_CLKPSOURCE_HSI))
 8006718:	6812      	ldr	r2, [r2, #0]
 800671a:	f012 0f02 	tst.w	r2, #2
 800671e:	d02d      	beq.n	800677c <HAL_RCCEx_GetPeriphCLKFreq+0x1554>
 8006720:	bb63      	cbnz	r3, 800677c <HAL_RCCEx_GetPeriphCLKFreq+0x1554>
              frequency = (HSI_VALUE >> (__HAL_RCC_GET_HSI_DIVIDER() >> RCC_CR_HSIDIV_Pos));
 8006722:	4b50      	ldr	r3, [pc, #320]	@ (8006864 <HAL_RCCEx_GetPeriphCLKFreq+0x163c>)
 8006724:	681b      	ldr	r3, [r3, #0]
 8006726:	f3c3 03c1 	ubfx	r3, r3, #3, #2
 800672a:	484f      	ldr	r0, [pc, #316]	@ (8006868 <HAL_RCCEx_GetPeriphCLKFreq+0x1640>)
 800672c:	40d8      	lsrs	r0, r3
 800672e:	f7fe bda9 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
        switch (srcclk)
 8006732:	2000      	movs	r0, #0
 8006734:	f7fe bda6 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
            HAL_RCCEx_GetPLL2ClockFreq(&pll2_clocks);
 8006738:	a804      	add	r0, sp, #16
 800673a:	f7fe fb5d 	bl	8004df8 <HAL_RCCEx_GetPLL2ClockFreq>
            frequency = pll2_clocks.PLL2_P_Frequency;
 800673e:	9804      	ldr	r0, [sp, #16]
            break;
 8006740:	f7fe bda0 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
            HAL_RCCEx_GetPLL3ClockFreq(&pll3_clocks);
 8006744:	a801      	add	r0, sp, #4
 8006746:	f7fe fc63 	bl	8005010 <HAL_RCCEx_GetPLL3ClockFreq>
            frequency = pll3_clocks.PLL3_R_Frequency;
 800674a:	9803      	ldr	r0, [sp, #12]
            break;
 800674c:	f7fe bd9a 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
            if (HAL_IS_BIT_SET(RCC->BDCR, RCC_BDCR_LSERDY))
 8006750:	4b44      	ldr	r3, [pc, #272]	@ (8006864 <HAL_RCCEx_GetPeriphCLKFreq+0x163c>)
 8006752:	f8d3 00f0 	ldr.w	r0, [r3, #240]	@ 0xf0
 8006756:	f010 0002 	ands.w	r0, r0, #2
 800675a:	f43e ad93 	beq.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
              frequency = LSE_VALUE;
 800675e:	f44f 4000 	mov.w	r0, #32768	@ 0x8000
 8006762:	f7fe bd8f 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
            if (HAL_IS_BIT_SET(RCC->BDCR, RCC_BDCR_LSIRDY))
 8006766:	4b3f      	ldr	r3, [pc, #252]	@ (8006864 <HAL_RCCEx_GetPeriphCLKFreq+0x163c>)
 8006768:	f8d3 00f0 	ldr.w	r0, [r3, #240]	@ 0xf0
 800676c:	f010 6000 	ands.w	r0, r0, #134217728	@ 0x8000000
 8006770:	f43e ad88 	beq.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
              frequency = LSI_VALUE;
 8006774:	f44f 40fa 	mov.w	r0, #32000	@ 0x7d00
 8006778:	f7fe bd84 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
            else if (HAL_IS_BIT_SET(RCC->CR, RCC_CR_CSIRDY) && (ckpclocksource == RCC_CLKPSOURCE_CSI))
 800677c:	4a39      	ldr	r2, [pc, #228]	@ (8006864 <HAL_RCCEx_GetPeriphCLKFreq+0x163c>)
 800677e:	6812      	ldr	r2, [r2, #0]
 8006780:	f412 7f00 	tst.w	r2, #512	@ 0x200
 8006784:	d003      	beq.n	800678e <HAL_RCCEx_GetPeriphCLKFreq+0x1566>
 8006786:	f1b3 4f80 	cmp.w	r3, #1073741824	@ 0x40000000
 800678a:	f000 8344 	beq.w	8006e16 <HAL_RCCEx_GetPeriphCLKFreq+0x1bee>
            else if (HAL_IS_BIT_SET(RCC->CR, RCC_CR_HSERDY) && (ckpclocksource == RCC_CLKPSOURCE_HSE))
 800678e:	4a35      	ldr	r2, [pc, #212]	@ (8006864 <HAL_RCCEx_GetPeriphCLKFreq+0x163c>)
 8006790:	6812      	ldr	r2, [r2, #0]
 8006792:	f412 3f00 	tst.w	r2, #131072	@ 0x20000
 8006796:	f000 8341 	beq.w	8006e1c <HAL_RCCEx_GetPeriphCLKFreq+0x1bf4>
 800679a:	f1b3 4f00 	cmp.w	r3, #2147483648	@ 0x80000000
 800679e:	f000 8340 	beq.w	8006e22 <HAL_RCCEx_GetPeriphCLKFreq+0x1bfa>
              frequency = 0;
 80067a2:	2000      	movs	r0, #0
 80067a4:	f7fe bd6e 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
        srcclk = __HAL_RCC_GET_FDCAN_SOURCE();
 80067a8:	4a2e      	ldr	r2, [pc, #184]	@ (8006864 <HAL_RCCEx_GetPeriphCLKFreq+0x163c>)
 80067aa:	f8d2 30e8 	ldr.w	r3, [r2, #232]	@ 0xe8
 80067ae:	f403 7340 	and.w	r3, r3, #768	@ 0x300
        if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_HSERDY)) && (srcclk == RCC_FDCANCLKSOURCE_HSE))
 80067b2:	6812      	ldr	r2, [r2, #0]
 80067b4:	f412 3f00 	tst.w	r2, #131072	@ 0x20000
 80067b8:	d002      	beq.n	80067c0 <HAL_RCCEx_GetPeriphCLKFreq+0x1598>
 80067ba:	2b00      	cmp	r3, #0
 80067bc:	f000 8334 	beq.w	8006e28 <HAL_RCCEx_GetPeriphCLKFreq+0x1c00>
        else if (srcclk == RCC_FDCANCLKSOURCE_PLL1Q)
 80067c0:	f5b3 7f80 	cmp.w	r3, #256	@ 0x100
 80067c4:	d005      	beq.n	80067d2 <HAL_RCCEx_GetPeriphCLKFreq+0x15aa>
        else if (srcclk == RCC_FDCANCLKSOURCE_PLL2Q)
 80067c6:	f5b3 7f00 	cmp.w	r3, #512	@ 0x200
 80067ca:	d008      	beq.n	80067de <HAL_RCCEx_GetPeriphCLKFreq+0x15b6>
          frequency = 0U;
 80067cc:	2000      	movs	r0, #0
 80067ce:	f7fe bd59 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          HAL_RCCEx_GetPLL1ClockFreq(&pll1_clocks);
 80067d2:	a807      	add	r0, sp, #28
 80067d4:	f7fe fa04 	bl	8004be0 <HAL_RCCEx_GetPLL1ClockFreq>
          frequency = pll1_clocks.PLL1_Q_Frequency;
 80067d8:	9808      	ldr	r0, [sp, #32]
 80067da:	f7fe bd53 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          HAL_RCCEx_GetPLL2ClockFreq(&pll2_clocks);
 80067de:	a804      	add	r0, sp, #16
 80067e0:	f7fe fb0a 	bl	8004df8 <HAL_RCCEx_GetPLL2ClockFreq>
          frequency = pll2_clocks.PLL2_Q_Frequency;
 80067e4:	9805      	ldr	r0, [sp, #20]
 80067e6:	f7fe bd4d 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
        switch (srcclk)
 80067ea:	4820      	ldr	r0, [pc, #128]	@ (800686c <HAL_RCCEx_GetPeriphCLKFreq+0x1644>)
 80067ec:	f7fe bd4a 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
            HAL_RCCEx_GetPLL1ClockFreq(&pll1_clocks);
 80067f0:	a807      	add	r0, sp, #28
 80067f2:	f7fe f9f5 	bl	8004be0 <HAL_RCCEx_GetPLL1ClockFreq>
            frequency = pll1_clocks.PLL1_Q_Frequency;
 80067f6:	9808      	ldr	r0, [sp, #32]
            break;
 80067f8:	f7fe bd44 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
            HAL_RCCEx_GetPLL2ClockFreq(&pll2_clocks);
 80067fc:	a804      	add	r0, sp, #16
 80067fe:	f7fe fafb 	bl	8004df8 <HAL_RCCEx_GetPLL2ClockFreq>
            frequency = pll2_clocks.PLL2_P_Frequency;
 8006802:	9804      	ldr	r0, [sp, #16]
            break;
 8006804:	f7fe bd3e 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
            HAL_RCCEx_GetPLL3ClockFreq(&pll3_clocks);
 8006808:	a801      	add	r0, sp, #4
 800680a:	f7fe fc01 	bl	8005010 <HAL_RCCEx_GetPLL3ClockFreq>
            frequency = pll3_clocks.PLL3_P_Frequency;
 800680e:	9801      	ldr	r0, [sp, #4]
            break;
 8006810:	f7fe bd38 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
            ckpclocksource = __HAL_RCC_GET_CLKP_SOURCE();
 8006814:	4a13      	ldr	r2, [pc, #76]	@ (8006864 <HAL_RCCEx_GetPeriphCLKFreq+0x163c>)
 8006816:	f8d2 30e8 	ldr.w	r3, [r2, #232]	@ 0xe8
 800681a:	f003 4340 	and.w	r3, r3, #3221225472	@ 0xc0000000
            if (HAL_IS_BIT_SET(RCC->CR, RCC_CR_HSIRDY) && (ckpclocksource == RCC_CLKPSOURCE_HSI))
 800681e:	6812      	ldr	r2, [r2, #0]
 8006820:	f012 0f02 	tst.w	r2, #2
 8006824:	d008      	beq.n	8006838 <HAL_RCCEx_GetPeriphCLKFreq+0x1610>
 8006826:	b93b      	cbnz	r3, 8006838 <HAL_RCCEx_GetPeriphCLKFreq+0x1610>
              frequency = (HSI_VALUE >> (__HAL_RCC_GET_HSI_DIVIDER() >> RCC_CR_HSIDIV_Pos));
 8006828:	4b0e      	ldr	r3, [pc, #56]	@ (8006864 <HAL_RCCEx_GetPeriphCLKFreq+0x163c>)
 800682a:	681b      	ldr	r3, [r3, #0]
 800682c:	f3c3 03c1 	ubfx	r3, r3, #3, #2
 8006830:	480d      	ldr	r0, [pc, #52]	@ (8006868 <HAL_RCCEx_GetPeriphCLKFreq+0x1640>)
 8006832:	40d8      	lsrs	r0, r3
 8006834:	f7fe bd26 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
            else if (HAL_IS_BIT_SET(RCC->CR, RCC_CR_CSIRDY) && (ckpclocksource == RCC_CLKPSOURCE_CSI))
 8006838:	4a0a      	ldr	r2, [pc, #40]	@ (8006864 <HAL_RCCEx_GetPeriphCLKFreq+0x163c>)
 800683a:	6812      	ldr	r2, [r2, #0]
 800683c:	f412 7f00 	tst.w	r2, #512	@ 0x200
 8006840:	d003      	beq.n	800684a <HAL_RCCEx_GetPeriphCLKFreq+0x1622>
 8006842:	f1b3 4f80 	cmp.w	r3, #1073741824	@ 0x40000000
 8006846:	f000 82f5 	beq.w	8006e34 <HAL_RCCEx_GetPeriphCLKFreq+0x1c0c>
            else if (HAL_IS_BIT_SET(RCC->CR, RCC_CR_HSERDY) && (ckpclocksource == RCC_CLKPSOURCE_HSE))
 800684a:	4a06      	ldr	r2, [pc, #24]	@ (8006864 <HAL_RCCEx_GetPeriphCLKFreq+0x163c>)
 800684c:	6812      	ldr	r2, [r2, #0]
 800684e:	f412 3f00 	tst.w	r2, #131072	@ 0x20000
 8006852:	f000 82f2 	beq.w	8006e3a <HAL_RCCEx_GetPeriphCLKFreq+0x1c12>
 8006856:	f1b3 4f00 	cmp.w	r3, #2147483648	@ 0x80000000
 800685a:	f000 82f1 	beq.w	8006e40 <HAL_RCCEx_GetPeriphCLKFreq+0x1c18>
              frequency = 0;
 800685e:	2000      	movs	r0, #0
 8006860:	f7fe bd10 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
 8006864:	44020c00 	.word	0x44020c00
 8006868:	03d09000 	.word	0x03d09000
 800686c:	00bb8000 	.word	0x00bb8000
        srcclk = __HAL_RCC_GET_SPI2_SOURCE();
 8006870:	4ba8      	ldr	r3, [pc, #672]	@ (8006b14 <HAL_RCCEx_GetPeriphCLKFreq+0x18ec>)
 8006872:	f8d3 30e0 	ldr.w	r3, [r3, #224]	@ 0xe0
 8006876:	f003 0338 	and.w	r3, r3, #56	@ 0x38
        switch (srcclk)
 800687a:	2b20      	cmp	r3, #32
 800687c:	f200 82e3 	bhi.w	8006e46 <HAL_RCCEx_GetPeriphCLKFreq+0x1c1e>
 8006880:	e8df f013 	tbh	[pc, r3, lsl #1]
 8006884:	02e10024 	.word	0x02e10024
 8006888:	02e102e1 	.word	0x02e102e1
 800688c:	02e102e1 	.word	0x02e102e1
 8006890:	02e102e1 	.word	0x02e102e1
 8006894:	02e1002a 	.word	0x02e1002a
 8006898:	02e102e1 	.word	0x02e102e1
 800689c:	02e102e1 	.word	0x02e102e1
 80068a0:	02e102e1 	.word	0x02e102e1
 80068a4:	02e10030 	.word	0x02e10030
 80068a8:	02e102e1 	.word	0x02e102e1
 80068ac:	02e102e1 	.word	0x02e102e1
 80068b0:	02e102e1 	.word	0x02e102e1
 80068b4:	02e10021 	.word	0x02e10021
 80068b8:	02e102e1 	.word	0x02e102e1
 80068bc:	02e102e1 	.word	0x02e102e1
 80068c0:	02e102e1 	.word	0x02e102e1
 80068c4:	0036      	.short	0x0036
 80068c6:	4894      	ldr	r0, [pc, #592]	@ (8006b18 <HAL_RCCEx_GetPeriphCLKFreq+0x18f0>)
 80068c8:	f7fe bcdc 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
            HAL_RCCEx_GetPLL1ClockFreq(&pll1_clocks);
 80068cc:	a807      	add	r0, sp, #28
 80068ce:	f7fe f987 	bl	8004be0 <HAL_RCCEx_GetPLL1ClockFreq>
            frequency = pll1_clocks.PLL1_Q_Frequency;
 80068d2:	9808      	ldr	r0, [sp, #32]
            break;
 80068d4:	f7fe bcd6 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
            HAL_RCCEx_GetPLL2ClockFreq(&pll2_clocks);
 80068d8:	a804      	add	r0, sp, #16
 80068da:	f7fe fa8d 	bl	8004df8 <HAL_RCCEx_GetPLL2ClockFreq>
            frequency = pll2_clocks.PLL2_P_Frequency;
 80068de:	9804      	ldr	r0, [sp, #16]
            break;
 80068e0:	f7fe bcd0 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
            HAL_RCCEx_GetPLL3ClockFreq(&pll3_clocks);
 80068e4:	a801      	add	r0, sp, #4
 80068e6:	f7fe fb93 	bl	8005010 <HAL_RCCEx_GetPLL3ClockFreq>
            frequency = pll3_clocks.PLL3_P_Frequency;
 80068ea:	9801      	ldr	r0, [sp, #4]
            break;
 80068ec:	f7fe bcca 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
            ckpclocksource = __HAL_RCC_GET_CLKP_SOURCE();
 80068f0:	4a88      	ldr	r2, [pc, #544]	@ (8006b14 <HAL_RCCEx_GetPeriphCLKFreq+0x18ec>)
 80068f2:	f8d2 30e8 	ldr.w	r3, [r2, #232]	@ 0xe8
 80068f6:	f003 4340 	and.w	r3, r3, #3221225472	@ 0xc0000000
            if (HAL_IS_BIT_SET(RCC->CR, RCC_CR_HSIRDY) && (ckpclocksource == RCC_CLKPSOURCE_HSI))
 80068fa:	6812      	ldr	r2, [r2, #0]
 80068fc:	f012 0f02 	tst.w	r2, #2
 8006900:	d008      	beq.n	8006914 <HAL_RCCEx_GetPeriphCLKFreq+0x16ec>
 8006902:	b93b      	cbnz	r3, 8006914 <HAL_RCCEx_GetPeriphCLKFreq+0x16ec>
              frequency = (HSI_VALUE >> (__HAL_RCC_GET_HSI_DIVIDER() >> RCC_CR_HSIDIV_Pos));
 8006904:	4b83      	ldr	r3, [pc, #524]	@ (8006b14 <HAL_RCCEx_GetPeriphCLKFreq+0x18ec>)
 8006906:	681b      	ldr	r3, [r3, #0]
 8006908:	f3c3 03c1 	ubfx	r3, r3, #3, #2
 800690c:	4883      	ldr	r0, [pc, #524]	@ (8006b1c <HAL_RCCEx_GetPeriphCLKFreq+0x18f4>)
 800690e:	40d8      	lsrs	r0, r3
 8006910:	f7fe bcb8 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
            else if (HAL_IS_BIT_SET(RCC->CR, RCC_CR_CSIRDY) && (ckpclocksource == RCC_CLKPSOURCE_CSI))
 8006914:	4a7f      	ldr	r2, [pc, #508]	@ (8006b14 <HAL_RCCEx_GetPeriphCLKFreq+0x18ec>)
 8006916:	6812      	ldr	r2, [r2, #0]
 8006918:	f412 7f00 	tst.w	r2, #512	@ 0x200
 800691c:	d003      	beq.n	8006926 <HAL_RCCEx_GetPeriphCLKFreq+0x16fe>
 800691e:	f1b3 4f80 	cmp.w	r3, #1073741824	@ 0x40000000
 8006922:	f000 829d 	beq.w	8006e60 <HAL_RCCEx_GetPeriphCLKFreq+0x1c38>
            else if (HAL_IS_BIT_SET(RCC->CR, RCC_CR_HSERDY) && (ckpclocksource == RCC_CLKPSOURCE_HSE))
 8006926:	4a7b      	ldr	r2, [pc, #492]	@ (8006b14 <HAL_RCCEx_GetPeriphCLKFreq+0x18ec>)
 8006928:	6812      	ldr	r2, [r2, #0]
 800692a:	f412 3f00 	tst.w	r2, #131072	@ 0x20000
 800692e:	f000 829a 	beq.w	8006e66 <HAL_RCCEx_GetPeriphCLKFreq+0x1c3e>
 8006932:	f1b3 4f00 	cmp.w	r3, #2147483648	@ 0x80000000
 8006936:	f000 8299 	beq.w	8006e6c <HAL_RCCEx_GetPeriphCLKFreq+0x1c44>
              frequency = 0;
 800693a:	2000      	movs	r0, #0
 800693c:	f7fe bca2 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
        srcclk = __HAL_RCC_GET_SPI3_SOURCE();
 8006940:	4b74      	ldr	r3, [pc, #464]	@ (8006b14 <HAL_RCCEx_GetPeriphCLKFreq+0x18ec>)
 8006942:	f8d3 30e0 	ldr.w	r3, [r3, #224]	@ 0xe0
 8006946:	f403 73e0 	and.w	r3, r3, #448	@ 0x1c0
        switch (srcclk)
 800694a:	2b80      	cmp	r3, #128	@ 0x80
 800694c:	d02d      	beq.n	80069aa <HAL_RCCEx_GetPeriphCLKFreq+0x1782>
 800694e:	d917      	bls.n	8006980 <HAL_RCCEx_GetPeriphCLKFreq+0x1758>
 8006950:	2bc0      	cmp	r3, #192	@ 0xc0
 8006952:	f000 828e 	beq.w	8006e72 <HAL_RCCEx_GetPeriphCLKFreq+0x1c4a>
 8006956:	f5b3 7f80 	cmp.w	r3, #256	@ 0x100
 800695a:	d11d      	bne.n	8006998 <HAL_RCCEx_GetPeriphCLKFreq+0x1770>
            ckpclocksource = __HAL_RCC_GET_CLKP_SOURCE();
 800695c:	4a6d      	ldr	r2, [pc, #436]	@ (8006b14 <HAL_RCCEx_GetPeriphCLKFreq+0x18ec>)
 800695e:	f8d2 30e8 	ldr.w	r3, [r2, #232]	@ 0xe8
 8006962:	f003 4340 	and.w	r3, r3, #3221225472	@ 0xc0000000
            if (HAL_IS_BIT_SET(RCC->CR, RCC_CR_HSIRDY) && (ckpclocksource == RCC_CLKPSOURCE_HSI))
 8006966:	6812      	ldr	r2, [r2, #0]
 8006968:	f012 0f02 	tst.w	r2, #2
 800696c:	d023      	beq.n	80069b6 <HAL_RCCEx_GetPeriphCLKFreq+0x178e>
 800696e:	bb13      	cbnz	r3, 80069b6 <HAL_RCCEx_GetPeriphCLKFreq+0x178e>
              frequency = (HSI_VALUE >> (__HAL_RCC_GET_HSI_DIVIDER() >> RCC_CR_HSIDIV_Pos));
 8006970:	4b68      	ldr	r3, [pc, #416]	@ (8006b14 <HAL_RCCEx_GetPeriphCLKFreq+0x18ec>)
 8006972:	681b      	ldr	r3, [r3, #0]
 8006974:	f3c3 03c1 	ubfx	r3, r3, #3, #2
 8006978:	4868      	ldr	r0, [pc, #416]	@ (8006b1c <HAL_RCCEx_GetPeriphCLKFreq+0x18f4>)
 800697a:	40d8      	lsrs	r0, r3
 800697c:	f7fe bc82 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
        switch (srcclk)
 8006980:	b16b      	cbz	r3, 800699e <HAL_RCCEx_GetPeriphCLKFreq+0x1776>
 8006982:	2b40      	cmp	r3, #64	@ 0x40
 8006984:	d105      	bne.n	8006992 <HAL_RCCEx_GetPeriphCLKFreq+0x176a>
            HAL_RCCEx_GetPLL2ClockFreq(&pll2_clocks);
 8006986:	a804      	add	r0, sp, #16
 8006988:	f7fe fa36 	bl	8004df8 <HAL_RCCEx_GetPLL2ClockFreq>
            frequency = pll2_clocks.PLL2_P_Frequency;
 800698c:	9804      	ldr	r0, [sp, #16]
            break;
 800698e:	f7fe bc79 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
            frequency = 0;
 8006992:	2000      	movs	r0, #0
 8006994:	f7fe bc76 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
 8006998:	2000      	movs	r0, #0
 800699a:	f7fe bc73 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
            HAL_RCCEx_GetPLL1ClockFreq(&pll1_clocks);
 800699e:	a807      	add	r0, sp, #28
 80069a0:	f7fe f91e 	bl	8004be0 <HAL_RCCEx_GetPLL1ClockFreq>
            frequency = pll1_clocks.PLL1_Q_Frequency;
 80069a4:	9808      	ldr	r0, [sp, #32]
            break;
 80069a6:	f7fe bc6d 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
            HAL_RCCEx_GetPLL3ClockFreq(&pll3_clocks);
 80069aa:	a801      	add	r0, sp, #4
 80069ac:	f7fe fb30 	bl	8005010 <HAL_RCCEx_GetPLL3ClockFreq>
            frequency = pll3_clocks.PLL3_P_Frequency;
 80069b0:	9801      	ldr	r0, [sp, #4]
            break;
 80069b2:	f7fe bc67 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
            else if (HAL_IS_BIT_SET(RCC->CR, RCC_CR_CSIRDY) && (ckpclocksource == RCC_CLKPSOURCE_CSI))
 80069b6:	4a57      	ldr	r2, [pc, #348]	@ (8006b14 <HAL_RCCEx_GetPeriphCLKFreq+0x18ec>)
 80069b8:	6812      	ldr	r2, [r2, #0]
 80069ba:	f412 7f00 	tst.w	r2, #512	@ 0x200
 80069be:	d003      	beq.n	80069c8 <HAL_RCCEx_GetPeriphCLKFreq+0x17a0>
 80069c0:	f1b3 4f80 	cmp.w	r3, #1073741824	@ 0x40000000
 80069c4:	f000 8258 	beq.w	8006e78 <HAL_RCCEx_GetPeriphCLKFreq+0x1c50>
            else if (HAL_IS_BIT_SET(RCC->CR, RCC_CR_HSERDY) && (ckpclocksource == RCC_CLKPSOURCE_HSE))
 80069c8:	4a52      	ldr	r2, [pc, #328]	@ (8006b14 <HAL_RCCEx_GetPeriphCLKFreq+0x18ec>)
 80069ca:	6812      	ldr	r2, [r2, #0]
 80069cc:	f412 3f00 	tst.w	r2, #131072	@ 0x20000
 80069d0:	f000 8255 	beq.w	8006e7e <HAL_RCCEx_GetPeriphCLKFreq+0x1c56>
 80069d4:	f1b3 4f00 	cmp.w	r3, #2147483648	@ 0x80000000
 80069d8:	f000 8254 	beq.w	8006e84 <HAL_RCCEx_GetPeriphCLKFreq+0x1c5c>
              frequency = 0;
 80069dc:	2000      	movs	r0, #0
 80069de:	f7fe bc51 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = HAL_RCC_GetPCLK2Freq();
 80069e2:	f7fc ff79 	bl	80038d8 <HAL_RCC_GetPCLK2Freq>
 80069e6:	f7fe bc4d 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          HAL_RCCEx_GetPLL2ClockFreq(&pll2_clocks);
 80069ea:	a804      	add	r0, sp, #16
 80069ec:	f7fe fa04 	bl	8004df8 <HAL_RCCEx_GetPLL2ClockFreq>
          frequency = pll2_clocks.PLL2_Q_Frequency;
 80069f0:	9805      	ldr	r0, [sp, #20]
 80069f2:	f7fe bc47 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          HAL_RCCEx_GetPLL3ClockFreq(&pll3_clocks);
 80069f6:	a801      	add	r0, sp, #4
 80069f8:	f7fe fb0a 	bl	8005010 <HAL_RCCEx_GetPLL3ClockFreq>
          frequency = pll3_clocks.PLL3_Q_Frequency;
 80069fc:	9802      	ldr	r0, [sp, #8]
 80069fe:	f7fe bc41 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = (HSI_VALUE >> (__HAL_RCC_GET_HSI_DIVIDER() >> RCC_CR_HSIDIV_Pos));
 8006a02:	4b44      	ldr	r3, [pc, #272]	@ (8006b14 <HAL_RCCEx_GetPeriphCLKFreq+0x18ec>)
 8006a04:	681b      	ldr	r3, [r3, #0]
 8006a06:	f3c3 03c1 	ubfx	r3, r3, #3, #2
 8006a0a:	4844      	ldr	r0, [pc, #272]	@ (8006b1c <HAL_RCCEx_GetPeriphCLKFreq+0x18f4>)
 8006a0c:	40d8      	lsrs	r0, r3
 8006a0e:	f7fe bc39 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
        srcclk = __HAL_RCC_GET_SPI5_SOURCE();
 8006a12:	4b40      	ldr	r3, [pc, #256]	@ (8006b14 <HAL_RCCEx_GetPeriphCLKFreq+0x18ec>)
 8006a14:	f8d3 30e0 	ldr.w	r3, [r3, #224]	@ 0xe0
        if (srcclk == RCC_SPI5CLKSOURCE_PCLK3)
 8006a18:	f413 43e0 	ands.w	r3, r3, #28672	@ 0x7000
 8006a1c:	d02d      	beq.n	8006a7a <HAL_RCCEx_GetPeriphCLKFreq+0x1852>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_PLL2RDY)) && (srcclk == RCC_SPI5CLKSOURCE_PLL2Q))
 8006a1e:	4a3d      	ldr	r2, [pc, #244]	@ (8006b14 <HAL_RCCEx_GetPeriphCLKFreq+0x18ec>)
 8006a20:	6812      	ldr	r2, [r2, #0]
 8006a22:	f012 6f00 	tst.w	r2, #134217728	@ 0x8000000
 8006a26:	d002      	beq.n	8006a2e <HAL_RCCEx_GetPeriphCLKFreq+0x1806>
 8006a28:	f5b3 5f80 	cmp.w	r3, #4096	@ 0x1000
 8006a2c:	d029      	beq.n	8006a82 <HAL_RCCEx_GetPeriphCLKFreq+0x185a>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_PLL3RDY)) && (srcclk == RCC_SPI5CLKSOURCE_PLL3Q))
 8006a2e:	4a39      	ldr	r2, [pc, #228]	@ (8006b14 <HAL_RCCEx_GetPeriphCLKFreq+0x18ec>)
 8006a30:	6812      	ldr	r2, [r2, #0]
 8006a32:	f012 5f00 	tst.w	r2, #536870912	@ 0x20000000
 8006a36:	d002      	beq.n	8006a3e <HAL_RCCEx_GetPeriphCLKFreq+0x1816>
 8006a38:	f5b3 5f00 	cmp.w	r3, #8192	@ 0x2000
 8006a3c:	d027      	beq.n	8006a8e <HAL_RCCEx_GetPeriphCLKFreq+0x1866>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_HSIRDY)) && (srcclk == RCC_SPI5CLKSOURCE_HSI))
 8006a3e:	4a35      	ldr	r2, [pc, #212]	@ (8006b14 <HAL_RCCEx_GetPeriphCLKFreq+0x18ec>)
 8006a40:	6812      	ldr	r2, [r2, #0]
 8006a42:	f012 0f02 	tst.w	r2, #2
 8006a46:	d002      	beq.n	8006a4e <HAL_RCCEx_GetPeriphCLKFreq+0x1826>
 8006a48:	f5b3 5f40 	cmp.w	r3, #12288	@ 0x3000
 8006a4c:	d025      	beq.n	8006a9a <HAL_RCCEx_GetPeriphCLKFreq+0x1872>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_CSIRDY)) && (srcclk == RCC_SPI5CLKSOURCE_CSI))
 8006a4e:	4a31      	ldr	r2, [pc, #196]	@ (8006b14 <HAL_RCCEx_GetPeriphCLKFreq+0x18ec>)
 8006a50:	6812      	ldr	r2, [r2, #0]
 8006a52:	f412 7f00 	tst.w	r2, #512	@ 0x200
 8006a56:	d003      	beq.n	8006a60 <HAL_RCCEx_GetPeriphCLKFreq+0x1838>
 8006a58:	f5b3 4f80 	cmp.w	r3, #16384	@ 0x4000
 8006a5c:	f000 821e 	beq.w	8006e9c <HAL_RCCEx_GetPeriphCLKFreq+0x1c74>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_HSERDY)) && (srcclk == RCC_SPI5CLKSOURCE_HSE))
 8006a60:	4a2c      	ldr	r2, [pc, #176]	@ (8006b14 <HAL_RCCEx_GetPeriphCLKFreq+0x18ec>)
 8006a62:	6812      	ldr	r2, [r2, #0]
 8006a64:	f412 3f00 	tst.w	r2, #131072	@ 0x20000
 8006a68:	f000 821b 	beq.w	8006ea2 <HAL_RCCEx_GetPeriphCLKFreq+0x1c7a>
 8006a6c:	f5b3 4fa0 	cmp.w	r3, #20480	@ 0x5000
 8006a70:	f000 821a 	beq.w	8006ea8 <HAL_RCCEx_GetPeriphCLKFreq+0x1c80>
          frequency = 0U;
 8006a74:	2000      	movs	r0, #0
 8006a76:	f7fe bc05 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = HAL_RCC_GetPCLK3Freq();
 8006a7a:	f7fc ff3f 	bl	80038fc <HAL_RCC_GetPCLK3Freq>
 8006a7e:	f7fe bc01 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          HAL_RCCEx_GetPLL2ClockFreq(&pll2_clocks);
 8006a82:	a804      	add	r0, sp, #16
 8006a84:	f7fe f9b8 	bl	8004df8 <HAL_RCCEx_GetPLL2ClockFreq>
          frequency = pll2_clocks.PLL2_Q_Frequency;
 8006a88:	9805      	ldr	r0, [sp, #20]
 8006a8a:	f7fe bbfb 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          HAL_RCCEx_GetPLL3ClockFreq(&pll3_clocks);
 8006a8e:	a801      	add	r0, sp, #4
 8006a90:	f7fe fabe 	bl	8005010 <HAL_RCCEx_GetPLL3ClockFreq>
          frequency = pll3_clocks.PLL3_Q_Frequency;
 8006a94:	9802      	ldr	r0, [sp, #8]
 8006a96:	f7fe bbf5 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = (HSI_VALUE >> (__HAL_RCC_GET_HSI_DIVIDER() >> RCC_CR_HSIDIV_Pos));
 8006a9a:	4b1e      	ldr	r3, [pc, #120]	@ (8006b14 <HAL_RCCEx_GetPeriphCLKFreq+0x18ec>)
 8006a9c:	681b      	ldr	r3, [r3, #0]
 8006a9e:	f3c3 03c1 	ubfx	r3, r3, #3, #2
 8006aa2:	481e      	ldr	r0, [pc, #120]	@ (8006b1c <HAL_RCCEx_GetPeriphCLKFreq+0x18f4>)
 8006aa4:	40d8      	lsrs	r0, r3
 8006aa6:	f7fe bbed 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = HAL_RCC_GetPCLK2Freq();
 8006aaa:	f7fc ff15 	bl	80038d8 <HAL_RCC_GetPCLK2Freq>
 8006aae:	f7fe bbe9 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          HAL_RCCEx_GetPLL2ClockFreq(&pll2_clocks);
 8006ab2:	a804      	add	r0, sp, #16
 8006ab4:	f7fe f9a0 	bl	8004df8 <HAL_RCCEx_GetPLL2ClockFreq>
          frequency = pll2_clocks.PLL2_Q_Frequency;
 8006ab8:	9805      	ldr	r0, [sp, #20]
 8006aba:	f7fe bbe3 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          HAL_RCCEx_GetPLL3ClockFreq(&pll3_clocks);
 8006abe:	a801      	add	r0, sp, #4
 8006ac0:	f7fe faa6 	bl	8005010 <HAL_RCCEx_GetPLL3ClockFreq>
          frequency = pll3_clocks.PLL3_Q_Frequency;
 8006ac4:	9802      	ldr	r0, [sp, #8]
 8006ac6:	f7fe bbdd 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = (HSI_VALUE >> (__HAL_RCC_GET_HSI_DIVIDER() >> RCC_CR_HSIDIV_Pos));
 8006aca:	4b12      	ldr	r3, [pc, #72]	@ (8006b14 <HAL_RCCEx_GetPeriphCLKFreq+0x18ec>)
 8006acc:	681b      	ldr	r3, [r3, #0]
 8006ace:	f3c3 03c1 	ubfx	r3, r3, #3, #2
 8006ad2:	4812      	ldr	r0, [pc, #72]	@ (8006b1c <HAL_RCCEx_GetPeriphCLKFreq+0x18f4>)
 8006ad4:	40d8      	lsrs	r0, r3
 8006ad6:	f7fe bbd5 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
        srcclk = __HAL_RCC_GET_OSPI_SOURCE();
 8006ada:	4b0e      	ldr	r3, [pc, #56]	@ (8006b14 <HAL_RCCEx_GetPeriphCLKFreq+0x18ec>)
 8006adc:	f8d3 30e4 	ldr.w	r3, [r3, #228]	@ 0xe4
 8006ae0:	f003 0303 	and.w	r3, r3, #3
        switch (srcclk)
 8006ae4:	2b03      	cmp	r3, #3
 8006ae6:	f200 81eb 	bhi.w	8006ec0 <HAL_RCCEx_GetPeriphCLKFreq+0x1c98>
 8006aea:	e8df f003 	tbb	[pc, r3]
 8006aee:	0602      	.short	0x0602
 8006af0:	190c      	.short	0x190c
            frequency = HAL_RCC_GetHCLKFreq();
 8006af2:	f7fc fb83 	bl	80031fc <HAL_RCC_GetHCLKFreq>
            break;
 8006af6:	f7fe bbc5 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
            HAL_RCCEx_GetPLL1ClockFreq(&pll1_clocks);
 8006afa:	a807      	add	r0, sp, #28
 8006afc:	f7fe f870 	bl	8004be0 <HAL_RCCEx_GetPLL1ClockFreq>
            frequency = pll1_clocks.PLL1_Q_Frequency;
 8006b00:	9808      	ldr	r0, [sp, #32]
            break;
 8006b02:	f7fe bbbf 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
            HAL_RCCEx_GetPLL2ClockFreq(&pll2_clocks);
 8006b06:	a804      	add	r0, sp, #16
 8006b08:	f7fe f976 	bl	8004df8 <HAL_RCCEx_GetPLL2ClockFreq>
            frequency = pll2_clocks.PLL2_R_Frequency;
 8006b0c:	9806      	ldr	r0, [sp, #24]
            break;
 8006b0e:	f7fe bbb9 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
 8006b12:	bf00      	nop
 8006b14:	44020c00 	.word	0x44020c00
 8006b18:	00bb8000 	.word	0x00bb8000
 8006b1c:	03d09000 	.word	0x03d09000
            ckpclocksource = __HAL_RCC_GET_CLKP_SOURCE();
 8006b20:	4aca      	ldr	r2, [pc, #808]	@ (8006e4c <HAL_RCCEx_GetPeriphCLKFreq+0x1c24>)
 8006b22:	f8d2 30e8 	ldr.w	r3, [r2, #232]	@ 0xe8
 8006b26:	f003 4340 	and.w	r3, r3, #3221225472	@ 0xc0000000
            if (HAL_IS_BIT_SET(RCC->CR, RCC_CR_HSIRDY) && (ckpclocksource == RCC_CLKPSOURCE_HSI))
 8006b2a:	6812      	ldr	r2, [r2, #0]
 8006b2c:	f012 0f02 	tst.w	r2, #2
 8006b30:	d008      	beq.n	8006b44 <HAL_RCCEx_GetPeriphCLKFreq+0x191c>
 8006b32:	b93b      	cbnz	r3, 8006b44 <HAL_RCCEx_GetPeriphCLKFreq+0x191c>
              frequency = (HSI_VALUE >> (__HAL_RCC_GET_HSI_DIVIDER() >> RCC_CR_HSIDIV_Pos));
 8006b34:	4bc5      	ldr	r3, [pc, #788]	@ (8006e4c <HAL_RCCEx_GetPeriphCLKFreq+0x1c24>)
 8006b36:	681b      	ldr	r3, [r3, #0]
 8006b38:	f3c3 03c1 	ubfx	r3, r3, #3, #2
 8006b3c:	48c4      	ldr	r0, [pc, #784]	@ (8006e50 <HAL_RCCEx_GetPeriphCLKFreq+0x1c28>)
 8006b3e:	40d8      	lsrs	r0, r3
 8006b40:	f7fe bba0 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
            else if (HAL_IS_BIT_SET(RCC->CR, RCC_CR_CSIRDY) && (ckpclocksource == RCC_CLKPSOURCE_CSI))
 8006b44:	4ac1      	ldr	r2, [pc, #772]	@ (8006e4c <HAL_RCCEx_GetPeriphCLKFreq+0x1c24>)
 8006b46:	6812      	ldr	r2, [r2, #0]
 8006b48:	f412 7f00 	tst.w	r2, #512	@ 0x200
 8006b4c:	d003      	beq.n	8006b56 <HAL_RCCEx_GetPeriphCLKFreq+0x192e>
 8006b4e:	f1b3 4f80 	cmp.w	r3, #1073741824	@ 0x40000000
 8006b52:	f000 81b8 	beq.w	8006ec6 <HAL_RCCEx_GetPeriphCLKFreq+0x1c9e>
            else if (HAL_IS_BIT_SET(RCC->CR, RCC_CR_HSERDY) && (ckpclocksource == RCC_CLKPSOURCE_HSE))
 8006b56:	4abd      	ldr	r2, [pc, #756]	@ (8006e4c <HAL_RCCEx_GetPeriphCLKFreq+0x1c24>)
 8006b58:	6812      	ldr	r2, [r2, #0]
 8006b5a:	f412 3f00 	tst.w	r2, #131072	@ 0x20000
 8006b5e:	f000 81b5 	beq.w	8006ecc <HAL_RCCEx_GetPeriphCLKFreq+0x1ca4>
 8006b62:	f1b3 4f00 	cmp.w	r3, #2147483648	@ 0x80000000
 8006b66:	f000 81b4 	beq.w	8006ed2 <HAL_RCCEx_GetPeriphCLKFreq+0x1caa>
              frequency = 0U;
 8006b6a:	2000      	movs	r0, #0
 8006b6c:	f7fe bb8a 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
        srcclk = __HAL_RCC_GET_RNG_SOURCE();
 8006b70:	4ab6      	ldr	r2, [pc, #728]	@ (8006e4c <HAL_RCCEx_GetPeriphCLKFreq+0x1c24>)
 8006b72:	f8d2 30e8 	ldr.w	r3, [r2, #232]	@ 0xe8
 8006b76:	f003 0330 	and.w	r3, r3, #48	@ 0x30
        if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_HSI48RDY)) && (srcclk == RCC_RNGCLKSOURCE_HSI48))
 8006b7a:	6812      	ldr	r2, [r2, #0]
 8006b7c:	f412 5f00 	tst.w	r2, #8192	@ 0x2000
 8006b80:	d002      	beq.n	8006b88 <HAL_RCCEx_GetPeriphCLKFreq+0x1960>
 8006b82:	2b00      	cmp	r3, #0
 8006b84:	f000 81b7 	beq.w	8006ef6 <HAL_RCCEx_GetPeriphCLKFreq+0x1cce>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_PLL1RDY)) && (srcclk == RCC_RNGCLKSOURCE_PLL1Q))
 8006b88:	4ab0      	ldr	r2, [pc, #704]	@ (8006e4c <HAL_RCCEx_GetPeriphCLKFreq+0x1c24>)
 8006b8a:	6812      	ldr	r2, [r2, #0]
 8006b8c:	f012 7f00 	tst.w	r2, #33554432	@ 0x2000000
 8006b90:	d001      	beq.n	8006b96 <HAL_RCCEx_GetPeriphCLKFreq+0x196e>
 8006b92:	2b10      	cmp	r3, #16
 8006b94:	d015      	beq.n	8006bc2 <HAL_RCCEx_GetPeriphCLKFreq+0x199a>
        else if ((HAL_IS_BIT_SET(RCC->BDCR, RCC_BDCR_LSERDY)) && (srcclk == RCC_RNGCLKSOURCE_LSE))
 8006b96:	4aad      	ldr	r2, [pc, #692]	@ (8006e4c <HAL_RCCEx_GetPeriphCLKFreq+0x1c24>)
 8006b98:	f8d2 20f0 	ldr.w	r2, [r2, #240]	@ 0xf0
 8006b9c:	f012 0f02 	tst.w	r2, #2
 8006ba0:	d002      	beq.n	8006ba8 <HAL_RCCEx_GetPeriphCLKFreq+0x1980>
 8006ba2:	2b20      	cmp	r3, #32
 8006ba4:	f000 81aa 	beq.w	8006efc <HAL_RCCEx_GetPeriphCLKFreq+0x1cd4>
        else if ((HAL_IS_BIT_SET(RCC->BDCR, RCC_BDCR_LSIRDY)) && (srcclk == RCC_RNGCLKSOURCE_LSI))
 8006ba8:	4aa8      	ldr	r2, [pc, #672]	@ (8006e4c <HAL_RCCEx_GetPeriphCLKFreq+0x1c24>)
 8006baa:	f8d2 20f0 	ldr.w	r2, [r2, #240]	@ 0xf0
 8006bae:	f012 6f00 	tst.w	r2, #134217728	@ 0x8000000
 8006bb2:	f000 81a7 	beq.w	8006f04 <HAL_RCCEx_GetPeriphCLKFreq+0x1cdc>
 8006bb6:	2b30      	cmp	r3, #48	@ 0x30
 8006bb8:	f000 81a7 	beq.w	8006f0a <HAL_RCCEx_GetPeriphCLKFreq+0x1ce2>
          frequency = 0U;
 8006bbc:	2000      	movs	r0, #0
 8006bbe:	f7fe bb61 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          HAL_RCCEx_GetPLL1ClockFreq(&pll1_clocks);
 8006bc2:	a807      	add	r0, sp, #28
 8006bc4:	f7fe f80c 	bl	8004be0 <HAL_RCCEx_GetPLL1ClockFreq>
          frequency = pll1_clocks.PLL1_Q_Frequency;
 8006bc8:	9808      	ldr	r0, [sp, #32]
 8006bca:	f7fe bb5b 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
        srcclk = __HAL_RCC_GET_USB_SOURCE();
 8006bce:	4b9f      	ldr	r3, [pc, #636]	@ (8006e4c <HAL_RCCEx_GetPeriphCLKFreq+0x1c24>)
 8006bd0:	f8d3 30e4 	ldr.w	r3, [r3, #228]	@ 0xe4
 8006bd4:	f003 0330 	and.w	r3, r3, #48	@ 0x30
        if (srcclk == RCC_USBCLKSOURCE_PLL1Q)
 8006bd8:	2b10      	cmp	r3, #16
 8006bda:	d012      	beq.n	8006c02 <HAL_RCCEx_GetPeriphCLKFreq+0x19da>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_PLL3RDY)) && (srcclk == RCC_USBCLKSOURCE_PLL3Q))
 8006bdc:	4a9b      	ldr	r2, [pc, #620]	@ (8006e4c <HAL_RCCEx_GetPeriphCLKFreq+0x1c24>)
 8006bde:	6812      	ldr	r2, [r2, #0]
 8006be0:	f012 5f00 	tst.w	r2, #536870912	@ 0x20000000
 8006be4:	d001      	beq.n	8006bea <HAL_RCCEx_GetPeriphCLKFreq+0x19c2>
 8006be6:	2b20      	cmp	r3, #32
 8006be8:	d011      	beq.n	8006c0e <HAL_RCCEx_GetPeriphCLKFreq+0x19e6>
        else if ((HAL_IS_BIT_SET(RCC->CR, RCC_CR_HSI48RDY)) && (srcclk == RCC_USBCLKSOURCE_HSI48))
 8006bea:	4a98      	ldr	r2, [pc, #608]	@ (8006e4c <HAL_RCCEx_GetPeriphCLKFreq+0x1c24>)
 8006bec:	6812      	ldr	r2, [r2, #0]
 8006bee:	f412 5f00 	tst.w	r2, #8192	@ 0x2000
 8006bf2:	f000 818e 	beq.w	8006f12 <HAL_RCCEx_GetPeriphCLKFreq+0x1cea>
 8006bf6:	2b30      	cmp	r3, #48	@ 0x30
 8006bf8:	f000 818e 	beq.w	8006f18 <HAL_RCCEx_GetPeriphCLKFreq+0x1cf0>
          frequency = 0U;
 8006bfc:	2000      	movs	r0, #0
 8006bfe:	f7fe bb41 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          HAL_RCCEx_GetPLL1ClockFreq(&pll1_clocks);
 8006c02:	a807      	add	r0, sp, #28
 8006c04:	f7fd ffec 	bl	8004be0 <HAL_RCCEx_GetPLL1ClockFreq>
          frequency = pll1_clocks.PLL1_Q_Frequency;
 8006c08:	9808      	ldr	r0, [sp, #32]
          break;
 8006c0a:	f7fe bb3b 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          HAL_RCCEx_GetPLL3ClockFreq(&pll3_clocks);
 8006c0e:	a801      	add	r0, sp, #4
 8006c10:	f7fe f9fe 	bl	8005010 <HAL_RCCEx_GetPLL3ClockFreq>
          frequency = pll3_clocks.PLL3_Q_Frequency;
 8006c14:	9802      	ldr	r0, [sp, #8]
 8006c16:	f7fe bb35 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
      frequency = LSE_VALUE;
 8006c1a:	f44f 4000 	mov.w	r0, #32768	@ 0x8000
 8006c1e:	4770      	bx	lr
      frequency = LSI_VALUE;
 8006c20:	f44f 40fa 	mov.w	r0, #32000	@ 0x7d00
 8006c24:	4770      	bx	lr
        frequency = 0U;
 8006c26:	2000      	movs	r0, #0
 8006c28:	4770      	bx	lr
    switch (PeriphClk)
 8006c2a:	2000      	movs	r0, #0
 8006c2c:	f7fe bb2a 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
        switch (srcclk)
 8006c30:	4888      	ldr	r0, [pc, #544]	@ (8006e54 <HAL_RCCEx_GetPeriphCLKFreq+0x1c2c>)
 8006c32:	f7fe bb27 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
              frequency = CSI_VALUE;
 8006c36:	4888      	ldr	r0, [pc, #544]	@ (8006e58 <HAL_RCCEx_GetPeriphCLKFreq+0x1c30>)
 8006c38:	f7fe bb24 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
              frequency = 0U;
 8006c3c:	2000      	movs	r0, #0
 8006c3e:	f7fe bb21 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
              frequency = HSE_VALUE;
 8006c42:	4886      	ldr	r0, [pc, #536]	@ (8006e5c <HAL_RCCEx_GetPeriphCLKFreq+0x1c34>)
 8006c44:	f7fe bb1e 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
        switch (srcclk)
 8006c48:	4882      	ldr	r0, [pc, #520]	@ (8006e54 <HAL_RCCEx_GetPeriphCLKFreq+0x1c2c>)
 8006c4a:	f7fe bb1b 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
              frequency = CSI_VALUE;
 8006c4e:	4882      	ldr	r0, [pc, #520]	@ (8006e58 <HAL_RCCEx_GetPeriphCLKFreq+0x1c30>)
 8006c50:	f7fe bb18 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
              frequency = 0U;
 8006c54:	2000      	movs	r0, #0
 8006c56:	f7fe bb15 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
              frequency = HSE_VALUE;
 8006c5a:	4880      	ldr	r0, [pc, #512]	@ (8006e5c <HAL_RCCEx_GetPeriphCLKFreq+0x1c34>)
 8006c5c:	f7fe bb12 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = CSI_VALUE;
 8006c60:	487d      	ldr	r0, [pc, #500]	@ (8006e58 <HAL_RCCEx_GetPeriphCLKFreq+0x1c30>)
 8006c62:	f7fe bb0f 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = 0U;
 8006c66:	2000      	movs	r0, #0
 8006c68:	f7fe bb0c 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = LSE_VALUE;
 8006c6c:	f44f 4000 	mov.w	r0, #32768	@ 0x8000
 8006c70:	f7fe bb08 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = CSI_VALUE;
 8006c74:	4878      	ldr	r0, [pc, #480]	@ (8006e58 <HAL_RCCEx_GetPeriphCLKFreq+0x1c30>)
 8006c76:	f7fe bb05 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = 0U;
 8006c7a:	2000      	movs	r0, #0
 8006c7c:	f7fe bb02 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = LSE_VALUE;
 8006c80:	f44f 4000 	mov.w	r0, #32768	@ 0x8000
 8006c84:	f7fe bafe 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = CSI_VALUE;
 8006c88:	4873      	ldr	r0, [pc, #460]	@ (8006e58 <HAL_RCCEx_GetPeriphCLKFreq+0x1c30>)
 8006c8a:	f7fe bafb 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = 0U;
 8006c8e:	2000      	movs	r0, #0
 8006c90:	f7fe baf8 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = LSE_VALUE;
 8006c94:	f44f 4000 	mov.w	r0, #32768	@ 0x8000
 8006c98:	f7fe baf4 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = CSI_VALUE;
 8006c9c:	486e      	ldr	r0, [pc, #440]	@ (8006e58 <HAL_RCCEx_GetPeriphCLKFreq+0x1c30>)
 8006c9e:	f7fe baf1 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = 0U;
 8006ca2:	2000      	movs	r0, #0
 8006ca4:	f7fe baee 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = LSE_VALUE;
 8006ca8:	f44f 4000 	mov.w	r0, #32768	@ 0x8000
 8006cac:	f7fe baea 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = CSI_VALUE;
 8006cb0:	4869      	ldr	r0, [pc, #420]	@ (8006e58 <HAL_RCCEx_GetPeriphCLKFreq+0x1c30>)
 8006cb2:	f7fe bae7 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = 0U;
 8006cb6:	2000      	movs	r0, #0
 8006cb8:	f7fe bae4 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = LSE_VALUE;
 8006cbc:	f44f 4000 	mov.w	r0, #32768	@ 0x8000
 8006cc0:	f7fe bae0 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = CSI_VALUE;
 8006cc4:	4864      	ldr	r0, [pc, #400]	@ (8006e58 <HAL_RCCEx_GetPeriphCLKFreq+0x1c30>)
 8006cc6:	f7fe badd 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = 0U;
 8006cca:	2000      	movs	r0, #0
 8006ccc:	f7fe bada 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = LSE_VALUE;
 8006cd0:	f44f 4000 	mov.w	r0, #32768	@ 0x8000
 8006cd4:	f7fe bad6 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = CSI_VALUE;
 8006cd8:	485f      	ldr	r0, [pc, #380]	@ (8006e58 <HAL_RCCEx_GetPeriphCLKFreq+0x1c30>)
 8006cda:	f7fe bad3 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = 0U;
 8006cde:	2000      	movs	r0, #0
 8006ce0:	f7fe bad0 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = LSE_VALUE;
 8006ce4:	f44f 4000 	mov.w	r0, #32768	@ 0x8000
 8006ce8:	f7fe bacc 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = CSI_VALUE;
 8006cec:	485a      	ldr	r0, [pc, #360]	@ (8006e58 <HAL_RCCEx_GetPeriphCLKFreq+0x1c30>)
 8006cee:	f7fe bac9 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = 0U;
 8006cf2:	2000      	movs	r0, #0
 8006cf4:	f7fe bac6 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = LSE_VALUE;
 8006cf8:	f44f 4000 	mov.w	r0, #32768	@ 0x8000
 8006cfc:	f7fe bac2 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = CSI_VALUE;
 8006d00:	4855      	ldr	r0, [pc, #340]	@ (8006e58 <HAL_RCCEx_GetPeriphCLKFreq+0x1c30>)
 8006d02:	f7fe babf 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = 0U;
 8006d06:	2000      	movs	r0, #0
 8006d08:	f7fe babc 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = LSE_VALUE;
 8006d0c:	f44f 4000 	mov.w	r0, #32768	@ 0x8000
 8006d10:	f7fe bab8 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = CSI_VALUE;
 8006d14:	4850      	ldr	r0, [pc, #320]	@ (8006e58 <HAL_RCCEx_GetPeriphCLKFreq+0x1c30>)
 8006d16:	f7fe bab5 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = 0U;
 8006d1a:	2000      	movs	r0, #0
 8006d1c:	f7fe bab2 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = LSE_VALUE;
 8006d20:	f44f 4000 	mov.w	r0, #32768	@ 0x8000
 8006d24:	f7fe baae 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = CSI_VALUE;
 8006d28:	484b      	ldr	r0, [pc, #300]	@ (8006e58 <HAL_RCCEx_GetPeriphCLKFreq+0x1c30>)
 8006d2a:	f7fe baab 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = 0U;
 8006d2e:	2000      	movs	r0, #0
 8006d30:	f7fe baa8 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = LSE_VALUE;
 8006d34:	f44f 4000 	mov.w	r0, #32768	@ 0x8000
 8006d38:	f7fe baa4 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = CSI_VALUE;
 8006d3c:	4846      	ldr	r0, [pc, #280]	@ (8006e58 <HAL_RCCEx_GetPeriphCLKFreq+0x1c30>)
 8006d3e:	f7fe baa1 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = 0U;
 8006d42:	2000      	movs	r0, #0
 8006d44:	f7fe ba9e 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = LSE_VALUE;
 8006d48:	f44f 4000 	mov.w	r0, #32768	@ 0x8000
 8006d4c:	f7fe ba9a 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = CSI_VALUE;
 8006d50:	4841      	ldr	r0, [pc, #260]	@ (8006e58 <HAL_RCCEx_GetPeriphCLKFreq+0x1c30>)
 8006d52:	f7fe ba97 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = 0U;
 8006d56:	2000      	movs	r0, #0
 8006d58:	f7fe ba94 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = LSE_VALUE;
 8006d5c:	f44f 4000 	mov.w	r0, #32768	@ 0x8000
 8006d60:	f7fe ba90 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = HSE_VALUE;
 8006d64:	483d      	ldr	r0, [pc, #244]	@ (8006e5c <HAL_RCCEx_GetPeriphCLKFreq+0x1c34>)
 8006d66:	f7fe ba8d 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = 0U;
 8006d6a:	2000      	movs	r0, #0
 8006d6c:	f7fe ba8a 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = CSI_VALUE;
 8006d70:	4839      	ldr	r0, [pc, #228]	@ (8006e58 <HAL_RCCEx_GetPeriphCLKFreq+0x1c30>)
 8006d72:	f7fe ba87 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = LSE_VALUE;
 8006d76:	f44f 4000 	mov.w	r0, #32768	@ 0x8000
 8006d7a:	f7fe ba83 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = 0U;
 8006d7e:	2000      	movs	r0, #0
 8006d80:	f7fe ba80 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = LSI_VALUE;
 8006d84:	f44f 40fa 	mov.w	r0, #32000	@ 0x7d00
 8006d88:	f7fe ba7c 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = 0U;
 8006d8c:	2000      	movs	r0, #0
 8006d8e:	f7fe ba79 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = CSI_VALUE;
 8006d92:	4831      	ldr	r0, [pc, #196]	@ (8006e58 <HAL_RCCEx_GetPeriphCLKFreq+0x1c30>)
 8006d94:	f7fe ba76 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = 0U;
 8006d98:	2000      	movs	r0, #0
 8006d9a:	f7fe ba73 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = CSI_VALUE;
 8006d9e:	482e      	ldr	r0, [pc, #184]	@ (8006e58 <HAL_RCCEx_GetPeriphCLKFreq+0x1c30>)
 8006da0:	f7fe ba70 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = 0U;
 8006da4:	2000      	movs	r0, #0
 8006da6:	f7fe ba6d 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = CSI_VALUE;
 8006daa:	482b      	ldr	r0, [pc, #172]	@ (8006e58 <HAL_RCCEx_GetPeriphCLKFreq+0x1c30>)
 8006dac:	f7fe ba6a 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = 0U;
 8006db0:	2000      	movs	r0, #0
 8006db2:	f7fe ba67 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = CSI_VALUE;
 8006db6:	4828      	ldr	r0, [pc, #160]	@ (8006e58 <HAL_RCCEx_GetPeriphCLKFreq+0x1c30>)
 8006db8:	f7fe ba64 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
              frequency = CSI_VALUE;
 8006dbc:	4826      	ldr	r0, [pc, #152]	@ (8006e58 <HAL_RCCEx_GetPeriphCLKFreq+0x1c30>)
 8006dbe:	f7fe ba61 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
              frequency = 0;
 8006dc2:	2000      	movs	r0, #0
 8006dc4:	f7fe ba5e 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
              frequency = HSE_VALUE;
 8006dc8:	4824      	ldr	r0, [pc, #144]	@ (8006e5c <HAL_RCCEx_GetPeriphCLKFreq+0x1c34>)
 8006dca:	f7fe ba5b 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
              frequency = CSI_VALUE;
 8006dce:	4822      	ldr	r0, [pc, #136]	@ (8006e58 <HAL_RCCEx_GetPeriphCLKFreq+0x1c30>)
 8006dd0:	f7fe ba58 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
              frequency = 0;
 8006dd4:	2000      	movs	r0, #0
 8006dd6:	f7fe ba55 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
              frequency = HSE_VALUE;
 8006dda:	4820      	ldr	r0, [pc, #128]	@ (8006e5c <HAL_RCCEx_GetPeriphCLKFreq+0x1c34>)
 8006ddc:	f7fe ba52 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
              frequency = CSI_VALUE;
 8006de0:	481d      	ldr	r0, [pc, #116]	@ (8006e58 <HAL_RCCEx_GetPeriphCLKFreq+0x1c30>)
 8006de2:	f7fe ba4f 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
              frequency = 0;
 8006de6:	2000      	movs	r0, #0
 8006de8:	f7fe ba4c 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
              frequency = HSE_VALUE;
 8006dec:	481b      	ldr	r0, [pc, #108]	@ (8006e5c <HAL_RCCEx_GetPeriphCLKFreq+0x1c34>)
 8006dee:	f7fe ba49 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
              frequency = CSI_VALUE;
 8006df2:	4819      	ldr	r0, [pc, #100]	@ (8006e58 <HAL_RCCEx_GetPeriphCLKFreq+0x1c30>)
 8006df4:	f7fe ba46 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
              frequency = 0;
 8006df8:	2000      	movs	r0, #0
 8006dfa:	f7fe ba43 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
              frequency = HSE_VALUE;
 8006dfe:	4817      	ldr	r0, [pc, #92]	@ (8006e5c <HAL_RCCEx_GetPeriphCLKFreq+0x1c34>)
 8006e00:	f7fe ba40 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
              frequency = CSI_VALUE;
 8006e04:	4814      	ldr	r0, [pc, #80]	@ (8006e58 <HAL_RCCEx_GetPeriphCLKFreq+0x1c30>)
 8006e06:	f7fe ba3d 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
              frequency = 0;
 8006e0a:	2000      	movs	r0, #0
 8006e0c:	f7fe ba3a 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
              frequency = HSE_VALUE;
 8006e10:	4812      	ldr	r0, [pc, #72]	@ (8006e5c <HAL_RCCEx_GetPeriphCLKFreq+0x1c34>)
 8006e12:	f7fe ba37 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
              frequency = CSI_VALUE;
 8006e16:	4810      	ldr	r0, [pc, #64]	@ (8006e58 <HAL_RCCEx_GetPeriphCLKFreq+0x1c30>)
 8006e18:	f7fe ba34 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
              frequency = 0;
 8006e1c:	2000      	movs	r0, #0
 8006e1e:	f7fe ba31 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
              frequency = HSE_VALUE;
 8006e22:	480e      	ldr	r0, [pc, #56]	@ (8006e5c <HAL_RCCEx_GetPeriphCLKFreq+0x1c34>)
 8006e24:	f7fe ba2e 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = HSE_VALUE;
 8006e28:	480c      	ldr	r0, [pc, #48]	@ (8006e5c <HAL_RCCEx_GetPeriphCLKFreq+0x1c34>)
 8006e2a:	f7fe ba2b 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
            frequency = 0;
 8006e2e:	2000      	movs	r0, #0
 8006e30:	f7fe ba28 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
              frequency = CSI_VALUE;
 8006e34:	4808      	ldr	r0, [pc, #32]	@ (8006e58 <HAL_RCCEx_GetPeriphCLKFreq+0x1c30>)
 8006e36:	f7fe ba25 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
              frequency = 0;
 8006e3a:	2000      	movs	r0, #0
 8006e3c:	f7fe ba22 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
              frequency = HSE_VALUE;
 8006e40:	4806      	ldr	r0, [pc, #24]	@ (8006e5c <HAL_RCCEx_GetPeriphCLKFreq+0x1c34>)
 8006e42:	f7fe ba1f 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
            frequency = 0;
 8006e46:	2000      	movs	r0, #0
 8006e48:	f7fe ba1c 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
 8006e4c:	44020c00 	.word	0x44020c00
 8006e50:	03d09000 	.word	0x03d09000
 8006e54:	00bb8000 	.word	0x00bb8000
 8006e58:	003d0900 	.word	0x003d0900
 8006e5c:	017d7840 	.word	0x017d7840
              frequency = CSI_VALUE;
 8006e60:	482f      	ldr	r0, [pc, #188]	@ (8006f20 <HAL_RCCEx_GetPeriphCLKFreq+0x1cf8>)
 8006e62:	f7fe ba0f 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
              frequency = 0;
 8006e66:	2000      	movs	r0, #0
 8006e68:	f7fe ba0c 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
              frequency = HSE_VALUE;
 8006e6c:	482d      	ldr	r0, [pc, #180]	@ (8006f24 <HAL_RCCEx_GetPeriphCLKFreq+0x1cfc>)
 8006e6e:	f7fe ba09 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
        switch (srcclk)
 8006e72:	482d      	ldr	r0, [pc, #180]	@ (8006f28 <HAL_RCCEx_GetPeriphCLKFreq+0x1d00>)
 8006e74:	f7fe ba06 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
              frequency = CSI_VALUE;
 8006e78:	4829      	ldr	r0, [pc, #164]	@ (8006f20 <HAL_RCCEx_GetPeriphCLKFreq+0x1cf8>)
 8006e7a:	f7fe ba03 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
              frequency = 0;
 8006e7e:	2000      	movs	r0, #0
 8006e80:	f7fe ba00 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
              frequency = HSE_VALUE;
 8006e84:	4827      	ldr	r0, [pc, #156]	@ (8006f24 <HAL_RCCEx_GetPeriphCLKFreq+0x1cfc>)
 8006e86:	f7fe b9fd 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = CSI_VALUE;
 8006e8a:	4825      	ldr	r0, [pc, #148]	@ (8006f20 <HAL_RCCEx_GetPeriphCLKFreq+0x1cf8>)
 8006e8c:	f7fe b9fa 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = 0U;
 8006e90:	2000      	movs	r0, #0
 8006e92:	f7fe b9f7 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = HSE_VALUE;
 8006e96:	4823      	ldr	r0, [pc, #140]	@ (8006f24 <HAL_RCCEx_GetPeriphCLKFreq+0x1cfc>)
 8006e98:	f7fe b9f4 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = CSI_VALUE;
 8006e9c:	4820      	ldr	r0, [pc, #128]	@ (8006f20 <HAL_RCCEx_GetPeriphCLKFreq+0x1cf8>)
 8006e9e:	f7fe b9f1 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = 0U;
 8006ea2:	2000      	movs	r0, #0
 8006ea4:	f7fe b9ee 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = HSE_VALUE;
 8006ea8:	481e      	ldr	r0, [pc, #120]	@ (8006f24 <HAL_RCCEx_GetPeriphCLKFreq+0x1cfc>)
 8006eaa:	f7fe b9eb 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = CSI_VALUE;
 8006eae:	481c      	ldr	r0, [pc, #112]	@ (8006f20 <HAL_RCCEx_GetPeriphCLKFreq+0x1cf8>)
 8006eb0:	f7fe b9e8 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = 0U;
 8006eb4:	2000      	movs	r0, #0
 8006eb6:	f7fe b9e5 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = HSE_VALUE;
 8006eba:	481a      	ldr	r0, [pc, #104]	@ (8006f24 <HAL_RCCEx_GetPeriphCLKFreq+0x1cfc>)
 8006ebc:	f7fe b9e2 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
        switch (srcclk)
 8006ec0:	2000      	movs	r0, #0
 8006ec2:	f7fe b9df 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
              frequency = CSI_VALUE;
 8006ec6:	4816      	ldr	r0, [pc, #88]	@ (8006f20 <HAL_RCCEx_GetPeriphCLKFreq+0x1cf8>)
 8006ec8:	f7fe b9dc 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
              frequency = 0U;
 8006ecc:	2000      	movs	r0, #0
 8006ece:	f7fe b9d9 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
              frequency = HSE_VALUE;
 8006ed2:	4814      	ldr	r0, [pc, #80]	@ (8006f24 <HAL_RCCEx_GetPeriphCLKFreq+0x1cfc>)
 8006ed4:	f7fe b9d6 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = LSE_VALUE;
 8006ed8:	f44f 4000 	mov.w	r0, #32768	@ 0x8000
 8006edc:	f7fe b9d2 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = LSI_VALUE;
 8006ee0:	f44f 40fa 	mov.w	r0, #32000	@ 0x7d00
 8006ee4:	f7fe b9ce 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = 0U;
 8006ee8:	2000      	movs	r0, #0
 8006eea:	f7fe b9cb 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = CSI_VALUE / 122U;
 8006eee:	f248 0012 	movw	r0, #32786	@ 0x8012
 8006ef2:	f7fe b9c7 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = HSI48_VALUE;
 8006ef6:	480d      	ldr	r0, [pc, #52]	@ (8006f2c <HAL_RCCEx_GetPeriphCLKFreq+0x1d04>)
 8006ef8:	f7fe b9c4 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = LSE_VALUE;
 8006efc:	f44f 4000 	mov.w	r0, #32768	@ 0x8000
 8006f00:	f7fe b9c0 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = 0U;
 8006f04:	2000      	movs	r0, #0
 8006f06:	f7fe b9bd 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = LSI_VALUE;
 8006f0a:	f44f 40fa 	mov.w	r0, #32000	@ 0x7d00
 8006f0e:	f7fe b9b9 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = 0U;
 8006f12:	2000      	movs	r0, #0
 8006f14:	f7fe b9b6 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
          frequency = HSI48_VALUE;
 8006f18:	4804      	ldr	r0, [pc, #16]	@ (8006f2c <HAL_RCCEx_GetPeriphCLKFreq+0x1d04>)
  return (frequency);
 8006f1a:	f7fe b9b3 	b.w	8005284 <HAL_RCCEx_GetPeriphCLKFreq+0x5c>
}
 8006f1e:	4770      	bx	lr
 8006f20:	003d0900 	.word	0x003d0900
 8006f24:	017d7840 	.word	0x017d7840
 8006f28:	00bb8000 	.word	0x00bb8000
 8006f2c:	02dc6c00 	.word	0x02dc6c00

08006f30 <HAL_GPIO_Init>:
  * @param  pGPIO_Init: pointer to a GPIO_InitTypeDef structure that contains
  *         the configuration information for the specified GPIO peripheral.
  * @retval None
  */
void HAL_GPIO_Init(GPIO_TypeDef  *GPIOx, const GPIO_InitTypeDef *pGPIO_Init)
{
 8006f30:	b5f0      	push	{r4, r5, r6, r7, lr}
  uint32_t tmp;
  uint32_t iocurrent;
  uint32_t position = 0U;
 8006f32:	2200      	movs	r2, #0
  assert_param(IS_GPIO_PIN(pGPIO_Init->Pin));
  assert_param(IS_GPIO_MODE(pGPIO_Init->Mode));
  assert_param(IS_GPIO_PULL(pGPIO_Init->Pull));

  /* Configure the port pins */
  while (((pGPIO_Init->Pin) >> position) != 0U)
 8006f34:	e067      	b.n	8007006 <HAL_GPIO_Init+0xd6>
      {
        /* Check the Speed parameter */
        assert_param(IS_GPIO_SPEED(pGPIO_Init->Speed));

        /* Configure the IO Speed */
        tmp = GPIOx->OSPEEDR;
 8006f36:	6886      	ldr	r6, [r0, #8]
        tmp &= ~(GPIO_OSPEEDR_OSPEED0 << (position * GPIO_OSPEEDR_OSPEED1_Pos));
 8006f38:	402e      	ands	r6, r5
        tmp |= (pGPIO_Init->Speed << (position * GPIO_OSPEEDR_OSPEED1_Pos));
 8006f3a:	68cc      	ldr	r4, [r1, #12]
 8006f3c:	fa04 f40e 	lsl.w	r4, r4, lr
 8006f40:	4334      	orrs	r4, r6
        GPIOx->OSPEEDR = tmp;
 8006f42:	6084      	str	r4, [r0, #8]

        /* Configure the IO Output Type */
        tmp = GPIOx->OTYPER;
 8006f44:	6846      	ldr	r6, [r0, #4]
        tmp &= ~(GPIO_OTYPER_OT0 << position) ;
 8006f46:	ea26 060c 	bic.w	r6, r6, ip
        tmp |= (((pGPIO_Init->Mode & GPIO_OUTPUT_TYPE) >> 4U) << position);
 8006f4a:	684c      	ldr	r4, [r1, #4]
 8006f4c:	f3c4 1400 	ubfx	r4, r4, #4, #1
 8006f50:	4094      	lsls	r4, r2
 8006f52:	4334      	orrs	r4, r6
        GPIOx->OTYPER = tmp;
 8006f54:	6044      	str	r4, [r0, #4]
      }

      if (((pGPIO_Init->Mode & GPIO_MODE) != GPIO_MODE_ANALOG) ||
 8006f56:	684c      	ldr	r4, [r1, #4]
 8006f58:	f004 0403 	and.w	r4, r4, #3
 8006f5c:	2c03      	cmp	r4, #3
 8006f5e:	f000 8093 	beq.w	8007088 <HAL_GPIO_Init+0x158>
      {
        /* Check the Pull parameters */
        assert_param(IS_GPIO_PULL(pGPIO_Init->Pull));

        /* Activate the Pull-up or Pull down resistor for the current IO */
        tmp = GPIOx->PUPDR;
 8006f62:	68c4      	ldr	r4, [r0, #12]
        tmp &= ~(GPIO_PUPDR_PUPD0 << (position * GPIO_PUPDR_PUPD1_Pos));
 8006f64:	4025      	ands	r5, r4
        tmp |= ((pGPIO_Init->Pull) << (position * GPIO_PUPDR_PUPD1_Pos));
 8006f66:	688c      	ldr	r4, [r1, #8]
 8006f68:	fa04 f40e 	lsl.w	r4, r4, lr
 8006f6c:	432c      	orrs	r4, r5
        GPIOx->PUPDR = tmp;
 8006f6e:	60c4      	str	r4, [r0, #12]
      }

      /*--------------------- EXTI Mode Configuration ------------------------*/
      /* Configure the External Interrupt or event for the current IO */
      if ((pGPIO_Init->Mode & EXTI_MODE) == EXTI_MODE)
 8006f70:	684c      	ldr	r4, [r1, #4]
 8006f72:	f014 5f80 	tst.w	r4, #268435456	@ 0x10000000
 8006f76:	d045      	beq.n	8007004 <HAL_GPIO_Init+0xd4>
      {
        tmp = EXTI->EXTICR[position >> 2U];
 8006f78:	0895      	lsrs	r5, r2, #2
 8006f7a:	4f46      	ldr	r7, [pc, #280]	@ (8007094 <HAL_GPIO_Init+0x164>)
 8006f7c:	3518      	adds	r5, #24
 8006f7e:	f857 4025 	ldr.w	r4, [r7, r5, lsl #2]
        tmp &= ~((0x0FUL) << ((position & 0x03U) * EXTI_EXTICR1_EXTI1_Pos));
 8006f82:	f002 0603 	and.w	r6, r2, #3
 8006f86:	00f6      	lsls	r6, r6, #3
 8006f88:	f04f 0c0f 	mov.w	ip, #15
 8006f8c:	fa0c fc06 	lsl.w	ip, ip, r6
 8006f90:	ea24 0c0c 	bic.w	ip, r4, ip
        tmp |= (GPIO_GET_INDEX(GPIOx) << ((position & 0x03U) * EXTI_EXTICR1_EXTI1_Pos));
 8006f94:	4c40      	ldr	r4, [pc, #256]	@ (8007098 <HAL_GPIO_Init+0x168>)
 8006f96:	ea04 2490 	and.w	r4, r4, r0, lsr #10
 8006f9a:	40b4      	lsls	r4, r6
 8006f9c:	ea44 040c 	orr.w	r4, r4, ip
        EXTI->EXTICR[position >> 2U] = tmp;
 8006fa0:	f847 4025 	str.w	r4, [r7, r5, lsl #2]

        /* Clear Rising Falling edge configuration */
        tmp = EXTI->RTSR1;
 8006fa4:	683d      	ldr	r5, [r7, #0]
        tmp &= ~((uint32_t)iocurrent);
 8006fa6:	43dc      	mvns	r4, r3
 8006fa8:	ea25 0603 	bic.w	r6, r5, r3
        if ((pGPIO_Init->Mode & RISING_EDGE) == RISING_EDGE)
 8006fac:	684f      	ldr	r7, [r1, #4]
 8006fae:	f417 1f80 	tst.w	r7, #1048576	@ 0x100000
 8006fb2:	d001      	beq.n	8006fb8 <HAL_GPIO_Init+0x88>
        {
          tmp |= iocurrent;
 8006fb4:	ea43 0605 	orr.w	r6, r3, r5
        }
        EXTI->RTSR1 = tmp;
 8006fb8:	4d36      	ldr	r5, [pc, #216]	@ (8007094 <HAL_GPIO_Init+0x164>)
 8006fba:	602e      	str	r6, [r5, #0]

        tmp = EXTI->FTSR1;
 8006fbc:	686d      	ldr	r5, [r5, #4]
        tmp &= ~((uint32_t)iocurrent);
 8006fbe:	ea04 0605 	and.w	r6, r4, r5
        if ((pGPIO_Init->Mode & FALLING_EDGE) == FALLING_EDGE)
 8006fc2:	684f      	ldr	r7, [r1, #4]
 8006fc4:	f417 1f00 	tst.w	r7, #2097152	@ 0x200000
 8006fc8:	d001      	beq.n	8006fce <HAL_GPIO_Init+0x9e>
        {
          tmp |= iocurrent;
 8006fca:	ea43 0605 	orr.w	r6, r3, r5
        }
        EXTI->FTSR1 = tmp;
 8006fce:	4d31      	ldr	r5, [pc, #196]	@ (8007094 <HAL_GPIO_Init+0x164>)
 8006fd0:	606e      	str	r6, [r5, #4]

        /* Clear EXTI line configuration */
        tmp = EXTI->EMR1;
 8006fd2:	f8d5 5084 	ldr.w	r5, [r5, #132]	@ 0x84
        tmp &= ~((uint32_t)iocurrent);
 8006fd6:	ea04 0605 	and.w	r6, r4, r5
        if ((pGPIO_Init->Mode & GPIO_MODE_EVT) == GPIO_MODE_EVT)
 8006fda:	684f      	ldr	r7, [r1, #4]
 8006fdc:	f417 3f00 	tst.w	r7, #131072	@ 0x20000
 8006fe0:	d001      	beq.n	8006fe6 <HAL_GPIO_Init+0xb6>
        {
          tmp |= iocurrent;
 8006fe2:	ea43 0605 	orr.w	r6, r3, r5
        }
        EXTI->EMR1 = tmp;
 8006fe6:	4d2b      	ldr	r5, [pc, #172]	@ (8007094 <HAL_GPIO_Init+0x164>)
 8006fe8:	f8c5 6084 	str.w	r6, [r5, #132]	@ 0x84

        tmp = EXTI->IMR1;
 8006fec:	f8d5 5080 	ldr.w	r5, [r5, #128]	@ 0x80
        tmp &= ~((uint32_t)iocurrent);
 8006ff0:	402c      	ands	r4, r5
        if ((pGPIO_Init->Mode & GPIO_MODE_IT) == GPIO_MODE_IT)
 8006ff2:	684e      	ldr	r6, [r1, #4]
 8006ff4:	f416 3f80 	tst.w	r6, #65536	@ 0x10000
 8006ff8:	d001      	beq.n	8006ffe <HAL_GPIO_Init+0xce>
        {
          tmp |= iocurrent;
 8006ffa:	ea43 0405 	orr.w	r4, r3, r5
        }
        EXTI->IMR1 = tmp;
 8006ffe:	4b25      	ldr	r3, [pc, #148]	@ (8007094 <HAL_GPIO_Init+0x164>)
 8007000:	f8c3 4080 	str.w	r4, [r3, #128]	@ 0x80
      }
    }

    position++;
 8007004:	3201      	adds	r2, #1
  while (((pGPIO_Init->Pin) >> position) != 0U)
 8007006:	680b      	ldr	r3, [r1, #0]
 8007008:	fa33 f402 	lsrs.w	r4, r3, r2
 800700c:	d041      	beq.n	8007092 <HAL_GPIO_Init+0x162>
    iocurrent = (pGPIO_Init->Pin) & (1UL << position);
 800700e:	f04f 0c01 	mov.w	ip, #1
 8007012:	fa0c fc02 	lsl.w	ip, ip, r2
    if (iocurrent != 0U)
 8007016:	ea1c 0303 	ands.w	r3, ip, r3
 800701a:	d0f3      	beq.n	8007004 <HAL_GPIO_Init+0xd4>
      if ((pGPIO_Init->Mode == GPIO_MODE_AF_PP) || (pGPIO_Init->Mode == GPIO_MODE_AF_OD))
 800701c:	684c      	ldr	r4, [r1, #4]
 800701e:	2c02      	cmp	r4, #2
 8007020:	d001      	beq.n	8007026 <HAL_GPIO_Init+0xf6>
 8007022:	2c12      	cmp	r4, #18
 8007024:	d114      	bne.n	8007050 <HAL_GPIO_Init+0x120>
        tmp = GPIOx->AFR[position >> 3U];
 8007026:	08d5      	lsrs	r5, r2, #3
 8007028:	3508      	adds	r5, #8
 800702a:	f850 4025 	ldr.w	r4, [r0, r5, lsl #2]
        tmp &= ~(0x0FUL << ((position & 0x07U) * GPIO_AFRL_AFSEL1_Pos));
 800702e:	f002 0607 	and.w	r6, r2, #7
 8007032:	00b6      	lsls	r6, r6, #2
 8007034:	f04f 0e0f 	mov.w	lr, #15
 8007038:	fa0e fe06 	lsl.w	lr, lr, r6
 800703c:	ea24 0e0e 	bic.w	lr, r4, lr
        tmp |= ((pGPIO_Init->Alternate & 0x0FUL) << ((position & 0x07U) * GPIO_AFRL_AFSEL1_Pos));
 8007040:	690c      	ldr	r4, [r1, #16]
 8007042:	f004 040f 	and.w	r4, r4, #15
 8007046:	40b4      	lsls	r4, r6
 8007048:	ea44 040e 	orr.w	r4, r4, lr
        GPIOx->AFR[position >> 3U] = tmp;
 800704c:	f840 4025 	str.w	r4, [r0, r5, lsl #2]
      tmp = GPIOx->MODER;
 8007050:	6806      	ldr	r6, [r0, #0]
      tmp &= ~(GPIO_MODER_MODE0 << (position * GPIO_MODER_MODE1_Pos));
 8007052:	ea4f 0e42 	mov.w	lr, r2, lsl #1
 8007056:	2403      	movs	r4, #3
 8007058:	fa04 f40e 	lsl.w	r4, r4, lr
 800705c:	43e5      	mvns	r5, r4
 800705e:	ea26 0604 	bic.w	r6, r6, r4
      tmp |= ((pGPIO_Init->Mode & GPIO_MODE) << (position * GPIO_MODER_MODE1_Pos));
 8007062:	684c      	ldr	r4, [r1, #4]
 8007064:	f004 0403 	and.w	r4, r4, #3
 8007068:	fa04 f40e 	lsl.w	r4, r4, lr
 800706c:	4334      	orrs	r4, r6
      GPIOx->MODER = tmp;
 800706e:	6004      	str	r4, [r0, #0]
      if ((pGPIO_Init->Mode == GPIO_MODE_OUTPUT_PP) || (pGPIO_Init->Mode == GPIO_MODE_AF_PP) ||
 8007070:	684c      	ldr	r4, [r1, #4]
 8007072:	1e66      	subs	r6, r4, #1
 8007074:	2e01      	cmp	r6, #1
 8007076:	f67f af5e 	bls.w	8006f36 <HAL_GPIO_Init+0x6>
 800707a:	2c11      	cmp	r4, #17
 800707c:	f43f af5b 	beq.w	8006f36 <HAL_GPIO_Init+0x6>
          (pGPIO_Init->Mode == GPIO_MODE_OUTPUT_OD) || (pGPIO_Init->Mode == GPIO_MODE_AF_OD))
 8007080:	2c12      	cmp	r4, #18
 8007082:	f47f af68 	bne.w	8006f56 <HAL_GPIO_Init+0x26>
 8007086:	e756      	b.n	8006f36 <HAL_GPIO_Init+0x6>
          (((pGPIO_Init->Mode & GPIO_MODE) == GPIO_MODE_ANALOG) && (pGPIO_Init->Pull != GPIO_PULLUP)))
 8007088:	688c      	ldr	r4, [r1, #8]
      if (((pGPIO_Init->Mode & GPIO_MODE) != GPIO_MODE_ANALOG) ||
 800708a:	2c01      	cmp	r4, #1
 800708c:	f47f af69 	bne.w	8006f62 <HAL_GPIO_Init+0x32>
 8007090:	e76e      	b.n	8006f70 <HAL_GPIO_Init+0x40>
  }
}
 8007092:	bdf0      	pop	{r4, r5, r6, r7, pc}
 8007094:	44022000 	.word	0x44022000
 8007098:	002f7f7f 	.word	0x002f7f7f

0800709c <__NVIC_SetPriority>:
  \param [in]  priority  Priority to set.
  \note    The priority cannot be set for every processor exception.
 */
__STATIC_INLINE void __NVIC_SetPriority(IRQn_Type IRQn, uint32_t priority)
{
  if ((int32_t)(IRQn) >= 0)
 800709c:	2800      	cmp	r0, #0
 800709e:	db08      	blt.n	80070b2 <__NVIC_SetPriority+0x16>
  {
    NVIC->IPR[((uint32_t)IRQn)]               = (uint8_t)((priority << (8U - __NVIC_PRIO_BITS)) & (uint32_t)0xFFUL);
 80070a0:	0109      	lsls	r1, r1, #4
 80070a2:	b2c9      	uxtb	r1, r1
 80070a4:	f100 4060 	add.w	r0, r0, #3758096384	@ 0xe0000000
 80070a8:	f500 4061 	add.w	r0, r0, #57600	@ 0xe100
 80070ac:	f880 1300 	strb.w	r1, [r0, #768]	@ 0x300
 80070b0:	4770      	bx	lr
  }
  else
  {
    SCB->SHPR[(((uint32_t)IRQn) & 0xFUL)-4UL] = (uint8_t)((priority << (8U - __NVIC_PRIO_BITS)) & (uint32_t)0xFFUL);
 80070b2:	f000 000f 	and.w	r0, r0, #15
 80070b6:	0109      	lsls	r1, r1, #4
 80070b8:	b2c9      	uxtb	r1, r1
 80070ba:	4b01      	ldr	r3, [pc, #4]	@ (80070c0 <__NVIC_SetPriority+0x24>)
 80070bc:	5419      	strb	r1, [r3, r0]
  }
}
 80070be:	4770      	bx	lr
 80070c0:	e000ed14 	.word	0xe000ed14

080070c4 <NVIC_EncodePriority>:
  \param [in]   PreemptPriority  Preemptive priority value (starting from 0).
  \param [in]       SubPriority  Subpriority value (starting from 0).
  \return                        Encoded priority. Value can be used in the function \ref NVIC_SetPriority().
 */
__STATIC_INLINE uint32_t NVIC_EncodePriority (uint32_t PriorityGroup, uint32_t PreemptPriority, uint32_t SubPriority)
{
 80070c4:	b500      	push	{lr}
  uint32_t PriorityGroupTmp = (PriorityGroup & (uint32_t)0x07UL);   /* only values 0..7 are used          */
 80070c6:	f000 0007 	and.w	r0, r0, #7
  uint32_t PreemptPriorityBits;
  uint32_t SubPriorityBits;

  PreemptPriorityBits = ((7UL - PriorityGroupTmp) > (uint32_t)(__NVIC_PRIO_BITS)) ? (uint32_t)(__NVIC_PRIO_BITS) : (uint32_t)(7UL - PriorityGroupTmp);
 80070ca:	f1c0 0c07 	rsb	ip, r0, #7
 80070ce:	f1bc 0f04 	cmp.w	ip, #4
 80070d2:	bf28      	it	cs
 80070d4:	f04f 0c04 	movcs.w	ip, #4
  SubPriorityBits     = ((PriorityGroupTmp + (uint32_t)(__NVIC_PRIO_BITS)) < (uint32_t)7UL) ? (uint32_t)0UL : (uint32_t)((PriorityGroupTmp - 7UL) + (uint32_t)(__NVIC_PRIO_BITS));
 80070d8:	1d03      	adds	r3, r0, #4
 80070da:	2b06      	cmp	r3, #6
 80070dc:	d90f      	bls.n	80070fe <NVIC_EncodePriority+0x3a>
 80070de:	1ec3      	subs	r3, r0, #3

  return (
           ((PreemptPriority & (uint32_t)((1UL << (PreemptPriorityBits)) - 1UL)) << SubPriorityBits) |
 80070e0:	f04f 3eff 	mov.w	lr, #4294967295	@ 0xffffffff
 80070e4:	fa0e f00c 	lsl.w	r0, lr, ip
 80070e8:	ea21 0100 	bic.w	r1, r1, r0
 80070ec:	4099      	lsls	r1, r3
           ((SubPriority     & (uint32_t)((1UL << (SubPriorityBits    )) - 1UL)))
 80070ee:	fa0e fe03 	lsl.w	lr, lr, r3
 80070f2:	ea22 020e 	bic.w	r2, r2, lr
         );
}
 80070f6:	ea41 0002 	orr.w	r0, r1, r2
 80070fa:	f85d fb04 	ldr.w	pc, [sp], #4
  SubPriorityBits     = ((PriorityGroupTmp + (uint32_t)(__NVIC_PRIO_BITS)) < (uint32_t)7UL) ? (uint32_t)0UL : (uint32_t)((PriorityGroupTmp - 7UL) + (uint32_t)(__NVIC_PRIO_BITS));
 80070fe:	2300      	movs	r3, #0
 8007100:	e7ee      	b.n	80070e0 <NVIC_EncodePriority+0x1c>
	...

08007104 <HAL_NVIC_SetPriorityGrouping>:
  reg_value  =  SCB->AIRCR;                                                   /* read old register configuration    */
 8007104:	4a07      	ldr	r2, [pc, #28]	@ (8007124 <HAL_NVIC_SetPriorityGrouping+0x20>)
 8007106:	68d3      	ldr	r3, [r2, #12]
  reg_value &= ~((uint32_t)(SCB_AIRCR_VECTKEY_Msk | SCB_AIRCR_PRIGROUP_Msk)); /* clear bits to change               */
 8007108:	f423 63e0 	bic.w	r3, r3, #1792	@ 0x700
 800710c:	041b      	lsls	r3, r3, #16
 800710e:	0c1b      	lsrs	r3, r3, #16
                (PriorityGroupTmp << SCB_AIRCR_PRIGROUP_Pos)  );              /* Insert write key and priority group */
 8007110:	0200      	lsls	r0, r0, #8
 8007112:	f400 60e0 	and.w	r0, r0, #1792	@ 0x700
                ((uint32_t)0x5FAUL << SCB_AIRCR_VECTKEY_Pos) |
 8007116:	4303      	orrs	r3, r0
  reg_value  =  (reg_value                                   |
 8007118:	f043 63bf 	orr.w	r3, r3, #100139008	@ 0x5f80000
 800711c:	f443 3300 	orr.w	r3, r3, #131072	@ 0x20000
  SCB->AIRCR =  reg_value;
 8007120:	60d3      	str	r3, [r2, #12]
  /* Check the parameters */
  assert_param(IS_NVIC_PRIORITY_GROUP(PriorityGroup));

  /* Set the PRIGROUP[10:8] bits according to the PriorityGroup parameter value */
  NVIC_SetPriorityGrouping(PriorityGroup);
}
 8007122:	4770      	bx	lr
 8007124:	e000ed00 	.word	0xe000ed00

08007128 <HAL_NVIC_SetPriority>:
  *         This parameter can be a value between 0 and 15
  *         A lower priority value indicates a higher priority.
  * @retval None
  */
void HAL_NVIC_SetPriority(IRQn_Type IRQn, uint32_t PreemptPriority, uint32_t SubPriority)
{
 8007128:	b510      	push	{r4, lr}
 800712a:	4604      	mov	r4, r0
  return ((uint32_t)((SCB->AIRCR & SCB_AIRCR_PRIGROUP_Msk) >> SCB_AIRCR_PRIGROUP_Pos));
 800712c:	4b05      	ldr	r3, [pc, #20]	@ (8007144 <HAL_NVIC_SetPriority+0x1c>)
 800712e:	68d8      	ldr	r0, [r3, #12]
  assert_param(IS_NVIC_SUB_PRIORITY(SubPriority));
  assert_param(IS_NVIC_PREEMPTION_PRIORITY(PreemptPriority));

  prioritygroup = NVIC_GetPriorityGrouping();

  NVIC_SetPriority(IRQn, NVIC_EncodePriority(prioritygroup, PreemptPriority, SubPriority));
 8007130:	f3c0 2002 	ubfx	r0, r0, #8, #3
 8007134:	f7ff ffc6 	bl	80070c4 <NVIC_EncodePriority>
 8007138:	4601      	mov	r1, r0
 800713a:	4620      	mov	r0, r4
 800713c:	f7ff ffae 	bl	800709c <__NVIC_SetPriority>
}
 8007140:	bd10      	pop	{r4, pc}
 8007142:	bf00      	nop
 8007144:	e000ed00 	.word	0xe000ed00

08007148 <HAL_SYSTICK_Config>:
  * @retval status:  - 0  Function succeeded.
  *                  - 1  Function failed.
  */
uint32_t HAL_SYSTICK_Config(uint32_t TicksNumb)
{
  if ((TicksNumb - 1UL) > SysTick_LOAD_RELOAD_Msk)
 8007148:	3801      	subs	r0, #1
 800714a:	f1b0 7f80 	cmp.w	r0, #16777216	@ 0x1000000
 800714e:	d209      	bcs.n	8007164 <HAL_SYSTICK_Config+0x1c>
    /* Reload value impossible */
    return (1UL);
  }

  /* Set reload register */
  WRITE_REG(SysTick->LOAD, (uint32_t)(TicksNumb - 1UL));
 8007150:	f04f 23e0 	mov.w	r3, #3758153728	@ 0xe000e000
 8007154:	6158      	str	r0, [r3, #20]

  /* Load the SysTick Counter Value */
  WRITE_REG(SysTick->VAL, 0UL);
 8007156:	2000      	movs	r0, #0
 8007158:	6198      	str	r0, [r3, #24]

  /* Enable SysTick IRQ and SysTick Timer */
  SET_BIT(SysTick->CTRL, (SysTick_CTRL_TICKINT_Msk | SysTick_CTRL_ENABLE_Msk));
 800715a:	691a      	ldr	r2, [r3, #16]
 800715c:	f042 0203 	orr.w	r2, r2, #3
 8007160:	611a      	str	r2, [r3, #16]

  /* Function successful */
  return (0UL);
 8007162:	4770      	bx	lr
    return (1UL);
 8007164:	2001      	movs	r0, #1
}
 8007166:	4770      	bx	lr

08007168 <HAL_SYSTICK_CLKSourceConfig>:
  */
void HAL_SYSTICK_CLKSourceConfig(uint32_t CLKSource)
{
  /* Check the parameters */
  assert_param(IS_SYSTICK_CLK_SOURCE(CLKSource));
  switch (CLKSource)
 8007168:	2804      	cmp	r0, #4
 800716a:	d838      	bhi.n	80071de <HAL_SYSTICK_CLKSourceConfig+0x76>
 800716c:	e8df f000 	tbb	[pc, r0]
 8007170:	3728180a 	.word	0x3728180a
 8007174:	03          	.byte	0x03
 8007175:	00          	.byte	0x00
  {
    /* Select HCLK as Systick clock source */
    case SYSTICK_CLKSOURCE_HCLK:
      SET_BIT(SysTick->CTRL, SYSTICK_CLKSOURCE_HCLK);
 8007176:	f04f 22e0 	mov.w	r2, #3758153728	@ 0xe000e000
 800717a:	6913      	ldr	r3, [r2, #16]
 800717c:	f043 0304 	orr.w	r3, r3, #4
 8007180:	6113      	str	r3, [r2, #16]
      break;
 8007182:	4770      	bx	lr
    /* Select HCLK_DIV8 as Systick clock source */
    case SYSTICK_CLKSOURCE_HCLK_DIV8:
      CLEAR_BIT(SysTick->CTRL, SYSTICK_CLKSOURCE_HCLK);
 8007184:	f04f 22e0 	mov.w	r2, #3758153728	@ 0xe000e000
 8007188:	6913      	ldr	r3, [r2, #16]
 800718a:	f023 0304 	bic.w	r3, r3, #4
 800718e:	6113      	str	r3, [r2, #16]
      MODIFY_REG(RCC->CCIPR4, RCC_CCIPR4_SYSTICKSEL, (0x00000000U));
 8007190:	4a13      	ldr	r2, [pc, #76]	@ (80071e0 <HAL_SYSTICK_CLKSourceConfig+0x78>)
 8007192:	f8d2 30e4 	ldr.w	r3, [r2, #228]	@ 0xe4
 8007196:	f023 030c 	bic.w	r3, r3, #12
 800719a:	f8c2 30e4 	str.w	r3, [r2, #228]	@ 0xe4
      break;
 800719e:	4770      	bx	lr
    /* Select LSI as Systick clock source */
    case SYSTICK_CLKSOURCE_LSI:
      CLEAR_BIT(SysTick->CTRL, SYSTICK_CLKSOURCE_HCLK);
 80071a0:	f04f 22e0 	mov.w	r2, #3758153728	@ 0xe000e000
 80071a4:	6913      	ldr	r3, [r2, #16]
 80071a6:	f023 0304 	bic.w	r3, r3, #4
 80071aa:	6113      	str	r3, [r2, #16]
      MODIFY_REG(RCC->CCIPR4, RCC_CCIPR4_SYSTICKSEL, RCC_CCIPR4_SYSTICKSEL_0);
 80071ac:	4a0c      	ldr	r2, [pc, #48]	@ (80071e0 <HAL_SYSTICK_CLKSourceConfig+0x78>)
 80071ae:	f8d2 30e4 	ldr.w	r3, [r2, #228]	@ 0xe4
 80071b2:	f023 030c 	bic.w	r3, r3, #12
 80071b6:	f043 0304 	orr.w	r3, r3, #4
 80071ba:	f8c2 30e4 	str.w	r3, [r2, #228]	@ 0xe4
      break;
 80071be:	4770      	bx	lr
    /* Select LSE as Systick clock source */
    case SYSTICK_CLKSOURCE_LSE:
      CLEAR_BIT(SysTick->CTRL, SYSTICK_CLKSOURCE_HCLK);
 80071c0:	f04f 22e0 	mov.w	r2, #3758153728	@ 0xe000e000
 80071c4:	6913      	ldr	r3, [r2, #16]
 80071c6:	f023 0304 	bic.w	r3, r3, #4
 80071ca:	6113      	str	r3, [r2, #16]
      MODIFY_REG(RCC->CCIPR4, RCC_CCIPR4_SYSTICKSEL, RCC_CCIPR4_SYSTICKSEL_1);
 80071cc:	4a04      	ldr	r2, [pc, #16]	@ (80071e0 <HAL_SYSTICK_CLKSourceConfig+0x78>)
 80071ce:	f8d2 30e4 	ldr.w	r3, [r2, #228]	@ 0xe4
 80071d2:	f023 030c 	bic.w	r3, r3, #12
 80071d6:	f043 0308 	orr.w	r3, r3, #8
 80071da:	f8c2 30e4 	str.w	r3, [r2, #228]	@ 0xe4
      break;
    default:
      /* Nothing to do */
      break;
  }
}
 80071de:	4770      	bx	lr
 80071e0:	44020c00 	.word	0x44020c00

080071e4 <HAL_SYSTICK_GetCLKSourceConfig>:
{
  uint32_t systick_source;
  uint32_t systick_rcc_source;

  /* Read SysTick->CTRL register for internal or external clock source */
  if (READ_BIT(SysTick->CTRL, SysTick_CTRL_CLKSOURCE_Msk) != 0U)
 80071e4:	f04f 23e0 	mov.w	r3, #3758153728	@ 0xe000e000
 80071e8:	6918      	ldr	r0, [r3, #16]
 80071ea:	f010 0004 	ands.w	r0, r0, #4
 80071ee:	d10a      	bne.n	8007206 <HAL_SYSTICK_GetCLKSourceConfig+0x22>
    systick_source = SYSTICK_CLKSOURCE_HCLK;
  }
  else
  {
    /* External clock source, check the selected one in RCC */
    systick_rcc_source = READ_BIT(RCC->CCIPR4, RCC_CCIPR4_SYSTICKSEL);
 80071f0:	4b07      	ldr	r3, [pc, #28]	@ (8007210 <HAL_SYSTICK_GetCLKSourceConfig+0x2c>)
 80071f2:	f8d3 30e4 	ldr.w	r3, [r3, #228]	@ 0xe4
 80071f6:	f003 030c 	and.w	r3, r3, #12

    switch (systick_rcc_source)
 80071fa:	2b04      	cmp	r3, #4
 80071fc:	d005      	beq.n	800720a <HAL_SYSTICK_GetCLKSourceConfig+0x26>
 80071fe:	2b08      	cmp	r3, #8
 8007200:	d104      	bne.n	800720c <HAL_SYSTICK_GetCLKSourceConfig+0x28>
      case (RCC_CCIPR4_SYSTICKSEL_0):
        systick_source = SYSTICK_CLKSOURCE_LSI;
        break;

      case (RCC_CCIPR4_SYSTICKSEL_1):
        systick_source = SYSTICK_CLKSOURCE_LSE;
 8007202:	2002      	movs	r0, #2
 8007204:	4770      	bx	lr
    systick_source = SYSTICK_CLKSOURCE_HCLK;
 8007206:	2004      	movs	r0, #4
 8007208:	4770      	bx	lr
        systick_source = SYSTICK_CLKSOURCE_LSI;
 800720a:	2001      	movs	r0, #1
        systick_source = SYSTICK_CLKSOURCE_HCLK_DIV8;
        break;
    }
  }
  return systick_source;
}
 800720c:	4770      	bx	lr
 800720e:	bf00      	nop
 8007210:	44020c00 	.word	0x44020c00

08007214 <HAL_ICACHE_ConfigAssociativityMode>:

  /* Check the parameters */
  assert_param(IS_ICACHE_ASSOCIATIVITY_MODE(AssociativityMode));

  /* Check cache is not enabled */
  if (READ_BIT(ICACHE->CR, ICACHE_CR_EN) != 0U)
 8007214:	4b07      	ldr	r3, [pc, #28]	@ (8007234 <HAL_ICACHE_ConfigAssociativityMode+0x20>)
 8007216:	681b      	ldr	r3, [r3, #0]
 8007218:	f013 0f01 	tst.w	r3, #1
 800721c:	d107      	bne.n	800722e <HAL_ICACHE_ConfigAssociativityMode+0x1a>
  {
    status = HAL_ERROR;
  }
  else
  {
    MODIFY_REG(ICACHE->CR, ICACHE_CR_WAYSEL, AssociativityMode);
 800721e:	4a05      	ldr	r2, [pc, #20]	@ (8007234 <HAL_ICACHE_ConfigAssociativityMode+0x20>)
 8007220:	6813      	ldr	r3, [r2, #0]
 8007222:	f023 0304 	bic.w	r3, r3, #4
 8007226:	4303      	orrs	r3, r0
 8007228:	6013      	str	r3, [r2, #0]
  HAL_StatusTypeDef status = HAL_OK;
 800722a:	2000      	movs	r0, #0
 800722c:	4770      	bx	lr
    status = HAL_ERROR;
 800722e:	2001      	movs	r0, #1
  }

  return status;
}
 8007230:	4770      	bx	lr
 8007232:	bf00      	nop
 8007234:	40030400 	.word	0x40030400

08007238 <HAL_ICACHE_Enable>:
  *         cache operation completes.
  * @retval HAL status (HAL_OK)
  */
HAL_StatusTypeDef HAL_ICACHE_Enable(void)
{
  SET_BIT(ICACHE->CR, ICACHE_CR_EN);
 8007238:	4a03      	ldr	r2, [pc, #12]	@ (8007248 <HAL_ICACHE_Enable+0x10>)
 800723a:	6813      	ldr	r3, [r2, #0]
 800723c:	f043 0301 	orr.w	r3, r3, #1
 8007240:	6013      	str	r3, [r2, #0]

  return HAL_OK;
}
 8007242:	2000      	movs	r0, #0
 8007244:	4770      	bx	lr
 8007246:	bf00      	nop
 8007248:	40030400 	.word	0x40030400

0800724c <UART_EndRxTransfer>:
  * @retval None
  */
static void UART_EndRxTransfer(UART_HandleTypeDef *huart)
{
  /* Disable RXNE, PE and ERR (Frame error, noise error, overrun error) interrupts */
  ATOMIC_CLEAR_BIT(huart->Instance->CR1, (USART_CR1_RXNEIE_RXFNEIE | USART_CR1_PEIE));
 800724c:	6802      	ldr	r2, [r0, #0]
 */
__STATIC_FORCEINLINE uint32_t __LDREXW(volatile uint32_t *addr)
{
    uint32_t result;

   __ASM volatile ("ldrex %0, %1" : "=r" (result) : "Q" (*addr) );
 800724e:	e852 3f00 	ldrex	r3, [r2]
 8007252:	f423 7390 	bic.w	r3, r3, #288	@ 0x120
 */
__STATIC_FORCEINLINE uint32_t __STREXW(uint32_t value, volatile uint32_t *addr)
{
   uint32_t result;

   __ASM volatile ("strex %0, %2, %1" : "=&r" (result), "=Q" (*addr) : "r" (value) );
 8007256:	e842 3100 	strex	r1, r3, [r2]
 800725a:	2900      	cmp	r1, #0
 800725c:	d1f6      	bne.n	800724c <UART_EndRxTransfer>
  ATOMIC_CLEAR_BIT(huart->Instance->CR3, (USART_CR3_EIE | USART_CR3_RXFTIE));
 800725e:	6802      	ldr	r2, [r0, #0]
   __ASM volatile ("ldrex %0, %1" : "=r" (result) : "Q" (*addr) );
 8007260:	f102 0308 	add.w	r3, r2, #8
 8007264:	e853 3f00 	ldrex	r3, [r3]
 8007268:	f023 5380 	bic.w	r3, r3, #268435456	@ 0x10000000
 800726c:	f023 0301 	bic.w	r3, r3, #1
   __ASM volatile ("strex %0, %2, %1" : "=&r" (result), "=Q" (*addr) : "r" (value) );
 8007270:	3208      	adds	r2, #8
 8007272:	e842 3100 	strex	r1, r3, [r2]
 8007276:	2900      	cmp	r1, #0
 8007278:	d1f1      	bne.n	800725e <UART_EndRxTransfer+0x12>

  /* In case of reception waiting for IDLE event, disable also the IDLE IE interrupt source */
  if (huart->ReceptionType == HAL_UART_RECEPTION_TOIDLE)
 800727a:	6ec3      	ldr	r3, [r0, #108]	@ 0x6c
 800727c:	2b01      	cmp	r3, #1
 800727e:	d006      	beq.n	800728e <UART_EndRxTransfer+0x42>
  {
    ATOMIC_CLEAR_BIT(huart->Instance->CR1, USART_CR1_IDLEIE);
  }

  /* At end of Rx process, restore huart->RxState to Ready */
  huart->RxState = HAL_UART_STATE_READY;
 8007280:	2320      	movs	r3, #32
 8007282:	f8c0 308c 	str.w	r3, [r0, #140]	@ 0x8c
  huart->ReceptionType = HAL_UART_RECEPTION_STANDARD;
 8007286:	2300      	movs	r3, #0
 8007288:	66c3      	str	r3, [r0, #108]	@ 0x6c

  /* Reset RxIsr function pointer */
  huart->RxISR = NULL;
 800728a:	6743      	str	r3, [r0, #116]	@ 0x74
}
 800728c:	4770      	bx	lr
    ATOMIC_CLEAR_BIT(huart->Instance->CR1, USART_CR1_IDLEIE);
 800728e:	6802      	ldr	r2, [r0, #0]
   __ASM volatile ("ldrex %0, %1" : "=r" (result) : "Q" (*addr) );
 8007290:	e852 3f00 	ldrex	r3, [r2]
 8007294:	f023 0310 	bic.w	r3, r3, #16
   __ASM volatile ("strex %0, %2, %1" : "=&r" (result), "=Q" (*addr) : "r" (value) );
 8007298:	e842 3100 	strex	r1, r3, [r2]
 800729c:	2900      	cmp	r1, #0
 800729e:	d1f6      	bne.n	800728e <UART_EndRxTransfer+0x42>
 80072a0:	e7ee      	b.n	8007280 <UART_EndRxTransfer+0x34>
	...

080072a4 <UART_SetConfig>:
{
 80072a4:	b570      	push	{r4, r5, r6, lr}
 80072a6:	4604      	mov	r4, r0
  if (UART_INSTANCE_LOWPOWER(huart))
 80072a8:	6801      	ldr	r1, [r0, #0]
  tmpreg = (uint32_t)huart->Init.WordLength | huart->Init.Parity | huart->Init.Mode | huart->Init.OverSampling ;
 80072aa:	6883      	ldr	r3, [r0, #8]
 80072ac:	6902      	ldr	r2, [r0, #16]
 80072ae:	4313      	orrs	r3, r2
 80072b0:	6942      	ldr	r2, [r0, #20]
 80072b2:	4313      	orrs	r3, r2
 80072b4:	69c2      	ldr	r2, [r0, #28]
 80072b6:	4313      	orrs	r3, r2
  MODIFY_REG(huart->Instance->CR1, USART_CR1_FIELDS, tmpreg);
 80072b8:	6808      	ldr	r0, [r1, #0]
 80072ba:	4a83      	ldr	r2, [pc, #524]	@ (80074c8 <UART_SetConfig+0x224>)
 80072bc:	4002      	ands	r2, r0
 80072be:	431a      	orrs	r2, r3
 80072c0:	600a      	str	r2, [r1, #0]
  MODIFY_REG(huart->Instance->CR2, USART_CR2_STOP, huart->Init.StopBits);
 80072c2:	6822      	ldr	r2, [r4, #0]
 80072c4:	6853      	ldr	r3, [r2, #4]
 80072c6:	f423 5340 	bic.w	r3, r3, #12288	@ 0x3000
 80072ca:	68e1      	ldr	r1, [r4, #12]
 80072cc:	430b      	orrs	r3, r1
 80072ce:	6053      	str	r3, [r2, #4]
  tmpreg = (uint32_t)huart->Init.HwFlowCtl;
 80072d0:	69a1      	ldr	r1, [r4, #24]
  if (!(UART_INSTANCE_LOWPOWER(huart)))
 80072d2:	6822      	ldr	r2, [r4, #0]
 80072d4:	4b7d      	ldr	r3, [pc, #500]	@ (80074cc <UART_SetConfig+0x228>)
 80072d6:	429a      	cmp	r2, r3
 80072d8:	d005      	beq.n	80072e6 <UART_SetConfig+0x42>
 80072da:	f103 5380 	add.w	r3, r3, #268435456	@ 0x10000000
 80072de:	429a      	cmp	r2, r3
 80072e0:	d001      	beq.n	80072e6 <UART_SetConfig+0x42>
    tmpreg |= huart->Init.OneBitSampling;
 80072e2:	6a23      	ldr	r3, [r4, #32]
 80072e4:	4319      	orrs	r1, r3
  MODIFY_REG(huart->Instance->CR3, USART_CR3_FIELDS, tmpreg);
 80072e6:	6893      	ldr	r3, [r2, #8]
 80072e8:	f023 436e 	bic.w	r3, r3, #3992977408	@ 0xee000000
 80072ec:	f423 6330 	bic.w	r3, r3, #2816	@ 0xb00
 80072f0:	430b      	orrs	r3, r1
 80072f2:	6093      	str	r3, [r2, #8]
  MODIFY_REG(huart->Instance->PRESC, USART_PRESC_PRESCALER, huart->Init.ClockPrescaler);
 80072f4:	6822      	ldr	r2, [r4, #0]
 80072f6:	6ad3      	ldr	r3, [r2, #44]	@ 0x2c
 80072f8:	f023 030f 	bic.w	r3, r3, #15
 80072fc:	6a61      	ldr	r1, [r4, #36]	@ 0x24
 80072fe:	430b      	orrs	r3, r1
 8007300:	62d3      	str	r3, [r2, #44]	@ 0x2c
  UART_GETCLOCKSOURCE(huart, clocksource);
 8007302:	6823      	ldr	r3, [r4, #0]
 8007304:	4a72      	ldr	r2, [pc, #456]	@ (80074d0 <UART_SetConfig+0x22c>)
 8007306:	4293      	cmp	r3, r2
 8007308:	d033      	beq.n	8007372 <UART_SetConfig+0xce>
 800730a:	f5a2 4274 	sub.w	r2, r2, #62464	@ 0xf400
 800730e:	4293      	cmp	r3, r2
 8007310:	d058      	beq.n	80073c4 <UART_SetConfig+0x120>
 8007312:	f502 6280 	add.w	r2, r2, #1024	@ 0x400
 8007316:	4293      	cmp	r3, r2
 8007318:	d056      	beq.n	80073c8 <UART_SetConfig+0x124>
 800731a:	f502 6280 	add.w	r2, r2, #1024	@ 0x400
 800731e:	4293      	cmp	r3, r2
 8007320:	d054      	beq.n	80073cc <UART_SetConfig+0x128>
 8007322:	f502 6280 	add.w	r2, r2, #1024	@ 0x400
 8007326:	4293      	cmp	r3, r2
 8007328:	d052      	beq.n	80073d0 <UART_SetConfig+0x12c>
 800732a:	f502 52a0 	add.w	r2, r2, #5120	@ 0x1400
 800732e:	4293      	cmp	r3, r2
 8007330:	d050      	beq.n	80073d4 <UART_SetConfig+0x130>
 8007332:	f502 52a0 	add.w	r2, r2, #5120	@ 0x1400
 8007336:	4293      	cmp	r3, r2
 8007338:	d04e      	beq.n	80073d8 <UART_SetConfig+0x134>
 800733a:	f502 6280 	add.w	r2, r2, #1024	@ 0x400
 800733e:	4293      	cmp	r3, r2
 8007340:	d04c      	beq.n	80073dc <UART_SetConfig+0x138>
 8007342:	f502 6280 	add.w	r2, r2, #1024	@ 0x400
 8007346:	4293      	cmp	r3, r2
 8007348:	d04a      	beq.n	80073e0 <UART_SetConfig+0x13c>
 800734a:	f5a2 52c0 	sub.w	r2, r2, #6144	@ 0x1800
 800734e:	4293      	cmp	r3, r2
 8007350:	d049      	beq.n	80073e6 <UART_SetConfig+0x142>
 8007352:	f502 6280 	add.w	r2, r2, #1024	@ 0x400
 8007356:	4293      	cmp	r3, r2
 8007358:	d048      	beq.n	80073ec <UART_SetConfig+0x148>
 800735a:	f502 52c0 	add.w	r2, r2, #6144	@ 0x1800
 800735e:	4293      	cmp	r3, r2
 8007360:	d047      	beq.n	80073f2 <UART_SetConfig+0x14e>
 8007362:	4a5a      	ldr	r2, [pc, #360]	@ (80074cc <UART_SetConfig+0x228>)
 8007364:	4293      	cmp	r3, r2
 8007366:	d001      	beq.n	800736c <UART_SetConfig+0xc8>
 8007368:	2000      	movs	r0, #0
 800736a:	e003      	b.n	8007374 <UART_SetConfig+0xd0>
 800736c:	f44f 5080 	mov.w	r0, #4096	@ 0x1000
 8007370:	e000      	b.n	8007374 <UART_SetConfig+0xd0>
 8007372:	2001      	movs	r0, #1
  if (UART_INSTANCE_LOWPOWER(huart))
 8007374:	4a55      	ldr	r2, [pc, #340]	@ (80074cc <UART_SetConfig+0x228>)
 8007376:	4293      	cmp	r3, r2
 8007378:	d03e      	beq.n	80073f8 <UART_SetConfig+0x154>
 800737a:	f102 5280 	add.w	r2, r2, #268435456	@ 0x10000000
 800737e:	4293      	cmp	r3, r2
 8007380:	d03a      	beq.n	80073f8 <UART_SetConfig+0x154>
  else if (huart->Init.OverSampling == UART_OVERSAMPLING_8)
 8007382:	69e3      	ldr	r3, [r4, #28]
 8007384:	f5b3 4f00 	cmp.w	r3, #32768	@ 0x8000
 8007388:	d065      	beq.n	8007456 <UART_SetConfig+0x1b2>
    pclk = HAL_RCCEx_GetPeriphCLKFreq(clocksource);
 800738a:	2100      	movs	r1, #0
 800738c:	f7fd ff4c 	bl	8005228 <HAL_RCCEx_GetPeriphCLKFreq>
    if (pclk != 0U)
 8007390:	2800      	cmp	r0, #0
 8007392:	f000 8094 	beq.w	80074be <UART_SetConfig+0x21a>
      usartdiv = (uint32_t)(UART_DIV_SAMPLING16(pclk, huart->Init.BaudRate, huart->Init.ClockPrescaler));
 8007396:	6a61      	ldr	r1, [r4, #36]	@ 0x24
 8007398:	4a4e      	ldr	r2, [pc, #312]	@ (80074d4 <UART_SetConfig+0x230>)
 800739a:	f832 2011 	ldrh.w	r2, [r2, r1, lsl #1]
 800739e:	fbb0 f3f2 	udiv	r3, r0, r2
 80073a2:	6862      	ldr	r2, [r4, #4]
 80073a4:	eb03 0352 	add.w	r3, r3, r2, lsr #1
 80073a8:	fbb3 f3f2 	udiv	r3, r3, r2
      if ((usartdiv >= UART_BRR_MIN) && (usartdiv <= UART_BRR_MAX))
 80073ac:	f1a3 0110 	sub.w	r1, r3, #16
 80073b0:	f64f 72ef 	movw	r2, #65519	@ 0xffef
 80073b4:	4291      	cmp	r1, r2
 80073b6:	f200 8084 	bhi.w	80074c2 <UART_SetConfig+0x21e>
        huart->Instance->BRR = (uint16_t)usartdiv;
 80073ba:	6822      	ldr	r2, [r4, #0]
 80073bc:	b29b      	uxth	r3, r3
 80073be:	60d3      	str	r3, [r2, #12]
  HAL_StatusTypeDef ret               = HAL_OK;
 80073c0:	2000      	movs	r0, #0
 80073c2:	e069      	b.n	8007498 <UART_SetConfig+0x1f4>
  UART_GETCLOCKSOURCE(huart, clocksource);
 80073c4:	2002      	movs	r0, #2
 80073c6:	e7d5      	b.n	8007374 <UART_SetConfig+0xd0>
 80073c8:	2004      	movs	r0, #4
 80073ca:	e7d3      	b.n	8007374 <UART_SetConfig+0xd0>
 80073cc:	2008      	movs	r0, #8
 80073ce:	e7d1      	b.n	8007374 <UART_SetConfig+0xd0>
 80073d0:	2010      	movs	r0, #16
 80073d2:	e7cf      	b.n	8007374 <UART_SetConfig+0xd0>
 80073d4:	2020      	movs	r0, #32
 80073d6:	e7cd      	b.n	8007374 <UART_SetConfig+0xd0>
 80073d8:	2040      	movs	r0, #64	@ 0x40
 80073da:	e7cb      	b.n	8007374 <UART_SetConfig+0xd0>
 80073dc:	2080      	movs	r0, #128	@ 0x80
 80073de:	e7c9      	b.n	8007374 <UART_SetConfig+0xd0>
 80073e0:	f44f 7080 	mov.w	r0, #256	@ 0x100
 80073e4:	e7c6      	b.n	8007374 <UART_SetConfig+0xd0>
 80073e6:	f44f 7000 	mov.w	r0, #512	@ 0x200
 80073ea:	e7c3      	b.n	8007374 <UART_SetConfig+0xd0>
 80073ec:	f44f 6080 	mov.w	r0, #1024	@ 0x400
 80073f0:	e7c0      	b.n	8007374 <UART_SetConfig+0xd0>
 80073f2:	f44f 6000 	mov.w	r0, #2048	@ 0x800
 80073f6:	e7bd      	b.n	8007374 <UART_SetConfig+0xd0>
    pclk = HAL_RCCEx_GetPeriphCLKFreq(clocksource);
 80073f8:	2100      	movs	r1, #0
 80073fa:	f7fd ff15 	bl	8005228 <HAL_RCCEx_GetPeriphCLKFreq>
    if (pclk != 0U)
 80073fe:	4601      	mov	r1, r0
 8007400:	2800      	cmp	r0, #0
 8007402:	d048      	beq.n	8007496 <UART_SetConfig+0x1f2>
      lpuart_ker_ck_pres = (pclk / UARTPrescTable[huart->Init.ClockPrescaler]);
 8007404:	6a62      	ldr	r2, [r4, #36]	@ 0x24
 8007406:	4b33      	ldr	r3, [pc, #204]	@ (80074d4 <UART_SetConfig+0x230>)
 8007408:	f833 2012 	ldrh.w	r2, [r3, r2, lsl #1]
 800740c:	fbb0 f3f2 	udiv	r3, r0, r2
      if ((lpuart_ker_ck_pres < (3U * huart->Init.BaudRate)) ||
 8007410:	6865      	ldr	r5, [r4, #4]
 8007412:	eb05 0045 	add.w	r0, r5, r5, lsl #1
 8007416:	4298      	cmp	r0, r3
 8007418:	d847      	bhi.n	80074aa <UART_SetConfig+0x206>
 800741a:	ebb3 3f05 	cmp.w	r3, r5, lsl #12
 800741e:	d846      	bhi.n	80074ae <UART_SetConfig+0x20a>
        usartdiv = (uint32_t)(UART_DIV_LPUART(pclk, huart->Init.BaudRate, huart->Init.ClockPrescaler));
 8007420:	2600      	movs	r6, #0
 8007422:	4633      	mov	r3, r6
 8007424:	4608      	mov	r0, r1
 8007426:	4631      	mov	r1, r6
 8007428:	f7f8 ffce 	bl	80003c8 <__aeabi_uldivmod>
 800742c:	0209      	lsls	r1, r1, #8
 800742e:	ea41 6110 	orr.w	r1, r1, r0, lsr #24
 8007432:	0200      	lsls	r0, r0, #8
 8007434:	086b      	lsrs	r3, r5, #1
 8007436:	18c0      	adds	r0, r0, r3
 8007438:	462a      	mov	r2, r5
 800743a:	4633      	mov	r3, r6
 800743c:	f141 0100 	adc.w	r1, r1, #0
 8007440:	f7f8 ffc2 	bl	80003c8 <__aeabi_uldivmod>
        if ((usartdiv >= LPUART_BRR_MIN) && (usartdiv <= LPUART_BRR_MAX))
 8007444:	f5a0 7240 	sub.w	r2, r0, #768	@ 0x300
 8007448:	4b23      	ldr	r3, [pc, #140]	@ (80074d8 <UART_SetConfig+0x234>)
 800744a:	429a      	cmp	r2, r3
 800744c:	d831      	bhi.n	80074b2 <UART_SetConfig+0x20e>
          huart->Instance->BRR = usartdiv;
 800744e:	6823      	ldr	r3, [r4, #0]
 8007450:	60d8      	str	r0, [r3, #12]
  HAL_StatusTypeDef ret               = HAL_OK;
 8007452:	4630      	mov	r0, r6
 8007454:	e020      	b.n	8007498 <UART_SetConfig+0x1f4>
    pclk = HAL_RCCEx_GetPeriphCLKFreq(clocksource);
 8007456:	2100      	movs	r1, #0
 8007458:	f7fd fee6 	bl	8005228 <HAL_RCCEx_GetPeriphCLKFreq>
    if (pclk != 0U)
 800745c:	b358      	cbz	r0, 80074b6 <UART_SetConfig+0x212>
      usartdiv = (uint32_t)(UART_DIV_SAMPLING8(pclk, huart->Init.BaudRate, huart->Init.ClockPrescaler));
 800745e:	6a61      	ldr	r1, [r4, #36]	@ 0x24
 8007460:	4a1c      	ldr	r2, [pc, #112]	@ (80074d4 <UART_SetConfig+0x230>)
 8007462:	f832 2011 	ldrh.w	r2, [r2, r1, lsl #1]
 8007466:	fbb0 f2f2 	udiv	r2, r0, r2
 800746a:	6861      	ldr	r1, [r4, #4]
 800746c:	084b      	lsrs	r3, r1, #1
 800746e:	eb03 0342 	add.w	r3, r3, r2, lsl #1
 8007472:	fbb3 f3f1 	udiv	r3, r3, r1
      if ((usartdiv >= UART_BRR_MIN) && (usartdiv <= UART_BRR_MAX))
 8007476:	f1a3 0110 	sub.w	r1, r3, #16
 800747a:	f64f 72ef 	movw	r2, #65519	@ 0xffef
 800747e:	4291      	cmp	r1, r2
 8007480:	d81b      	bhi.n	80074ba <UART_SetConfig+0x216>
        brrtemp = (uint16_t)(usartdiv & 0xFFF0U);
 8007482:	b29a      	uxth	r2, r3
 8007484:	f022 020f 	bic.w	r2, r2, #15
        brrtemp |= (uint16_t)((usartdiv & (uint16_t)0x000FU) >> 1U);
 8007488:	f3c3 0342 	ubfx	r3, r3, #1, #3
 800748c:	4313      	orrs	r3, r2
        huart->Instance->BRR = brrtemp;
 800748e:	6822      	ldr	r2, [r4, #0]
 8007490:	60d3      	str	r3, [r2, #12]
  HAL_StatusTypeDef ret               = HAL_OK;
 8007492:	2000      	movs	r0, #0
 8007494:	e000      	b.n	8007498 <UART_SetConfig+0x1f4>
 8007496:	2000      	movs	r0, #0
  huart->NbTxDataToProcess = 1;
 8007498:	2301      	movs	r3, #1
 800749a:	f8a4 306a 	strh.w	r3, [r4, #106]	@ 0x6a
  huart->NbRxDataToProcess = 1;
 800749e:	f8a4 3068 	strh.w	r3, [r4, #104]	@ 0x68
  huart->RxISR = NULL;
 80074a2:	2300      	movs	r3, #0
 80074a4:	6763      	str	r3, [r4, #116]	@ 0x74
  huart->TxISR = NULL;
 80074a6:	67a3      	str	r3, [r4, #120]	@ 0x78
}
 80074a8:	bd70      	pop	{r4, r5, r6, pc}
        ret = HAL_ERROR;
 80074aa:	2001      	movs	r0, #1
 80074ac:	e7f4      	b.n	8007498 <UART_SetConfig+0x1f4>
 80074ae:	2001      	movs	r0, #1
 80074b0:	e7f2      	b.n	8007498 <UART_SetConfig+0x1f4>
          ret = HAL_ERROR;
 80074b2:	2001      	movs	r0, #1
 80074b4:	e7f0      	b.n	8007498 <UART_SetConfig+0x1f4>
  HAL_StatusTypeDef ret               = HAL_OK;
 80074b6:	2000      	movs	r0, #0
 80074b8:	e7ee      	b.n	8007498 <UART_SetConfig+0x1f4>
        ret = HAL_ERROR;
 80074ba:	2001      	movs	r0, #1
 80074bc:	e7ec      	b.n	8007498 <UART_SetConfig+0x1f4>
  HAL_StatusTypeDef ret               = HAL_OK;
 80074be:	2000      	movs	r0, #0
 80074c0:	e7ea      	b.n	8007498 <UART_SetConfig+0x1f4>
        ret = HAL_ERROR;
 80074c2:	2001      	movs	r0, #1
 80074c4:	e7e8      	b.n	8007498 <UART_SetConfig+0x1f4>
 80074c6:	bf00      	nop
 80074c8:	cfff69f3 	.word	0xcfff69f3
 80074cc:	44002400 	.word	0x44002400
 80074d0:	40013800 	.word	0x40013800
 80074d4:	08009264 	.word	0x08009264
 80074d8:	000ffcff 	.word	0x000ffcff

080074dc <UART_AdvFeatureConfig>:
  if (HAL_IS_BIT_SET(huart->AdvancedInit.AdvFeatureInit, UART_ADVFEATURE_SWAP_INIT))
 80074dc:	6a83      	ldr	r3, [r0, #40]	@ 0x28
 80074de:	f013 0f08 	tst.w	r3, #8
 80074e2:	d006      	beq.n	80074f2 <UART_AdvFeatureConfig+0x16>
    MODIFY_REG(huart->Instance->CR2, USART_CR2_SWAP, huart->AdvancedInit.Swap);
 80074e4:	6802      	ldr	r2, [r0, #0]
 80074e6:	6853      	ldr	r3, [r2, #4]
 80074e8:	f423 4300 	bic.w	r3, r3, #32768	@ 0x8000
 80074ec:	6b81      	ldr	r1, [r0, #56]	@ 0x38
 80074ee:	430b      	orrs	r3, r1
 80074f0:	6053      	str	r3, [r2, #4]
  if (HAL_IS_BIT_SET(huart->AdvancedInit.AdvFeatureInit, UART_ADVFEATURE_TXINVERT_INIT))
 80074f2:	6a83      	ldr	r3, [r0, #40]	@ 0x28
 80074f4:	f013 0f01 	tst.w	r3, #1
 80074f8:	d006      	beq.n	8007508 <UART_AdvFeatureConfig+0x2c>
    MODIFY_REG(huart->Instance->CR2, USART_CR2_TXINV, huart->AdvancedInit.TxPinLevelInvert);
 80074fa:	6802      	ldr	r2, [r0, #0]
 80074fc:	6853      	ldr	r3, [r2, #4]
 80074fe:	f423 3300 	bic.w	r3, r3, #131072	@ 0x20000
 8007502:	6ac1      	ldr	r1, [r0, #44]	@ 0x2c
 8007504:	430b      	orrs	r3, r1
 8007506:	6053      	str	r3, [r2, #4]
  if (HAL_IS_BIT_SET(huart->AdvancedInit.AdvFeatureInit, UART_ADVFEATURE_RXINVERT_INIT))
 8007508:	6a83      	ldr	r3, [r0, #40]	@ 0x28
 800750a:	f013 0f02 	tst.w	r3, #2
 800750e:	d006      	beq.n	800751e <UART_AdvFeatureConfig+0x42>
    MODIFY_REG(huart->Instance->CR2, USART_CR2_RXINV, huart->AdvancedInit.RxPinLevelInvert);
 8007510:	6802      	ldr	r2, [r0, #0]
 8007512:	6853      	ldr	r3, [r2, #4]
 8007514:	f423 3380 	bic.w	r3, r3, #65536	@ 0x10000
 8007518:	6b01      	ldr	r1, [r0, #48]	@ 0x30
 800751a:	430b      	orrs	r3, r1
 800751c:	6053      	str	r3, [r2, #4]
  if (HAL_IS_BIT_SET(huart->AdvancedInit.AdvFeatureInit, UART_ADVFEATURE_DATAINVERT_INIT))
 800751e:	6a83      	ldr	r3, [r0, #40]	@ 0x28
 8007520:	f013 0f04 	tst.w	r3, #4
 8007524:	d006      	beq.n	8007534 <UART_AdvFeatureConfig+0x58>
    MODIFY_REG(huart->Instance->CR2, USART_CR2_DATAINV, huart->AdvancedInit.DataInvert);
 8007526:	6802      	ldr	r2, [r0, #0]
 8007528:	6853      	ldr	r3, [r2, #4]
 800752a:	f423 2380 	bic.w	r3, r3, #262144	@ 0x40000
 800752e:	6b41      	ldr	r1, [r0, #52]	@ 0x34
 8007530:	430b      	orrs	r3, r1
 8007532:	6053      	str	r3, [r2, #4]
  if (HAL_IS_BIT_SET(huart->AdvancedInit.AdvFeatureInit, UART_ADVFEATURE_RXOVERRUNDISABLE_INIT))
 8007534:	6a83      	ldr	r3, [r0, #40]	@ 0x28
 8007536:	f013 0f10 	tst.w	r3, #16
 800753a:	d006      	beq.n	800754a <UART_AdvFeatureConfig+0x6e>
    MODIFY_REG(huart->Instance->CR3, USART_CR3_OVRDIS, huart->AdvancedInit.OverrunDisable);
 800753c:	6802      	ldr	r2, [r0, #0]
 800753e:	6893      	ldr	r3, [r2, #8]
 8007540:	f423 5380 	bic.w	r3, r3, #4096	@ 0x1000
 8007544:	6bc1      	ldr	r1, [r0, #60]	@ 0x3c
 8007546:	430b      	orrs	r3, r1
 8007548:	6093      	str	r3, [r2, #8]
  if (HAL_IS_BIT_SET(huart->AdvancedInit.AdvFeatureInit, UART_ADVFEATURE_DMADISABLEONERROR_INIT))
 800754a:	6a83      	ldr	r3, [r0, #40]	@ 0x28
 800754c:	f013 0f20 	tst.w	r3, #32
 8007550:	d006      	beq.n	8007560 <UART_AdvFeatureConfig+0x84>
    MODIFY_REG(huart->Instance->CR3, USART_CR3_DDRE, huart->AdvancedInit.DMADisableonRxError);
 8007552:	6802      	ldr	r2, [r0, #0]
 8007554:	6893      	ldr	r3, [r2, #8]
 8007556:	f423 5300 	bic.w	r3, r3, #8192	@ 0x2000
 800755a:	6c01      	ldr	r1, [r0, #64]	@ 0x40
 800755c:	430b      	orrs	r3, r1
 800755e:	6093      	str	r3, [r2, #8]
  if (HAL_IS_BIT_SET(huart->AdvancedInit.AdvFeatureInit, UART_ADVFEATURE_AUTOBAUDRATE_INIT))
 8007560:	6a83      	ldr	r3, [r0, #40]	@ 0x28
 8007562:	f013 0f40 	tst.w	r3, #64	@ 0x40
 8007566:	d00a      	beq.n	800757e <UART_AdvFeatureConfig+0xa2>
    MODIFY_REG(huart->Instance->CR2, USART_CR2_ABREN, huart->AdvancedInit.AutoBaudRateEnable);
 8007568:	6802      	ldr	r2, [r0, #0]
 800756a:	6853      	ldr	r3, [r2, #4]
 800756c:	f423 1380 	bic.w	r3, r3, #1048576	@ 0x100000
 8007570:	6c41      	ldr	r1, [r0, #68]	@ 0x44
 8007572:	430b      	orrs	r3, r1
 8007574:	6053      	str	r3, [r2, #4]
    if (huart->AdvancedInit.AutoBaudRateEnable == UART_ADVFEATURE_AUTOBAUDRATE_ENABLE)
 8007576:	6c43      	ldr	r3, [r0, #68]	@ 0x44
 8007578:	f5b3 1f80 	cmp.w	r3, #1048576	@ 0x100000
 800757c:	d00b      	beq.n	8007596 <UART_AdvFeatureConfig+0xba>
  if (HAL_IS_BIT_SET(huart->AdvancedInit.AdvFeatureInit, UART_ADVFEATURE_MSBFIRST_INIT))
 800757e:	6a83      	ldr	r3, [r0, #40]	@ 0x28
 8007580:	f013 0f80 	tst.w	r3, #128	@ 0x80
 8007584:	d006      	beq.n	8007594 <UART_AdvFeatureConfig+0xb8>
    MODIFY_REG(huart->Instance->CR2, USART_CR2_MSBFIRST, huart->AdvancedInit.MSBFirst);
 8007586:	6802      	ldr	r2, [r0, #0]
 8007588:	6853      	ldr	r3, [r2, #4]
 800758a:	f423 2300 	bic.w	r3, r3, #524288	@ 0x80000
 800758e:	6cc1      	ldr	r1, [r0, #76]	@ 0x4c
 8007590:	430b      	orrs	r3, r1
 8007592:	6053      	str	r3, [r2, #4]
}
 8007594:	4770      	bx	lr
      MODIFY_REG(huart->Instance->CR2, USART_CR2_ABRMODE, huart->AdvancedInit.AutoBaudRateMode);
 8007596:	6802      	ldr	r2, [r0, #0]
 8007598:	6853      	ldr	r3, [r2, #4]
 800759a:	f423 03c0 	bic.w	r3, r3, #6291456	@ 0x600000
 800759e:	6c81      	ldr	r1, [r0, #72]	@ 0x48
 80075a0:	430b      	orrs	r3, r1
 80075a2:	6053      	str	r3, [r2, #4]
 80075a4:	e7eb      	b.n	800757e <UART_AdvFeatureConfig+0xa2>

080075a6 <UART_WaitOnFlagUntilTimeout>:
{
 80075a6:	e92d 43f8 	stmdb	sp!, {r3, r4, r5, r6, r7, r8, r9, lr}
 80075aa:	4605      	mov	r5, r0
 80075ac:	460e      	mov	r6, r1
 80075ae:	4617      	mov	r7, r2
 80075b0:	4699      	mov	r9, r3
 80075b2:	f8dd 8020 	ldr.w	r8, [sp, #32]
  while ((__HAL_UART_GET_FLAG(huart, Flag) ? SET : RESET) == Status)
 80075b6:	682b      	ldr	r3, [r5, #0]
 80075b8:	69dc      	ldr	r4, [r3, #28]
 80075ba:	ea36 0404 	bics.w	r4, r6, r4
 80075be:	bf0c      	ite	eq
 80075c0:	2401      	moveq	r4, #1
 80075c2:	2400      	movne	r4, #0
 80075c4:	42bc      	cmp	r4, r7
 80075c6:	d136      	bne.n	8007636 <UART_WaitOnFlagUntilTimeout+0x90>
    if (Timeout != HAL_MAX_DELAY)
 80075c8:	f1b8 3fff 	cmp.w	r8, #4294967295	@ 0xffffffff
 80075cc:	d0f3      	beq.n	80075b6 <UART_WaitOnFlagUntilTimeout+0x10>
      if (((HAL_GetTick() - Tickstart) > Timeout) || (Timeout == 0U))
 80075ce:	f7fb fbd7 	bl	8002d80 <HAL_GetTick>
 80075d2:	eba0 0009 	sub.w	r0, r0, r9
 80075d6:	4540      	cmp	r0, r8
 80075d8:	d830      	bhi.n	800763c <UART_WaitOnFlagUntilTimeout+0x96>
 80075da:	f1b8 0f00 	cmp.w	r8, #0
 80075de:	d02f      	beq.n	8007640 <UART_WaitOnFlagUntilTimeout+0x9a>
      if ((READ_BIT(huart->Instance->CR1, USART_CR1_RE) != 0U) && (Flag != UART_FLAG_TXE) && (Flag != UART_FLAG_TC))
 80075e0:	682b      	ldr	r3, [r5, #0]
 80075e2:	681a      	ldr	r2, [r3, #0]
 80075e4:	f012 0f04 	tst.w	r2, #4
 80075e8:	d0e5      	beq.n	80075b6 <UART_WaitOnFlagUntilTimeout+0x10>
 80075ea:	2e80      	cmp	r6, #128	@ 0x80
 80075ec:	d0e3      	beq.n	80075b6 <UART_WaitOnFlagUntilTimeout+0x10>
 80075ee:	2e40      	cmp	r6, #64	@ 0x40
 80075f0:	d0e1      	beq.n	80075b6 <UART_WaitOnFlagUntilTimeout+0x10>
        if (__HAL_UART_GET_FLAG(huart, UART_FLAG_ORE) == SET)
 80075f2:	69da      	ldr	r2, [r3, #28]
 80075f4:	f012 0f08 	tst.w	r2, #8
 80075f8:	d111      	bne.n	800761e <UART_WaitOnFlagUntilTimeout+0x78>
        if (__HAL_UART_GET_FLAG(huart, UART_FLAG_RTOF) == SET)
 80075fa:	69da      	ldr	r2, [r3, #28]
 80075fc:	f412 6f00 	tst.w	r2, #2048	@ 0x800
 8007600:	d0d9      	beq.n	80075b6 <UART_WaitOnFlagUntilTimeout+0x10>
          __HAL_UART_CLEAR_FLAG(huart, UART_CLEAR_RTOF);
 8007602:	f44f 6200 	mov.w	r2, #2048	@ 0x800
 8007606:	621a      	str	r2, [r3, #32]
          UART_EndRxTransfer(huart);
 8007608:	4628      	mov	r0, r5
 800760a:	f7ff fe1f 	bl	800724c <UART_EndRxTransfer>
          huart->ErrorCode = HAL_UART_ERROR_RTO;
 800760e:	2320      	movs	r3, #32
 8007610:	f8c5 3090 	str.w	r3, [r5, #144]	@ 0x90
          __HAL_UNLOCK(huart);
 8007614:	2300      	movs	r3, #0
 8007616:	f885 3084 	strb.w	r3, [r5, #132]	@ 0x84
          return HAL_TIMEOUT;
 800761a:	2003      	movs	r0, #3
 800761c:	e00c      	b.n	8007638 <UART_WaitOnFlagUntilTimeout+0x92>
          __HAL_UART_CLEAR_FLAG(huart, UART_CLEAR_OREF);
 800761e:	2408      	movs	r4, #8
 8007620:	621c      	str	r4, [r3, #32]
          UART_EndRxTransfer(huart);
 8007622:	4628      	mov	r0, r5
 8007624:	f7ff fe12 	bl	800724c <UART_EndRxTransfer>
          huart->ErrorCode = HAL_UART_ERROR_ORE;
 8007628:	f8c5 4090 	str.w	r4, [r5, #144]	@ 0x90
          __HAL_UNLOCK(huart);
 800762c:	2300      	movs	r3, #0
 800762e:	f885 3084 	strb.w	r3, [r5, #132]	@ 0x84
          return HAL_ERROR;
 8007632:	2001      	movs	r0, #1
 8007634:	e000      	b.n	8007638 <UART_WaitOnFlagUntilTimeout+0x92>
  return HAL_OK;
 8007636:	2000      	movs	r0, #0
}
 8007638:	e8bd 83f8 	ldmia.w	sp!, {r3, r4, r5, r6, r7, r8, r9, pc}
        return HAL_TIMEOUT;
 800763c:	2003      	movs	r0, #3
 800763e:	e7fb      	b.n	8007638 <UART_WaitOnFlagUntilTimeout+0x92>
 8007640:	2003      	movs	r0, #3
 8007642:	e7f9      	b.n	8007638 <UART_WaitOnFlagUntilTimeout+0x92>

08007644 <HAL_UART_Transmit>:
{
 8007644:	e92d 41f0 	stmdb	sp!, {r4, r5, r6, r7, r8, lr}
 8007648:	b082      	sub	sp, #8
 800764a:	461e      	mov	r6, r3
  if (huart->gState == HAL_UART_STATE_READY)
 800764c:	f8d0 3088 	ldr.w	r3, [r0, #136]	@ 0x88
 8007650:	2b20      	cmp	r3, #32
 8007652:	d162      	bne.n	800771a <HAL_UART_Transmit+0xd6>
 8007654:	4604      	mov	r4, r0
 8007656:	460d      	mov	r5, r1
 8007658:	4690      	mov	r8, r2
    if ((pData == NULL) || (Size == 0U))
 800765a:	2900      	cmp	r1, #0
 800765c:	d061      	beq.n	8007722 <HAL_UART_Transmit+0xde>
 800765e:	2a00      	cmp	r2, #0
 8007660:	d061      	beq.n	8007726 <HAL_UART_Transmit+0xe2>
    if (HAL_IS_BIT_SET(huart->Instance->CR3, USART_CR3_DMAT))
 8007662:	6803      	ldr	r3, [r0, #0]
 8007664:	689a      	ldr	r2, [r3, #8]
 8007666:	f012 0f80 	tst.w	r2, #128	@ 0x80
 800766a:	d003      	beq.n	8007674 <HAL_UART_Transmit+0x30>
      CLEAR_BIT(huart->Instance->CR3, USART_CR3_DMAT);
 800766c:	689a      	ldr	r2, [r3, #8]
 800766e:	f022 0280 	bic.w	r2, r2, #128	@ 0x80
 8007672:	609a      	str	r2, [r3, #8]
    huart->ErrorCode = HAL_UART_ERROR_NONE;
 8007674:	2300      	movs	r3, #0
 8007676:	f8c4 3090 	str.w	r3, [r4, #144]	@ 0x90
    huart->gState = HAL_UART_STATE_BUSY_TX;
 800767a:	2321      	movs	r3, #33	@ 0x21
 800767c:	f8c4 3088 	str.w	r3, [r4, #136]	@ 0x88
    tickstart = HAL_GetTick();
 8007680:	f7fb fb7e 	bl	8002d80 <HAL_GetTick>
 8007684:	4607      	mov	r7, r0
    huart->TxXferSize  = Size;
 8007686:	f8a4 8054 	strh.w	r8, [r4, #84]	@ 0x54
    huart->TxXferCount = Size;
 800768a:	f8a4 8056 	strh.w	r8, [r4, #86]	@ 0x56
    if ((huart->Init.WordLength == UART_WORDLENGTH_9B) && (huart->Init.Parity == UART_PARITY_NONE))
 800768e:	68a3      	ldr	r3, [r4, #8]
 8007690:	f5b3 5f80 	cmp.w	r3, #4096	@ 0x1000
 8007694:	d002      	beq.n	800769c <HAL_UART_Transmit+0x58>
      pdata16bits = NULL;
 8007696:	f04f 0800 	mov.w	r8, #0
 800769a:	e016      	b.n	80076ca <HAL_UART_Transmit+0x86>
    if ((huart->Init.WordLength == UART_WORDLENGTH_9B) && (huart->Init.Parity == UART_PARITY_NONE))
 800769c:	6923      	ldr	r3, [r4, #16]
 800769e:	b343      	cbz	r3, 80076f2 <HAL_UART_Transmit+0xae>
      pdata16bits = NULL;
 80076a0:	f04f 0800 	mov.w	r8, #0
 80076a4:	e011      	b.n	80076ca <HAL_UART_Transmit+0x86>
        huart->gState = HAL_UART_STATE_READY;
 80076a6:	2320      	movs	r3, #32
 80076a8:	f8c4 3088 	str.w	r3, [r4, #136]	@ 0x88
        return HAL_TIMEOUT;
 80076ac:	2003      	movs	r0, #3
 80076ae:	e035      	b.n	800771c <HAL_UART_Transmit+0xd8>
        huart->Instance->TDR = (uint16_t)(*pdata16bits & 0x01FFU);
 80076b0:	f838 3b02 	ldrh.w	r3, [r8], #2
 80076b4:	6822      	ldr	r2, [r4, #0]
 80076b6:	f3c3 0308 	ubfx	r3, r3, #0, #9
 80076ba:	6293      	str	r3, [r2, #40]	@ 0x28
      huart->TxXferCount--;
 80076bc:	f8b4 2056 	ldrh.w	r2, [r4, #86]	@ 0x56
 80076c0:	b292      	uxth	r2, r2
 80076c2:	3a01      	subs	r2, #1
 80076c4:	b292      	uxth	r2, r2
 80076c6:	f8a4 2056 	strh.w	r2, [r4, #86]	@ 0x56
    while (huart->TxXferCount > 0U)
 80076ca:	f8b4 3056 	ldrh.w	r3, [r4, #86]	@ 0x56
 80076ce:	b29b      	uxth	r3, r3
 80076d0:	b193      	cbz	r3, 80076f8 <HAL_UART_Transmit+0xb4>
      if (UART_WaitOnFlagUntilTimeout(huart, UART_FLAG_TXE, RESET, tickstart, Timeout) != HAL_OK)
 80076d2:	9600      	str	r6, [sp, #0]
 80076d4:	463b      	mov	r3, r7
 80076d6:	2200      	movs	r2, #0
 80076d8:	2180      	movs	r1, #128	@ 0x80
 80076da:	4620      	mov	r0, r4
 80076dc:	f7ff ff63 	bl	80075a6 <UART_WaitOnFlagUntilTimeout>
 80076e0:	2800      	cmp	r0, #0
 80076e2:	d1e0      	bne.n	80076a6 <HAL_UART_Transmit+0x62>
      if (pdata8bits == NULL)
 80076e4:	2d00      	cmp	r5, #0
 80076e6:	d0e3      	beq.n	80076b0 <HAL_UART_Transmit+0x6c>
        huart->Instance->TDR = (uint8_t)(*pdata8bits & 0xFFU);
 80076e8:	f815 2b01 	ldrb.w	r2, [r5], #1
 80076ec:	6823      	ldr	r3, [r4, #0]
 80076ee:	629a      	str	r2, [r3, #40]	@ 0x28
        pdata8bits++;
 80076f0:	e7e4      	b.n	80076bc <HAL_UART_Transmit+0x78>
      pdata16bits = (const uint16_t *) pData;
 80076f2:	46a8      	mov	r8, r5
      pdata8bits  = NULL;
 80076f4:	2500      	movs	r5, #0
 80076f6:	e7e8      	b.n	80076ca <HAL_UART_Transmit+0x86>
    if (UART_WaitOnFlagUntilTimeout(huart, UART_FLAG_TC, RESET, tickstart, Timeout) != HAL_OK)
 80076f8:	9600      	str	r6, [sp, #0]
 80076fa:	463b      	mov	r3, r7
 80076fc:	2200      	movs	r2, #0
 80076fe:	2140      	movs	r1, #64	@ 0x40
 8007700:	4620      	mov	r0, r4
 8007702:	f7ff ff50 	bl	80075a6 <UART_WaitOnFlagUntilTimeout>
 8007706:	b918      	cbnz	r0, 8007710 <HAL_UART_Transmit+0xcc>
    huart->gState = HAL_UART_STATE_READY;
 8007708:	2320      	movs	r3, #32
 800770a:	f8c4 3088 	str.w	r3, [r4, #136]	@ 0x88
    return HAL_OK;
 800770e:	e005      	b.n	800771c <HAL_UART_Transmit+0xd8>
      huart->gState = HAL_UART_STATE_READY;
 8007710:	2320      	movs	r3, #32
 8007712:	f8c4 3088 	str.w	r3, [r4, #136]	@ 0x88
      return HAL_TIMEOUT;
 8007716:	2003      	movs	r0, #3
 8007718:	e000      	b.n	800771c <HAL_UART_Transmit+0xd8>
    return HAL_BUSY;
 800771a:	2002      	movs	r0, #2
}
 800771c:	b002      	add	sp, #8
 800771e:	e8bd 81f0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, pc}
      return  HAL_ERROR;
 8007722:	2001      	movs	r0, #1
 8007724:	e7fa      	b.n	800771c <HAL_UART_Transmit+0xd8>
 8007726:	2001      	movs	r0, #1
 8007728:	e7f8      	b.n	800771c <HAL_UART_Transmit+0xd8>

0800772a <UART_CheckIdleState>:
{
 800772a:	b530      	push	{r4, r5, lr}
 800772c:	b083      	sub	sp, #12
 800772e:	4604      	mov	r4, r0
  huart->ErrorCode = HAL_UART_ERROR_NONE;
 8007730:	2300      	movs	r3, #0
 8007732:	f8c0 3090 	str.w	r3, [r0, #144]	@ 0x90
  tickstart = HAL_GetTick();
 8007736:	f7fb fb23 	bl	8002d80 <HAL_GetTick>
 800773a:	4605      	mov	r5, r0
  if ((huart->Instance->CR1 & USART_CR1_TE) == USART_CR1_TE)
 800773c:	6822      	ldr	r2, [r4, #0]
 800773e:	6812      	ldr	r2, [r2, #0]
 8007740:	f012 0f08 	tst.w	r2, #8
 8007744:	d110      	bne.n	8007768 <UART_CheckIdleState+0x3e>
  if ((huart->Instance->CR1 & USART_CR1_RE) == USART_CR1_RE)
 8007746:	6823      	ldr	r3, [r4, #0]
 8007748:	681b      	ldr	r3, [r3, #0]
 800774a:	f013 0f04 	tst.w	r3, #4
 800774e:	d128      	bne.n	80077a2 <UART_CheckIdleState+0x78>
  huart->gState = HAL_UART_STATE_READY;
 8007750:	2320      	movs	r3, #32
 8007752:	f8c4 3088 	str.w	r3, [r4, #136]	@ 0x88
  huart->RxState = HAL_UART_STATE_READY;
 8007756:	f8c4 308c 	str.w	r3, [r4, #140]	@ 0x8c
  huart->ReceptionType = HAL_UART_RECEPTION_STANDARD;
 800775a:	2000      	movs	r0, #0
 800775c:	66e0      	str	r0, [r4, #108]	@ 0x6c
  huart->RxEventType = HAL_UART_RXEVENT_TC;
 800775e:	6720      	str	r0, [r4, #112]	@ 0x70
  __HAL_UNLOCK(huart);
 8007760:	f884 0084 	strb.w	r0, [r4, #132]	@ 0x84
}
 8007764:	b003      	add	sp, #12
 8007766:	bd30      	pop	{r4, r5, pc}
    if (UART_WaitOnFlagUntilTimeout(huart, USART_ISR_TEACK, RESET, tickstart, HAL_UART_TIMEOUT_VALUE) != HAL_OK)
 8007768:	f06f 437e 	mvn.w	r3, #4261412864	@ 0xfe000000
 800776c:	9300      	str	r3, [sp, #0]
 800776e:	4603      	mov	r3, r0
 8007770:	2200      	movs	r2, #0
 8007772:	f44f 1100 	mov.w	r1, #2097152	@ 0x200000
 8007776:	4620      	mov	r0, r4
 8007778:	f7ff ff15 	bl	80075a6 <UART_WaitOnFlagUntilTimeout>
 800777c:	2800      	cmp	r0, #0
 800777e:	d0e2      	beq.n	8007746 <UART_CheckIdleState+0x1c>
      ATOMIC_CLEAR_BIT(huart->Instance->CR1, (USART_CR1_TXEIE_TXFNFIE));
 8007780:	6822      	ldr	r2, [r4, #0]
   __ASM volatile ("ldrex %0, %1" : "=r" (result) : "Q" (*addr) );
 8007782:	e852 3f00 	ldrex	r3, [r2]
 8007786:	f023 0380 	bic.w	r3, r3, #128	@ 0x80
   __ASM volatile ("strex %0, %2, %1" : "=&r" (result), "=Q" (*addr) : "r" (value) );
 800778a:	e842 3100 	strex	r1, r3, [r2]
 800778e:	2900      	cmp	r1, #0
 8007790:	d1f6      	bne.n	8007780 <UART_CheckIdleState+0x56>
      huart->gState = HAL_UART_STATE_READY;
 8007792:	2320      	movs	r3, #32
 8007794:	f8c4 3088 	str.w	r3, [r4, #136]	@ 0x88
      __HAL_UNLOCK(huart);
 8007798:	2300      	movs	r3, #0
 800779a:	f884 3084 	strb.w	r3, [r4, #132]	@ 0x84
      return HAL_TIMEOUT;
 800779e:	2003      	movs	r0, #3
 80077a0:	e7e0      	b.n	8007764 <UART_CheckIdleState+0x3a>
    if (UART_WaitOnFlagUntilTimeout(huart, USART_ISR_REACK, RESET, tickstart, HAL_UART_TIMEOUT_VALUE) != HAL_OK)
 80077a2:	f06f 437e 	mvn.w	r3, #4261412864	@ 0xfe000000
 80077a6:	9300      	str	r3, [sp, #0]
 80077a8:	462b      	mov	r3, r5
 80077aa:	2200      	movs	r2, #0
 80077ac:	f44f 0180 	mov.w	r1, #4194304	@ 0x400000
 80077b0:	4620      	mov	r0, r4
 80077b2:	f7ff fef8 	bl	80075a6 <UART_WaitOnFlagUntilTimeout>
 80077b6:	2800      	cmp	r0, #0
 80077b8:	d0ca      	beq.n	8007750 <UART_CheckIdleState+0x26>
      ATOMIC_CLEAR_BIT(huart->Instance->CR1, (USART_CR1_RXNEIE_RXFNEIE | USART_CR1_PEIE));
 80077ba:	6822      	ldr	r2, [r4, #0]
   __ASM volatile ("ldrex %0, %1" : "=r" (result) : "Q" (*addr) );
 80077bc:	e852 3f00 	ldrex	r3, [r2]
 80077c0:	f423 7390 	bic.w	r3, r3, #288	@ 0x120
   __ASM volatile ("strex %0, %2, %1" : "=&r" (result), "=Q" (*addr) : "r" (value) );
 80077c4:	e842 3100 	strex	r1, r3, [r2]
 80077c8:	2900      	cmp	r1, #0
 80077ca:	d1f6      	bne.n	80077ba <UART_CheckIdleState+0x90>
      ATOMIC_CLEAR_BIT(huart->Instance->CR3, USART_CR3_EIE);
 80077cc:	6822      	ldr	r2, [r4, #0]
   __ASM volatile ("ldrex %0, %1" : "=r" (result) : "Q" (*addr) );
 80077ce:	f102 0308 	add.w	r3, r2, #8
 80077d2:	e853 3f00 	ldrex	r3, [r3]
 80077d6:	f023 0301 	bic.w	r3, r3, #1
   __ASM volatile ("strex %0, %2, %1" : "=&r" (result), "=Q" (*addr) : "r" (value) );
 80077da:	3208      	adds	r2, #8
 80077dc:	e842 3100 	strex	r1, r3, [r2]
 80077e0:	2900      	cmp	r1, #0
 80077e2:	d1f3      	bne.n	80077cc <UART_CheckIdleState+0xa2>
      huart->RxState = HAL_UART_STATE_READY;
 80077e4:	2320      	movs	r3, #32
 80077e6:	f8c4 308c 	str.w	r3, [r4, #140]	@ 0x8c
      __HAL_UNLOCK(huart);
 80077ea:	2300      	movs	r3, #0
 80077ec:	f884 3084 	strb.w	r3, [r4, #132]	@ 0x84
      return HAL_TIMEOUT;
 80077f0:	2003      	movs	r0, #3
 80077f2:	e7b7      	b.n	8007764 <UART_CheckIdleState+0x3a>

080077f4 <HAL_UART_Init>:
  if (huart == NULL)
 80077f4:	b378      	cbz	r0, 8007856 <HAL_UART_Init+0x62>
{
 80077f6:	b510      	push	{r4, lr}
 80077f8:	4604      	mov	r4, r0
  if (huart->gState == HAL_UART_STATE_RESET)
 80077fa:	f8d0 3088 	ldr.w	r3, [r0, #136]	@ 0x88
 80077fe:	b30b      	cbz	r3, 8007844 <HAL_UART_Init+0x50>
  huart->gState = HAL_UART_STATE_BUSY;
 8007800:	2324      	movs	r3, #36	@ 0x24
 8007802:	f8c4 3088 	str.w	r3, [r4, #136]	@ 0x88
  __HAL_UART_DISABLE(huart);
 8007806:	6822      	ldr	r2, [r4, #0]
 8007808:	6813      	ldr	r3, [r2, #0]
 800780a:	f023 0301 	bic.w	r3, r3, #1
 800780e:	6013      	str	r3, [r2, #0]
  if (huart->AdvancedInit.AdvFeatureInit != UART_ADVFEATURE_NO_INIT)
 8007810:	6aa3      	ldr	r3, [r4, #40]	@ 0x28
 8007812:	b9e3      	cbnz	r3, 800784e <HAL_UART_Init+0x5a>
  if (UART_SetConfig(huart) == HAL_ERROR)
 8007814:	4620      	mov	r0, r4
 8007816:	f7ff fd45 	bl	80072a4 <UART_SetConfig>
 800781a:	2801      	cmp	r0, #1
 800781c:	d011      	beq.n	8007842 <HAL_UART_Init+0x4e>
  CLEAR_BIT(huart->Instance->CR2, (USART_CR2_LINEN | USART_CR2_CLKEN));
 800781e:	6822      	ldr	r2, [r4, #0]
 8007820:	6853      	ldr	r3, [r2, #4]
 8007822:	f423 4390 	bic.w	r3, r3, #18432	@ 0x4800
 8007826:	6053      	str	r3, [r2, #4]
  CLEAR_BIT(huart->Instance->CR3, (USART_CR3_SCEN | USART_CR3_HDSEL | USART_CR3_IREN));
 8007828:	6822      	ldr	r2, [r4, #0]
 800782a:	6893      	ldr	r3, [r2, #8]
 800782c:	f023 032a 	bic.w	r3, r3, #42	@ 0x2a
 8007830:	6093      	str	r3, [r2, #8]
  __HAL_UART_ENABLE(huart);
 8007832:	6822      	ldr	r2, [r4, #0]
 8007834:	6813      	ldr	r3, [r2, #0]
 8007836:	f043 0301 	orr.w	r3, r3, #1
 800783a:	6013      	str	r3, [r2, #0]
  return (UART_CheckIdleState(huart));
 800783c:	4620      	mov	r0, r4
 800783e:	f7ff ff74 	bl	800772a <UART_CheckIdleState>
}
 8007842:	bd10      	pop	{r4, pc}
    huart->Lock = HAL_UNLOCKED;
 8007844:	f880 3084 	strb.w	r3, [r0, #132]	@ 0x84
    HAL_UART_MspInit(huart);
 8007848:	f000 f8d2 	bl	80079f0 <HAL_UART_MspInit>
 800784c:	e7d8      	b.n	8007800 <HAL_UART_Init+0xc>
    UART_AdvFeatureConfig(huart);
 800784e:	4620      	mov	r0, r4
 8007850:	f7ff fe44 	bl	80074dc <UART_AdvFeatureConfig>
 8007854:	e7de      	b.n	8007814 <HAL_UART_Init+0x20>
    return HAL_ERROR;
 8007856:	2001      	movs	r0, #1
}
 8007858:	4770      	bx	lr
	...

0800785c <UARTEx_SetNbDataToProcess>:
  uint8_t rx_fifo_threshold;
  uint8_t tx_fifo_threshold;
  static const uint8_t numerator[] = {1U, 1U, 1U, 3U, 7U, 1U, 0U, 0U};
  static const uint8_t denominator[] = {8U, 4U, 2U, 4U, 8U, 1U, 1U, 1U};

  if (huart->FifoMode == UART_FIFOMODE_DISABLE)
 800785c:	6e43      	ldr	r3, [r0, #100]	@ 0x64
 800785e:	b92b      	cbnz	r3, 800786c <UARTEx_SetNbDataToProcess+0x10>
  {
    huart->NbTxDataToProcess = 1U;
 8007860:	2301      	movs	r3, #1
 8007862:	f8a0 306a 	strh.w	r3, [r0, #106]	@ 0x6a
    huart->NbRxDataToProcess = 1U;
 8007866:	f8a0 3068 	strh.w	r3, [r0, #104]	@ 0x68
 800786a:	4770      	bx	lr
{
 800786c:	b430      	push	{r4, r5}
  }
  else
  {
    rx_fifo_depth = RX_FIFO_DEPTH;
    tx_fifo_depth = TX_FIFO_DEPTH;
    rx_fifo_threshold = (uint8_t)(READ_BIT(huart->Instance->CR3, USART_CR3_RXFTCFG) >> USART_CR3_RXFTCFG_Pos);
 800786e:	6803      	ldr	r3, [r0, #0]
 8007870:	689a      	ldr	r2, [r3, #8]
 8007872:	f3c2 6242 	ubfx	r2, r2, #25, #3
    tx_fifo_threshold = (uint8_t)(READ_BIT(huart->Instance->CR3, USART_CR3_TXFTCFG) >> USART_CR3_TXFTCFG_Pos);
 8007876:	6899      	ldr	r1, [r3, #8]
 8007878:	0f49      	lsrs	r1, r1, #29
    huart->NbTxDataToProcess = ((uint16_t)tx_fifo_depth * numerator[tx_fifo_threshold]) /
 800787a:	4d09      	ldr	r5, [pc, #36]	@ (80078a0 <UARTEx_SetNbDataToProcess+0x44>)
 800787c:	5c6b      	ldrb	r3, [r5, r1]
 800787e:	00db      	lsls	r3, r3, #3
                               (uint16_t)denominator[tx_fifo_threshold];
 8007880:	4c08      	ldr	r4, [pc, #32]	@ (80078a4 <UARTEx_SetNbDataToProcess+0x48>)
 8007882:	5c61      	ldrb	r1, [r4, r1]
    huart->NbTxDataToProcess = ((uint16_t)tx_fifo_depth * numerator[tx_fifo_threshold]) /
 8007884:	fb93 f3f1 	sdiv	r3, r3, r1
 8007888:	f8a0 306a 	strh.w	r3, [r0, #106]	@ 0x6a
    huart->NbRxDataToProcess = ((uint16_t)rx_fifo_depth * numerator[rx_fifo_threshold]) /
 800788c:	5cab      	ldrb	r3, [r5, r2]
 800788e:	00db      	lsls	r3, r3, #3
                               (uint16_t)denominator[rx_fifo_threshold];
 8007890:	5ca2      	ldrb	r2, [r4, r2]
    huart->NbRxDataToProcess = ((uint16_t)rx_fifo_depth * numerator[rx_fifo_threshold]) /
 8007892:	fb93 f3f2 	sdiv	r3, r3, r2
 8007896:	f8a0 3068 	strh.w	r3, [r0, #104]	@ 0x68
  }
}
 800789a:	bc30      	pop	{r4, r5}
 800789c:	4770      	bx	lr
 800789e:	bf00      	nop
 80078a0:	08009284 	.word	0x08009284
 80078a4:	0800927c 	.word	0x0800927c

080078a8 <HAL_UARTEx_DisableFifoMode>:
  __HAL_LOCK(huart);
 80078a8:	f890 3084 	ldrb.w	r3, [r0, #132]	@ 0x84
 80078ac:	2b01      	cmp	r3, #1
 80078ae:	d018      	beq.n	80078e2 <HAL_UARTEx_DisableFifoMode+0x3a>
 80078b0:	2301      	movs	r3, #1
 80078b2:	f880 3084 	strb.w	r3, [r0, #132]	@ 0x84
  huart->gState = HAL_UART_STATE_BUSY;
 80078b6:	2324      	movs	r3, #36	@ 0x24
 80078b8:	f8c0 3088 	str.w	r3, [r0, #136]	@ 0x88
  tmpcr1 = READ_REG(huart->Instance->CR1);
 80078bc:	6803      	ldr	r3, [r0, #0]
 80078be:	681a      	ldr	r2, [r3, #0]
  __HAL_UART_DISABLE(huart);
 80078c0:	6819      	ldr	r1, [r3, #0]
 80078c2:	f021 0101 	bic.w	r1, r1, #1
 80078c6:	6019      	str	r1, [r3, #0]
  CLEAR_BIT(tmpcr1, USART_CR1_FIFOEN);
 80078c8:	f022 5200 	bic.w	r2, r2, #536870912	@ 0x20000000
  huart->FifoMode = UART_FIFOMODE_DISABLE;
 80078cc:	2300      	movs	r3, #0
 80078ce:	6643      	str	r3, [r0, #100]	@ 0x64
  WRITE_REG(huart->Instance->CR1, tmpcr1);
 80078d0:	6801      	ldr	r1, [r0, #0]
 80078d2:	600a      	str	r2, [r1, #0]
  huart->gState = HAL_UART_STATE_READY;
 80078d4:	2220      	movs	r2, #32
 80078d6:	f8c0 2088 	str.w	r2, [r0, #136]	@ 0x88
  __HAL_UNLOCK(huart);
 80078da:	f880 3084 	strb.w	r3, [r0, #132]	@ 0x84
  return HAL_OK;
 80078de:	4618      	mov	r0, r3
 80078e0:	4770      	bx	lr
  __HAL_LOCK(huart);
 80078e2:	2002      	movs	r0, #2
}
 80078e4:	4770      	bx	lr

080078e6 <HAL_UARTEx_SetTxFifoThreshold>:
{
 80078e6:	b538      	push	{r3, r4, r5, lr}
  __HAL_LOCK(huart);
 80078e8:	f890 3084 	ldrb.w	r3, [r0, #132]	@ 0x84
 80078ec:	2b01      	cmp	r3, #1
 80078ee:	d01d      	beq.n	800792c <HAL_UARTEx_SetTxFifoThreshold+0x46>
 80078f0:	4604      	mov	r4, r0
 80078f2:	2301      	movs	r3, #1
 80078f4:	f880 3084 	strb.w	r3, [r0, #132]	@ 0x84
  huart->gState = HAL_UART_STATE_BUSY;
 80078f8:	2324      	movs	r3, #36	@ 0x24
 80078fa:	f8c0 3088 	str.w	r3, [r0, #136]	@ 0x88
  tmpcr1 = READ_REG(huart->Instance->CR1);
 80078fe:	6803      	ldr	r3, [r0, #0]
 8007900:	681d      	ldr	r5, [r3, #0]
  __HAL_UART_DISABLE(huart);
 8007902:	681a      	ldr	r2, [r3, #0]
 8007904:	f022 0201 	bic.w	r2, r2, #1
 8007908:	601a      	str	r2, [r3, #0]
  MODIFY_REG(huart->Instance->CR3, USART_CR3_TXFTCFG, Threshold);
 800790a:	6802      	ldr	r2, [r0, #0]
 800790c:	6893      	ldr	r3, [r2, #8]
 800790e:	f023 4360 	bic.w	r3, r3, #3758096384	@ 0xe0000000
 8007912:	4319      	orrs	r1, r3
 8007914:	6091      	str	r1, [r2, #8]
  UARTEx_SetNbDataToProcess(huart);
 8007916:	f7ff ffa1 	bl	800785c <UARTEx_SetNbDataToProcess>
  WRITE_REG(huart->Instance->CR1, tmpcr1);
 800791a:	6823      	ldr	r3, [r4, #0]
 800791c:	601d      	str	r5, [r3, #0]
  huart->gState = HAL_UART_STATE_READY;
 800791e:	2320      	movs	r3, #32
 8007920:	f8c4 3088 	str.w	r3, [r4, #136]	@ 0x88
  __HAL_UNLOCK(huart);
 8007924:	2000      	movs	r0, #0
 8007926:	f884 0084 	strb.w	r0, [r4, #132]	@ 0x84
}
 800792a:	bd38      	pop	{r3, r4, r5, pc}
  __HAL_LOCK(huart);
 800792c:	2002      	movs	r0, #2
 800792e:	e7fc      	b.n	800792a <HAL_UARTEx_SetTxFifoThreshold+0x44>

08007930 <HAL_UARTEx_SetRxFifoThreshold>:
{
 8007930:	b538      	push	{r3, r4, r5, lr}
  __HAL_LOCK(huart);
 8007932:	f890 3084 	ldrb.w	r3, [r0, #132]	@ 0x84
 8007936:	2b01      	cmp	r3, #1
 8007938:	d01d      	beq.n	8007976 <HAL_UARTEx_SetRxFifoThreshold+0x46>
 800793a:	4604      	mov	r4, r0
 800793c:	2301      	movs	r3, #1
 800793e:	f880 3084 	strb.w	r3, [r0, #132]	@ 0x84
  huart->gState = HAL_UART_STATE_BUSY;
 8007942:	2324      	movs	r3, #36	@ 0x24
 8007944:	f8c0 3088 	str.w	r3, [r0, #136]	@ 0x88
  tmpcr1 = READ_REG(huart->Instance->CR1);
 8007948:	6803      	ldr	r3, [r0, #0]
 800794a:	681d      	ldr	r5, [r3, #0]
  __HAL_UART_DISABLE(huart);
 800794c:	681a      	ldr	r2, [r3, #0]
 800794e:	f022 0201 	bic.w	r2, r2, #1
 8007952:	601a      	str	r2, [r3, #0]
  MODIFY_REG(huart->Instance->CR3, USART_CR3_RXFTCFG, Threshold);
 8007954:	6802      	ldr	r2, [r0, #0]
 8007956:	6893      	ldr	r3, [r2, #8]
 8007958:	f023 6360 	bic.w	r3, r3, #234881024	@ 0xe000000
 800795c:	4319      	orrs	r1, r3
 800795e:	6091      	str	r1, [r2, #8]
  UARTEx_SetNbDataToProcess(huart);
 8007960:	f7ff ff7c 	bl	800785c <UARTEx_SetNbDataToProcess>
  WRITE_REG(huart->Instance->CR1, tmpcr1);
 8007964:	6823      	ldr	r3, [r4, #0]
 8007966:	601d      	str	r5, [r3, #0]
  huart->gState = HAL_UART_STATE_READY;
 8007968:	2320      	movs	r3, #32
 800796a:	f8c4 3088 	str.w	r3, [r4, #136]	@ 0x88
  __HAL_UNLOCK(huart);
 800796e:	2000      	movs	r0, #0
 8007970:	f884 0084 	strb.w	r0, [r4, #132]	@ 0x84
}
 8007974:	bd38      	pop	{r3, r4, r5, pc}
  __HAL_LOCK(huart);
 8007976:	2002      	movs	r0, #2
 8007978:	e7fc      	b.n	8007974 <HAL_UARTEx_SetRxFifoThreshold+0x44>

0800797a <hal_uart1_init>:
#include "platform_driver.h"

void hal_uart1_init(void)
{
 800797a:	b508      	push	{r3, lr}
    platform_uart1_init();
 800797c:	f000 f812 	bl	80079a4 <platform_uart1_init>
 8007980:	bd08      	pop	{r3, pc}

08007982 <hal_system_clock_pre_init>:
#else
#error "Unsupported platform"
#endif

void hal_system_clock_pre_init()
{
 8007982:	b508      	push	{r3, lr}
    platform_system_clock_pre_init();
 8007984:	f000 f892 	bl	8007aac <platform_system_clock_pre_init>
}
 8007988:	bd08      	pop	{r3, pc}

0800798a <hal_system_clock_init>:

void hal_system_clock_init()
{
 800798a:	b508      	push	{r3, lr}
    platform_system_clock_init();
 800798c:	f000 f892 	bl	8007ab4 <platform_system_clock_init>
}
 8007990:	bd08      	pop	{r3, pc}

08007992 <hal_system_sdk_init>:

void hal_system_sdk_init()
{
 8007992:	b508      	push	{r3, lr}
    platform_sdk_init();
 8007994:	f000 f882 	bl	8007a9c <platform_sdk_init>
}
 8007998:	bd08      	pop	{r3, pc}

0800799a <hal_system_get_systemhandler>:

void (*hal_system_get_systemhandler(void))(void)
{
 800799a:	b508      	push	{r3, lr}
    return platform_get_sytemtick_handler();
 800799c:	f000 f882 	bl	8007aa4 <platform_get_sytemtick_handler>
 80079a0:	bd08      	pop	{r3, pc}
	...

080079a4 <platform_uart1_init>:
UART_HandleTypeDef huart1;

/* USART1 init function */

void platform_uart1_init(void)
{
 80079a4:	b538      	push	{r3, r4, r5, lr}

    huart1.Instance = USART1;
 80079a6:	4c10      	ldr	r4, [pc, #64]	@ (80079e8 <platform_uart1_init+0x44>)
 80079a8:	4b10      	ldr	r3, [pc, #64]	@ (80079ec <platform_uart1_init+0x48>)
 80079aa:	6023      	str	r3, [r4, #0]
    huart1.Init.BaudRate = 115200;
 80079ac:	f44f 33e1 	mov.w	r3, #115200	@ 0x1c200
 80079b0:	6063      	str	r3, [r4, #4]
    huart1.Init.WordLength = UART_WORDLENGTH_8B;
 80079b2:	2500      	movs	r5, #0
 80079b4:	60a5      	str	r5, [r4, #8]
    huart1.Init.StopBits = UART_STOPBITS_1;
 80079b6:	60e5      	str	r5, [r4, #12]
    huart1.Init.Parity = UART_PARITY_NONE;
 80079b8:	6125      	str	r5, [r4, #16]
    huart1.Init.Mode = UART_MODE_TX_RX;
 80079ba:	230c      	movs	r3, #12
 80079bc:	6163      	str	r3, [r4, #20]
    huart1.Init.HwFlowCtl = UART_HWCONTROL_NONE;
 80079be:	61a5      	str	r5, [r4, #24]
    huart1.Init.OverSampling = UART_OVERSAMPLING_16;
 80079c0:	61e5      	str	r5, [r4, #28]
    huart1.Init.OneBitSampling = UART_ONE_BIT_SAMPLE_DISABLE;
 80079c2:	6225      	str	r5, [r4, #32]
    huart1.Init.ClockPrescaler = UART_PRESCALER_DIV1;
 80079c4:	6265      	str	r5, [r4, #36]	@ 0x24
    huart1.AdvancedInit.AdvFeatureInit = UART_ADVFEATURE_NO_INIT;
 80079c6:	62a5      	str	r5, [r4, #40]	@ 0x28
    if (HAL_UART_Init(&huart1) != HAL_OK)
 80079c8:	4620      	mov	r0, r4
 80079ca:	f7ff ff13 	bl	80077f4 <HAL_UART_Init>
    {
        // Error_Handler();
    }
    if (HAL_UARTEx_SetTxFifoThreshold(&huart1, UART_TXFIFO_THRESHOLD_1_8) != HAL_OK)
 80079ce:	4629      	mov	r1, r5
 80079d0:	4620      	mov	r0, r4
 80079d2:	f7ff ff88 	bl	80078e6 <HAL_UARTEx_SetTxFifoThreshold>
    {
        // Error_Handler();
    }
    if (HAL_UARTEx_SetRxFifoThreshold(&huart1, UART_RXFIFO_THRESHOLD_1_8) != HAL_OK)
 80079d6:	4629      	mov	r1, r5
 80079d8:	4620      	mov	r0, r4
 80079da:	f7ff ffa9 	bl	8007930 <HAL_UARTEx_SetRxFifoThreshold>
    {
        // Error_Handler();
    }
    if (HAL_UARTEx_DisableFifoMode(&huart1) != HAL_OK)
 80079de:	4620      	mov	r0, r4
 80079e0:	f7ff ff62 	bl	80078a8 <HAL_UARTEx_DisableFifoMode>
    {
        // Error_Handler();
    }
}
 80079e4:	bd38      	pop	{r3, r4, r5, pc}
 80079e6:	bf00      	nop
 80079e8:	200040a0 	.word	0x200040a0
 80079ec:	40013800 	.word	0x40013800

080079f0 <HAL_UART_MspInit>:

void HAL_UART_MspInit(UART_HandleTypeDef *uartHandle)
{
 80079f0:	b510      	push	{r4, lr}
 80079f2:	b0ca      	sub	sp, #296	@ 0x128
 80079f4:	4604      	mov	r4, r0

    GPIO_InitTypeDef GPIO_InitStruct = {0};
 80079f6:	2100      	movs	r1, #0
 80079f8:	9145      	str	r1, [sp, #276]	@ 0x114
 80079fa:	9146      	str	r1, [sp, #280]	@ 0x118
 80079fc:	9147      	str	r1, [sp, #284]	@ 0x11c
 80079fe:	9148      	str	r1, [sp, #288]	@ 0x120
 8007a00:	9149      	str	r1, [sp, #292]	@ 0x124
    RCC_PeriphCLKInitTypeDef PeriphClkInitStruct = {0};
 8007a02:	f44f 7284 	mov.w	r2, #264	@ 0x108
 8007a06:	a802      	add	r0, sp, #8
 8007a08:	f000 f97c 	bl	8007d04 <memset>
    if (uartHandle->Instance == USART1)
 8007a0c:	6822      	ldr	r2, [r4, #0]
 8007a0e:	4b1a      	ldr	r3, [pc, #104]	@ (8007a78 <HAL_UART_MspInit+0x88>)
 8007a10:	429a      	cmp	r2, r3
 8007a12:	d001      	beq.n	8007a18 <HAL_UART_MspInit+0x28>

        /* USER CODE BEGIN USART1_MspInit 1 */

        /* USER CODE END USART1_MspInit 1 */
    }
}
 8007a14:	b04a      	add	sp, #296	@ 0x128
 8007a16:	bd10      	pop	{r4, pc}
        PeriphClkInitStruct.PeriphClockSelection = RCC_PERIPHCLK_USART1;
 8007a18:	2201      	movs	r2, #1
 8007a1a:	2300      	movs	r3, #0
 8007a1c:	e9cd 2302 	strd	r2, r3, [sp, #8]
        if (HAL_RCCEx_PeriphCLKConfig(&PeriphClkInitStruct) != HAL_OK)
 8007a20:	a802      	add	r0, sp, #8
 8007a22:	f7fc f859 	bl	8003ad8 <HAL_RCCEx_PeriphCLKConfig>
        __HAL_RCC_USART1_CLK_ENABLE();
 8007a26:	4b15      	ldr	r3, [pc, #84]	@ (8007a7c <HAL_UART_MspInit+0x8c>)
 8007a28:	f8d3 20a4 	ldr.w	r2, [r3, #164]	@ 0xa4
 8007a2c:	f442 4280 	orr.w	r2, r2, #16384	@ 0x4000
 8007a30:	f8c3 20a4 	str.w	r2, [r3, #164]	@ 0xa4
 8007a34:	f8d3 20a4 	ldr.w	r2, [r3, #164]	@ 0xa4
 8007a38:	f402 4280 	and.w	r2, r2, #16384	@ 0x4000
 8007a3c:	9200      	str	r2, [sp, #0]
 8007a3e:	9a00      	ldr	r2, [sp, #0]
        __HAL_RCC_GPIOA_CLK_ENABLE();
 8007a40:	f8d3 208c 	ldr.w	r2, [r3, #140]	@ 0x8c
 8007a44:	f042 0201 	orr.w	r2, r2, #1
 8007a48:	f8c3 208c 	str.w	r2, [r3, #140]	@ 0x8c
 8007a4c:	f8d3 308c 	ldr.w	r3, [r3, #140]	@ 0x8c
 8007a50:	f003 0301 	and.w	r3, r3, #1
 8007a54:	9301      	str	r3, [sp, #4]
 8007a56:	9b01      	ldr	r3, [sp, #4]
        GPIO_InitStruct.Pin = GPIO_PIN_9 | GPIO_PIN_10;
 8007a58:	f44f 63c0 	mov.w	r3, #1536	@ 0x600
 8007a5c:	9345      	str	r3, [sp, #276]	@ 0x114
        GPIO_InitStruct.Mode = GPIO_MODE_AF_PP;
 8007a5e:	2302      	movs	r3, #2
 8007a60:	9346      	str	r3, [sp, #280]	@ 0x118
        GPIO_InitStruct.Pull = GPIO_NOPULL;
 8007a62:	2300      	movs	r3, #0
 8007a64:	9347      	str	r3, [sp, #284]	@ 0x11c
        GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
 8007a66:	9348      	str	r3, [sp, #288]	@ 0x120
        GPIO_InitStruct.Alternate = GPIO_AF7_USART1;
 8007a68:	2307      	movs	r3, #7
 8007a6a:	9349      	str	r3, [sp, #292]	@ 0x124
        HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);
 8007a6c:	a945      	add	r1, sp, #276	@ 0x114
 8007a6e:	4804      	ldr	r0, [pc, #16]	@ (8007a80 <HAL_UART_MspInit+0x90>)
 8007a70:	f7ff fa5e 	bl	8006f30 <HAL_GPIO_Init>
}
 8007a74:	e7ce      	b.n	8007a14 <HAL_UART_MspInit+0x24>
 8007a76:	bf00      	nop
 8007a78:	40013800 	.word	0x40013800
 8007a7c:	44020c00 	.word	0x44020c00
 8007a80:	42020000 	.word	0x42020000

08007a84 <tt>:
        /* USER CODE END USART1_MspDeInit 1 */
    }
}

void tt(char *str, int size)
{
 8007a84:	b508      	push	{r3, lr}
    
    HAL_UART_Transmit(&huart1, str, size, 0xfffff);
 8007a86:	4b03      	ldr	r3, [pc, #12]	@ (8007a94 <tt+0x10>)
 8007a88:	b28a      	uxth	r2, r1
 8007a8a:	4601      	mov	r1, r0
 8007a8c:	4802      	ldr	r0, [pc, #8]	@ (8007a98 <tt+0x14>)
 8007a8e:	f7ff fdd9 	bl	8007644 <HAL_UART_Transmit>
}
 8007a92:	bd08      	pop	{r3, pc}
 8007a94:	000fffff 	.word	0x000fffff
 8007a98:	200040a0 	.word	0x200040a0

08007a9c <platform_sdk_init>:
#include "stm32h5xx_hal_rcc.h"
#include "stm32h5xx_hal_cortex.h"
#include <stddef.h>

void platform_sdk_init()
{
 8007a9c:	b508      	push	{r3, lr}
    HAL_Init();
 8007a9e:	f7fb f93f 	bl	8002d20 <HAL_Init>
}
 8007aa2:	bd08      	pop	{r3, pc}

08007aa4 <platform_get_sytemtick_handler>:

void (*platform_get_sytemtick_handler(void))(void)
{
    return HAL_IncTick;
}
 8007aa4:	4800      	ldr	r0, [pc, #0]	@ (8007aa8 <platform_get_sytemtick_handler+0x4>)
 8007aa6:	4770      	bx	lr
 8007aa8:	08002d69 	.word	0x08002d69

08007aac <platform_system_clock_pre_init>:
/*------------------------------------------------------------------------------
 * System Clock
 *----------------------------------------------------------------------------*/

void platform_system_clock_pre_init()
{
 8007aac:	b508      	push	{r3, lr}
    SystemInit();
 8007aae:	f7f8 ff8d 	bl	80009cc <SystemInit>
}
 8007ab2:	bd08      	pop	{r3, pc}

08007ab4 <platform_system_clock_init>:

uint32_t platform_system_clock_init()
{
 8007ab4:	b510      	push	{r4, lr}
 8007ab6:	b09e      	sub	sp, #120	@ 0x78

    RCC_OscInitTypeDef RCC_OscInitStruct = {0};
 8007ab8:	2250      	movs	r2, #80	@ 0x50
 8007aba:	2100      	movs	r1, #0
 8007abc:	a80a      	add	r0, sp, #40	@ 0x28
 8007abe:	f000 f921 	bl	8007d04 <memset>
    RCC_ClkInitTypeDef RCC_ClkInitStruct = {0};
 8007ac2:	2300      	movs	r3, #0
 8007ac4:	9304      	str	r3, [sp, #16]
 8007ac6:	9305      	str	r3, [sp, #20]
 8007ac8:	9306      	str	r3, [sp, #24]
 8007aca:	9307      	str	r3, [sp, #28]
 8007acc:	9308      	str	r3, [sp, #32]
 8007ace:	9309      	str	r3, [sp, #36]	@ 0x24

    /** Configure the main internal regulator output voltage
     */
    __HAL_PWR_VOLTAGESCALING_CONFIG(PWR_REGULATOR_VOLTAGE_SCALE0);
 8007ad0:	4b2d      	ldr	r3, [pc, #180]	@ (8007b88 <platform_system_clock_init+0xd4>)
 8007ad2:	691a      	ldr	r2, [r3, #16]
 8007ad4:	f042 0230 	orr.w	r2, r2, #48	@ 0x30
 8007ad8:	611a      	str	r2, [r3, #16]
 8007ada:	691b      	ldr	r3, [r3, #16]
 8007adc:	f003 0330 	and.w	r3, r3, #48	@ 0x30
 8007ae0:	9301      	str	r3, [sp, #4]
 8007ae2:	9b01      	ldr	r3, [sp, #4]

    while (!__HAL_PWR_GET_FLAG(PWR_FLAG_VOSRDY))
 8007ae4:	4b28      	ldr	r3, [pc, #160]	@ (8007b88 <platform_system_clock_init+0xd4>)
 8007ae6:	695b      	ldr	r3, [r3, #20]
 8007ae8:	f013 0f08 	tst.w	r3, #8
 8007aec:	d0fa      	beq.n	8007ae4 <platform_system_clock_init+0x30>
    }

    /** Initializes the RCC Oscillators according to the specified parameters
     * in the RCC_OscInitTypeDef structure.
     */
    RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_CSI;
 8007aee:	2310      	movs	r3, #16
 8007af0:	930a      	str	r3, [sp, #40]	@ 0x28
    RCC_OscInitStruct.CSIState = RCC_CSI_ON;
 8007af2:	f44f 7380 	mov.w	r3, #256	@ 0x100
 8007af6:	9311      	str	r3, [sp, #68]	@ 0x44
    RCC_OscInitStruct.CSICalibrationValue = RCC_CSICALIBRATION_DEFAULT;
 8007af8:	2320      	movs	r3, #32
 8007afa:	9312      	str	r3, [sp, #72]	@ 0x48
    RCC_OscInitStruct.PLL.PLLState = RCC_PLL_ON;
 8007afc:	2302      	movs	r3, #2
 8007afe:	9314      	str	r3, [sp, #80]	@ 0x50
    RCC_OscInitStruct.PLL.PLLSource = RCC_PLL1_SOURCE_CSI;
 8007b00:	9315      	str	r3, [sp, #84]	@ 0x54
    RCC_OscInitStruct.PLL.PLLM = 2;
 8007b02:	9316      	str	r3, [sp, #88]	@ 0x58
    RCC_OscInitStruct.PLL.PLLN = 250;
 8007b04:	22fa      	movs	r2, #250	@ 0xfa
 8007b06:	9217      	str	r2, [sp, #92]	@ 0x5c
    RCC_OscInitStruct.PLL.PLLP = 2;
 8007b08:	9318      	str	r3, [sp, #96]	@ 0x60
    RCC_OscInitStruct.PLL.PLLQ = 2;
 8007b0a:	9319      	str	r3, [sp, #100]	@ 0x64
    RCC_OscInitStruct.PLL.PLLR = 2;
 8007b0c:	931a      	str	r3, [sp, #104]	@ 0x68
    RCC_OscInitStruct.PLL.PLLRGE = RCC_PLL1_VCIRANGE_1;
 8007b0e:	2304      	movs	r3, #4
 8007b10:	931b      	str	r3, [sp, #108]	@ 0x6c
    RCC_OscInitStruct.PLL.PLLVCOSEL = RCC_PLL1_VCORANGE_WIDE;
 8007b12:	2400      	movs	r4, #0
 8007b14:	941c      	str	r4, [sp, #112]	@ 0x70
    RCC_OscInitStruct.PLL.PLLFRACN = 0;
 8007b16:	941d      	str	r4, [sp, #116]	@ 0x74
    if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK)
 8007b18:	a80a      	add	r0, sp, #40	@ 0x28
 8007b1a:	f7fb fb85 	bl	8003228 <HAL_RCC_OscConfig>
        // Error_Handler();
    }

    /** Initializes the CPU, AHB and APB buses clocks
     */
    RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK | RCC_CLOCKTYPE_SYSCLK | RCC_CLOCKTYPE_PCLK1 | RCC_CLOCKTYPE_PCLK2 | RCC_CLOCKTYPE_PCLK3;
 8007b1e:	231f      	movs	r3, #31
 8007b20:	9304      	str	r3, [sp, #16]
    RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
 8007b22:	2303      	movs	r3, #3
 8007b24:	9305      	str	r3, [sp, #20]
    RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
 8007b26:	9406      	str	r4, [sp, #24]
    RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV1;
 8007b28:	9407      	str	r4, [sp, #28]
    RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV1;
 8007b2a:	9408      	str	r4, [sp, #32]
    RCC_ClkInitStruct.APB3CLKDivider = RCC_HCLK_DIV1;
 8007b2c:	9409      	str	r4, [sp, #36]	@ 0x24

    if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_5) != HAL_OK)
 8007b2e:	2105      	movs	r1, #5
 8007b30:	a804      	add	r0, sp, #16
 8007b32:	f7fb fa17 	bl	8002f64 <HAL_RCC_ClockConfig>
        // Error_Handler();
    }

    /** Configure the programming delay
     */
    __HAL_FLASH_SET_PROGRAM_DELAY(FLASH_PROGRAMMING_DELAY_2);
 8007b36:	4a15      	ldr	r2, [pc, #84]	@ (8007b8c <platform_system_clock_init+0xd8>)
 8007b38:	6813      	ldr	r3, [r2, #0]
 8007b3a:	f023 0330 	bic.w	r3, r3, #48	@ 0x30
 8007b3e:	f043 0320 	orr.w	r3, r3, #32
 8007b42:	6013      	str	r3, [r2, #0]

    /* GPIO Ports Clock Enable */
    __HAL_RCC_GPIOH_CLK_ENABLE();
 8007b44:	4b12      	ldr	r3, [pc, #72]	@ (8007b90 <platform_system_clock_init+0xdc>)
 8007b46:	f8d3 208c 	ldr.w	r2, [r3, #140]	@ 0x8c
 8007b4a:	f042 0280 	orr.w	r2, r2, #128	@ 0x80
 8007b4e:	f8c3 208c 	str.w	r2, [r3, #140]	@ 0x8c
 8007b52:	f8d3 208c 	ldr.w	r2, [r3, #140]	@ 0x8c
 8007b56:	f002 0280 	and.w	r2, r2, #128	@ 0x80
 8007b5a:	9202      	str	r2, [sp, #8]
 8007b5c:	9a02      	ldr	r2, [sp, #8]
    __HAL_RCC_GPIOA_CLK_ENABLE();
 8007b5e:	f8d3 208c 	ldr.w	r2, [r3, #140]	@ 0x8c
 8007b62:	f042 0201 	orr.w	r2, r2, #1
 8007b66:	f8c3 208c 	str.w	r2, [r3, #140]	@ 0x8c
 8007b6a:	f8d3 308c 	ldr.w	r3, [r3, #140]	@ 0x8c
 8007b6e:	f003 0301 	and.w	r3, r3, #1
 8007b72:	9303      	str	r3, [sp, #12]
 8007b74:	9b03      	ldr	r3, [sp, #12]

    if (HAL_ICACHE_ConfigAssociativityMode(ICACHE_1WAY) != HAL_OK)
 8007b76:	4620      	mov	r0, r4
 8007b78:	f7ff fb4c 	bl	8007214 <HAL_ICACHE_ConfigAssociativityMode>
    {
        // Error_Handler();
    }
    if (HAL_ICACHE_Enable() != HAL_OK)
 8007b7c:	f7ff fb5c 	bl	8007238 <HAL_ICACHE_Enable>
    }
    /* USER CODE BEGIN ICACHE_Init 2 */

    /* USER CODE END ICACHE_Init 2 */
    return 0;
}
 8007b80:	4620      	mov	r0, r4
 8007b82:	b01e      	add	sp, #120	@ 0x78
 8007b84:	bd10      	pop	{r4, pc}
 8007b86:	bf00      	nop
 8007b88:	44020800 	.word	0x44020800
 8007b8c:	40022000 	.word	0x40022000
 8007b90:	44020c00 	.word	0x44020c00

08007b94 <osal_system_get_systemtick_handler_callback>:
#include "osal_port.h"

void (*osal_system_get_systemtick_handler_callback(void))(void)
{
 8007b94:	b508      	push	{r3, lr}
    return osal_get_need_register_to_systemtick_hander_callback_ll();
 8007b96:	f000 f805 	bl	8007ba4 <osal_get_need_register_to_systemtick_hander_callback_ll>
}
 8007b9a:	bd08      	pop	{r3, pc}

08007b9c <osal_register_callback>:

void osal_register_callback(void (*callback)(void))
{
 8007b9c:	b508      	push	{r3, lr}
    osal_register_callback_ll(callback);
 8007b9e:	f000 f805 	bl	8007bac <osal_register_callback_ll>
}
 8007ba2:	bd08      	pop	{r3, pc}

08007ba4 <osal_get_need_register_to_systemtick_hander_callback_ll>:
}
extern void rt_os_tick_callback(void);
void (*osal_get_need_register_to_systemtick_hander_callback_ll(void))(void)
{
    return rt_os_tick_callback;
}
 8007ba4:	4800      	ldr	r0, [pc, #0]	@ (8007ba8 <osal_get_need_register_to_systemtick_hander_callback_ll+0x4>)
 8007ba6:	4770      	bx	lr
 8007ba8:	08002c21 	.word	0x08002c21

08007bac <osal_register_callback_ll>:
extern void rt_register_callback(void (*callback)(void));
void osal_register_callback_ll(void (*callback)(void))
{
 8007bac:	b508      	push	{r3, lr}
    rt_register_callback(callback);
 8007bae:	f7fb f83f 	bl	8002c30 <rt_register_callback>
}
 8007bb2:	bd08      	pop	{r3, pc}

08007bb4 <framework_system_tick_handler>:
 * @brief this function is interrupt function , it will hanler system tick
 */
typedef void (*system_tick_inc_fun)(void);
static system_tick_inc_fun system_tick_callback[2];
void framework_system_tick_handler()
{
 8007bb4:	b510      	push	{r4, lr}
    for (uint8_t i = 0; i < 2; i++)
 8007bb6:	2400      	movs	r4, #0
 8007bb8:	e001      	b.n	8007bbe <framework_system_tick_handler+0xa>
 8007bba:	3401      	adds	r4, #1
 8007bbc:	b2e4      	uxtb	r4, r4
 8007bbe:	2c01      	cmp	r4, #1
 8007bc0:	d806      	bhi.n	8007bd0 <framework_system_tick_handler+0x1c>
    {
        if (system_tick_callback[i] != NULL)
 8007bc2:	4b04      	ldr	r3, [pc, #16]	@ (8007bd4 <framework_system_tick_handler+0x20>)
 8007bc4:	f853 3024 	ldr.w	r3, [r3, r4, lsl #2]
 8007bc8:	2b00      	cmp	r3, #0
 8007bca:	d0f6      	beq.n	8007bba <framework_system_tick_handler+0x6>
        {
            system_tick_callback[i]();
 8007bcc:	4798      	blx	r3
 8007bce:	e7f4      	b.n	8007bba <framework_system_tick_handler+0x6>
        }
    }
}
 8007bd0:	bd10      	pop	{r4, pc}
 8007bd2:	bf00      	nop
 8007bd4:	20004134 	.word	0x20004134

08007bd8 <framework_system_clock_init>:
{
 8007bd8:	b508      	push	{r3, lr}
    hal_system_clock_pre_init();
 8007bda:	f7ff fed2 	bl	8007982 <hal_system_clock_pre_init>
}
 8007bde:	bd08      	pop	{r3, pc}

08007be0 <framework_data_init>:
    uint32_t *dst = (uint32_t *)&_sdata;
 8007be0:	4b0e      	ldr	r3, [pc, #56]	@ (8007c1c <framework_data_init+0x3c>)
    uint32_t *src = (uint32_t *)&_sidata;
 8007be2:	4a0f      	ldr	r2, [pc, #60]	@ (8007c20 <framework_data_init+0x40>)
    while (dst < end)
 8007be4:	e003      	b.n	8007bee <framework_data_init+0xe>
        *dst++ = *src++;
 8007be6:	f852 1b04 	ldr.w	r1, [r2], #4
 8007bea:	f843 1b04 	str.w	r1, [r3], #4
    while (dst < end)
 8007bee:	490d      	ldr	r1, [pc, #52]	@ (8007c24 <framework_data_init+0x44>)
 8007bf0:	428b      	cmp	r3, r1
 8007bf2:	d3f8      	bcc.n	8007be6 <framework_data_init+0x6>
    dst = (uint32_t *)&_sramcode;
 8007bf4:	4b0c      	ldr	r3, [pc, #48]	@ (8007c28 <framework_data_init+0x48>)
    src = (uint32_t *)&_siramcode;
 8007bf6:	4a0d      	ldr	r2, [pc, #52]	@ (8007c2c <framework_data_init+0x4c>)
 8007bf8:	e003      	b.n	8007c02 <framework_data_init+0x22>
        *dst++ = *src++;
 8007bfa:	f852 1b04 	ldr.w	r1, [r2], #4
 8007bfe:	f843 1b04 	str.w	r1, [r3], #4
    while (dst < end)
 8007c02:	490b      	ldr	r1, [pc, #44]	@ (8007c30 <framework_data_init+0x50>)
 8007c04:	428b      	cmp	r3, r1
 8007c06:	d3f8      	bcc.n	8007bfa <framework_data_init+0x1a>
    uint32_t *bss_start = (uint32_t *)&_sbss;
 8007c08:	4b0a      	ldr	r3, [pc, #40]	@ (8007c34 <framework_data_init+0x54>)
 8007c0a:	e002      	b.n	8007c12 <framework_data_init+0x32>
        *bss_start++ = 0;
 8007c0c:	2200      	movs	r2, #0
 8007c0e:	f843 2b04 	str.w	r2, [r3], #4
    while (bss_start < bss_end)
 8007c12:	4a09      	ldr	r2, [pc, #36]	@ (8007c38 <framework_data_init+0x58>)
 8007c14:	4293      	cmp	r3, r2
 8007c16:	d3f9      	bcc.n	8007c0c <framework_data_init+0x2c>
}
 8007c18:	4770      	bx	lr
 8007c1a:	bf00      	nop
 8007c1c:	20000000 	.word	0x20000000
 8007c20:	080092c8 	.word	0x080092c8
 8007c24:	20000098 	.word	0x20000098
 8007c28:	20000098 	.word	0x20000098
 8007c2c:	08009360 	.word	0x08009360
 8007c30:	20000098 	.word	0x20000098
 8007c34:	20000098 	.word	0x20000098
 8007c38:	2000451c 	.word	0x2000451c

08007c3c <framework_system_tick_callback_register>:

void framework_system_tick_callback_register(system_tick_inc_fun callback)
{
    for (uint8_t i = 0; i < 2; i++)
 8007c3c:	2300      	movs	r3, #0
 8007c3e:	2b01      	cmp	r3, #1
 8007c40:	d80a      	bhi.n	8007c58 <framework_system_tick_callback_register+0x1c>
    {
        if (system_tick_callback[i] == NULL)
 8007c42:	4a06      	ldr	r2, [pc, #24]	@ (8007c5c <framework_system_tick_callback_register+0x20>)
 8007c44:	f852 2023 	ldr.w	r2, [r2, r3, lsl #2]
 8007c48:	b112      	cbz	r2, 8007c50 <framework_system_tick_callback_register+0x14>
    for (uint8_t i = 0; i < 2; i++)
 8007c4a:	3301      	adds	r3, #1
 8007c4c:	b2db      	uxtb	r3, r3
 8007c4e:	e7f6      	b.n	8007c3e <framework_system_tick_callback_register+0x2>
        {
            system_tick_callback[i] = callback;
 8007c50:	4a02      	ldr	r2, [pc, #8]	@ (8007c5c <framework_system_tick_callback_register+0x20>)
 8007c52:	f842 0023 	str.w	r0, [r2, r3, lsl #2]
            break;
 8007c56:	4770      	bx	lr
        }
    }
}
 8007c58:	4770      	bx	lr
 8007c5a:	bf00      	nop
 8007c5c:	20004134 	.word	0x20004134

08007c60 <framework_register_os_tick_handler>:

void framework_register_os_tick_handler(void)
{
 8007c60:	b508      	push	{r3, lr}
    framework_system_tick_callback_register(osal_system_get_systemtick_handler_callback());
 8007c62:	f7ff ff97 	bl	8007b94 <osal_system_get_systemtick_handler_callback>
 8007c66:	f7ff ffe9 	bl	8007c3c <framework_system_tick_callback_register>
}
 8007c6a:	bd08      	pop	{r3, pc}

08007c6c <framework_sdk_base_init>:

void framework_sdk_base_init(void)
{
 8007c6c:	b508      	push	{r3, lr}
    /* 此处主要初始化sdk驱动*/
    framework_interrupts_init_vector_table();
 8007c6e:	f000 f82f 	bl	8007cd0 <framework_interrupts_init_vector_table>
    framework_interrupts_register_handler(14, framework_system_tick_handler);
 8007c72:	4907      	ldr	r1, [pc, #28]	@ (8007c90 <framework_sdk_base_init+0x24>)
 8007c74:	200e      	movs	r0, #14
 8007c76:	f000 f835 	bl	8007ce4 <framework_interrupts_register_handler>
    framework_system_tick_callback_register(hal_system_get_systemhandler());
 8007c7a:	f7ff fe8e 	bl	800799a <hal_system_get_systemhandler>
 8007c7e:	f7ff ffdd 	bl	8007c3c <framework_system_tick_callback_register>
    hal_system_sdk_init();
 8007c82:	f7ff fe86 	bl	8007992 <hal_system_sdk_init>
    /* 系统的基础时钟*/
    hal_system_clock_init();
 8007c86:	f7ff fe80 	bl	800798a <hal_system_clock_init>
    /* 配置基本的内核级别的硬件，如内存，数据总线，mpu，flash，内核电源等*/
    hal_uart1_init();
 8007c8a:	f7ff fe76 	bl	800797a <hal_uart1_init>
}
 8007c8e:	bd08      	pop	{r3, pc}
 8007c90:	08007bb5 	.word	0x08007bb5

08007c94 <framework_os_base_init>:

void framework_os_base_init(void)
{
 8007c94:	b508      	push	{r3, lr}
    /* there will init rtos need hardware exampel uart ...*/
    osal_register_callback(framework_register_os_tick_handler);
 8007c96:	4802      	ldr	r0, [pc, #8]	@ (8007ca0 <framework_os_base_init+0xc>)
 8007c98:	f7ff ff80 	bl	8007b9c <osal_register_callback>
}
 8007c9c:	bd08      	pop	{r3, pc}
 8007c9e:	bf00      	nop
 8007ca0:	08007c61 	.word	0x08007c61

08007ca4 <framework_init_os>:

void framework_init_os(void)
{
 8007ca4:	b508      	push	{r3, lr}
    /* there will init os kernel*/
    extern void rtthread_startup(void);
    rtthread_startup();
 8007ca6:	f7f9 fb13 	bl	80012d0 <rtthread_startup>
}
 8007caa:	bd08      	pop	{r3, pc}

08007cac <framework_start>:

void framework_start(void)
{
 8007cac:	b508      	push	{r3, lr}
    framework_sdk_base_init();
 8007cae:	f7ff ffdd 	bl	8007c6c <framework_sdk_base_init>
#if OSAL_RTOS_RTTHREAD == 1
    framework_os_base_init();
 8007cb2:	f7ff ffef 	bl	8007c94 <framework_os_base_init>
    framework_init_os();
 8007cb6:	f7ff fff5 	bl	8007ca4 <framework_init_os>
#else
    extern int main(void);
    main();
#endif
}
 8007cba:	bd08      	pop	{r3, pc}

08007cbc <g_interrupt_handler>:
{
    __enable_irq();
}

static void g_interrupt_handler(int irq_number)
{
 8007cbc:	b508      	push	{r3, lr}

    if (interrupt_entries[irq_number].handler != NULL)
 8007cbe:	4b03      	ldr	r3, [pc, #12]	@ (8007ccc <g_interrupt_handler+0x10>)
 8007cc0:	f853 3020 	ldr.w	r3, [r3, r0, lsl #2]
 8007cc4:	b103      	cbz	r3, 8007cc8 <g_interrupt_handler+0xc>
    {
        interrupt_entries[irq_number].handler();
 8007cc6:	4798      	blx	r3
    }
}
 8007cc8:	bd08      	pop	{r3, pc}
 8007cca:	bf00      	nop
 8007ccc:	2000413c 	.word	0x2000413c

08007cd0 <framework_interrupts_init_vector_table>:
{
 8007cd0:	b508      	push	{r3, lr}
    memset(interrupt_entries, 0, sizeof(interrupt_entries));
 8007cd2:	f44f 7212 	mov.w	r2, #584	@ 0x248
 8007cd6:	2100      	movs	r1, #0
 8007cd8:	4801      	ldr	r0, [pc, #4]	@ (8007ce0 <framework_interrupts_init_vector_table+0x10>)
 8007cda:	f000 f813 	bl	8007d04 <memset>
}
 8007cde:	bd08      	pop	{r3, pc}
 8007ce0:	2000413c 	.word	0x2000413c

08007ce4 <framework_interrupts_register_handler>:
    interrupt_entries[irq_number].handler = handler;
 8007ce4:	4b01      	ldr	r3, [pc, #4]	@ (8007cec <framework_interrupts_register_handler+0x8>)
 8007ce6:	f843 1020 	str.w	r1, [r3, r0, lsl #2]
}
 8007cea:	4770      	bx	lr
 8007cec:	2000413c 	.word	0x2000413c

08007cf0 <framework_irq_handler>:

void framework_irq_handler(uint32_t irq_num)
{
 8007cf0:	b508      	push	{r3, lr}
    g_interrupt_handler(irq_num);
 8007cf2:	f7ff ffe3 	bl	8007cbc <g_interrupt_handler>
}
 8007cf6:	bd08      	pop	{r3, pc}

08007cf8 <SysTick_Handler>:
{
    g_interrupt_handler(PENDSV_IRQ_NUM);
}

void SysTick_Handler(void)
{
 8007cf8:	b508      	push	{r3, lr}
    g_interrupt_handler(SYSTICK_IRQ_NUM);
 8007cfa:	200e      	movs	r0, #14
 8007cfc:	f7ff ffde 	bl	8007cbc <g_interrupt_handler>
}
 8007d00:	bd08      	pop	{r3, pc}

08007d02 <main>:
    // printf("sin(pi/2) = %f, cos(0) = %f\n", sin(3.14159 / 2.0), cos(0.0));
    // printf("sqrt(2) = %f, log(10) = %f\n", sqrt(2.0), log(10.0));

    // printf("=== End test ===\n");

    while (1)
 8007d02:	e7fe      	b.n	8007d02 <main>

08007d04 <memset>:
 8007d04:	0783      	lsls	r3, r0, #30
 8007d06:	b530      	push	{r4, r5, lr}
 8007d08:	d046      	beq.n	8007d98 <memset+0x94>
 8007d0a:	1884      	adds	r4, r0, r2
 8007d0c:	4684      	mov	ip, r0
 8007d0e:	e004      	b.n	8007d1a <memset+0x16>
 8007d10:	f803 1b01 	strb.w	r1, [r3], #1
 8007d14:	079d      	lsls	r5, r3, #30
 8007d16:	d004      	beq.n	8007d22 <memset+0x1e>
 8007d18:	469c      	mov	ip, r3
 8007d1a:	45a4      	cmp	ip, r4
 8007d1c:	4663      	mov	r3, ip
 8007d1e:	d1f7      	bne.n	8007d10 <memset+0xc>
 8007d20:	bd30      	pop	{r4, r5, pc}
 8007d22:	3a01      	subs	r2, #1
 8007d24:	4402      	add	r2, r0
 8007d26:	eba2 020c 	sub.w	r2, r2, ip
 8007d2a:	2a03      	cmp	r2, #3
 8007d2c:	d929      	bls.n	8007d82 <memset+0x7e>
 8007d2e:	b2cc      	uxtb	r4, r1
 8007d30:	2a0f      	cmp	r2, #15
 8007d32:	eb04 2404 	add.w	r4, r4, r4, lsl #8
 8007d36:	eb04 4404 	add.w	r4, r4, r4, lsl #16
 8007d3a:	d92f      	bls.n	8007d9c <memset+0x98>
 8007d3c:	f1a2 0c10 	sub.w	ip, r2, #16
 8007d40:	f103 0510 	add.w	r5, r3, #16
 8007d44:	f02c 0c0f 	bic.w	ip, ip, #15
 8007d48:	44ac      	add	ip, r5
 8007d4a:	e9c3 4400 	strd	r4, r4, [r3]
 8007d4e:	e9c3 4402 	strd	r4, r4, [r3, #8]
 8007d52:	3310      	adds	r3, #16
 8007d54:	4563      	cmp	r3, ip
 8007d56:	d1f8      	bne.n	8007d4a <memset+0x46>
 8007d58:	f012 0f0c 	tst.w	r2, #12
 8007d5c:	f002 0e0f 	and.w	lr, r2, #15
 8007d60:	d018      	beq.n	8007d94 <memset+0x90>
 8007d62:	f02e 0c03 	bic.w	ip, lr, #3
 8007d66:	f1ae 0504 	sub.w	r5, lr, #4
 8007d6a:	461a      	mov	r2, r3
 8007d6c:	449c      	add	ip, r3
 8007d6e:	f842 4b04 	str.w	r4, [r2], #4
 8007d72:	4562      	cmp	r2, ip
 8007d74:	d1fb      	bne.n	8007d6e <memset+0x6a>
 8007d76:	f025 0403 	bic.w	r4, r5, #3
 8007d7a:	3304      	adds	r3, #4
 8007d7c:	f00e 0203 	and.w	r2, lr, #3
 8007d80:	4423      	add	r3, r4
 8007d82:	2a00      	cmp	r2, #0
 8007d84:	d0cc      	beq.n	8007d20 <memset+0x1c>
 8007d86:	b2c9      	uxtb	r1, r1
 8007d88:	441a      	add	r2, r3
 8007d8a:	f803 1b01 	strb.w	r1, [r3], #1
 8007d8e:	4293      	cmp	r3, r2
 8007d90:	d1fb      	bne.n	8007d8a <memset+0x86>
 8007d92:	bd30      	pop	{r4, r5, pc}
 8007d94:	4672      	mov	r2, lr
 8007d96:	e7f4      	b.n	8007d82 <memset+0x7e>
 8007d98:	4603      	mov	r3, r0
 8007d9a:	e7c6      	b.n	8007d2a <memset+0x26>
 8007d9c:	4696      	mov	lr, r2
 8007d9e:	e7e0      	b.n	8007d62 <memset+0x5e>

08007da0 <__retarget_lock_acquire_recursive>:
 8007da0:	4770      	bx	lr
 8007da2:	bf00      	nop

08007da4 <__retarget_lock_release_recursive>:
 8007da4:	4770      	bx	lr
 8007da6:	bf00      	nop

08007da8 <register_fini>:
 8007da8:	4b02      	ldr	r3, [pc, #8]	@ (8007db4 <register_fini+0xc>)
 8007daa:	b113      	cbz	r3, 8007db2 <register_fini+0xa>
 8007dac:	4802      	ldr	r0, [pc, #8]	@ (8007db8 <register_fini+0x10>)
 8007dae:	f000 b805 	b.w	8007dbc <atexit>
 8007db2:	4770      	bx	lr
 8007db4:	00000000 	.word	0x00000000
 8007db8:	08007dc9 	.word	0x08007dc9

08007dbc <atexit>:
 8007dbc:	2300      	movs	r3, #0
 8007dbe:	4601      	mov	r1, r0
 8007dc0:	461a      	mov	r2, r3
 8007dc2:	4618      	mov	r0, r3
 8007dc4:	f000 b814 	b.w	8007df0 <__register_exitproc>

08007dc8 <__libc_fini_array>:
 8007dc8:	b538      	push	{r3, r4, r5, lr}
 8007dca:	4d07      	ldr	r5, [pc, #28]	@ (8007de8 <__libc_fini_array+0x20>)
 8007dcc:	4c07      	ldr	r4, [pc, #28]	@ (8007dec <__libc_fini_array+0x24>)
 8007dce:	1b2c      	subs	r4, r5, r4
 8007dd0:	10a4      	asrs	r4, r4, #2
 8007dd2:	d005      	beq.n	8007de0 <__libc_fini_array+0x18>
 8007dd4:	3c01      	subs	r4, #1
 8007dd6:	f855 3d04 	ldr.w	r3, [r5, #-4]!
 8007dda:	4798      	blx	r3
 8007ddc:	2c00      	cmp	r4, #0
 8007dde:	d1f9      	bne.n	8007dd4 <__libc_fini_array+0xc>
 8007de0:	e8bd 4038 	ldmia.w	sp!, {r3, r4, r5, lr}
 8007de4:	f000 b9f2 	b.w	80081cc <_fini>
 8007de8:	080092c4 	.word	0x080092c4
 8007dec:	080092c8 	.word	0x080092c8

08007df0 <__register_exitproc>:
 8007df0:	e92d 43f8 	stmdb	sp!, {r3, r4, r5, r6, r7, r8, r9, lr}
 8007df4:	4d1c      	ldr	r5, [pc, #112]	@ (8007e68 <__register_exitproc+0x78>)
 8007df6:	4606      	mov	r6, r0
 8007df8:	4698      	mov	r8, r3
 8007dfa:	460f      	mov	r7, r1
 8007dfc:	6828      	ldr	r0, [r5, #0]
 8007dfe:	4691      	mov	r9, r2
 8007e00:	f7ff ffce 	bl	8007da0 <__retarget_lock_acquire_recursive>
 8007e04:	4b19      	ldr	r3, [pc, #100]	@ (8007e6c <__register_exitproc+0x7c>)
 8007e06:	681c      	ldr	r4, [r3, #0]
 8007e08:	b32c      	cbz	r4, 8007e56 <__register_exitproc+0x66>
 8007e0a:	6828      	ldr	r0, [r5, #0]
 8007e0c:	6865      	ldr	r5, [r4, #4]
 8007e0e:	2d1f      	cmp	r5, #31
 8007e10:	dc24      	bgt.n	8007e5c <__register_exitproc+0x6c>
 8007e12:	b94e      	cbnz	r6, 8007e28 <__register_exitproc+0x38>
 8007e14:	1c6b      	adds	r3, r5, #1
 8007e16:	3502      	adds	r5, #2
 8007e18:	6063      	str	r3, [r4, #4]
 8007e1a:	f844 7025 	str.w	r7, [r4, r5, lsl #2]
 8007e1e:	f7ff ffc1 	bl	8007da4 <__retarget_lock_release_recursive>
 8007e22:	2000      	movs	r0, #0
 8007e24:	e8bd 83f8 	ldmia.w	sp!, {r3, r4, r5, r6, r7, r8, r9, pc}
 8007e28:	eb04 0185 	add.w	r1, r4, r5, lsl #2
 8007e2c:	2301      	movs	r3, #1
 8007e2e:	2e02      	cmp	r6, #2
 8007e30:	f8c1 9088 	str.w	r9, [r1, #136]	@ 0x88
 8007e34:	fa03 f305 	lsl.w	r3, r3, r5
 8007e38:	f8d4 2188 	ldr.w	r2, [r4, #392]	@ 0x188
 8007e3c:	ea42 0203 	orr.w	r2, r2, r3
 8007e40:	f8c4 2188 	str.w	r2, [r4, #392]	@ 0x188
 8007e44:	f8c1 8108 	str.w	r8, [r1, #264]	@ 0x108
 8007e48:	d1e4      	bne.n	8007e14 <__register_exitproc+0x24>
 8007e4a:	f8d4 218c 	ldr.w	r2, [r4, #396]	@ 0x18c
 8007e4e:	431a      	orrs	r2, r3
 8007e50:	f8c4 218c 	str.w	r2, [r4, #396]	@ 0x18c
 8007e54:	e7de      	b.n	8007e14 <__register_exitproc+0x24>
 8007e56:	4c06      	ldr	r4, [pc, #24]	@ (8007e70 <__register_exitproc+0x80>)
 8007e58:	601c      	str	r4, [r3, #0]
 8007e5a:	e7d6      	b.n	8007e0a <__register_exitproc+0x1a>
 8007e5c:	f7ff ffa2 	bl	8007da4 <__retarget_lock_release_recursive>
 8007e60:	f04f 30ff 	mov.w	r0, #4294967295	@ 0xffffffff
 8007e64:	e7de      	b.n	8007e24 <__register_exitproc+0x34>
 8007e66:	bf00      	nop
 8007e68:	20000094 	.word	0x20000094
 8007e6c:	20004388 	.word	0x20004388
 8007e70:	2000438c 	.word	0x2000438c

08007e74 <__udivmoddi4>:
 8007e74:	e92d 4ff0 	stmdb	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, lr}
 8007e78:	468c      	mov	ip, r1
 8007e7a:	9e09      	ldr	r6, [sp, #36]	@ 0x24
 8007e7c:	4604      	mov	r4, r0
 8007e7e:	460f      	mov	r7, r1
 8007e80:	2b00      	cmp	r3, #0
 8007e82:	d148      	bne.n	8007f16 <__udivmoddi4+0xa2>
 8007e84:	428a      	cmp	r2, r1
 8007e86:	4615      	mov	r5, r2
 8007e88:	d95e      	bls.n	8007f48 <__udivmoddi4+0xd4>
 8007e8a:	fab2 f382 	clz	r3, r2
 8007e8e:	b13b      	cbz	r3, 8007ea0 <__udivmoddi4+0x2c>
 8007e90:	f1c3 0220 	rsb	r2, r3, #32
 8007e94:	409f      	lsls	r7, r3
 8007e96:	409d      	lsls	r5, r3
 8007e98:	409c      	lsls	r4, r3
 8007e9a:	fa20 f202 	lsr.w	r2, r0, r2
 8007e9e:	4317      	orrs	r7, r2
 8007ea0:	ea4f 4e15 	mov.w	lr, r5, lsr #16
 8007ea4:	fa1f fc85 	uxth.w	ip, r5
 8007ea8:	0c22      	lsrs	r2, r4, #16
 8007eaa:	fbb7 f1fe 	udiv	r1, r7, lr
 8007eae:	fb0e 7711 	mls	r7, lr, r1, r7
 8007eb2:	fb01 f00c 	mul.w	r0, r1, ip
 8007eb6:	ea42 4207 	orr.w	r2, r2, r7, lsl #16
 8007eba:	4290      	cmp	r0, r2
 8007ebc:	d907      	bls.n	8007ece <__udivmoddi4+0x5a>
 8007ebe:	18aa      	adds	r2, r5, r2
 8007ec0:	f101 37ff 	add.w	r7, r1, #4294967295	@ 0xffffffff
 8007ec4:	d202      	bcs.n	8007ecc <__udivmoddi4+0x58>
 8007ec6:	4290      	cmp	r0, r2
 8007ec8:	f200 8158 	bhi.w	800817c <__udivmoddi4+0x308>
 8007ecc:	4639      	mov	r1, r7
 8007ece:	1a12      	subs	r2, r2, r0
 8007ed0:	b2a4      	uxth	r4, r4
 8007ed2:	fbb2 f0fe 	udiv	r0, r2, lr
 8007ed6:	fb0e 2210 	mls	r2, lr, r0, r2
 8007eda:	fb00 fc0c 	mul.w	ip, r0, ip
 8007ede:	ea44 4402 	orr.w	r4, r4, r2, lsl #16
 8007ee2:	45a4      	cmp	ip, r4
 8007ee4:	d90b      	bls.n	8007efe <__udivmoddi4+0x8a>
 8007ee6:	192c      	adds	r4, r5, r4
 8007ee8:	f100 32ff 	add.w	r2, r0, #4294967295	@ 0xffffffff
 8007eec:	bf2c      	ite	cs
 8007eee:	2701      	movcs	r7, #1
 8007ef0:	2700      	movcc	r7, #0
 8007ef2:	45a4      	cmp	ip, r4
 8007ef4:	d902      	bls.n	8007efc <__udivmoddi4+0x88>
 8007ef6:	2f00      	cmp	r7, #0
 8007ef8:	f000 8143 	beq.w	8008182 <__udivmoddi4+0x30e>
 8007efc:	4610      	mov	r0, r2
 8007efe:	ea40 4001 	orr.w	r0, r0, r1, lsl #16
 8007f02:	eba4 040c 	sub.w	r4, r4, ip
 8007f06:	2100      	movs	r1, #0
 8007f08:	b11e      	cbz	r6, 8007f12 <__udivmoddi4+0x9e>
 8007f0a:	40dc      	lsrs	r4, r3
 8007f0c:	2300      	movs	r3, #0
 8007f0e:	e9c6 4300 	strd	r4, r3, [r6]
 8007f12:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
 8007f16:	428b      	cmp	r3, r1
 8007f18:	d906      	bls.n	8007f28 <__udivmoddi4+0xb4>
 8007f1a:	b10e      	cbz	r6, 8007f20 <__udivmoddi4+0xac>
 8007f1c:	e9c6 0100 	strd	r0, r1, [r6]
 8007f20:	2100      	movs	r1, #0
 8007f22:	4608      	mov	r0, r1
 8007f24:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
 8007f28:	fab3 f183 	clz	r1, r3
 8007f2c:	2900      	cmp	r1, #0
 8007f2e:	d151      	bne.n	8007fd4 <__udivmoddi4+0x160>
 8007f30:	4563      	cmp	r3, ip
 8007f32:	f0c0 8116 	bcc.w	8008162 <__udivmoddi4+0x2ee>
 8007f36:	4282      	cmp	r2, r0
 8007f38:	f240 8113 	bls.w	8008162 <__udivmoddi4+0x2ee>
 8007f3c:	4608      	mov	r0, r1
 8007f3e:	2e00      	cmp	r6, #0
 8007f40:	d0e7      	beq.n	8007f12 <__udivmoddi4+0x9e>
 8007f42:	e9c6 4700 	strd	r4, r7, [r6]
 8007f46:	e7e4      	b.n	8007f12 <__udivmoddi4+0x9e>
 8007f48:	2a00      	cmp	r2, #0
 8007f4a:	f000 80af 	beq.w	80080ac <__udivmoddi4+0x238>
 8007f4e:	fab2 f382 	clz	r3, r2
 8007f52:	2b00      	cmp	r3, #0
 8007f54:	f040 80c2 	bne.w	80080dc <__udivmoddi4+0x268>
 8007f58:	1a8a      	subs	r2, r1, r2
 8007f5a:	ea4f 4e15 	mov.w	lr, r5, lsr #16
 8007f5e:	b2af      	uxth	r7, r5
 8007f60:	2101      	movs	r1, #1
 8007f62:	0c20      	lsrs	r0, r4, #16
 8007f64:	fbb2 fcfe 	udiv	ip, r2, lr
 8007f68:	fb0e 221c 	mls	r2, lr, ip, r2
 8007f6c:	ea40 4202 	orr.w	r2, r0, r2, lsl #16
 8007f70:	fb07 f00c 	mul.w	r0, r7, ip
 8007f74:	4290      	cmp	r0, r2
 8007f76:	d90e      	bls.n	8007f96 <__udivmoddi4+0x122>
 8007f78:	18aa      	adds	r2, r5, r2
 8007f7a:	f10c 38ff 	add.w	r8, ip, #4294967295	@ 0xffffffff
 8007f7e:	bf2c      	ite	cs
 8007f80:	f04f 0901 	movcs.w	r9, #1
 8007f84:	f04f 0900 	movcc.w	r9, #0
 8007f88:	4290      	cmp	r0, r2
 8007f8a:	d903      	bls.n	8007f94 <__udivmoddi4+0x120>
 8007f8c:	f1b9 0f00 	cmp.w	r9, #0
 8007f90:	f000 80f0 	beq.w	8008174 <__udivmoddi4+0x300>
 8007f94:	46c4      	mov	ip, r8
 8007f96:	1a12      	subs	r2, r2, r0
 8007f98:	b2a4      	uxth	r4, r4
 8007f9a:	fbb2 f0fe 	udiv	r0, r2, lr
 8007f9e:	fb0e 2210 	mls	r2, lr, r0, r2
 8007fa2:	fb00 f707 	mul.w	r7, r0, r7
 8007fa6:	ea44 4402 	orr.w	r4, r4, r2, lsl #16
 8007faa:	42a7      	cmp	r7, r4
 8007fac:	d90e      	bls.n	8007fcc <__udivmoddi4+0x158>
 8007fae:	192c      	adds	r4, r5, r4
 8007fb0:	f100 32ff 	add.w	r2, r0, #4294967295	@ 0xffffffff
 8007fb4:	bf2c      	ite	cs
 8007fb6:	f04f 0e01 	movcs.w	lr, #1
 8007fba:	f04f 0e00 	movcc.w	lr, #0
 8007fbe:	42a7      	cmp	r7, r4
 8007fc0:	d903      	bls.n	8007fca <__udivmoddi4+0x156>
 8007fc2:	f1be 0f00 	cmp.w	lr, #0
 8007fc6:	f000 80d2 	beq.w	800816e <__udivmoddi4+0x2fa>
 8007fca:	4610      	mov	r0, r2
 8007fcc:	1be4      	subs	r4, r4, r7
 8007fce:	ea40 400c 	orr.w	r0, r0, ip, lsl #16
 8007fd2:	e799      	b.n	8007f08 <__udivmoddi4+0x94>
 8007fd4:	f1c1 0520 	rsb	r5, r1, #32
 8007fd8:	408b      	lsls	r3, r1
 8007fda:	fa0c f401 	lsl.w	r4, ip, r1
 8007fde:	fa00 f901 	lsl.w	r9, r0, r1
 8007fe2:	fa22 f705 	lsr.w	r7, r2, r5
 8007fe6:	fa2c fc05 	lsr.w	ip, ip, r5
 8007fea:	408a      	lsls	r2, r1
 8007fec:	431f      	orrs	r7, r3
 8007fee:	fa20 f305 	lsr.w	r3, r0, r5
 8007ff2:	0c38      	lsrs	r0, r7, #16
 8007ff4:	4323      	orrs	r3, r4
 8007ff6:	fa1f fe87 	uxth.w	lr, r7
 8007ffa:	0c1c      	lsrs	r4, r3, #16
 8007ffc:	fbbc f8f0 	udiv	r8, ip, r0
 8008000:	fb00 cc18 	mls	ip, r0, r8, ip
 8008004:	ea44 440c 	orr.w	r4, r4, ip, lsl #16
 8008008:	fb08 fc0e 	mul.w	ip, r8, lr
 800800c:	45a4      	cmp	ip, r4
 800800e:	d90e      	bls.n	800802e <__udivmoddi4+0x1ba>
 8008010:	193c      	adds	r4, r7, r4
 8008012:	f108 3aff 	add.w	sl, r8, #4294967295	@ 0xffffffff
 8008016:	bf2c      	ite	cs
 8008018:	f04f 0b01 	movcs.w	fp, #1
 800801c:	f04f 0b00 	movcc.w	fp, #0
 8008020:	45a4      	cmp	ip, r4
 8008022:	d903      	bls.n	800802c <__udivmoddi4+0x1b8>
 8008024:	f1bb 0f00 	cmp.w	fp, #0
 8008028:	f000 80b8 	beq.w	800819c <__udivmoddi4+0x328>
 800802c:	46d0      	mov	r8, sl
 800802e:	eba4 040c 	sub.w	r4, r4, ip
 8008032:	fa1f fc83 	uxth.w	ip, r3
 8008036:	fbb4 f3f0 	udiv	r3, r4, r0
 800803a:	fb00 4413 	mls	r4, r0, r3, r4
 800803e:	fb03 fe0e 	mul.w	lr, r3, lr
 8008042:	ea4c 4404 	orr.w	r4, ip, r4, lsl #16
 8008046:	45a6      	cmp	lr, r4
 8008048:	d90e      	bls.n	8008068 <__udivmoddi4+0x1f4>
 800804a:	193c      	adds	r4, r7, r4
 800804c:	f103 30ff 	add.w	r0, r3, #4294967295	@ 0xffffffff
 8008050:	bf2c      	ite	cs
 8008052:	f04f 0c01 	movcs.w	ip, #1
 8008056:	f04f 0c00 	movcc.w	ip, #0
 800805a:	45a6      	cmp	lr, r4
 800805c:	d903      	bls.n	8008066 <__udivmoddi4+0x1f2>
 800805e:	f1bc 0f00 	cmp.w	ip, #0
 8008062:	f000 809f 	beq.w	80081a4 <__udivmoddi4+0x330>
 8008066:	4603      	mov	r3, r0
 8008068:	ea43 4008 	orr.w	r0, r3, r8, lsl #16
 800806c:	eba4 040e 	sub.w	r4, r4, lr
 8008070:	fba0 ec02 	umull	lr, ip, r0, r2
 8008074:	4564      	cmp	r4, ip
 8008076:	4673      	mov	r3, lr
 8008078:	46e0      	mov	r8, ip
 800807a:	d302      	bcc.n	8008082 <__udivmoddi4+0x20e>
 800807c:	d107      	bne.n	800808e <__udivmoddi4+0x21a>
 800807e:	45f1      	cmp	r9, lr
 8008080:	d205      	bcs.n	800808e <__udivmoddi4+0x21a>
 8008082:	ebbe 0302 	subs.w	r3, lr, r2
 8008086:	eb6c 0c07 	sbc.w	ip, ip, r7
 800808a:	3801      	subs	r0, #1
 800808c:	46e0      	mov	r8, ip
 800808e:	b15e      	cbz	r6, 80080a8 <__udivmoddi4+0x234>
 8008090:	ebb9 0203 	subs.w	r2, r9, r3
 8008094:	eb64 0408 	sbc.w	r4, r4, r8
 8008098:	fa04 f505 	lsl.w	r5, r4, r5
 800809c:	fa22 f301 	lsr.w	r3, r2, r1
 80080a0:	40cc      	lsrs	r4, r1
 80080a2:	431d      	orrs	r5, r3
 80080a4:	e9c6 5400 	strd	r5, r4, [r6]
 80080a8:	2100      	movs	r1, #0
 80080aa:	e732      	b.n	8007f12 <__udivmoddi4+0x9e>
 80080ac:	0842      	lsrs	r2, r0, #1
 80080ae:	462f      	mov	r7, r5
 80080b0:	084b      	lsrs	r3, r1, #1
 80080b2:	46ac      	mov	ip, r5
 80080b4:	ea42 72c1 	orr.w	r2, r2, r1, lsl #31
 80080b8:	46ae      	mov	lr, r5
 80080ba:	07c4      	lsls	r4, r0, #31
 80080bc:	0c11      	lsrs	r1, r2, #16
 80080be:	b292      	uxth	r2, r2
 80080c0:	ea41 4103 	orr.w	r1, r1, r3, lsl #16
 80080c4:	ea42 4201 	orr.w	r2, r2, r1, lsl #16
 80080c8:	fbb1 f1f5 	udiv	r1, r1, r5
 80080cc:	fbb3 f0f5 	udiv	r0, r3, r5
 80080d0:	231f      	movs	r3, #31
 80080d2:	eba2 020c 	sub.w	r2, r2, ip
 80080d6:	ea41 4100 	orr.w	r1, r1, r0, lsl #16
 80080da:	e742      	b.n	8007f62 <__udivmoddi4+0xee>
 80080dc:	409d      	lsls	r5, r3
 80080de:	f1c3 0220 	rsb	r2, r3, #32
 80080e2:	4099      	lsls	r1, r3
 80080e4:	409c      	lsls	r4, r3
 80080e6:	fa2c fc02 	lsr.w	ip, ip, r2
 80080ea:	ea4f 4e15 	mov.w	lr, r5, lsr #16
 80080ee:	fa20 f202 	lsr.w	r2, r0, r2
 80080f2:	b2af      	uxth	r7, r5
 80080f4:	fbbc f8fe 	udiv	r8, ip, lr
 80080f8:	430a      	orrs	r2, r1
 80080fa:	fb0e cc18 	mls	ip, lr, r8, ip
 80080fe:	0c11      	lsrs	r1, r2, #16
 8008100:	ea41 410c 	orr.w	r1, r1, ip, lsl #16
 8008104:	fb08 fc07 	mul.w	ip, r8, r7
 8008108:	458c      	cmp	ip, r1
 800810a:	d950      	bls.n	80081ae <__udivmoddi4+0x33a>
 800810c:	1869      	adds	r1, r5, r1
 800810e:	f108 30ff 	add.w	r0, r8, #4294967295	@ 0xffffffff
 8008112:	bf2c      	ite	cs
 8008114:	f04f 0901 	movcs.w	r9, #1
 8008118:	f04f 0900 	movcc.w	r9, #0
 800811c:	458c      	cmp	ip, r1
 800811e:	d902      	bls.n	8008126 <__udivmoddi4+0x2b2>
 8008120:	f1b9 0f00 	cmp.w	r9, #0
 8008124:	d030      	beq.n	8008188 <__udivmoddi4+0x314>
 8008126:	eba1 010c 	sub.w	r1, r1, ip
 800812a:	fbb1 f8fe 	udiv	r8, r1, lr
 800812e:	fb08 fc07 	mul.w	ip, r8, r7
 8008132:	fb0e 1118 	mls	r1, lr, r8, r1
 8008136:	b292      	uxth	r2, r2
 8008138:	ea42 4201 	orr.w	r2, r2, r1, lsl #16
 800813c:	4562      	cmp	r2, ip
 800813e:	d234      	bcs.n	80081aa <__udivmoddi4+0x336>
 8008140:	18aa      	adds	r2, r5, r2
 8008142:	f108 31ff 	add.w	r1, r8, #4294967295	@ 0xffffffff
 8008146:	bf2c      	ite	cs
 8008148:	f04f 0901 	movcs.w	r9, #1
 800814c:	f04f 0900 	movcc.w	r9, #0
 8008150:	4562      	cmp	r2, ip
 8008152:	d2be      	bcs.n	80080d2 <__udivmoddi4+0x25e>
 8008154:	f1b9 0f00 	cmp.w	r9, #0
 8008158:	d1bb      	bne.n	80080d2 <__udivmoddi4+0x25e>
 800815a:	f1a8 0102 	sub.w	r1, r8, #2
 800815e:	442a      	add	r2, r5
 8008160:	e7b7      	b.n	80080d2 <__udivmoddi4+0x25e>
 8008162:	1a84      	subs	r4, r0, r2
 8008164:	eb6c 0203 	sbc.w	r2, ip, r3
 8008168:	2001      	movs	r0, #1
 800816a:	4617      	mov	r7, r2
 800816c:	e6e7      	b.n	8007f3e <__udivmoddi4+0xca>
 800816e:	442c      	add	r4, r5
 8008170:	3802      	subs	r0, #2
 8008172:	e72b      	b.n	8007fcc <__udivmoddi4+0x158>
 8008174:	f1ac 0c02 	sub.w	ip, ip, #2
 8008178:	442a      	add	r2, r5
 800817a:	e70c      	b.n	8007f96 <__udivmoddi4+0x122>
 800817c:	3902      	subs	r1, #2
 800817e:	442a      	add	r2, r5
 8008180:	e6a5      	b.n	8007ece <__udivmoddi4+0x5a>
 8008182:	442c      	add	r4, r5
 8008184:	3802      	subs	r0, #2
 8008186:	e6ba      	b.n	8007efe <__udivmoddi4+0x8a>
 8008188:	eba5 0c0c 	sub.w	ip, r5, ip
 800818c:	f1a8 0002 	sub.w	r0, r8, #2
 8008190:	4461      	add	r1, ip
 8008192:	fbb1 f8fe 	udiv	r8, r1, lr
 8008196:	fb08 fc07 	mul.w	ip, r8, r7
 800819a:	e7ca      	b.n	8008132 <__udivmoddi4+0x2be>
 800819c:	f1a8 0802 	sub.w	r8, r8, #2
 80081a0:	443c      	add	r4, r7
 80081a2:	e744      	b.n	800802e <__udivmoddi4+0x1ba>
 80081a4:	3b02      	subs	r3, #2
 80081a6:	443c      	add	r4, r7
 80081a8:	e75e      	b.n	8008068 <__udivmoddi4+0x1f4>
 80081aa:	4641      	mov	r1, r8
 80081ac:	e791      	b.n	80080d2 <__udivmoddi4+0x25e>
 80081ae:	eba1 010c 	sub.w	r1, r1, ip
 80081b2:	4640      	mov	r0, r8
 80081b4:	fbb1 f8fe 	udiv	r8, r1, lr
 80081b8:	fb08 fc07 	mul.w	ip, r8, r7
 80081bc:	e7b9      	b.n	8008132 <__udivmoddi4+0x2be>
 80081be:	bf00      	nop

080081c0 <_init>:
 80081c0:	b5f8      	push	{r3, r4, r5, r6, r7, lr}
 80081c2:	bf00      	nop
 80081c4:	bcf8      	pop	{r3, r4, r5, r6, r7}
 80081c6:	bc08      	pop	{r3}
 80081c8:	469e      	mov	lr, r3
 80081ca:	4770      	bx	lr

080081cc <_fini>:
 80081cc:	b5f8      	push	{r3, r4, r5, r6, r7, lr}
 80081ce:	bf00      	nop
 80081d0:	bcf8      	pop	{r3, r4, r5, r6, r7}
 80081d2:	bc08      	pop	{r3}
 80081d4:	469e      	mov	lr, r3
 80081d6:	4770      	bx	lr
