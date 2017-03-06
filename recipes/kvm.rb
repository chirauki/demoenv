#
# Cookbook Name:: demoenv
# Recipe:: kvm
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

# Install Abiquo API gem
include_recipe "abiquo_api::default"

selinux_state "SELinux Permissive" do
    action :permissive
end

node.set['system']['short_hostname'] = "#{node['demoenv']['environment']}-#{node['abiquo']['profile']}-#{node['ipaddress'].gsub(".", "-")}" unless 
 node['system']['short_hostname'].eql? "#{node['demoenv']['environment']}-#{node['abiquo']['profile']}-#{node['ipaddress'].gsub(".", "-")}"

# Find Out monolithic IP
monolithics = search(:node, "role:demo-monolithic AND environment:#{node['demoenv']['environment']}")

if monolithics.count > 0
  # There should be only 1 monolithic right?
  monolithic = monolithics.first
  
  # Get the IP for the NFS mount
  monolithic_ip = monolithic['ipaddress']
  node.set['demoenv']['abiquo_connection_data']['abiquo_api_url'] = "https://#{monolithic_ip}.xip.io/api"

  # Only know if the monolithic knows about us
  if monolithic['demoenv']['kvm_hosts']
    do_mount = true if monolithic['demoenv']['kvm_hosts'].include?(node['ipaddress'])
  end
end

# setup NFS and install AIM
include_recipe "nfs"
include_recipe "abiquo::repository"
include_recipe "abiquo::install_kvm"

directory '/var/lib/virt' do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
  action :create
end

# Do AIM setup only if we can use NFS
if monolithic_ip.nil?
  node.set['abiquo']['nfs']['location'] = nil
else
  # Search for the databag and my IP on it
  if do_mount
    # Setup the tunnel to the monolithic
    include_recipe 'demoenv::tunnels_kvm'

    nfs_share = "#{monolithic_ip}:/opt/vm_repository"
    node.set['abiquo']['nfs']['location'] = nfs_share
    include_recipe "abiquo::setup_kvm"

    if node['system']['short_hostname'].eql? "#{node['demoenv']['environment']}-#{node['abiquo']['profile']}-#{node['ipaddress'].gsub(".", "-")}"
      abiquo_api_machine "#{node['ipaddress']}" do 
        type "KVM"
        port node['abiquo']['aim']['port']
        datastore_name "/dev/vda1"
        datastore_dir "/var/lib/virt"
        service_nic "l2tpeth0"
        datacenter node['demoenv']['datacenter_name']
        rack node['demoenv']['rack_name']
        abiquo_connection_data node['demoenv']['abiquo_connection_data']
        action :create
      end
    end
  else
    node.set['abiquo']['nfs']['location'] = nil
  end
end
