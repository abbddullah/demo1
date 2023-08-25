#!/bin/bash

# Get Slack webhook URL from the first argument
SLACK_WEBHOOK_URL="$1"

# List of domains to check
DOMAINS=("www.google.com" "www.twitter.com")

# Loop through domains
for domain in "${DOMAINS[@]}"; do
    # Retrieve SSL expiry date and calculate days remaining
    expiry_date=$(echo | openssl s_client -servername "$domain" -connect "$domain":443 2>/dev/null | openssl x509 -noout -dates | awk -F= '/^notAfter/ {print $2}')
    expiry_unix=$(date -d "$expiry_date" '+%s')
    current_unix=$(date '+%s')
    days_until_expiry=11
    #$(( (expiry_unix - current_unix) / 86400 ))
    # Check if expiry is within 30 days
    if [[ $days_until_expiry -ge 0 && $days_until_expiry -le 30 ]]; then
        # Prepare and send Slack alert
        message="SSL Expiry Alert\n* Domain: $domain\n* Warning: The SSL certificate for $domain will expire in $days_until_expiry days."
        payload="{\"text\":\"$message\"}"
        curl -X POST -H 'Content-type: application/json' --data "$payload" "$SLACK_WEBHOOK_URL"
    fi
done
