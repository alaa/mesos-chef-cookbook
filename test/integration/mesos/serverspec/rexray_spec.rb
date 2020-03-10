require 'spec_helper'

describe "rexray" do
  describe file("/etc/rexray/config.yml") do
    it {should be_file }
    it {should contain("ebs")}
    it {should contain("accessKey") and contain("secretKey")}
  end

  describe file("/etc/rexray/rexray.env") do
    it {should be_file }
    it {should contain("EBS_ACCESSKEY=") and contain("EBS_SECRETKEY=")}
  end

  describe file('/usr/bin/rexray') do
    it { should exist }
  end

  describe command('/usr/bin/rexray version') do
    its(:stdout) { should match /REX-Ray/ }
    its(:stdout) { should match /SemVer: 0.9.2/ }
    its(:stdout) { should match /libStorage/ }
    its(:stdout) { should match /SemVer: 0.6.2/ }
  end

  describe service('rexray') do
    it { should be_running }
    it { should be_enabled }
  end
end
