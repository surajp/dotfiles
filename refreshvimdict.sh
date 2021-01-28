#!/bin/bash
# set strict mode
set -euo pipefail
IFS=$'\n\t'

#remove existing schema file
if [ -f schema.txt ]
then
  rm schema.txt
fi

if [ -f objects.txt ]
then
  rm objects.txt
fi

if [[ ! -f "./standard_objects.txt" ]]; then
  wget https://gist.githubusercontent.com/surajp/097965584eaa770d2dca687e66dec4f9/raw/616fce345b2d1e08733fe130d0ee3cef37b562d9/sf_standard_objects.txt
  wget https://gist.githubusercontent.com/surajp/75e4b283479e066e2044b7208f8f980d/raw/3a2845b7303885479cec04e12036e761783b69a8/sf_standard_schema.txt
  mv sf_standard_objects.txt objects.txt
  mv sf_standard_schema.txt schema.txt
  if [[ -f "./standard_objects_extended.txt" ]]; then
    while read objectname
    do
      sfdx force:data:soql:query -q "select name,entitydefinitionid from entityparticle where entitydefinitionid='$objectname'" -t -r csv >> schema.txt
    done < standard_objects_extended.txt
  fi
else
  # We can't query all standard fields in a single tooling api query. Hence, we loop. Add/remove objects to 'standard_objects.txt' as required
  while read objectname
  do
    sfdx force:data:soql:query -q "select name,entitydefinitionid from entityparticle where entitydefinitionid='$objectname'" -t -r csv >> schema.txt
  done < standard_objects.txt
  cat standard_objects.txt > objects.txt
fi

sfdx force:schema:sobject:list -c custom > custom_objects.txt

while read objectname
do
  sfdx force:data:soql:query -q "select name,entitydefinitionid from entityparticle where entitydefinitionid='$objectname'" -t -r csv >> schema.txt
  sed -i "s/01I[^ ]*/$objectname/g" schema.txt
done < custom_objects.txt

cat custom_objects.txt >> objects.txt

# Get custom fields
# sfdx force:data:soql:query -q "Select developername,TableEnumOrId from customfield" -t -r csv >> schema.txt

cat schema.txt | awk -F ',' '{len=length($1);i=0;while(i<40-len){$1=$1" ";i++};print $1$2}' > schema1.txt

mv schema1.txt schema.txt

#sort and uniq in place
sort -u -o schema.txt schema.txt

#add schema.txt to your vim dictionary using
#set dictionary+=<your pwd path>/schema.txt
#for autocomplete from dictionary use <Ctrl-X><Ctrl-k> in insert mode
