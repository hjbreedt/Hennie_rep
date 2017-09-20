#!/bin/bash
# Author: Hennie Breedt
# Version: 3
# Date: 18 September 2017
# This script restores maarchive to a clients Maildir.
# Usage: ./maarchive-restore.sh <username> and then just answer the questions.

if [ -z "$1" ];then
	echo
	echo "You are missing an input argument."
	echo "Usage: ./maarchive-restore.sh <username> and then just answer the questions."
	echo "eg. ./maarchive-restore.sh hennie"
	echo
	exit 1
fi	

USER=$1
ls /home/$USER > /dev/null
EXITUSER=$?
if [ $EXITUSER != 0 ];then
	echo 
	echo "User: $USER does not exist, please enter correct user."
	echo 
	exit 1
fi

USERID=`id -nu $USER`
USERGRP=`id -ng $USER`
RESTOREDIN="restored-inbox-`/bin/date +'%d%b%y'`"
RESTOREDOUT="restored-sent-`/bin/date +'%d%b%y'`"
MB2MD="/usr/local/pkmailbox/bin/mb2md-3.20.pl"
WORKINGDIR="/home/sevenc/maarchive/$USER"
MAILDIR="/home/$USER/Maildir"
mkdir -p /tmp/$USER/inbox
mkdir -p /tmp/$USER/sent
SRCIN="/tmp/$USER/inbox"
SRCOUT="/tmp/$USER/sent"
DSTIN="$MAILDIR/.$RESTOREDIN"
DSTOUT="$MAILDIR/.$RESTOREDOUT"


restoreall () {
	mkdir $DSTIN
	mkdir $DSTOUT
	cd $WORKINGDIR
       	cat *in >> $SRCIN/incoming
       	cat *out >> $SRCOUT/outgoing
       	$MB2MD -s $SRCIN/incoming -d $DSTIN/.
       	$MB2MD -s $SRCOUT/outgoing -d $DSTOUT/.
       	chown -R $USERID:$USERGRP $DSTIN
       	chmod -R 700 $DSTIN
       	chown -R $USERID:$USERGRP $DSTOUT
       	chmod -R 700 $DSTOUT
       	echo $RESTOREDIN >> $MAILDIR/subscriptions
       	echo $RESTOREDOUT >> $MAILDIR/subscriptions
	echo
       	echo "'mutt -f $DSTIN' to see if all is fine."
       	echo "'mutt -f $DSTOUT' to see if all is fine."
	echo
	echo "Tell the user to restart the mail client, you should be able to see the two new folders."
	echo
	}

restorein () {
	mkdir $DSTIN
	cd $WORKINGDIR
	until [ $STARTDATE = $NEWSTOPDATE ];
	do
		for i in `ls $WORKINGDIR | sort | grep $STARTDATE | grep in`;
		do
			cat $i >> $SRCIN/incoming
			#echo $i
		done
		#STARTDATE=`date +"%Y%m%d" -d "$STARTDATE + 1 day"`
		STARTDATE=`date -d "$STARTDATE 1 day" +%Y%m%d`
	done
	if [ -f $SRCIN/incoming ];then
		$MB2MD -s $SRCIN/incoming -d $DSTIN/.
        	chown -R $USERID:$USERGRP $DSTIN
        	chmod -R 700 $DSTIN
        	echo $RESTOREDIN >> $MAILDIR/subscriptions
		echo
        	echo "'mutt -f $DSTIN' to see if all is fine."
		echo
		echo "Tell the user to restart the mail client, you should be able to see the two new folders."
		echo
	else
		echo "There are no inbox items."
	fi
	
	}

restoreout () {
	mkdir $DSTOUT
	cd $WORKINGDIR
	until [ $SENTSTARTDATE = $NEWSTOPDATE ];
	do
		for i in `ls $WORKINGDIR | sort | grep $SENTSTARTDATE | grep out`;
		do
			cat $i >> $SRCOUT/outgoing
		done
		#STARTDATE=`date +"%Y%m%d" -d "$STARTDATE + 1 day"`
		SENTSTARTDATE=`date -d "$SENTSTARTDATE 1 day" +%Y%m%d`
	done
	rm -f $SSTMP 
	if [ -f $SRCOUT/outgoing ];then
		$MB2MD -s $SRCOUT/outgoing -d $DSTOUT/.
        	chown -R $USERID:$USERGRP $DSTOUT
        	chmod -R 700 $DSTOUT
        	echo $RESTOREDOUT >> $MAILDIR/subscriptions
		echo
        	echo "'mutt -f $DSTOUT' to see if all is fine."
		echo
		echo "Tell the user to restart the mail client, you should be able to see the two new folders."
		echo
	else
		echo "There are no sent items."
	fi
	
	}		

read -p "Do you want to recover all the mails in maarchive for this user? (Y/N):  " ALLYESNO


case $ALLYESNO in
	[yY] | [yY][eE][sS] )
		restoreall
        	;;
        
	[nN] | [nN][oO] )
		SSTMP="/tmp/sentstartdate.txt"	
        	echo -en "Enter start date (YYYYmmdd): "
        	read STARTDATE
		echo $STARTDATE > $SSTMP
		SENTSTARTDATE=`cat $SSTMP`
        	echo -en "Enter stop date (YYYYmmdd): "
        	read STOPDATE
        	#NEWSTOPDATE=`date +"%Y%m%d" -d "$STOPDATE + 1 day"`
        	NEWSTOPDATE=`date -d "$STOPDATE 1 day" +%Y%m%d`
	       	read -p "Press 'I' for inbox,'O' for Sent Items or 'B' for both (I/O/B): " INOUTBOTH
  		case $INOUTBOTH in
			[iI] | [iI][nN] )
                		restorein
				;;
            		[oO] | [oO][uU][tT] )
                		restoreout
				;;
	    		[bB] | [bB][oO][tT][hH] )
                		restorein
				restoreout
				;;
			* )
                		echo "Please choose a valid option. "
                		;;
        	esac
esac
rm -rf /tmp/$USER


echo -----------------------------------
echo        
echo "Author:Hennie Breedt"
echo "Thanks for using my script :)"         
echo
echo -----------------------------------
