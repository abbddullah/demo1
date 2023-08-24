#!/bin/bash

SLACK_URL="$1"
DOMAINS=("www.google.com" "www.github.com" "www.twitter.com")

for i in "$DOMAINS[@]"; do
  days_to_expire=$(echo | openssl s_client -servername "$i" -connect "$i":443 2> /dev/null | openssl x509 -noout -dates | awk -F= '/^notAfter/ {print $2}' )
  expiry_unix=$(date -d "$days_to_expire" '+%s')
  current_unix=$(date '+%s') 
  no_of_days_left=5
  	if [[ $no_of_days_left -ge 0 && no_of_days_left -le 30 ]]; then 
  		msg="SSL Expiry Alert \n*Domain: $i \n*Domain:$i\n*Warning: The SSL certificate for $i will expire in $no_of_days_left."
    		payload="{\"text\":\"$msg\"}"
		curl -X POST -H 'Content-type: application/json' --data "$payload" "$SLACK_URL
    	fi
 done
