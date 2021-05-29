#!/bin/bash
REPO_BASE=$(git rev-parse --show-toplevel)

f_md5() {
    if command -v md5sum >/dev/null
    then
        md5sum
    else
        md5
    fi
}

f_rubyfmt() {
    "${REPO_BASE}/target/release/rubyfmt-main" "$@"
}


diff_files() {
    IDEMPOTENCY=$1
    ACTUAL=$2
    EXPECTED=$3

    if ! diff -u "$ACTUAL" "$EXPECTED"
    then
        if [[ $IDEMPOTENCY == "i" ]]
        then
            echo "got idempotent diff"
        else
            echo "got diff between formated formatted actual and expected"
        fi
        exit 1
    fi
}


test_fixtures_folder() {
    current_dir="$1"

    # Fallback to * (all tests)
    fixture_name=${FIXTURE_NAME:-*}

    find "$current_dir" -name "${fixture_name}_expected.rb" -maxdepth 1 | while read -r expected_file; do
      actual_file="${expected_file//expected/actual}"

      ## Test if the formatting works as expected
      time f_rubyfmt "$actual_file" > /tmp/out.rb
      diff_files o /tmp/out.rb "$expected_file"

      ## Test if the formatting is idempotent
      time f_rubyfmt "$expected_file" > /tmp/out.rb
      diff_files i /tmp/out.rb "$expected_file"
    done

    ## Recurse over ruby version dirs
    find "$current_dir" -type d -mindepth 1 -maxdepth 1 -name '*2.*' | while read -r dir
    do
        RUBY_VERSION=$(ruby -v | grep -o "[0-9].[0-9]" | head -n 1)
        base="$(basename "$dir")"
        fixture_version=${base#"ruby-"}
        if [[ $(echo "$fixture_version<=$RUBY_VERSION" | bc -l) -ne 0 ]]
        then
            test_fixtures_folder "$dir"
        fi
    done
}
