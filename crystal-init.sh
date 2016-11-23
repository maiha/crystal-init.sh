#!/usr/bin/env bash

# A simple wrapper for "crystal init"
#
# Usage: crystal-init (lib|app) NAME

set -eu

TYPE=${1:?"specify project type 'lib' or 'app'"}
NAME=${2:?"specify project NAME"}

VERSION=$(crystal -v | cut -d' ' -f2)
DESC="${NAME} for [Crystal](http://crystal-lang.org/).\n\n- crystal: ${VERSION}"

run() {
  eval $1
}

# project
run "crystal init ${TYPE} ${NAME}"
run "mv ${NAME} ${NAME}.cr"
run "cd ${NAME}.cr"
run "echo /.crystal-version > .gitignore"

# README.md
run "sed -i 's/\b${NAME}\b/${NAME}.cr/g' README.md"
run "sed -i 's/\[your-github-name\]/$(whoami)/g' README.md"
run "sed -i 's!^.*description.*\$!${DESC}!' README.md"

# src
run "rm src/${NAME}/version.cr"

# done!
echo "$(tput setaf 2)cd ${NAME}.cr"

