!/bin/bash
token=$(cat ~/.tok_mm)
mmserver="https://SERVER/mm/api/v4/posts"
channelid="CHANNEL_ID"

nseconds=301
sql="SELECT id, firstName, lastName, time
FROM (SELECT e.id, e.firstName, e.lastName, min(s.started) AS time, e.email
      FROM Session AS s
      INNER JOIN Experimenter AS e ON e.id=s.owner
      GROUP BY e.id
      ORDER BY time DESC) AS first_conn
WHERE time > (Now() - '$nseconds seconds'::interval)"


raw_res="There is a new user:\\n\`\`\`\\n"$(psql omero -U report_user -h 127.0.0.1 -c "$sql" | sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g')"\\n\`\`\`"
regex="\(([0-9]+) row"
if [[ $raw_res =~ $regex ]]; then
    nrow="${BASH_REMATCH[1]}"
    if [[ $nrow -ge 1 ]]; then
        curl -i -X POST -H 'Content-Type: text/plain' -d '{"channel_id":"'"$channelid"'", "message":"'"$raw_res"'"}' -H 'Authorization: Bearer '"$token" "$mmserver"
    fi
fi