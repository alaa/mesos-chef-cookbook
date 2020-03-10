require 'spec_helper'

describe "calico" do
  describe docker_image('quay.io/calico/node:v2.4.1') do
    it { should exist }
  end

  describe file("/lib/systemd/system/calico.service") do
    it { should contain "ETCD_ENDPOINTS=http://10.0.2.15:2379" }
  end

  describe command('docker network rm kitchenNetwork || true && docker network create --driver=calico --ipam-driver=calico-ipam kitchenNetwork') do
    its(:exit_status) { should eq 0 }
  end

  describe command('docker network ls') do
    its(:stdout) { should match /kitchenNetwork/}
  end

end
