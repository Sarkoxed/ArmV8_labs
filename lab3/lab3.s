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

    .data
tmp:
    .string " " 
    .text
    .align  2
    .type   even, %function
    .equ    fd, 16
    .equ    buf, 24
    //.equ    bufsize, 10 //4096
    //.equ    extra, 34 //4120
   // .equ    bufsize, 4096
   // .equ    extra, 4120
    //.equ    bufsize, 5
    .equ    bufsize, 6500
    .equ    extra, 6524
even:
    ldr     x1, [sp, #16]
    mov     x16, extra               // changed
    sub     sp, sp, x16
    stp     x29, x30, [sp]
    mov     x29, sp
    mov     x0, #-100
    mov     x2, #0x241
    mov     x3, #0600
    mov     x8, #56
    svc     #0
    cmp     x0, #0
    bge     beg
    bl      errout
    b       fclose 
beg:
    str     x0, [x29, fd]
    mov     x10, #0
    mov     x18, #0         // odds and evens
    mov     x14, #0         // word number
    mov     x15, #0         // were there a space
enroll:
    mov     x0, #0
    add     x1, x29, buf
    mov     x2, bufsize
    mov     x8, #63
    svc     #0
    cmp     x0, #0
    beq     fclose
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
    mov     x2, #1
    add     x1, x29, buf
    mov     x8, #64
    mov     x11, #-1        // read bytes count
    mov     x12, x0
loop:
    add     x11, x11, #1
    ldrb    w16, [x1, x11]
    cmp     x11, x12
    beq     enroll
    cmp     w16, ' '
    beq     spaces
    cmp     w16, '\t'
    beq     spaces
    cmp     w16, '\n'
    beq     newline

    add     x14, x14, #1
    cmp     x15, #0
    beq     continue
putspace: 
    mov     x18, #0
    mov     x15, #0
    cmp     x14, #1
    beq     continue
    mov     x6, x1
    adr     x1, tmp
    ldr     x0, [x29, fd]
    svc     #0
    mov     x1, x6
continue:
    add     x18, x18, #1
    tbz     x18, 0, loop
    b       load
spaces:
    ldrb    w16, [x1, x11]
    add     x11, x11, #1
    cmp     w16, ' '
    beq     spaces
    cmp     w16, '\t'
    beq     spaces
    sub     x11, x11, #1
    cmp     w16, '\n'
    beq     newline
    mov     x15, #1
    sub     x11, x11, #1
    b       loop
load:
    mov     x7, x1
    add     x1, x1, x11
    ldr     x0, [x29, fd]
    svc     #0
    mov     x1, x7
    b       loop
newline:
    mov     x7, x1
    add     x1, x1, x11
    ldr     x0, [x29, fd]
    svc     #0
    mov     x1, x7
    mov     x18, #0
    mov     x14, #0
    mov     x15, #0
    b       loop
fclose:
    ldr     x0, [x29, fd]
    mov     x8, #57
    svc     #0
    mov     x0, #0
end:
    ldp     x29, x30, [sp]
    mov     x16, extra
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
