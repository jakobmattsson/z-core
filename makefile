DATE = $(shell date +'%Y-%m-%d')

CHAI = node_modules/chai/chai.js
CHAI_AS_PROMISED = node_modules/chai-as-promised/lib/chai-as-promised.js

ES6_ALIAS = /node_modules/es6-promise/dist/commonjs/main.js:./lib/promise.js

cjsify = node_modules/commonjs-everywhere/bin/cjsify

TEST_FILES = $(shell find test -name *.coffee)
LIBS = $(CHAI) $(CHAI_AS_PROMISED)



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
	$(cjsify) lib/index.js --no-node -x Z     --alias $(ES6_ALIAS) | cat tmp/dist-header.txt - > dist/z-core-es6.js

dist/z-core-es6-min.js: lib dist tmp/dist-header.txt
	$(cjsify) lib/index.js --no-node -x Z --m --alias $(ES6_ALIAS) | cat tmp/dist-header.txt - > dist/z-core-es6-min.js

dist/z-core.js: lib dist tmp/dist-header.txt
	$(cjsify) lib/index.js --no-node -x Z                          | cat tmp/dist-header.txt - > dist/z-core.js

dist/z-core-min.js: lib dist tmp/dist-header.txt
	$(cjsify) lib/index.js --no-node -x Z --m                      | cat tmp/dist-header.txt - > dist/z-core-min.js



# Browser test files
# ------------------

browsertest:
	@mkdir -p browsertest

tmp/test-vendor.js: package.json tmp $(LIBS) test/support/browser.js
	@cat $(LIBS) test/support/browser.js > tmp/vendor.js

tmp/test-cases.js: package.json tmp $(TEST_FILES)
	find test -type f -name *.coffee ! -iname "versions.coffee" -exec $(cjsify) {} --no-node \; > tmp/tests.js

browsertest/es6/tests.js: package.json browsertest tmp/test-vendor.js tmp/test-cases.js dist/z-core-es6.js
	@mocha init browsertest/es6
	@cat tmp/vendor.js dist/z-core-es6.js tmp/tests.js > browsertest/es6/tests.js

browsertest/default/tests.js: package.json browsertest tmp/test-vendor.js tmp/test-cases.js dist/z-core.js
	@mocha init browsertest/default
	@cat tmp/vendor.js dist/z-core.js tmp/tests.js > browsertest/default/tests.js



## Tasks
## ==========================================================================

clean:
	@rm -rf lib browsertest tmp .cov

update-dist: dist/z-core-es6.js dist/z-core-es6-min.js dist/z-core.js dist/z-core-min.js

compile-browser-tests: browsertest/es6/tests.js browsertest/default/tests.js

deploy-browser-tests: compile-browser-tests
	@bucketful

test-coverage: .cov
	@JSCOV=.cov mocha --reporter mocha-term-cov-reporter

test-node:
	@mocha --grep "$(TESTS)" --compilers coffee:coffee-script/register --require test/support/node.js

test-browsers: deploy-browser-tests
	@chalcogen --platform saucelabs

run-tests: lib
ifneq ($(CI),true)
	# Not running CI; only testing in node
	@make test-node
else ifneq ($(TRAVIS_NODE_VERSION),0.10)
	# Running CI in a node version other than 0.10; only testing in node
	@make test-node
else
	# Running CI in a node 0.10 - testing node AND browsers!
	@make test-node
	@make test-browsers
endif
