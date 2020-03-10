include_recipe "mesos::repo"

attr = node[:mesos]
zk = attr[:zk]

masters = Mesos.new(attr[:discovery_query], node)

package "mesos" do
  version attr[:version]
  action :install
  options "--force-yes"
  notifies :restart, 'service[mesos-master]', :delayed
end

service "mesos-master" do
  action [:enable, :start]
end

# disable slave from running automatically
file '/etc/init/mesos-slave.override' do
  content "manual"
end

template '/etc/mesos/zk' do
  source "etc/mesos/zk.erb"
  variables({
    zookeepers: masters.etc_mesos_zk
  })
  notifies :restart, 'service[mesos-master]', :delayed
end

file '/etc/mesos-master/quorum' do
  content masters.quorum
  notifies :restart, 'service[mesos-master]', :delayed
end

file '/etc/mesos-master/work_dir' do
  content '/var/lib/mesos'
  notifies :restart, 'service[mesos-master]', :delayed
end

# Duration of time to wait in order to store data in the registry after which
# the operation is considered a failure. (default: 20secs)
file '/etc/mesos-master/registry_store_timeout' do
  content '10secs'
  notifies :restart, 'service[mesos-master]', :delayed
end

# Duration of time to wait in order to fetch data from the registry after
# which the operation is considered a failure. (default: 1mins)
file '/etc/mesos-master/registry_fetch_timeout' do
  content '10secs'
  notifies :restart, 'service[mesos-master]', :delayed
end

file '/etc/mesos-master/max_agent_ping_timeouts' do
  content '1'
  notifies :restart, 'service[mesos-master]', :delayed
end

file '/etc/mesos-master/agent_ping_timeout' do
  content '10secs'
  notifies :restart, 'service[mesos-master]', :delayed
end

file '/etc/zookeeper/conf/myid' do
  content masters.zk_myid
  notifies :restart, 'service[zookeeper]', :delayed
end

template '/etc/zookeeper/conf/zoo.cfg' do
  source 'etc/zookeeper/zoo.cfg.erb'
  variables({
    ticktime: zk[:ticktime],
    dataDir: zk[:dataDir],
    clientPort: zk[:clientPort],
    initLimit: zk[:initLimit],
    syncLimit: zk[:syncLimit],
    zookeepers: masters.zoo_cfg
  })
  notifies :restart, 'service[zookeeper]', :delayed
end

service "zookeeper" do
  action :nothing
end

service "mesos-master" do
  action :nothing
end

service "mesos-slave" do
  action [:disable, :stop]
end

