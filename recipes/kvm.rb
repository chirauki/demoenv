selinux_state "SELinux Permissive" do
    action :permissive
end

ruby_block "attach ip to hostname" do
  block do
    node.set['system']['short_hostname'] = "#{node['abiquo']['environment']}-#{node['abiquo']['profile']}-#{node['ipaddress'].gsub!(".", "-")}" unless 
      node['system']['short_hostname'].eql? "#{node['abiquo']['environment']}-#{node['abiquo']['profile']}-#{node['ipaddress'].gsub!(".", "-")}"
  end
  action :run
end

# Find Out monolithic IP
monolithics = search(:node, "role:demo-monolithic AND environment:#{node['demoenv']['environment']}")

if monolithics.count > 0
  # There should be only 1 monolithic right?
  monolithic = monolithics.first
  
  # Get the IP for the NFS mount
  monolithic_ip = monolithic['digital_ocean']['networks']['v4'][0]['ip_address']

  # Only know if the monolithic knows about us
  if monolithic['demoenv']['kvm_hosts']
    do_mount = true if monolithic['demoenv']['kvm_hosts'].include?(node['ipaddress'])
  end
end

# setup NFS and install AIM
include_recipe "nfs"
include_recipe "abiquo::repository"
include_recipe "abiquo::install_kvm"

# Do AIM setup only if we can use NFS
if monolithic_ip.nil?
  node.set['abiquo']['nfs']['location'] = nil
else
  # Search for the databag and my IP on it
  if do_mount
    nfs_share = "#{monolithic_ip}:/opt/vm_repository"
    node.set['abiquo']['nfs']['location'] = nfs_share
    include_recipe "abiquo::setup_kvm"
  else
    node.set['abiquo']['nfs']['location'] = nil
  end
end
