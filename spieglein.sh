. $1

backup() {
	thejob=`eval echo \\$${job}`

	export thejob

	eval $lockf $lockf_params <<'TRALARI'

eval $thejob

for f in $datasets
do
	source=`echo "$f" | cut -d "|" -f 1`
	destination=`echo "$f" | cut -d "|" -f 2`

	#norecursion=1
	if [ -z "$norecursion" ]; then
		recursion_send=-R
		recursion_list=-r
	else
		recursion_list=-rd1
	fi

	destination_snaps_array=`
		zfs list -H -t snapshot -S creation -o name -rd1 $destination |
		awk '/@/ { split($1, s, /@/); print s[2] }'
	`

	[ -n "$verbose" ] && echo "($f) local snapshots:" `echo "$destination_snaps_array" | sed '11{ s/.*/.../; q; }'` 1>&2
	for destination_snap in $destination_snaps_array; do
		[ -n "$verbose" ] && echo "($f) checking snapshot $destination_snap" 1>&2

		destination_snaps=`
			zfs list -H -t snapshot -S name $recursion_list $destination |
			fgrep $destination_snap | awk '{ print $1 }' |
			sed "s|^$destination||"
		`

		source_snaps=`
			ssh $ssh_params $ssh_user@$ssh_host zfs list -H -t snapshot -S name $recursion_list $source |
			fgrep $destination_snap | awk '{ print $1 }' |
			sed "s|^$source||"
		`

		if [ "$destination_snaps" = "$source_snaps" ]; then
			[ -n "$verbose" ] && echo "($f) same snapshots found: $destination_snap" 1>&2
			break
		fi

		temp_command=$(
			echo "$source_snaps" | egrep -v "`
				echo "$destination_snaps" | sed 's|.*|^&$|'
			`" | cat -n
		)
		if [ -z "$temp_command" ]; then
			echo "($f) WARNING: More datasets in backup. It seems that some datasets are deleted" 1>&2
			break
		fi

	done

	if [ -z "$filter" ]; then
		source_snap=`
			ssh $ssh_params $ssh_user@$ssh_host zfs list -H -t snapshot -s creation -rd1 $source |
			awk 'END { split($1, s, /@/); print s[2] }'
		`
	else
		source_snap=`
			ssh $ssh_params $ssh_user@$ssh_host zfs list -H -t snapshot -s creation -rd1 $source |
			$filter $filter_params |
			awk 'END { split($1, s, /@/); print s[2] }'
		`
	fi

	if [ -z "$source_snap" ]; then
		echo "($f) WARNING: $ssh_host:$source contains no snapshots. Nothing copied" 1>&2
		continue
	fi

	if [ "$destination_snap" = "$source_snap" ]; then
		[ -n "$verbose" ] && {
			echo "($f) no newer snap. Nothing to copy"
		} 1>&2
		continue
	fi

	if [ -n "$incremental_all" ]; then
		minus_i=-I
	else
		minus_i=-i
	fi
	if [ -n "$destination_snap" ]; then
		incremental="$minus_i @$destination_snap"
	else
		incremental=""
	fi

	if [ -z "$compress" ]; then
		temp_command='ssh $ssh_params $ssh_user@$ssh_host "zfs send $send_params $recursion_send $incremental $source@$source_snap" | zfs recv $recv_params $destination'
	else
		temp_command='ssh $ssh_params $ssh_user@$ssh_host "zfs send $send_params $recursion_send $incremental $source@$source_snap | $compress $compress_params" | $decompress $decompress_params | zfs recv $recv_params $destination'
	fi
	[ -n "$verbose" ] && echo "($f) executing:" $temp_command
	eval $temp_command
done
TRALARI
}

for job in $active
do
	if [ -z "$inparallel" ]; then
		( backup )
	else
		( backup ) &
	fi
done
