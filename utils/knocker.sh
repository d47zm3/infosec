#!/bin/bash
# knocker.sh v0.1
# last edit 11-03-2016 13:30
#
#
#						VARIABLES
########################################################################
VERS=$(sed -n 2p $0 | awk '{print $3}' | sed 's/v//')
TMPFILE=/root/ports_knocker.tmp
rm -rf $TMPFILE
PERMUTE=0
COUNT=1
RETRY=0
SLEEP=1
VAR=0
#
#						TEH COLORZ
########################################################################
STD=$(echo -e "\e[0;0;0m")		#Revert fonts to standard colour/format
RED=$(echo -e "\e[1;31m")		#Alter fonts to red bold
REDN=$(echo -e "\e[0;31m")		#Alter fonts to red normal
GRN=$(echo -e "\e[1;32m")		#Alter fonts to green bold
GRNN=$(echo -e "\e[0;32m")		#Alter fonts to green normal
ORN=$(echo -e "\e[1;33m")		#Alter fonts to orange bold
ORNN=$(echo -e "\e[0;33m")		#Alter fonts to orange bold
BLU=$(echo -e "\e[1;36m")		#Alter fonts to blue bold
BLUN=$(echo -e "\e[0;36m")		#Alter fonts to blue normal
#
#						HEADER
########################################################################
f_header() {
echo $BLU" _               _           
| |_ ___ ___ ___| |_ ___ ___ 
| '_|   | . |  _| '_| -_|  _|
|_,_|_|_|___|___|_,_|___|_|"
}
#						HELP
########################################################################
f_help() {
f_header
echo $BLU">$BLUN Help Information$STD"
echo "
Usage; 
./knocker.sh -i <IP> -p <PORT,PORT,PORT>

Required Input
-i  --  IP ADDRESS
-p  --  Ports (comma seperated for multiple ports)

Options
-c  --  Number of times each knock to be done (default=1)
-n  --  NetCat connect to port and read returned port values
        (this option then uses returned ports to knock and ignores -p)
-P  --  Permute all possible knocking sequences (for upto max 5 ports)
-r  --  Number of times to repeat the command (default=0)
-s  --  Sleep inbetween knocks in seconds (default=1)
-x  --  Show examples
"
exit
}
#						EXAMPLES
########################################################################
f_examples() {
f_header
echo -e $BLU">$BLUN Examples$STD\n
$GRNN ./knocker.sh -i 192.168.1.101 -p 1243,65111,1337 $STD
 will knock on each of the given ports 1 time

$GRNN ./knocker.sh -i 192.168.1.101 -n 1337 -r 5 $STD
 will attempt connection with netcat on port 1337 and knock on the returned values
 this command will be repeated 5 times                                            

$GRNN ./knocker.sh -i 192.168.1.101 -p 123,456.789 -c 2 -s 2 -r 3 $STD
 knock on each given port 2x, sleep 2 seconds between knock, repeat this command 3x

$GRNN ./knocker.sh -i 192.168.1.101 -n 1337 -P $STD
 will attempt connection with netcat on port 1337 and knock on all possible sequences
 
$GRNN ./knocker.sh -i 192.168.1.101 -p 123,456,789 -P $STD
 will knock on each of the given ports in all possible sequences"
exit
}
#						VERSION
########################################################################
f_version() {
f_header
echo $BLU">$GRNN Version $VERS    By TAPE$STD"
echo -e $BLUN"\nKnock Knock.. Who's there?$STD\n"
echo -e "Script made for the THS crew at Top-Hat-Sec.com
enjoy Guyz & Galz ;)"
exit
}
#						NETCAT CONNECT FUNCTION						
########################################################################
f_nc() {
f_header
echo $BLU">$BLUN Using data from nc connection attempt$STD"
if [ "$RETRY" == "0" ] ; then
	VAR=$(($VAR+1))
	echo -e "\nKnock #$VAR.."
	for i in $(nc $IP $NCPORT | sed -e 's/\[//' -e 's/,//g' -e 's/\]//' -e 's/ /\n/g') ; do 
		echo "+$STD Knocking on port $i"
#		hping3 -S $IP -p $i -c $COUNT &> /dev/null
		nping --tcp -p $i --ttl 2 $IP -c $COUNT &> /dev/null 
		sleep $SLEEP
	done
	echo ""
elif [ $RETRY -gt 0 ] ; then 
	while (( $VAR<$RETRY )) ; do
		VAR=$(($VAR+1))
		echo -e "\nKnock #$VAR.."
		for i in $(nc $IP $NCPORT | sed -e 's/\[//' -e 's/,//g' -e 's/\]//' -e 's/ /\n/g') ; do 
			echo "+ Knocking on port $i"
#			hping3 -S $IP -p $i -c $COUNT &> /dev/null
			nping --tcp -p $i --ttl 2 $IP -c $COUNT &> /dev/null 
			sleep $SLEEP
		done
	done
	echo ""
fi
exit
}
#						PERMUTE RETURNED PORTS FROM NETCAT
########################################################################
f_ncpermute() {
f_header
echo $BLU">$BLUN Using data from nc connection attempt$STD"
echo -e $BLU">$BLUN Knocking all sequence permutations$STD\n"
PORTS=$(nc $IP $NCPORT | sed -e 's/\[//' -e 's/,//g' -e 's/\]//' -e 's/ /\n/g')
PORTCOUNT=$(echo $PORTS | wc -w)
if [ $PORTCOUNT -gt 5 ] ; then 
	echo $RED">$STD Input error, script can handle maximum of 5 ports to permute"
	echo $RED">$STD Number of ports: $PORTCOUNT"
	exit
else 
	PORTLIST=$(echo $PORTS | sed 's/\n/ /g')
	echo "$PORTCOUNT ports found: $PORTLIST"
fi
#					WRITE PERMUTATIONS OF PORT SEQUENCES TO TMP FILE
#-----------------------------------------------------------------------
LIST=$(echo $PORTS)
if [ "$PORTCOUNT" == "1" ] ; then
	for c1 in $LIST ; do 
		echo $c1 >> $TMPFILE
	done
elif [ "$PORTCOUNT" == "2" ] ; then 
	for c1 in $LIST ; do
		for c2 in $LIST ; do
			if (( c2 != c1 )) ; then
				echo $c1 $c2 >> $TMPFILE
			fi
		done
	done
elif [ "$PORTCOUNT" == "3" ] ; then
	for c1 in $LIST ; do
		for c2 in $LIST ; do
			if (( c2 != c1 )) ; then
				for c3 in $LIST ; do
					if (( c3 != c2 && c3 != c1)) ; then
						echo $c1 $c2 $c3 >> $TMPFILE
					fi
				done
			fi
		done
	done
elif [ "$PORTCOUNT" == "4" ] ; then
	for c1 in $LIST ; do
		for c2 in $LIST ; do
			if (( c2 != c1 )) ; then
				for c3 in $LIST ; do
					if (( c3 != c2 && c3 != c1)) ; then
						for c4 in $LIST ; do
							if (( c4 != c3 && c4 != c2 && c4 != c1 )) ; then
								echo $c1 $c2 $c3 $c4 >> $TMPFILE
							fi
						done
					fi
				done
			fi
		done
	done
elif [ "$PORTCOUNT" == "5" ] ; then	
	for c1 in $LIST ; do
		for c2 in $LIST ; do
			if (( c2 != c1 )) ; then
				for c3 in $LIST ; do
					if (( c3 != c2 && c3 != c1)) ; then
						for c4 in $LIST ; do
							if (( c4 != c3 && c4 != c2 && c4 != c1 )) ; then
								for c5 in $LIST ; do
									if (( c5 != c4 && c5 != c3 && c5 != c2 && c5 != c1 )) ; then
										echo $c1 $c2 $c3 $c4 $c5 >> $TMPFILE
									fi
								done
							fi
						done
					fi
				done
			fi
		done
	done
fi
#					KNOCK PORTS IN ALL POSSIBLE SEQUENCES
#-----------------------------------------------------------------------
sleep 0.5
while read line ; do
	VAR=$(($VAR+1))
	echo -e "\nKnocking sequence #$VAR"
	PLIST=$(echo $line)
	for i in $PLIST ; do 
		echo "+ Knocking port $i"
#		hping3 -S $IP -p $i -c $COUNT &> /dev/null
		nping --tcp -p $i --ttl 2 $IP -c $COUNT &> /dev/null 
		sleep $SLEEP
	done
done < $TMPFILE
rm -rf $TMPFILE
echo ""
exit
}
#						BASIC KNOCK
########################################################################
f_basic() {
f_header
echo $BLU">$BLUN Knocking given port(s)$STD"
PORTS=$(echo $PORTS | sed 's/,/ /g')
if [ "$RETRY" == "0" ] ; then
		VAR=$(($VAR+1))
		echo -e "\nKnock #$VAR.."
	for i in $(echo $PORTS) ; do 
		echo "+ Knocking on port $i"
#		hping3 -S $IP -p $i -c $COUNT &> /dev/null
		nping --tcp -p $i --ttl 2 $IP -c $COUNT &> /dev/null 
		sleep $SLEEP
	done
elif [ $RETRY -gt 0 ] ; then 
	while (( $VAR<$RETRY )) ; do
		VAR=$(($VAR+1))
		echo -e "\nKnock #$VAR.."
		for i in $(echo $PORTS) ; do 
			echo "+ Knocking on port $i"
#			hping3 -S $IP -p $i -c $COUNT &> /dev/null
			nping --tcp -p $i --ttl 2 $IP -c $COUNT &> /dev/null 
			sleep $SLEEP
		done
	done
fi
echo $STD""
exit
}
#						BASIC KNOCK WITH PERMUTATION
########################################################################
f_basicpermute() {
f_header
echo $BLU">$BLUN Knocking all sequence permutations$STD"
PORTS=$(echo $PORTS | sed 's/,/ /g')
PORTCOUNT=$(echo $PORTS | wc -w)
if [ "$PORTCOUNT" == "1" ] ; then
	echo $RED">$STD Input error; only 1 port, no need to invoke permute function"
	sleep 1
	echo $GRN">$STD Going to basic function.."
	sleep 1
	f_basic
elif [ $PORTCOUNT -gt 5 ] ; then 
	echo $RED">$STD Input error, script can handle maximum of 5 ports to permute"
	echo $RED">$STD Number of ports: $PORTCOUNT"
	exit
else 
	PORTLIST=$(echo $PORTS | sed 's/\n/ /g')
	
fi
#					WRITE PERMUTATIONS OF PORT SEQUENCES TO TMP FILE
#-----------------------------------------------------------------------
LIST=$(echo $PORTS)
if [ "$PORTCOUNT" == "2" ] ; then 
	for c1 in $LIST ; do
		for c2 in $LIST ; do
			if (( c2 != c1 )) ; then
				echo $c1 $c2 >> $TMPFILE
			fi
		done
	done
elif [ "$PORTCOUNT" == "3" ] ; then
	for c1 in $LIST ; do
		for c2 in $LIST ; do
			if (( c2 != c1 )) ; then
				for c3 in $LIST ; do
					if (( c3 != c2 && c3 != c1)) ; then
						echo $c1 $c2 $c3 >> $TMPFILE
					fi
				done
			fi
		done
	done
elif [ "$PORTCOUNT" == "4" ] ; then
	for c1 in $LIST ; do
		for c2 in $LIST ; do
			if (( c2 != c1 )) ; then
				for c3 in $LIST ; do
					if (( c3 != c2 && c3 != c1)) ; then
						for c4 in $LIST ; do
							if (( c4 != c3 && c4 != c2 && c4 != c1 )) ; then
								echo $c1 $c2 $c3 $c4 >> $TMPFILE
							fi
						done
					fi
				done
			fi
		done
	done
elif [ "$PORTCOUNT" == "5" ] ; then	
	for c1 in $LIST ; do
		for c2 in $LIST ; do
			if (( c2 != c1 )) ; then
				for c3 in $LIST ; do
					if (( c3 != c2 && c3 != c1)) ; then
						for c4 in $LIST ; do
							if (( c4 != c3 && c4 != c2 && c4 != c1 )) ; then
								for c5 in $LIST ; do
									if (( c5 != c4 && c5 != c3 && c5 != c2 && c5 != c1 )) ; then
										echo $c1 $c2 $c3 $c4 $c5 >> $TMPFILE
									fi
								done
							fi
						done
					fi
				done
			fi
		done
	done
fi
#					KNOCK PORTS IN ALL POSSIBLE SEQUENCES
#-----------------------------------------------------------------------
while read line ; do
	VAR=$(($VAR+1))
	echo -e "\nKnocking sequence #$VAR"
	PLIST=$(echo $line)
	for i in $PLIST ; do 
		echo "+ Knocking port $i"
#		hping3 -S $IP -p $i -c $COUNT &> /dev/null
		nping --tcp -p $i --ttl 2 $IP -c $COUNT &> /dev/null
		sleep $SLEEP
	done
done < $TMPFILE
#
rm -rf $TMPFILE
exit
}
#						OPTION FUNCTIONS
########################################################################
#	
	
while getopts ":c:hi:n:p:Pr:s:vx" opt; do
  case $opt in
	c)
	COUNT=$OPTARG ;;
	h) 
	f_help ;;
	i)
	IP=$OPTARG ;;
	n)
	NCPORT=$OPTARG ;;
	p)
	PORTS=$OPTARG ;;
	P)
	PERMUTE=1 ;;
	r)
	RETRY=$OPTARG ;;
	s)
	SLEEP=$OPTARG ;;
	v)
	f_version ;;
	x)
	f_examples ;;
  esac
done
#
#						INPUT CHECKS
########################################################################
if [ $# -eq 0 ]; then clear ; f_help
elif [[ -z $IP ]] ; then 
	echo $RED">$STD Missing input; IP address must be entered with -i switch"
	exit
elif [[ ! -n $PORTS && ! -n $NCPORT ]] ; then 
	echo $RED">$STD Missing input; no ports defined to knock"
	exit
fi
#
#						START THE KNOCKING
########################################################################
#
if [[ -n $IP && -n $PORTS ]] ; then
	if [ "$PERMUTE" == "1" ] ; then f_basicpermute
	else f_basic
	fi	
elif [[ -n $IP && -n $NCPORT ]] ; then
	if [ "$PERMUTE" == "1" ] ; then f_ncpermute
	else f_nc
	fi
fi
#
# THE END :D
#
# v0.1b released 09-03-2016 
# -------------------------
# Created this script after getting seriously frustrated with a vulnhub VM called knockknock
# The script's usefulness is probably limited to this VM, possibly other similar types of 
# deliberately vulnerable VMs.
#
# Real-World applications ... probably limited :) but fun to write and will be fun to build on.
#
#
# 10-03-2016
# ----------
# changed ping command to nping to avoid issues with hping3 <- Thanks ch3rn0byl !
# 11-03-216
# included permutation options.
# Public release of v0.1 to THS.
#
#
# TO DO 
# -----
# Improve feedback/output when knocking multiple times with -c
# 
