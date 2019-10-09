# Install PHP 7.1 from PPA
#
apt_repository 'php7.1' do
  distribution  node['lsb']['codename']
  uri           "https://#{node['apt_repo']['lightspeedhq']['username']}:#{node['apt_repo']['lightspeedhq']['password']}@lightspeedhq.jfrog.io/lightspeedhq/debian"
  key           "https://#{node['apt_repo']['lightspeedhq']['username']}:#{node['apt_repo']['lightspeedhq']['password']}@lightspeedhq.jfrog.io/lightspeedhq/debian/mirror.cs.uchicago.edu.gpg"
  components    ['main']
  arch          'amd64'
  trusted       true
  only_if       { node['php']['version'].start_with?('7') }
end

apt_repository 'php5.6' do
  distribution  node['lsb']['codename']
  uri           "https://#{node['apt_repo']['lightspeedhq']['username']}:#{node['apt_repo']['lightspeedhq']['password']}@lightspeedhq.jfrog.io/lightspeedhq/debian"
  key           "https://#{node['apt_repo']['lightspeedhq']['username']}:#{node['apt_repo']['lightspeedhq']['password']}@lightspeedhq.jfrog.io/lightspeedhq/debian/mirror.cs.uchicago.edu.gpg"
  components    ['main']
  arch          'amd64'
  trusted       true
  only_if       { node['php']['version'].start_with?('5.6') }
end


# Toggle attributes based on php version
node.default['php'].tap do |php|
  case node['php']['version']
    when '7.1'
      php['checksum']            = '4124a3532e2ae0e1f14b8f4f73114f56499c24ce21bac58fe1d760ed94fa5ce0'
      php['conf_dir']            = '/etc/php/7.1'
      php['src_deps']            = %w(libbz2-dev libc-client2007e-dev libcurl4-gnutls-dev libfreetype6-dev libgmp3-dev libjpeg62-dev libkrb5-dev libmcrypt-dev libpng12-dev libssl-dev pkg-config)
      php['packages'].concat(%w(php7.1-cgi php7.1 php7.1-dev php7.1-cli php-pear))
      php['mysql']['package']    = 'php7.1-mysql'
      php['curl']['package']     = 'php7.1-curl'
      php['apc']['package']      = 'php-apc'
      php['apcu']['package']     = 'php-apcu'
      php['gd']['package']       = 'php7.1-gd'
      php['ldap']['package']     = 'php7.1-ldap'
      php['pgsql']['package']    = 'php7.1-pgsql'
      php['sqlite']['package']   = 'php7.1-sqlite3'
      php['fpm_package']         = 'php7.1-fpm'
      php['fpm_pooldir']         = '/etc/php/7.1/fpm/pool.d'
      php['fpm_service']         = 'php7.1-fpm'
      php['fpm_socket']          = '/var/run/php/php7.1-fpm.sock'
      php['fpm_default_conf']    = '/etc/php/7.1/fpm/pool.d/www.conf'
      php['fpm_service_conf']    = '/etc/php/7.1/fpm/php-fpm.conf'
      php['fpm_error_log']       = '/var/log/php7.1-fpm.log'
      php['fpm_pid']             = '/var/run/php7.1-fpm.pid'
      php['enable_mod']          = '/usr/sbin/phpenmod'
      php['disable_mod']         = '/usr/sbin/phpdismod'
      php['ext_conf_dir']        = '/etc/php/7.1/mods-available'
    else
      # Core config
      php['conf_dir'] = '/etc/php/5.6'

      # Install packages through the standard `php` cookbook
      php['packages'].concat(%w(php5.6-cgi php5.6 php5.6-dev php5.6-cli php-pear))
      php['mysql']['package']    = 'php5.6-mysqlnd'
      php['fpm_package']         = 'php5.6-fpm'

      # Other configs
      php['fpm_pooldir']         = '/etc/php/5.6/fpm/pool.d'
      php['fpm_service']         = 'php5.6-fpm'
      php['fpm_socket']          = '/var/run/php/php5.6-fpm.sock'
      php['fpm_default_conf']    = '/etc/php/5.6/fpm/pool.d/www.conf'
      php['fpm_service_conf']    = '/etc/php/5.6/fpm/php-fpm.conf'
      php['fpm_error_log']       = '/var/log/php5.6-fpm.log'
      php['fpm_pid']             = '/var/run/php5.6-fpm.pid'
      php['ext_conf_dir']        = '/etc/php/5.6/mods-available'
  end
end

case node['php']['version']
  when '7.1'
    node.default['php_wrapper']['session']['save_path'] = '/var/lib/php7.1/sessions'
  else
    node.default['php_wrapper']['session']['save_path'] = '/var/lib/php5.6/sessions'
end

include_recipe 'php::default'

# Ensure that php.ini is symlinked into each PHP SAPI to prevent having to
# manage a bunch of different configuration files.
#
%w(cgi cli fpm).each do |sapi|
  link "#{node['php']['conf_dir']}/#{sapi}/php.ini" do
    to "#{node['php']['conf_dir']}/php.ini"
    only_if do
      ::Dir.exist? "#{node['php']['conf_dir']}/#{sapi}"
    end
  end
end

# Install PHP Pear packages from attributes
# - Note: Given that upstream php_pear does not have the concept of
#   configuration file priorities, it is highly recommended that you _not_
#   use the `directives` and `zend_extensions` properties on this resource.
#
node['php']['pear_packages'].each do |name, hash|
  php_pear name do
    hash.each do |k, v|
      send(k, v) if respond_to?(k)
    end
  end
end

# Install PHP module configuration files from attributes
# - These are essentially used to plop down /etc/php5/conf.d/*.conf files which
#   provide default configurations for some/all SAPIs.
#
node['php']['directives']['module'].each do |name, hash|
  php_config name do
    hash.each do |k, v|
      send(k, v) if respond_to?(k)
    end
  end
end
