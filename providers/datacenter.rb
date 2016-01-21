include Demoenv::API::Datacenter

# Support whyrun
def whyrun_supported?
  true
end

action :create do
  if @current_resource.exists
    Chef::Log.info "#{ @new_resource } already exists - nothing to do."
  else
    converge_by("Create #{ @new_resource }") do 
      create_abiquo_dc
    end
  end
end

action :delete do
  if @current_resource.exists
    converge_by("Delete #{ @new_resource }") do
      delete_abiquo_dc
    end
  else
    Chef::Log.info "#{ @current_resource } does not exists. Can't delete."
  end
end

def load_current_resource
  @current_resource = Chef::Resource::DemoenvDatacenter.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.location(@new_resource.location)
  @current_resource.rs_address(@new_resource.rs_address)
  @current_resource.abiquo_password(@new_resource.abiquo_password)
  @current_resource.abiquo_username(@new_resource.abiquo_username)
  @current_resource.abiquo_api_url(@new_resource.abiquo_api_url)

  if lookup_dc_by_name(@current_resource.name)
    @current_resource.exists = true
  end
end
