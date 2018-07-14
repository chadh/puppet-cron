# rsg_cron::install
#
# Install package
#
# @summary Install cron package and purge script
#
# @api private
#
# @example
#   include rsg_cron::install
class rsg_cron::install {
  include rsg_cron

  if $rsg_cron::package_name {
    package { $rsg_cron::package_name:
      ensure => $rsg_cron::package_version,
    }
  }

  if ! $rsg_cron::classic {
    file { '/etc/cron.d':
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    }
  }
  if $rsg_cron::purge and ! $rsg_cron::classic {
    $purge_script = '/usr/local/sbin/purge_cron.sh'
    file { $purge_script:
      ensure  => present,
      content => file('rsg_cron/purge_cron.sh'),
      owner   => 'root',
      group   => 'root',
      mode    => '0700',
    }

    file { "/etc/cron.d/${rsg_cron::prefix}${rsg_cron::persistent_prefix}_purge_cron":
      ensure  => present,
      content => "*/10 * * * * root ${purge_script}\n",
      owner   => 'root',
      group   => 'root',
      mode    => '0600',
    }
  }
}
