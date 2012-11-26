//
//  IndividDispatch.s
//  IndividExample
//
//  Created by Sergey Gavrilyuk on 12-11-19.
//
//

#if  __i386__
.globl _individMessageDispatch
_individMessageDispatch:
    pushl	%ebp
    movl	%esp, %ebp
    sub $8,%esp
    movl 8(%ebp),%eax
    movl 12(%ebp),%ecx
    movl %eax,(%esp)
    movl %ecx,4(%esp)
    call _individMessageDispatchGetImp
    cmpl $0,%eax
    jne m1
    calll _individForwardTarget
    cmpl $0,%eax
    je m2
    addl $8,%esp
    popl %ebp
    mov %eax, 4(%esp)
    calll _objc_msgSendAddr
    jmpl *%eax
m2:
    calll _individMessageDispatchDoesnotRecognizeAddr
m1:
    addl $8,%esp
    popl %ebp
    jmpl *%eax
    ret

#else
.align	2
.code	16
.globl _individMessageDispatch
.thumb_func	_individMessageDispatch
_individMessageDispatch:
//    stmfd sp!, {r0-r3,lr}
    push {r0-r3,lr}
    blx _individMessageDispatchGetImp
    cmp r0,#0
    bne m1
    ldr r0,[sp]
    ldr r1,[sp,#4]
    blx _individForwardTarget
    cmp r0,#0
    beq m2
    mov r5,r0
    blx _objc_msgSendAddr
    mov ip,r0
    //ldmfd	sp!,{r0,r1,r2,r3,lr}
    pop {r0-r3,lr}
    mov r0,r5
    bx ip
m2:
    blx _individMessageDispatchDoesnotRecognizeAddr
m1:
    mov ip,r0
    //ldmfd	sp!,{r0,r1,r2,r3,lr}
    pop {r0-r3,lr}
    bx ip
    bx lr

.align	2
.code	16
.globl _individMessageDispatchStret
.thumb_func	_individMessageDispatchStret
_individMessageDispatchStret:
//    stmfd sp!, {r0-r3,lr}
push {r0-r3,lr}
mov r0,r1
mov r1,r2
blx _individMessageDispatchGetImp
cmp r0,#0
bne m11
ldr r1,[sp]
ldr r2,[sp,#4]
blx _individForwardTarget
cmp r0,#0
beq m12
mov r5,r0
blx _objc_msgSendStretAddr
mov ip,r0
//ldmfd	sp!,{r0,r1,r2,r3,lr}
pop {r0-r3,lr}
mov r1,r5
bx ip
m12:
blx _individMessageDispatchDoesnotRecognizeAddr
m11:
mov ip,r0
//ldmfd	sp!,{r0,r1,r2,r3,lr}
pop {r0-r3,lr}
bx ip
bx lr

#endif