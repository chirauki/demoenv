default['demoenv']['environment'] = "DEMO"
default['demoenv']['datacenter_name'] = "#{node['demoenv']['environment']} DC"
default['demoenv']['rack_name'] = "#{node['demoenv']['environment']} Rack"

default['abiquo']['profile'] = "monolithic"
default['abiquo']['ui_address_type'] = 'ipaddress'
default['abiquo']['nfs']['location'] = nil
default['abiquo']['properties']['abiquo.appliancemanager.checkMountedRepository'] = false
default['abiquo']['ignore_failure'] = true

default['nfs']['port']['statd'] = 32765
default['nfs']['port']['statd_out'] = 32766
default['nfs']['port']['mountd'] = 32767
default['nfs']['port']['lockd'] = 32768

default['system']['short_hostname'] = "#{node['demoenv']['environment']}-#{node['abiquo']['profile']}"

default['chef_client']['interval'] = 300 # 5 min
default['chef_client']['splay'] = 60 # 1 min
default['chef_client']['log_dir'] = "/var/log/chef"
default['chef_client']['log_file'] = "client.log"
default['chef_client']['config']['log_location'] = "#{node['chef_client']['log_dir']}/#{node['chef_client']['log_file']}"
