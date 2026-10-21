#!/bin/bash
date_str=$(date +"%Y-%m-%d")
outdir="/home/report_user/omero_stats_csv/output/$date_str"
mkdir -p $outdir
outfile="'$outdir/user_per_year.csv'"

sql="SELECT to_char(s.started, 'YYYY') AS year,
            count(DISTINCT e.omeName) AS single_user
     FROM Session s
     INNER JOIN Experimenter AS e ON e.id=s.owner
     GROUP BY to_char(s.started, 'YYYY')"

csv_export_query="\copy ($sql) TO $outfile WITH DELIMITER ',' CSV HEADER"

psql omero -U report_user -h 127.0.0.1 -c "$csv_export_query"