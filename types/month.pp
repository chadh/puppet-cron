# Cron::Month
#
# Type used for validation of the month parameter for cron::entry
#
# @summary Validation type for cron month
type Cron::Month = Variant[
  Integer[1,12],
  Pattern[/^([1-9]|1[0-2]|\*)$/,
    /^(([1-9]|1[0-2])(-([1-9]|1[0-2]))?|\*)(\/([1-9]|1[0-2]))?$/,
    /^(([1-9]|1[0-2])(-([1-9]|1[0-2]))?,)+([1-9]|1[0-2])(-([1-9]|1[0-2]))?$/],
  Array[Integer[1,12]]
]
