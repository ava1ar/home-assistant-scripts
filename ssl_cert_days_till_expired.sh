#!/bin/bash
#
# Prints number of days left until certificate for the specified domain name (and optionally port) will expire
#

# print usage and exit
usage() {
  cat <<EOM
Usage: $(basename $0) server_name [port]

EOM
  exit 0
}

# show usage if started w/o arguments
[ -z $1 ] && { usage; }

# get server_name from $1
server_name=$1
# get port from $2
port=$2

# check if ${server_name} was specified (error if not specified)
if [[ -z ${server_name} ]]; then
  echo "Missing server name!"
  exit 1
fi

# check if ${port} was specified (default to 443 if not specified)
if [[ -z ${port} ]]; then
  port=443
fi

# get expiration date for certificate
expiration_date=$(echo | openssl s_client -servername ${server_name} -connect ${server_name}:${port} 2>/dev/null | openssl x509 -noout -enddate 2>/dev/null | awk -F= '{print $2}')

# check if received ${expiration_date} is not empty (return error is empty)
if [[ -z ${expiration_date} ]]; then
  echo "Error!"
  exit 1
fi

# calculate number of days between ${expiration_date} and current time
days_till_expiration=$(( ($(date -d "${expiration_date}" '+%s') - $(date '+%s')) / 86400 ))

if [[ ! $days_till_expiration -gt 0 ]]; then
  echo Expired!
else
  echo ${days_till_expiration} days
fi
