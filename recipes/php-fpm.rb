# Install the PHP FPM package
package node['php']['fpm_package']

# Ensure any change to the .ini file triggers a reload of php-fpm
ini = resources(template: "#{node['php']['conf_dir']}/php.ini")
ini.notifies :reload, "service[#{node['php']['fpm_service']}]"

# Install the PHP FPM configuration file
template node['php']['fpm_service_conf'] do
  source 'fpm.conf.erb'
  variables lazy { node['php'] }
  mode 00644
  notifies :reload, "service[#{node['php']['fpm_service']}]"
end

# Create php_pool resources from attributes
node['php']['fpm_pools'].each do |name, hash|
  php_pool name do
    hash.each do |k, v|
      send(k, v) if respond_to?(k)
    end
    notifies :reload, "service[#{node['php']['fpm_service']}]"
  end
end

# Register the PHP FPM service
service node['php']['fpm_service'] do
  supports start: true, stop: true, restart: true, reload: true
  action [:enable, :start]
end
