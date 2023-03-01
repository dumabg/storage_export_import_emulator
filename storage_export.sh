#!/bin/bash
Red='\033[1;31m'
White='\033[1;37m'
if [ -z $1 ]; then
    printf "${Red}Error parameters: ${White}$0 <storage bucket> <out dir>\n"
    echo "storage bucket without .appspot.com"
    echo "out dir default to out"
    exit 1
fi
if [ -z $2 ]; then
    OUT="out"
else
    OUT=$2
fi
echo $OUT
gsutil -m cp -R gs://$1.appspot.com $OUT
