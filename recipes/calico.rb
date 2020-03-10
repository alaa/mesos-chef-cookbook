attr = node[:mesos][:calico]

masters = Mesos.new(node[:mesos][:discovery_query], node)

remote_file '/usr/local/bin/calicoctl' do
  source sprintf("https://github.com/projectcalico/calicoctl/releases/download/%s/calicoctl", attr[:calicoctl_version])
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

execute "pull calcio node image" do
  command sprintf("docker pull %s:%s", attr[:calico_node_repo], attr[:calico_node_version])
end

etcd_endpoints = masters.masters.map{|x| sprintf("http://%s:2379", x)}.join(',').to_s

template "/lib/systemd/system/calico.service" do
  source 'etc/systemd/calico.service.erb'
  owner "root"
  group "root"
  mode "0644"
  action :create
  variables({
    etcd_endpoints: etcd_endpoints,
    calico_node_repo: attr[:calico_node_repo],
    calico_node_version: attr[:calico_node_version],
  })
  notifies :run, 'execute[systemctl-daemon-reload]', :immediately
  notifies :restart, "service[calico]", :delayed
end

execute "systemctl-daemon-reload" do
  command "systemctl daemon-reload"
end

service "calico" do
  action [:enable]
end
