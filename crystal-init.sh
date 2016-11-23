#!/usr/bin/env bash

# A simple wrapper for "crystal init"
#
# Usage: crystal-init (lib|app) NAME

set -eu

TYPE=${1:?"specify project type 'lib' or 'app'"}
NAME=${2:?"specify project NAME"}

VERSION=$(crystal -v | cut -d' ' -f2)
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
sed -i "s/\b${NAME}\b/${NAME}.cr/g"         README.md
sed -i "s/\[your-github-name\]/$(whoami)/g" README.md
sed -i "s!^.*description.*\$!${DESC}!"      README.md

# src
rm src/${NAME}/version.cr

# shard.yml
sed -i "s/^name:.*\$/name: ${NAME}.cr/" shard.yml

# .travis.yml
cat >> .travis.yml <<EOF
sudo: false
script:
  - make test
EOF

# Makefile
cat >> Makefile <<EOF
.PHONY : test
test: spec

.PHONY : spec
spec:
	crystal spec -v --fail-fast
EOF

######################################################################
### DONE
echo "$(tput setaf 2)cd ${NAME}.cr"
