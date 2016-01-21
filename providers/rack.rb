include Demoenv::API::Rack

# Support whyrun
def whyrun_supported?
  true
end

action :create do
  if @current_resource.exists
    Chef::Log.info "#{ @new_resource } already exists - nothing to do."
  else
    converge_by("Create #{ @new_resource }") do 
      create_abiquo_rack
    end
  end
end

action :delete do
  if @current_resource.exists
    converge_by("Delete #{ @new_resource }") do
      delete_abiquo_rack
    end
  else
    Chef::Log.info "#{ @current_resource } does not exists. Can't delete."
  end
end

def load_current_resource
  @current_resource = Chef::Resource::DemoenvRack.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.datacenter(@new_resource.datacenter)
  @current_resource.vlan_min(@new_resource.vlan_min)
  @current_resource.vlan_max(@new_resource.vlan_max)
  @current_resource.vlan_avoided(@new_resource.vlan_avoided)
  @current_resource.vlan_reserved(@new_resource.vlan_reserved)
  @current_resource.nrsq(@new_resource.nrsq)
  @current_resource.ha_enabled(@new_resource.ha_enabled)
  @current_resource.abiquo_username(@new_resource.abiquo_username)
  @current_resource.abiquo_password(@new_resource.abiquo_password)
  @current_resource.abiquo_api_url(@new_resource.abiquo_api_url)

  if lookup_rack_by_name(@current_resource.name, @current_resource.datacenter)
    @current_resource.exists = true
  end
end
