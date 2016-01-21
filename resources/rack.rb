actions :create, :delete

attribute :name,                  :kind_of => String, :name_attribute => true
attribute :datacenter,            :kind_of => String, :required => true
attribute :vlan_min,              :kind_of => Fixnum, :default => 2
attribute :vlan_max,              :kind_of => Fixnum, :default => 4094
attribute :vlan_avoided,          :kind_of => String, :default => nil
attribute :vlan_reserved,         :kind_of => Fixnum, :default => 1
attribute :nrsq,                  :kind_of => Fixnum, :default => 10
attribute :ha_enabled,            :kind_of => [ FalseClass, TrueClass ], :default => false
attribute :abiquo_username,       :kind_of => String, :required => true
attribute :abiquo_password,       :kind_of => String, :required => true
attribute :abiquo_api_url,        :kind_of => String, :required => true

attr_accessor :exists
