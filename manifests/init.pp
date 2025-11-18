# paw_ansible_role_ruby
# @summary Manage paw_ansible_role_ruby configuration
#
# @param workspace
# @param ruby_install_bundler Whether this role should install Bundler.
# @param ruby_install_gems A list of Ruby gems to install.
# @param ruby_install_gems_user The user account under which Ruby gems will be installed.
# @param ruby_install_from_source the 'ruby_version' variable instead of using a package.
# @param ruby_download_url
# @param ruby_version
# @param ruby_source_configure_command
# @param ruby_rubygems_package_name Default should usually work, but this will be overridden on Ubuntu 14.04.
# @param par_tags An array of Ansible tags to execute (optional)
# @param par_skip_tags An array of Ansible tags to skip (optional)
# @param par_start_at_task The name of the task to start execution at (optional)
# @param par_limit Limit playbook execution to specific hosts (optional)
# @param par_verbose Enable verbose output from Ansible (optional)
# @param par_check_mode Run Ansible in check mode (dry-run) (optional)
# @param par_timeout Timeout in seconds for playbook execution (optional)
# @param par_user Remote user to use for Ansible connections (optional)
# @param par_env_vars Additional environment variables for ansible-playbook execution (optional)
# @param par_logoutput Control whether playbook output is displayed in Puppet logs (optional)
# @param par_exclusive Serialize playbook execution using a lock file (optional)
class paw_ansible_role_ruby (
  String $workspace = '/root',
  Boolean $ruby_install_bundler = true,
  Array $ruby_install_gems = [],
  String $ruby_install_gems_user = '{{ ansible_user }}',
  Boolean $ruby_install_from_source = false,
  String $ruby_download_url = 'http://cache.ruby-lang.org/pub/ruby/3.0/ruby-3.0.0.tar.gz',
  String $ruby_version = '3.0.0',
  String $ruby_source_configure_command = './configure --enable-shared',
  String $ruby_rubygems_package_name = 'rubygems',
  Optional[Array[String]] $par_tags = undef,
  Optional[Array[String]] $par_skip_tags = undef,
  Optional[String] $par_start_at_task = undef,
  Optional[String] $par_limit = undef,
  Optional[Boolean] $par_verbose = undef,
  Optional[Boolean] $par_check_mode = undef,
  Optional[Integer] $par_timeout = undef,
  Optional[String] $par_user = undef,
  Optional[Hash] $par_env_vars = undef,
  Optional[Boolean] $par_logoutput = undef,
  Optional[Boolean] $par_exclusive = undef
) {
# Execute the Ansible role using PAR (Puppet Ansible Runner)
  $vardir = $facts['puppet_vardir'] ? {
    undef   => $settings::vardir ? {
      undef   => '/opt/puppetlabs/puppet/cache',
      default => $settings::vardir,
    },
    default => $facts['puppet_vardir'],
  }
  $playbook_path = "${vardir}/lib/puppet_x/ansible_modules/ansible_role_ruby/playbook.yml"

  par { 'paw_ansible_role_ruby-main':
    ensure        => present,
    playbook      => $playbook_path,
    playbook_vars => {
      'workspace'                     => $workspace,
      'ruby_install_bundler'          => $ruby_install_bundler,
      'ruby_install_gems'             => $ruby_install_gems,
      'ruby_install_gems_user'        => $ruby_install_gems_user,
      'ruby_install_from_source'      => $ruby_install_from_source,
      'ruby_download_url'             => $ruby_download_url,
      'ruby_version'                  => $ruby_version,
      'ruby_source_configure_command' => $ruby_source_configure_command,
      'ruby_rubygems_package_name'    => $ruby_rubygems_package_name,
    },
    tags          => $par_tags,
    skip_tags     => $par_skip_tags,
    start_at_task => $par_start_at_task,
    limit         => $par_limit,
    verbose       => $par_verbose,
    check_mode    => $par_check_mode,
    timeout       => $par_timeout,
    user          => $par_user,
    env_vars      => $par_env_vars,
    logoutput     => $par_logoutput,
    exclusive     => $par_exclusive,
  }
}
