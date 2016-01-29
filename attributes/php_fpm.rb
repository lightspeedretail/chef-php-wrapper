# php-fpm config
#
default[:php][:fpm_pools].tap do |config|
  config[:www].tap do |www|
    www[:listen] = "127.0.0.1:65500"
    www[:user] = node[:php][:fpm_user]
    www[:group] = node[:php][:fpm_group]
    www[:process_manager] = "ondemand"
    www[:max_children] = 1
    www[:start_servers] = 1
    www[:min_spare_servers] = 1
    www[:max_spare_servers] = 1
    www[:action] = :create
  end
end

default[:php][:fpm_service_conf] = "/etc/php5/fpm/php-fpm.conf"
default[:php][:fpm_pid] = "/var/run/php-fpm.pid"
default[:php][:fpm_error_log] = "/var/log/php5-fpm.log"
default[:php][:fpm_log_level] = "warning"
default[:php][:fpm_restart_threshold] = 0
default[:php][:fpm_restart_interval] = -
default[:php][:fpm_control_timeout] = 0
