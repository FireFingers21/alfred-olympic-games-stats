#!/bin/zsh --no-rcs

# Get files for games list
games_file="${alfred_workflow_data}/olympic-games.json"

# Auto Update
# [[ -f "${games_file}" ]] && [[ "$(date -r "${games_file}" +%s)" -lt "$(date -v -"${autoUpdate}"M +%s)" ]] && reload=$(./scripts/reload.sh "${+para}")

# Load Olympic Games
jq -cs \
'{
    "variables": { "keyword": "'${alfred_workflow_keyword}'" },
    "skipknowledge": true,
	"items": (if (length != 0) then
		.[].modules[-1].content | map(
		select((.year|tonumber <= (now|strftime("%Y")|tonumber)) and (.season == "Winter" or .season == "Summer")) |
		select(.slug == "milano-cortina-2026") |
		{
			"title": .title,
			"arg": .slug,
			"icon": { "path": "images/sports/CER.png" },
			"variables": { "name": "\(.title) \(.season) Olympics" }
		},
		{
			"title": "\(.title) Paralympics",
			"arg": .slug,
			"icon": { "path": "images/parasports/CER.png" },
			"variables": { "name": "\(.title) \(.season) Paralympics", "para": 1 }
		})
	else
		[{
			"title": "No Games Found",
			"subtitle": "Press ↩ to load Olympic Games",
			"arg": "reload"
		}]
	end)
}' "${games_file}"