#!/bin/zsh --no-rcs

# Set variables for helper assets
download_dir="${HOME}/Downloads/Olympic Helper Assets"
userAgent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:147.0) Gecko/20100101 Firefox/147.0"
mkdir -p "${download_dir}"

# Helper functions for generating workflow assets
generateNocDict() {
    # Set one for Olympics or Paralympics
    mode="wmr-owg2026"
    # mode="wmr-para-owg2026"

    download_dir="${download_dir}/nocs_${mode}"
    mkdir -p "${download_dir}"
    nocs_file="${download_dir}/nocs.json"
    [[ ! -f "${nocs_file}" ]] && curl -f --compressed -L "https://www.olympics.com/${mode}/info/api/ENG/nocs" -o "${nocs_file}" -A "${userAgent}"
    jq '{ "emoji": [.nocs[] | { (.id): .name}] | add, "names": [.nocs[] | { (.id): .name}] | add }' "${nocs_file}" > "${download_dir}/new_nocs.json"
}

downloadIcons() {
    # Set one for Olympics or Paralympics
    mode="oly" && competitionCode="OWG2026"
    # mode="para" && competitionCode="PWG2026"

    # Download scripts
    download_dir="${download_dir}/icons/${mode}"
    competition_file="${download_dir}/competitions.json"
    mkdir -p "${download_dir}"
    [[ ! -f "${competition_file}" ]] && curl -f --compressed -L "https://www.olympics.com/wmr-api/api/v2/competitions?competitionCode=${competitionCode}&languageCode=ENG" -o "${competition_file}" -A "${userAgent}"
    icons=($(jq -r '"https://gstatic.olympics.com/s3/mc2026/pictograms/$mode/dark/big/" + .Data[].Disciplines[].DisciplineCode + ".svg"' "${competition_file}"))
    curl -f --compressed --parallel --output-dir "${download_dir}" --remote-name-all -L "${icons[@]//\$mode/${mode}}"
}

# generateNocDict
downloadIcons