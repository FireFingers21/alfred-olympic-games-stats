#!/bin/zsh --no-rcs

# Set variables for current games
baseUrl="https://www.olympics.com/en/milano-cortina-2026/results"
schedule_file="${alfred_workflow_data}/2026/schedule.json"
id="${1}"

getLink() {
jq -r --arg query "${id}" \
      --arg baseUrl "${baseUrl}" \
'([.groups[].unitId]) as $groupPhaseName |
.units[] | select(.id == $query) |
    "\($baseUrl)/" +
    "\(.disciplineCode)/" +
    (
        if ((["BTH","FSK","SJP"] as $d | .disciplineCode | IN($d[])) and (.eventType | . == "TEAM" or . == "DGRP")) then "te/"
        elif (.eventCode | contains("TC")) then "tc/"
        elif (.eventName | contains("Team Relay")) then "tr/"
        elif (.eventCode | contains("RY4-")) then "tr/"
        elif (.eventCode | contains("TEAMPU") or contains("TEAMSP")) then "tp/"
        elif (.eventCode | contains("SX-") or contains("SBX-")) then "sx/"
        elif (.eventCode | contains("XT")) then "xt/"
        elif (.id | contains("SSKWMS") or contains("SSKMMS")) then "ms/"
        elif (.eventCode | contains("AET")) then "at/"
        elif (.eventCode | contains("AE-")) then "ae/"
        elif (.eventCode | contains("DM")) then "dm/"
        elif (.eventCode | contains("MO-")) then "mo/"
        elif (.eventCode | contains("PGS")) then "ps/"
        elif (.eventCode | contains("SPRINT")) then "sp/"
        elif (.eventCode | contains("RELAY-")) then "re/"
        elif (.eventCode | contains("ICEDANCE")) then "id/"
        elif (.eventName | contains("Single Skating")) then "ss/"
        elif (.eventName | contains("Pair Skating")) then "prs/"
        elif (.eventCode | contains("SL") or contains("GS")) then "sl/"
        elif (.disciplineCode == "CCS") then (.eventName | (
            if contains("Interval") then "in/"
            elif contains("Relay") then "re/"
            else "ms/"
        end))
        elif (.disciplineCode == "NCB") then (.eventType | (
            if (. == "DGRP") then "tg"
            elif (. == "INDV") then "ig"
        end)) + (.id | (
            if (contains("SJ")) then "sj/"
            elif (contains("CC")) then "cc/"
        end))
        elif (.disciplineCode == "ALP") then "cl/"
        elif (.disciplineCode | . == "SBD" or . == "FRS") then "je/"
        elif (.disciplineCode == "SSK") then "st/"
        elif (["BTH","SJP","STK"] as $d | .disciplineCode | IN($d[])) then "in/"
        else ""
    end) +
    "\(.genderCode)/" +
    "\(.eventCode)/" +
    "\(.phaseCode)/" +
    "\(if (.groupId | if . then (contains("QUAL") or contains("FNL")) else false end) or (.id[-8:] | test("^[A-D]")) or (.id | test("00000[0-9]--$")) or (.phaseCode | contains("SEED")) or (.phaseCode | contains("QUAL") or contains("FNL")) and ("\(.sessionCode)_\(.phaseId)" | IN($groupPhaseName[])) then "--------" else .id[-8:] end)/" +
    "\(
        if (["FRS","FSK","NCB","SBD","SJP"] as $d | .disciplineCode | IN($d[])) then "result"
        elif ((["INDV","DGRP","IGRP"] as $e | .eventType | IN($e[]))) then "race-result"
        else "team-lineups"
    end)" | ascii_downcase
' "${schedule_file}"
}

open "$(getLink)"