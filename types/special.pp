# Cron::Special
#
# Type used for validation of the special parameter for cron::entry
#
# @summary Validation type for special month
type Cron::Special = Enum[
  '@reboot',
  '@yearly',
  '@annually',
  '@monthly',
  '@weekly',
  '@daily',
  '@midnight',
  '@hourly',
  '@every_minute',
  '@every_second',
]
