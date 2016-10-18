#!/bin/sh

PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/games:/usr/local/sbin:/usr/local/bin

t=$(date -j '+%Y%m%d%H%M' `date '+%Y%m%d%H%M'`)

snap=`date -j '+%Y-%m-%d_%H-%M' $t `-`hostname -s`
oldsnap=`date -j -v -1w '+%Y-%m-%d_%H-%M' $t `-`hostname -s`

for fs in $*
do
	zfs snapshot -r ${fs}@${snap}

	if ! echo $snap | grep '^20..-..-.._06-..' >/dev/null 
	then
		zfs destroy -r ${fs}@${oldsnap} 2>&1 |
		    sed '/could not find any snapshots to destroy; check snapshot names./d'
	fi
done
