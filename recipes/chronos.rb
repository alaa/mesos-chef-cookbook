attr = node[:chronos]

masters = Mesos.new(node[:mesos][:discovery_query], node)

docker_image = sprintf("%s/%s:%s", attr[:registry], attr[:image], attr[:tag])

execute 'fetch chronos image' do
  command "sudo docker pull #{docker_image}"
end

template "/lib/systemd/system/chronos.service" do
  source 'etc/systemd/chronos.conf.erb'
  owner "root"
  group "root"
  mode "0644"
  action :create
  variables({
    docker_image: docker_image,
    container_name: 'chronos',
    zookeeper_urls: masters.etc_mesos_zk.to_s.gsub(/[\[\]\"\ ]/, '')
  })
  notifies :run, 'execute[systemctl-daemon-reload]', :immediately
  notifies :restart, "service[chronos]", :delayed
end

execute "systemctl-daemon-reload" do
  command "systemctl daemon-reload"
end

service "chronos" do
  action [:enable]
end
