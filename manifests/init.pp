# rsg_cron class
#
#  @summary configures cron jobs
#
# @example Basic Usage
#    include rsg_cron
#    rsg_cron::entry { 'job1':
#      command => '/usr/bin/find /tmp -type f -mtime +60 -delete',
#      user    => 'root',
#      hour    => 2,
#    }
#
# @param [Boolean] purge
#  Whether or not to purge unmanaged Cron entries.  Only applies to cron entries installed by this resource.
#
class rsg_cron(
  Boolean $purge = true,
) {

}
