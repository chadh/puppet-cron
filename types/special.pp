# Rsg_cron::Special
#
# Type used for validation of the special parameter for rsg_cron::entry
#
# @summary Validation type for special month
type Rsg_cron::Special = Enum[
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
