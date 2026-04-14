.globl main

.section .rodata
fmt: .string "%d "      # format string for printing integers
nl:  .string "\n"       # newline string

.section .text

main:
    addi sp, sp, -48
    sd ra, 40(sp)
    sd s0, 32(sp)   # save pointer to arr (input array)
    sd s1, 24(sp)   # save pointer to stack (index stack)
    sd s2, 16(sp)   # save pointer to result array (next greater indices)
    sd s3, 8(sp)    # save n (number of elements)

    mv t0, a0          # argc (argument count)
    mv t1, a1          # argv (argument vector)

    addi s3, t0, -1    # n = argc - 1 (ignore program name)

    slli t2, s3, 2     # compute size in bytes (n * 4)

    # allocate arr
    mv a0, t2
    call malloc        # allocate memory for input array
    mv s0, a0

    # allocate stack
    mv a0, t2
    call malloc        # allocate memory for stack (stores indices)
    mv s1, a0

    # allocate result
    mv a0, t2
    call malloc        # allocate memory for result array
    mv s2, a0

    # fill arr using atoi (convert input strings to integers)
    li t3, 1           # argv index starts from 1
    li t4, 0           # arr index starts from 0

    # Traverse input arguments and store integers in arr
fill_loop:
    bge t3, t0, start_stack_insertion

    slli t5, t3, 3
    add t6, t1, t5
    ld a0, 0(t6)
    call atoi         # convert string to integer

    slli t5, t4, 2
    add t6, s0, t5
    sw a0, 0(t6)      # store value in arr

    addi t3, t3, 1
    addi t4, t4, 1
    j fill_loop

# Use a monotonic stack to find next greater element index for each element
start_stack_insertion:

    addi t4, s3, -1    # start from last index (i = n-1)
    li t5, -1          # initialize stack top = -1 (empty stack)

# Main loop traversing array from right to left
main_loop:
    blt t4, zero, done

# Pop elements from stack while they are smaller than current element
while_loop:
    blt t5, zero, while_done

    slli t6, t5, 2
    add t7, s1, t6
    lw t8, 0(t7)       # stack[top] (index)

    slli t9, t8, 2
    add t10, s0, t9
    lw t11, 0(t10)     #  access the element ar arr[stack[top]]

    slli t12, t4, 2
    add t13, s0, t12
    lw t14, 0(t13)     # arr[i]

    ble t11, t14, pop_stack  # pop if stack element <= current
    j while_done

pop_stack:
    addi t5, t5, -1    # decrement stack top
    j while_loop

while_done:

    slli t6, t4, 2
    add t7, s2, t6     # address of result[i]

    blt t5, zero, no_greater  # if stack empty, no greater element

    slli t8, t5, 2
    add t9, s1, t8
    lw t10, 0(t9)
    sw t10, 0(t7)      # store index of next greater element
    j push

# If no greater element exists, store -1. (as given in the question)
no_greater:
    li t11, -1
    sw t11, 0(t7)

# Push current index onto stack
push:
    addi t5, t5, 1
    slli t6, t5, 2
    add t7, s1, t6
    sw t4, 0(t7)       # push index i onto stack

    addi t4, t4, -1    # move to previous element
    j main_loop

done:

    li t4, 0

# Print result array (indices of next greater elements)
print_loop:
    bge t4, s3, print_done

    slli t5, t4, 2
    add t6, s2, t5
    lw a1, 0(t6)

    la a0, fmt
    call printf        # print each result element.

    addi t4, t4, 1
    j print_loop

print_done:
    la a0, nl
    call printf        # print newline

    ld ra, 40(sp)
    ld s0, 32(sp)
    ld s1, 24(sp)
    ld s2, 16(sp)
    ld s3, 8(sp)

    addi sp, sp, 48

    li a0, 0
    ret
