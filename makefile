TAG = $(shell git tag | tail -n 1)
TESTDIR = browsertest

ES5_SHIM = node_modules/es5-shim/es5-shim.js
ES5_SHAM = node_modules/es5-shim/es5-sham.js
MOCHA = node_modules/mocha/mocha.js
CHAI = node_modules/chai/chai.js
CHAI_AS_PROMISED = node_modules/chai-as-promised/lib/chai-as-promised.js
MOCHA_AS_PROMISED = node_modules/mocha-as-promised/mocha-as-promised.js

BROWSER_TEST_FILES = $(ES5_SHIM) $(ES5_SHAM) $(MOCHA) $(CHAI) $(CHAI_AS_PROMISED) $(MOCHA_AS_PROMISED)

DIST_FILENAME = z-core-$(TAG)

ES6_ALIAS = /node_modules/es6-promise/dist/commonjs/main.js:./lib/promise.js

clean:
	rm -rf lib dist browsertest

lib: src/*.coffee
	rm -rf lib
	coffee -co lib src

dist: lib
	make run-node-tests
	mkdir -p dist
	cjsify lib/index.js -x Z -o dist/$(DIST_FILENAME)-es6.js         --alias $(ES6_ALIAS)
	cjsify lib/index.js -x Z -o dist/$(DIST_FILENAME)-es6-min.js --m --alias $(ES6_ALIAS)
	cjsify lib/index.js -x Z -o dist/$(DIST_FILENAME).js
	cjsify lib/index.js -x Z -o dist/$(DIST_FILENAME)-min.js     --m

browsertest: dist test/* test/**/*

	rm -rf browsertest
	mkdir -p $(TESTDIR)/vendor

	cp node_modules/mocha/mocha.css $(TESTDIR)
	cat $(BROWSER_TEST_FILES) > $(TESTDIR)/vendor.js

	cp dist/*.js $(TESTDIR)

	cat test/support/test.html | sed -e 's/ZDIST.js/$(DIST_FILENAME).js/' > $(TESTDIR)/index.html
	cat test/support/test.html | sed -e 's/ZDIST.js/$(DIST_FILENAME)-es6.js/' > $(TESTDIR)/es6.html

	browserify -t coffeeify test/support/browser.js > $(TESTDIR)/browserified-tests.js

deploy-browser-tests: browsertest
	bucketful

run-node-tests:
	mocha --grep "$TESTS"

run-browser-test: deploy-browser-tests
	chalcogen --platform saucelabs

run-tests: lib
ifeq ($(CI),true)
	make run-node-tests
	make run-browser-test
else
	make run-node-tests
endif
