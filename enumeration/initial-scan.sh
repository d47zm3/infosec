#!/bin/bash

target=${1}

function decho
{
  string=$1
  echo "[$( date +'%H:%M:%S' )] ${string}"
}

decho "Runnning Nmap Scan..."
nmap -sV -oA -sC ${target} | tee ${target}.nmap.log

decho "Runnning Nmap Scan For Exploits..."
nmap --script exploit -Pn ${target} | tee ${target}.nmap.exploit.log

decho "Running Nikto Scan..."
nikto -h http://${target}/ | tee ${target}.nikto.log

decho "Running GoBuster Scan..."
gobuster -w /usr/share/dirb/wordlists/big.txt -u http://${target}/ -r -t 4 | tee ${target}.gobuster.log
