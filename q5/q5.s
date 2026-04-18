.section .data
filename:   .asciz "input.txt"
yes_msg:    .asciz "Yes\n"
no_msg:     .asciz "No\n"

.section .bss
left_char:  .skip 1
right_char: .skip 1

.section .text
.globl _start

# Strategy: O(n) time, O(1) space palindrome check using two file seeks.
# 1. Open the file.
# 2. Use lseek(fd, 0, SEEK_END) to get file size.
# 3. Use two pointers: left starting at offset 0, right starting at size-1.

_start:
    # open("input.txt", O_RDONLY=0)
    la   a0, filename
    li   a1, 0
    li   a7, 56           # syscall: openat (use -1 for AT_FDCWD in a0 with openat)
    # On RISC-V Linux, open() is syscall 56 (openat), needs AT_FDCWD in a0
    li   a0, -100         # AT_FDCWD
    la   a1, filename
    li   a2, 0            # O_RDONLY
    li   a3, 0            # mode (ignored for O_RDONLY)
    li   a7, 56           # openat
    ecall
    mv   s0, a0           # s0 = fd

    # lseek(fd, 0, SEEK_END=2) to get file size
    mv   a0, s0
    li   a1, 0
    li   a2, 2            # SEEK_END
    li   a7, 62           # lseek
    ecall
    mv   s1, a0           # s1 = file size

    # Edge case: empty file is a palindrome
    beqz s1, palindrome_confirmed

    # Initialize two pointers
    li   s2, 0            # left  = 0
    addi s3, s1, -1       # right = size - 1

loop:
    # If left >= right, all characters matched
    bge  s2, s3, palindrome_confirmed

    # Seek to left position and read 1 byte
    mv   a0, s0
    mv   a1, s2
    li   a2, 0            # SEEK_SET
    li   a7, 62           # lseek
    ecall

    mv   a0, s0
    la   a1, left_char
    li   a2, 1
    li   a7, 63           # read
    ecall

    # Seek to right position and read 1 byte
    mv   a0, s0
    mv   a1, s3
    li   a2, 0            # SEEK_SET
    li   a7, 62           # lseek
    ecall

    mv   a0, s0
    la   a1, right_char
    li   a2, 1
    li   a7, 63           # read
    ecall

    # Compare left_char and right_char
    la   t0, left_char
    lb   t1, 0(t0)
    la   t0, right_char
    lb   t2, 0(t0)
    bne  t1, t2, not_palindrome

    # Advance pointers inward
    addi s2, s2, 1
    addi s3, s3, -1
    j    loop

not_palindrome:
    # Print "No\n" (3 bytes) to stdout
    li   a0, 1
    la   a1, no_msg
    li   a2, 3
    li   a7, 64           # write
    ecall
    j    exit             # <-- CRITICAL: must jump past palindrome_confirmed

palindrome_confirmed:
    # Print "Yes\n" (4 bytes) to stdout
    li   a0, 1
    la   a1, yes_msg
    li   a2, 4
    li   a7, 64           # write
    ecall

exit:
    # Close the file descriptor
    mv   a0, s0
    li   a7, 57           # close
    ecall

    # exit(0)
    li   a7, 93
    li   a0, 0
    ecall
