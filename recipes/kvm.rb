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

    include_recipe "demoenv::lwrp"

    if node['system']['short_hostname'].eql? "#{node['demoenv']['environment']}-#{node['abiquo']['profile']}-#{node['ipaddress'].gsub(".", "-")}"
      demoenv_machine "#{node['ipaddress']}" do 
        type "KVM"
        port node['abiquo']['aim']['port']
        datastore_name "/dev/vda1"
        datastore_dir "/var/lib/virt"
        service_nic "eth0"
        datacenter node['demoenv']['datacenter_name']
        rack node['demoenv']['rack_name']
        abiquo_api_url "https://#{monolithic_ip}/api"
        abiquo_username 'admin'
        abiquo_password 'xabiquo'
        action :create
      end
    end
  else
    node.set['abiquo']['nfs']['location'] = nil
  end
end
