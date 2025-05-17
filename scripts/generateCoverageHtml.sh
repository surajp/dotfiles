#!/usr/bin/env bash

if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
  echo "Usage: $0 [path_to_json_file]"
  echo "Generates an HTML report from a JSON code coverage file."
  echo "If no file is specified, it defaults to './test-result-codecoverage.json'."
  exit 0
fi

coverage_file=${1:-"./test-result-codecoverage.json"}

jq -r '
def uncovered_lines:
  [.lines | to_entries[] | select(.value == 0) | .key] | sort_by(tonumber) | join(", ");

"<!DOCTYPE html>
<html>
<head>
    <meta charset=\"UTF-8\">
    <title>Code Coverage Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        table { border-collapse: collapse; width: 100%; margin-top: 20px; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        .high-coverage { background-color: #d4edda; }
        .medium-coverage { background-color: #fff3cd; }
        .low-coverage { background-color: #f8d7da; }
        .uncovered-lines { font-family: monospace; font-size: 0.9em; }
    </style>
</head>
<body>
    <h1>Code Coverage Report</h1>
    <table>
        <thead>
            <tr>
                <th>Class Name</th>
                <th>Coverage %</th>
                <th>Lines Covered</th>
                <th>Total Lines</th>
                <th>Uncovered Lines</th>
            </tr>
        </thead>
        <tbody>" +
(map(
    "<tr class=\"" + 
    (if .coveredPercent >= 80 then "high-coverage" 
     elif .coveredPercent >= 60 then "medium-coverage" 
     else "low-coverage" end) + "\">
        <td>" + .name + "</td>
        <td>" + (.coveredPercent | tostring) + "%</td>
        <td>" + (.totalCovered | tostring) + "</td>
        <td>" + (.totalLines | tostring) + "</td>
        <td class=\"uncovered-lines\">" + uncovered_lines + "</td>
    </tr>"
) | join("")) +
"        </tbody>
    </table>
</body>
</html>"
' "$coverage_file" > coverage-report.html
