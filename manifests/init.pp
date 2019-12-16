class rkhunter  (
  Boolean $rotate_mirrors                             = true,
  Boolean $update_mirrors                             = true,
  Enum['any','local','remote'] $mirrors_mode          = 'any',
  Optional[String[1]] $mail_on_warning                = undef,
  String[1] $mail_cmd                                 = 'mail -s "[rkhunter] Warnings found for ${HOST_NAME}"',
  Stdlib::Absolutepath $tmpdir                        = $rkhunter::params::tmpdir,
  Stdlib::Absolutepath $dbdir                         = '/var/lib/rkhunter/db',
  Stdlib::Absolutepath $scriptdir                     = '/usr/share/rkhunter/scripts',
  Optional[String[1]] $bindir                         = undef,
  $logfile                                            = $rkhunter::params::logfile,
  Boolean $append_log                                 = $rkhunter::params::append_log,
  Boolean $copy_log_on_error                          = false,
  $use_syslog                                         = $rkhunter::params::use_syslog,
  Boolean $color_set2                                 = false,
  Boolean $auto_x_detect                              = $rkhunter::params::auto_x_detect,
  Boolean $whitelisted_is_white                       = false,
  $allow_ssh_root_user                                = $rkhunter::params::allow_ssh_root_user,
  String[1] $allow_ssh_prot_v1                        = '0',
  String[1] $enable_tests                             = 'all',
  String[1] $disable_tests                            = 'suspscan hidden_procs deleted_files packet_cap_apps apps',
  String[1] $immutable_set                            = '0',
  Boolean $allow_syslog_remote_logging                = false,
  Stdlib::Absolutepath $suspscan_temp                 = '/dev/shm',
  String[1] $suspscan_maxsize                         = '10240000',
  String[1] $suspscan_thresh                          = '200',
  Boolean $use_locking                                = false,
  String[1]$lock_timeout                              = '300',
  Boolean $show_lockmsgs                              = true,
  Optional[Enum['0','1','2']] $disable_unhide         = $rkhunter::params::disable_unhide,
  Stdlib::Absolutepath $installdir                    = '/usr',
  Optional[Stdlib::Absolutepath] $ssh_config_dir      = undef,
  Optional[String[1]] $hash_cmd                       = undef,
  Optional[String[1]] $hash_fld_idx                   = undef,
  $package_manager                                    = $rkhunter::params::package_manager,
  Array[Stdlib::Absolutepath] $pkgmgr_no_verfy        = [],
  Array[Stdlib::Absolutepath] $ignore_prelink_dep_err = [],
  Optional[Boolean] $use_sunsum                       = undef,
  $existwhitelist                                     = $rkhunter::params::existwhitelist,
  Array[Stdlib::Absolutepath] $attrwhitelist          = [],
  Array[Stdlib::Absolutepath] $writewhitelist         = [],
  Enum['THOROUGH', 'LAZY'] $scan_mode_dev             = 'THOROUGH',
  Boolean $phalanx2_dirtest                           = false,
  Optional[Stdlib::Absolutepath] $inetd_conf_path     = undef,
  Array[String[1]] $inetd_allowed_svc                 = [],
  Optional[Stdlib::Absolutepath] $xinetd_conf_path    = undef,
  Array[String[1]] $xinetd_allowed_svc                = [],
  Optional[Stdlib::Absolutepath] $startup_paths       = undef,
  Optional[Stdlib::Absolutepath] $passwd_file         = undef,
  Array[String[1]] $user_fileprop_files_dirs          = [],
  $rtkt_file_whitelist                                = $rkhunter::params::rtkt_file_whitelist,
  Array[String[1]] $rtkt_dir_whitelist                = [],
  Optional[Stdlib::Absolutepath] $os_version_file     = undef,
  Optional[String[1]] $stat_cmd                       = undef,
  Optional[String[1]] $readlink_cmd                   = undef,
  Optional[String[1]] $web_cmd                        = undef,
  Optional[String[1]] $scanrootkitmode                = undef,
  Optional[String[1]] $unhide_tests                   = undef,
  Optional[String[1]] $unhidetcp_opts                 = undef,
  $scriptwhitelist                                    = $rkhunter::params::scriptwhitelist,
  Array[String[1]] $immutewhitelist                   = [],
  $allowhiddendir                                     = $rkhunter::params::allowhiddendir,
  $allowhiddenfile                                    = $rkhunter::params::allowhiddenfile,
  Array[String[1]] $allowprocdelfile                  = [],
  Array[String[1]] $allowproclisten                   = [],
  Array[String[1]] $allowpromiscif                    = [],
  $allowdevfile                                       = $rkhunter::params::allowdevfile,
  Array[String[1]] $allowipcproc                      = [],
  Array[String[1]] $allowipcpid                       = [],
  Array[String[1]] $allowipcuser                      = [],
  Optional[Variant[String[1],Integer]] $ipc_seg_size  = undef,
  Array[String[1]] $uid0_accounts                     = [],
  Array[String[1]] $pwdless_accounts                  = [],
  Array[Stdlib::Absolutepath] $syslog_config_file     = [],
  Array[String[1]] $app_whitelist                     = [],
  Array[String[1]] $suspscan_dirs                     = [],
  Array[String[1]] $port_whitelist                    = [],
  Array[String[1]] $port_path_whitelist               = [],
  Optional[String[1]] $warn_on_os_change              = undef,
  Optional[String[1]] $updt_on_os_change              = undef,
  Array[Stdlib::Absolutepath] $shared_lib_whitelist   = [],
  Optional[Boolean] $show_summary_warnings_number     = undef,
  Optional[String[1]] $show_summary_time              = undef,
  Optional[String[1]] $empty_logfiles                 = undef,
  Optional[String[1]] $missing_logfiles               = undef,
  String[1] $package_name                             = 'rkhunter',
  Optional[Stdlib::HTTPUrl] $local_mirror             = undef,
) inherits ::rkhunter::params {

  contain rkhunter::packages

  $mirrors_file = '/var/lib/rkhunter/db/mirrors.dat'

  # Make sure mimimal mirrors.dat exists for file_line to function
  file { $mirrors_file:
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => "Version:1\n",
    replace => false,
    require => Class['rkhunter::packages'],
  }
  if $local_mirror {
    file_line { 'Add local mirror to mirrors.dat':
      ensure  => present,
      path    => $mirrors_file,
      line    => "local=${local_mirror}",
      match   => '^local=',
      require => File[$mirrors_file],
    }
  } else {
    file_line { 'Remove local mirror from mirrors.dat':
      ensure            => absent,
      path              => $mirrors_file,
      match             => '^local=',
      match_for_absence => true,
      require           => File[$mirrors_file],
    }
  }

  file { '/etc/rkhunter.conf':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp('rkhunter/rkhunter.conf.epp');
  }
}
