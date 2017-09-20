#!/bin/bash
# Author: Hennie Breedt
# Date: 10 July 2017
# Script: addZone.sh
# This script will add new zone files.
# You could add the domains to the domains.txt file.
# eg. for i in `cat domains.txt`;do ./addZone.sh $i Clientname;done;service named restart
# or eg. ./addZone.sh example.co.za clientname 2017-07-10
# If it's a new site, the 3rd argument is not nesessary.

DB_USER='pietie'
DB_PASSWD='password'
DB_NAME='dbname'

ID='NULL'
NAMEDCONF=/etc/named.conf
WORKDIR=/etc/named
DOMAINNAME=$1
CLIENT=$2
NAME=$(echo $DOMAINNAME | awk -F'.' ' { print $1 } ')
TLD=$(echo $DOMAINNAME | sed -e s/$NAME//)

## Test to see if any arguments was given.
#if [ -z "$#" ];then
#	echo "You need to give the following arguments to the script...."
#	echo "./addZone.sh <domainname> <clientname> <dateregistered>"
#	echo "eg. ./addZone.sh hennie.co.za hennie 2017-07-10"
#	echo "If it's a new site, the 3rd argument is not nesessary."
#fi

# Test to see if you specified a date or not.
if [ -z "$3" ];then
        DATE=$(date +"%Y-%m-%d")
else
        DATE=$3
fi

## Adding data to database.
mysql -u$DB_USER -p$DB_PASSWD -D$DB_NAME << EOF
INSERT INTO domain_name (id,name,tld,date_registered,client) VALUES ('$ID', '$NAME', '$TLD', '$DATE', '$CLIENT');
EOF

# Test to see if zone file exist.
ZONEFILE="${WORKDIR}/${DOMAINNAME}"
if [ -e "$ZONEFILE" ];then
	echo "Zone file already exists, just edit it and remember to increment the serial number with 1"
	echo "and restart the named service."
	exit 1
else
	echo touching ${DOMAINNAME}
	sleep 2
	touch $ZONEFILE
	echo ";
;Done by Hennie Breedt on $(date +"%Y-%m-%d") 	Client: $2
;
\$TTL 300
@                       IN      SOA             ns1.example.co.za.  dnsadmin.example.co.za. (
						2005080122;
						28800;
						7200;
						604800;
						86400;
)
@                       IN      NS              ns1.example.co.za.
@                       IN      NS              ns2.example.co.za.
@                       IN      MX 10   mail.$DOMAINNAME.
@                       IN      MX 20   mail2.$DOMAINNAME.
;@                       IN      TXT     'v=spf1 include:spf.example.co.za mx a ptr a:linexchange.$DOMAINNAME.ipactive.biz -all'
@                       IN      TXT             \"CLIENT: $2\"
@                       IN      A               154.0.173.94
localhost	        IN      A               127.0.0.1
mail          		IN      A               64.150.177.30
mail2              	IN      A               41.76.209.62
www                     IN      A               154.0.173.94
www2                    IN      A               154.0.173.94
ftp                     IN      CNAME   www
cpanel                  IN      CNAME   www
phpmyadmin              IN      CNAME   www
\$TTL 86400" >> $ZONEFILE

	echo "zone \"$DOMAINNAME\" IN {
   type master;
   file \"$DOMAINNAME\";
};" >> $NAMEDCONF

	ls $WORKDIR | grep $DOMAINNAME
	sleep 2
fi

cat $ZONEFILE
echo
echo -------- Checking DB for $DOMAINNAME ---------
echo
echo NAME = $NAME
echo TLD = $TLD
echo
mysql -u$DB_USER -p$DB_PASSWD -D$DB_NAME << EOF
select * from domain_name where name='$NAME' and tld='$TLD';
EOF
echo
echo -------------------------------------------------

exit 0
