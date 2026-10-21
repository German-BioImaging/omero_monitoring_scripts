# omero_monitoring_scripts
Bash scripts executed periodically to send alerts to a mattermost channel

## Set up a read-only PostgreSQL user

Connect to PostgreSQL as an administrator, create the login, and grant it access
to the `omero` database. Replace the password with a strong one:

```sql
CREATE ROLE report_user LOGIN PASSWORD 'replace-with-a-strong-password';
GRANT CONNECT ON DATABASE omero TO report_user;
\connect omero
GRANT USAGE ON SCHEMA public TO report_user;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO report_user;
```

To also grant access to tables created later, run this as each role that creates
tables in the `public` schema:

```sql
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT SELECT ON TABLES TO report_user;
```

These grants allow reading tables in the `public` schema without granting
`INSERT`, `UPDATE`, or `DELETE` privileges.
