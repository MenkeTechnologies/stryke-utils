SHELL := /bin/sh
.PHONY: all test check-counts install clean help

all: test check-counts

help:
	@printf '%s\n' \
	  'targets:' \
	  '  make test          - s test t/   (run the .stk tests in t/)' \
	  '  make check-counts  - verify README/docs counts match lib/ + t/ + examples/' \
	  '  make install       - s pkg install -g .  (publish to ~/.stryke/store/utils@<ver>/)' \
	  '  make clean         - remove /tmp/stryke-utils-* scratch dirs'

test:
	s test t/

check-counts:
	scripts/check-counts.sh

install:
	s pkg install -g .

clean:
	rm -rf /tmp/stryke-utils-*
