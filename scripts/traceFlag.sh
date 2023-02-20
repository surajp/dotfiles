#!/usr/bin/env bash
set -euo pipefail

usage="./traceFlag.sh <traced user name>(defaults to 'System') <trace interval in minutes>(defaults to 30 minutes)"
if [[ $# > 0 && ($1 = "-h" || $1 = "-help") ]]; then
	echo $usage
	exit 0
fi
tracedUserName=${1:-System}
traceInterval=${2:-30}
echo "tracing $tracedUserName for $traceInterval minutes"
if [[ $tracedUserName == *"@"* ]]; then # if the name contains '@' we query against the username. else, name
	userId=$(sfdx data:query -q "select Id from user where username='$tracedUserName'" --json | jq -r '.result.records[0].Id')
else
	userId=$(sfdx data:query -q "select Id from user where name='$tracedUserName'" --json | jq -r '.result.records[0].Id')
fi
if [[ $userId != "005"* ]]; then
	echo "Failed to find user $tracedUserName"
	exit 1
fi
debugLevelId=$(sfdx data:query -q "select id from debuglevel where Developername='SFDC_DevConsole'" -t --json | jq -r '.result.records[0].Id')
startDate=$(date +"%Y-%m-%dT%H:%M:%S%z")
expirationDate=$(date -d "$startDate +$traceInterval minutes" +"%Y-%m-%dT%H:%M:%S%z")
sfdx data:create:record -s TraceFlag -v "DebugLevelId='$debugLevelId' LogType='USER_DEBUG' TracedEntityId='$userId' startDate=$startDate expirationDate=$expirationDate" -t
