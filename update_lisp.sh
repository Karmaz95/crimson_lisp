#!/bin/bash
wget -nv -i <(curl -s https://api.github.com/repos/carlospolop/PEASS-ng/releases/latest | jq -r '.assets[].browser_download_url' | grep linpeas.sh)
mv linpeas.sh tools/linpeas.sh
