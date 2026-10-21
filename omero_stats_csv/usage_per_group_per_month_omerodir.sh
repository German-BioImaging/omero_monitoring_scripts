#!/bin/bash
date_str=$(date +"%Y-%m-%d")
outdir="/home/report_user/omero_stats_csv/output/$date_str"
mkdir -p $outdir
outfile="'$outdir/usage_per_group_per_month_omerodir.csv'"

n_group=$(wc -w AGs.txt | awk '{ print $1 }')

# Desired output SQL
# sql="WITH data AS (
#         SELECT yr_mt, sum(AG_xyz) AS AG_xyz
#         FROM (SELECT to_char(e.time, 'YYYY-MM') AS yr_mt,
#                 CASE WHEN g.name = 'AG_xyz' THEN sum(o.size) ELSE 0 END AS AG_xyz,
#               FROM FilesetEntry AS f
#              INNER JOIN OriginalFile AS o ON o.id=f.originalFile
#               INNER JOIN Fileset AS i ON i.id=f.fileset
#               INNER JOIN Event AS e ON e.id=i.creation_id
#               INNER JOIN ExperimenterGroup AS g ON g.id=i.group_id
#               WHERE f.clientpath NOT LIKE 'mnt/inplace_import/%' AND i.id IN (SELECT fileset FROM Image)
#               GROUP BY yr_mt, g.name
#               ) AS sub
#         GROUP BY yr_mt
#         )
#     SELECT yr_mt,
#            trunc(sum(AG_xyz) OVER (ORDER BY yr_mt ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)/pow(2,30)) AS AG_xyz,
#     FROM data"

# My inplace_import files are in /mnt/inplace_import/...

sql_shard_1="WITH data AS (SELECT yr_mt,"
sql_shard_2="FROM (SELECT to_char(e.time, 'YYYY-MM') AS yr_mt,"
sql_shard_3="FROM FilesetEntry AS f
             INNER JOIN OriginalFile AS o ON o.id=f.originalFile
             INNER JOIN Fileset AS i ON i.id=f.fileset
             INNER JOIN Event AS e ON e.id=i.creation_id
             INNER JOIN ExperimenterGroup AS g ON g.id=i.group_id
             WHERE f.clientpath NOT LIKE 'mnt/inplace_import/%' AND i.id IN (SELECT fileset FROM Image)
             GROUP BY yr_mt, g.name
             ) AS sub
         GROUP BY yr_mt
         )
     SELECT yr_mt AS month,"

count_line=0
while read -r line; do
    ((count_line++))
    sql_shard_1=$sql_shard_1"sum($line) AS $line "
    sql_shard_2=$sql_shard_2"CASE WHEN g.name = '$line' THEN sum(o.size) ELSE 0 END AS $line "
    sql_shard_3=$sql_shard_3"trunc(sum($line) OVER (ORDER BY yr_mt ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)/pow(2,30)) AS $line "
    if (($count_line < $n_group)); then
         sql_shard_1=$sql_shard_1","
         sql_shard_2=$sql_shard_2","
         sql_shard_3=$sql_shard_3","
    fi
done < AGs.txt
sql=$sql_shard_1$sql_shard_2$sql_shard_3" FROM data"

csv_export_query="\copy ($sql) TO $outfile WITH DELIMITER ',' CSV HEADER"

psql omero -U report_user -h 127.0.0.1 -c "$csv_export_query"