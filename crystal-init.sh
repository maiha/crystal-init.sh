#!/usr/bin/env bash

# A simple wrapper for "crystal init"
#
# Usage: crystal-init (lib|app) NAME

set -eu

TYPE=${1:?"specify project type 'lib' or 'app'"}
NAME=${2:?"specify project NAME"}

VERSION=$(crystal -v | head -1 | cut -d' ' -f2)
DESC="${NAME} for [Crystal](http://crystal-lang.org/).\n\n- crystal: ${VERSION}"

######################################################################
### MAIN

# project
crystal init ${TYPE} ${NAME}
mv ${NAME} ${NAME}.cr
cd ${NAME}.cr

# .gitignore
echo "/.crystal-version" >> .gitignore

# README.md
sed -i "s/^# ${NAME}\b/# ${NAME}.cr/g"      README.md
sed -i "s!^    github:.*\$!    github: $(whoami)/${NAME}.cr\n    version: 0.1.0!" README.md
sed -i "s/\[your-github-name\]/$(whoami)/g" README.md
sed -i "s/\[your-github-user\]/$(whoami)/g" README.md
sed -i "s!^.*description.*\$!${DESC}!"      README.md
sed -i "s!/${NAME}/fork!/${NAME}.cr/fork!"  README.md

# src
rm src/${NAME}/version.cr

# shard.yml
sed -i -e "/^crystal:/d" shard.yml

# .travis.yml
cat >> .travis.yml <<EOF
sudo: false
script:
  - make test
EOF

# Makefile
cat > Makefile <<'EOF'
SHELL=/bin/bash

VERSION=
CURRENT_VERSION=$(shell git tag -l | sort -V | tail -1)
GUESSED_VERSION=$(shell git tag -l | sort -V | tail -1 | awk 'BEGIN { FS="." } { $$3++; } { printf "%d.%d.%d", $$1, $$2, $$3 }')

.SHELLFLAGS = -o pipefail -c

.PHONY : test
test: check_version_mismatch spec

.PHONY : spec
spec:
	crystal spec -v --fail-fast

.PHONY : check_version_mismatch
check_version_mismatch: shard.yml README.md
	diff -w -c <(grep version: README.md) <(grep ^version: shard.yml)

.PHONY : version
version:
	@if [ "$(VERSION)" = "" ]; then \
	  echo "ERROR: specify VERSION as bellow. (current: $(CURRENT_VERSION))";\
	  echo "  make version VERSION=$(GUESSED_VERSION)";\
	else \
	  sed -i -e 's/^version: .*/version: $(VERSION)/' shard.yml ;\
	  sed -i -e 's/^    version: [0-9]\+\.[0-9]\+\.[0-9]\+/    version: $(VERSION)/' README.md ;\
	  echo git commit -a -m "'$(COMMIT_MESSAGE)'" ;\
	  git commit -a -m 'version: $(VERSION)' ;\
	  git tag "v$(VERSION)" ;\
	fi

.PHONY : bump
bump:
	make version VERSION=$(GUESSED_VERSION) -s
EOF

######################################################################
### DONE
echo "$(tput setaf 2)cd ${NAME}.cr$(tput sgr0)"
