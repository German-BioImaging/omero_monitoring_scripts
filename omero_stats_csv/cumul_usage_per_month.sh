#!/bin/bash
date_str=$(date +"%Y-%m-%d")
outdir="/home/report_user/omero_stats_csv/output/$date_str"
mkdir -p $outdir
outfile="'$outdir/cumul_usage_per_month.csv'"

sql="WITH data AS (SELECT date_trunc('month', e.time) AS month,
                          count(o.size) AS n_files,
                          sum(o.size) AS storage_GB
                   FROM FilesetEntry AS f
                   INNER JOIN OriginalFile AS o ON o.id=f.originalFile
                   INNER JOIN Fileset AS i ON i.id=f.fileset
                   INNER JOIN Event AS e ON e.id=i.creation_id
                   WHERE i.id IN (SELECT fileset
                                  FROM Image)
                   GROUP BY date_trunc('month', e.time)
                   ORDER BY date_trunc('month', e.time))
     SELECT month,
            sum(n_files) OVER (ORDER BY month ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS n_files,
            trunc(sum(storage_gb) OVER (ORDER BY month ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)/pow(2,30)) AS storage_gb
     FROM data
"

csv_export_query="\copy ($sql) TO $outfile WITH DELIMITER ',' CSV HEADER"

psql omero -U report_user -h 127.0.0.1 -c "$csv_export_query"
