#!/bin/sh

# This script is tested only on FreeBSD and is most probably not portable. Patches
# are welcome :)
# It should run from cron every few hours.
# It creates a snapshot when it runs and deletes the snapshot that was created exactly
# a week ago. Although it is just a sample it could be of help.
# Usage:
# sh zfs_snapshot.sh pool_name
# or
# sh zfs_snapshot.sh pool_name/root/important_filesystem

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
