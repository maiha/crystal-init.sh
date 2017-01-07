SHELL=/bin/bash

.PHONY: all
all:

.PHONY: install
install:
	cp -p crystal-init.sh ~/bin/

.PHONY: test
test:
	 docker run --rm -t -v ${PWD}:/mnt:ro -w /tmp -e LIBRARY_PATH="/opt/crystal/embedded/lib/" crystallang/crystal make -f /mnt/Makefile test_in_docker

.PHONY: test_in_docker
test_in_docker:
	/mnt/crystal-init.sh lib foo
	sed -i -e "s/root/travis/g" foo.cr/README.md
	diff -x .git -cr /mnt/test/expected/foo.cr foo.cr

.PHONY: travisci
travisci:
	@rm -rf foo.cr
	./crystal-init.sh lib foo
	rmdir foo.cr/src/foo
	diff -x .git -cr test/expected/foo.cr foo.cr

