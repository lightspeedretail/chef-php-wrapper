
# Core config
#
default[:php][:conf_dir] = "/etc/php5"

# Ubuntu PPA Support
#
default[:php][:ppas]["php5-5.6"].tap do |ppa|
  ppa[:uri] = "ppa:ondrej/php5-5.6"
  ppa[:enabled] = false
end

# Install packages
# (php upstream)
default[:php][:packages].concat(%w())
default[:php][:mysql][:package] = "php5-mysqlnd"

# Install PHP Pear packages
# (php_wrapper::deault)
default[:php][:pear_packages] = {}

# Use custom php.ini template
# (php upstream)
default[:php][:ini][:cookbook] = "php_wrapper"

# Custom php.ini directives
# (php_wrapper template)
default[:php][:directives][:custom] ||= {}

# Install module configuration files
# (php_wrapper::default)
default[:php][:directives][:module] = {}

# Default configuration
#
default[:php][:directives].tap do |config|
  config["date.timezone"]       = "UTC"
  config[:memory_limit]         = "128M"
  config[:upload_max_filesize]  = "2M"
  config[:post_max_size]        = "8M"
  config[:max_execution_time]   = "30"
  config[:max_input_time]       = "-1"
  config[:max_input_vars]       = 1000
  config[:default_socket_timeout] = "60"
  config[:html_errors]          = "Off"
  config[:display_errors]       = "Off"
  config[:error_reporting]      = "E_ALL & ~E_DEPRECATED"
  config[:error_log]            = ""
  config[:expose_php]           = "Off"
  config[:cgi_fix_pathinfo]     = 0
  config["opcache.enable"]      = "On"
  config["opcache.memory_consumption"] = conf[:memory_limit]
  config["opcache.max_accelerated_files"]   = 2000
end
