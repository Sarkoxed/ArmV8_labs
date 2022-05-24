    .arch   armv8-a
    .data
n:  .byte   6
m:  .byte   5
matr:
//    .byte   -79, 50, 87, -100, -40
//    .byte   95, -105, -43, 10, -51
//    .byte   -59, 31, 127, -50, 45
//    .byte   -65, -122, 27, -7, -13
//    .byte   -19, 45, -8, 65, -105
//    .byte   59, -47, 116, 15, -113

//     .byte   87, -100, -79, 50, -40
//     .byte   -43, 10, 95, -105, -51
//     .byte   127, -50, -59, 31, 45
//     .byte   27, -7, -65, -122, -13
//     .byte   -8, 65, -19, 45, -105
//     .byte   116, 15, 59, -47, -113
	.byte 95, 69, 40, -61, -82
	.byte -20, -105, -105, -96, 102
	.byte 97, 118, -12, -123, 58
	.byte 11, 41, 65, -115, -30
	.byte 118, -48, 113, 69, -77
	.byte 15, -29, 99, 53, 56
    .align  1
sums:
    .skip   10
    .align  3
pointers:
    .byte   0, 1, 2, 3, 4 
    .text
    .align  2
    .global _start
    .type   _start, %function

_start:
    ADR     x0, n
    LDRB    w0, [x0]
    ADR     x1, m
    LDRB    w1, [x1]
    ADR     x29, matr
    MOV     x8, x29
    ADR     x3, sums
    ADR     x4, pointers
    MOV     w5, #0
    MOV     w20, #1
    NEG     w20, w20
    MOV     w25, #0
SUM:
    CMP     w5, w1  // columnss
    BGE     PRED_SOR
    MOV     w6, #0  // rows
    MOV     w7, #0  // sum
SUM1:
    CMP     w6, w0
    BGE     SUM_R
    MUL     w2, w1, w6
    ADD     w2, w2, w5
    LDRSB   w10, [x8, w2, uxtw]
    ADD     w7, w7, w10
    ADD     w6, w6, #1
    B       SUM1
SUM_R:  
    LSL     w2, w5, #1
    STRH    w7, [x3, w2, uxtw]
    ADD     w5, w5, #1
    B       SUM
PRED_SOR:
    MOV     w22, #0
    MOV     w23, w1
SOR:
    CMP     w25, #1
    BEQ     PERMUTE
    MOV     w25, #1

    NEG     w20, W20
    ADD     w5, w22, w20      // beg
    MOV     w6, w23           // end

    SUB     w23, w22, w20
    SUB     w22, w6, w20
    SUB     w22, w22, w20

    SUB     w8, w5, W20       // prev pos
    LSL     w24, w8, #1
    LDRSH   w12, [x3, w24, uxtw]
ITERATE: 
    MOV     w9, w12
    MUL     w16, w20, w5
    MUL     w17, w20, w6
    CMP     w16, w17
    BGT     PERMUTE
    BEQ     SOR 

    LSL     w10, w5, #1 // cur
    LDRSH   w12, [x3, w10, uxtw]
    MOV     w8, w5 
    ADD     w5, w5, w20

    MUL     w16, w12, w20
    MUL     w17, w9, w20
    CMP     w17, w16
    .IFDEF  rev
    BLE     ITERATE
    .ELSE
    BGE     ITERATE
    .ENDIF
    
    MOV     w25, #0
    SUB     w7, w8, w20 
    LDRSB   w13, [x4, w8, uxtw]
    LDRSB   w14, [x4, w7, uxtw]
    STRB    w13, [x4, w7, uxtw]
    STRB    w14, [x4, w8, uxtw]

    STRH    w9, [x3, w10, uxtw]
    LSL     w10, w7, #1
    STRH    w12,[x3, w10, uxtw]
    MOV     w12, w9
    B       ITERATE
PERMUTE:
    MOV     w5, #0
LO1:
    CMP     w5, w1
    BEQ     _exit
    LDRSB   w6, [x4, w5, uxtw]
    CMP     w5, w6
    BNE     SWAP
    ADD     w5, w5, #1
    B       LO1
SWAP:
    MOV     w8, #0
LO2:
    CMP     w8, w0
    BEQ     LO3
    
    MUL     w11, w1, w8
    ADD     w12, w5, w11
    ADD     w13, w6, w11
    LDRSB   w10, [x29, w12, uxtw]
    LDRSB   w14, [x29, w13, uxtw]
    STRB    w10, [x29, w13, uxtw]
    STRB    w14, [x29, w12, uxtw]
    
    ADD     w8, w8, #1
    B       LO2
LO3:
    ADD     w11, w5, #1
LO4:
    LDRSB   w12, [x4, w11, uxtw]
    CMP     w12, w5
    ADD     w11, w11, #1
    BNE     LO4
    SUB     w11, w11, #1
    STRB    w6, [x4, w11, uxtw]
    ADD     w5, w5, #1
    B       LO1
_exit:
    MOV     x0, #0
    MOV     x8, #93
    SVC     #0
    .size   _start, .-_start
