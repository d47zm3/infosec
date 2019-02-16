global _start

section .text
_start:

  mov eax,1
  mov ebx,1
  int 0x80
