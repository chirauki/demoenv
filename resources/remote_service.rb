actions :create, :delete

attribute :uri,                   :kind_of => String, :name_attribute => true
attribute :type,                  :kind_of => String, :required => true
attribute :datacenter,            :kind_of => [ String, Array ], :required => true
attribute :uuid,                  :kind_of => String
attribute :abiquo_username,       :kind_of => String, :required => true
attribute :abiquo_password,       :kind_of => String, :required => true
attribute :abiquo_api_url,        :kind_of => String, :required => true

attr_accessor :exists
