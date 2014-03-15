# Z [![Build Status](https://secure.travis-ci.org/jakobmattsson/z-core.png)](http://travis-ci.org/jakobmattsson/z-core)

Utility library for JavaScript promises


### Installation

Use npm: `npm install z-core` and then `var Z = require('z-core');`

Or bower: (not uploaded yet)

Or download it manually from the `dist` folder of this repo.



### Wrapping functions to accept promises as parameters and return promises

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


### Use a prepackaged version of Z

There are several mixin packages available for your convenience:

* [Builtins](https://github.com/jakobmattsson/z-builtins)
* [Underscore](https://github.com/jakobmattsson/z-underscore)
* more to come...

And even bundles where certain set of mixins have already been applied:

* [z-std-pack](https://github.com/jakobmattsson/z-std-pack): Z, builtins and underscore bundled together.



### Additional resources

[Slides from 2014-02-25 presentation on Z](https://speakerdeck.com/jakobmattsson/how-to-star-actually-star-use-promises-in-javascript)

[Code from the above presentation](https://github.com/jakobmattsson/z-presentation)
