#
# Cookbook Name:: wt_analytics
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

if deploy_mode? 
  include_recipe "wt_analytics::uninstall" 
  include_recipe "ms_dotnet4::resetiis"
  # source build
	build_data = data_bag_item('wt_builds', node.chef_environment)
	build_id = build_data[node['wt_search']['tc_proj'] ]
	base_url = 'http://teamcity.webtrends.corp/guestAuth/app/rest/builds/' + build_id

	response = RestClient.get base_url
	btID = nil
	build_doc = REXML::Document.new(response.body)
	build_doc.elements.each('//buildType') do |type|
		btID = type.attributes["id"]
	end
	install_url = "http://teamcity.webtrends.corp/guestAuth/repository/download/#{btID}/#{build_id}:id/#{node['wt_analytics']['artifact']}"
	log install_url
end

#Properties
install_dir = node['wt_common']['install_dir_windows']node['wt_analytics']['install_dir']
install_logdir = node['wt_common']['install_log_dir_windows']
pod = node.chef_environment
user_data = data_bag_item('authorization', pod)
ui_user = user_data['wt_common']['ui_user']
ui_password = user_data['wt_common']['ui_pass']

directory install_logdir do
	action :create
end

iis_site 'Default Web Site' do
	action [:stop, :delete]
end

iis_site 'Analytics' do
	protocol :http
    port 80
    path "#{node['wt_common']['install_dir_windows']}\\Insight"
	action [:add,:start]
end

wt_base_firewall 'A10WS' do
	protocol "TCP"
	port 80
	action [:open_port]
end

if deploy_mode?
	windows_zipfile install_dir do
		source install_url
		action :unzip
	end
	
	iis_pool "Webtrends_Analytics" do
  	  pipeline_mode :Integrated
  	  runtime_version "4.0"
      action [:add, :config]
    end
end