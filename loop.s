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

