global _start			

; Print hello world using write syscall - shellcode version - using stack

section .text
_start:

  xor eax,eax
	mov al, 0x4 ; syscall number taken from /usr/include/i386-linux-gnu/asm/unistd_32.h

  xor ebx,ebx
	mov bl, 1 ; stdout, where message goes

  xor edx,edx
  push edx

  push 0x0a646c72 ; Hello World in reverse order, 4 bytes at a time
  push 0x6f57206f ; Hello World in reverse order
  push 0x6c6c6548 ; Hello World in reverse order

  mov ecx,esp ; ecx is loaded with stack location (where our string is!)

  mov dl, 12 ; new string length
	int 0x80 ; call interrupt

  xor eax,eax
  mov al, 0x1
  xor ebx,ebx
	int 0x80 ; ebx is 0 - exit code
