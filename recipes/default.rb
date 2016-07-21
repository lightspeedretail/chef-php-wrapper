include_recipe "php::default"

# Ensure that php.ini is symlinked into each PHP SAPI to prevent having to
# manage a bunch of different configuration files.
#
%w(cgi cli fpm).each do |sapi|
  link "#{node[:php][:conf_dir]}/#{sapi}/php.ini" do
    to "#{node[:php][:conf_dir]}/php.ini"
    only_if do
      ::Dir.exists? "#{node[:php][:conf_dir]}/#{sapi}"
    end
  end
end

# Install PHP Pear packages from attributes
# - Note: Given that upstream php_pear does not have the concept of 
#   configuration file priorities, it is highly recommended that you _not_
#   use the `directives` and `zend_extensions` properties on this resource.
#
node[:php][:pear_packages].each do |name, hash|
  php_pear name do
    hash.each do |k,v|
      send(k, v) if respond_to?(k)
    end
  end
end

# Install PHP module configuration files from attributes
# - These are essentially used to plop down /etc/php5/conf.d/*.conf files which
#   provide default configurations for some/all SAPIs.
#
node[:php][:directives][:module].each do |name, hash|
  php_config name do
    hash.each do |k,v|
      send(k, v) if respond_to?(k)
    end
  end
end
