
# Execute the composer command
#

resource_name :php_composer_command
actions :run

# Path to execute composer in
property :cwd,
  kind_of: String,
  name_property: true

# Arguments to pass to composer
property :arguments,
  kind_of: [String, Array],
  coerce: proc { |v| Array(v) },
  default: %w(--no-ansi --no-interaction --prefer-dist --optimize-autoloader)

# Path to the composer binary
property :path,
  kind_of: String,
  default: lazy { node[:php][:composer][:command] }

# User to execute the command as
property :user,
  kind_of: String

# Group to execute the command as
property :group,
  kind_of: String

# Hash of environment variables to set
property :environment,
  kind_of: Hash

action :run do
  execute "composer #{new_resource.arguments.join(" ")}" do
    cwd new_resource.cwd
    command "#{new_resource.path} #{new_resource.arguments.join(" ")}"
    user new_resource.user
    group new_resource.group
    environment new_resource.environment
  end
end

