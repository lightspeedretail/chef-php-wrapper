
default[:php][:composer].tap do |config|
  config[:url] = "https://getcomposer.org/installer"
  config[:command] = "/usr/local/bin/composer"
  config[:version] = "1.0.0-alpha10"
end
