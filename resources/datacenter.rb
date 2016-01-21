actions :create, :delete

attribute :name,                  :kind_of => String, :name_attribute => true
attribute :location,              :kind_of => String, :required => true
attribute :rs_address,            :kind_of => String, :default => "127.0.0.1"
attribute :abiquo_username,       :kind_of => String, :required => true
attribute :abiquo_password,       :kind_of => String, :required => true
attribute :abiquo_api_url,        :kind_of => String, :required => true

attr_accessor :exists
