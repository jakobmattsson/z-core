TESTDIR="browsertest"

# Copy dependencies
mkdir -p $TESTDIR/vendor
cp node_modules/chai/chai.js $TESTDIR/vendor
cp node_modules/chai-as-promised/lib/chai-as-promised.js $TESTDIR/vendor
cp node_modules/mocha-as-promised/mocha-as-promised.js $TESTDIR/vendor
cp node_modules/mocha/mocha.css $TESTDIR/vendor
cp node_modules/mocha/mocha.js $TESTDIR/vendor
cp node_modules/q/q.js $TESTDIR/vendor
cp node_modules/underscore/underscore.js $TESTDIR/vendor
cp node_modules/underscore.string/lib/underscore.string.js $TESTDIR/vendor
cp node_modules/es5-shim/es5-shim.js $TESTDIR/vendor
cp node_modules/es5-shim/es5-sham.js $TESTDIR/vendor
cp test/support/test.html $TESTDIR/index.html

# Produce the latest distribution of Z
npm run make-dist
cp dist/latest.js $TESTDIR/latest-dist.js

# Bundle the tests for the browser
browserify -t coffeeify test/support/browser.js > $TESTDIR/browserified-tests.js
