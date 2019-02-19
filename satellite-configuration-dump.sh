#!/bin/bash

# ------------------------------------------------------------------------
#             |
# Name        | satellite-configuration-dump.sh
#             |
# Description | This script will dump the satellite configuration
#             | to asciidoc formatted file that can be used by
#             | AsciidocFX, asciidoctor, etc. to create documentation.
#             | If uploaded to github, bitbucket, etc. the document is
#             | is formatted to be readable as document on those services.
#             | 
# Disclaimer  | This script is NOT SUPPORTED by Red Hat Global
#             | Support Services
#             |
# License     | GPLv3 - https://www.gnu.org/licenses/gpl-3.0.en.html
#             |
#             | This program is free software; you can redistribute it and/or modify
#             | it under the terms of the GNU General Public License as published by
#             | the Free Software Foundation; either version 3 of the License, or
#             | (at your option) any later version.
#             |
#             | This program is distributed in the hope that it will be useful,
#             | but WITHOUT ANY WARRANTY; without even the implied warranty of
#             | MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#             | GNU General Public License for more details.
#             |
#             | You should have received a copy of the GNU General Public License
#             | along with this program; if not, write to the Free Software
#             | Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#             | MA 02110-1301, USA.
#             |
# History     | 2019-02-14 - v1.0
#             | Created by Scott Parker (Red Hat Consulting - NA)
#             |
# Contribute  | If you would like to contribute to the script please do 
#             | pull request for changes and for incorporation into the
#             | original.
# ------------------------------------------------------------------------

usage() {

cat << EOF
Usage Examples: 

Long Method:

$0 --h or $0 --help
$0 --organization <name of organization> --listing <filename>.adoc --type <AD|MD>

Short Method: 

$0 -o <name of organization> -l <filename>.adoc -t <AD|MD>

Options:

-l | --listing filename.adoc          : name of file to store the output.
-o | --organization organization_name : name_of_organization in Satellite.
-t | --type AD|MD                     : report types: AD (asciidoc) or MD (markdown)
-h | --help                           : usage

EOF

exit 1
}

function report-configuration () {
  REPORT_TYPE=$1

  if [ $REPORT_TYPE -eq 0 ]; then

  exec 3>&1 4>&2 1>>$OUTPUT 2>>$ERRORLOG
  cat << EOF
= {subject}
:subject: Satelite 6 Configuration
:description: {subject}
:doctype: book
:confidentiality: Confidential
:listing-caption: Listing
:numbered:
:chapter-label:
:pdf-page-size: A4
:pdf-style: redhat
:pdf-stylesdir: .
:revnumber: 1.0.0
:toc: left
:toclevels: 6
:icons: font
:icon-set: octicon
:source-highlighter: prettify
:experimental:
ifdef::backend-pdf[]
endif::[]
EOF
  else
  cat << EOF
## Satellite 6 Configuration
EOF
  fi
  exec 1>&3 3>&- 2>&4 4>&-

}

function code-block-header () { 

  LISTING_TYPE="${1}"
  LISTING_HEADER="${2}"
  LISTING_HEADER_MASKED=$(echo ${LISTING_HEADER} | sed 's/ /_/g')
  LEVEL="${3}"
  REPORT_TYPE=${4}

  case $LEVEL in
    1 ) if [ $REPORT_TYPE -eq 0 ]; then
           LEVEL_OPTION="==="
        else
           LEVEL_OPTION="###"
        fi
        ;;
    2 ) if [ $REPORT_TYPE -eq 0 ]; then
           LEVEL_OPTION="===="
        else
           LEVEL_OPTION="####"
        fi
        ;;
  esac

  if [ $REPORT_TYPE -eq 0 ]; then

  cat << EOF
${LEVEL_OPTION} ${LISTING_HEADER} Configuration.

anchor:${LISTING_HEADER_MASKED}[${LISTING_HEADER}]

.Listing of ${LISTING_HEADER}
[source,${LISTING_TYPE},linenums,options="nowrap",subs="attributes,verbatim"]
----
EOF

  else

  cat << EOF
${LEVEL_OPTION} ${LISTING_HEADER} Configuration.

\`\`\` ${LISTING_TYPE}
EOF
 
  fi

}

function code-block-footer () { 
  REPORT_TYPE="${1}"

  if [ $REPORT_TYPE -eq 0 ]; then

cat << EOF
----
EOF

  else

  cat << EOF
\`\`\`
EOF

  fi
}


function get-info () {
  
  LISTING_TYPE="${1}"
  LISTING_HEADER="${2}"
  ORG_OPT="${3}"
  
  [ ! -z "$3" ] && ORG_OPT="--organization ${3}"
  CNT=$(hammer --csv ${2} list ${ORG_OPT} | grep -iv ^Id | wc -l)
  if [ $CNT -eq 0 ] ; then return 0; fi
  echo ...${LISTING_HEADER}
  exec 3>&1 4>&2 1>>$OUTPUT 2>>$ERRORLOG
  code-block-header "${LISTING_TYPE}" "${LISTING_HEADER}" 1 $REPORT_TYPE
  hammer ${2} list $ORG_OPT
  echo
  echo ---[ DETAILS ]-------------------------------
  echo
  hammer --csv ${2} list $ORG_OPT  | \
  grep -iv ^Id | \
  awk -F, '{print $1}' | \
  while read ID
  do
    hammer ${2} info --id ${ID} $ORG_OPT
  done
  code-block-footer  $REPORT_TYPE
  exec 1>&3 3>&- 2>&4 4>&-

}

function get-global-parameters () {

  LISTING_TYPE="${1}"
  LISTING_HEADER="${2}"

  echo ...${LISTING_HEADER}
  exec 3>&1 4>&2 1>>$OUTPUT 2>>$ERRORLOG
  [ ! -z "$3" ] && ORG_OPT="--organization ${3}"
  code-block-header "${LISTING_TYPE}" "${LISTING_HEADER}" 1 $REPORT_TYPE
  hammer global-parameter list --show-hidden yes
  code-block-footer  $REPORT_TYPE
  exec 1>&3 3>&- 2>&4 4>&-

}

function get-info-simple () {

  LISTING_TYPE="${1}"
  LISTING_HEADER="${2}"
  ORG_OPT="${3}"

  [ ! -z "$3" ] && ORG_OPT="--organization ${3}"
  CNT=$(hammer --csv ${2} list $ORG_OPT | grep -iv ^Id | wc -l)
  if [ $CNT -eq 0 ] ; then return 0; fi
  echo ...${LISTING_HEADER}
  exec 3>&1 4>&2 1>>$OUTPUT 2>>$ERRORLOG
  code-block-header "${LISTING_TYPE}" "${LISTING_HEADER}" 1 $REPORT_TYPE
  hammer ${2} list $ORG_OPT
  code-block-footer  $REPORT_TYPE
  exec 1>&3 3>&- 2>&4 4>&-

}

function get-ping () {

  LISTING_TYPE="${1}"
  LISTING_HEADER="${2}"
  ORG_OPT="${3}"

  [ ! -z "$3" ] && ORG_OPT="--organization ${3}"
  echo ...${LISTING_HEADER}
  exec 3>&1 4>&2 1>>$OUTPUT 2>>$ERRORLOG
  code-block-header "${LISTING_TYPE}" "${LISTING_HEADER}" 1 $REPORT_TYPE
  hammer ping
  code-block-footer  $REPORT_TYPE
  exec 1>&3 3>&- 2>&4 4>&-

}

function get-info-roles () {

  LISTING_TYPE="${1}"
  LISTING_HEADER="${2}"
  
  [ ! -z "$3" ] && ORG_OPT="--organization ${3}"
  CNT=$(hammer --csv ${2} list ${ORG_OPT} | grep -iv ^Id | wc -l)
  [ $CNT -eq 0 ] && return 0
  echo ...${LISTING_HEADER}
  exec 3>&1 4>&2 1>>$OUTPUT 2>>$ERRORLOG
  hammer --csv location list --organization ${ORGANIZATION} | \
  grep -iv ^Id | \
  awk -F, '{print $1}' | \
  while read ID
  do
    code-block-header "${LISTING_TYPE}" "${LISTING_HEADER}" 1 $REPORT_TYPE
    hammer role list --organization ${ORGANIZATION}
    code-block-footer  $REPORT_TYPE

    hammer --csv role list --organization ${ORGANIZATION} | \
    grep -iv ^Id | \
    awk -F, '{print $1}' | \
    while read RID
    do
       code-block-header "${LISTING_TYPE}" "${LISTING_HEADER} Details" 2 $REPORT_TYPE
       hammer role info --id ${RID} --organization ${ORGANIZATION}
       code-block-footer  $REPORT_TYPE
       
       code-block-header "${LISTING_TYPE}" "${LISTING_HEADER} Filters" 2 $REPORT_TYPE
       hammer role filters --id ${RID} --organization ${ORGANIZATION}
       code-block-footer  $REPORT_TYPE
    done
    echo ----------------------------------
  done
  code-block-footer  $REPORT_TYPE
  exec 1>&3 3>&- 2>&4 4>&-

}

function get-info-details () {

  LISTING_TYPE="${1}"
  LISTING_HEADER="${2}"
  ORG_OPT=""
  
  [ ! -z "$3" ] && ORG_OPT="--organization ${3}"
  CNT=$(hammer --csv ${2} list ${ORG_OPT} | grep -iv ^Id | wc -l)
  if [ $CNT -eq 0 ] ; then return 0; fi
  echo ...${LISTING_HEADER}
  exec 3>&1 4>&2 1>>$OUTPUT 2>>$ERRORLOG
  code-block-header "${LISTING_TYPE}" "${LISTING_HEADER}" 1 $REPORT_TYPE
  hammer --csv location list ${ORG_OPT} | \
  grep -iv ^Id | \
  awk -F, '{print $1}' | \
  while read ID
  do
    hammer ${2} list --location-id ${ID} ${ORG_OPT}
    echo
    echo ---[ DETAILS ]-------------------------------
    echo
    hammer --csv ${2} list --location-id ${ID} ${ORG_OPT} | \
    grep -iv ^Id | \
    awk -F, '{print $1}' | \
    while read HID
    do
       echo ==================================
       hammer ${2} info --id ${HID} ${ORG_OPT}
    done
    echo ----------------------------------
  done
  code-block-footer  $REPORT_TYPE
  exec 1>&3 3>&- 2>&4 4>&-

}

function get-info-compute-resources () {

  LISTING_TYPE="${1}"
  LISTING_HEADER="${2}"
  ORG_OPT="${3}"
  
  [ ! -z "$3" ] && ORG_OPT="--organization ${3}"
  CNT=$(hammer --csv ${2} list $ORG_OPT | grep -iv ^Id | wc -l)
  if [ $CNT -eq 0 ] ; then return 0; fi
  echo ...${LISTING_HEADER}
  exec 3>&1 4>&2 1>>$OUTPUT 2>>$ERRORLOG
  hammer --csv location list ${ORG_OPT} | \
  grep -iv ^Id | \
  awk -F, '{print $1}' | \
  while read ID
  do
    code-block-header "${LISTING_TYPE}" "${LISTING_HEADER}" 1 $REPORT_TYPE
    hammer compute-resource list --location-id ${ID} ${ORG_OPT}
    code-block-footer  $REPORT_TYPE

    hammer --csv compute-resource list --location-id ${ID} ${ORG_OPT} | \
    grep -iv ^Id | \
    awk -F, '{print $1}' | \
    while read CID
    do
       code-block-header "${LISTING_TYPE}" "${LISTING_HEADER} Details" 2 $REPORT_TYPE
       hammer compute-resource info --id ${CID} --organization ${ORG_OPT}
       code-block-footer  $REPORT_TYPE
       
       code-block-header "${LISTING_TYPE}" "${LISTING_HEADER} Images" 2 $REPORT_TYPE
       hammer compute-resource image list --compute-resource-id ${CID} ${ORG_OPT}
       code-block-footer  $REPORT_TYPE
    done
    echo ----------------------------------
  done
  code-block-footer  $REPORT_TYPE
  exec 1>&3 3>&- 2>&4 4>&-

}

function get-info-hostgroup () {

  LISTING_TYPE="${1}"
  LISTING_HEADER="${2}"
  
  [ ! -z "$3" ] && ORG_OPT="--organization ${3}"
  CNT=$(hammer --csv ${2} list $ORG_OPT | grep -iv ^Id | wc -l)
  if [ $CNT -eq 0 ] ; then return 0 ; fi
  echo ...${LISTING_HEADER}
  exec 3>&1 4>&2 1>>$OUTPUT 2>>$ERRORLOG
  hammer --csv location list ${ORG_OPT} | \
  grep -iv ^Id | \
  awk -F, '{print $1}' | \
  while read ID
  do
    code-block-header "${LISTING_TYPE}" "${LISTING_HEADER}" 1 $REPORT_TYPE
    hammer hostgroup list --location-id ${ID} ${ORG_OPT}
    code-block-footer  $REPORT_TYPE
    
    hammer --csv hostgroup list --location-id ${ID} ${ORG_OPT} | \
    grep -iv ^Id | \
    awk -F, '{print $1}' | \
    while read HID
    do
       code-block-header "${LISTING_TYPE}" "${2} Hidden Parameters" 2 $REPORT_TYPE
       hammer hostgroup info --show-hidden-parameters yes --id ${HID} ${ORG_OPT}
       code-block-footer  $REPORT_TYPE

       code-block-header "${LISTING_TYPE}" "${2} Puppet Classes" 2 $REPORT_TYPE
       hammer hostgroup puppet-classes --hostgroup-id ${HID} 
       code-block-footer  $REPORT_TYPE

       code-block-header "${LISTING_TYPE}" "${2} Parameters" 2 $REPORT_TYPE
       hammer hostgroup sc-params --show-hidden yes --hostgroup-id ${HID} ${ORG_OPT}
       code-block-footer  $REPORT_TYPE

       code-block-header "${LISTING_TYPE}" "${2} Smart Parameters" 2 $REPORT_TYPE
       hammer hostgroup smart-variables --show-hidden yes --hostgroup-id ${HID} ${ORG_OPT}
       code-block-footer  $REPORT_TYPE
    done
  done
  exec 1>&3 3>&- 2>&4 4>&-

}

function get-info-job-templates () {

  LISTING_TYPE="${1}"
  LISTING_HEADER="${2}"
  ORG_OPT="${3}"

  echo ...${LISTING_HEADER}
  exec 3>&1 4>&2 1>>$OUTPUT 2>>$ERRORLOG
  [ ! -z "$3" ] && ORG_OPT="--organization ${3}"
  hammer --csv location list ${ORG_OPT} | \
  grep -iv ^Id | \
  awk -F, '{print $1}' | \
  while read ID
  do

    code-block-header "${LISTING_TYPE}" "${LISTING_HEADER}" 1 $REPORT_TYPE
    hammer job-template list --location-id ${ID} ${ORG_OPT}
    code-block-footer  $REPORT_TYPE

    hammer --csv job-template list --location-id ${ID} ${ORG_OPT} | \
    grep -iv ^Id | \
    awk -F, '{print $1" "$2}' | \
    while read PID LISTING_HEADER
    do
       
       code-block-header "${LISTING_TYPE}" "${LISTING_HEADER}" 2 $REPORT_TYPE
       hammer job-template info --id ${PID} ${ORG_OPT}
       code-block-footer  $REPORT_TYPE

       code-block-header "${LISTING_TYPE}" "${LISTING_HEADER} - Source" 2 $REPORT_TYPE
       hammer job-template dump --id ${PID} ${ORG_OPT}
       code-block-footer  $REPORT_TYPE

    done
  done
  exec 1>&3 3>&- 2>&4 4>&-

}

function get-info-templates () {

  LISTING_TYPE="${1}"
  LISTING_HEADER="${2}"
  ORG_OPT="${3}"

  echo ...${LISTING_HEADER}
  exec 3>&1 4>&2 1>>$OUTPUT 2>>$ERRORLOG
  [ ! -z "$3" ] && ORG_OPT="--organization ${3}"
  hammer --csv location list ${ORG_OPT} | \
  grep -iv ^Id | \
  awk -F, '{print $1}' | \
  while read ID
  do

    code-block-header "${LISTING_TYPE}" "${LISTING_HEADER}" 1 $REPORT_TYPE
    hammer template list --location-id ${ID} ${ORG_OPT}
    code-block-footer  $REPORT_TYPE

    hammer --csv template list --location-id ${ID} ${ORG_OPT} | \
    grep -iv ^Id | \
    awk -F, '{print $1" "$2}' | \
    while read PID LISTING_HEADER
    do

       code-block-header "${LISTING_TYPE}" "${LISTING_HEADER}" 2 $REPORT_TYPE
       hammer template info --id ${PID} ${ORG_OPT}
       code-block-footer  $REPORT_TYPE

       code-block-header "${LISTING_TYPE}" "${LISTING_HEADER} - Source" 2 $REPORT_TYPE
       hammer template dump --id ${PID} ${ORG_OPT}
       code-block-footer  $REPORT_TYPE

    done
  done
  exec 1>&3 3>&- 2>&4 4>&-

}

function get-info-partition-table () {

  LISTING_TYPE="${1}"
  LISTING_HEADER="${2}"
  ORG_OPT="${3}"
  
  echo ...${LISTING_HEADER}
  exec 3>&1 4>&2 1>>$OUTPUT 2>>$ERRORLOG
  [ ! -z "$3" ] && ORG_OPT="--organization ${3}"
  hammer --csv location list ${ORG_OPT} | \
  grep -iv ^Id | \
  awk -F, '{print $1}' | \
  while read ID
  do
    code-block-header "${LISTING_TYPE}" "${LISTING_HEADER}" 1 $REPORT_TYPE
    hammer --csv partition-table list --location-id ${ID} ${ORG_OPT} 
    code-block-footer  $REPORT_TYPE
    
    hammer --csv partition-table list --location-id ${ID} ${ORG_OPT} | \
    grep -iv ^Id | \
    awk -F, '{print $1" "$2}' | \
    while read PID LISTING_HEADER
    do
       code-block-header "${LISTING_TYPE}" "${LISTING_HEADER} - Details" 2 $REPORT_TYPE
       hammer partition-table info --id ${PID} ${ORG_OPT}
       code-block-footer  $REPORT_TYPE
     
       code-block-header "${LISTING_TYPE}" "${LISTING_HEADER} - Source" 2 $REPORT_TYPE
       hammer partition-table dump --id ${PID} ${ORG_OPT}
       code-block-footer  $REPORT_TYPE
    done
  done
  exec 1>&3 3>&- 2>&4 4>&-

}

function get-info-dump () {

  LISTING_TYPE="${1}"
  LISTING_HEADER="${2}"
  
  exec 3>&1 4>&2 1>>$OUTPUT 2>>$ERRORLOG
  code-block-header "${LISTING_TYPE}" "${LISTING_HEADER}" 1 $REPORT_TYPE
  hammer ${2} list --organization ${ORGANIZATION}
  echo ---[ DETAILS ]-------------------------------
  hammer --csv ${2} list --organization ${ORGANIZATION} | \
  grep -iv ^Id | \
  awk -F, '{print $1}' | \
  while read ID
  do
    hammer ${2} info --id ${ID} --organization ${ORGANIZATION}
  done
  hammer --csv ${2} list --organization ${ORGANIZATION} | \
  grep -iv ^Id | \
  awk -F, '{print $2}' | \
  while read ID
  do
    hammer ${2} dump --id ${ID} --organization ${ORGANIZATION}
  done
  code-block-footer  $REPORT_TYPE
  exec 1>&3 3>&- 2>&4 4>&-

}


function get-info-content-view () {

  LISTING_TYPE="${1}"
  LISTING_HEADER="${2}"
  ORG_OPT="${3}"
  
  echo ...${LISTING_HEADER}
  exec 3>&1 4>&2 1>>$OUTPUT 2>>$ERRORLOG
  [ ! -z "$3" ] && ORG_OPT="--organization ${3}"
  code-block-header "${LISTING_TYPE}" "${LISTING_HEADER}" 1 $REPORT_TYPE
  hammer content-view list $ORG_OPT
  echo ---[ DETAILS ]-------------------------------
  hammer --csv content-view list $ORG_OPT | \
  grep -iv 'Content View ID' | \
  awk -F, '{print $1}' | \
  while read ID
  do
    hammer content-view info --id ${ID} $ORG_OPT
  done
  code-block-footer  $REPORT_TYPE
  exec 1>&3 3>&- 2>&4 4>&-

}

# MAIN

# Global Variable

LISTING=""
LISTING_HEADER=""
LISTING_TYPE=""
ORGANIZATION=""
OUTPUT=""
REPORT_TYPE=0

# If no arguments found then print usage.

if [ $# -lt 1 ] ; then usage >&2 ; fi

# get command line options and check for required options

OPTS=`getopt -n 'parse-options' -o ho:l:t: --long help,organization:,listing:,type: -- "$@"`
if [ $? != 0 ] ; then usage >&2 ; fi
eval set -- "$OPTS"

# Process the arguments into variables.

while true; do
    case "$1" in
        -h | --help )
            shift
            usage
            ;;
        -o | --organization )
            ORGANIZATION="${2}"
            shift 2
            ;;
        -l | --listing )
            OUTPUT="${2}"
            shift 2
            ;;
        -t | --type )
            RTYPE="${2}"
            if [ "RTYPE" == "ADOC" ]; then
               REPORT_TYPE=0
            else # Markdown
               REPORT_TYPE=1
            fi 
            shift 2
            ;;
        -- )
            shift
            break
            ;;
         * )
            shift
            usage
            ;;
    esac
done

# Check for required options and values.

if [ -z ${ORGANIZATION} ]; then
   echo "${ORGANIZATION} was not found!!"
   usage
   exit 1
fi

if [ -z ${OUTPUT} ]; then
   echo "${OUTPUT} was not found!!"
   usage
   exit 1
else
   # Add .adoc on the end of the output file.
   if [[ ${OUTPUT} == *"\.adoc$" ]]; then
      OUTPUT="${OUTPUT}.adoc"
   fi
fi

# reset the output file

cp /dev/null $OUTPUT
ERRORLOG="${OUTPUT}.errors"
cp /dev/null $ERRORLOG

# Write asciidoc configuration to file.
if [ $REPORT_TYPE -eq 0 ]; then
report-configuration $REPORT_TYPE
fi

echo Gathering information:
# Content 
get-info bash organization ""
get-info bash location ""
get-info-simple bash subscription $ORGANIZATION
get-info bash product $ORGANIZATION
get-info bash repository $ORGANIZATION
get-info bash sync-plan $ORGANIZATION
get-info bash lifecycle-environment $ORGANIZATION
get-info-content-view bash 'content views' $ORGANIZATION
get-info bash 'content-view version' $ORGANIZATION
get-info bash file $ORGANIZATION
get-info bash gpg $ORGANIZATION
get-info bash 'virt-who-config' $ORGANIZATION
get-info-job-templates bash 'job templates' $ORGANIZATION

# Build
get-info bash os ""
get-info bash architecture ""
get-info bash 'medium' $ORGANIZATION
get-info-partition-table bash 'partition-table' ""
get-info-templates bash 'Provisioning Templates' $ORGANIZATION
get-global-parameters bash 'global-parameters' $ORGANIZATION 
get-info bash discovery ""
get-info bash discovery-rule $ORGANIZATION
get-info-details bash subnet $ORGANIZATION
get-info-details bash domain $ORGANIZATION
get-info-details bash 'realm' $ORGANIZATION
get-info-details bash user $ORGANIZATION
get-info-hostgroup bash hostgroup $ORGANIZATION
get-info-compute-resources bash 'compute-resource' ""
get-info bash 'remote-execution-feature' $ORGANIZATION

# Puppet
get-info-details bash environment $ORGANIZATION
get-info bash 'config-group' ""
get-info bash 'sc-param' $ORGANIZATION
get-info bash 'smart-variable' $ORGANIZATION
get-info-simple bash fact $ORGANIZATION

# Administration
get-info-roles bash role $ORGANIZATION
get-info bash 'recurring-logic' ""
get-info-simple bash settings ""

# Compliance
get-info bash policy ""
get-info bash 'scap-content' ""
get-info bash 'tailoring-file' ""

# Capsules
get-info-details bash capsule ""
get-info bash 'proxy' $ORGANIZATION

# Authenication
if [ -f ~/.hammer/defaults.yml ]; then
   cp -f ~/.hammer/defaults.yml /tmp/defaults.yml
   rm -f ~/.hammer/defaults.yml
fi
get-info bash 'auth-source ldap' $ORGANIZATION
if [ -f ~/.hammer/defaults.yml ]; then
   cp -f /tmp/defaults.yml ~/.hammer/defaults.yml
   rm -f /tmp/defaults.yml
fi
get-info bash 'user-group' ""

# Information
get-ping bash "hammer ping" ""
