require 'resolv'

class Chef::Recipe::Mesos
  attr_reader :masters

  # initialize query with chef server to find mesos-master nodes attributes.
  def initialize(query, node)
    fail if (query.nil? or query.empty?)
    @ip   = node[:ipaddress]
    masters = Chef::Search::Query.new.search(:node, query).first
    @masters = masters.map{ |n| n[:ipaddress] }.uniq.sort
  end

  def etc_mesos_zk
    @masters.map { |n| "#{n}:2181" }
  end

  def quorum
    ((@masters.size / 2) + 1).to_s
  end

  # zk_myid returns zk myid.
  def zk_myid
    (@masters.find_index(@ip).to_i + 1).to_s
  end

  # zoo_cfg returns a list of "server.n=zoo_ip:2888:3888"
  def zoo_cfg
    @masters.each_with_index.map do |ip, i|
      "server.#{i+1}=#{ip}:2888:3888"
    end
  end
end
