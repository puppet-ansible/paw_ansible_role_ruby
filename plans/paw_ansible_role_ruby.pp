# Execute Ansible role across inventory hosts
#
# This plan parses Ansible inventory, filters targets, and executes the paw_ansible_role_ruby task
# on each host with merged variables from group_vars and host_vars.
#
# Uses garrettrowell-par module (>= 0.2.0) helper functions:
#   - par::parse_inventory() - Parse inventory files (INI/YAML/JSON/dynamic)
#   - par::filter_targets() - Filter hosts by limit/groups patterns
#   - par::merge_vars() - Merge group_vars and host_vars with proper precedence
#
# @summary Execute paw_ansible_role_ruby task across Ansible inventory hosts
#
# @param inventory_source
#   Ansible inventory source with auto-detection:
#   - URL: http://example.com/api/inventory or https://cmdb.example.com/inventory
#   - File path: /etc/ansible/hosts.ini or /path/to/inventory.yaml
#   - Inline content: INI, YAML, or JSON inventory content as a string
#   - Executable script: /usr/local/bin/dynamic_inventory.py (dynamic inventory)
#
# @param limit
#   Limit execution to specific hosts (Ansible --limit pattern)
#   Example: 'webservers:dbservers' or 'host1,host2'
#
# @param groups
#   Limit execution to specific groups (alternative to limit)
#   Example: ['webservers', 'dbservers']
#
# @param parallel
#   Execute tasks in parallel across hosts (default: true)
#
# @param concurrency
#   Maximum number of parallel executions (default: 10)
#
# @param par_check_mode
#   Run Ansible in check mode (dry-run, no changes made)
#
# @param par_verbose
#   Enable verbose output from Ansible execution
#
# @param par_tags
#   Array of Ansible tags to execute (only run tasks with these tags)
#
# @param par_skip_tags
#   Array of Ansible tags to skip
#
# @param par_timeout
#   Timeout in seconds for playbook execution
#
# @param par_user
#   Remote user for Ansible connections
#
# @example Execute on all hosts from file
#   puppet plan run paw_ansible_role_ruby inventory_source=/path/to/inventory
#
# @example Execute on hosts from API
#   puppet plan run paw_ansible_role_ruby inventory_source=https://cmdb.example.com/inventory
#
# @example Execute on specific hosts
#   puppet plan run paw_ansible_role_ruby inventory_source=/path/to/inventory limit='webservers'
#
# @example Execute with custom concurrency
#   puppet plan run paw_ansible_role_ruby inventory_source=/path/to/inventory parallel=true concurrency=5
#
# @example Execute in check mode with verbose output
#   puppet plan run paw_ansible_role_ruby inventory_source=/path/to/inventory par_check_mode=true par_verbose=true
#
plan paw_ansible_role_ruby (
  String $inventory_source,
  Optional[String] $limit = undef,
  Optional[Array[String]] $groups = undef,
  Boolean $parallel = true,
  Integer $concurrency = 10,
  Optional[Boolean] $par_check_mode = undef,
  Optional[Boolean] $par_verbose = undef,
  Optional[Array[String]] $par_tags = undef,
  Optional[Array[String]] $par_skip_tags = undef,
  Optional[Integer] $par_timeout = undef,
  Optional[String] $par_user = undef
) {
  # Step 1: Parse inventory using PAR module function
  $inventory = par::parse_inventory($inventory_source)
  
  # Step 2: Filter targets based on limit/groups
  $targets = par::filter_targets($inventory, $limit, $groups)
  
  # Step 3: Execute task on each target with merged variables
  $results = if $parallel {
    # Parallel execution with concurrency limit
    $targets.slice($concurrency).map |$batch| {
      parallelize($batch) |$target| {
        # Merge group_vars and host_vars for this target
        # PAR merge_vars handles group filtering based on target membership
        $merged_vars = par::merge_vars($inventory['group_vars'], $target['host_vars'], $target['groups'])
        
        # Add PAR control parameters if specified (filter out undef values)
        $par_params = {
          'par_check_mode' => $par_check_mode,
          'par_verbose'    => $par_verbose,
          'par_tags'       => $par_tags,
          'par_skip_tags'  => $par_skip_tags,
          'par_timeout'    => $par_timeout,
          'par_user'       => $par_user,
        }
        $defined_par_params = $par_params.filter |$k, $v| { $v != undef }
        $task_params = $merged_vars + $defined_par_params
        
        # Execute task with merged variables
        $result = run_task('paw_ansible_role_ruby', $target['host'], $task_params)
        
        # Return structured result
        $task_result = {
          'host'      => $target['host'],
          'task'      => 'paw_ansible_role_ruby',
          'status'    => $result.ok ? 'success' : 'failure',
          'exit_code' => $result['exit_code'],
          'stdout'    => $result['stdout'],
          'stderr'    => $result['stderr'],
          'vars'      => $merged_vars,
        }
        $task_result
      }
    }.flatten
  } else {
    # Sequential execution
    $targets.map |$target| {
      # Merge group_vars and host_vars for this target
      # PAR merge_vars handles group filtering based on target membership
      $merged_vars = par::merge_vars($inventory['group_vars'], $target['host_vars'], $target['groups'])
      
      # Add PAR control parameters if specified (filter out undef values)
      $par_params = {
        'par_check_mode' => $par_check_mode,
        'par_verbose'    => $par_verbose,
        'par_tags'       => $par_tags,
        'par_skip_tags'  => $par_skip_tags,
        'par_timeout'    => $par_timeout,
        'par_user'       => $par_user,
      }
      $defined_par_params = $par_params.filter |$k, $v| { $v != undef }
      $task_params = $merged_vars + $defined_par_params
      
      # Execute task with merged variables
      $result = run_task('paw_ansible_role_ruby', $target['host'], $task_params)
      
      # Return structured result
      $task_result = {
        'host'      => $target['host'],
        'task'      => 'paw_ansible_role_ruby',
        'status'    => $result.ok ? 'success' : 'failure',
        'exit_code' => $result['exit_code'],
        'stdout'    => $result['stdout'],
        'stderr'    => $result['stderr'],
        'vars'      => $merged_vars,
      }
      $task_result
    }
  }
  
  return $results
}
