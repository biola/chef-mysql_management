#
# Cookbook Name:: mysql_management
# Recipe:: default
#
# Copyright 2015, Biola University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "chef-vault"

# Create the backup location if needed
directory node['mysql']['backup']['backup_location'] do
  owner "root"
  group "root"
  mode "0700"
  recursive true
  action :create
end

# Store backup definitions in an array of hashes
backup_definitions = Array.new

# Loop through all of the items in the data bag containing MySQL database configuration
mysql_databases = data_bag(node['mysql']['management']['databases_databag'])
mysql_databases.each do |db_name|
  database = data_bag_item(node['mysql']['management']['databases_databag'], db_name)
  backup_schedule = database['backup_schedule'] ? database['backup_schedule'] : node['mysql']['backup']['default_schedule']
  unless backup_schedule == 'none'
    # Add the database to the backup definitions
    backup_rotation_period = database['backup_rotation_period'] ? database['backup_rotation_period'] : node['mysql']['backup']['default_rotation_period']
    backup_definitions << { "db_name" => db_name, "schedule" => backup_schedule, "rotation_period" => backup_rotation_period }

    # Create a subdirectory for the backups
    directory "#{node['mysql']['backup']['backup_location']}/#{db_name}" do
      owner "root"
      group "root"
      mode 00755
      action :create
    end
  end
end

# Sort the definitions by database name
backup_definitions.sort! {|a,b| a['db_name'] <=> b['db_name'] }

# Save the backup definitions to a local file
template "#{node['mysql']['backup']['backup_location']}/backup_definitions" do
  source "backup_definitions.erb"
  mode 0644
  owner "root"
  group "root"
  variables(
    :backup_definitions => backup_definitions
  )
end

# Retrieve authentication information from the data bag containing MySQL user configuration
backup_user = chef_vault_item(node['mysql']['management']['users_vault'], node['mysql']['backup']['backup_user'])

# Create the backup script
template "#{node['mysql']['backup']['backup_location']}/scheduled_backup.sh" do
  source "scheduled_backup.sh.erb"
  mode 0700
  owner "root"
  group "root"
  variables(
    :backup_user => node['mysql']['backup']['backup_user'],
    :backup_password => backup_user['password']
  )
end

# Schedule hourly and daily backup jobs
cron_d "mysql_hourly_backup" do
  minute node['mysql']['backup']['hourly_schedule_minute']
  command "#{node['mysql']['backup']['backup_location']}/scheduled_backup.sh hourly"
end

cron_d "mysql_daily_backup" do
  minute node['mysql']['backup']['daily_schedule_minute']
  hour node['mysql']['backup']['daily_schedule_hour']
  command "#{node['mysql']['backup']['backup_location']}/scheduled_backup.sh daily"
end
