DATE = $(shell date +'%Y-%m-%d')
GIT_STATUS = $(shell git status --porcelain)
GIT_BRANCH = $(shell git rev-parse --abbrev-ref HEAD)

CHAI = node_modules/chai/chai.js
CHAI_AS_PROMISED = node_modules/chai-as-promised/lib/chai-as-promised.js

ES6_ALIAS = /node_modules/es6-promise/dist/commonjs/main.js:./lib/promise.js

cjsify = node_modules/commonjs-everywhere/bin/cjsify

TEST_FILES = $(shell find test -name *.coffee; find test -name *.js)
LIBS = $(CHAI) $(CHAI_AS_PROMISED)

MOCHA_PARAMS = --compilers coffee:coffee-script/register --require test/support/node.js

NODE_TARGET_VERSION = 0.10

SOURCE_FILES=$(shell find src -name *.coffee)
TARGET_FILES=$(SOURCE_FILES:src/%.coffee=lib/%.js)



BROWSERTEST_OUTPUT_FILES = tmp/browsertest/es6/tests.js tmp/browsertest/default/tests.js



## Creating files and folders
## ==========================================================================

tmp tmp/browsertest:
	@mkdir -p $@

.cov: $(SOURCE_FILES)
	@jscov --expand --conditionals src .cov

lib/%.js: src/%.coffee
	@coffee -co lib $?



# Distribution files
# ------------------

tmp/dist-header.txt: package.json tmp
	@echo "// z-core v`cat package.json | json version`\n// Jakob Mattsson $(DATE)" > $@

dist/z-core-es6.js: $(TARGET_FILES) dist tmp/dist-header.txt
	@$(cjsify) lib/index.js --no-node -x Z     --alias $(ES6_ALIAS) | cat tmp/dist-header.txt - > $@

dist/z-core-es6-min.js: $(TARGET_FILES) dist tmp/dist-header.txt
	@$(cjsify) lib/index.js --no-node -x Z --m --alias $(ES6_ALIAS) | cat tmp/dist-header.txt - > $@

dist/z-core.js: $(TARGET_FILES) dist tmp/dist-header.txt
	@$(cjsify) lib/index.js --no-node -x Z                          | cat tmp/dist-header.txt - > $@

dist/z-core-min.js: $(TARGET_FILES) dist tmp/dist-header.txt
	@$(cjsify) lib/index.js --no-node -x Z --m                      | cat tmp/dist-header.txt - > $@



# Browser test files
# ------------------

tmp/vendor.js: package.json tmp $(LIBS) test/support/browser.js
	@cat $(LIBS) test/support/browser.js > $@

tmp/tests.js: package.json tmp $(TEST_FILES)
	@find test -type f -name *.coffee ! -iname "versions.coffee" -exec $(cjsify) {} --no-node \; > $@

tmp/browsertest/es6/tests.js: package.json tmp/browsertest tmp/vendor.js tmp/tests.js dist/z-core-es6.js
	@mocha init tmp/browsertest/es6
	@cat tmp/vendor.js dist/z-core-es6.js tmp/tests.js > $@

tmp/browsertest/default/tests.js: package.json tmp/browsertest tmp/vendor.js tmp/tests.js dist/z-core.js
	@mocha init tmp/browsertest/default
	@cat tmp/vendor.js dist/z-core.js tmp/tests.js > $@



## Internal tasks
## ==========================================================================

test-coverage: $(TARGET_FILES) .cov
	@JSCOV=.cov mocha --reporter mocha-term-cov-reporter $(MOCHA_PARAMS)

test-coveralls: $(TARGET_FILES) .cov
	@JSCOV=.cov mocha --reporter mocha-lcov-reporter $(MOCHA_PARAMS)

test-node: $(TARGET_FILES)
	@mocha --grep "$(TESTS)" $(MOCHA_PARAMS)




## Tasks
## ==========================================================================

clean:
	@rm -rf lib tmp .cov

deploy-browser-tests: $(BROWSERTEST_OUTPUT_FILES)
	@bucketful

test-browsers: deploy-browser-tests
	@chalcogen --platform sauceunit

run-local: $(BROWSERTEST_OUTPUT_FILES)
	@nws -p 5555 -d tmp/browsertest

watch:
	watchman watch $(shell pwd)
	watchman -f --log-level 2 -- trigger $(shell pwd) blabla41 'src/*.coffee' -- make apa

apa: $(BROWSERTEST_OUTPUT_FILES)
	open http://localhost:5555/default

run-tests:
ifneq ($(CI),true)
	# Not running CI; only testing in node and showing code coverage
	@make test-node
	@make test-coverage
else ifneq ($(TRAVIS_NODE_VERSION),$(NODE_TARGET_VERSION))
	# Running CI in a node version other than the target version; only testing in node
	@make test-node
else
	# Running CI in the target version of node - testing node AND coverage AND browsers!
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
	@make dist/z-core-es6.js dist/z-core-es6-min.js dist/z-core.js dist/z-core-min.js
	@git add bower.json package.json dist/*.js
	@git commit -m v$(VERSION)
	@git tag -a v$(VERSION) -m v$(VERSION)
	@git push --follow-tags
endif
