#!/bin/sh

# This script is tested only on FreeBSD and GNU/Linux. It won't work
# on other systems. Patches are welcome :)
#
# It should run from cron every few hours. It creates a recursive snapshot
# and deletes the snapshot that was created exactly two weeks ago. Although
# it is just a sample, it could be of help.
# Usage:
# sh zfs_snapshot.sh pool_name
# or
# sh zfs_snapshot.sh pool_name/root/important_filesystem

PATH=/sbin:/bin:/usr/sbin:/usr/bin

# Subtracting dates is not portable.
if [ `uname -s` = FreeBSD ]
then
	jflag=-j
	now=`date '+%Y%m%d%H%M'`
	oldsnap=`date $jflag -v -2w "$now" '+%Y-%m-%d_%H-%M' `-`hostname -s` 
elif [ `uname -s` = Linux ]
then
	jflag=-d
	now=`date '+%Y%m%d %H%M'`
	oldsnap=`date $jflag "$now - 2 weeks" '+%Y-%m-%d_%H-%M' `-`hostname -s` 
fi
# This works on both FreeBSD and GNU/Linux.
snap=`date $jflag "$now" '+%Y-%m-%d_%H-%M' `-`hostname -s`

for fs in $*
do
	# When something fails, print a warning and continue
	zfs snapshot -r ${fs}@${snap} || echo exitcode: $?
	zfs destroy -r ${fs}@${oldsnap} || echo exitcode: $?
done
