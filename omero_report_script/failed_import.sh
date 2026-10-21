#!/bin/bash
token=$(cat ~/.tok_mm)
mmserver="https://SERVER/mm/api/v4/posts"
channelid="CHANNEL_ID"

sql="SELECT f.id, templateprefix, e.time, a.textValue AS importmethod
FROM Fileset f
LEFT JOIN Image i ON f.id=i.fileset
LEFT JOIN Event e ON f.creation_id=e.id
LEFT JOIN FilesetAnnotationLink fal ON fal.parent=f.id
LEFT JOIN Annotation a ON a.id=fal.child
WHERE i.id IS NULL
AND e.time >= (now() - '14400 seconds'::interval)
AND e.time < (now() - '7200 seconds'::interval)
ORDER BY e.time DESC
LIMIT 20;"

raw_res="Failed imports:\\n\`\`\`\\n"$(psql omero -U report_user -h 127.0.0.1 -c "$sql" | sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g')"\\n\`\`\`"

regex="\(([0-9]+) row"
if [[ $raw_res =~ $regex ]]; then
    nrow="${BASH_REMATCH[1]}"
    if [[ $nrow -ge 1 ]]; then
        curl -i -X POST -H 'Content-Type: text/plain' -d '{"channel_id":"'"$channelid"'", "message":"'"$raw_res"'"}' -H 'Authorization: Bearer '"$token" "$mmserver"
    fi
fi