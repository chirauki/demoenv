actions :create, :delete

attribute :name,                  :kind_of => String, :name_attribute => true
attribute :code,                  :kind_of => String, :required => true
attribute :abiquo_username,       :kind_of => String, :required => true
attribute :abiquo_password,       :kind_of => String, :required => true
attribute :abiquo_api_url,        :kind_of => String, :required => true

attr_accessor :exists
