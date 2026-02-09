#!/bin/zsh --no-rcs

# Set variables for current games
medals_file="${alfred_workflow_data}/2026/medals.json"

# Get age of medals_file in minutes
[[ -f "${medals_file}" ]] && minutes="$((($(date +%s)-$(date -r "${medals_file}" +%s))/60))"

# Download Medals Data
if [[ "${forceReload}" -eq 1 || "$(date -r "${medals_file}" +%s)" -lt "$(date -v -"${autoUpdate}"M +%s)" ]]; then
    # https://img.olympics.com/images/image/private/t_1-1_64/primary/f7v9edfa6utluhwnxcyq
    # Rate limit to only refresh if data is older than 1 minute
    [[ "${minutes}" -gt 0 || -z "${minutes}" ]] && curl -sf --compressed --connect-timeout 10 \
        -L "https://www.olympics.com/wmr-owg2026/competition/api/ENG/medals" -o "${medals_file}" \
        -A "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:147.0) Gecko/20100101 Firefox/147.0" \
    && minutes=0
fi

# Format Last Updated Time
if [[ ! -f "${medals_file}" || ${minutes} -eq 0 ]]; then
    lastUpdated="Just now"
elif [[ ${minutes} -eq 1 ]]; then
    lastUpdated="${minutes} minute ago"
elif [[ ${minutes} -lt 60 ]]; then
    lastUpdated="${minutes} minutes ago"
elif [[ ${minutes} -ge 60 && ${minutes} -lt 120 ]]; then
    lastUpdated="$((${minutes}/60)) hour ago"
elif [[ ${minutes} -ge 120 && ${minutes} -lt 1440 ]]; then
    lastUpdated="$((${minutes}/60)) hours ago"
else
    lastUpdated="$(date -r "${medals_file}" +'%Y-%m-%d')"
fi

# Format Data to Markdown
mdOutput=$(jq -crs --arg name "${name}" --slurpfile nocDict "nocDict.json" \
'(
    "![Sport Icon](images/sports/small/CER.png)\n",
    "# \($name)",
    "***",
    "### Medal Table",
    "```",
    "Order" + (" "*4) + "NOC" + (" "*24) + "🥇  🥈   🥉    Total"
),
(.[].medalStandings.medalsTable[] |
    (" "*4) +
    ("\(.rank)" | .+" "*(5-length)) +
    $nocDict[].emoji."\(.organisation)" + " " +
    ("\(.description)" | .+" "*(24-length)) +
    ("\(.medalsNumber[-1].gold)" | .+" "*(5-length)) +
    ("\(.medalsNumber[-1].silver)" | .+" "*(5-length)) +
    ("\(.medalsNumber[-1].bronze)" | .+" "*(6-length)) +
    ("\(.medalsNumber[-1].total)")
),
(
    "```",
    "\n**Completed Events:**  \(.[].medalStandings.eventInfo.finishedEvents) of \(.[].medalStandings.eventInfo.totalEvents)"
)' "${medals_file}" | sed 's/\"/\\"/g')

# Output Formatted Data to Text View
cat << EOB
{
    "variables": { "forceReload": 1 },
    "response": "${mdOutput//$'\n'/\n}",
    "footer": "Last Updated: ${lastUpdated}            ⌥↩ Update Now   ·   ⌘↩ Open in Browser"
}
EOB