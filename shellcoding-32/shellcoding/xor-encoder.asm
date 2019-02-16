global _start			

section .text
_start:

  ; push the first null dword (string terminated)
  xor eax,eax
  push eax

  ; push //bin/sh (8)
  push 0x68732f6e
  push 0x69622f2f

  ; esp currently points to /bin/bash so we take address from there and push it
  mov ebx, esp

  ; push another null - envp - it needs to be in edx
  push eax
  mov edx, esp ; pointing to zero

  ; push ebx - argv
  push ebx
  
  ; stop of the stack
  mov ecx, esp 

  ; syscall - execve
  mov al, 0xb
  int 0x80
