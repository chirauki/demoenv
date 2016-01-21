require 'open-uri'

module Demoenv
  module API
    module Datacenter
      def abq
        @@abq ||= AbiquoAPI.new(
          :abiquo_api_url => new_resource.abiquo_api_url,
          :abiquo_username => new_resource.abiquo_username,
          :abiquo_password => new_resource.abiquo_password
        )
      end

      def lookup_dc_by_name(dc_name)
        l = AbiquoAPI::Link.new(
          :href => '/api/admin/datacenters',
          :type => 'application/vnd.abiquo.datacenters+json',
          :client => abq
        )

        dcs = l.get
        if dcs.size > 0
          dcs.select {|d| d.name.eql? dc_name }.first
        else
          nil
        end
      end

      def create_abiquo_dc
        # Create DC
        l = AbiquoAPI::Link.new(
          :href => '/api/admin/datacenters',
          :type => 'application/vnd.abiquo.datacenters+json',
        )

        dc = {
          "name" => new_resource.name,
          "location" => new_resource.location
        }
        
        dc = abq.post(l, dc, :content => 'application/vnd.abiquo.datacenter+json',
                                       :accept => 'application/vnd.abiquo.datacenter+json')
        Chef::Log.info "Datacenter #{new_resource.name} created."
        dc_lnk = dc.link(:edit).clone
        dc_lnk.rel = 'datacenter'

        # Create RSs
        remoteservices = []
        rstypes = [ 'VIRTUAL_FACTORY', 'VIRTUAL_SYSTEM_MONITOR', 'NODE_COLLECTOR', 
                    'STORAGE_SYSTEM_MONITOR', 'APPLIANCE_MANAGER', 'BPM_SERVICE', 'CLOUD_PROVIDER_PROXY' ]
        uris = [ 'virtualfactory', 'vsm', 'nodecollector', 
                    'ssm', 'bpm-async', 'cpp' ]

        rss_lnk = AbiquoAPI::Link.new :href => '/api/admin/remoteservices',
                                      :type => 'application/vnd.abiquo.remoteservices+json'
        uris.each_index do |i|
          uri = uris[i]
          unless check_rs("http://#{new_resource.rs_address}:8009/#{uri}")
            type = rstypes[i]
            
            lhash = {
              "type" => type,
              "uri"  => "http://#{new_resource.rs_address}:8009/#{uri}",
              "uuid" => node['abiquo']['properties']['abiquo.datacenter.id'],
              "links" => [ dc_lnk.to_hash ]
            }
            
            rs = abq.post(rss_lnk, lhash, :content => 'application/vnd.abiquo.remoteservice+json',
                                     :accept => 'application/vnd.abiquo.remoteservice+json')
            Chef::Log.info "Created RS id #{rs.id} with uri 'http://#{new_resource.rs_address}:8009/#{uri}'"

            rs_lnk = rs.link(:edit).clone
            rs_lnk.rel = "remoteservice"
            remoteservices << rs_lnk
          else
            Chef::Log.info "RS http://#{new_resource.rs_address}:8009/#{uri} already exists."
          end
        end

        # Create DHCP services
        %w{DHCP_SERVICE DHCPv6}.each do |dhcp|
          lhash = {
            "type" => dhcp,
            "uri"  => "omapi://#{new_resource.rs_address}:7911",
            "links" => [ dc_lnk.to_hash ]
          }
          
          rs = abq.post(rss_lnk, lhash, :content => 'application/vnd.abiquo.remoteservice+json',
                                   :accept => 'application/vnd.abiquo.remoteservice+json')
          Chef::Log.info "Created RS id #{rs.id} with uri 'omapi://#{new_resource.rs_address}:7911'"

          rs_lnk = rs.link(:edit).clone
          rs_lnk.rel = "remoteservice"
          remoteservices << rs_lnk
        end
      end

      def delete_abiquo_dc
        l = AbiquoAPI::Link.new(
          :href => '/api/admin/datacenters',
          :type => 'application/vnd.abiquo.datacenters+json',
          :client => abq
        )

        dcs = l.get
        if dcs.select {|d| d.name.eql? current_resource.name }.first
          dcs.select {|d| d.name.eql? current_resource.name }.first.delete
        end
      end

      private

      def check_rs(rs_uri)
        rss_lnk = AbiquoAPI::Link.new(:href => '/api/admin/remoteservices',
                                      :type => 'application/vnd.abiquo.remoteservices+json',
                                      :client => abq)
        rss = rss_lnk.get
        not rss.select {|r| r.uri.eql? rs_uri}.empty?
      end
    end
  end
end