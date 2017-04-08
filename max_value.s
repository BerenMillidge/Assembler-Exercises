#This program finds the maximum value in a list of data, written in assembler.
#our registers are as follows %edi is the index register, %ebx is the largest data item found, %eax is the current data item

.section .data

data_items:
.long 3,67,34,222,45,75,432,0,54,33,55,32,11,22,66,9,1234,0
#a 0 is used to terminate our list.

.section .text

.globl _start
_start:

movl $0, %edi	#we move 0 into the index register to start
movl data_items(,%edi,4), %eax	#we load the first byte of data
movl %eax, %ebx	#since this is the first item, it is also the largest

start_loop:
cmpl $0, %eax # check if we've hit the end
je loop_exit	#quit if we have
incl %edi	#increment the index
movl data_items(,%edi,4), %eax	#move next set of items into storage
cmpl %ebx, %eax	#compare current and max value
jle start_loop	#jump to loop beginning if the new one isn't the biggest

movl %eax, %ebx	#if it is the biggest, move the value to the largest
jmp start_loop 	#jump to loop beginning

loop_exit:	#exit the loop. I think this is a kind of primitive function!
	movl $1, %eax 	#1 isthe system exit call. ebx already has the max number
	int $0x80

#It fails if numbers greater than 255 are used in the list because there are only 255 system calls possible in the %ebx so it goes weird
