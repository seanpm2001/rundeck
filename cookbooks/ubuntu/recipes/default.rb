#
# Cookbook Name:: ubuntu
# Recipe:: default
#
# Copyright 2008-2009, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "apt"

template "/etc/apt/sources.list" do
  mode 00644
  variables(
    :architectures => node['ubuntu']['architectures'],
    :code_name => node['lsb']['codename'],
    :security_url => node['ubuntu']['security_url'],
    :archive_url => node['ubuntu']['archive_url'],
    :include_source_packages => node['ubuntu']['include_source_packages']
  )
  notifies :run, "execute[apt-get update]", :immediately
  source "sources.list.erb"
end

execute "set_locale_lc" do
  command "update-locale LC_ALL=#{node['ubuntu']['locale']}"
  action :run
  only_if { node['ubuntu']['locale'] }
  not_if "grep LC_ALL=#{node['ubuntu']['locale']} /etc/default/locale"
end

execute "set_locale_lang" do
  command "update-locale LANG=#{node['ubuntu']['locale']}"
  action :run
  only_if { node['ubuntu']['locale'] }
  not_if "grep LANG=#{node['ubuntu']['locale']} /etc/default/locale"
end