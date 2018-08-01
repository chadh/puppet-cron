# cron::install
#
# Install package
#
# @summary Install cron package and purge script
#
# @api private
#
# @example
#   include cron::install
class cron::install {
  include cron

  if $cron::package_name {
    package { $cron::package_name:
      ensure => $cron::package_version,
    }
  }

  if ! $cron::classic {
    file { '/etc/cron.d':
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    }
  }
  if $cron::purge and ! $cron::classic {
    file { $cron::purge_script:
      ensure  => present,
      content => epp('cron/purge_cron.sh.epp', {'prefix' => $cron::prefix}),
      owner   => 'root',
      group   => 'root',
      mode    => '0700',
    }

    file { "/etc/cron.d/${cron::persistent_prefix}_purge_cron":
      ensure  => present,
      content => "*/10 * * * * root ${$cron::purge_script}\n",
      owner   => 'root',
      group   => 'root',
      mode    => '0600',
    }
  }
}
