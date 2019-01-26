#!/bin/bash
#
# Cisco Router Uptime Check
#
# Erik Sundberg erikpsundberg@gmail.com
#
# Cisco fix: CSCvk35460 please....
#

#Set Number of days to flag as a warning
Warning=800

if [ -z "$1" ]; then
	echo "Usage: $0 <file>"
	echo ""
	echo "Input File, One Device Per Line"
	echo "Line Format: "
	echo "host, ip, community"
	exit -1
fi


if [ ! -f "$1" ]; then
	echo "File Not Found: $1"
	exit
fi


while IFS=',' read -r host ip community
do
	host=`echo $host | sed 's/ //g'`
	community=`echo $community | sed 's/ //g'`
	ip=`echo $ip | sed 's/ //g'`
	
	echo -n "$host, $ip"

	seconds=`snmpwalk -Ov -v 2c -c "$community" $ip .1.3.6.1.6.3.10.2.1.3 | cut -d ' ' -f 2`
	if [ $seconds -gt 1 ]; then
		
		days=$(($seconds / 86400))
		echo -n ", $days"

		if [ $days -gt $Warning ]; then
			echo ", WARNING"
		else	
			echo ", OK"
		fi
	else
		echo ", SNMP Fail"
	fi
done < $1
