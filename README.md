# spieglein
Spieglein is a small tool to backup ZFS-based systems to a central backup server. It is designed to run periodically on the backup server from which it connects to remote systems and pulls backups. It is written in plain shell and the script is believed to be POSIX compliant. It uses SSH as transport, can optionally use compression, can mirror ZFS pools or individual datasets, can optionally filter out ZFS snapshot names.

It is based on the ZFS snapshot idea where a recursive snapshot is considered to be a consistent point in time that the administrator wants to back up. It always tries to use the latest snapshot found in the backup server and copy differentially to the latest snapshot found in the system-to-be backed up. If local and remote snapshots are found to differ (due to an incomplete backup for example) then it tries to use the snapshot just before the latest. This procedure goes on until a common snapshot which can be copied is found on both systems. Spieglein copies everything recursively and this can be changed explicitly per job definition.

Features that might be added later:

Log file per job

Pre and post backup command

Sudo support

Bandwidth throttling and data buffering





What spieglein can do:

It can clone a system to another one. Just use a similar system, boot and run spieglein from a removable medium. Then update your backup as often as needed.

It can copy recursively ZFS dataset hierarchies or non-recursively individual datasets to a remote system.

A single configuration file is enough to backup a great number of systems, either one by one or all in parallel.

Configuration can be split in many files so users can run several instances of spieglein in parallel.




=======

The actual commands used are:

zfs list

zfs send

zfs receive
