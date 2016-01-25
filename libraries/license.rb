module Demoenv
  module API
    module License
      def abq
        @@abq ||= AbiquoAPI.new(
          :abiquo_api_url => new_resource.abiquo_api_url,
          :abiquo_username => new_resource.abiquo_username,
          :abiquo_password => new_resource.abiquo_password
        )
      end

      def lookup_license_by_code(license_code)
        l = AbiquoAPI::Link.new(
          :href => '/api/config/licenses',
          :type => 'application/vnd.abiquo.licenses+json',
          :client => abq
        )

        lics = l.get
        if lics.size > 0
          lics.select {|l| l.code.eql? license_code }.first
        else
          nil
        end
      end

      def create_abiquo_license
        # Create DC
        l = AbiquoAPI::Link.new(
          :href => '/api/config/licenses',
          :type => 'application/vnd.abiquo.licenses+json',
        )

        lic = {
          "code" => new_resource.code,
        }
        
        license = abq.post(l, lic, :content => 'application/vnd.abiquo.license+json',
                                   :accept => 'application/vnd.abiquo.license+json')
        Chef::Log.info "License '#{new_resource.name}' created."
      end

      def delete_abiquo_license
        l = AbiquoAPI::Link.new(
          :href => '/api/config/licenses',
          :type => 'application/vnd.abiquo.licenses+json',
          :client => abq
        )

        lics = l.get
        if lics.select {|l| l.code.eql? current_resource.code }.first
          lics.select {|l| l.code.eql? current_resource.code }.first.delete
        end
      end
    end
  end
end