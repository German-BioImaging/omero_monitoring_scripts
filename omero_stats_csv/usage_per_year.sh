#!/bin/bash
date_str=$(date +"%Y-%m-%d")
outdir="/home/report_user/omero_stats_csv/output/$date_str"
mkdir -p $outdir
outfile="'$outdir/usage_per_year.csv'"

sql="SELECT extract('year' from date_trunc('year', ev.time)) AS year,
            count(ofi.size) AS n_files,
            trunc(sum(ofi.size)/pow(2,30)) AS storage_GB
     FROM FilesetEntry AS fe
     INNER JOIN OriginalFile AS ofi ON ofi.id=fe.originalFile
     INNER JOIN Fileset AS fs ON fs.id=fe.fileset
     INNER JOIN Event AS ev ON ev.id=fs.creation_id
     WHERE fs.id IN (SELECT fileset
                    FROM Image)
     GROUP BY date_trunc('year', ev.time)
     ORDER BY date_trunc('year', ev.time)"

csv_export_query="\copy ($sql) TO $outfile WITH DELIMITER ',' CSV HEADER"

psql omero -U report_user -h 127.0.0.1 -c "$csv_export_query"