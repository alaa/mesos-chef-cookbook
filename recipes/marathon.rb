include_recipe "mesos::repo"
include_recipe "java"

attr = node[:mesos][:marathon]

directory '/etc/marathon' do
  action :create
end

package "marathon" do
  version attr[:version]
  action [:install]
  notifies :restart, 'service[marathon]', :delayed
end

template '/etc/default/marathon' do
  source 'etc/default/marathon.erb'
  variables({
    marathon_reconciliation_interval: 15000
  })
  notifies :restart, 'service[marathon]', :delayed
end

service "marathon" do
  action [:enable, :start]
end

