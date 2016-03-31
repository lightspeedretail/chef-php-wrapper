# The php_config resource is used to manage individual configuration files
# within the php/conf.d directory

require 'pathname'

resource_name :php_config

# Name of the configuration file
property :name,
  kind_of: String,
  name_attribute: true

# Priority prefix for the enabled configuration file
property :priority,
  kind_of: String,
  default: "20"

# Target path to install the configuration file in
property :path,
  kind_of: String,
  default: lazy { |r| "#{node[:php][:ext_conf_dir]}/#{r.name}.ini" }

# PHP SAPI packages to enable / disable the module for
property :php_sapi,
  kind_of: [String, Array],
  coerce: proc { |v| Array(v).map {|v| v.split(" ")}.flatten },
  default: %w(ALL)

# Cookbook providing the configuration file template
property :cookbook,
  kind_of: String,
  default: "php_wrapper"

# Template name to use
property :source,
  kind_of: String,
  default: "extension.ini.erb"

# PHP directives to define within the configuration file
property :directives,
  kind_of: Hash,
  default: {}

# PHP extensions to enable in the configuration file
property :extensions,
  kind_of: Hash,
  default: {}

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
  template_resource.action :create
end

action :delete do
  template_resource.action :delete
end

action :enable do
  if supports_php5query? and not whyrun_mode?
    resource_sapi_list.each do |sapi_name|
      sapi_files_found(sapi_name).each do |sapi_file|
        unless sapi_file == sapi_file_path(sapi_name, new_resource.priority)
          activation_resource(sapi_name, sapi_file).action :delete
        end
      end
    end
    activation_resource(sapi_name)
  elsif whyrun_mode?
    Chef.run_context.events.whyrun_assumption(
      :enable, new_resource,
      "would enable the configuration for: #{new_resource.php_sapi.join(", ")}"
    )
  else Chef::Log.info("#{new_resource} does not support enabling")
  end
end

action :disable do
  if supports_php5query? and not whyrun_mode?
    resource_sapi_list.each do |sapi_name|
      sapi_files_found(sapi_name).each do |sapi_file|
        if sapi_file == sapi_file_path(sapi_name, new_resource.priority)
          activation_resource(sapi_name, sapi_file).action :delete
        end
      end
    end
  elsif whyrun_mode?
    Chef.run_context.events.whyrun_assumption(
      :disable, new_resource,
      "would disable the configuration for: #{new_resource.php_sapi.join(", ")}"
    )
  else  Chef::Log.info("#{new_resource} does not support disabling")
  end
end

# Shared template resource used within the actions
#
def template_resource
  @template_resource ||= template new_resource.path do
    source new_resource.source
    cookbook new_resource.cookbook
    owner "root"
    group "root"
    mode  00644
    variables name: new_resource.name,
              priority: new_resource.priority,
              extensions: new_resource.extensions,
              directives: new_resource.directives
    action :nothing
  end
end

# Share link resource used within actions to enable/disable
#
def activation_resource(sapi_name, sapi_file = nil)
  sapi_file ||= sapi_file_path(sapi_name, new_resource.priority)
  link sapi_file do
    new_resource.path
    action :nothing
  end
end

# Determine whether php5query exists (debian like systems) to see whether
# this resource should provide the required PHP SAPI symlinks
#
def supports_php5query?
  ::File.exists?("/usr/sbin/php5query")
end

# List of the installed PHP SAPIs
#
def sapi_list
  @sapi_list ||= if supports_php5_query?
                   `/usr/sbin/php5query -q -S`.split("\n")
                 else Array.new
                 end
end

# List of the resource's desired PHP SAPI (new_resource.php_sapi)
#
def resource_sapi_list
  if new_resource.php_sapi.include?("ALL") then sapi_list
  elsif supports_php5query? then new_resource.php_sapi
  else Array.new
  end
end

# PHP SAPI specific directory
#
def sapi_directory(sapi)
  "/etc/php5/#{sapi}/conf.d"
end

# PHP SAPI specific file path
#
def sapi_file_path(sapi, priority = nil)
  name = "#{new_resource.name}.ini"
  name = priority.nil? ? name : "#{new_resource.priority}-#{name}"
  ::File.join(sapi_directory(sapi), name)
end

# Files currently installed for a specific PHP SAPI
#
def sapi_files_found(sapi, priority = "*")
  ::Dir.glob(sapi_file_path(sapi, priority)) + ::Dir.glob(sapi_file_path(sapi))
end

