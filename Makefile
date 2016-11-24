SHELL=/bin/bash

.PHONY: all
all:

.PHONY: install
install:
	cp -p crystal-init.sh ~/bin/

.PHONY: test
test:
	@rm -rf foo.cr
	./crystal-init.sh lib foo > /dev/null
	@sed -i "s/maiha/$$(whoami)/g" foo.cr/{shard.yml,LICENSE,README.md}
	diff -cr test/expected/foo.cr foo.cr
