#!/bin/zsh --no-rcs

schedule_file="${alfred_workflow_data}/2026/schedule.json"
medals_file="${alfred_workflow_data}/2026/medals.json"
games_file="${alfred_workflow_data}/olympic-games.json"

mkdir -p "${alfred_workflow_data}/2026"
curl -sf --compressed --parallel --connect-timeout 10 \
    -L "https://www.olympics.com/wmr-owg2026/schedules/api/ENG/schedule" -o "${schedule_file}" \
    -L "https://www.olympics.com/wmr-owg2026/competition/api/ENG/medals" -o "${medals_file}" \
    -L "https://www.olympics.com/en/api/v1/b2p/menu/topbar/olympic-games" -o "${games_file}" \
    -A "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:147.0) Gecko/20100101 Firefox/147.0" \
&& downloadStatus=1

if [[ -n "${downloadStatus}" ]]; then
    printf "Schedule Updated"
else
    printf "Schedule not Updated"
fi