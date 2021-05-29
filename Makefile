.PHONY: clean clippy lint fmt all release debug

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S), Darwin)
	LDFLAGS=-framework Foundation
endif

ifeq ($(UNAME_S), Linux)
	LDFLAGS=-lcrypt -lm -lpthread -lrt -ldl
endif

LDFLAGS +=  -lz

all: submodules release debug

debug:
	cargo build

release:
	cargo build --release

submodules:
	git submodule init
	git submodule update

target/c_main_debug: target/debug/deps/librubyfmt-*.a src/main.c
	clang -O3 src/main.c $< $(LDFLAGS) -o $@

target/c_main_release: target/release/deps/librubyfmt-*.a src/main.c
	clang -O3 src/main.c $< $(LDFLAGS) -o $@

target/release/deps/librubyfmt-*.a: release

target/debug/deps/librubyfmt-*.a: debug

lint: clippy
	./script/lints/lint_fixtures.sh
	./script/lints/lint_scripts.sh
	./script/lints/lint_rust.sh

clean:
	rm -rf target/

fmt:
	cargo fmt

clippy:
	cargo clippy
