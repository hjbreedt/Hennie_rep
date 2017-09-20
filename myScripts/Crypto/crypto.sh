#!/bin/bash

if curl -s http://myip.sevenc.co.za/ransomware.txt > /dev/null; then
        echo "Curl suceeding... continuing with ransomware check."
                for EXT in `curl -s http://myip.sevenc.co.za/ransomware.txt`;
                        do
                                echo "$(date) - checking $EXT"
                                LOCKY=$( find /home/samba -type f -iname $EXT | wc -l )
                                if [ $LOCKY -ge 1 ];then
                                        echo "$EXT Ransomware found! Bailing out"
                                        exit 1
                                else
                                        echo "$EXT not found! Continuing..."
                                fi
                        done
else
        echo "Curl not working! continuing with preamble..."
fi
#for EXT in `cat $RANSOMWARE`;
echo "Deleting Allwaysync temp files..."
find /home/samba/archive7 -type f -iname *.mce -delete
find /home/samba/archive7 -type f -iname *.tmp -delete


#echo "Nothing to be done yet in preamble.sh"

exit 0

