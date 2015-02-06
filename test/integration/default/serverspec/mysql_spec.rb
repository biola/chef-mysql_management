require 'serverspec'

set :backend, :exec
set :path, '/sbin:/usr/sbin:$PATH'

describe "mysql" do
  it "is listening on port 3306" do
    expect(port(3306)).to be_listening
  end

  it "has a running service of mysql" do
    expect(service("mysql")).to be_running
  end
end

describe "MySQL database and user created" do
  describe "'db1' database exists" do
    describe command(
      "echo \"SHOW DATABASES LIKE 'db1'\" | mysql --host=127.0.0.1 --user=root --password=ilikerandompasswords"
    ) do
      its(:stdout) { should match /db1/ }
    end
  end

  describe "'mysqldump_user' is created for localhost" do
    describe command(
      "echo \"SELECT User, Host FROM mysql.user\" | mysql --host=127.0.0.1 --user=root --password=ilikerandompasswords"
    ) do
      its(:stdout) { should match /mysqldump_user\tlocalhost/ }
    end
  end
end

describe "MySQL backups set up" do
  describe file('/backup') do
    it { should be_directory }
  end

  describe file('/backup/backup_definitions') do
    it { should be_file }
    it { should contain 'db1:daily:7' }
  end

  describe file('/backup/scheduled_backup.sh') do
    it { should be_file }
  end

  describe file('/etc/cron.d/mysql_daily_backup') do
    it { should be_file }
    it { should contain '30 0 * * * root /backup/scheduled_backup.sh daily' }
  end

  describe file('/etc/cron.d/mysql_hourly_backup') do
    it { should be_file }
    it { should contain '0 * * * * root /backup/scheduled_backup.sh hourly' }
  end
end
