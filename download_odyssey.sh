#!/bin/sh
mkdir -p odyssey
curl https://data.ninjakiwi.com/btd6/odyssey | 
tee odyssey/odyssey$(date +%Y%m%d).json |
jq -r '.body[] | .metadata_easy, .metadata_medium, .metadata_hard | 
"url = "+., "output = "+((./"/")[-3:] | join("/"))+".json"' |
curl -Z -K - --create-dirs
