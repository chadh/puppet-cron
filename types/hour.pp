# Rsg_cron::Hour
#
# Type used for validation of the hour parameter for rsg_cron::entry
#
# @summary Validation type for cron hour
type Rsg_cron::Hour = Variant[
  Integer[0,23],
  Pattern[/^((1?[0-9]|2[0-3])|\*)$/,
    /^((1?[0-9]|2[0-3])(-(1?[0-9]|2[0-3]))?|\*)(\/(1?[0-9]|2[0-3]))?$/,
    /^((1?[0-9]|2[0-3])(-(1?[0-9]|2[0-3]))?,)+(1?[0-9]|2[0-3])(-(1?[0-9]|2[0-3]))?$/],
  Array[Integer[0,23]]
]
