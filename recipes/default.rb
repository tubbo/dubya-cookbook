#
# Cookbook Name:: dubya-cookbook
# Recipe:: default
#
# Copyright (C) 2014 YOUR_NAME
#
# All rights reserved - Do Not Redistribute

include_recipe 'nginx'
include_recipe 'ruby-install'

package 'vim'

ruby_install_ruby '2.1.5'

%w(erb gem irb rake rdoc ri ruby testrb).each do |binary|
  link "/usr/local/bin/#{binary}"  do
    to "/opt/rubies/ruby-2.1.5/bin/#{binary}"
  end
end

gem_package 'bundler'

user 'dubya' do
  group 'dubya'
  home '/srv/dubya'
  action :create
end

directory '/srv/dubya' do
  user 'dubya'
  group 'dubya'
end

git '/srv/dubya' do
  repo 'https://github.com/tubbo/dubya.git'
  revision 'master'
  user 'dubya'
  group 'dubya'
end

execute 'bundle install --jobs=4' do
  cwd '/srv/dubya'
  user 'dubya'
  group 'dubya'
end

git '/srv/dubya/vendor/wiki' do
  repo node['dubya']['wiki']['repo']
  revision node['dubya']['wiki']['ref']
  user 'dubya'
  group 'dubya'
end

git '/srv/dubya/.vim' do
  repo 'https://github.com/tpope/vim-pathogen.git'
  revision 'master'
  user 'dubya'
  group 'dubya'
end

git '/srv/dubya/.vim/bundle/vimwiki' do
  repo 'https://github.com/vim-scripts/vimwiki.git'
  revision 'master'
  user 'dubya'
  group 'dubya'
end

template '/srv/dubya/.vimrc' do
  source 'vimrc.erb'
end

template '/etc/init.d/dubya.conf' do
  source 'init.conf.erb'
  notifies :start, 'service[dubya]'
end

file '/etc/nginx/sites-enabled/default' do
  action :remove
end

template '/etc/nginx/sites-available/dubya' do
  source 'site.conf.erb'
  variables directory: '/srv/dubya', domain: node['dubya']['fqdn']
end

nginx_site 'dubya' do
  action :enable
  notifies :reload, 'service[nginx]'
end
