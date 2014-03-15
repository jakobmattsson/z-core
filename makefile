TAG = $(shell git tag | tail -n 1)
DATE = $(shell date +'%Y-%m-%d')
TESTDIR = browsertest

ES5_SHIM = node_modules/es5-shim/es5-shim.js
ES5_SHAM = node_modules/es5-shim/es5-sham.js
MOCHA = node_modules/mocha/mocha.js
CHAI = node_modules/chai/chai.js
CHAI_AS_PROMISED = node_modules/chai-as-promised/lib/chai-as-promised.js
MOCHA_AS_PROMISED = node_modules/mocha-as-promised/mocha-as-promised.js

BROWSER_TEST_FILES = $(ES5_SHIM) $(ES5_SHAM) $(MOCHA) $(CHAI) $(CHAI_AS_PROMISED) $(MOCHA_AS_PROMISED)

ES6_ALIAS = /node_modules/es6-promise/dist/commonjs/main.js:./lib/promise.js

cjsify = node_modules/commonjs-everywhere/bin/cjsify

clean:
	@rm -rf lib dist browsertest tmp

lib: src/*.coffee
	@rm -rf lib
	@coffee -co lib src

dist: lib makefile
	@make run-node-tests
	@mkdir -p dist tmp

	echo "// z-core $(TAG)\n// Jakob Mattsson $(DATE)" > tmp/header.txt

	$(cjsify) lib/index.js --no-node -x Z     --alias $(ES6_ALIAS) | cat tmp/header.txt - > dist/z-core-es6.js
	$(cjsify) lib/index.js --no-node -x Z --m --alias $(ES6_ALIAS) | cat tmp/header.txt - > dist/z-core-es6-min.js
	$(cjsify) lib/index.js --no-node -x Z                          | cat tmp/header.txt - > dist/z-core.js
	$(cjsify) lib/index.js --no-node -x Z --m                      | cat tmp/header.txt - > dist/z-core-min.js

browsertest: dist test/* test/**/* makefile

	rm -rf browsertest
	mkdir -p $(TESTDIR)/vendor

	cp node_modules/mocha/mocha.css $(TESTDIR)
	cat $(BROWSER_TEST_FILES) > $(TESTDIR)/vendor.js

	cp dist/*.js $(TESTDIR)

	cat test/support/test.html | sed -e 's/ZDIST.js/z-core.js/' | $(TESTDIR)/index.html
	cat test/support/test.html | sed -e 's/ZDIST.js/z-core-es6.js/' | $(TESTDIR)/es6.html

	browserify -t coffeeify test/support/browser.js > $(TESTDIR)/browserified-tests.js

deploy-browser-tests: browsertest
	@bucketful

run-node-tests:
	@mocha --grep "$(TESTS)"

run-browser-test: deploy-browser-tests
	@chalcogen --platform saucelabs

run-tests: lib
ifeq ($(CI),true)
	@make run-node-tests
	@make run-browser-test
else
	@make run-node-tests
endif
