.globl main

.section .rodata
filename: .string "input.txt"
yes_msg:  .string "Yes\n"
no_msg:   .string "No\n"

# -----------------------------------------------------------------------
# Q5 – Palindrome check on an arbitrarily large file.
# O(n) time, O(1) space.
#
# Method: two-pointer with lseek + read.
# Compiled with: gcc q5.s -o q5  (libc, entry = main)
#
# Stack frame (80 bytes, 16-byte aligned):
#   sp+ 0 : left_char  buffer (1 byte used, 8 bytes reserved)
#   sp+ 8 : right_char buffer (1 byte used, 8 bytes reserved)
#   sp+16 : padding
#   sp+24 : saved s5
#   sp+32 : saved s4
#   sp+40 : saved s3  (right offset)
#   sp+48 : saved s2  (left  offset)
#   sp+56 : saved s1  (file size)
#   sp+64 : saved s0  (fd)
#   sp+72 : saved ra
# -----------------------------------------------------------------------

main:
    addi sp, sp, -80
    sd   ra, 72(sp)
    sd   s0, 64(sp)
    sd   s1, 56(sp)
    sd   s2, 48(sp)
    sd   s3, 40(sp)
    sd   s4, 32(sp)
    sd   s5, 24(sp)

    # --- open("input.txt", O_RDONLY) ---
    la   a0, filename
    li   a1, 0              # O_RDONLY
    call open
    mv   s0, a0             # s0 = fd

    # --- get file size: lseek(fd, 0, SEEK_END) ---
    mv   a0, s0
    li   a1, 0
    li   a2, 2              # SEEK_END
    call lseek
    mv   s1, a0             # s1 = file size

    beqz s1, is_palindrome  # empty file is trivially a palindrome

    li   s2, 0              # left  pointer = byte offset 0
    addi s3, s1, -1         # right pointer = byte offset (size - 1)

loop:
    bge  s2, s3, is_palindrome   # pointers met/crossed -> all matched

    # --- seek to left offset, read 1 byte into sp+0 ---
    mv   a0, s0
    mv   a1, s2             # left offset
    li   a2, 0              # SEEK_SET
    call lseek

    mv   a0, s0
    addi a1, sp, 0          # buffer at sp+0
    li   a2, 1
    call read

    # --- seek to right offset, read 1 byte into sp+8 ---
    mv   a0, s0
    mv   a1, s3             # right offset
    li   a2, 0              # SEEK_SET
    call lseek

    mv   a0, s0
    addi a1, sp, 8          # buffer at sp+8
    li   a2, 1
    call read

    # --- compare using s4/s5 (callee-saved, safe across any future call) ---
    lb   s4, 0(sp)          # left  char
    lb   s5, 8(sp)          # right char
    bne  s4, s5, not_palindrome

    addi s2, s2, 1          # left++
    addi s3, s3, -1         # right--
    j    loop

not_palindrome:
    la   a0, no_msg
    call printf
    j    done

is_palindrome:
    la   a0, yes_msg
    call printf

done:
    mv   a0, s0
    call close

    li   a0, 0
    ld   ra, 72(sp)
    ld   s0, 64(sp)
    ld   s1, 56(sp)
    ld   s2, 48(sp)
    ld   s3, 40(sp)
    ld   s4, 32(sp)
    ld   s5, 24(sp)
    addi sp, sp, 80
    ret
