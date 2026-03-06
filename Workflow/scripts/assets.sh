#!/bin/zsh --no-rcs

# Helper functions for generating workflow assets

generateNocDict() {
    # nocs file URL: "https://www.olympics.com/wmr-owg2026/info/api/ENG/nocs"
    nocs_file="${HOME}/Downloads/nocs.json"

    jq '{ "emoji": [.nocs[] | { (.id): .name}] | add, "names": [.nocs[] | { (.id): .name}] | add }' "${nocs_file}"
}
downloadIcons() {
    # competition file URL: "https://www.olympics.com/wmr-api/api/v2/competitions?competitionCode=OWG2026&languageCode=ENG"
    competition_file="${HOME}/Downloads/competitions.json"
    download_dir="${HOME}/Downloads/Olympic Icons"

    mkdir -p "${download_dir}"
    # Olympic
    # icons=($(jq -r '"https://gstatic.olympics.com/s3/mc2026/pictograms/oly/dark/big/" + .Data[].Disciplines[].DisciplineCode + ".svg"' "${competition_file}"))
    # Paralympic
    icons=($(jq -r '"https://gstatic.olympics.com/s3/mc2026/pictograms/para/dark/big/" + .Data[].Disciplines[].DisciplineCode + ".svg"' "${competition_file}"))
    curl -f --compressed --parallel --output-dir "${download_dir}" --remote-name-all -L "${icons[@]}"
}

# generateNocDict
downloadIcons