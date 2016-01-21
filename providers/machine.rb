include Demoenv::API::Machine

# Support whyrun
def whyrun_supported?
  true
end

action :create do
  if @current_resource.exists
    Chef::Log.info "#{ @new_resource } already exists - nothing to do."
  else
    converge_by("Create #{ @new_resource }") do 
      create_abiquo_machine
    end
  end
end

action :delete do
  if @current_resource.exists
    converge_by("Delete #{ @new_resource }") do
      delete_abiquo_machine
    end
  else
    Chef::Log.info "#{ @current_resource } does not exists. Can't delete."
  end
end

def load_current_resource
  @current_resource = Chef::Resource::DemoenvMachine.new(@new_resource.name)
  @current_resource.ip(@new_resource.ip)
  @current_resource.port(@new_resource.port)
  @current_resource.ip_service(@new_resource.ip_service)
  @current_resource.type(@new_resource.type)
  @current_resource.user(@new_resource.user)
  @current_resource.password(@new_resource.password)
  @current_resource.datastore_name(@new_resource.datastore_name)
  @current_resource.datastore_dir(@new_resource.datastore_dir)
  @current_resource.service_nic(@new_resource.service_nic)
  @current_resource.datacenter(@new_resource.datacenter)
  @current_resource.rack(@new_resource.rack)
  @current_resource.abiquo_username(@new_resource.abiquo_username)
  @current_resource.abiquo_password(@new_resource.abiquo_password)
  @current_resource.abiquo_api_url(@new_resource.abiquo_api_url)

  if lookup_machine_by_ip(@current_resource.ip, @current_resource.datacenter, @current_resource.rack)
    @current_resource.exists = true
  end
end
