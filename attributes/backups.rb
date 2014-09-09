#
# Cookbook Name:: mysql_management
# Attributes:: backups
#
# Copyright 2014, Biola University
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

default['mysql']['backup']['backup_location'] = "/backup"
default['mysql']['backup']['backup_user'] = "mysqldump_user"
default['mysql']['backup']['default_schedule'] = "daily"
default['mysql']['backup']['default_rotation_period'] = "7"
default['mysql']['backup']['daily_schedule_hour'] = "0"
default['mysql']['backup']['daily_schedule_minute'] = "30"
default['mysql']['backup']['hourly_schedule_minute'] = "0"