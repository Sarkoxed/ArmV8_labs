// uns 32a, 8b, 16c, 32d, 32e
// b*c + a/(d+e) - d*d/(b*e) + a*e
    .arch   armv8-a
    .data
    .align  3
res:    
    .skip   8
a:  .word   0xbeef
b:  .byte   0x10
c:  .hword  0xabcd

d:  .word   0x132344
e:  .word   0x1fbeea
//d:  .word   0x0
//e:  .word   0x0

    .text
    .align  2
    .global _start
    .type   _start, %function
_start:
    ADR     x0, a
    LDR     w1, [x0], #4
    LDRB    w2, [x0], #1
    LDRH    w3, [x0], #2
    LDP     w4, w5, [x0]
    
    ADDS    w6, w4, w5
    BEQ     _exception
    BCS     _exception
    UDIV    w6, w1, w6
    BCS     _exception
    MADD    w6, w2, w3, w6
    BCS     _exception

    UMULL   x7, w2, w5
    BEQ     _exception
    UMULL   x8, W4, W4
    UDIV    x8, x8, x7
    BCS     _exception
    
    UMULL   x7, w1, w5
    ADDS    x7, x7, w6, uxtw
    BCS     _exception

    SUBS    x7, x7, x8
    BCC     _exception
      
    ADR     x0, res
    STR     x9, [x0]
    MOV     x0, #0
    B       _exit

_exception:
    MOV     x0, #1
    B       _exit

_exit:
    MOV     x8, #93
    svc     #0
    .size   _start, _exit-_start
