#
# Cookbook Name:: ess-elastic-ls-prd
# Recipe:: _config
#
# Copyright 2016, Autodesk, Inc
#
# All rights reserved - Do Not Redistribute
#

# Per ES documentation calculate heap as 50% of total system memory
# https://www.elastic.co/guide/en/elasticsearch/reference/master/heap-size.html
memory_factor = 0.50
memory = node['memory']['total'].to_s

log 'heap message' do
  message "Reported system memory: #{memory}"
  level :info
end

# Calculate Java heap size for ES
# System Memory / 2 !> 31
heap = ((memory[0...-2].to_i / 1024) * memory_factor).to_f.round.to_i / 1024

# Make sure not to exceed 31
heap = 31 if heap > 31

log 'heap calculation' do
  message "Logstash heap calculated to be: #{heap}GB"
  level :info
end

###############
# EFS Mount
###############
# mount "/opt/elastic/logstash/data/efs" do
#     action [ :mount, :enable ]
#     device node['ess-elastic-ls-prd']['efs_mount']
#     fstype 'nfs'
#     options 'rw'
# end

###############
# Configuration
###############

execute 'set min heap size' do
  command "sed -i -e 's/-Xms[0-9]\\+[mg]/-Xms" + heap.to_s + "g/g' /etc/logstash/jvm.options"
  environment 'PATH' => "/bin:/usr/bin:#{ENV['PATH']}"
  notifies :restart, 'service[logstash]', :delayed
end

execute 'set max heap size' do
  command "sed -i -e 's/-Xmx[0-9]\\+[mg]/-Xmx" + heap.to_s + "g/g' /etc/logstash/jvm.options"
  environment 'PATH' => "/bin:/usr/bin:#{ENV['PATH']}"
  notifies :restart, 'service[logstash]', :delayed
end

execute 'set max open files' do
  command "sed -i -e 's/LS_OPEN_FILES=.*/LS_OPEN_FILES=65535/g' /etc/logstash/startup.options"
  environment 'PATH' => "/bin:/usr/bin:#{ENV['PATH']}"
  notifies :restart, 'service[logstash]', :delayed
end

execute 'start system-install' do
  command '/usr/share/logstash/bin/system-install'
  environment 'PATH' => "/bin:/usr/bin:#{ENV['PATH']}"
  notifies :restart, 'service[logstash]', :delayed
end

cookbook_file '/etc/logstash/truststore' do
  source 'etc/logstash/truststore'
  mode 0755
  owner 'logstash'
  group 'logstash'
  action :create
end

template '/etc/logstash/logstash.yml' do
  source 'logstash.yml.erb'
  mode 0400
  owner 'logstash'
  group 'logstash'
  action :create
  notifies :restart, 'service[logstash]', :delayed
end

template '/etc/logstash/conf.d/01-conf-beats-input.conf' do
  source '01-conf-beats-input.conf.erb'
  mode 0400
  owner 'logstash'
  group 'logstash'
  action :create
end

template '/etc/logstash/conf.d/02-conf-beats-input.conf' do
  source '02-conf-beats-input.conf.erb'
  mode 0400
  owner 'logstash'
  group 'logstash'
  action :create
end

template '/etc/logstash/conf.d/03-conf-http-input.conf' do
  source '03-conf-http-input.conf.erb'
  mode 0400
  owner 'logstash'
  group 'logstash'
  action :create
end

template '/etc/logstash/conf.d/04-conf-tcp-input.conf' do
  source '04-conf-tcp-input.conf.erb'
  mode 0400
  owner 'logstash'
  group 'logstash'
  action :create
end

template '/etc/logstash/conf.d/1000-conf-elasticsearch-output.conf' do
  source '1000-conf-elasticsearch-output.conf.erb'
  mode 0400
  owner 'logstash'
  group 'logstash'
  action :create
end

template '/etc/logstash/conf.d/1000-conf-http-output.conf' do
  source '1000-conf-http-output.conf.erb'
  mode 0400
  owner 'logstash'
  group 'logstash'
  action :create
end

cookbook_file '/opt/elastic/logstash/ssl/ca.crt' do
  source 'opt/elastic/logstash/ssl/ca.crt'
  mode 0400
  owner 'logstash'
  group 'logstash'
  action :create
end

cookbook_file '/opt/elastic/logstash/ssl/logstash.elastic.aws.autodesk.com.crt' do
  source 'opt/elastic/logstash/ssl/logstash.elastic.aws.autodesk.com.crt'
  mode 0400
  owner 'logstash'
  group 'logstash'
  action :create
end

cookbook_file '/opt/elastic/logstash/ssl/logstash.elastic.aws.autodesk.com.key.pk8' do
  source 'opt/elastic/logstash/ssl/logstash.elastic.aws.autodesk.com.key.pk8'
  mode 0400
  owner 'logstash'
  group 'logstash'
  action :create
end

cookbook_file '/opt/elastic/logstash/ssl/logstash.external.elastic.aws.autodesk.com.crt' do
  source 'opt/elastic/logstash/ssl/logstash.external.elastic.aws.autodesk.com.crt'
  mode 0400
  owner 'logstash'
  group 'logstash'
  action :create
end

cookbook_file '/opt/elastic/logstash/ssl/logstash.external.elastic.aws.autodesk.com.key.pk8' do
  source 'opt/elastic/logstash/ssl/logstash.external.elastic.aws.autodesk.com.key.pk8'
  mode 0400
  owner 'logstash'
  group 'logstash'
  action :create
end

cookbook_file '/opt/elastic/logstash/ssl/keystore' do
  source 'opt/elastic/logstash/ssl/keystore'
  mode 0400
  owner 'logstash'
  group 'logstash'
  action :create
end

# Elastic config update script
cookbook_file '/opt/elastic/update_elastic.sh' do
  source 'opt/elastic/update_elastic.sh'
  mode 0755
  action :create
end

cron 'elastic config update' do
  command '/opt/elastic/update_elastic.sh'
  minute '*/30'
  user 'root'
  action :create
end

# Execute the cron script to get the latest config data
execute 'elastic config update script' do
  command '/opt/elastic/update_elastic.sh'
end
