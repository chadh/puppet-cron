
# rsg_cron




#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with rsg_cron](#setup)
    * [Beginning with rsg_cron](#beginning-with-rsg_cron)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)

## Description

The `rsg_cron` module provides resources for managing cron jobs in `/etc/cron.d`.  Beyond just creating the cron files, it also deploys a cleaner script that removes jobs that are no longer managed by puppet.

## Setup

### Beginning with rsg_cron

To use the `rsg_cron` module, include it:

``` puppet
include rsg_cron
```

## Usage

To create a new cron job, use the `cron::entry` defined resource type:

This example will run `mycommand` at 23 past the hour as user root.

``` puppet
cron::entry { 'my_job':
  command => '/usr/local/bin/mycommand > /dev/null',
  user => 'root',
  minute => '23',
}
```

## Reference

This module uses puppet strings for documentation.

## Limitations

As long as this module is used for generating cron entries, they will be cleaned up when they are no longer managed (that is, when the resource is removed from your puppet catalog).  The cleanup script works by looking at all jobs with "mcpup" prefix, so if you do not want the cron job to be purged, you will need to rename it.

