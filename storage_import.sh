#!/bin/bash
Red='\033[1;31m'
White='\033[1;37m'
if [ -z $1 ]; then
    printf "${Red}Error parameters: ${White}$0 <storage bucket> <dir>\n"
    echo "storage bucket without .appspot.com"
    exit 1
fi
export STORAGE_BUCKET=$1
export SRC_DIR=$2
import_file() {
    FILE=$1
    DEST=${FILE/$SRC_DIR/}
    DEST_ENCODED=${DEST////%2F}
    curl -X PUT --data-binary @./$FILE http://127.0.0.1:19199/v0/b/$STORAGE_BUCKET.appspot.com/o/$DEST_ENCODED
    curl -X PATCH --data-binary @./metadata_import.json -H "Content-Type: application/json" http://127.0.0.1:19199/v0/b/$STORAGE_BUCKET.appspot.com/o/$DEST_ENCODED
    return 0
}
export -f import_file

find $2 -type f -print0 | xargs -0 -I {} bash -c 'import_file "{}"'
