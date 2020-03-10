require 'spec_helper'

describe "zookeeper" do
  describe package("zookeeper") do
    it { should be_installed }
  end

  describe service("zookeeper") do
    it { should be_enabled }
    it { should be_running }
  end

  describe port(2181) do
    it { should be_listening }
  end

  describe file('/etc/zookeeper/conf/myid') do
    it { should exist }
    its(:content) { should match(/1/) }
  end

  describe file('/etc/zookeeper/conf/zoo.cfg') do
    its(:content) { should match /server\.1=10.0.2.15/ }
  end
end
