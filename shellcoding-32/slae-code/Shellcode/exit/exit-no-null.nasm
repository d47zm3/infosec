; Filename: exit.nasm
; Author:  Vivek Ramachandran
; Website:  http://securitytube.net
; Training: http://securitytube-training.com 
;
;
; Purpose: 

global _start			

section .text
_start:

	xor eax, eax
	mov al, 1
	xor ebx, ebx
  mov bl, 1
	int 0x80


