#We do hello world in assembly, both with and without a library call to the prinf function

##WITHOUT##

.include "linux.s"
.section .data

helloworld:
.ascii "hello world!\n"
helloworld_end:
.equ helloworld_len, helloworld_end - helloworld

.section .text
.globl _start
_start:

movl $STDOUT, %ebx
movl $helloworld, %ecx
movl $helloworld_len, %edx
movl $SYS_WRITE, %eax
int $LINUX_SYSCALL

movl $0, %ebx
movl $SYS_EXIT, %eax
int $LINUX_SYSCALL

#It actually works! Assembler is pretty awesome!

#now with library

#.globl _start2
#_start2:
#pushl $helloworld
#call printf
#movl $0, %ebx
#movl $SYS_EXIT, %eax
#int $LINUX_SYSCALL

## Well, apparently this doesn't work because I'm on a 64 bit machine which doesn't have the 32 bit libraries(!) which is just great. I guess I'm going to have to do everything from scratch! oh well
