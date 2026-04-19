.section .data
file: .asciz "input.txt"
Yes:  .asciz "Yes\n"
No: .asciz "No\n"

.bss
buffer1: .space 1
buffer2: .space 1
.section .text
.globl main 
main:
   addi sp, sp, -32 #saving the save registars because we need the orignal value in the end for program to actually work
    sd s0, 24(sp)
    sd s1, 16(sp)
    sd s2, 8(sp)
    sd s3, 0(sp)
    addi a7, x0, 56   #to call openfile a7=56
    addi a0, x0, -100  #a0=-100 means use the same directory
1:  auipc a1, %pcrel_hi(file)       # %pcrel_hi gives upper 20 bits of PC-relative offset to file label, linker fills this at link time
    addi  a1, a1, %pcrel_lo(1b)     # %pcrel_lo gives lower 12 bits using same target as auipc at label 1b, works across sections
    addi a2, x0, 0 #a2 is flag 0 mean read only 1 mean write only 2 means read+write while 64 is create a file
    addi a3, x0, 0 #file permission only required when creating a new file not used here
    ecall
    addi s0, a0, 0 #s0=a0=file descriptor fd 
    addi a7, x0, 62 #a7=62 for fseek
    addi a0, s0, 0 #a0= fd
    addi a1, x0, 0 #a1= offset we do it 0 because we want to be exact end not move from end
    addi a2, x0, 2   # a2=2 is SEEK_END that is from where we have to go to the location of offset 0 is begn and 1 is curr pos
    ecall #now a0 has the new position which is last of the file
    addi s1, a0, 0   #s1 has now the last file position ie n
    addi s2, x0, 0 #s2=left=0 
    addi s3, s1, -1 #s3=right=n-1
    loop:
      bge s2, s3, ypaln
      addi a7, x0, 62 #lseek
      addi a0, s0, 0 #fd
      addi a1, s2, 0 #offset 
      addi a2, x0, 0 #from start
      ecall
      addi a7, x0, 63 #a7=63 is read 
      addi a0, s0, 0 #a0=fd
2:    auipc a1, %pcrel_hi(buffer1)  
      addi  a1, a1, %pcrel_lo(2b)  
      addi a2, x0, 1 #a2 = number of bytes to read 
      ecall 
      addi a7, x0, 62
      addi a0, s0, 0
      addi a1, s3, 0 #just changed the offset to right from left all same so this will go to str[right]
      addi a2, x0, 0
      ecall
      addi a7, x0, 63
      addi a0, s0, 0
3:    auipc a1, %pcrel_hi(buffer2)  
      addi  a1, a1, %pcrel_lo(3b)   
      addi a2, x0, 1
     ecall
4:   auipc t0, %pcrel_hi(buffer1)  
     addi  t0, t0, %pcrel_lo(4b)    
    lb t1, 0(t0)
5:   auipc t0, %pcrel_hi(buffer2)  
     addi  t0, t0, %pcrel_lo(5b)    
    lb t2, 0(t0)
    bne t1, t2, notpaln
    addi s2, s2, 1 #l=l+1
    addi s3, s3, -1 #r=r+1
    beq x0, x0, loop
    notpaln:
      addi a7, x0, 64 #for print a7=64
    addi a0, x0, 1 #its fd here 1 is stdout 0 is stdin and 2 is stdout we can use other fd also to write i other file
6:  auipc a1, %pcrel_hi(No)       
    addi  a1, a1, %pcrel_lo(6b)     
    addi a2, x0, 3 #a2- no. of bytes here 3
    ecall
     beq x0, x0, end
     ypaln:
       addi a7, x0, 64
    addi a0, x0, 1
7:  auipc a1, %pcrel_hi(Yes)        
    addi  a1, a1, %pcrel_lo(7b)     
    addi a2, x0, 4
    ecall
    end:
   
    addi a7, x0, 57
    addi a0, s0, 0
    ecall #close the file it need a8=57 and a0=fd
    # restore registers and stack
   ld s0, 24(sp)
ld s1, 16(sp)
ld s2,  8(sp)
ld s3,  0(sp)
addi sp, sp, 32
   
    addi a7, x0, 93
    addi a0, x0, 0
    ecall #exit call a7=93 and a0=0
