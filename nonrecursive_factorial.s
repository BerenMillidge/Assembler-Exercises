#This is where I do the non-recursive factorial exercise, which should be trickier. We'll have to do this via a loop which increments stuff, and then do strange memory manipulations which stores where we are and so forth. It'll probably be quite involved, but I've no doubt we can manage it.

.section .data
#no data

.section .text
#no test

.globl _start
_start:

pushl $4
call factorial
movl %eax, %ebx
movl $1, %eax
int $0x80
#this was just the standard calling function for simple routine and exiting

.type factorial, @function
factorial:
pushl %ebp
movl %esp, %ebp	#standard functoin setup for the stack frame
movl 8(%ebp), %eax	#store our initial numbe in eax
movl %eax, %ebx
decl %ebx
start_loop:
cmpl $1, %ebx	#compare the index to 1
je end_loop
imull %ebx, %eax
decl %ebx
jmp start_loop

end_loop:
movl %ebp, %esp
popl %ebp
ret

#If this works I'll be shocked! IT DOES!
