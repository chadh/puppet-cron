#!/bin/bash
#
# Script to purge /etc/cron.d of stale cron::entry resources.
#
# cron::entry resource filenames begin with "mcpup_".
#
# shellcheck disable=SC1091
lastrunreport="$(puppet config print lastrunreport)"
catalog="$(puppet config print client_datadir)/catalog/$(hostname).json"

# if there is no lastrunreport (new install) or if the last run was a failed run, just exit
[[ -r "$lastrunreport" ]] || exit
grep -q '^  status: failed' "$lastrunreport" && exit

# jq isn't quite ubiquitous, so we have make sure it's available
export PATH="${PATH}:/usr/local/bin"
# if we get here, it would seem that we successfully downloaded a catalog from the master
# let's pull out the Cron::Entry resources and check them against the ones we currently have
[[ -r "$catalog" ]] || exit
declare -A mycrons
for e in $(jq -r '.data.resources[] | select(.type == "Cron::Entry") | select(.parameters.persistent == false) | .title' "$catalog"); do
  mycrons[$e]=""
done
if [[ ${#mycrons[@]} -eq 0 ]]; then
	logger "purge_cron: Found 0 Cron::Entry resources in catalog.  Bailing!!"
	exit
fi

for e in /etc/cron.d/mcpup_*; do
  taskname=$(basename "$e" .cron | sed 's/^mcpup_\(.*\)/\1/')

  if [ ! ${mycrons[$taskname]+_} ]; then
    logger "purge_cron: removing ${taskname} (${e})"
    rm -f "$e"
  fi
done