#!/bin/bash
Red='\033[1;31m'
White='\033[1;37m'
if [ -z $1 ]; then
  printf "${Red}Error parameters: ${White}$0 <storage bucket> <dir> [parallel count]\n"
  echo "storage bucket without .appspot.com"
  exit 1
fi
export STORAGE_BUCKET=$1
export SRC_DIR=$2
PARALLEL_COUNT=${3:-4}
import_file() {
  FILE=$1
  DEST=${FILE/$SRC_DIR/}
  DEST=$(echo "$DEST" | sed 's|^/||;s|/$||')
  DEST_ENCODED=${DEST////%2F}
  DEST_ENCODED=${DEST_ENCODED// /%20}
  MIME_TYPE=$(file -b --mime-type "$FILE")
  METADATA_JSON=$(printf '{"contentType": "%s"}' "$MIME_TYPE")
  curl -s -o /dev/null -w "%{http_code}" -X PUT --data-binary "@./$FILE" -H "Authorization: Bearer owner" http://127.0.0.1:9199/v0/b/$STORAGE_BUCKET.appspot.com/o/$DEST_ENCODED | grep -v "200"
  curl -s -o /dev/null -w "%{http_code}" -X PATCH --data-binary "$METADATA_JSON" -H "Authorization: Bearer owner" -H "Content-Type: application/json" http://127.0.0.1:9199/v0/b/$STORAGE_BUCKET.appspot.com/o/$DEST_ENCODED | grep -v "200"
  return 0
}
export -f import_file

find $2 -type f -print0 | xargs -0 -I {} -P $PARALLEL_COUNT bash -c 'import_file "{}"'
