.globl main

.section .rodata
fmt_d:  .string "%d"    # print an integer
fmt_sp: .string " "     # space between elements
fmt_nl: .string "\n"    # trailing newline

# -----------------------------------------------------------------------
# Q2 – Next Greater Element (position / 0-based index)
#
# For each element in argv[1..n], output the 0-based index of the first
# element to its right that is strictly greater, or -1 if none exists.
#
# Algorithm: single right-to-left pass with a monotonic (decreasing) stack.
# Time: O(n)   Space: O(n)
#
# Callee-saved register map (survive across malloc / atoi / printf calls):
#   s0 = argv  (char**)
#   s1 = arr   (int*, parsed values)
#   s2 = stk   (int*, index stack)
#   s3 = res   (int*, result array)
#   s4 = n     (number of elements = argc-1)
#   s5 = stk_top  (-1 means empty)
#   s6 = loop variable i
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
    sd   s6, 16(sp)

    # Save argv and n BEFORE any call clobbers a0/a1
    mv   s0, a1             # s0 = argv (save immediately)
    addi s4, a0, -1         # s4 = n = argc - 1

    # Allocate arr[n]  (4 bytes per int)
    slli a0, s4, 2
    call malloc
    mv   s1, a0             # s1 = arr

    # Allocate stk[n]
    slli a0, s4, 2
    call malloc
    mv   s2, a0             # s2 = stk

    # Allocate res[n], then initialise every element to -1
    slli a0, s4, 2
    call malloc
    mv   s3, a0             # s3 = res

    li   s6, 0
init_res:
    bge  s6, s4, parse_args
    slli t0, s6, 2
    add  t0, s3, t0
    li   t1, -1
    sw   t1, 0(t0)          # res[s6] = -1
    addi s6, s6, 1
    j    init_res

    # --- Parse argv[1..n] into arr[] ---
parse_args:
    li   s6, 0              # s6 = index 0..n-1
parse_loop:
    bge  s6, s4, algo_start
    addi t0, s6, 1          # argv index = s6 + 1
    slli t0, t0, 3          # * 8 (pointer width)
    add  t0, s0, t0
    ld   a0, 0(t0)          # a0 = argv[s6+1]  (string)
    call atoi               # a0 = integer
    slli t0, s6, 2
    add  t0, s1, t0
    sw   a0, 0(t0)          # arr[s6] = integer
    addi s6, s6, 1
    j    parse_loop

    # --- Monotonic stack pass (right to left) ---
algo_start:
    li   s5, -1             # s5 = stk_top  (-1 = empty)
    addi s6, s4, -1         # s6 = i = n-1

main_loop:
    blt  s6, zero, print_start

    # Load arr[i] into t2
    slli t0, s6, 2
    add  t0, s1, t0
    lw   t2, 0(t0)          # t2 = arr[i]

    # While stack not empty AND arr[stk[top]] <= arr[i]: pop
pop_loop:
    blt  s5, zero, pop_done     # stack empty
    slli t0, s5, 2
    add  t0, s2, t0
    lw   t1, 0(t0)              # t1 = stk[top]  (an index)
    slli t3, t1, 2
    add  t3, s1, t3
    lw   t3, 0(t3)              # t3 = arr[stk[top]]
    bgt  t3, t2, pop_done       # strictly greater -> stop
    addi s5, s5, -1             # pop
    j    pop_loop

pop_done:
    # If stack not empty: res[i] = stk[top]
    blt  s5, zero, do_push
    slli t0, s5, 2
    add  t0, s2, t0
    lw   t1, 0(t0)              # t1 = stk[top]
    slli t0, s6, 2
    add  t0, s3, t0
    sw   t1, 0(t0)              # res[i] = stk[top]
    # (else res[i] stays -1)

do_push:
    # stk[++top] = i
    addi s5, s5, 1
    slli t0, s5, 2
    add  t0, s2, t0
    sw   s6, 0(t0)

    addi s6, s6, -1         # i--
    j    main_loop

    # --- Print res[] space-separated with newline ---
print_start:
    li   s6, 0
print_loop:
    bge  s6, s4, print_done

    # Print space before every element except the first
    beqz s6, skip_space
    la   a0, fmt_sp
    call printf
skip_space:
    slli t0, s6, 2
    add  t0, s3, t0
    lw   a1, 0(t0)          # value to print
    la   a0, fmt_d
    call printf             # printf("%d", res[s6])

    addi s6, s6, 1
    j    print_loop

print_done:
    la   a0, fmt_nl
    call printf             # print newline

    li   a0, 0
    ld   ra, 72(sp)
    ld   s0, 64(sp)
    ld   s1, 56(sp)
    ld   s2, 48(sp)
    ld   s3, 40(sp)
    ld   s4, 32(sp)
    ld   s5, 24(sp)
    ld   s6, 16(sp)
    addi sp, sp, 80
    ret
