# Some default properties
node.set['abiquo']['properties']['abiquo.virtualfactory.kvm.fullVirt'] = false

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

# Firewall
include_recipe "iptables"
iptables_rule "firewall-nfs"

# Install Abiquo
include_recipe "abiquo::default"
