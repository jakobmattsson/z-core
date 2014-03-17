DATE = $(shell date +'%Y-%m-%d')

MOCHA = node_modules/mocha/mocha.js
CHAI = node_modules/chai/chai.js
CHAI_AS_PROMISED = node_modules/chai-as-promised/lib/chai-as-promised.js

BROWSER_TEST_FILES = $(MOCHA) $(CHAI) $(CHAI_AS_PROMISED)

ES6_ALIAS = /node_modules/es6-promise/dist/commonjs/main.js:./lib/promise.js

cjsify = node_modules/commonjs-everywhere/bin/cjsify

TEST_FILES = $(shell find test -name *.coffee)


## Creating files and folders
## --------------------------------------------------------------------------

.cov: src/*.coffee
	@jscov --expand --conditionals src .cov

lib: src/*.coffee makefile
	@rm -rf lib
	@coffee -co lib src

tmp:
	@mkdir -p tmp

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

browsertest:
	@mkdir -p browsertest

browsertest/vendor.css: browsertest
	@cp node_modules/mocha/mocha.css browsertest/vendor.css

browsertest/vendor.js: browsertest
	@cat $(BROWSER_TEST_FILES) > browsertest/vendor.js

browsertest/z-core.js: browsertest dist/z-core.js
	@cp dist/z-core.js browsertest

browsertest/z-core-es6.js: browsertest dist/z-core-es6.js
	@cp dist/z-core-es6.js browsertest

browsertest/index.html: browsertest test/support/test.html browsertest/browserified-tests.js browsertest/vendor.js browsertest/vendor.css browsertest/z-core.js
	@cat test/support/test.html | sed -e 's/ZDIST.js/z-core.js/' > browsertest/index.html

browsertest/es6.html:   browsertest test/support/test.html browsertest/browserified-tests.js browsertest/vendor.js browsertest/vendor.css browsertest/z-core-es6.js
	@cat test/support/test.html | sed -e 's/ZDIST.js/z-core-es6.js/' > browsertest/es6.html

browsertest/browserified-tests.js: browsertest $(TEST_FILES) package.json
	find test -type f -name *.coffee ! -iname "versions.coffee" -exec $(cjsify) {} --no-node \; > browsertest/browserified-tests.js



## Tasks
## --------------------------------------------------------------------------

clean:
	@rm -rf lib browsertest tmp .cov

update-dist: dist/z-core-es6.js dist/z-core-es6-min.js dist/z-core.js dist/z-core-min.js

compile-browser-tests: browsertest/index.html browsertest/es6.html

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
