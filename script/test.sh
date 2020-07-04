#!/bin/bash
set -ex

cargo build --release

export RUBYFMT_USE_RELEASE=1
uname -a
./script/tests/test_string_literals.sh
./script/tests/test_methods.sh
./script/tests/test_fixtures.sh
./script/tests/test_rspec_stress.sh
