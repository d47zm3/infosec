#!/bin/bash

new_ip=${1}

function decho
{
  string=${1}
  echo -e "[$( date +'%H:%M:%S' )] ${string}"
}

if [[ -z ${new_ip} ]]
then
  decho "[warning] i need new ip to insert!"
  decho "checking if you've got yaes config file..."
  if [[ -f ${HOME}/.yaes.conf ]]
  then
    source ${HOME}/.yaes.conf
    new_ip=$( ip -f inet -o addr show ${iface} | cut -d\  -f 7 | cut -d/ -f 1 )
  else
    decho "[error] no yaes config was found... provide ip!"
    exit 1
  fi
fi

decho "updating php shell..."
sed -i -e "s/\$ip = .*/\$ip = '${new_ip}';/g" php-reverse-shell.php
decho "updating perl shell..."
sed -i -e "s/my \$ip = .*/my \$ip = '${new_ip}';/g" perl-reverse-shell.pl
