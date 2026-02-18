#!/bin/zsh --no-rcs

# Get files for current games
schedule_file="${alfred_workflow_data}/2026/schedule.json"

# Auto Update
[[ -f "${schedule_file}" ]] && [[ "$(date -r "${schedule_file}" +%s)" -lt "$(date -v -"${autoUpdate}"M +%s)" ]] && reload=$(./scripts/reload.sh)

# Load Schedule
jq -cs \
   --argjson spoilSchedule "${spoilSchedule}" \
   --argjson spoilSearch "${spoilSearch}" \
   --argjson showNowTime "${showNowTime}" \
   --argjson showDoneTime "${showDoneTime}" \
   --argjson showOldEvents "${showOldEvents:=0}" \
   --slurpfile nocDict "nocDict.json" \
'{
    "variables": { "keyword": "'${alfred_workflow_keyword}'" },
    "skipknowledge": true,
	"items": (if (length != 0) then
		.[].units | map(
		(.startDate | match("(?<=:[0-9]{2})(\\+|-)[0-9]{2}").string | tonumber * 3600) as $timeAdj |
		(.startDate | sub("(?<=:[0-9]{2})(\\+|-).*"; "Z") | fromdate - $timeAdj) as $utcStartDate |
		(.endDate | if . then (sub("(?<=:[0-9]{2})(\\+|-).*"; "Z") | fromdate - $timeAdj) else false end) as $utcEndDate |
		(.status == "CANCELLED") as $isCancelled |
		(if (($isCancelled|not) and now >= $utcStartDate and now < $utcEndDate) then "Now"+" "*8 else false end) as $isNow |
		(if (($isCancelled|not) and now > $utcEndDate) then "Done"+" "*7 else false end) as $isDone |
		((if ($showDoneTime != 1) then $isDone else false end) // (if ($showNowTime != 1) then $isNow else false end) // ($utcStartDate | strflocaltime("%H:%M") | .+" "*(if (gsub("[^1]";"")|length > 1) then 7 else 6 end))) as $localStartTime |
		(.eventUnitName + (.locationShortDescription | if contains("Sheet") then " - "+. else "" end)) as $evtDesc |
		(.competitors.[0] | if (.code == "TBD") then .code else $nocDict[].emoji."\(.noc)" + " \(.name) \(if ($spoilSchedule == 1 and .results.winnerLoserTie == "W") then "✓" else "" end)" end) as $noc0 |
		(.competitors.[1] | if (.code == "TBD") then .code else $nocDict[].emoji."\(.noc)" + " \(.name) \(if ($spoilSchedule == 1 and .results.winnerLoserTie == "W") then "✓" else "" end)" end) as $noc1 |
		(($spoilSchedule == 0 and (.phaseCode | contains("QUAL") or contains("FNL"))) | not) as $notSpoiler |
		{
			"title": "\($localStartTime)\(.disciplineName)\(if $isCancelled then "  –  Cancelled" elif ($notSpoiler and .eventType == "TEAM" and (.competitors | length == 2)) then "   –   \($noc0)  /  \($noc1)" else "" end)",
			"subtitle": "\($utcStartDate | strflocaltime("%b %d") + " "*12)\(if (.medalFlag > 0) then "🏅 " else "" end)\($evtDesc)",
			"arg": .id,
			"match": [
                .disciplineName, $evtDesc,
                (if ($notSpoiler or $spoilSearch == 1) then (.competitors | select(.) | unique_by(.noc) | $nocDict[].names."\(.[].noc)") else "" end),
                ($utcStartDate | strflocaltime("\"%b %d\" \"%b %e\"")),
                (if $isCancelled then "Cancelled" else "" end),
                (if (.medalFlag > 0) then "medal" else "" end),
                (if ($isNow) then "live now" elif ($isDone) then "finished done" else "upcoming" end)
            ] | map(select(.)) | join(" "),
			"icon": { "path": "images/sports/\(.disciplineCode)\(if $isCancelled then "cancelled" elif $isNow then "live" elif $isDone then "done" else "" end).png" },
			"variables": { "stale": ((now - $utcStartDate) > (12*3600)) },
			"mods": {"alt": {
			    "subtitle":($utcStartDate | strflocaltime("%b %d")+" "*12+"⌥↩ \(if ($showOldEvents == 1) then "Hide" else "Show" end) old events"),
				"variables": { "showOldEvents":($showOldEvents == 1 | not) }
			}}
		}) | (if ($showOldEvents == 1 or isempty(.[] | select(.variables.stale | not))) then . else [.[] | select(.variables.stale | not)] end)
	else
		[{
			"title": "No Schedule Found",
			"subtitle": "Press ↩ to load the schedule for the current year",
			"arg": "reload"
		}]
	end)
}' "${schedule_file}"