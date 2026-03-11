#!/bin/bash

USERNAME=pi
SUBJECT="Test mutt"
MAILBODY="Testing mail sending with mutt"
RECIPIENT="radmilo@feliks.ro"
ATTACHMENT="BashUsefulFunctions.incl.sh"


gridfilesend()
{
        scriptinit
        getsystemtime
        SUBJECT=$GRIDWATCHSUBJECT
        MAILBODY="$GRIDWATCHBODYINTERMEDIARY 1 - $mday $mmonthnamefull $myear"
        ATTACHMENT=$GRIDFILE
        sendmailmutt
}




sendmailmutt()
{
#ATTACHMENT="$GRIDFILEPATH/upsgridwatch-2025-04.csv"
#DEBUGLEVEL="-d0"
#DEBUGLEVEL=-d5
#runuser -l  $USERNAME -c "echo $MAILBODY | mutt $DEBUGLEVEL  $RECIPIENT -s '${SUBJECT}'-a $ATTACHMENT"
runuser -l  $USERNAME -c "echo $MAILBODY | mutt $RECIPIENT -s '${SUBJECT}' -a $ATTACHMENT"
}

$1
