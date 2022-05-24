    .arch   armv8-a
    .data
err1:
    .string "USAGE:: "
    .equ    errlen1, .-err1
err2:
    .string " [filEname!!!!11]\n"
    .equ    errlen2, .-err2

    .global _start
    .type   _start, %function
    .text
    .align  2
_start:
    ldr     x0, [sp]
    cmp     x0, #2
    beq     _func
    mov     x0, #2
    adr     x1, err1
    mov     x2, errlen1
    mov     x8, #64
    svc     #0
    mov     x0, #2
    ldr     x1, [sp, #8]
    mov     x2, #0
    mov     x8, #64
_len_filename:
    ldrb    w3, [x1, x2]
    cbz     w3, _out1
    add     x2, x2, #1
    b       _len_filename
_out1:
    svc     #0
    mov     x0, #2
    adr     x1, err2
    mov     x2, errlen2
    mov     x8, #64
    svc     #0
    mov     x0, #1
    b       _exit
_func:
    bl      even
_exit:
    mov     x8, #93
    svc     #0
    .size       _start, .-_start  

    .text
    .align  2
    .type   even, %function
    .equ    fd, 16
    .equ    buf, 24
even:
    ldr     x1, [sp, #16]
    mov     x16, #4120
//    mov     x16, 34               // changed
    sub     sp, sp, x16
    stp     x29, x30, [sp]
    mov     x29, sp
    mov     x0, #-100
    mov     x2, #0x241
    mov     x8, #56
    svc     #0
    cmp     x0, #0
    bge     beg
    bl      errout
    b       fclose 
beg:
    str     x0, [x29, fd]
    mov     x10, #0
enroll:
    mov     x0, #0
    add     x1, x29, buf
    mov     x2, #4096
//    mov     x2, #10
    mov     x8, #63
    svc     #0
    cmp     x0, #0
    beq     fclose
//    cmp     x10, #0  //changed
//    bgt     loop     //changed 
//    mov     x10, #1  //changed
//    cmp     x0, #0
    bgt     proceed
    str     x0, [sp, #-16]!
    ldr     x0, [x29, fd]
    mov     x8, #57
    svc     #0
    ldr     x0, [sp], #16
    bl      errout
    mov     x0, #1
    b       end
proceed:
    mov     x18, #0
    mov     x2, #1
    add     x1, x29, buf
    mov     x8, #64
    mov     x15, #0
    mov     x14, #0
loop:
    ldrb    w16, [x1], #1
    cbz     w16, enroll
    cmp     w16, ' '
    beq     spaces
    cmp     w16, '\n'
    beq     reload
    cmp     w16, '\t'
    beq     spaces
    add     x14, x14, #1
    cmp     x15, #0
    bgt     putspace
continue:
    add     x18, x18, #1
    tbz     x18, 0, loop
    b       load
putspace: 
    mov     x18, #0
    mov     x15, #0
    cmp     x14, #1
    beq     continue
    sub     x1, x1, #2
    mov     w13, ' '
    strb    w13, [x1]
    ldr     x0, [x29, fd]
    svc     #0
    add     x1, x1, #2
    b       continue
spaces:
    ldrb    w16, [x1], #1
    cbz     w16, enroll
    cmp     w16, ' '
    beq     spaces
    cmp     w16, '\t'
    beq     spaces
    sub     x1, x1, #1
    mov     x15, #1
    b       loop
load:
    sub     x1, x1, #1
    ldr     x0, [x29, fd]
    svc     #0
    add     x1, x1, #1
    b       loop
reload:
    sub     x1, x1, #1
    ldr     x0, [x29, fd]
    svc     #0
//    mov     x10, #0  //changed
    b       enroll
    
fclose:
    ldr     x0, [x29, fd]
    mov     x8, #57
    svc     #0
    mov     x0, #0
end:
    ldp     x29, x30, [sp]
    mov     x16, #4120
//    mov     x16, #10
    add     sp, sp, x16
    ret
    .size   even, .-even

    .type   errout, %function
    .data    
nofile:
    .string "No such file or directory\n"
    .equ    nof, .-nofile
perm:
    .string "Permission denied\n"
    .equ    per, .-perm
unknown:
    .string "Unknown error\n"
    .equ    unk, .-unknown
directory:
    .string "Is a directory\n"
    .equ    dir, .-directory
    .text
    .text
    .align  2
errout:
    cmp     x0, #-2
    bne     1f
    adr     x1, nofile
    mov     x2, nof
    b       out
1:
    cmp     x0, #-13
    bne     2f
    adr     x1, perm
    mov     x2, per
    b       out
2:
    cmp     x0, #-21
    bne     3f
    adr     x1, directory
    mov     x2, dir
    b       out
3:
    adr     x1, unknown
    mov     x2, unk
out:
    mov     x0, #2
    mov     x8, #64
    svc     #0
    ret
