#!/bin/bash

program_name=${1}
if [[ -z ${program_name} ]]
then
  echo "[*ERROR*] No arguments given, give me binary name to extract shellcode"
  exit 1
fi

objdump -d ./${program_name} |grep '[0-9a-f]:'|grep -v 'file'|cut -f2 -d:|cut -f1-6 -d' '|tr -s ' '|tr '\t' ' '|sed 's/ $//g'|sed 's/ /\\x/g'|paste -d '' -s |sed 's/^/"/'|sed 's/$/"/g'
