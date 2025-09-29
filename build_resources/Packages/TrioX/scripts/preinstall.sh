#!/bin/sh

killall trioX

if [ -d "/Applications/trioX.app" ] ; then 
    rm -rf "/Applications/trioX.app" 
fi

