#!/usr/bin/env bash
set -euo pipefail

# one downloader function to rule them all
download_all() {
    local api_url="$1"
    local outdir="$2"
    local fields="$3"  # API JSON fields to further download

    mkdir -p "$outdir"

    # output jq magic trims URL path to end part
    local jq_expr='
        .body[] |
        '"$fields"' |
        "url = " + .,
        "output = "+((./"/")[4:] | join("/")) + ".json"
    '

    # fetch index JSON and generate curl config string
    local curlconfig
    curlconfig=$(
        curl "$api_url" |
        tee "$outdir/${outdir}$(date +%Y%m%d).json" |
        jq -r "$jq_expr"
    )

    # for debug
    echo "$curlconfig"

    # download curlconfig JSON URLs
    echo "$curlconfig" | 
    curl -Z --config - --create-dirs

    # pretty-print and overwrite JSON files
    echo "$curlconfig" |
    grep '^output =' |
    cut -d= -f2 |
    xargs -I{} sh -c 'jq . "{}" | sponge "{}"'
}


# for fun: user input
# for each API, only the fields change
case "${1:-}" in
    bosses)
        download_all \
            "https://data.ninjakiwi.com/btd6/bosses" \
            "bosses" \
            '.leaderboard_standard_players_1,
             .leaderboard_elite_players_1,
             .metadataStandard,
             .metadataElite'
        ;;
    races)
        download_all \
            "https://data.ninjakiwi.com/btd6/races" \
            "races" \
            '.leaderboard,
             .metadata'
        ;;
    odyssey)
        download_all \
            "https://data.ninjakiwi.com/btd6/odyssey" \
            "odyssey" \
            '.metadata_easy,
             .metadata_medium,
             .metadata_hard'
        ;;
    *)
        echo "Usage: $0 {bosses|races|odyssey}"
        exit 1
        ;;
esac

