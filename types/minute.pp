# Rsg_cron::Minute
#
# Type used for validation of the minute parameter for rsg_cron::entry
#
# @summary Validation type for cron minute
type Rsg_cron::Minute = Variant[
  Integer[0,59],
  Pattern[/^([1-5]?[0-9]|\*)$/,
    /^([1-5]?[0-9](-[1-5]?[0-9])?|\*)(\/[1-5]?[0-9])?$/,
    /^([1-5]?[0-9](-[1-5]?[0-9])?,)+[1-5]?[0-9](-[1-5]?[0-9])?$/],
  Array[Integer[0,59]]
]
