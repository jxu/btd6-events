#!/bin/sh
mkdir races
curl https://data.ninjakiwi.com/btd6/races > races/races$(date +%Y%m%d).json

curl https://data.ninjakiwi.com/btd6/races |
jq -r '.body[] | .leaderboard, .metadata | "url = "+., "output = "+((./"/")[-3:] | join("/"))+".json"' |
curl -Z -K - --create-dirs
