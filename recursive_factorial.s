#This program is to compute the factorial of the number in a recursive way, because there's nothing like being needlessly difficul and show-offy

.section .data
#no global data
.section .text

.globl _start
.globl factorial # this says the function we define later is global

_start:

pushl $4 # our number to get the factorial of

call factorial
addl $4, %esp 	# get rid of the parameter we put on the stack
movl %eax, %ebx # transfers return value to ebx to prepare to exit
movl $1, %eax	# 1 code for exit system call
int $0x80

#now for the meat of the implementation, the actual recursive factorial function:
.type factorial, @function
factorial:
pushl %ebp 	#we have to save where we were before going into this functoin
movl %esp, %ebp	# set the base pointer to where the function actually is
movl 8(%ebp), %eax	#this sets the first argument to eax, because 4 is the return address from the base pointer
cmpl $1, %eax	# if number is 1 we're done
je end_factorial
decl %eax
pushl %eax
call factorial
movl 8(%ebp), %ebx
imull %ebx, %eax

end_factorial:
movl %ebp, %esp
popl %ebp
ret

#this isn't actualy that difficult at all really. Assembly is pretty fun, which is surprising!
