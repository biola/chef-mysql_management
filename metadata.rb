name             'mysql_management'
maintainer       'Biola University'
maintainer_email 'jared.king@biola.edu'
license          'Apache 2.0'
description      'Manages MySQL databases, users, and backups'
long_description 'Manages MySQL databases, users, and backups using data bags and the database cookbook'
version          '3.0.0'

depends          'chef-vault', '~> 1.1.2'
depends          'cron', '~> 1.4.0'
depends          'database', '~> 2.3.0'
depends          'mysql', '~> 5.5.2'