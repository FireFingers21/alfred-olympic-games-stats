#!/bin/zsh --no-rcs

# Get files for current games
schedule_file="${alfred_workflow_data}/2026/schedule.json"
# nocs_file="${alfred_workflow_data}/2026/nocs.json"

# Auto Update
[[ -f "${schedule_file}" ]] && [[ "$(date -r "${schedule_file}" +%s)" -lt "$(date -v -"${autoUpdate}"M +%s)" ]] && reload=$(./reload.sh)

# Load Schedule
jq -c --slurpfile nocDict "nocDict.json" \
'{
    "skipknowledge": true,
	"items": (if (length != 0) then
		.units | map(
		(.startDate | match("(?<=:[0-9]{2})(\\+|-)[0-9]{2}").string | tonumber * 3600) as $timeAdj |
		(.startDate | sub("(?<=:[0-9]{2})(\\+|-).*"; "Z") | fromdate - $timeAdj) as $localStartDate |
		(.endDate | sub("(?<=:[0-9]{2})(\\+|-).*"; "Z") | fromdate - $timeAdj) as $localEndDate |
		(if (now >= $localStartDate and now < $localEndDate) then "Now"+" "*8 else false end) as $isNow |
		(if (now > $localEndDate) then "Done"+" "*7 else false end) as $isDone |
		($isDone // $isNow // ($localStartDate | strflocaltime("%H:%M") | .+" "*(if (gsub("[^1]";"")|length > 1) then 7 else 6 end))) as $localStartTime |
		(.eventUnitName + (.locationShortDescription | if contains("Sheet") then " - "+. else "" end)) as $evtDesc |
		(.competitors.[0] | if (.code == "TBD") then .code else $nocDict[].emoji."\(.noc)" + " " + .name end) as $noc0 |
		(.competitors.[1] | if (.code == "TBD") then .code else $nocDict[].emoji."\(.noc)" + " " + .name end) as $noc1 |
		{
			"title": $localStartTime + .disciplineName + (.competitors | if (length == 2) then "   –   \($noc0)  /  \($noc1)" else "" end),
			"subtitle": ($localStartDate | strflocaltime("%b %d") + " "*11) + $evtDesc,
			"match": [
                .disciplineName, $evtDesc,
                (.competitors | select(.) | unique_by(.noc) | $nocDict[].names."\(.[].noc)"),
                ($localStartDate | strflocaltime("\"%b %d\" \"%b %e\""))
            ] | map(select(.)) | join(" "),
			"icon": {"path": (if .disciplineName != "Ceremonies" then
			    "images/sports/\(.disciplineCode)\(if $isNow then "live" else "" end).png"
			else "icon.png" end)},
			"variables": { "stale": ($isDone and (now - $localStartDate) > (12*3600)) }
		}) | [.[] | select(.variables.stale | not)]
	else
		[{
			"title": "No Schedule Found",
			"subtitle": "Press ↩ to load the schedule for the current year",
			"arg": "reload"
		}]
	end)
}' "${schedule_file}"