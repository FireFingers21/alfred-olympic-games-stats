#!/bin/zsh --no-rcs

schedule_file="${alfred_workflow_data}/2026/schedule.json"
nocs_file="${alfred_workflow_data}/2026/nocs.json"

mkdir -p "${alfred_workflow_data}/2026"
curl -sf --compressed --parallel --connect-timeout 10 -L "https://www.olympics.com/wmr-owg2026/schedules/api/ENG/schedule" -o "${schedule_file}" -L "https://www.olympics.com/wmr-owg2026/info/api/ENG/nocs" -o "${nocs_file}" -A "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:147.0) Gecko/20100101 Firefox/147.0" && downloadStatus=1

if [[ -n "${downloadStatus}" ]]; then
    printf "Schedule Updated"
else
    printf "Schedule not Updated"
fi