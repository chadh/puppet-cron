# cron::entry
#
# Adds a cron job to /etc/cron.d
#
# @summary This resource schedules a cron job.
#
# @example
#    cron::entry { 'job1':
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
# @param environment
#   cron environment specification (newline- or comma-separated lines, array of lines, or hash of key/values)
#
define cron::entry(
  String $command,
  Enum['absent','present'] $ensure         = 'present',
  Boolean $persistent                      = false,
  String[1] $user                          = 'root',
  Optional[Cron::Minute] $minute           = undef,
  Optional[Cron::Hour] $hour               = undef,
  Optional[Cron::Day] $day                 = undef,
  Optional[Cron::Month] $month             = undef,
  Optional[Cron::Weekday] $weekday         = undef,
  Optional[Cron::Special] $special         = undef,
  Optional[Cron::Environment] $environment = undef,
) {
  require cron

  if $persistent {
    $prefix = "${cron::persistent_prefix}_"
  } else {
    $prefix = "${cron::prefix}_"
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
      undef   => '*',
      default => $minute,
    }
    $_hour = $hour ? {
      Array   => join($hour,','),
      String  => regsubst($hour, ' ', ''),
      undef   => '*',
      default => $hour,
    }
    $_day = $day ? {
      Array   => join($day,','),
      String  => regsubst($day, ' ', ''),
      undef   => '*',
      default => $day,
    }
    $_month = $month ? {
      Array   => join($month,','),
      String  => regsubst($month, ' ', ''),
      undef   => '*',
      default => $month,
    }
    $_weekday = $weekday ? {
      Array   => join($weekday,','),
      String  => regsubst($weekday, ' ', ''),
      undef   => '*',
      default => $weekday,
    }
  }

  if $environment {
    $env_array = $environment ? {
      Hash => $environment.join_keys_to_values('='),
      String => $environment.split('[\n,]'),
      default => $environment,
    }
    $env_string = $env_array.join("\n")
    $_environment = "${env_string}\n"
  } else {
    $_environment = undef
  }

  if $cron::classic {
    if $special {
      cron { $jobname:
        ensure      => $ensure,
        command     => $command,
        user        => $user,
        special     => $special,
        environment => $_environment,
      }
    } else {
      cron { $jobname:
        ensure      => $ensure,
        command     => $command,
        user        => $user,
        minute      => $_minute,
        hour        => $_hour,
        monthday    => $_day,
        month       => $_month,
        weekday     => $_weekday,
        environment => $_environment,
      }
    }
  } else {
    if $special {
      $time = $special
    } else {
      $time = "${_minute} ${_hour} ${_day} ${_month} ${_weekday}"
    }

    file { "/etc/cron.d/${jobname}.cron":
      ensure  => $ensure,
      content => "${_environment}${time} ${user} ${command}\n",
      owner   => 'root',
      group   => 'root',
      mode    => '0600',
    }
  }
}
