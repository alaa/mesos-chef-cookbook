require 'spec_helper'

describe "mesos-dns" do
  describe file("/etc/mesos-dns/config.json") do
    it {should be_file }
    it {should contain("zk")}
    it {should contain("8.8.8.8") and contain("8.8.4.4")}
    it {should contain("zk://10.0.2.15:2181/mesos")}
    it {should contain("[\"10.0.2.15:5050\"]")}
  end

  describe file('/usr/bin/mesos-dns') do
    it { should exist }
  end

  describe command('/usr/bin/mesos-dns -version') do
    its(:stdout) { should match /v0.6.0/ }
  end

  describe port('53') do
    it { should be_listening }
  end

  describe port('8123') do
    it { should be_listening }
  end
end
