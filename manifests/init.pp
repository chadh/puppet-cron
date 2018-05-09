# rsg_cron class
#
# @summary configures cron jobs
#
# @example Basic Usage
#    include rsg_cron
#
# @param [String[1]] prefix
#   prefix string for cron jobs
#
# @param [String[1]] persistent_prefix
#   prefix string for persistent (purge-safe) cron jobs
#
# @param [Boolean] purge
#  Whether or not to purge unmanaged Cron entries.  Only applies to cron entries installed by this resource.
#
# @param [Boolean] classic
#   whether the host has an old version of cron that does not support `/etc/cron.d`
#
class rsg_cron(
  String[1] $prefix            = 'rsg',
  String[1] $persistent_prefix = 'persistent',
  Boolean $purge               = true,
  Boolean $classic             = false
) {

  $purge_script = '/usr/local/sbin/purge_cron.sh'
  if $purge {
    file { $purge_script:
      ensure  => present,
      content => file('rsg_cron/purge_cron.sh'),
      owner   => 'root',
      group   => 'root',
      mode    => '0700',
    }

    file { "/etc/cron.d/${prefix}${persistent_prefix}_purge_cron":
      ensure  => present,
      content => "*/10 * * * * root ${purge_script}\n",
      owner   => 'root',
      group   => 'root',
      mode    => '0600',
    }
  }

}
