# Rsg_cron::Weekday
#
# Type used for validation of the weekday parameter for rsg_cron::entry
#
# @summary Validation type for weekday month
type Rsg_cron::Weekday = Variant[
  Integer[0,7],
  Pattern[/^([0-7]|\*)$/,
    /^([0-7](-[0-7])?|\*)(\/[0-7])?$/,
    /^([0-7](-[0-7])?,)+[0-7](-[0-7])?$/],
  Array[Integer[0,7]]
]
