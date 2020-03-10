require 'spec_helper'

describe "chronos" do
  describe docker_image('mesosphere/chronos:v3.0.1') do
    it { should exist }
  end

  describe port('9090') do
    it { should be_listening }
  end

  describe port('9091') do
    it { should be_listening }
  end

  describe file("/lib/systemd/system/chronos.service") do
    it { should contain("10.0.2.15")}
  end
end
