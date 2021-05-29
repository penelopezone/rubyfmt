#!/bin/bash
set -euxo pipefail
source ./script/functions.sh
REPO_DIRS=$(find ./formatting_locks -type d -mindepth 2)
for REPO_DIR in $REPO_DIRS
do
    HEAD=$(cat "$REPO_DIR/HEAD")
    FN="$(pwd)/$REPO_DIR/files"
    REPO=$(echo "$REPO_DIR" | sed 's/.\/formatting_locks\///')
    (
    cd "$(mktemp -d)"
    git clone "https://github.com/$REPO" "$REPO"
    cd "$REPO"
    git checkout "$HEAD"
    lfs=$(find ./lib | grep -i '\.rb$')
    for file in $lfs
    do
        if grep "$file" "$FN"
        then
            echo ""
        else
            f_rubyfmt -i "$file"
            less "$file"
            echo "do you want to lock this file? [y/n/q]"
            read -r cmd
            if [[ $cmd == "y" ]]
            then
                file_md5=$(f_md5 < "$file")
                echo "$file,$file_md5" >> "$FN"
            fi
            if [[ $cmd == "q" ]]
            then
                exit 0
            fi
        fi
    done
    )
done
