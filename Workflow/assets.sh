#!/bin/zsh --no-rcs

# Helper functions for generating workflow assets

generateNocDict() {
    nocs_file="${HOME}/Downloads/nocs.json"

    jq '{ "emoji": [.nocs[] | { (.id): .name}] | add, "names": [.nocs[] | { (.id): .name}] | add }' "${nocs_file}"
}
downloadIcons() {
    competition_file="${HOME}/Downloads/competitions.json"
    download_dir="${HOME}/Downloads/icons"

    mkdir -p "${download_dir}"
    icons=($(jq -r '"https://gstatic.olympics.com/s3/mc2026/pictograms/oly/dark/big/" + .Data[].Disciplines[].DisciplineCode + ".svg"' "${competition_file}"))
    curl -f --compressed --parallel --output-dir "${download_dir}" --remote-name-all -L "${icons[@]}"
}

generateNocDict