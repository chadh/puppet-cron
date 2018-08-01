# Cron::Weekday
#
# Type used for validation of the weekday parameter for cron::entry
#
# @summary Validation type for weekday month
type Cron::Weekday = Variant[
  Integer[0,7],
  Pattern[/^([0-7]|\*)$/,
    /^([0-7](-[0-7])?|\*)(\/[0-7])?$/,
    /^([0-7](-[0-7])?,)+[0-7](-[0-7])?$/],
  Array[Integer[0,7]]
]
