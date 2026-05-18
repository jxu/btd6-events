#!/bin/sh

mkdir -p bosses

# download links from NK API and store in curl config format
curlconfig=$(
    curl https://data.ninjakiwi.com/btd6/bosses |
    tee "bosses/bosses$(date +%Y%m%d).json" |
    jq -r '.body[] | .leaderboard_standard_players_1, .leaderboard_elite_players_1, .metadataStandard, .metadataElite | 
    "url = "+., "output = "+((./"/")[4:] | join("/"))+".json"'
)

# run curl with config passed in
echo "$curlconfig" | curl -Z --config - --create-dirs

# pretty-print JSON files, overwriting them
echo "$curlconfig" | grep '^output =' | cut -d= -f2 |
    xargs -I{} sh -c 'jq . "{}" | sponge "{}"'
