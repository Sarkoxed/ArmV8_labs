    .text
	.global MMax
	.align 2
	.type MMax, %function
MMax:
	cmp 	x1, x0
	blt 	if2
	mov 	x0, x1
if2:
	cmp 	x2, x0
	blt 	end1
	mov 	x0, x2
end1:
	b       maxcont
	.size   MMax, .-MMax

// single stripe
    .text
    .global greyStripe
    .align  2
    .type   greyStripe, %function
greyStripe:
    sub       sp, sp, #64
    stp     x22, x23, [sp]
    stp     x24, x25, [sp, #16]
    stp     x26, x27, [sp, #32]
    stp     x28, x29, [sp, #48]

    mov     x25, #1

    mov     x19, x0     //buf
    mov     x20, x1     //width
    mov     x21, x2     //height    x3 - lbound
    cmp     x3, x1
    bgt     end
                        // x4 - widthstripe
    
    mov     x28, x3     //start for x
    add     x27, x4, x3
    cmp     x27, x20    
    blt     pred
    mov     x27, x20    // end for x    
pred:
    mov     x29, xzr    // y <= x2
stripeY:
stripeX:
    mov     x22, x19       //buf
    mul     x23, x20, x29  //row    width * cur height
    add     x23, x23, x28  // pos
    mov     x0, #3
    mul     x23, x23, x0
    add     x22, x22, x23   // address
    ldrb    w0, [x22]
    add     x22, x22, x25
    ldrb    w1, [x22]
    add     x22, x22, x25
    ldrb    w2, [x22]
    b       MMax 
maxcont:
    sub     x22, x22, x25
    sub     x22, x22, x25
    strb    w0, [x22]
    add     x22, x22, x25
    strb    w0, [x22]
    add     x22, x22, x25
    strb    w0, [x22]
    add     x28, x28, x25
    cmp     x28, x27
    blt     stripeX
    add     x29, x29, x25
    mov     x28, x3
    cmp     x29, x21
    blt     stripeY
    mov     x0, x19
end:
    ldp     x22, x23, [sp]
    ldp     x24, x25, [sp, #16]
    ldp     x26, x27, [sp, #32]
    ldp     x28, x29, [sp, #48]
    add     sp, sp, #64
    ret
    .size   greyStripe, .-greyStripe
