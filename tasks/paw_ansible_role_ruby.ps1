# Puppet task for executing Ansible role: ansible_role_ruby
# This script runs the entire role via ansible-playbook

$ErrorActionPreference = 'Stop'

# Determine the ansible modules directory
if ($env:PT__installdir) {
  $AnsibleDir = Join-Path $env:PT__installdir "lib\puppet_x\ansible_modules\ansible_role_ruby"
} else {
  # Fallback to Puppet cache directory
  $AnsibleDir = "C:\ProgramData\PuppetLabs\puppet\cache\lib\puppet_x\ansible_modules\ansible_role_ruby"
}

# Check if ansible-playbook is available
$AnsiblePlaybook = Get-Command ansible-playbook -ErrorAction SilentlyContinue
if (-not $AnsiblePlaybook) {
  $result = @{
    _error = @{
      msg = "ansible-playbook command not found. Please install Ansible."
      kind = "puppet-ansible-converter/ansible-not-found"
    }
  }
  Write-Output ($result | ConvertTo-Json)
  exit 1
}

# Check if the role directory exists
if (-not (Test-Path $AnsibleDir)) {
  $result = @{
    _error = @{
      msg = "Ansible role directory not found: $AnsibleDir"
      kind = "puppet-ansible-converter/role-not-found"
    }
  }
  Write-Output ($result | ConvertTo-Json)
  exit 1
}

# Detect playbook location (collection vs standalone)
# Collections: ansible_modules/collection_name/roles/role_name/playbook.yml
# Standalone: ansible_modules/role_name/playbook.yml
$CollectionPlaybook = Join-Path $AnsibleDir "roles\paw_ansible_role_ruby\playbook.yml"
$StandalonePlaybook = Join-Path $AnsibleDir "playbook.yml"

if ((Test-Path (Join-Path $AnsibleDir "roles")) -and (Test-Path $CollectionPlaybook)) {
  # Collection structure
  $PlaybookPath = $CollectionPlaybook
  $PlaybookDir = Join-Path $AnsibleDir "roles\paw_ansible_role_ruby"
} elseif (Test-Path $StandalonePlaybook) {
  # Standalone role structure
  $PlaybookPath = $StandalonePlaybook
  $PlaybookDir = $AnsibleDir
} else {
  $result = @{
    _error = @{
      msg = "playbook.yml not found in $AnsibleDir or $AnsibleDir\roles\paw_ansible_role_ruby"
      kind = "puppet-ansible-converter/playbook-not-found"
    }
  }
  Write-Output ($result | ConvertTo-Json)
  exit 1
}

# Build extra-vars from PT_* environment variables
$ExtraVars = @{}
if ($env:PT_workspace) {
  $ExtraVars['workspace'] = $env:PT_workspace
}
if ($env:PT_ruby_install_bundler) {
  $ExtraVars['ruby_install_bundler'] = $env:PT_ruby_install_bundler
}
if ($env:PT_ruby_install_gems) {
  $ExtraVars['ruby_install_gems'] = $env:PT_ruby_install_gems
}
if ($env:PT_ruby_install_gems_user) {
  $ExtraVars['ruby_install_gems_user'] = $env:PT_ruby_install_gems_user
}
if ($env:PT_ruby_install_from_source) {
  $ExtraVars['ruby_install_from_source'] = $env:PT_ruby_install_from_source
}
if ($env:PT_ruby_download_url) {
  $ExtraVars['ruby_download_url'] = $env:PT_ruby_download_url
}
if ($env:PT_ruby_version) {
  $ExtraVars['ruby_version'] = $env:PT_ruby_version
}
if ($env:PT_ruby_source_configure_command) {
  $ExtraVars['ruby_source_configure_command'] = $env:PT_ruby_source_configure_command
}
if ($env:PT_ruby_rubygems_package_name) {
  $ExtraVars['ruby_rubygems_package_name'] = $env:PT_ruby_rubygems_package_name
}

$ExtraVarsJson = $ExtraVars | ConvertTo-Json -Compress

# Execute ansible-playbook with the role
Push-Location $PlaybookDir
try {
  ansible-playbook playbook.yml `
    --extra-vars $ExtraVarsJson `
    --connection=local `
    --inventory=localhost, `
    2>&1 | Write-Output
  
  $ExitCode = $LASTEXITCODE
  
  if ($ExitCode -eq 0) {
    $result = @{
      status = "success"
      role = "ansible_role_ruby"
    }
  } else {
    $result = @{
      status = "failed"
      role = "ansible_role_ruby"
      exit_code = $ExitCode
    }
  }
  
  Write-Output ($result | ConvertTo-Json)
  exit $ExitCode
}
finally {
  Pop-Location
}
