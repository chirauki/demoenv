r = gem_package "abiquo-api" do
  gem_binary '/opt/chef/embedded/bin/gem'
  action :nothing
end

r.run_action(:install)

require 'abiquo-api'
