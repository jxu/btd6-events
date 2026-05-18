#!/usr/bin/env bash
set -euo pipefail

# unified downloader function
download_all() {
    local api_url="$1"
    local outdir="$2"
    local jq_expr="$3"  # special jq expr to format curl config

    mkdir -p "$outdir"

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

# specific API fields to use
 
download_bosses() {
    download_all \
        "https://data.ninjakiwi.com/btd6/bosses" \
        "bosses" \
        '.body[] |
         .leaderboard_standard_players_1,
         .leaderboard_elite_players_1,
         .metadataStandard,
         .metadataElite |
         "url = "+.,
         "output = "+((./"/")[4:] | join("/"))+".json"'
}

download_races() {
    download_all \
        "https://data.ninjakiwi.com/btd6/races" \
        "races" \
        '.body[] |
         .leaderboard,
         .metadata |
         "url = "+.,
         "output = "+((./"/")[4:] | join("/"))+".json"'
}

download_odyssey() {
    download_all \
        "https://data.ninjakiwi.com/btd6/odyssey" \
        "odyssey" \
        '.body[] |
         .metadata_easy,
         .metadata_medium,
         .metadata_hard |
         "url = "+.,
         "output = "+((./"/")[4:] | join("/"))+".json"'
}

# for fun: user input
case "${1:-}" in
    bosses)     download_bosses ;;
    races)      download_races ;;
    odyssey)    download_odyssey ;;
    *)
        echo "Usage: $0 {bosses|races|odyssey}"
        exit 1
        ;;
esac

