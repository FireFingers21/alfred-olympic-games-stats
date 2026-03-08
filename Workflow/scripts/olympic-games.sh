#!/bin/zsh --no-rcs

# Set variables for current games
source "games.env"
games_file="${alfred_workflow_data}/olympic-games.json"

# Auto Update
[[ -f "${games_file}" ]] && [[ "$(date -r "${games_file}" +%s)" -lt "$(date -v -6m +%s)" ]] \
&& curl -sf --compressed --connect-timeout 10 \
    -L "https://www.olympics.com/en/api/v1/b2p/menu/topbar/olympic-games" -o "${games_file}" \
    -A "${userAgent}" \

# Load Olympic Games
jq -cs --argjson year "${year}" \
'{
    "variables": { "keyword": "'${alfred_workflow_keyword}'" },
    "skipknowledge": true,
	"items": (if (length != 0) then
		.[].modules[-1].content | map(
		select((.year|tonumber <= $year) and (.season == "Winter" or .season == "Summer")) |
		(.year|tonumber == $year) as $currentYear |
		select(.slug == "milano-cortina-2026") |
		{
			"title": .title,
			"arg": .slug,
			"icon": { "path": "images/sports/CER.png" },
			"variables": {
			    "name": "\(.title) \(.season) Olympics",
				"url": "\(.url)/medals",
				"browser": ($currentYear | not),
			},
			"mods": { "cmd": {
			    "subtitle":"⌘↩ Open in Browser",
				"variables": {
				    "browser": true,
					"url": "\(.url)/medals"
				}
			}}
		},
		{
			"title": "\(.title) Paralympics",
			"arg": .slug,
			"icon": { "path": "images/parasports/CER.png" },
			"variables": {
			    "name": "\(.title) \(.season) Paralympics",
				"url": "\(.url)/paralympic-games/medals",
				"browser": ($currentYear | not),
				"para": 1
			},
			"mods": { "cmd": {
			    "subtitle":"⌘↩ Open in Browser",
				"variables": {
				    "browser": true,
					"url": "\(.url)/paralympic-games/medals"
				}
			}}
		})
	else
		[{
			"title": "No Games Found",
			"subtitle": "Press ↩ to load Olympic Games",
			"arg": "reload"
		}]
	end)
}' "${games_file}"