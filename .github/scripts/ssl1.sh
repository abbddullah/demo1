#!/bin/bash
SLACK_WEBHOOK_URL="$1"
DOMAINS=("www.google.com" "www.twitter.com")


for domain in "${DOMAINS[@]}"; do
    expiry_date=$(echo | openssl s_client -servername "$domain" -connect "$domain":443 2>/dev/null | openssl x509 -noout -dates | awk -F= '/^notAfter/ {print $2}')
    expiry_unix=$(date -d "$expiry_date" '+%s')
    current_unix=$(date '+%s')
    days_until_expiry=11
    #$(( (expiry_unix - current_unix) / 86400 ))
    if [[ $days_until_expiry -ge 0 && $days_until_expiry -le 30 ]]; then
        message="SSL Expiry Alert\n* Domain: $domain\n* Warning: The SSL certificate for $domain will expire in $days_until_expiry days."
        payload="{\"text\":\"$message\"}"
        curl -X POST -H 'Content-type: application/json' --data "$payload" "$SLACK_WEBHOOK_URL"
    fi
done
