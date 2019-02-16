global _start			

section .text
_start:

  jmp short call_shellcode
	; Print hello world using write syscall - shellcode version

shellcode:
  xor eax,eax
	mov al, 0x4 ; syscall number taken from /usr/include/i386-linux-gnu/asm/unistd_32.h

  xor ebx,ebx
	mov bl, 1 ; stdout, where message goes

  pop ecx ; after call address of next function is stored on stack, we pop it from there to ecx

  xor edx,edx
  mov dl, 12 ; new string length
	int 0x80 ; call interrupt


  xor eax,eax
  mov al, 0x1
  xor ebx,ebx
	int 0x80 ; ebx is 0 - exit code

call_shellcode:
  call shellcode
	message: db "Hello World", 0xA  ; new line
