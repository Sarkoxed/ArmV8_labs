    .arch   armv8-a
    .data
usage:
    .string "Usage: %s file\n"
mes:
    .string "Resulting Matrix:\n"
elem:
    .string "%.10lf "
enel:
    .string "%.10lf\n"
size:
    .string "Dim of matrices must be less or equal 20\n"
format:
    .string "Incorrect file format\n"
formint:
    .string "%d"
formdouble:
    .string "%lf"
mode:
    .string "r"
    
    .text
    .align  2
    .global main
    .type   main, %function
    .equ    progname, 48
    .equ    filename, 56
    .equ    filestruct, 64
    .equ    dim, 72
    .equ    matrix1, 80
    .equ    matrix2, 3280
    .equ    matrsize, 3200
    .equ    extra, 6480
main:
    mov     x2, extra
    sub     sp, sp, x2
    stp     x29, x30, [sp]
    stp     x28, x27, [sp, #16]
    stp     x26, x25, [sp, #32]
    mov     x29, sp
    cmp     w0, #2
    beq     open_file
    
    ldr     x2, [x1]
    adr     x0, stderr
    ldr     x0, [x0]
    adr     x1, usage
    bl      fprintf
errexit:
    mov     w0, #1
    ldp     x29, x30, [sp]
    ldp     x28, x27, [sp, #16]
    ldp     x26, x25, [sp, #32]
    mov     x2, extra
    add     sp, sp, x2
    ret
open_file:
    ldr     x0, [x1]
    str     x0, [x29, progname]
    ldr     x0, [x1, #8]
    str     x0, [x29, filename]
    adr     x1, mode
    bl      fopen
    cbnz    x0, save_pointer
    ldr     x0, [x29, filename]
    bl      perror
    b       errexit
save_pointer:
    str     x0,[x29, filestruct]
    adr     x1, formint
    add     x2, x29, dim
    bl      fscanf
    cmp     w0, #1
    beq     check_dim
    str     x0, [x29, filename]
    bl      fclose
    adr     x0, stderr
    str     x0, [x0]
    adr     x1, format
    bl      fprintf
    b       errexit
check_dim:
    mov     x27, #0
    mov     x26, #0
    ldr     x28, [x29, dim]
    cmp     x28, #0
    ble     wrong_dim
    cmp     x28, #20
    bgt     wrong_dim
    mul     x28, x28, x28
    mov     x25, matrix1
    b       scan_matrices
wrong_dim:
    ldr     x0, [x29, filestruct]
    bl      fclose
    adr     x0, stderr
    str     x0, [x0]
    adr     x1, size
    bl      fprintf
    b       errexit
scan_matrices: 
    ldr     x0, [x29, filestruct]
    adr     x1, formdouble
    lsl     x2, x27, #3
    
    add     x2, x2, x25 //do just mov
    add     x2, x29, x2
    
    bl      fscanf
    cmp     w0, #1
    beq     prescan
    ldr     x0, [x29, filestruct]
    bl      fclose
    adr     x0, stderr
    ldr     x0, [x0]
    ldr     x1, [x29, format]
    b       errexit
prescan:
    add     x27, x27, #1
    cmp     x27, x28
    bne     scan_matrices
    
    add     x26, x26, #1
    mov     x25, matrix2

    cmp     x26, #2
    beq     pre_multiply
    mov     x27, #0
    b       scan_matrices
pre_multiply:
    ldr     x0, [x29, filestruct]
    bl      fclose
    ldr     x28, [x29, dim]
    mov     x27, #0  // row
    mov     x26, #0  // column
    mov     x25, #-1 // column iteration
    adr     x0, stdout
    ldr     x0, [x0]
    adr     x1, mes
    bl      fprintf
matr_multiply:
    cmp     x27, x28     
    beq     end
    mov     x25, #-1
    fmov    d4, xzr // sum ij 
row_multiply:
    add     x25, x25, #1
    cmp     x25, x28
    beq     next_column

    mov     x6, matrix2
    mov     x5, matrix1

    
    mul     x3, x27, x28        // number in column
    add     x3, x3, x25         // + number in row
    lsl     x3, x3, #3

    add     x7, x3, x6             // bi
    add     x3, x3, x5             // ai
    add     x3, x3, x29
    add     x7, x7, x29
    ldr     d0, [x3]
    ldr     d2, [x7]


    mul     x7, x25, x28        //number in column
    add     x4, x26, x7
    lsl     x4, x4, #3
                                // bj
    add     x8, x4, x5             // aj
    add     x4, x4,  x6
    add     x4, x4, x29
    add     x8, x8, x29

    ldr     d1, [x4]
    ldr     d3, [x8]
    fmadd   d4, d0, d1, d4
    fmsub   d4, d2, d3, d4
    b       row_multiply
next_column:
    add     x26, x26, #1
    cmp     x26, x28
    beq     print_last_el
print_el:
    adr     x0, stdout
    ldr     x0, [x0]
    adr     x1, elem
    fmov    d0, d4
    bl      fprintf
    b       matr_multiply
print_last_el:
    adr     x0, stdout
    ldr     x0, [x0]
    adr     x1, enel
    fmov    d0, d4
    bl      fprintf
    mov     x26, #0
next_row:
    add     x27, x27, #1
    b       matr_multiply    
end:
    ldp     x29, x30, [sp]
    ldp     x28, x27, [sp, #16]
    ldp     x26, x25, [sp, #32]
    mov     x2, extra
    add     sp, sp, x2
    mov     w0, #0
    ret
    .size   main, .-main
    
