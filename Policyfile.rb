
name 'php_wrapper'
default_source :supermarket

run_list 'recipe[php_wrapper::default]', 'recipe[php_wrapper::php-fpm]'

cookbook 'php_wrapper', path: '.'
cookbook 'php'
