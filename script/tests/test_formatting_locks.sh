#!/bin/bash
set -euo pipefail
source ./script/functions.sh
REPO_DIRS=$(find ./formatting_locks -type d -mindepth 2)
for REPO_DIR in $REPO_DIRS
do
    HEAD=$(cat "$REPO_DIR/HEAD")
    FILES=$(cat "$REPO_DIR/files")
    REPO=$(echo "$REPO_DIR" | sed 's/.\/formatting_locks\///')
    (
    cd "$(mktemp -d)"
    git clone "https://github.com/$REPO" "$REPO"
    cd "$REPO"
    git checkout "$HEAD"
    f_rubyfmt -i lib/
    for FILE in $FILES
    do
        fn=$(echo "$FILE" | cut -f1 -d,)
        expected_md5=$(echo "$FILE" | cut -f2 -d,)
        res_md5=$(f_md5 < "$fn")
        if [[ "$res_md5" != "$expected_md5" ]]
        then
            echo "$fn did not match"
            exit 1
        fi

    done
    )
done
echo 'everything checks out'

