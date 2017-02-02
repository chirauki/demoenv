default['demoenv']['environment'] = "DEMO"
default['demoenv']['datacenter_name'] = "#{node['demoenv']['environment']} DC"
default['demoenv']['rack_name'] = "#{node['demoenv']['environment']} Rack"
default['demoenv']['abiquo_connection_data'] = { abiquo_api_url: 'http://localhost:8009/api',
                                                 abiquo_username: 'admin',
                                                 abiquo_password: 'xabiquo',
                                                 connection_options: { ssl: { verify: false } }
                                               }

default['system']['short_hostname'] = "#{node['demoenv']['environment']}-#{node['abiquo']['profile']}"

default['abiquo']['profile'] = "monolithic"
default['abiquo']['nfs']['location'] = nil
default['abiquo']['properties']['abiquo.appliancemanager.checkMountedRepository'] = false
default['abiquo']['properties']['abiquo.datacenter.id'] = node['system']['short_hostname']
default['abiquo']['ui_config'] = { 'config.endpoint' => "https://#{node['ipaddress']}.xip.io/api" }
override['abiquo']['certificate']['common_name'] = "#{node['ipaddress']}.xip.io"
override['abiquo']['certificate']['file'] = "/etc/pki/abiquo/#{node['ipaddress']}.xip.io.crt"
override['abiquo']['certificate']['key_file'] = "/etc/pki/abiquo/#{node['ipaddress']}.xip.io.key"
override['abiquo']['websockify']['crt'] = node['abiquo']['certificate']['file']
override['abiquo']['websockify']['key'] = node['abiquo']['certificate']['key_file']
override['abiquo']['properties']['abiquo.server.api.location'] = "https://#{node['ipaddress']}.xip.io/api"

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
