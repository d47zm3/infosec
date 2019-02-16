#include<stdio.h>
#include<string.h>

unsigned char code[] = \
"\xb8\x01\x00\x00\x00\xbb\x01\x00\x00\x00\xcd\x80";

//"\x31\xc0\xb0\x01\x31\xdb\xb3\x0a\xcd\x80";

main()
{

	printf("Shellcode Length:  %d\n", strlen(code));

	int (*ret)() = (int(*)())code;

	ret();

}

	
