#!/usr/bin/env bash
if [ $# -eq 1 ]
then
	~/pmd-bin-6.30.0/bin/run.sh pmd -R rulesets/apex/quickstart.xml -d "$1" -l apex
else
	echo "Missing file argument"
fi
