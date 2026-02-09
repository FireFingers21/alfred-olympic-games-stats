#!/bin/zsh --no-rcs

# Get files for games list
games_file="${alfred_workflow_data}/olympic-games.json"

# Auto Update
# [[ -f "${games_file}" ]] && [[ "$(date -r "${games_file}" +%s)" -lt "$(date -v -"${autoUpdate}"M +%s)" ]] && reload=$(./scripts/reload.sh)

# Load Olympic Games
jq -s \
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
			"variables": {
			    "game": "https://bff-api.olympics.com/bff/api/usdm/v1/competitions/\(.slug)?languageCode=EN",
				"name": "\(.title) \(.season) Olympics"
			}
		})
	else
		[{
			"title": "No Games Found",
			"subtitle": "Press ↩ to load Olympic Games",
			"arg": "reload"
		}]
	end)
}' "${games_file}"