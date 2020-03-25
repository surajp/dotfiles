#!/bin/bash
# set strict mode
set -euo pipefail
IFS=$'\n\t'

#remove existing schema file
if [ -f schema.txt ]
then
  rm schema.txt
fi

# We can't query all standard fields in a single tooling api query. Hence, we loop. Add/remove objects to 'standard_objects.txt' as required
while read objectname
do
  sfdx force:data:soql:query -q "select developername from entityparticle where entitydefinitionid='$objectname'" -t -r csv >> schema.txt
done < standard_objects.txt

# Get custom fields
sfdx force:data:soql:query -q "Select developername from customfield" -t -r csv >> schema.txt

#sort and uniq in place
sort -u -o schema.txt schema.txt

#add schema.txt to your vim dictionary using
#set dictionary+=<your pwd path>/schema.txt
#for autocomplete from dictionary use <Ctrl-X><Ctrl-k> in insert mode
