#!/bin/sh

fzfAwsProfile () {
    awsp=$(aws configure list-profiles | fzf -1 | awk '{print $1}')

    if [ -n "$awsp" ]; then
        AWS_PROFILE=$awsp
        export AWS_PROFILE
    fi
}

fzfAwsProfile