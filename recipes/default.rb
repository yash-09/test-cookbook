#
# Cookbook Name:: ess-elastic-ls-prd
# Recipe:: default
#
# Copyright 2016, Autodesk, Inc
#
# All rights reserved - Do Not Redistribute
#

# Disable SELinux
# include_recipe 'ess-elastic-selinux-disable'

###########
# Packages
###########
# Elastic states there is no performance impact when using OpenJDK
package 'java-1.8.0-openjdk-devel' do
  action :install
end

package 'java-1.7.0-openjdk' do
  action :remove
end

##############
# Installation
##############
remote_file "#{Chef::Config[:file_cache_path]}/logstash.rpm" do
  source node['ess-elastic-ls-prd']['rpm_location']
  action :create
end

rpm_package 'logstash' do
  source "#{Chef::Config[:file_cache_path]}/logstash.rpm"
  action :upgrade
end

# Install logstash-output-s3
execute 'logstash-plugin install logstash-output-s3' do
  command '/usr/share/logstash/bin/logstash-plugin install logstash-output-s3'
  environment 'PATH' => "/bin:/usr/bin:#{ENV['PATH']}"
  notifies :restart, 'service[logstash]', :delayed
  ignore_failure true
end

directory '/opt/elastic/logstash' do
  owner 'logstash'
  group 'logstash'
  mode 0755
  recursive true
  action :create
end

directory '/opt/elastic/logstash/data' do
  owner 'logstash'
  group 'logstash'
  mode 0755
  action :create
end

directory '/opt/elastic/logstash/data/efs' do
  owner 'logstash'
  group 'logstash'
  mode 0755
  action :create
end

directory "/opt/elastic/logstash/data/efs/#{node['hostname']}-queue" do
  owner 'logstash'
  group 'logstash'
  mode 0755
  action :create
end

directory '/opt/elastic/logstash/ssl' do
  owner 'logstash'
  group 'logstash'
  mode 0755
  action :create
end

###############
# Conifugration
###############
include_recipe 'ess-elastic-ls-prd::_config'
include_recipe 'ess-elastic-ls-prd::_service'

# Install metricbeat
# include_recipe 'ess-elastic-metricbeat-prd::default'

# Install Filebeat
# include_recipe 'ess-elastic-filebeat-prd::default'
