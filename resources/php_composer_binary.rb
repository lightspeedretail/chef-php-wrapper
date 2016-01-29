
# A php_composer_binary installs composer to the filesystem
#

resource_name :php_composer_binary
actions :create, :delete

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
    Chef::Config["file_cache_path"], 
    "composer.#{version || "latest"}"
  )
end

# Create the current_resource object to compare against new_resource
load_current_value do
  if ::File.exists?(new_resource.path)
    path new_resource.path
    version `#{new_resource.path} --version --no-ansi`.split(' ')[2]
  else current_value_does_not_exist!
  end
end

action :create do
  converge_if_changed do
    remote_file new_resource.installer_path do
      source new_resource.source_url
      mode 00755
    end

    execute "install composer" do
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

