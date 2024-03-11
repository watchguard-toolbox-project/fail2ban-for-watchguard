#/bin/bash

P=`dirname $0`
test -f $P/config.sh || echo "please set up config.sh first. (cp config.sh-dist config.sh, change ip/pass etc.)"
test -f $P/config.sh || exit

source $P/config.sh

# check for exactly one argument
if [ "$1" == "" -o  "$2" != "" ]
then
	echo usage:
	echo "$0 <ip to block>"
	exit
fi

# protect against double run
# safeguard: max runtime = 3 min

#create checkdir
BLOCKFILE=blockip.sh.running
CHECKDIR=/dev/shm/fail2ban-for-watchguard
test -d $CHECKDIR || mkdir $CHECKDIR

#check for File
COUNT=1
while [ $COUNT -gt 0 ]
do
	COUNT=`find $CHECKDIR -type f -mmin -3 -name $BLOCKFILE | wc -l`
	if [ $COUNT -gt 0 ]
	then
		echo -n .
		sleep 1
	fi
done
echo

# delete blockfile
find $CHECKDIR -type f -mmin +2 -name $BLOCKFILE -exec rm {} \;

touch $CHECKDIR/$BLOCKFILE

IP=$1
$P/blockip.expect $FW $USER $PASS $1 "$TIME"

rm $CHECKDIR/$BLOCKFILE
