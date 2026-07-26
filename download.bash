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
        jq . |  # pretty-print output
        tee "$outdir/${outdir}$(date +%Y%m%d).json" |
        jq -r "$jq_expr"
    )

    # for debug
    echo "$curlconfig"

    # download curlconfig JSON URLs
    curl -Z --config - --create-dirs <<< "$curlconfig"

    # pretty-print and overwrite JSON files
    echo "$curlconfig" |
    grep '^output =' |
    cut -d= -f2 |
    xargs -I{} sh -c 'jq . "{}" | sponge "{}"'
}


# For fun: read user input
# For each API, only the fields change.
# Due to the API returning zero scores for too old leaderboards (issue #2),
# bosses and races use a jq expression for fields to avoid overwriting
# with empty leaderboard
case "${1:-}" in
    bosses)
        download_all \
            "https://data.ninjakiwi.com/btd6/bosses" \
            "bosses" \
            '(if .totalScores_standard > 0 then .leaderboard_standard_players_1 else empty end),
             (if .totalScores_elite > 0 then .leaderboard_elite_players_1 else empty end),
             .metadataStandard,
             .metadataElite'
        ;;
    races)
        download_all \
            "https://data.ninjakiwi.com/btd6/races" \
            "races" \
            '(if .totalScores > 0 then .leaderboard else empty end),
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

