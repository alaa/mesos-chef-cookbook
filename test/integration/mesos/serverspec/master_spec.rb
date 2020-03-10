require 'spec_helper'

describe "master" do
  describe package("mesos") do
    it { should be_installed }
  end

  describe service("mesos-master") do
    it { should be_enabled }
    it { should be_running }
  end

  describe port('5050') do
    it { should be_listening }
  end

  describe file('/etc/mesos/zk') do
    its(:content) { should match "zk://10.0.2.15:2181/mesos" }
  end
end
