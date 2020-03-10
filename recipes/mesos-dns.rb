attr = node[:mesos][:mesos_dns]

masters = Mesos.new(node[:mesos][:discovery_query], node)

remote_file '/usr/bin/mesos-dns' do
  source sprintf("https://github.com/mesosphere/mesos-dns/releases/download/%s/mesos-dns-%s-linux-amd64", attr[:version], attr[:version])
  owner 'root'
  group 'root'
  mode '0755'
  action :create
  not_if { ::File.exist?('/usr/bin/mesos-dns') && `/usr/bin/mesos-dns -version`.match(/#{attr[:version]}/) }
end

directory '/etc/mesos-dns/' do
  action :create
  user 'root'
  group 'root'
end

mesos_masters = masters.masters.map{|x| sprintf("%s:%s", x, '5050')}
zks = masters.masters.map{|x| sprintf("%s:%s", x, '2181')}.join(',')
zk_url = sprintf("zk://%s/mesos", zks)
config = attr[:config].merge({'zk' => zk_url, 'masters' => mesos_masters})

file '/etc/mesos-dns/config.json' do
  content Chef::JSONCompat.to_json_pretty(config)
  action :create
  user 'root'
  group 'root'
end

template "/lib/systemd/system/mesos-dns.service" do
  source 'etc/systemd/mesos-dns.conf.erb'
  owner "root"
  group "root"
  mode "0644"
  action :create
  variables({
    docker_image: attr[:docker_image]
  })
  notifies :run, 'execute[systemctl-daemon-reload]', :immediately
  notifies :restart, "service[mesos-dns]", :delayed
end

execute "systemctl-daemon-reload" do
  command "systemctl daemon-reload"
end

service "mesos-dns" do
  action [:enable]
end
