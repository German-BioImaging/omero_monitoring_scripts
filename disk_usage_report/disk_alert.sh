#!/bin/bash
token=$(cat ~/.tok_mm)
mmserver="https://SERVER/mm/api/v4/posts"
channelid="CHANNEL_ID"

# Check the output of df -h and add SOMEFILTER if you don't want to see all the lines.

result=$(df -h | grep SOMEFILTER | awk '$4 ~ /T/ && $4+0 < 2 {print "Less than 2TB free on: "$0}')
if [ -n "$result" ]; then
  raw_res="\`\`\`\\nFileserver root\\n"$(date +%F)"\\n"$(df -h | awk '$4 ~ /T/ && $4+0 < 2 {print "Less than 2TB free on: "$0}' | sed -E $'s/\t/    /g' | sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g')"\\n\`\`\`"
  curl -i -X POST -H 'Content-Type: text/plain' -d '{"channel_id":"'"$channelid"'", "message":"'"$raw_res"'"}' -H 'Authorization: Bearer '"$token" "$mmserver"
fi
