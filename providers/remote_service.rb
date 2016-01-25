include Demoenv::API::RemoteService

# Support whyrun
def whyrun_supported?
  true
end

action :create do
  if @current_resource.exists
    Chef::Log.info "#{ @new_resource } already exists - nothing to do."
  else
    converge_by("Create #{ @new_resource }") do 
      create_abiquo_remote_service
    end
  end
end

action :delete do
  if @current_resource.exists
    converge_by("Delete #{ @new_resource }") do
      delete_abiquo_remote_service
    end
  else
    Chef::Log.info "#{ @current_resource } does not exists. Can't delete."
  end
end

def load_current_resource
  @current_resource = Chef::Resource::DemoenvRemoteService.new(@new_resource.uri)
  @current_resource.uri(@new_resource.uri)
  @current_resource.type(@new_resource.type)
  @current_resource.datacenter(@new_resource.datacenter)
  @current_resource.uuid(@new_resource.uuid)
  @current_resource.abiquo_username(@new_resource.abiquo_username)
  @current_resource.abiquo_password(@new_resource.abiquo_password)
  @current_resource.abiquo_api_url(@new_resource.abiquo_api_url)


  if lookup_remote_service_by_uri(@current_resource.uri)
    @current_resource.exists = true
  end
end
