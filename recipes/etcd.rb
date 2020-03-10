attr = node[:etcd]

masters = Mesos.new(node[:mesos][:discovery_query], node)

docker_image = sprintf("%s/%s:%s", attr[:registry], attr[:image], attr[:tag])

execute 'fetch etcd image' do
  command "sudo docker pull #{docker_image}"
end

template "/lib/systemd/system/etcd.service" do
  source 'etc/systemd/etcd.conf.erb'
  owner "root"
  group "root"
  mode "0644"
  action :create
  variables({
    docker_image: docker_image,
    container_name: 'etcd',
    data_dir: attr[:data_dir],
    cluster_token: 'calico',
    node_name: sprintf("etcd%s", masters.masters.find_index(node[:ipaddress])),
    ip: node[:ipaddress],
    initial_cluster: masters.masters
                            .map.with_index{|ip,i| sprintf("etcd%d=http://%s:2380", i, ip)}
                            .join(',')
  })
  notifies :run, 'execute[systemctl-daemon-reload]', :immediately
  notifies :restart, "service[etcd]", :delayed
end

execute "systemctl-daemon-reload" do
  command "systemctl daemon-reload"
end

service "etcd" do
  action [:enable, :start]
end
