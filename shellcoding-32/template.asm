global _start			

section .text
_start:

	mov eax, 1
	mov ebx, 1		; sys_exit syscall - exit status
	int 0x80

section .data

	message: db "Hello World"
