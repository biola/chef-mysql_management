# mysql_management-cookbook

This cookbook automates the creation of MySQL databases, users, and backups. Configuration is stored in data bags and chef-vault items, and the resources in the database cookbook (https://supermarket.getchef.com/cookbooks/database) are leveraged to create the databases and users.

## Supported Platforms

Tested on Ubuntu 12.04, but should work on any modern Ubuntu distribution.

## Attributes

### mysql_management::default

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['mysql']['management']['databases_databag']</tt></td>
    <td>String</td>
    <td>Data bag containing database configuration</td>
    <td>mysql_databases</td>
  </tr>
  <tr>
    <td><tt>['mysql']['management']['users_vault']</tt></td>
    <td>String</td>
    <td>Chef vault containing user configuration</td>
    <td>mysql_users</td>
  </tr>
</table>

### mysql_management::backups

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['mysql']['backup']['backup_location']</tt></td>
    <td>String</td>
    <td>Location to store backups</td>
    <td>/backup</td>
  </tr>
  <tr>
    <td><tt>['mysql']['backup']['backup_user']</tt></td>
    <td>String</td>
    <td>Database user to connect with</td>
    <td>mysqldump_user</td>
  </tr>
  <tr>
    <td><tt>['mysql']['backup']['default_schedule']</tt></td>
    <td>String</td>
    <td>Default backup schedule to use</td>
    <td>daily</td>
  </tr>
  <tr>
    <td><tt>['mysql']['backup']['default_rotation_period']</tt></td>
    <td>String</td>
    <td>Default rotation period for backup files</td>
    <td>7</td>
  </tr>
  <tr>
    <td><tt>['mysql']['backup']['daily_schedule_hour']</tt></td>
    <td>String</td>
    <td>Hour to run daily backups</td>
    <td>0</td>
  </tr>
  <tr>
    <td><tt>['mysql']['backup']['daily_schedule_minute']</tt></td>
    <td>String</td>
    <td>Minute to run daily backups</td>
    <td>30</td>
  </tr>
  <tr>
    <td><tt>['mysql']['backup']['hourly_schedule_minute']</tt></td>
    <td>String</td>
    <td>Minute to run hourly backups</td>
    <td>0</td>
  </tr>
</table>

## Usage

### mysql_management::default

Include `mysql_management` in your node's `run_list`. Ensure that a chef-vault item for the root user has been created.

Create a `mysql_databases` data bag in Chef to hold database configuration. In the below example, `encoding`, `backup_schedule`, and `backup_rotation_period` are optional. A database can be created simply with an "id" and other options can be added later if needed.

```json
{
  "id": "database_name",
  "encoding": "utf8",
  "backup_schedule": "daily",
  "backup_rotation_period": "7"
}
```

Database user configuration must be stored with chef-vault. Items in the `mysql_users` vault should be in the format below. Note that any users that do not have permissions assigned will be ignored by this cookbook.

```json
{
  "id": "user_name",
  "hosts": [
    "localhost"
  ],
  "password": "notarealpassword",
  "privileges": {
    "db1": [
      "select",
      "insert"
    ],
    "*": [
      "select"
    ]
  }
}
```

### mysql_management::backups

Include `mysql_management::backups` in your node's `run_list`. Ensure that a chef-vault item for the backup user (default `mysqldump_user`) has been created and has appropriate permission to back up the databases in the `mysql_databases` data bag.

## License and Authors

Author:: Biola University (<jared.king@biola.edu>)