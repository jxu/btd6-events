#!/bin/sh
mkdir -p bosses
curl https://data.ninjakiwi.com/btd6/bosses |
tee bosses/bosses$(date +%Y%m%d).json |
jq -r '.body[] | .leaderboard_standard_players_1, .leaderboard_elite_players_1, .metadataStandard | 
"url = "+., "output = "+((./"/")[4:] | join("/"))+".json"' |
curl -Z -K - --create-dirs
