#!/bin/bash

program_name=${1}
if [[ -z ${program_name} ]]
then
  echo "[*ERROR*] No arguments given, give me source file name to compile  shellcode"
  exit 1
fi

gcc -fno-stack-protector -z execstack ${program_name}.c -o ${program_name}
