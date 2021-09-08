# Description
Simple script to monitor network connection

# Structure
 - *backup.sh* : bash script that does all the work (it is the one who should appear in the crontab)
 - *.backup_list* : the file containing hosts to monitor
 - *.backup_log*  : the log file which is to be sent by email (created automatically)
 - *.backup_mail* : the file containing the recipients which is to be informed in case of a connection error

# Usage
## Hosts to monitor
Place the desired machine hostname (with a user name) in the *.backup_list*, e.g.:

```
user1@my.host.name
user2@other.host.name
```

## Who is to be informed
Place the recipients in the *.backup_mail*, e.g.:

```
user1@gmail.com
user2@gmail.com
```

## How to run
It is convenient to use the script as a scheduled job (e.g. using `cron`):

Type

```
crontab -e
```

then place the following line (execute the job hourly):

```
0 * * * * /path/to/backup.sh >/dev/null 2>&1
```

save and quit.
