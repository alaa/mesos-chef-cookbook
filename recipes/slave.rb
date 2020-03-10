include_recipe "mesos::repo"

attr = node[:mesos]

masters = Mesos.new(attr[:discovery_query], node)

package "mesos" do
  version attr[:version]
  action :install
  options "--force-yes"
  notifies :restart, 'service[mesos-slave]', :delayed
end

file '/etc/init/zookeeper.override' do
  content "manual"
end

file '/etc/init/mesos-master.override' do
  content "manual"
end

directory '/etc/mesos-slave' do
  action :create
end

file '/etc/mesos-slave/containerizers' do
  content 'docker,mesos'
  notifies :restart, 'service[mesos-slave]', :delayed
end

template '/etc/mesos/zk' do
  source "etc/mesos/zk.erb"
  variables({
    zookeepers: masters.etc_mesos_zk
  })
  notifies :restart, 'service[mesos-slave]', :delayed
end

file '/etc/mesos-slave/executor_registration_timeout' do
  content '5mins'
  notifies :restart, 'service[mesos-slave]', :delayed
end

service "mesos-slave" do
  action [:enable, :start]
end

service "mesos-master" do
  action [:disable, :stop]
end

service "zookeeper" do
  action [:disable, :stop]
end
