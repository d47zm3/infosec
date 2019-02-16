global _start			

section .text
_start:

	; Print hello world using write syscall

	mov eax, 0x4 ; syscall number taken from /usr/include/i386-linux-gnu/asm/unistd_32.h
	mov ebx, 1 ; stdout, where message goes
	mov ecx, message ; pointer to buffer
	mov edx, mlen ; buffer length
	int 0x80 ; call interrupt


	mov eax, 1
	mov ebx, 1		; sys_exit syscall - exit status
	int 0x80

section .data

	message: db "Hello World"
	mlen     equ $-message
