# Add mesosphere repository
# deb "http://repos.mesosphere.io/ubuntu" trusty main
apt_repository 'mesosphere' do
  uri          "http://repos.mesosphere.com/ubuntu"
  distribution node[:lsb][:codename]
  components   ["main"]
  keyserver    "hkp://keyserver.ubuntu.com"
  key          "E56151BF"
end

# Update aptitiude cache
include_recipe 'apt'

execute 'apt update' do
  command 'sudo apt update'
end
