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

# Install dependencies
include_recipe "chef-vault"

# Retrieve authentication information from the vault containing MySQL user configuration
root_password = chef_vault_item(node['mysql']['management']['users_vault'], "root")['password']

# Create a hash of MySQL authentication info
mysql_connection_info = { :host => "127.0.0.1", :username => 'root', :password => root_password }

# Loop through all of the items in the data bag containing MySQL database configuration
if Chef::DataBag.list.key?(node['mysql']['management']['databases_databag'])
  mysql_databases = data_bag(node['mysql']['management']['databases_databag'])
  mysql_databases.each do |db_name|
    database = data_bag_item(node['mysql']['management']['databases_databag'], db_name)
    # Create the database if it doesn't exist
    mysql_database db_name do
      connection mysql_connection_info
      collation database['collation'] if database['collation']
      encoding database['encoding'] if database['encoding']
      action :create
    end
  end
else
  Chef::Log.info('Data bag for MySQL databases not found. Skipping...')
end

# Loop through all of the items in the vault containing MySQL user configuration
if Chef::DataBag.list.key?(node['mysql']['management']['users_vault'])
  mysql_users = data_bag(node['mysql']['management']['users_vault'])
  mysql_users.each do |user_name|
    user = chef_vault_item(node['mysql']['management']['users_vault'], user_name)
    # Grant permissions on each of the databases configured
    if user['privileges']
      user['privileges'].each do |db_name, db_privileges|
        user['hosts'].each do |h|
          mysql_database_user user_name do
            connection mysql_connection_info
            host h
            database_name db_name
            password user['password']
            privileges db_privileges
            action :grant
          end
        end
      end
    end
  end
else
  Chef::Log.info('Data bag for MySQL users not found. Skipping...')
end
