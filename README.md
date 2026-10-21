# omero_monitoring_scripts
Bash scripts executed periodically to send alerts to a mattermost channel.

See https://docs.mattermost.com/developers/integrate/reference/bot-accounts to learn about bot accounts for mattermost

The scripts are shared with no guarantee. They must be edited to include your mattermost server address and channel ID where the message are posted.
The following must be edited further to include specificities of your server:
- `disk_usage_report/disk_alert.sh` → change `SOMEFILTER`
- `disk_usage_report/disk_usage.sh` → change `cd /mnt/the_location_i_want_to_check`
- `omero_stats_csv/usage_per_group_per_month_omerodir.sh` → Edit AGs.txt to list the groups you want to get a report for.

## Set up a read-only PostgreSQL user

Connect to PostgreSQL as an administrator, create the login, and grant it access
to the `omero` database. Replace the password with a strong one:

```sql
CREATE ROLE report_user LOGIN PASSWORD 'replace-with-a-strong-password';
GRANT CONNECT ON DATABASE omero TO report_user;
\connect omero
GRANT USAGE ON SCHEMA public TO report_user;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO report_user;
REVOKE SELECT ON TABLE public.password FROM report_user;
```

## Execute the scripts periodically

> [!WARNING]  
> Changing the crontab entries requires changes in the period queried by the corresponding script

The crontab entries I use are in `crontab`
