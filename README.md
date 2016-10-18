# spieglein
Spieglein is a small tool to backup ZFS-based systems to a central backup server. It is meant to run periodically on the backup server from where it connects to remote systems and pulls backups. It is written in plain shell and the script is believed to be POSIX compliant. It uses SSH as transport, can optionally use compression, can mirror ZFS pools or individual datasets, can optionally filter out ZFS snapshot names.

It is based on the ZFS snapshot idea where a recursive snapshot is considered to be a consistent point in time that the administrator wants to back up. It always tries to use the latest snapshot found in the backup server and copy differentially to the latest snapshot found in the system-to-be backed up. If local and remote snapshots are found to differ (due to an incomplete backup for example) then it tries to use the snapshot just before the latest and this procedure goes on until a common snapshot which can be copied is found on both systems. Spieglein copies everything recursively and this can be changed explicitly per job definition.

Things that might be added later:
Pre and post backup command
Sudo support
Bandwidth throttling and data buffering

Things that spieglein does not do:
ZFS snapshots. The user should deploy his/hers own snapshot-creating tool. There is a script though.
