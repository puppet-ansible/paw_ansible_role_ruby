# Example usage of paw_ansible_role_ruby

# Simple include with default parameters
include paw_ansible_role_ruby

# Or with custom parameters:
# class { 'paw_ansible_role_ruby':
#   workspace => '/root',
#   ruby_install_bundler => true,
#   ruby_install_gems => [],
#   ruby_install_gems_user => '{{ ansible_user }}',
#   ruby_install_from_source => false,
#   ruby_download_url => 'http://cache.ruby-lang.org/pub/ruby/3.0/ruby-3.0.0.tar.gz',
#   ruby_version => '3.0.0',
#   ruby_source_configure_command => './configure --enable-shared',
#   ruby_rubygems_package_name => 'rubygems',
# }
