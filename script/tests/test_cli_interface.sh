#!/bin/bash
set -euxo pipefail

source "./script/functions.sh"

test_single_file_stdout() {
    (
    cd "$(mktemp -d)"

    echo "a 1,2,3" > a_ruby_file.rb
    echo "a(1, 2, 3)" > expected.rb

    f_rubyfmt a_ruby_file.rb > out.rb

    diff_files o out.rb expected.rb
    )
}

test_stdin_stdout() {
    (
    cd "$(mktemp -d)"

    echo "a(1, 2, 3)" > expected.rb

    echo "a 1,2,3" | f_rubyfmt > out.rb

    diff_files o out.rb expected.rb
    )
}

test_dir_no_i_flag() {
    (
    cd "$(mktemp -d)"

    mkdir bees/
    echo "a 1,2,3" > bees/a_ruby_file_1.rb
    echo "a 1,2,5" > bees/a_ruby_file_2.rb
    echo "a(1, 2, 3)" > expected_1.rb
    echo "a(1, 2, 5)" > expected_2.rb

    f_rubyfmt bees/

    diff_files o bees/a_ruby_file_1.rb expected_1.rb
    diff_files o bees/a_ruby_file_2.rb expected_2.rb
    )
}

test_i_flag() {
    (
    cd "$(mktemp -d)"

    mkdir bees/
    mkdir bees/sub
    echo "a 1,2,3" > bees/a_ruby_file_1.rb
    echo "a 1,2,5" > bees/a_ruby_file_2.rb
    echo "a 1,2,6" > bees/sub/a_ruby_file_3.rb
    echo "a 1,2,7" > cows.rb

    echo "a(1, 2, 3)" > expected_1.rb
    echo "a(1, 2, 5)" > expected_2.rb
    echo "a(1, 2, 6)" > expected_3.rb
    echo "a(1, 2, 7)" > expected_4.rb

    f_rubyfmt -i bees/ cows.rb

    diff_files o bees/a_ruby_file_1.rb expected_1.rb
    diff_files o bees/a_ruby_file_2.rb expected_2.rb
    diff_files o bees/sub/a_ruby_file_3.rb expected_3.rb
    diff_files o cows.rb expected_4.rb
    )
}

test_single_file_stdout
test_stdin_stdout
test_dir_no_i_flag
test_i_flag
