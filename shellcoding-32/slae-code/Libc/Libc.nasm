; Filename: Libc.nasm
; Author:  Vivek Ramachandran
; Website:  http://securitytube.net
; Training: http://securitytube-training.com 
;
;
; Purpose: 

extern printf
extern exit

global main

section .text
main:

	push message
	call printf
	add esp, 0x4  ; adjust the stack 

	mov eax, 0xa
	call exit

	

section .data

	message: db "Hello World!", 0xA, 0x00
	mlen     equ $-message


