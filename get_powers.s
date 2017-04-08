#So the aim of this is to illustrate how functions work in assembler, and we'll do this by computing the powers and exponents of random numbers by calling a function which can do that for any base/exponent combination.

.section .data
.section .text

.globl _start
_start:

push $2	#push our second argument (exponent)
push $2	#push our first argument (base)
call power	#call the function
addl $8, %esp	# move the stack pointer back as we've used up our values
pushl %eax	#push the value of %eax to the stack, which is the return value of the function

#start with the second numbers
push $0
push $5
call power
addl $8, %esp

#first answer already now on stack. Second is on eax, so we save first from stack into ebx
popl %ebx

addl %eax, %ebx	#we add thetwo values together, the result is in ebx
movl $1, %eax 	#prepare for existing
int $0x80	#system call for exit; result in ebx

#Now we set up our power function
.type power, @function
power:

pushl %ebp	#we save the old base pointer
movl %esp, %ebp	#we move the stack pointer to the base pointer
subl $4, %esp	#get a word of storage for variables

movl 8(%ebp), %ebx	#first argument in ebx
movl 12(%ebp), %ecx

movl %ebx, -4(%ebp)	#we store the current result

power_loop_start:
cmpl $0, %ecx	#if power is 0, we want to return 1
je end_zero
cmpl $1, %ecx	#if the power is 1 we're finished
je end_power
movl -4(%ebp), %eax	#move result into eax as return register
imull %ebx, %eax	#multiply base number by current result, and store in eax
movl %eax, -4(%ebp)	#store new result
decl %ecx	#decrement the index
jmp power_loop_start

end_zero:
movl $1, %eax
movl %ebp, %esp
popl %ebp
ret

end_power:
movl -4(%ebp), %eax	#return value goes to eax
movl %ebp, %esp
popl %ebp
ret
