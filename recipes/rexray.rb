attr = node[:mesos][:rexray]

package 'curl'

execute 'Install latest stable rexray binary only once' do
  command 'curl -sSL https://dl.bintray.com/emccode/rexray/install | sh -s -- stable'
  user 'root'
  group 'root'
  not_if { ::File.exists?('/usr/bin/rexray') }
end

execute 'install rexyray systemd unit file' do
  command 'rexray install'
  user 'root'
  group 'root'
end

directory '/etc/rexray' do
  action :create
  user 'root'
  group 'root'
  not_if { ::File.exists?('/etc/systemd/system/rexray.service') }
end

databag_secret = IO.read(node[:mesos][:databag_secret_key_path])
secrets = data_bag_item('secrets', node.chef_environment, databag_secret)[cookbook_name]
aws_user = secrets["aws_users"]["rexray"]

template '/etc/rexray/config.yml' do
  source 'etc/rexray/config.yml.erb'
  user 'root'
  group 'root'
  mode '0644'
  variables({
    aws_access_key_id: aws_user["access_key_id"],
    aws_secret_access_key: aws_user["secret_access_key"],
    aws_region: attr[:aws_region]
  })
  notifies :run, 'execute[systemctl-daemon-reload]', :immediately
  notifies :restart, "service[rexray]", :delayed
end

template '/etc/rexray/rexray.env' do
  source 'etc/rexray/rexray.env.erb'
  user 'root'
  group 'root'
  mode '0644'
  variables({
    aws_access_key_id: aws_user["access_key_id"],
    aws_secret_access_key: aws_user["secret_access_key"],
    aws_region: attr[:aws_region]
  })
  notifies :run, 'execute[systemctl-daemon-reload]', :immediately
  notifies :restart, "service[rexray]", :delayed
end

execute "systemctl-daemon-reload" do
  command "systemctl daemon-reload"
end

service "rexray" do
  action [:enable, :start]
end
