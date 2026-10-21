#!/bin/bash
token=$(cat ~/.tok_mm)
mmserver="https://SERVER/mm/api/v4/posts"
channelid="CHANNEL_ID"

sql="SELECT count(o.size) AS n_files, trunc(sum(o.size)/pow(2,20)) AS storage_mb, g.name
FROM FilesetEntry AS f
INNER JOIN OriginalFile AS o ON f.originalFile=o.id
INNER JOIN Fileset AS i ON i.id=f.fileset
INNER JOIN Event AS e ON e.id=i.creation_id
INNER JOIN ExperimenterGroup AS g ON g.id=i.group_id
WHERE i.id IN (SELECT fileset
               FROM Image)
      AND e.time > (Now() - '1 week'::interval)
GROUP BY g.name
ORDER BY sum(o.size) DESC;
"

raw_res="Data added in the past week:\\n\`\`\`\\n"$(psql omero -U report_user -h 127.0.0.1 -c "$sql" | sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g')"\\n\`\`\`"

curl -i -X POST -H 'Content-Type: text/plain' -d '{"channel_id":"'"$channelid"'", "message":"'"$raw_res"'"}' -H 'Authorization: Bearer '"$token" "$mmserver"