# Cron::Minute
#
# Type used for validation of the minute parameter for cron::entry
#
# @summary Validation type for cron minute
type Cron::Minute = Variant[
  Integer[0,59],
  Pattern[/^([1-5]?[0-9]|\*)$/,
    /^([1-5]?[0-9](-[1-5]?[0-9])?|\*)(\/[1-5]?[0-9])?$/,
    /^([1-5]?[0-9](-[1-5]?[0-9])?,)+[1-5]?[0-9](-[1-5]?[0-9])?$/],
  Array[Integer[0,59]]
]
