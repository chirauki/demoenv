# Some default properties
node.set['abiquo']['properties']['abiquo.virtualfactory.kvm.fullVirt'] = false
node.set['abiquo']['properties']['abiquo.appliancemanager.repositoryLocation'] = "#{node['ipaddress']}:/opt/vm_repository"

# Find Out monitoring IP and setup properties
monitoring = search(:node, "role:demo-monitoring AND environment:#{node['demoenv']['environment']}")

if monitoring.count > 0
  monitoring_ip = monitoring.first['ipaddress']

  node.set['abiquo']['properties']['abiquo.kairosdb.host'] = monitoring_ip
  node.set['abiquo']['properties']['abiquo.kairosdb.port'] = 8080
end

# Setup NFS server
include_recipe "nfs"

# Search for KVM hosts and save them to an attribute so we can query from KVMs
kvm_hosts = search(:node, "role:demo-kvm AND environment:#{node['demoenv']['environment']}")
if kvm_hosts.count > 0 
  # There are KVM hosts in the env!
  ips = kvm_hosts.map {|k| k['ipaddress'] }.join(",")
  node.set['demoenv']['kvm_hosts'] = ips
end

# Firewall
include_recipe "iptables"
iptables_rule "firewall-nfs"

# Retrieve a demo license
ruby_block "obtain a demo license" do
  block do 
    require 'net/http'
    require 'json'

    uri = URI.parse("https://www.abiquo.com/license.php")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    param_hash = {
      "email" => "demo@abiquo.com",
      "company" => "DEMO",
      "name" => "Abiquo Demo Env",
      "batch" => true
    }.to_json

    req = Net::HTTP::Post.new(uri.request_uri, initheader = {'Content-Type' =>'application/json'})
    req.body = param_hash
    response = http.request(req)

    node.set['abiquo']['license'] = response.body.gsub!("\n", "")
  end
  action :run
  only_if { node['abiquo']['license'].nil? }
end

# Install Abiquo
include_recipe "abiquo::default"

# If we know about KVM hosts, setup NFS export
if node['demoenv']['kvm_hosts']
  ips = node['demoenv']['kvm_hosts'].split(",")

  ips.each do |ip|
    nfs_export "/opt/vm_repository" do
      network ip
      writeable true
      sync true
      options ['no_root_squash', 'no_subtree_check']
      notifies :restart, "service[nfs]"
    end
  end
end

# Ensure NFS will survive restarts
service "nfs" do
  action :enable
end

# File required in order to use the vm_repository
file '/opt/vm_repository/.abiquo_repository' do 
  content ''
  owner 'root'
  group 'root'
end

# Included to use LWRPs
include_recipe "demoenv::lwrp"

unless node['abiquo']['license'].nil? or node['abiquo']['license'].length == 0
  # Add license
  demoenv_license 'add-demo-license' do
    code node['abiquo']['license']
    abiquo_api_url 'http://localhost:8009/api'
    abiquo_username 'admin'
    abiquo_password 'xabiquo'
    action :create
    only_if "while /bin/netstat -lnt | awk '$4 ~ /:8009$/ {exit 1}'; do /bin/sleep 2; done && /usr/bin/curl -u admin:xabiquo http://localhost:8009/api/version -H 'Accept: text/plain' -s > /dev/null"
  end
end

# Create datacenter
demoenv_datacenter node['demoenv']['datacenter_name'] do
  location "Somewhere over the rainbows"
  abiquo_api_url 'http://localhost:8009/api'
  abiquo_username 'admin'
  abiquo_password 'xabiquo'
  action :create
  only_if "while /bin/netstat -lnt | awk '$4 ~ /:8009$/ {exit 1}'; do /bin/sleep 2; done && /usr/bin/curl -u admin:xabiquo http://localhost:8009/api/version -H 'Accept: text/plain' -s > /dev/null"
  notifies :create, "demoenv_rack[#{node['demoenv']['rack_name']}]", :immediately
end

# Public Cloud Regions
# SSH keys
regions = data_bag_item('demo-env-pcr', 'regions')
regions.delete('id')

regions['regions'].each do |region|
  demoenv_public_cloud_region region['name'] do
    region region['region']
    cloud_provider region['provider']
    abiquo_api_url 'http://localhost:8009/api'
    abiquo_username 'admin'
    abiquo_password 'xabiquo'
    action :create
    only_if "while /bin/netstat -lnt | awk '$4 ~ /:8009$/ {exit 1}'; do /bin/sleep 2; done && /usr/bin/curl -u admin:xabiquo http://localhost:8009/api/version -H 'Accept: text/plain' -s > /dev/null"
  end
end

# Create rack
demoenv_rack node['demoenv']['rack_name'] do
  datacenter node['demoenv']['datacenter_name']
  abiquo_api_url 'http://localhost:8009/api'
  abiquo_username 'admin'
  abiquo_password 'xabiquo'
  action :nothing
end

# Create Remote Services
demoenv_remote_service "http://#{node['ipaddress']}:8009/vsm" do
  type "VIRTUAL_SYSTEM_MONITOR"
  datacenter [node['demoenv']['datacenter_name'], "DO ams2"]
  abiquo_api_url 'http://localhost:8009/api'
  abiquo_username 'admin'
  abiquo_password 'xabiquo'
  action :create
end

demoenv_remote_service "http://#{node['ipaddress']}:8009/nodecollector" do
  type "NODE_COLLECTOR"
  datacenter [node['demoenv']['datacenter_name'], "DO ams2"]
  abiquo_api_url 'http://localhost:8009/api'
  abiquo_username 'admin'
  abiquo_password 'xabiquo'
  action :create
end

demoenv_remote_service "http://#{node['ipaddress']}:8009/virtualfactory" do
  type "VIRTUAL_FACTORY"
  datacenter [node['demoenv']['datacenter_name'], "DO ams2"]
  abiquo_api_url 'http://localhost:8009/api'
  abiquo_username 'admin'
  abiquo_password 'xabiquo'
  action :create
end

demoenv_remote_service "http://#{node['ipaddress']}:8009/ssm" do
  type "STORAGE_SYSTEM_MONITOR"
  datacenter node['demoenv']['datacenter_name']
  abiquo_api_url 'http://localhost:8009/api'
  abiquo_username 'admin'
  abiquo_password 'xabiquo'
  action :create
end

demoenv_remote_service "https://#{node['ipaddress']}.xip.io:443/am" do
  type "APPLIANCE_MANAGER"
  uuid node['abiquo']['properties']['abiquo.datacenter.id']
  datacenter node['demoenv']['datacenter_name']
  abiquo_api_url 'http://localhost:8009/api'
  abiquo_username 'admin'
  abiquo_password 'xabiquo'
  action :create
  ignore_failure true
end

demoenv_remote_service "http://#{node['ipaddress']}:8009/bpm-async" do
  type "BPM_SERVICE"
  uuid node['abiquo']['properties']['abiquo.datacenter.id']
  datacenter node['demoenv']['datacenter_name']
  abiquo_api_url 'http://localhost:8009/api'
  abiquo_username 'admin'
  abiquo_password 'xabiquo'
  action :create
end

demoenv_remote_service "http://#{node['ipaddress']}:8009/cpp" do
  type "CLOUD_PROVIDER_PROXY"
  datacenter "DO ams2"
  abiquo_api_url 'http://localhost:8009/api'
  abiquo_username 'admin'
  abiquo_password 'xabiquo'
  action :create
end
