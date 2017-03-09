default['php']['composer'].tap do |config|
  config['url'] = 'https://getcomposer.org/installer'
  config['command'] = '/usr/local/bin/composer'
  config['version'] = '1.4.0'
end
