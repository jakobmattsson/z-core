// z-core v0.5.3
// Jakob Mattsson 2014-03-16
// Generated by CommonJS Everywhere 0.9.7
(function (global) {
  function require(file, parentModule) {
    if ({}.hasOwnProperty.call(require.cache, file))
      return require.cache[file];
    var resolved = require.resolve(file);
    if (!resolved)
      throw new Error('Failed to resolve module ' + file);
    var module$ = {
        id: file,
        require: require,
        filename: file,
        exports: {},
        loaded: false,
        parent: parentModule,
        children: []
      };
    if (parentModule)
      parentModule.children.push(module$);
    var dirname = file.slice(0, file.lastIndexOf('/') + 1);
    require.cache[file] = module$.exports;
    resolved.call(module$.exports, module$, module$.exports, dirname, file);
    module$.loaded = true;
    return require.cache[file] = module$.exports;
  }
  require.modules = {};
  require.cache = {};
  require.resolve = function (file) {
    return {}.hasOwnProperty.call(require.modules, file) ? require.modules[file] : void 0;
  };
  require.define = function (file, fn) {
    require.modules[file] = fn;
  };
  require.define('/lib/index.js', function (module, exports, __dirname, __filename) {
    (function () {
      var Promise, init, isArray, isPrimitive, keys, makeZ, object, objectCreate, pairs, proc, resolveAll, resolveCompletely, tools, values, __slice = [].slice;
      tools = require('/lib/tools.js', module);
      Promise = require('/node_modules/es6-promise/dist/commonjs/main.js', module).Promise;
      pairs = tools.pairs, keys = tools.keys, values = tools.values, object = tools.object, resolveAll = tools.resolveAll, isPrimitive = tools.isPrimitive, isArray = tools.isArray, objectCreate = tools.objectCreate, proc = tools.proc;
      resolveCompletely = function (unresolved, depth) {
        return resolveAll([unresolved]).then(function (_arg) {
          var resolved, unresolvedValues;
          resolved = _arg[0];
          if (depth <= 0 || resolved == null || isPrimitive(resolved)) {
            return resolved;
          }
          if (isArray(resolved)) {
            return resolveAll(resolved.map(function (x) {
              return resolveCompletely(x, depth - 1);
            }));
          }
          unresolvedValues = resolveAll(values(resolved).map(function (x) {
            return resolveCompletely(x, depth - 1);
          }));
          return unresolvedValues.then(function (resolvedValues) {
            return object(keys(resolved), resolvedValues);
          });
        });
      };
      init = function (defaultConf) {
        var Z, mixedIn, mixinObj, updateMixinObj;
        mixedIn = {};
        mixinObj = {};
        updateMixinObj = function () {
          return pairs(mixedIn).forEach(function (_arg) {
            var func, name;
            name = _arg[0], func = _arg[1];
            return mixinObj[name] = function () {
              var args;
              args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
              return this.then(function (resolved) {
                return resolveCompletely(args, 1).then(function (args) {
                  return func.apply({ value: resolved }, args);
                });
              });
            };
          });
        };
        Z = function (obj, conf) {
          var key, overrideLayer, resolvedObject, resultingPromise, value, _ref;
          conf = (_ref = conf != null ? conf : defaultConf) != null ? _ref : {};
          if (typeof conf.depth === 'undefined') {
            conf.depth = 1;
          }
          if (conf.depth === null) {
            conf.depth = 1e6;
          }
          resolvedObject = resolveCompletely(obj, conf.depth);
          overrideLayer = objectCreate(resolvedObject);
          resultingPromise = objectCreate(overrideLayer);
          overrideLayer.then = function () {
            var args;
            args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
            return Z(resolvedObject.then.apply(resolvedObject, args));
          };
          for (key in mixinObj) {
            value = mixinObj[key];
            resultingPromise[key] = value;
          }
          return resultingPromise;
        };
        Z.mixin = proc(function (hash) {
          pairs(hash).forEach(function (_arg) {
            var func, name, oldOne;
            name = _arg[0], func = _arg[1];
            oldOne = mixedIn[name];
            return mixedIn[name] = function () {
              var context;
              context = { value: this.value };
              if (oldOne) {
                context.base = oldOne;
              }
              return func.apply(context, arguments);
            };
          });
          return updateMixinObj();
        });
        Z.bindSync = function (func, context) {
          return function () {
            var unresolvedArgs;
            unresolvedArgs = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
            return Z(unresolvedArgs).then(function (_this) {
              return function (args) {
                return func.apply(context != null ? context : _this, args);
              };
            }(this));
          };
        };
        Z.bindAsync = function (func, context) {
          return function () {
            var ctx, unresolvedArgs;
            unresolvedArgs = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
            ctx = context != null ? context : this;
            return Z(unresolvedArgs).then(function (args) {
              return new Promise(function (resolve, reject) {
                var ex;
                args.push(function () {
                  var err, result;
                  err = arguments[0], result = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
                  if (err != null) {
                    return reject(err);
                  } else if (result.length === 1) {
                    return resolve(result[0]);
                  } else {
                    return resolve(result);
                  }
                });
                try {
                  return func.apply(ctx, args);
                } catch (_error) {
                  ex = _error;
                  return reject(ex);
                }
              });
            });
          };
        };
        return Z;
      };
      makeZ = function () {
        var Z;
        Z = init();
        Z.init = init;
        return Z;
      };
      if (typeof window !== 'undefined' && typeof window.require === 'undefined') {
        window.Z = makeZ();
      }
      if (typeof module !== 'undefined') {
        module.exports = makeZ();
      }
    }.call(this));
  });
  require.define('/node_modules/es6-promise/dist/commonjs/main.js', function (module, exports, __dirname, __filename) {
    'use strict';
    var Promise = require('/node_modules/es6-promise/dist/commonjs/promise/promise.js', module).Promise;
    var polyfill = require('/node_modules/es6-promise/dist/commonjs/promise/polyfill.js', module).polyfill;
    exports.Promise = Promise;
    exports.polyfill = polyfill;
  });
  require.define('/node_modules/es6-promise/dist/commonjs/promise/polyfill.js', function (module, exports, __dirname, __filename) {
    'use strict';
    var RSVPPromise = require('/node_modules/es6-promise/dist/commonjs/promise/promise.js', module).Promise;
    var isFunction = require('/node_modules/es6-promise/dist/commonjs/promise/utils.js', module).isFunction;
    function polyfill() {
      var es6PromiseSupport = 'Promise' in window && 'cast' in window.Promise && 'resolve' in window.Promise && 'reject' in window.Promise && 'all' in window.Promise && 'race' in window.Promise && function () {
          var resolve;
          new window.Promise(function (r) {
            resolve = r;
          });
          return isFunction(resolve);
        }();
      if (!es6PromiseSupport) {
        window.Promise = RSVPPromise;
      }
    }
    exports.polyfill = polyfill;
  });
  require.define('/node_modules/es6-promise/dist/commonjs/promise/utils.js', function (module, exports, __dirname, __filename) {
    'use strict';
    function objectOrFunction(x) {
      return isFunction(x) || typeof x === 'object' && x !== null;
    }
    function isFunction(x) {
      return typeof x === 'function';
    }
    function isArray(x) {
      return Object.prototype.toString.call(x) === '[object Array]';
    }
    var now = Date.now || function () {
        return new Date().getTime();
      };
    exports.objectOrFunction = objectOrFunction;
    exports.isFunction = isFunction;
    exports.isArray = isArray;
    exports.now = now;
  });
  require.define('/node_modules/es6-promise/dist/commonjs/promise/promise.js', function (module, exports, __dirname, __filename) {
    'use strict';
    var config = require('/node_modules/es6-promise/dist/commonjs/promise/config.js', module).config;
    var configure = require('/node_modules/es6-promise/dist/commonjs/promise/config.js', module).configure;
    var objectOrFunction = require('/node_modules/es6-promise/dist/commonjs/promise/utils.js', module).objectOrFunction;
    var isFunction = require('/node_modules/es6-promise/dist/commonjs/promise/utils.js', module).isFunction;
    var now = require('/node_modules/es6-promise/dist/commonjs/promise/utils.js', module).now;
    var cast = require('/node_modules/es6-promise/dist/commonjs/promise/cast.js', module).cast;
    var all = require('/node_modules/es6-promise/dist/commonjs/promise/all.js', module).all;
    var race = require('/node_modules/es6-promise/dist/commonjs/promise/race.js', module).race;
    var staticResolve = require('/node_modules/es6-promise/dist/commonjs/promise/resolve.js', module).resolve;
    var staticReject = require('/node_modules/es6-promise/dist/commonjs/promise/reject.js', module).reject;
    var asap = require('/node_modules/es6-promise/dist/commonjs/promise/asap.js', module).asap;
    var counter = 0;
    config.async = asap;
    function Promise(resolver) {
      if (!isFunction(resolver)) {
        throw new TypeError('You must pass a resolver function as the first argument to the promise constructor');
      }
      if (!(this instanceof Promise)) {
        throw new TypeError("Failed to construct 'Promise': Please use the 'new' operator, this object constructor cannot be called as a function.");
      }
      this._subscribers = [];
      invokeResolver(resolver, this);
    }
    function invokeResolver(resolver, promise) {
      function resolvePromise(value) {
        resolve(promise, value);
      }
      function rejectPromise(reason) {
        reject(promise, reason);
      }
      try {
        resolver(resolvePromise, rejectPromise);
      } catch (e) {
        rejectPromise(e);
      }
    }
    function invokeCallback(settled, promise, callback, detail) {
      var hasCallback = isFunction(callback), value, error, succeeded, failed;
      if (hasCallback) {
        try {
          value = callback(detail);
          succeeded = true;
        } catch (e) {
          failed = true;
          error = e;
        }
      } else {
        value = detail;
        succeeded = true;
      }
      if (handleThenable(promise, value)) {
        return;
      } else if (hasCallback && succeeded) {
        resolve(promise, value);
      } else if (failed) {
        reject(promise, error);
      } else if (settled === FULFILLED) {
        resolve(promise, value);
      } else if (settled === REJECTED) {
        reject(promise, value);
      }
    }
    var PENDING = void 0;
    var SEALED = 0;
    var FULFILLED = 1;
    var REJECTED = 2;
    function subscribe(parent, child, onFulfillment, onRejection) {
      var subscribers = parent._subscribers;
      var length = subscribers.length;
      subscribers[length] = child;
      subscribers[length + FULFILLED] = onFulfillment;
      subscribers[length + REJECTED] = onRejection;
    }
    function publish(promise, settled) {
      var child, callback, subscribers = promise._subscribers, detail = promise._detail;
      for (var i = 0; i < subscribers.length; i += 3) {
        child = subscribers[i];
        callback = subscribers[i + settled];
        invokeCallback(settled, child, callback, detail);
      }
      promise._subscribers = null;
    }
    Promise.prototype = {
      constructor: Promise,
      _state: undefined,
      _detail: undefined,
      _subscribers: undefined,
      then: function (onFulfillment, onRejection) {
        var promise = this;
        var thenPromise = new this.constructor(function () {
          });
        if (this._state) {
          var callbacks = arguments;
          config.async(function invokePromiseCallback() {
            invokeCallback(promise._state, thenPromise, callbacks[promise._state - 1], promise._detail);
          });
        } else {
          subscribe(this, thenPromise, onFulfillment, onRejection);
        }
        return thenPromise;
      },
      'catch': function (onRejection) {
        return this.then(null, onRejection);
      }
    };
    Promise.all = all;
    Promise.cast = cast;
    Promise.race = race;
    Promise.resolve = staticResolve;
    Promise.reject = staticReject;
    function handleThenable(promise, value) {
      var then = null, resolved;
      try {
        if (promise === value) {
          throw new TypeError('A promises callback cannot return that same promise.');
        }
        if (objectOrFunction(value)) {
          then = value.then;
          if (isFunction(then)) {
            then.call(value, function (val) {
              if (resolved) {
                return true;
              }
              resolved = true;
              if (value !== val) {
                resolve(promise, val);
              } else {
                fulfill(promise, val);
              }
            }, function (val) {
              if (resolved) {
                return true;
              }
              resolved = true;
              reject(promise, val);
            });
            return true;
          }
        }
      } catch (error) {
        if (resolved) {
          return true;
        }
        reject(promise, error);
        return true;
      }
      return false;
    }
    function resolve(promise, value) {
      if (promise === value) {
        fulfill(promise, value);
      } else if (!handleThenable(promise, value)) {
        fulfill(promise, value);
      }
    }
    function fulfill(promise, value) {
      if (promise._state !== PENDING) {
        return;
      }
      promise._state = SEALED;
      promise._detail = value;
      config.async(publishFulfillment, promise);
    }
    function reject(promise, reason) {
      if (promise._state !== PENDING) {
        return;
      }
      promise._state = SEALED;
      promise._detail = reason;
      config.async(publishRejection, promise);
    }
    function publishFulfillment(promise) {
      publish(promise, promise._state = FULFILLED);
    }
    function publishRejection(promise) {
      publish(promise, promise._state = REJECTED);
    }
    exports.Promise = Promise;
  });
  require.define('/node_modules/es6-promise/dist/commonjs/promise/asap.js', function (module, exports, __dirname, __filename) {
    'use strict';
    var browserGlobal = typeof window !== 'undefined' ? window : {};
    var BrowserMutationObserver = browserGlobal.MutationObserver || browserGlobal.WebKitMutationObserver;
    var local = typeof global !== 'undefined' ? global : this;
    function useNextTick() {
      return function () {
        process.nextTick(flush);
      };
    }
    function useMutationObserver() {
      var iterations = 0;
      var observer = new BrowserMutationObserver(flush);
      var node = document.createTextNode('');
      observer.observe(node, { characterData: true });
      return function () {
        node.data = iterations = ++iterations % 2;
      };
    }
    function useSetTimeout() {
      return function () {
        local.setTimeout(flush, 1);
      };
    }
    var queue = [];
    function flush() {
      for (var i = 0; i < queue.length; i++) {
        var tuple = queue[i];
        var callback = tuple[0], arg = tuple[1];
        callback(arg);
      }
      queue = [];
    }
    var scheduleFlush;
    if (typeof process !== 'undefined' && {}.toString.call(process) === '[object process]') {
      scheduleFlush = useNextTick();
    } else if (BrowserMutationObserver) {
      scheduleFlush = useMutationObserver();
    } else {
      scheduleFlush = useSetTimeout();
    }
    function asap(callback, arg) {
      var length = queue.push([
          callback,
          arg
        ]);
      if (length === 1) {
        scheduleFlush();
      }
    }
    exports.asap = asap;
  });
  require.define('/node_modules/es6-promise/dist/commonjs/promise/reject.js', function (module, exports, __dirname, __filename) {
    'use strict';
    function reject(reason) {
      var Promise = this;
      return new Promise(function (resolve, reject) {
        reject(reason);
      });
    }
    exports.reject = reject;
  });
  require.define('/node_modules/es6-promise/dist/commonjs/promise/resolve.js', function (module, exports, __dirname, __filename) {
    'use strict';
    function resolve(value) {
      var Promise = this;
      return new Promise(function (resolve, reject) {
        resolve(value);
      });
    }
    exports.resolve = resolve;
  });
  require.define('/node_modules/es6-promise/dist/commonjs/promise/race.js', function (module, exports, __dirname, __filename) {
    'use strict';
    var isArray = require('/node_modules/es6-promise/dist/commonjs/promise/utils.js', module).isArray;
    function race(promises) {
      var Promise = this;
      if (!isArray(promises)) {
        throw new TypeError('You must pass an array to race.');
      }
      return new Promise(function (resolve, reject) {
        var results = [], promise;
        for (var i = 0; i < promises.length; i++) {
          promise = promises[i];
          if (promise && typeof promise.then === 'function') {
            promise.then(resolve, reject);
          } else {
            resolve(promise);
          }
        }
      });
    }
    exports.race = race;
  });
  require.define('/node_modules/es6-promise/dist/commonjs/promise/all.js', function (module, exports, __dirname, __filename) {
    'use strict';
    var isArray = require('/node_modules/es6-promise/dist/commonjs/promise/utils.js', module).isArray;
    var isFunction = require('/node_modules/es6-promise/dist/commonjs/promise/utils.js', module).isFunction;
    function all(promises) {
      var Promise = this;
      if (!isArray(promises)) {
        throw new TypeError('You must pass an array to all.');
      }
      return new Promise(function (resolve, reject) {
        var results = [], remaining = promises.length, promise;
        if (remaining === 0) {
          resolve([]);
        }
        function resolver(index) {
          return function (value) {
            resolveAll(index, value);
          };
        }
        function resolveAll(index, value) {
          results[index] = value;
          if (--remaining === 0) {
            resolve(results);
          }
        }
        for (var i = 0; i < promises.length; i++) {
          promise = promises[i];
          if (promise && isFunction(promise.then)) {
            promise.then(resolver(i), reject);
          } else {
            resolveAll(i, promise);
          }
        }
      });
    }
    exports.all = all;
  });
  require.define('/node_modules/es6-promise/dist/commonjs/promise/cast.js', function (module, exports, __dirname, __filename) {
    'use strict';
    function cast(object) {
      if (object && typeof object === 'object' && object.constructor === this) {
        return object;
      }
      var Promise = this;
      return new Promise(function (resolve) {
        resolve(object);
      });
    }
    exports.cast = cast;
  });
  require.define('/node_modules/es6-promise/dist/commonjs/promise/config.js', function (module, exports, __dirname, __filename) {
    'use strict';
    var config = { instrument: false };
    function configure(name, value) {
      if (arguments.length === 2) {
        config[name] = value;
      } else {
        return config[name];
      }
    }
    exports.config = config;
    exports.configure = configure;
  });
  require.define('/lib/tools.js', function (module, exports, __dirname, __filename) {
    (function () {
      var Promise, __hasProp = {}.hasOwnProperty;
      Promise = require('/node_modules/es6-promise/dist/commonjs/main.js', module).Promise;
      exports.pairs = function (obj) {
        var key, value, _results;
        _results = [];
        for (key in obj) {
          if (!__hasProp.call(obj, key))
            continue;
          value = obj[key];
          _results.push([
            key,
            value
          ]);
        }
        return _results;
      };
      exports.keys = function (obj) {
        var key, value, _results;
        _results = [];
        for (key in obj) {
          if (!__hasProp.call(obj, key))
            continue;
          value = obj[key];
          _results.push(key);
        }
        return _results;
      };
      exports.values = function (obj) {
        var key, value, _results;
        _results = [];
        for (key in obj) {
          if (!__hasProp.call(obj, key))
            continue;
          value = obj[key];
          _results.push(value);
        }
        return _results;
      };
      exports.object = function (keys, values) {
        var i, key, out, _i, _len;
        out = {};
        for (i = _i = 0, _len = keys.length; _i < _len; i = ++_i) {
          key = keys[i];
          out[key] = values[i];
        }
        return out;
      };
      exports.resolveAll = function (list) {
        return Promise.all(list);
      };
      exports.isPrimitive = function (obj) {
        var types;
        types = [
          'Function',
          'String',
          'Number',
          'Date',
          'RegExp',
          'Boolean'
        ];
        if (obj === true || obj === false) {
          return true;
        }
        return types.some(function (type) {
          return Object.prototype.toString.call(obj) === '[object ' + type + ']';
        });
      };
      exports.isArray = Array.isArray || function (obj) {
        return Object.prototype.toString.call(obj) === '[object Array]';
      };
      exports.objectCreate = Object.create || function (obj) {
        var F;
        F = function () {
        };
        F.prototype = obj;
        return new F;
      };
      exports.proc = function (f) {
        return function () {
          f.apply(this, arguments);
          return void 0;
        };
      };
    }.call(this));
  });
  global.Z = require('/lib/index.js');
}.call(this, this));
