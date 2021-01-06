#!/usr/bin/env bash
if [ $# -eq 1 ]
then
	java -jar ~/libs/google-java-format-1.9-all-deps.jar --replace "$1"
else
	echo "Missing file argument"
fi
