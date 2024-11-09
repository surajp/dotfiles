#!/usr/bin/env zsh
set -euo pipefail

usage="./traceFlag.sh <traced user name>(defaults to 'System')  <trace interval in minutes>(defaults to 30 minutes) <target org>"
if [[ $# > 0 && ($1 = "-h" || $1 = "-help") ]]; then
	echo $usage
	exit 0
fi
tracedUserName=${1:-System}
traceInterval=${2:-30}
targetOrg=${3:-$(sfdx force:config:get target-org --json | jq -r '.result[0].value')}
if [[ "$targetOrg" = "null" ]]; then
	echo "No target orgs found"
	exit 1
fi
echo "tracing $tracedUserName for $traceInterval minutes in $targetOrg"
if [[ $tracedUserName == *"@"* ]]; then # if the name contains '@' we query against the username. else, name
	userId=$(sfdx data:query -q "select Id from user where username='$tracedUserName'" -o $targetOrg --json | jq -r '.result.records[0].Id')
else
	userId=$(sfdx data:query -q "select Id from user where name='$tracedUserName'" -o $targetOrg --json | jq -r '.result.records[0].Id')
fi
if [[ $userId != "005"* ]]; then
	echo "Failed to find user $tracedUserName"
	exit 1
fi
debugLevelId=$(sfdx data:query -q "select id from debuglevel where Developername='SFDC_DevConsole'" -o $targetOrg -t --json | jq -r '.result.records[0].Id')
startDate=$(date +"%Y-%m-%dT%H:%M:%S%z")
expirationDate=$(date -v "+$traceInterval""M" +"%Y-%m-%dT%H:%M:%S%z")
echo $expirationDate
sfdx data:create:record -o $targetOrg -s TraceFlag -v "DebugLevelId='$debugLevelId' LogType='USER_DEBUG' TracedEntityId='$userId' startDate=$startDate expirationDate=$expirationDate" -t
