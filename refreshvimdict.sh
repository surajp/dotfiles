#!/bin/bash
# set strict mode
set -euo pipefail
IFS=$'\n\t'

#remove existing schema file
if [ -f schema.txt ]
then
  rm schema.txt
fi

sfdx force:schema:sobject:list -c custom > custom_objects.txt

# We can't query all standard fields in a single tooling api query. Hence, we loop. Add/remove objects to 'standard_objects.txt' as required
while read objectname
do
  sfdx force:data:soql:query -q "select name,entitydefinitionid from entityparticle where entitydefinitionid='$objectname'" -t -r csv >> schema.txt
done < standard_objects.txt

while read objectname
do
  sfdx force:data:soql:query -q "select name,entitydefinitionid from entityparticle where entitydefinitionid='$objectname'" -t -r csv >> schema.txt
  sed -i "s/01I[^ ]*/$objectname/g" schema.txt
done < custom_objects.txt

# Get custom fields
# sfdx force:data:soql:query -q "Select developername,TableEnumOrId from customfield" -t -r csv >> schema.txt

#sort and uniq in place
sort -u -o schema.txt schema.txt

cat schema.txt | awk -F ',' '{len=length($1);i=0;while(i<40-len){$1=$1" ";i++};print $1$2}' > schema1.txt

mv schema1.txt schema.txt

#add schema.txt to your vim dictionary using
#set dictionary+=<your pwd path>/schema.txt
#for autocomplete from dictionary use <Ctrl-X><Ctrl-k> in insert mode
