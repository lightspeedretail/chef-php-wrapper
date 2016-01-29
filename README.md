# php_wrapper

This cookbook provides additional standard primitives to manage PHP and PHP-FPM deployments. 

# Reqirements
### Platforms
- Debina, Ubuntu

### Cookbooks
- common_utils
- php

### Attributes
- `node[:php][:packages]` = PHP packages to install (php::packages)
- `node[:php][:mysql][:package]` = Mysql PHP package to instal (php::module_mysql)
- `node[:php][:pear_packages]` = PHP Pear packages to install (php_wrapper::default)
- `node[:php][:directives]` = Default php.ini directives (php_wrapper::default)
- `node[:php][:directives][:custom]` = Additional php.ini directives
- `node[:php][:directives][:module]` = Additional modular php.ini directives
- `node[:php][:fpm_pools]` = PHP FPM pools to install

### Resources
This cookbook includes Resources for managing the following topics. Additional documentation may be found directly in each resource definition file.

- PHP Composer installation
- PHP Composer execution
- PHP-FPM Pool deployments
- PHP modular configuration files

### Recipes
#### default
Include the `php` upstream cookbook, installs packages and deploys configuration files.

#### composer
Installs a global `composer` binary installation

#### php_fpm
Installs and configures the `php-fpm` package and pools.

*Note*: The `php_pool` resource automatically sets the status page and ping path to be /_php/status and /_php/ping respectively. It is left up to you to secure the /_php/ uri path so that it may only be reached by your monitoring system.

