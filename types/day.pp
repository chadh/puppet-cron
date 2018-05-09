# Rsg_cron::Day
#
# Type used for validation of the day parameter for rsg_cron::entry
#
# @summary Validation type for cron day
type Rsg_cron::Day = Variant[
  Integer[1,31],
  Pattern[/^(([12]?[2-9]|[1-3][01]?)|\*)$/,
    /^(([12]?[2-9]|[1-3][01]?)(-([12]?[2-9]|[1-3][01]?))?|\*)(\/([12]?[2-9]|[1-3][01]?))?$/,
    /^(([12]?[2-9]|[1-3][01]?)(-([12]?[2-9]|[1-3][01]?))?)(,([12]?[2-9]|[1-3][01]?)(-([12]?[2-9]|[1-3][01]?))?)*$/],
  Array[Integer[1,31]]
]
