#!/bin/sh

# This script is tested only on FreeBSD and GNU/Linux. It won't work
# on other systems. Patches are welcome :)
#
# It should run from cron every few hours. It creates a recursive snapshot
# and deletes the snapshot that was created 14 days ago. Although
# it is just a sample, it could be of help.
# Usage:
# sh zfs_snapshot.sh pool_name
# sh zfs_snapshot.sh pool_name/root/important_filesystem anotherpool temp/anotherfs
## FreeBSD example
# sh zfs_snapshot.sh -ttl 200d pool_name
## GNU/Linux example
# sh zfs_snapshot.sh -ttl "200 days" pool_name/root/very_important_filesystem

PATH=/sbin:/bin:/usr/sbin:/usr/bin
if [ "$1" = -ttl ]
then
	ttl=$2
	shift 2
fi

# Subtracting dates is not portable.
if [ `uname -s` = FreeBSD ]
then
	jflag=-j
	ttl=${ttl-14d}
	now=`date '+%Y%m%d%H%M'`
	oldsnap=`date $jflag -v -${ttl} "$now" '+%Y-%m-%d_%H-%M' `-`hostname -s` 
elif [ `uname -s` = Linux ]
then
	jflag=-d
	ttl=${ttl-14 days}
	now=`date '+%Y%m%d %H%M'`
	oldsnap=`date $jflag "$now - $ttl" '+%Y-%m-%d_%H-%M' `-`hostname -s` 
fi
# This works on both FreeBSD and GNU/Linux.
snap=`date $jflag "$now" '+%Y-%m-%d_%H-%M' `-`hostname -s`

for fs in $*
do
	# When something fails, print a warning and continue
	echo zfs snapshot -r ${fs}@${snap} || echo exitcode: $?
	echo zfs destroy -r ${fs}@${oldsnap} || echo exitcode: $?
done
