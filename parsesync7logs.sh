#!/bin/bash
# Author: Hennie Breedt
# Date: 29 May 2017 
# Script Name: parsesync7log.sh
# This script parses the sync7 log files and writes to /home/sevenc/hennie/logs/sync7-status-`date +%Y%m%d`.csv listing all the clients marked with a status of "success# ful", "failed" and "did not finish".
# You can gf from this logfile the the clients logfile to see why it did not pass.
 
clear
PARSELOG="/home/sevenc/hennie/logs/sync7-status-`date +%Y%m%d`.csv"
WORKDIR="/var/log/sync7"

# Functions begin

verifyInputDateStart(){
	echo $START | grep '^[0-9][0-9][0-9][0-9][0-1][0-9][0-3][0-9]$'
	if [ $? -eq 0 ];then
		echo "Date is valid" >> /dev/null
	else
		echo "$START is NOT a valid date. Expected format : YYYYmmdd"
		read -n 1 -s -p "Press any key to continue"
		echo
		read -p "Enter start date ( YYYYmmdd ): " START
		verifyInputDateStart
	fi
	}

verifyInputDateStop(){
	echo $STOP | grep '^[0-9][0-9][0-9][0-9][0-1][0-9][0-3][0-9]$'
	if [ $? -eq 0 ];then
		echo "Date is valid" >> /dev/null
	else
		echo "$STOP is NOT a valid date. Expected format : YYYYmmdd"
		read -n 1 -s -p "Press any key to continue"
		echo
		read -p "Enter stop date ( YYYYmmdd ): " STOP
		verifyInputDateStop
	fi
}

# Functons stop

date > $PARSELOG

echo "----------------------------"
echo " SevenC Sync7 Weekly Status"
echo "----------------------------"
echo
read -p "Enter start date ( YYYYmmdd ): " START
verifyInputDateStart
read -p "Enter stop date ( YYYYmmdd ): " STOP
verifyInputDateStop

#STARTDATE=`date +"%Y%m%d" -d $START`
STARTDATE=`date +"%d%b%y" -d $START`
STARTDATEORIG=`date +"%d%b%y" -d $START`
STOPDATE=`date +"%d%b%y" -d $STOP`
NEWSTOPDATE=`date +"%d%b%y" -d "$STOPDATE + 1 day"`

echo >> $PARSELOG
echo "Client,,Log Status" >> $PARSELOG
echo >> $PARSELOG

until [ $STARTDATE = $NEWSTOPDATE ];
do
	echo
	echo Processing ...$STARTDATE
	echo
	for CLIENT in `ls $WORKDIR | grep $STARTDATE`;
	do
		if grep -q -e "\<LIKELY\>" $WORKDIR/$CLIENT;then
			echo "$CLIENT...successful..."
			echo "'$WORKDIR/$CLIENT',,Succeessful" >> $PARSELOG
		elif grep -q -e "\<UNLIKELY\>" $WORKDIR/$CLIENT;then
			echo "$CLIENT...failed..."
                        echo "'$WORKDIR/$CLIENT',,Failed - $STARTDATE" >> $PARSELOG
                elif ! grep -q -e "\<LIKELY\>" -e "\<UNLIKELY\>" $WORKDIR/$CLIENT;then
			echo "$CLIENT...did not finish..."
                        echo "'$WORKDIR/$CLIENT',,Did not finish - $STARTDATE" >> $PARSELOG
                fi

	done
	STARTDATE=`date +"%d%b%y" -d "$STARTDATE + 1 day"`
	cat $PARSELOG | sort >> $PARSELOG-sorted
	rm -f $PARSELOG
	mv $PARSELOG-sorted $PARSELOG
	echo >> $PARSELOG
	echo >> $PARSELOG
done


for i in `cat clients.txt`;
do
	if  grep -q -e "\<$i\>" $PARSELOG;then
		echo "$i was synced" >> /dev/null
	else
		echo "$i was not synced during $STARTDATEORIG and $STOPDATE"
		echo "$i was not synced during $STARTDATEORIG and $STOPDATE" >> $PARSELOG
	fi
done

echo "I R Done"
