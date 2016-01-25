include Demoenv::API::PublicCloudRegion

# Support whyrun
def whyrun_supported?
  true
end

action :create do
  if @current_resource.exists
    Chef::Log.info "#{ @new_resource } already exists - nothing to do."
  else
    converge_by("Create #{ @new_resource }") do 
      create_abiquo_pcr
    end
  end
end

action :delete do
  if @current_resource.exists
    converge_by("Delete #{ @new_resource }") do
      delete_abiquo_pcr
    end
  else
    Chef::Log.info "#{ @current_resource } does not exists. Can't delete."
  end
end

def load_current_resource
  @current_resource = Chef::Resource::DemoenvPublicCloudRegion.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.cloud_provider(@new_resource.cloud_provider)
  @current_resource.region(@new_resource.region)
  @current_resource.abiquo_password(@new_resource.abiquo_password)
  @current_resource.abiquo_username(@new_resource.abiquo_username)
  @current_resource.abiquo_api_url(@new_resource.abiquo_api_url)

  if lookup_pcr_by_name(@current_resource.name)
    @current_resource.exists = true
  end
end
