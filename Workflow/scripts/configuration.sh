#!/bin/zsh --no-rcs

# Paralympic check
[[ "${alfred_workflow_keyword}" == "${schedule_keyword_para}"* ]] && para=1 && schedule_keyword="${schedule_keyword_para}"

# Set variables for current games
source "games.env"

# Get lastest cache timestamp
readonly lastUpdated=$(date -r "${alfred_workflow_data}/${year}/${para:+para/}schedule.json" +"%A, %B %d %Y at %I:%M%p" || printf "Never")

cat << EOB
{"items": [
	{
		"title": "Reload Schedule",
		"subtitle": "Last Updated: ${lastUpdated}",
		"variables": { "pref_id": "reload", "keyword": "${schedule_keyword}" }
	},
	{
		"title": "Open Schedule in Browser",
		"arg": "${baseUrl}/${para:+paralympic-games/}schedule",
		"variables": { "pref_id": "open" }
	},
	{
		"title": "Configure Workflow...",
		"subtitle": "Open the configuration window for ${alfred_workflow_name}",
		"variables": { "pref_id": "configure" }
	}
]}
EOB