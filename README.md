# Z

Utility library for JavaScript promises

[![Build Status](https://secure.travis-ci.org/jakobmattsson/z-core.png)](http://travis-ci.org/jakobmattsson/z-core)
[![Coverage Status](https://coveralls.io/repos/jakobmattsson/z-core/badge.png?branch=master)](https://coveralls.io/r/jakobmattsson/z-core?branch=master)
[![NPM version](https://badge.fury.io/js/z-core.png)](http://badge.fury.io/js/z-core)

[![Selenium Test Status](https://saucelabs.com/browser-matrix/jakobmattsson-zcore.svg)](https://saucelabs.com/u/jakobmattsson-zcore)



### Installation

Option 1, npm: `npm install z-core` and then `var Z = require('z-core');`

Option 2, bower: `bower install z-core`

Option 3, download it manually from the `dist` folder of this repo.

If you care about shaving off some bytes and you only target ES6-compatible environments, then you can use `z-core-es6.js`. It assumes that there is a native promise-implementation, as provided by ES6. The standard Z implementation comes with a small polyfill though.

Minimified (not gziped) the code is about 10k for the standard version, compatibile with all environments, and about 4k for the ES6-version.

### Functions can now accept promises as arguments

Use `bindSync` to create promise-friendly functions from sync functions.

```js
var pmin = Z.bindSync(Math.min);

// It can still be called with regular values
pmin(10, 5).then(function(minValue) {
  console.log(minValue); // 5
});

// But is can also be called with promises
var promise = returnsTheValue2AsPromise();
pmin(promise, 5).then(function(minValue) {
  console.log(minValue); // 2
});
```

Use `bindAsync` to create promise-friendly functions from async functions.

```js
var postPromisedJSON = Z.bindAsync(postJSON);
var agePromise = returnsTheValue28AsPromise();

// Note that it's called with a mix of regular values an promises
postPromisedJSON('/people', { name: 'Jakob', age: agePromise }).then(function(res) {
  console.log(res); // the result of the request
});
```


### Augmenting promises

Extend the promises returned by Z using mixins.

```js
Z.mixin({
  get: function(prop) {
    return this.value[prop];
  },
  toLowerCase: function() {
    return this.value.toLowerCase();
  },
  first: function(n) {
    if (n == null) {
      n = 1;
    }
    return this.value.slice(0, n);
  },
  log: function() {
    console.log(this.value);
  }
});

var getPromisedJSON = Z.bindAsync(getJSON);

var firstThreeInName = getPromisedJSON('/cookies/123').get('name').toLowerCase().first(3);

firstThreeInName.log();
```


### Using a prepackaged version of Z

There are several mixin packages available for your convenience:

* [Builtins](https://github.com/jakobmattsson/z-builtins)
* [Underscore](https://github.com/jakobmattsson/z-underscore)
* more to come...

And even bundles where certain set of mixins have already been applied:

* [z-std-pack](https://github.com/jakobmattsson/z-std-pack): Z, builtins and underscore bundled together.



### Additional resources

[Slides from 2014-02-25 presentation on Z](https://speakerdeck.com/jakobmattsson/how-to-star-actually-star-use-promises-in-javascript)

[Code from the above presentation](https://github.com/jakobmattsson/z-presentation)
