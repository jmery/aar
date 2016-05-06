#
# Cookbook Name:: aar
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
#

# Make sure apt is up to date before we do any installs
include_recipe 'apt'

# Install required packages
node['aar']['required-packages'].each do |p|
  package "#{p}"
end

# Enable and start apache2
service 'apache2' do
  action [ :enable, :start ]
end

# Install some python stuff we need
python_pip "Flask"

# Make sure the default www doc root exists
directory '/var/www' do
  recursive true
end

# Deploy our application directory from the Cookbook
# Could also pull from a repo like github
remote_directory '/var/www/AAR' do
  source 'AAR'
  owner "#{node['aar']['web-user']}"
  group "#{node['aar']['web-group']}"
  files_owner "#{node['aar']['web-user']}"
  files_group "#{node['aar']['web-group']}"
  action :create
end

# Deploy the website config file from the Cookbook
template '/etc/apache2/sites-available/AAR-apache.conf' do
  source 'AAR-apache.conf.erb'
  owner 'root'
  group 'root'
  mode 644
end

# Enable the AAR site
link "/etc/apache2/sites-enabled/AAR-apache.conf" do
  to "/etc/apache2/sites-available/AAR-apache.conf"
  notifies :restart, "service[apache2]"
end

# Remove the default site
link "/etc/apache2/sites-enabled/000-default.conf" do
  to "/etc/apache2/sites-available/000-default.conf"
  action :delete
  notifies :restart, "service[apache2]"
end

# Deploy app connectivity config file from Cookbook
template '/var/www/AAR/AAR_config.py' do
  source 'AAR_config.py.erb'
  owner "#{node['aar']['web-user']}"
  group "#{node['aar']['web-group']}"
  mode 0644
end

# Get our DB creation script to a place we can use it
template '/tmp/make_AARdb.sql' do
  source 'make_AARdb.sql.erb'
  owner 'root'
  group 'root'
  mode 0644
end

# Make sure MySQL is enabled and started
service 'mysql' do
  action [ :enable, :start ]
end

# Install the mysql2 Ruby gem
mysql2_chef_gem 'default' do
  action :install
end

mysql_connection_info = {
  :host => "#{node['aar']['mysql-host']}",
  :username => "#{node['aar']['mysql-root-user']}",
  :password => "#{node['aar']['mysql-root-password']}"
}

# Create our database
mysql_database node['aar']['app-db'] do
  connection mysql_connection_info
  action :create
end

# Add our database user
mysql_database_user node['aar']['app-db-user'] do
  connection mysql_connection_info
  password "#{node['aar']['app-db-password']}"
  database_name "#{node['aar']['app-db']}"
  host "#{node['aar']['mysql-host']}"
  privileges [ :create, :insert, :delete, :update, :select, :alter ]
  action [ :create, :grant ]
end


# Run DB creation script
execute 'initialize-database' do
  command "mysql -h localhost -u #{node['aar']['app-db-user']} -p#{node['aar']['app-db-password']} -D #{node['aar']['app-db']} < /tmp/make_AARdb.sql"
  not_if  "mysql -h localhost -u #{node['aar']['app-db-user']} -p#{node['aar']['app-db-password']} -D #{node['aar']['app-db']} -e 'select * from users;'"
  notifies :restart, 'service[apache2]', :immediately
end
