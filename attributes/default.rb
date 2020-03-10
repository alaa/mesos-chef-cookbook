# Mesos attributes
default[:mesos][:chef_environment] = node.chef_environment
default[:mesos][:version] = "1.3.0-2.0.3"
default[:mesos][:discovery_query] = "role:masters-role AND chef_environment:cluster-env"

# Marathon attributes
default[:java][:jdk_version] = '8'
default[:mesos][:marathon][:version] = "1.4.6-1.0.656.ubuntu1604"

# Zookeeper attributes
default[:mesos][:zk][:ticktime] = 2000
default[:mesos][:zk][:dataDir] = '/var/lib/zookeeper'
default[:mesos][:zk][:clientPort] = 2181
default[:mesos][:zk][:initLimit] = 5
default[:mesos][:zk][:syncLimit] = 2

# Chronos attributes
default[:chronos][:registry] = 'mesosphere'
default[:chronos][:image] = 'chronos'
default[:chronos][:tag] = 'v3.0.1'

# etcD attributes
default[:etcd][:registry] = 'quay.io/coreos'
default[:etcd][:image] = 'etcd'
default[:etcd][:tag] = 'v2.3.8'
default[:etcd][:data_dir] = '/data/etcd/'

# Mesos DNS configs
default[:mesos][:mesos_dns][:docker_image] = "mesosphere/mesos-dns:v0.6.0"
default[:mesos][:mesos_dns][:version] = "v0.6.0"
default[:mesos][:mesos_dns][:resolvers] = ['8.8.8.8', '8.8.4.4']
default[:mesos][:mesos_dns][:config] = {
  "refreshSeconds" => 10,
  "ttl" => 10,
  "domain" => "mesos",
  "port" => 53,
  "resolvers" => node[:mesos][:mesos_dns][:resolvers],
  "timeout" => 5,
  "httpon" => true,
  "dnson" => true,
  "httpport" => 8123,
  "externalon" => true,
  "listener" => '0.0.0.0',
  "SOAMname" => "ns1.mesos",
  "SOARname" => "root.ns1.mesos",
  "SOARefresh" => 60,
  "SOARetry" =>   600,
  "SOAExpire" =>  86400,
  "SOAMinttl" => 60,
  "IPSources" => ["netinfo", "mesos", "host"]
}

# Calico settings
default[:mesos][:calico][:calicoctl_version] = 'v1.4.0'
default[:mesos][:calico][:calico_node_repo] = 'quay.io/calico/node'
default[:mesos][:calico][:calico_node_version] = 'v2.4.1'

# Rexray settings
default[:mesos][:rexray][:aws_region] = 'eu-central-1a'

# Encrypted Databag key
default[:mesos][:databag_secret_key_path] = '/home/ubuntu/chef_databag_secret.b64'
