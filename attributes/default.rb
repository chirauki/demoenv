default['demoenv']['environment'] = "DEMO"
default['demoenv']['datacenter_name'] = "#{node['demoenv']['environment']} DC"
default['demoenv']['rack_name'] = "#{node['demoenv']['environment']} Rack"

default['system']['short_hostname'] = "#{node['demoenv']['environment']}-#{node['abiquo']['profile']}"

default['abiquo']['profile'] = "monolithic"
default['abiquo']['nfs']['location'] = nil
default['abiquo']['properties']['abiquo.appliancemanager.checkMountedRepository'] = false
default['abiquo']['properties']['abiquo.datacenter.id'] = node['system']['short_hostname']
override['abiquo']['ui_address_type'] = 'fixed'
override['abiquo']['ui_address'] = "#{node['ipaddress']}.xip.io"
override['abiquo']['certificate']['common_name'] = "#{node['ipaddress']}.xip.io"
override['abiquo']['certificate']['file'] = "/etc/pki/abiquo/#{node['ipaddress']}.xip.io.crt"
override['abiquo']['certificate']['key_file'] = "/etc/pki/abiquo/#{node['ipaddress']}.xip.io.key"
override['abiquo']['websockify']['port'] = 41337
override['abiquo']['websockify']['crt'] = node['abiquo']['certificate']['file']
override['abiquo']['websockify']['key'] = node['abiquo']['certificate']['key_file']
# override['abiquo']['properties']['abiquo.server.api.location'] = "https://#{node[node['abiquo']['ui_address_type']]}/api"

default['nfs']['port']['statd'] = 32765
default['nfs']['port']['statd_out'] = 32766
default['nfs']['port']['mountd'] = 32767
default['nfs']['port']['lockd'] = 32768


default['selfsigned_certificate']['cn'] = "#{node['ipaddress']}.xip.io"

default['chef_client']['interval'] = 300 # 5 min
default['chef_client']['splay'] = 60 # 1 min
default['chef_client']['log_dir'] = "/var/log/chef"
default['chef_client']['log_file'] = "client.log"
default['chef_client']['config']['log_location'] = "#{node['chef_client']['log_dir']}/#{node['chef_client']['log_file']}"
