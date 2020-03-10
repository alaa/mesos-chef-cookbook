require 'spec_helper'

describe "etcd" do
  describe docker_image('quay.io/coreos/etcd:v2.3.8') do
    it { should exist }
  end

  describe port('2379') do
    it { should be_listening }
  end

  describe port('2380') do
    it { should be_listening }
  end

  describe port('4001') do
    it { should be_listening }
  end

  describe file("/lib/systemd/system/etcd.service") do
    it { should contain("etcd0=http://10.0.2.15:2380")}
  end
end
