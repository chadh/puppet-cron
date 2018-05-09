# rsg_cron::entry
#
# Adds a cron job to /etc/cron.d
#
# @summary This resource schedules a cron job.
#
# @example
#    rsg_cron::entry { 'job1':
#      command => '/usr/bin/find /tmp -type f -mtime +60 -delete',
#      user    => 'root',
#      hour    => 2,
#    }
#
# @param [String] command
#   command to run according to schedule
#
# @param [Enum['absent','present']] ensure
#    standard parameter for ensuring existence
#
# @param [Boolean] persistent
#   Whether or not this job is exempt from purging
#
# @param [String[1]] user
#   User account as which to run the job
#
# @param minute
#   minute(s) of the hour to run job
#
# @param hour
#   hour(s) of the day to run job
#
# @param day
#   day(s) of the month to run job
#
# @param month
#   month(s) of the year to run job
#
# @param weekday
#   day(s) of the week to run job
#
# @param special
#   override interval to run job (minute,hour,day,month,weekday ignored)
#
define rsg_cron::entry(
  String $command,
  Enum['absent','present'] $ensure     = 'present',
  Boolean $persistent                  = false,
  String[1] $user                      = 'root',
  Optional[Rsg_cron::Minute] $minute   = undef,
  Optional[Rsg_cron::Hour] $hour       = undef,
  Optional[Rsg_cron::Day] $day         = undef,
  Optional[Rsg_cron::Month] $month     = undef,
  Optional[Rsg_cron::Weekday] $weekday = undef,
  Optional[Rsg_cron::Special] $special = undef,
) {
  require rsg_cron

  if $persistent {
    $prefix = "${rsg_cron::prefix}${rsg_cron::persistent_prefix}_"
  } else {
    $prefix = "${rsg_cron::prefix}_"
  }
  $jobname = "${prefix}${title}"

  if $special {
    if $minute or $hour or $day or $month or $weekday {
      warning('special param overrides the other time params')
    }
  } else {
    $_minute = $minute ? {
      Array   => join($minute,','),
      String  => regsubst($minute, ' ', ''),
      default => $minute,
    }
    $_hour = $hour ? {
      Array   => join($hour,','),
      String  => regsubst($hour, ' ', ''),
      default => $hour,
    }
    $_day = $day ? {
      Array   => join($day,','),
      String  => regsubst($day, ' ', ''),
      default => $day,
    }
    $_month = $month ? {
      Array   => join($month,','),
      String  => regsubst($month, ' ', ''),
      default => $month,
    }
    $_weekday = $weekday ? {
      Array   => join($weekday,','),
      String  => regsubst($weekday, ' ', ''),
      default => $weekday,
    }
  }
  if $rsg_cron::classic {
    cron { $jobname:
      ensure   => $ensure,
      command  => $command,
      user     => $user,
      minute   => $_minute,
      hour     => $_hour,
      monthday => $_day,
      month    => $_month,
      weekday  => $_weekday,
    }
  } else {
    if $special {
      $time = $special
    } else {
      $time = "${_minute} ${_hour} ${_day} ${_month} ${_weekday}"
    }

    file { "/etc/cron.d/${jobname}.cron":
      ensure  => $ensure,
      content => "${time} ${user} ${command}\n",
      owner   => 'root',
      group   => 'root',
      mode    => '0600',
    }
  }
}
