DATE = $(shell date +'%Y-%m-%d')

ES5_SHIM = node_modules/es5-shim/es5-shim.js
ES5_SHAM = node_modules/es5-shim/es5-sham.js
MOCHA = node_modules/mocha/mocha.js
CHAI = node_modules/chai/chai.js
CHAI_AS_PROMISED = node_modules/chai-as-promised/lib/chai-as-promised.js
MOCHA_AS_PROMISED = node_modules/mocha-as-promised/mocha-as-promised.js

BROWSER_TEST_FILES = $(ES5_SHIM) $(ES5_SHAM) $(MOCHA) $(CHAI) $(CHAI_AS_PROMISED) $(MOCHA_AS_PROMISED)

ES6_ALIAS = /node_modules/es6-promise/dist/commonjs/main.js:./lib/promise.js

cjsify = node_modules/commonjs-everywhere/bin/cjsify



## Creating files and folders
## --------------------------------------------------------------------------

.cov: src/*.coffee
	@jscov --expand --conditionals src .cov

lib: src/*.coffee makefile
	@rm -rf lib
	@coffee -co lib src

tmp:
	@mkdir -p tmp

dist:
	@mkdir -p dist

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

browsertest/mocha.css: browsertest
	@cp node_modules/mocha/mocha.css browsertest

browsertest/vendor.js: browsertest
	@cat $(BROWSER_TEST_FILES) > browsertest/vendor.js

browsertest/z-core.js: browsertest dist/z-core.js
	@cp dist/z-core.js browsertest

browsertest/z-core-es6.js: browsertest dist/z-core-es6.js
	@cp dist/z-core-es6.js browsertest

browsertest/index.html: browsertest test/support/test.html browsertest/browserified-tests.js browsertest/vendor.js browsertest/mocha.css browsertest/z-core.js
	@cat test/support/test.html | sed -e 's/ZDIST.js/z-core.js/' > browsertest/index.html

browsertest/es6.html:   browsertest test/support/test.html browsertest/browserified-tests.js browsertest/vendor.js browsertest/mocha.css browsertest/z-core-es6.js
	@cat test/support/test.html | sed -e 's/ZDIST.js/z-core-es6.js/' > browsertest/es6.html

browsertest/browserified-tests.js: browsertest test/* test/**/*
	browserify -t coffeeify test/support/browser.js > browsertest/browserified-tests.js



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
	@mocha --grep "$(TESTS)"

test-browsers: deploy-browser-tests
	@chalcogen --platform saucelabs

run-tests: lib
ifneq ($(CI),true)
	echo "not CI.. only testing in node"
	@make test-node
else ifneq ($(TRAVIS_NODE_VERSION),0.10)
	echo "running node $(TRAVIS_NODE_VERSION).. only testing in node"
	@make test-node
else
	echo "running node $(TRAVIS_NODE_VERSION).. testing everything!"
	@make test-node
	@make test-browsers
endif
