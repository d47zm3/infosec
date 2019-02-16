; Filename: Strings.nasm
; Author:  Vivek Ramachandran
; Website:  http://securitytube.net
; Training: http://securitytube-training.com 
;
;
; Purpose: 

global _start			

section .text
_start:

	; copy a strign from source to destination
	
	mov ecx, sourceLen
	lea esi, [source]
	lea edi, [destination]


	cld  ; clear direction flag 
	rep movsb

	; Print hello world using write syscall

	mov eax, 0x4
	mov ebx, 0x1
	mov ecx, destination
	mov edx, sourceLen
	int 0x80

	; string comparison with cmpsb

	; compare source and destination 
	mov ecx, sourceLen
	lea esi, [source]
	lea edi, [destination]
	repe cmpsb

	jz SetEqual
	mov ecx, result2
	mov edx, result2Len
	jmp Print

SetEqual:
	mov ecx, result1
	mov edx, result1Len

Print:
	mov eax, 0x4
	mov ebx, 0x1
	int 0x80

	
	mov eax, 1
	mov ebx, 10		; sys_exit syscall
	int 0x80


section .data

	source: db "Hello World!", 0xA
	sourceLen equ $-source

	comparison: db "Hello"

	result1: db "Strings are Equal", 0xA
	result1Len equ $-result1

	result2: db "Strings are Unequal", 0xA
	result2Len equ $-result2

section .bss

	destination: resb 100

