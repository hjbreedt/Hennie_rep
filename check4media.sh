#!/bin/bash
# Author: Hennie Breedt
# Date: 1Jun17
# This script is looking for music and movie files on the server.

MEDIA="*.avi *.m4a *.mkv *.mp3 *.mp4 *.mpeg *.mpg *.wma"
WORKDIR="/home/samba"
LINE="=================================================================================================================="
LOGFILE="/home/sevenc/media.txt"
TOTAL=0

for SAMBAFOLDER in `ls $WORKDIR`;
do
	echo "$SAMBAFOLDER" >> $LOGFILE
	echo "$LINE" >> $LOGFILE
	for EXT in `echo "$MEDIA"`;
	do
		echo "$EXT" >> $LOGFILE
		find $WORKDIR/$SAMBAFOLDER -type f -iname "$EXT" -exec du -schm {} + >> $LOGFILE
		echo "$LINE" >> $LOGFILE
	done
done


for i in `cat $LOGFILE | grep 'total\>' | awk -F' ' ' { print $1 } '`;
do
        TOTAL=$(echo "$TOTAL+$i" | bc)
done
TOTAL=$(echo "$TOTAL/1024" | bc)
echo >> $LOGFILE
echo >> $LOGFILE
echo "The Grand Total = $TOTAL G" >> $LOGFILE

