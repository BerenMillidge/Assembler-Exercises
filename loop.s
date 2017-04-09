#A loop that prints the numbers up to a value
#if we have fun, we could try to write fizzbuzz in assembler, that will be a fun goal tbh

.include "linux.s"

.section .data
helloworld:
.ascii "hello world!\n"
helloworld_end:
.equ helloworld_len, helloworld_end - helloworld

value: 
.byte 10

.section .text

.globl _start
_start:
pushl $value
begin_loop:
popl %eax
cmpl $0, %eax
je end_loop
decl %eax
pushl %eax
movl $STDOUT, %ebx
movl %eax, %ecx
#movl $4, %edx
movl $SYS_WRITE, %eax
int $LINUX_SYSCALL
jmp begin_loop



end_loop:
movl $SYS_EXIT, %eax
movl $0, %ebx
int $LINUX_SYSCALL


## okay, the reason this isn't working is that we need to convert integers to strings before they can be displayed... nothign to do with my code really. So, let's definte a function that does this

.equ ST_VALUE, 8
.equ ST_BUFFER, 12

.type integer2string, @function
integer2string:
#This takes two parameters, an integer to convert, and a string buffer filled with null characters The buffer will be big enough to store the entire number of a string, and include a trailing null character
pushl %ebp
movl %esp, %ebp

#current character count- start as zero
xorl %ecx, %ecx
movl ST_VALUE(%ebp), %eax # get the function parameter value from the string
movl $10, %edi	#so we store the divisor (as we're wanting it in decimal!)

conversion_loop:
#we first divide on the edx:eax combined register, so first we claear out edx
xorl %edx, %edx
divl %edi	#not sure howthis knows the right register to divde things by?
addl $'0', %edx	#this will get us the ascii character value, as we start at the value for 0 and add the number (as the numbers are laid out in a simple increasing fashion in the ascii table)
pushl %edx 	#push this to the stack, when we're done we'll pop them off in inverse order!
incl %ecx	#ecx is the character count

cmpl $0, %eax	#check to see if the remainder in eax is 0
je end_conversion_loop	#if it is, skip to the end

jmp conversion_loop	#skip back to beginning of loop if not

end_conversion_loop:
movl ST_BUFFER(ebp), %edx	#start edx at the right place, this is the buffer address
popl %eax
movb %al, (%edx)
decl %ecx
incl %edx

cmpl $0, %ecx
je end_copy_reversing_loop
jmp copy_reversing_loop

end_copy_reversing_loop:
movb $0, (%edx)
movl %ebp, %esp
popl %ebp
ret

#well, unless we want to pick this up again, it looks like we're mostly done with assembly. I think it was pretty useful, even though I didn't get as far as I'd like. I can perhaps do a bit later, but the other book apparently uses HLA, which is weird

