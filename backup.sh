#!/usr/bin/env bash

# Assuming the repo in the ${HOME}/SimpleNetworkMonitor directory
HOSTS_FILE="${HOME}/SimpleNetworkMonitor/.backup_list"
LOG_FILE="${HOME}/SimpleNetworkMonitor/.backup_log"
MAIL_FILE="${HOME}/SimpleNetworkMonitor/.backup_mail"

function check_connection()
{
    #TODO: consider case when LOG_FILE is not writable
    for i in {1..5}
    do
    	ping -c 1 -W 2 -q "$1" >/dev/null 2>&1 && return 0
    done
    printf "Connection problem :: host :: $1" >> "${LOG_FILE}"
    return 1
}

function get_hostname()
{
    #TODO: add more robust regex to get hostname
    echo $1 | awk 'BEGIN {FS="@"; hostname="not_valid"} { if ($0 ~ /@/) {hostname=$2;} } END {print hostname}'
}

function send_email()
{
    #TODO: add more robust regex to get email address
    local MAILS=$(cat ${MAIL_FILE} | awk -vORS=, '{ if($0 ~ /^#/) {next} else if ($0 ~ /@/) {print $0;} }' | sed 's/,$//')
    cat ${LOG_FILE} | /usr/sbin/sendmail "${MAILS}" 
}

function update_log()
{
    printf "Subject: Connection problem in 210-2\n\n" > "${LOG_FILE}"
    printf "$(date)\n" >> "${LOG_FILE}"
}

update_log

ERROR_STATUS="false"

if [[ ! -r ${HOSTS_FILE} ]]; then
    echo "Couldn't find the \"${HOSTS_FILE}\" file" >> "${LOG_FILE}"
    ERROR_STATUS="true"
else
    HOSTS=$(cat ${HOSTS_FILE} | awk '{ if( $0 ~ /^#/ ) {next} else {gsub(/ /, "", $0); print} }')
	
    for HOST in ${HOSTS}
    do
        HOSTNAME=$(get_hostname ${HOST})
        check_connection ${HOSTNAME}
        if [[ $? -eq 0 ]]; then
            echo "COOL!"
        else
            ERROR_STATUS="true"
            #/usr/bin/notify-send --urgency=critical "ACHTUNG!" "${HOSTNAME} is unreachable"
        fi
    done
fi

if [[ "${ERROR_STATUS}" == "true" ]]; then
    send_email
fi
