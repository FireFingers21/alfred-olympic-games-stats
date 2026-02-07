#!/bin/zsh --no-rcs

# Set variables for current games
baseUrl="https://www.olympics.com/en/milano-cortina-2026/results"
schedule_file="${alfred_workflow_data}/2026/schedule.json"
id="${1}"

getLink() {
jq -r --arg query "${id}" \
      --arg baseUrl "${baseUrl}" \
'.units[] | select(.id == $query) |
    "\($baseUrl)/" +
    "\(.disciplineCode)/" +
    (
        if ((["BTH","FSK"] as $d | .disciplineCode | IN($d[])) and (.eventType | . == "TEAM" or . == "DGRP")) then "te/"
        elif (.eventCode | contains("TC")) then "tc/"
        elif (.eventName | contains("Mixed Team Relay")) then "tr/"
        elif (.eventName == "Team Pursuit") then "tp/"
        elif (.eventCode | contains("DM")) then "dm/"
        elif (.eventCode | contains("MO")) then "mo/"
        elif (.eventCode | contains("PGS")) then "ps/"
        elif (.eventCode | contains("SPRINT")) then "sp/"
        elif (.eventCode | contains("RELAY")) then "re/"
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
    "\(
        if (["SBD","STK"] as $d | .disciplineCode | IN($d[])) then "--------"
        elif ((.disciplineCode == "FRS") and (.eventCode | contains("MO") | not)) then "--------"
        else .id[-8:]
    end)/" +
    "\(
        if (["FRS","FSK","NCB","SBD","SJP"] as $d | .disciplineCode | IN($d[])) then "result"
        elif ((.eventUnitType == "TEAM") or (["INDV","DGRP","IGRP"] as $e | .eventType | IN($e[]))) then "race-result"
        else "team-lineups"
    end)" | ascii_downcase
' "${schedule_file}"
}

open "$(getLink)"