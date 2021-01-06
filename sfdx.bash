#!/usr/bin/env bash

# Get the word to complete and optional previous words.
# This is nicer than ${COMP_WORDS[COMP_CWORD]}, since it handles cases
# where the user is completing in the middle of a word.
# (For example, if the line is "ls foobar",
# and the cursor is here -------->   ^
# Also one is able to cross over possible wordbreak characters.
# Usage: _get_comp_words_by_ref [OPTIONS] [VARNAMES]
# Available VARNAMES:
#     cur         Return cur via $cur
#     prev        Return prev via $prev
#     words       Return words via $words
#     cword       Return cword via $cword
#
# Available OPTIONS:
#     -n EXCLUDE  Characters out of $COMP_WORDBREAKS which should NOT be
#                 considered word breaks. This is useful for things like scp
#                 where we want to return host:path and not only path, so we
#                 would pass the colon (:) as -n option in this case.
#     -c VARNAME  Return cur via $VARNAME
#     -p VARNAME  Return prev via $VARNAME
#     -w VARNAME  Return words via $VARNAME
#     -i VARNAME  Return cword via $VARNAME
#
# Example usage:
#
#    $ _get_comp_words_by_ref -n : cur prev
#
_get_comp_words_by_ref()
{
    local exclude flag i OPTIND=1
    local cur cword words=()
    local upargs=() upvars=() vcur vcword vprev vwords

    while getopts "c:i:n:p:w:" flag "$@"; do
        case $flag in
            c) vcur=$OPTARG ;;
            i) vcword=$OPTARG ;;
            n) exclude=$OPTARG ;;
            p) vprev=$OPTARG ;;
            w) vwords=$OPTARG ;;
            *)
                echo "bash_completion: $FUNCNAME: usage error" >&2
                return 1
                ;;
        esac
    done
    while [[ $# -ge $OPTIND ]]; do
        case ${!OPTIND} in
            cur) vcur=cur ;;
            prev) vprev=prev ;;
            cword) vcword=cword ;;
            words) vwords=words ;;
            *)
                echo "bash_completion: $FUNCNAME: \`${!OPTIND}':" \
                    "unknown argument" >&2
                return 1
                ;;
        esac
        ((OPTIND += 1))
    done

    __get_cword_at_cursor_by_ref "${exclude-}" words cword cur

    [[ -v vcur ]] && {
        upvars+=("$vcur")
        upargs+=(-v $vcur "$cur")
    }
    [[ -v vcword ]] && {
        upvars+=("$vcword")
        upargs+=(-v $vcword "$cword")
    }
    [[ -v vprev && $cword -ge 1 ]] && {
        upvars+=("$vprev")
        upargs+=(-v $vprev "${words[cword - 1]}")
    }
    [[ -v vwords ]] && {
        upvars+=("$vwords")
        upargs+=(-a${#words[@]} $vwords ${words+"${words[@]}"})
    }

    ((${#upvars[@]})) && local "${upvars[@]}" && _upvars "${upargs[@]}"
}

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

_sfdx()
{

  #local cur="${_join COMP_WORDS}" opts IFS=$' \t\n'
  _get_comp_words_by_ref -n : -c cur -w cwords -i cword
  COMPREPLY=()

  local commands="
force:lightning:lwc:start --json --loglevel --targetdevhubusername --targetusername --apiversion --port
scanner:rule:add --json --loglevel --language --path
scanner:rule:describe --json --loglevel --rulename --verbose
scanner:rule:list --json --loglevel --verbose --category --ruleset --language --engine
scanner:rule:remove --json --loglevel --verbose --force --path
scanner:run --json --loglevel --verbose --category --ruleset --engine --target --format --outfile --tsconfig --env --violations-cause-error
evergreen:app:create --space --target --default --wait
evergreen:app:delete --space --confirm --wait --target
evergreen:app:describe --columns --sort --filter --extended --no-truncate --no-header --output --space --target
evergreen:app:list --columns --sort --filter --extended --no-truncate --no-header --output --space --target
evergreen:auth:bearer 
evergreen:auth:login 
evergreen:auth:logout 
evergreen:function:create --language
evergreen:function:delete --space --app --confirm --wait --target
evergreen:function:deploy --app --space --targetusername --verbose --target --network --env --clear-cache --no-pull --buildpack --path
evergreen:function:list --columns --sort --filter --extended --no-truncate --no-header --output --space --target
evergreen:function:release --function --space --app --image --target
evergreen:function:update --space --app --private --public --target
evergreen:logs --space --app --function --target
evergreen:org:bind --app --space --name --targetusername --target
evergreen:org:list --columns --sort --filter --extended --no-truncate --no-header --output --target
evergreen:org:unbind --app --space --confirm --target --targetusername
evergreen:secret:app:bind --secret --app --space --target
evergreen:secret:app:unbind --secret --app --space --confirm --target
evergreen:secret:binding:list --columns --sort --filter --extended --no-truncate --no-header --output --space --target
evergreen:secret:create --space --data --from-file --target
evergreen:secret:data:list --columns --sort --filter --extended --no-truncate --no-header --output --space --target
evergreen:secret:delete --space --confirm --target
evergreen:secret:delete:key --space --secret --confirm --target
evergreen:secret:function:bind --secret --function --app --space --target
evergreen:secret:function:unbind --secret --function --app --space --confirm --target
evergreen:secret:list --columns --sort --filter --extended --no-truncate --no-header --output --space --target
evergreen:secret:update --space --data --from-file --force --target
evergreen:space:create --wait --target --default
evergreen:space:delete --confirm --wait --target
evergreen:space:list --columns --sort --filter --extended --no-truncate --no-header --output
evergreen:target:list --columns --sort --filter --extended --no-truncate --no-header --output
evergreen:target:remove 
evergreen:target:set --space --app --columns --sort --filter --extended --no-truncate --no-header --output
evergreen:whoami --json
force:lightning:lint --json --loglevel --ignore --files --config --verbose --exit
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
force:apex:execute --json --loglevel --targetusername --apiversion --apexcodefile
force:apex:log:get --json --loglevel --targetusername --apiversion --logid --number --outputdir
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
force:org:list --json --loglevel --verbose --all --clean --noprompt --skipconnectionstatus
force:org:open --json --loglevel --targetusername --apiversion --path --urlonly
force:org:shape:create --json --loglevel --targetusername --apiversion --definitionfile
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
force:package:create --json --loglevel --targetdevhubusername --apiversion --name --packagetype --description --nonamespace --path --orgdependent --errornotificationusername
force:package:delete --json --loglevel --targetdevhubusername --apiversion --noprompt --package
force:package:hammertest:list --json --loglevel --targetusername --apiversion --packageversionid
force:package:hammertest:report --json --loglevel --targetusername --apiversion --requestid --summary
force:package:hammertest:run --json --loglevel --targetusername --apiversion --packageversionids --subscriberorgs --subscriberfile --scheduledrundatetime --preview --apextests --apextestinterface
force:package:install --json --loglevel --targetusername --apiversion --wait --installationkey --publishwait --noprompt --package --apexcompile --securitytype --upgradetype
force:package:install:report --json --loglevel --targetusername --apiversion --requestid
force:package:installed:list --json --loglevel --targetusername --apiversion
force:package:list --json --loglevel --targetdevhubusername --apiversion --verbose
force:package:uninstall --json --loglevel --targetusername --apiversion --wait --package
force:package:uninstall:report --json --loglevel --targetusername --apiversion --requestid
force:package:update --json --loglevel --targetdevhubusername --apiversion --package --name --description --errornotificationusername
force:package:version:create --json --loglevel --targetdevhubusername --apiversion --package --path --definitionfile --branch --tag --installationkey --installationkeybypass --wait --versionname --versionnumber --versiondescription --codecoverage --releasenotesurl --postinstallurl --postinstallscript --uninstallscript --skipvalidation
force:package:version:create:list --json --loglevel --targetdevhubusername --apiversion --createdlastdays --status
force:package:version:create:report --json --loglevel --targetdevhubusername --apiversion --packagecreaterequestid
force:package:version:delete --json --loglevel --targetdevhubusername --apiversion --noprompt --package
force:package:version:displayancestry --json --loglevel --targetdevhubusername --apiversion --package --dotcode --verbose
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
force:source:tracking:clear --json --loglevel --targetusername --apiversion --noprompt
force:source:tracking:reset --json --loglevel --targetusername --apiversion --revision --noprompt
force:user:create --json --loglevel --targetdevhubusername --targetusername --apiversion --definitionfile --setalias
force:user:display --json --loglevel --targetdevhubusername --targetusername --apiversion
force:user:list --json --loglevel --targetdevhubusername --targetusername --apiversion
force:user:password:generate --json --loglevel --targetdevhubusername --targetusername --apiversion --onbehalfof
force:user:permset:assign --json --loglevel --targetusername --apiversion --permsetname --onbehalfof
force:lightning:lwc:test:create --json --loglevel --filepath
force:lightning:lwc:test:run --json --loglevel --debug --watch
force:lightning:lwc:test:setup --json --loglevel
force:cmdt:create --json --loglevel --typename --label --plurallabel --visibility --outputdir
force:cmdt:field:create --json --loglevel --fieldname --fieldtype --picklistvalues --decimalplaces --label --outputdir
force:cmdt:generate --json --loglevel --targetusername --apiversion --devname --label --plurallabel --visibility --sobjectname --ignoreunsupported --typeoutputdir --recordsoutputdir
force:cmdt:record:create --json --loglevel --typename --recordname --label --protected --inputdir --outputdir
force:cmdt:record:insert --json --loglevel --filepath --typename --inputdir --outputdir --namecolumn
help --all
evergreen:function:build --path --no-pull --verbose --clear-cache --env --env-file --buildpack --network
evergreen:function:invoke --headers --payload --structured --targetusername
evergreen:function:start --builder --port --debug-port --clear-cache --no-pull --env --network --verbose
evergreen:image:push --space
update 
config:get --json --loglevel --verbose
config:list --json --loglevel
config:set --json --loglevel --global
config:unset --json --loglevel --global
alias:list --json --loglevel
alias:set --json --loglevel
alias:unset --json --loglevel
auth:device:login --json --loglevel --clientid --instanceurl --setdefaultdevhubusername --setdefaultusername --setalias
auth:jwt:grant --json --loglevel --username --jwtkeyfile --clientid --instanceurl --setdefaultdevhubusername --setdefaultusername --setalias
auth:list --json --loglevel
auth:logout --json --loglevel --targetusername --apiversion --all --noprompt
auth:sfdxurl:store --json --loglevel --sfdxurlfile --setdefaultdevhubusername --setdefaultusername --setalias
auth:web:login --json --loglevel --clientid --instanceurl --setdefaultdevhubusername --setdefaultusername --setalias
autocomplete --refresh-cache
commands --help --json --hidden --columns --sort --filter --csv --output --extended --no-truncate --no-header
plugins --core
plugins:install --help --verbose --force
plugins:link --help --verbose
plugins:uninstall --help --verbose
plugins:update --help --verbose
which 
plugins:generate --defaults --force
"

  if [[ "${cword}" -eq 1 ]]; then
      opts=$(printf "$commands" | grep -Eo '^[a-zA-Z0-9:_-]+')
      COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
       __ltrim_colon_completions "$cur"
  else
    if [[ $cur == "-"* ]] ; then
      opts=$(printf "$commands" | grep "${cwords[1]}" | sed -n "s/^${cwords[1]} //p")
      COMPREPLY=( $(compgen -W  "${opts}" -- ${cur}) )
    fi
  fi
  return 0
}

complete -o default -F _sfdx sfdx
