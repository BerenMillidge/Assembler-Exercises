#Okay this is where we do our structured data reading files, which shouldn't be too difficult at all

#first we include our previous things
.include "record-def.s"
.include "linux.s"

#So this is a function which reads a file, it needs a buffer address anda file descriptor to work

.section .data
record1:
.ascii "Fredrick\0"
.rept 31 #so we pad to 40 bytes
.byte 0
.endr

.ascii "Bartlett\0"
.rept 31
.byte 0
.endr

.ascii "4242 S Prairie\nTulsa, OK 55555\0"
.rept 209 #pad to 240 bytes
.byte
.endr

.long 45

record2:
.ascii "Marilyn\0"
.rept 32
.byte 0
.endr

.ascii "Taylor\0"
.rept 33
.byte 0
.endr

.long29

record3:
.ascii "Derrick\0"
.rept 32
.byte
.endr

.ascii "McIntire\0"
.rept 31
.byte 0 
.endr

.ascii "500 W Oakland\nSan Diego, CA 54321\0"
.rept 206
.byte 0
.endr

.long 36

file_name:
.ascii "test.dat\0"




#stack local variables
.equ ST_READ_BUFFER, 8
.equ ST_FILEDES, 12

.section .text
.globl read_record
.type read_record, @function

read_record:
pushl %ebp	#we push previous base pointer onto the stack to save it
movl %esp, %ebp	# move base pointer to stack pointer so we're now actually pointing at the function
pushl %ebx # what is this? Presumably it's something, it depends when it's called. Is this a parameter?
movl ST_FILEDES(%ebp), %ebx	#move the file descriptor to ebx
movl ST_READ_BUFFER(%ebp), %ecx	# move the start of the read buffer to ecx
movl $SYS_READ, %eax
int $LINUX_SYSCALL	#this calls the read syscall with the previously established parameters, which is pretty easy imho. It assumes that the requisite parameters are on the stack as necessary.

popl %ebx
movl %ebp, %esp
popl %ebp
ret	
#our standard returning commands

#Now we define our write function

#stack local variables
.equ ST_WRITE_BUFFER, 8
.equ ST_FILEDES, 12

#.section .text # I'm not sure we need this again as we're doing this all in one file. In fact, I' mpretty sure we DONT need it twice, and putting it twice will confused things!

.globl write_record
.type write_record, @function

write_record:
pushl %epb
movl %esp, %ebp
pushl %ebx 	#I'm still not really sure on this point tbh
movl %ST_FILEDES(%ebp), %ebx
movl ST_WRITE_BUFFER(%ebp), %ecx
movl $SYS_WRITE, %eax
movl $RECORD_SIZE, %edx
int $LINUX_SYSCALL

popl %ebx
movl %ebp, %esp
popl %ebp
ret



#So now we've got our functions, we need to do this as follows. i.e. the actual program

.equ ST_FILE_DESCRIPTOR, -4

.globl _start
_start:

movl %esp, %ebp 	#maybe this is why ebp is used all the time in the functions, it's the stack pointer for this function! nope, that's ebx, ignore this
subl $4, %esp	#allocate the space to hold the file descriptor

#We prepare for opening and writing
movl $SYS_OPEN, %eax
movl $file_name, %ebx	#THIS is why we store and use ebx I strongly suspect
movl $SYS_CREATE_OPEN, %ecx
movl $0666, %edx	#not sure what this does
int $LINUX_SYSCALL

#Now we've got the file open and possibly created we ned to write shit to it!
movl %eax, ST_FILE_DESCRIPTOR(%ebp)	#this stores the file descriptor of the file where it's meant to be stored for later functions

pushl ST_FILE_DESCRIPTOR(%ebp)	#push the FD onto the stack as parameter for the write function
pushl $record1	#push this as second param to function
call write_record
addl $8, %esp	#why do we do this? presumbaly so we can store the return value or something. or no it's so we have space to add next bunch of functions?

#write second record:
pushl ST_FILE_DESCRIPTOR(%ebp)
pushl $record2
call write_record
addl $8, %esp

#write third record
pushl ST_FILE_DESCRIPTOR(%ebp)
pushl $record3
call write_record
adll $8, %esp

#we now close the file
movl $SYS_CLOSE, %eax
movl ST_FILE_DESCRIPTOR(%ebp), %ebx
int $LINUX_SYSCALL

#final exit
movl $SYS_EXIT, %eax
movl $0, %ebx	#set this as zero, because why not
int $LINUX_SYSCALL


