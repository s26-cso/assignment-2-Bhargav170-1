.section .data
filename:   .asciz "input.txt"
yes_msg:    .asciz "Yes\n"
no_msg:     .asciz "No\n"

.section .bss
left_char:  .skip 1
right_char: .skip 1

.section .text

.globl _start


# important to access the end of file and then start two pointers to check for palindromes.
_start:
    la a0, filename
    li a1, 0
    li a7, 56
    ecall
    addi s0, a0, 0

    addi a0, s0, 0
    li a1, 0
    li a2, 2
    li a7, 62
    ecall
    addi s1, a0, 0

    li s2, 0
    addi s3, s1, -1

    jal ra, loop

    #start the loop from starting and the endling location of the file.

loop:
    bge s2, s3, palindrome_confimed

    addi a0, s0, 0
    addi a1, s2, 0
    li a2, 0
    li a7, 62
    ecall

    addi a0, s0, 0
    la a1, left_char
    li a2, 1
    li a7, 63
    ecall

    addi a0, s0, 0
    addi a1, s3, 0
    li a2, 0
    li a7, 62
    ecall

    addi a0, s0, 0
    la a1, right_char
    li a2, 1
    li a7, 63
    ecall

    la t0, left_char
    lb t1, 0(t0)

    la t0, right_char
    lb t2, 0(t0)

    bne t1, t2, not_palindrome

    addi s2, s2, 1
    addi s3, s3, -1
    j loop


not_palindrome:
    li a0, 1
    la a1, no_msg
    li a2, 3
    li a7, 64
    ecall

palindrome_confimed:
    li a0, 1
    la a1, yes_msg
    li a2, 4
    li a7, 64
    ecall
    j exit


exit:
    li a7, 93
    li a0, 0
    ecall
