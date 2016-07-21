
# A php_pool resource will be used to create a PHP-FPM pool.
#

resource_name :php_pool

actions :create, :delete, :disable

# User name that the php-pool will run as
property :user,
  kind_of: String,
  default: lazy { node[:php][:fpm_user] }

# Group name that the php-pool will run as
property :group,
  kind_of: String,
  default: lazy { node[:php][:fpm_group] }

# Port of socket path the php-pool will listen on
property :listen,
  kind_of: String,
  required: true

# The file permissions to create the php socket on (when listen is a path)
property :listen_mode,
  kind_of: String,
  coerce: proc { |v| v.to_s },
  default: '00660'

# The owner of the php socket (when listen is a path)
property :listen_user,
  kind_of: String,
  default: lazy { |r| r.user }

# The owning group of the php socket (When listen is a path)
property :listen_group,
  kind_of: String,
  default: lazy { |r| r.group }

# The maximum amount of pending connections to the php listener
property :backlog,
  kind_of: Integer,
  default: 65_535

# List of IPv4 addresses of FastCGI clients allowed to connect
property :allowed_clients,
  kind_of: Array,
  default: []

# The php-fpm process manager (static,ondemand,dynamic)
property :process_manager,
  kind_of: String,
  required: true

# The php-fpm process idle timeout
property :process_idle_timeout,
  kind_of: String,
  default: '10s'

# The maximum amount of php-fpm processes in the pool
# - Note : When the process_manager is static, this is the total processes
property :max_children,
  kind_of: Integer,
  required: true

property :start_servers,
  kind_of: Integer

property :min_spare_servers,
  kind_of: Integer

property :max_spare_servers,
  kind_of: Integer

# Maximum amount of requests before a php process is restarted. Ensures that
# we do not suffer from memory leaks.
property :max_requests,
  kind_of: Integer,
  default: 0

# Whether to return stdout to the web process
property :catch_workers_output,
  kind_of: String,
  default: 'yes'

# URI which should return the php-fpm status page
property :status_path,
  kind_of: String,
  default: '/_php/status'

# URI which should return the php-fpm ping (short status) page
property :ping_path,
  kind_of: String,
  default: '/_php/ping'

# Which file extensions should be evaluated by php-fpm
property :security_limit_extensions,
  kind_of: Array,
  default: %w(.php)

# The hard limit for a php processes' maximum execution time
property :request_terminate_timeout,
  kind_of: Integer,
  default: 0

# Environment variables that should be defined for the php-pool
property :env_variables,
  kind_of: Hash,
  default: {}

# boolean PHP setting overrides
# - Note: Only PHP_INI_ALL and PHP_INIT_PERDIR options are supported
property :php_flags,
  kind_of: Hash,
  default: {}

# Non-boolean PHP setting overrides
# - Note: Only PHP_INI_ALL and PHP_INIT_PERDIR options are supported
property :php_variables,
  kind_of: Hash,
  default: {}

# Boolean PHP setting overrides specific to this php-pool
# - Note : These cannot be overwritten by the application
property :php_admin_flags,
  kind_of: Hash,
  default: {}

# Non-boolean PHP setting overrides specific to this php-pool
# - Note: These cannot be overwritten by the application
property :php_admin_variables,
  kind_of: Hash,
  default: {}

property :path,
  kind_of: String,
  default: lazy { |r|
    file_name = r.name.include?('.conf') ? r.name : "#{r.name}.conf"
    "#{node['php']['fpm_pooldir']}/#{file_name}"
  }

# Ensure that the resource is applied regardless of whether we are in why_run
# or standard mode.
#
# Refer to chef/chef#4537 for this uncommon syntax
action_class do
  def whyrun_supported?
    true
  end
end

action :create do
  template new_resource.path do
    path      new_resource.path
    cookbook  'php_wrapper'
    source    'pool.conf.erb'
    owner     'root'
    group     'root'
    mode      00640
    variables new_resource.variables
    action    :create
  end
end

action :delete do
  template new_resource.path do
    action :delete
  end
end

# Hash of php-pool properties to pass to the template
def variables
  {
    name: name,
    listen: listen,
    listen_mode: listen_mode,
    listen_user: listen_user,
    listen_group: listen_group,
    mode: listen_mode,
    backlog: backlog,
    allowed_clients: allowed_clients,
    user: user,
    group: group,
    process_manager: process_manager,
    process_idle_timeout: process_idle_timeout,
    max_children: max_children,
    start_servers: start_servers,
    min_spare_servers: min_spare_servers,
    max_spare_servers: max_spare_servers,
    max_requets: max_requests,
    catch_workers_output: catch_workers_output,
    status_path: status_path,
    ping_path: ping_path,
    security_limit_extensions: security_limit_extensions,
    request_terminate_timeout: request_terminate_timeout,
    env_variables: env_variables,
    php_variables: php_variables,
    php_flags: php_flags,
    php_admin_variables: php_admin_variables,
    php_admin_flags: php_admin_flags
  }
end
