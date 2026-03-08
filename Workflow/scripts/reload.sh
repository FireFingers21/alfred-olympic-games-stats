#!/bin/zsh --no-rcs

# Paralympic check
[[ "${keyword}" == "${schedule_keyword_para}" ]] || (( "${1}" )) && para=1

# Set variables for current games
source "games.env"
schedule_file="${alfred_workflow_data}/${year}/${para:+para/}schedule.json"
medals_file="${alfred_workflow_data}/${year}/${para:+para/}medals.json"
games_file="${alfred_workflow_data}/olympic-games.json"

mkdir -p "${alfred_workflow_data}/${year}${para:+/para}"
curl -sf --compressed --parallel --connect-timeout 10 \
    -L "${apiUrl}/schedules/api/ENG/schedule" -o "${schedule_file}" \
    -L "${apiUrl}/competition/api/ENG/medals" -o "${medals_file}" \
    -L "https://www.olympics.com/en/api/v1/b2p/menu/topbar/olympic-games" -o "${games_file}" \
    -A "${userAgent}" \
&& downloadStatus=1

if [[ -n "${downloadStatus}" ]]; then
    printf "Schedule Updated"
else
    printf "Schedule not Updated"
fi