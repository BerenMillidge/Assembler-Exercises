#oky, so this is where I start out on my own, with a function designed to square a number. It should be really simple

.section .data
#no data

.section .text
#no text

.globl _start
_start:

pushl $10	#push 5 onto stack for function to use
call square

movl %eax, %ebx
movl $1, %eax
int $0x80	#end

.type square, @function
square:
pushl %ebp	#save prev ret address
movl %esp, %ebp	#setup stack frame
movl 8(%ebp), %eax	#get param and put in eax
movl %eax, %ebx		#copy eax to ebx
imull %ebx, %eax	#multiply the two together
movl %ebp, %esp
popl %ebp
ret

