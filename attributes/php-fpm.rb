# php-fpm custom configurations used by this cookbook
#
# there are also other fpm specific configurations provded by the upstream php
# cookbook.
#
# Version specific configs are in the recipe

# Version agnostic ones
default['php']['fpm']['user'] = 'www-data'
default['php']['fpm']['group'] = 'www-data'
default['php']['fpm']['log_level'] = 'warning'
default['php']['fpm']['restart_threshold'] = 0
default['php']['fpm']['restart_interval'] = 0
default['php']['fpm']['control_timeout'] = 0

# php-fpm pool definitions
#
default['php']['fpm']['pools'].tap do |config|
  # This is the default pool configuration as shipped with Ubuntu
  config['www'].tap do |www|
    www['listen'] = '127.0.0.1:65500'
    www['user'] = node['php']['fpm_user']
    www['group'] = node['php']['fpm_group']
    www['process_manager'] = 'ondemand'
    www['max_children'] = 1
    www['start_servers'] = 1
    www['min_spare_servers'] = 1
    www['max_spare_servers'] = 1
    www['action'] = :create
  end
end
