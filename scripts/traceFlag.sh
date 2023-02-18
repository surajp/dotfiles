#!/usr/bin/env bash
set -euo pipefail
usage="./traceFlag.sh <traced user name>(defaults to 'System') <trace interval in minutes>(defaults to 30 minutes)"
if [[ $# = 0 || $1 = "-h" || $1 = "-help" ]]; then
	echo $usage
	exit 0
fi
tracedUserName=${1:-System}
traceInterval=${2:-30}
echo "tracing $tracedUserName for $traceInterval minutes"
userId=$(sfdx force:data:soql:query -q "select Id from user where name='$tracedUserName'" --json | jq -r '.result.records[0].Id')
debugLevelId=$(sfdx force:data:soql:query -q "select id from debuglevel where Developername='SFDC_DevConsole'" -t --json | jq -r '.result.records[0].Id')
startDate=$(date +"%Y-%m-%dT%H:%M:%S%z")
expirationDate=$(date -d "$startDate +$traceInterval minutes" +"%Y-%m-%dT%H:%M:%S%z")
sfdx force:data:record:create -s TraceFlag -v "DebugLevelId='$debugLevelId' LogType='USER_DEBUG' TracedEntityId='$userId' startDate=$startDate expirationDate=$expirationDate" -t
