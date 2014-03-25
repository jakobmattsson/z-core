DATE = $(shell date +'%Y-%m-%d')
GIT_STATUS = $(shell git status --porcelain)
GIT_BRANCH = $(shell git rev-parse --abbrev-ref HEAD)

CHAI = node_modules/chai/chai.js
CHAI_AS_PROMISED = node_modules/chai-as-promised/lib/chai-as-promised.js

ES6_ALIAS = /node_modules/es6-promise/dist/commonjs/main.js:./lib/promise.js

cjsify = node_modules/commonjs-everywhere/bin/cjsify

TEST_FILES = $(shell find test -name *.coffee)
LIBS = $(CHAI) $(CHAI_AS_PROMISED)

MOCHA_PARAMS = --compilers coffee:coffee-script/register --require test/support/node.js


## Creating files and folders
## ==========================================================================

.cov: src/*.coffee
	@jscov --expand --conditionals src .cov

lib: src/*.coffee makefile
	@rm -rf lib
	@coffee -co lib src

tmp:
	@mkdir -p tmp



# Distribution files
# ------------------

tmp/dist-header.txt: package.json tmp
	@echo "// z-core v`cat package.json | json version`\n// Jakob Mattsson $(DATE)" > tmp/dist-header.txt

dist/z-core-es6.js: lib dist tmp/dist-header.txt
	@$(cjsify) lib/index.js --no-node -x Z     --alias $(ES6_ALIAS) | cat tmp/dist-header.txt - > dist/z-core-es6.js

dist/z-core-es6-min.js: lib dist tmp/dist-header.txt
	@$(cjsify) lib/index.js --no-node -x Z --m --alias $(ES6_ALIAS) | cat tmp/dist-header.txt - > dist/z-core-es6-min.js

dist/z-core.js: lib dist tmp/dist-header.txt
	@$(cjsify) lib/index.js --no-node -x Z                          | cat tmp/dist-header.txt - > dist/z-core.js

dist/z-core-min.js: lib dist tmp/dist-header.txt
	@$(cjsify) lib/index.js --no-node -x Z --m                      | cat tmp/dist-header.txt - > dist/z-core-min.js



# Browser test files
# ------------------

tmp/browsertest:
	@mkdir -p tmp/browsertest

tmp/test-vendor.js: package.json tmp $(LIBS) test/support/browser.js
	@cat $(LIBS) test/support/browser.js > tmp/vendor.js

tmp/test-cases.js: package.json tmp $(TEST_FILES)
	@find test -type f -name *.coffee ! -iname "versions.coffee" -exec $(cjsify) {} --no-node \; > tmp/tests.js

tmp/browsertest/es6/tests.js: package.json tmp/browsertest tmp/test-vendor.js tmp/test-cases.js dist/z-core-es6.js
	@mocha init tmp/browsertest/es6
	@cat tmp/vendor.js dist/z-core-es6.js tmp/tests.js > tmp/browsertest/es6/tests.js

tmp/browsertest/default/tests.js: package.json tmp/browsertest tmp/test-vendor.js tmp/test-cases.js dist/z-core.js
	@mocha init tmp/browsertest/default
	@cat tmp/vendor.js dist/z-core.js tmp/tests.js > tmp/browsertest/default/tests.js



## Tasks
## ==========================================================================

clean:
	@rm -rf lib tmp .cov

update-dist: dist/z-core-es6.js dist/z-core-es6-min.js dist/z-core.js dist/z-core-min.js

compile-browser-tests: tmp/browsertest/es6/tests.js tmp/browsertest/default/tests.js

deploy-browser-tests: compile-browser-tests
	@bucketful

test-coverage: .cov
	@JSCOV=.cov mocha --reporter mocha-term-cov-reporter $(MOCHA_PARAMS)

test-coveralls: .cov
	@JSCOV=.cov mocha --reporter mocha-lcov-reporter $(MOCHA_PARAMS) | coveralls src

test-node:
	@mocha --grep "$(TESTS)" $(MOCHA_PARAMS)

test-browsers: deploy-browser-tests
	@chalcogen --platform saucelabs

run-local: compile-browser-tests
	@nws -p 5555 -d tmp/browsertest

run-tests: lib
ifneq ($(CI),true)
	# Not running CI; only testing in node
	@make test-node
else ifneq ($(TRAVIS_NODE_VERSION),0.10)
	# Running CI in a node version other than 0.10; only testing in node
	@make test-node
else
	# Running CI in a node 0.10 - testing node AND coverage AND browsers!
	@make test-node
	@make test-coveralls
	@make test-browsers
endif

release:
ifneq "$(GIT_STATUS)" ""
	@echo "clean up your changes first"
else ifneq "$(GIT_BRANCH)" "master"
	@echo "You can only release from the master branch"
else
	@npm test
	@json -I -e "version='$(VERSION)'" -f bower.json
	@json -I -e "version='$(VERSION)'" -f package.json
	@make update-dist
	@git add bower.json package.json dist/*.js
	@git commit -m v$(VERSION)
	@git tag -a v$(VERSION) -m v$(VERSION)
	@git push --follow-tags
endif
