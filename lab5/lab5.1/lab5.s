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

// full image
    .text
	.global  enGrey
	.align   2
	.type    enGrey, %function
enGrey:
	mov	     x19, x0   // buf
	mov	     x20, x1    // width
	mov      x21, x2    //height
	mov	     x28, xzr	// x
	mov	     x27, xzr	//  y
enGreyIterY:
enGreyIterX:
	mov	     x22, x19       // buf address
	mov 	 x23, x20       // width
	mul	     x23, x20, x27  // iteration row
	add	     x23, x23, x28  // index of byte
    mov      x25, #1
	mov	     x0, #3          
	mul	     x23, x23, x0   // pos in buffer
	add	     x22, x22, x23  // 
	ldrb	 w0, [x22]
    add      x22, x22, x25
	ldrb	 w1, [x22]
    add      x22, x22, x25
	ldrb	 w2, [x22]
	b	     MMax
maxcont:
    sub      x22, x22, x25
    sub      x22, x22, x25
    strb	 w0, [x22]
    add      x22, x22, x25
	strb	 w0, [x22]
    add      x22, x22, x25
	strb	 w0, [x22]
	add	     x28, x28, #1
	cmp	     x28, x20
	blt	     enGreyIterX
	add	     x27, x27, #1
	mov	     x28, xzr
	cmp	     x27, x21
	blt	     enGreyIterY
	mov	     x0, x19
	ret
	.size enGrey, .-enGrey
