#the opint of this is to mostly copy their miplementation for file uppercasing. Hopefully by actually writing it out by hand, it will stick considerably more. anyhow, here it is. there will probably be a few modifications by the end as I complete their additional exercises with it and tinker with it, and so forth.
#Basically this is to copy an input file into an output file, but having uppercased the output file.

.section .data
#CONSTANTS

.equ SYS_OPEN, 5
.equ SYS_WRITE, 4
.equ SYS_READ, 3
.equ SYS_CLOSE, 3
.equ SYS_EXIT,1
.equ O_RDONLY,0
.equ O_CREAT_WRONGLY_TRUNC, 03101
.equ STDIN, 0
.equ STDOUT, 1
.equ STDERR, 2

#SYSTEM CALL INTERRUPTS
.equ LINUX_SYSCALL, 0x80
.equ END_OF_FILE, 0
.equ NUMBER_ARGUMENTS, 2

.section .bss
#This is where we put our buffer - the data from the file is loaded here, modified, and then written to other files
.equ BUFFER_SIZE, 500
.lcomm BUFFER_DATA, BUFFER_SIZE

.section .text

#stack positions
.equ ST_SIZE_RESERVE, 8
.equ ST_FD_IN, -4
.equ ST_FD_OUT, -8
.equ ST_ARGC, 0		#number of arguments
.equ ST_ARGV_0, 4 	#name of program
.equ ST_ARGV_1, 8	#input file name
.equ ST_ARGV_2, 12	#output file name

.globl _start
_start:
#initialise program
movl %esp, %ebp		#save the stack pointer
subl $ST_SIZE_RESERVE, %esp	#allocate space on the stack for our file descriptors

open_files:
open_fd_in:
#OPEN INPUT FILE!##
movl $SYS_OPEN, %eax	#open syscall
movl ST_ARGV_1(%ebp), %ebx	#move filename into ebx
movl $O_RDONLY, %ecx	#add the read only flag
movl $0666, %edx
int $LINUX_SYSCALL	#Call linux

store_fd_in:
movl %eax, ST_FD_IN(%ebp)	#save the file descriptor we got

open_fd_out:
###OPEN OUTPUT FILE###
movl $SYS_OPEN, %eax	#move sys call number to eax
movl ST_ARGV_2(%ebp), %ebx	#move output file descriptor to ebx
movl $O_CREAT_WRONGLY_TRUNC, %ecx	#some flag
movl $0666, %edx	#anoher flag
int $LINUX_SYSCALL	#call linux

store_fd_out:
movl %eax, ST_FD_OUT(%ebp)	#store the output file description

###BEGIN MAIN LOOP###
read_loop_begin:
movl $SYS_READ, %eax	#this is the block from the input file
movl ST_FD_IN(%ebp), %ebx	#save the input file descriptor
movl $BUFFER_DATA, %ecx	#get the location to be read into
movl $BUFFER_SIZE, %edx	#get the size of the buffer
int $LINUX_SYSCALL	#call linux to read the buffer with the above params. the size read is returned in eax

cmpl $END_OF_FILE, %eax	 #check if we've reached the end of the file
jle end_loop	#if found, end

continue_read_loop:
###CONVERT TO UPPERCASE###
pushl $BUFFER_DATA	#push locatoin of buffer onto the stack
pushl %eax	#push size of the buffer onto the stack
call convert_to_upper 	#with the above params
popl %eax	#function doesn't return anything, so overwriting eax doesn't mater
addl $4, %esp	#restore the esp to previous value

###WRITE TO OUTPUT FILE###
movl %eax, %edx	#move size of buffer to other place
movl SYS_WRITE, %eax	#to prepare for system call
movl ST_FD_OUT(%ebp), %ebx	#to get fd of output file
movl $BUFFER_DATA, %ecx		#actual data to be written
int $LINUX_SYSCALL		#call linux with previously set up parameters

jmp read_loop_begin	#if loop continues, go back

end_loop:
#prepare to close files
movl $SYS_CLOSE, %eax
movl ST_FD_OUT(%ebp), %ebx
int $LINUX_SYSCALL	#close with previously established parameters

movl $SYS_CLOSE, %eax
movl ST_FD_IN(%ebp), %ebx
int $LINUX_SYSCALL	#this time we close the input file

#now exit
movl $SYS_EXIT, %eax
movl $0, %ebx
int $LINUX_SYSCALL

#now we define our upper_caser function!

##CONSTANTS##
.equ LOWERCASE_A, 'a'
.equ LOWERCASE_Z, 'z'
.equ UPPER_CONVERSION, 'A'-'a'
#stack stuff
.equ ST_BUFFER_LEN, 8
.equ ST_BUFFER, 12

convert_to_upper:
pushl %ebp
movl %esp, %ebp

#set up our variables
movl ST_BUFFER(%ebp), %eax
movl ST_BUFFER_LEN(%ebp), %ebx
movl $0, %edi

#If a buffer of zero length, just leave
cmpl $0, %ebx
je end_convert_loop

convert_loop:
#get current byte
movb (%eax, %edi,1), %cl

#go to the next byte unless it is between a nad z
cmpb $LOWERCASE_A, %cl
jl next_byte
cmpb $LOWERCASE_Z, %cl
jg next_byte

#otherwise convert the byte to uppercase
addb $UPPER_CONVERSION, %cl
movb %cl, (%eax, %edi, 	1)

next_byte:
incl %edi
cmpl %edi, %ebx	#continue unless we've reached the end
jne convert_loop

#end loop
end_convert_loop:
movl %ebp, %esp
popl %ebp
ret

