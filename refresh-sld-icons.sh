#!/usr/bin/env bash
set -euo pipefail

rm -r /tmp/slds-icons || echo "..."
mkdir /tmp/slds-icons
cd /tmp/slds-icons
wget https://www.lightningdesignsystem.com/assets/downloads/salesforce-lightning-design-system-icons.zip
unzip *.zip
rm *.zip
find -E . -type f -name "*.png" | tr -d '_1206' | sed 's/.png//' | sort | uniq | awk -F "/" '{print $2":"$3}' > $HOME/lib/.sldsicons.txt
cd -
rm -r /tmp/slds-icons
