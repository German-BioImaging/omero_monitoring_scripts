#!/bin/bash
token=$(cat ~/.tok_mm)
mmserver="https://SERVER/mm/api/v4/posts"
channelid="CHANNEL_ID"

cd /mnt/the_location_i_want_to_check
raw_res="\`\`\`\\nFileserver root\\n"$(date +%F)"\\n"$(ls | grep AG_ | xargs du -sBG | sed -E $'s/\t/    /g' | sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g')"\\n\`\`\`"
curl -i -X POST -H 'Content-Type: text/plain' -d '{"channel_id":"'"$channelid"'", "message":"'"$raw_res"'"}' -H 'Authorization: Bearer '"$token" "$mmserver"
