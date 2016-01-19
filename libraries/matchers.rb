if defined?(ChefSpec)
  def wait_wait_for_role(service_name)
    ChefSpec::Matcher::ResourceMatcher.new(:wait_for_role, :wait, service_name)
  end

  def wait_wait_for_role_with_port(service_name)
    ChefSpec::Matcher::ResourceMatcher.new(:wait_wait_for_role_with_port, :wait, service_name)
  end
end