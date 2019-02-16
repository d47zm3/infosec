#!/bin/bash

dns_suffix=$1

for name in $( cat common_hosts.txt )
do
	host ${name}.${dns_suffix} | grep "has address" | cut -d" " -f1,4
done
