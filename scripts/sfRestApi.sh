#!/usr/bin/env bash
set -euo pipefail

# A script for invoking SF REST APIs using session id from sfdx

if [[ $# = 0 || $1 = "-h" || $1 = "-help" ]]; then
	echo "Usage: $(basename $0) <org username/alias> <path starting from '/data' or '/apexrest'> <additional request info>"
	exit 1
fi

orgName=$1
path=${2#\/} #remove any leading slash. we'll add it ourselves
path=$(echo $path | sed 's/ /%20/g')
# path=$(echo $path | jq -sRr @uri)
request=${@:3}
json=$(sfdx force:org:display --verbose --json -u $orgName)
sessionId=$(echo $json | jq -r '.result.accessToken')
instanceUrl=$(echo $json | jq -r '.result.instanceUrl')
echo $instanceUrl/services/$path
echo $request
curl -H "Authorization: Bearer $sessionId" -H "Content-Type: application/json" -H "Accept:application/json" $request $instanceUrl/services/$path
echo "" #newline after output
