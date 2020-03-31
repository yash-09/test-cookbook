#
# Cookbook Name:: ess-elastic-ls-prd
# Recipe:: _service
#
# Copyright 2016, Autodesk, Inc
#
# All rights reserved - Do Not Redistribute
#

###########
# Services
###########
service 'logstash' do
  action :start
  provider Chef::Provider::Service::Upstart
  supports restart: true, status: true
end
