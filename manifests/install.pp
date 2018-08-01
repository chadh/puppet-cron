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
    $purge_script = '/usr/local/sbin/purge_cron.sh'
    file { $purge_script:
      ensure  => present,
      content => file('cron/purge_cron.sh'),
      owner   => 'root',
      group   => 'root',
      mode    => '0700',
    }

    file { "/etc/cron.d/${cron::prefix}${cron::persistent_prefix}_purge_cron":
      ensure  => present,
      content => "*/10 * * * * root ${purge_script}\n",
      owner   => 'root',
      group   => 'root',
      mode    => '0600',
    }
  }
}
