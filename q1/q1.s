.globl make_node
.globl insert
.globl get
.globl getAtMost

make_node:
addi sp, sp, -16
sw   ra, 12(sp)
sw   a0, 8(sp)                           # store input value temporarily

li   a0, 12
call malloc                               # allocate memory for new node (dynamic allocation) alternatively- fixed size memory allocation allowed.

lw   t0, 8(sp)
sw   t0, 0(a0)                            # assign node value
sw   zero, 4(a0)                          # initialize left child as NULL
sw   zero, 8(a0)                          # initialize right child as NULL

lw   ra, 12(sp)
addi sp, sp, 16
ret                                       # return pointer to new node


insert:
addi sp, sp, -32
sw   ra, 28(sp)
sw   s0, 24(sp)
sw   s1, 20(sp)

addi s0, a0, 0                           # current node (root)
addi s1, a1, 0                           # value to insert

beq  s0, zero, inssert_empty              # if tree empty → create node

lw   t0, 0(s0)                           # current node value
                
beq  s1, t0, insert_done                     # if value already exists → do nothing
blt  s1, t0, insert_at_left                     # if smaller → go to left subtree

insert_at_right:
lw   a0, 8(s0)
addi a1, s1, 0
call insert                               # recursively insert into right subtree
sw   a0, 8(s0)                            # update right child pointer
j    insert_done

insert_at_left:
lw   a0, 4(s0)
addi a1, s1, 0
call insert                              # recursively insert into left subtree
sw   a0, 4(s0)                           # update left child pointer
j    insert_done

inssert_empty:
addi a0, s1, 0
call make_node                           # create node if position is NULL
j    ins_ret

insert_done:
addi a0, s0, 0                           # return original root

ins_ret:
lw   s1, 20(sp)
lw   s0, 24(sp)
lw   ra, 28(sp)
addi sp, sp, 32
ret


get:
get_loop:
beq  a0, zero, get_done                 # if node is NULL → not found

lw   t0, 0(a0)

beq  t0, a1, get_done                   # if value matches → return node
blt  a1, t0, get_left                   # if search value smaller → go left

lw   a0, 8(a0)                           # if larger → go right
j    get_loop

get_left:
lw   a0, 4(a0)                           # move to left subtree
j    get_loop

get_done:
ret                                     # return found node or NULL


getAtMost:
addi t0, zero, -1                       # keep track of best ≤ value

gam_loop:
beq  a1, zero, gam_done                 # if node is NULL → stop
lw   t1, 0(a1)

blt  a0, t1, gam_left                   # if node value > target → go left
addi t0, t1, 0                          # update best candidate
beq  t0, a0, gam_done                   # if exact match → stop


lw   a1, 8(a1)                          # try finding larger valid value on right
j    gam_loop




gam_left:
lw   a1, 4(a1)                          # move left to find smaller values
j    gam_loop

gam_done:
addi a0, t0, 0                          # return best found value
ret
