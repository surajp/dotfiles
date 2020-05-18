#!/usr/bin/env bash

if ! type __ltrim_colon_completions >/dev/null 2>&1; then
  #   Copyright © 2006-2008, Ian Macdonald <ian@caliban.org>
  #             © 2009-2017, Bash Completion Maintainers
  __ltrim_colon_completions() {
      # If word-to-complete contains a colon,
      # and bash-version < 4,
      # or bash-version >= 4 and COMP_WORDBREAKS contains a colon
      if [[
          "$1" == *:* && (
              ${BASH_VERSINFO[0]} -lt 4 ||
              (${BASH_VERSINFO[0]} -ge 4 && "$COMP_WORDBREAKS" == *:*)
          )
      ]]; then
          # Remove colon-word prefix from COMPREPLY items
          local colon_word=${1%${1##*:}}
          local i=${#COMPREPLY[*]}
          while [ $((--i)) -ge 0 ]; do
              COMPREPLY[$i]=${COMPREPLY[$i]#"$colon_word"}
          done
      fi
  }
fi

concat_array(){ res="";for var in "$@"; do if [[ $var == "-"* ]]; then break; else res+=$var; fi; done; echo $res; }

_sfdx()
{

  #local cur="${COMP_WORDS[COMP_CWORD]}" opts IFS=$' \t\n'
  local cur=$(concat_array ${COMP_WORDS[@]:1}) opts IFS=$' \t\n'
  COMPREPLY=()

  local commands="
force:lightning:lint --json --loglevel --ignore --files --config --verbose --exit
autocomplete --refresh-cache
force:analytics:template:create --json --loglevel --outputdir --apiversion --templatename
force:apex:class:create --json --loglevel --classname --template --outputdir --apiversion
force:apex:trigger:create --json --loglevel --triggername --template --outputdir --apiversion --sobject --triggerevents
force:lightning:app:create --json --loglevel --appname --template --outputdir --apiversion
force:lightning:component:create --json --loglevel --componentname --template --outputdir --apiversion --type
force:lightning:event:create --json --loglevel --eventname --template --outputdir --apiversion
force:lightning:interface:create --json --loglevel --interfacename --template --outputdir --apiversion
force:lightning:test:create --json --loglevel --testname --template --outputdir
force:project:create --json --loglevel --projectname --template --outputdir --namespace --defaultpackagedir --manifest
force:visualforce:component:create --json --loglevel --template --outputdir --componentname --apiversion --label
force:visualforce:page:create --json --loglevel --template --outputdir --pagename --apiversion --label
force:alias:list --json --loglevel
force:alias:set --json --loglevel
force:apex:execute --json --loglevel --targetusername --apiversion --apexcodefile
force:apex:log:get --json --loglevel --targetusername --apiversion --color --logid --number
force:apex:log:list --json --loglevel --targetusername --apiversion
force:apex:log:tail --json --loglevel --targetusername --apiversion --color --debuglevel --skiptraceflag
force:apex:test:report --json --loglevel --targetusername --apiversion --testrunid --codecoverage --outputdir --wait --verbose --resultformat
force:apex:test:run --json --loglevel --targetusername --apiversion --classnames --suitenames --tests --codecoverage --outputdir --testlevel --wait --synchronous --verbose --resultformat
force:auth:device:login --json --loglevel --clientid --instanceurl --setdefaultdevhubusername --setdefaultusername --setalias
force:auth:jwt:grant --json --loglevel --username --jwtkeyfile --clientid --instanceurl --setdefaultdevhubusername --setdefaultusername --setalias
force:auth:list --json --loglevel
force:auth:logout --json --loglevel --targetusername --apiversion --all --noprompt
force:auth:sfdxurl:store --json --loglevel --sfdxurlfile --setdefaultdevhubusername --setdefaultusername --setalias
force:auth:web:login --json --loglevel --clientid --instanceurl --setdefaultdevhubusername --setdefaultusername --setalias
force:community:create --json --loglevel --targetusername --apiversion --name --templatename --urlpathprefix --description
force:community:publish --json --loglevel --targetusername --apiversion --name
force:community:template:list --json --loglevel --targetusername --apiversion
force:config:get --json --loglevel --verbose
force:config:list --json --loglevel
force:config:set --json --loglevel --global
force:data:bulk:delete --json --loglevel --targetusername --apiversion --sobjecttype --csvfile --wait
force:data:bulk:status --json --loglevel --targetusername --apiversion --jobid --batchid
force:data:bulk:upsert --json --loglevel --targetusername --apiversion --sobjecttype --csvfile --externalid --wait
force:data:record:create --json --loglevel --targetusername --apiversion --sobjecttype --values --usetoolingapi --perflog
force:data:record:delete --json --loglevel --targetusername --apiversion --sobjecttype --sobjectid --where --usetoolingapi --perflog
force:data:record:get --json --loglevel --targetusername --apiversion --sobjecttype --sobjectid --where --usetoolingapi --perflog
force:data:record:update --json --loglevel --targetusername --apiversion --sobjecttype --sobjectid --where --values --usetoolingapi --perflog
force:data:soql:query --json --loglevel --targetusername --apiversion --query --usetoolingapi --resultformat --perflog
force:data:tree:export --json --loglevel --targetusername --apiversion --query --plan --prefix --outputdir
force:data:tree:import --json --loglevel --targetusername --apiversion --sobjecttreefiles --plan --confighelp
force:doc:commands:display --json --loglevel
force:doc:commands:list --json --loglevel --usage
force:lightning:test:install --json --loglevel --targetusername --apiversion --wait --releaseversion --packagetype
force:lightning:test:run --json --loglevel --targetusername --apiversion --appname --outputdir --configfile --leavebrowseropen --timeout --resultformat
force:limits:api:display --json --loglevel --targetusername --apiversion
force:mdapi:convert --json --loglevel --rootdir --outputdir --manifest --metadata --metadatapath
force:mdapi:deploy --json --loglevel --targetusername --apiversion --checkonly --deploydir --wait --testlevel --runtests --ignoreerrors --ignorewarnings --validateddeployrequestid --verbose --zipfile --singlepackage
force:mdapi:deploy:cancel --json --loglevel --targetusername --apiversion --wait --jobid
force:mdapi:deploy:report --json --loglevel --targetusername --apiversion --wait --jobid --verbose
force:mdapi:describemetadata --json --loglevel --targetusername --apiversion --resultfile
force:mdapi:listmetadata --json --loglevel --targetusername --apiversion --resultfile --metadatatype --folder
force:mdapi:retrieve --json --loglevel --targetusername --apiversion --wait --retrievetargetdir --unpackaged --verbose --sourcedir --packagenames --singlepackage
force:mdapi:retrieve:report --json --loglevel --targetusername --apiversion --wait --retrievetargetdir --verbose --jobid
force:org:clone --json --loglevel --targetusername --apiversion --type --definitionfile --setdefaultusername --setalias --wait
force:org:create --json --loglevel --targetdevhubusername --targetusername --apiversion --type --definitionfile --nonamespace --noancestors --clientid --setdefaultusername --setalias --wait --durationdays
force:org:delete --json --loglevel --targetdevhubusername --targetusername --apiversion --noprompt
force:org:display --json --loglevel --targetusername --apiversion --verbose
force:org:list --json --loglevel --verbose --all --clean --noprompt
force:org:open --json --loglevel --targetusername --apiversion --path --urlonly
force:org:shape:create --json --loglevel --targetusername --apiversion
force:org:shape:delete --json --loglevel --targetusername --apiversion --noprompt
force:org:shape:list --json --loglevel --verbose
force:org:snapshot:create --json --loglevel --targetdevhubusername --apiversion --sourceorg --snapshotname --description
force:org:snapshot:delete --json --loglevel --targetdevhubusername --apiversion --snapshot
force:org:snapshot:get --json --loglevel --targetdevhubusername --apiversion --snapshot
force:org:snapshot:list --json --loglevel --targetdevhubusername --apiversion
force:org:status --json --loglevel --targetusername --apiversion --sandboxname --setdefaultusername --setalias --wait
force:package1:version:create --json --loglevel --targetusername --apiversion --packageid --name --description --version --managedreleased --releasenotesurl --postinstallurl --installationkey --wait
force:package1:version:create:get --json --loglevel --targetusername --apiversion --requestid
force:package1:version:display --json --loglevel --targetusername --apiversion --packageversionid
force:package1:version:list --json --loglevel --targetusername --apiversion --packageid
force:package:create --json --loglevel --targetdevhubusername --apiversion --name --packagetype --description --nonamespace --path
force:package:hammertest:list --json --loglevel --targetusername --apiversion --packageversionid
force:package:hammertest:report --json --loglevel --targetusername --apiversion --requestid --summary
force:package:hammertest:run --json --loglevel --targetusername --apiversion --packageversionids --subscriberorgs --subscriberfile --scheduledrundatetime --preview --apextests --apextestinterface
force:package:install --json --loglevel --targetusername --apiversion --wait --installationkey --publishwait --noprompt --package --apexcompile --securitytype --upgradetype
force:package:install:report --json --loglevel --targetusername --apiversion --requestid
force:package:installed:list --json --loglevel --targetusername --apiversion
force:package:list --json --loglevel --targetdevhubusername --apiversion --verbose
force:package:uninstall --json --loglevel --targetusername --apiversion --wait --package
force:package:uninstall:report --json --loglevel --targetusername --apiversion --requestid
force:package:update --json --loglevel --targetdevhubusername --apiversion --package --name --description
force:package:version:create --json --loglevel --targetdevhubusername --apiversion --package --path --definitionfile --branch --tag --installationkey --installationkeybypass --wait --versionname --versionnumber --versiondescription --codecoverage --releasenotesurl --postinstallurl --postinstallscript --uninstallscript --skipvalidation
force:package:version:create:list --json --loglevel --targetdevhubusername --apiversion --createdlastdays --status
force:package:version:create:report --json --loglevel --targetdevhubusername --apiversion --packagecreaterequestid
force:package:version:list --json --loglevel --targetdevhubusername --apiversion --createdlastdays --concise --modifiedlastdays --packages --released --orderby --verbose
force:package:version:promote --json --loglevel --targetdevhubusername --apiversion --package --noprompt
force:package:version:report --json --loglevel --targetdevhubusername --apiversion --package --verbose
force:package:version:update --json --loglevel --targetdevhubusername --apiversion --package --versionname --versiondescription --branch --tag --installationkey
force:project:upgrade --json --loglevel --forceupgrade
force:schema:sobject:describe --json --loglevel --targetusername --apiversion --sobjecttype --usetoolingapi
force:schema:sobject:list --json --loglevel --targetusername --apiversion --sobjecttypecategory
force:source:convert --json --loglevel --rootdir --outputdir --packagename --manifest --sourcepath --metadata
force:source:delete --json --loglevel --targetusername --apiversion --checkonly --noprompt --wait --sourcepath --metadata
force:source:deploy --json --loglevel --targetusername --apiversion --checkonly --wait --testlevel --runtests --ignoreerrors --ignorewarnings --validateddeployrequestid --verbose --metadata --sourcepath --manifest
force:source:deploy:cancel --json --loglevel --targetusername --apiversion --wait --jobid
force:source:deploy:report --json --loglevel --targetusername --apiversion --wait --jobid
force:source:open --json --loglevel --targetusername --apiversion --sourcefile --urlonly
force:source:pull --json --loglevel --targetusername --apiversion --wait --forceoverwrite
force:source:push --json --loglevel --targetusername --apiversion --forceoverwrite --ignorewarnings --wait
force:source:retrieve --json --loglevel --targetusername --apiversion --wait --manifest --metadata --packagenames --sourcepath --verbose
force:source:status --json --loglevel --targetusername --apiversion --all --local --remote
force:user:create --json --loglevel --targetdevhubusername --targetusername --apiversion --definitionfile --setalias
force:user:display --json --loglevel --targetdevhubusername --targetusername --apiversion
force:user:list --json --loglevel --targetdevhubusername --targetusername --apiversion
force:user:password:generate --json --loglevel --targetdevhubusername --targetusername --apiversion --onbehalfof
force:user:permset:assign --json --loglevel --targetusername --apiversion --permsetname --onbehalfof
update 
commands --help --json --hidden
help --all
which 
plugins --core
plugins:install --help --verbose --force
plugins:link --help --verbose
plugins:uninstall --help --verbose
plugins:update --help --verbose
plugins:trust:sign --json --loglevel --signatureurl --publickeyurl --privatekeypath
plugins:trust:verify --json --loglevel --npm --registry
plugins:generate --defaults --force
"

      if [[ ${COMP_WORDS[COMP_CWORD]} == "-"* ]] ; then
        opts=$(printf "$commands" | grep "$cur" | sed -n "s/^$cur //p")
        COMPREPLY=( $(compgen -W  "${opts}" -- ${COMP_WORDS[COMP_CWORD]}) )
      else
        opts=$(printf "$commands" | grep -Eo '^[a-zA-Z0-9:_-]+')
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
         __ltrim_colon_completions "$cur"
      fi
  return 0
}

complete -o default -F _sfdx sfdx
