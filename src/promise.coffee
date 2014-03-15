nativePromise = do -> this.Promise
if !nativePromise?
  throw new Error("No native ES6-promises - Use a shim manually or via Z")
exports.Promise = nativePromise
