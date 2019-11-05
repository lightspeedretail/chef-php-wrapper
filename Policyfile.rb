
name 'php_wrapper'
default_source :supermarket

run_list 'recipe[php_wrapper::default]', 'recipe[php_wrapper::php-fpm]'

cookbook 'php_wrapper', path: '.'

cookbook 'apt', '= 5.1.0'
cookbook 'seven_zip', '< 3.0.0'
cookbook 'windows', '~ 3.4.1'
