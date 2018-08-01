# cron class
#
# @summary configures cron jobs
#
# @example Basic Usage
#    include cron
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
# @param [Boolean] manage_package
#   whether or not to install the cron package
#
# @param [Optional[String[1]]] package_version
#   version of package to install or just "installed" to install latest or keep current if already installed
#
# @param [Optional[String[1]]] package_name
#   name of OS package
#
class cron(
  String[1] $prefix,
  String[1] $persistent_prefix,
  Boolean $purge,
  Boolean $classic,
  Boolean $manage_package,
  String[1] $package_version,
  Optional[String[1]] $package_name = undef,
) {
  contain cron::install
  contain cron::config
  contain cron::service
  Class['cron::install']
  -> Class['cron::config']
  ~> Class['cron::service']
}
