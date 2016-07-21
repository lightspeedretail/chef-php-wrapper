# A resource which handles installing the Composer php application either
# globally or for a given project.
# @since 2.0.0

resource_name :php_composer_binary

# Path to install composer to
property :path,
  kind_of: String,
  required: true,
  default: lazy { node[:php][:composer][:command] }

# Version to install
property :version,
  kind_of: String,
  default: lazy { node[:php][:composer][:version] }

# Url of the composer installer
property :source_url,
  desired_state: false,
  kind_of: String,
  default: lazy { node[:php][:composer][:url] }

# Path to download the installer to
def installer_path
  ::File.join(
    Chef::Config['file_cache_path'],
    "composer.#{version || 'latest'}"
  )
end

# Ensure that the resource is applied regardless of whether we are in why_run
# or standard mode.
#
# Refer to chef/chef#4537 for this uncommon syntax
action_class do
  def whyrun_supported?
    true
  end
end

# Create the current_resource object to compare against new_resource
load_current_value do
  if ::File.exist?(path)
    version `#{path} --version --no-ansi`.split(' ')[2]
  else current_value_does_not_exist!
  end
end

action :create do
  converge_if_changed do
    remote_file new_resource.installer_path do
      source new_resource.source_url
      mode 00755
    end

    execute 'install composer' do
      command <<-EOF
        #{node[:php][:bin]} #{new_resource.installer_path} \
        --install-dir=#{::File.dirname(new_resource.path)} \
        --filename=#{::File.basename(new_resource.path)} \
        --version=#{new_resource.version}
      EOF
    end
  end
end

action :delete do
  file new_resource.installer_path do
    action :delete
  end
end
