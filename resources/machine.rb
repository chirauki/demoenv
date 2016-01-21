actions :create, :delete

attribute :ip,                    :kind_of => String, :name_attribute => true
attribute :port,                  :kind_of => Fixnum, :required => true
attribute :type,                  :kind_of => String, :required => true
attribute :ip_service,            :kind_of => String, :default => nil
attribute :user,                  :kind_of => String, :default => "root"
attribute :password,              :kind_of => String, :default => "temporal"
attribute :datastore_name,        :kind_of => String, :required => true
attribute :datastore_dir,         :kind_of => String
attribute :service_nic,           :kind_of => String, :required => true
attribute :datacenter,            :kind_of => String, :required => true
attribute :rack,                  :kind_of => String, :required => true
attribute :abiquo_username,       :kind_of => String, :required => true
attribute :abiquo_password,       :kind_of => String, :required => true
attribute :abiquo_api_url,        :kind_of => String, :required => true

attr_accessor :exists
