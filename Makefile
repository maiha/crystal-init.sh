SHELL := /bin/bash
USER := $(shell whoami)

.PHONY: all
all:

.PHONY: install
install:
	cp -p crystal-init.sh ~/bin/

.PHONY: test
test:
	@rm -rf tmp foo.cr
	@mkdir tmp
	@cp -pr test/expected/foo.cr tmp/
	@sed -i "s/maiha@wota.jp//" tmp/foo.cr/shard.yml
	@sed -i "s/maiha/$(USER)/g" tmp/foo.cr/{shard.yml,LICENSE,README.md}
	./crystal-init.sh lib foo > /dev/null
	diff -cr tmp/foo.cr foo.cr
