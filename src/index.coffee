Q = require 'q'
_ = require 'underscore'
util = require 'util'

resolveCompletely = (unresolved) ->
  Q.when(unresolved).then (obj) ->
    return obj if !obj? || typeof obj in ['boolean', 'string', 'number', 'function']
    return Q.all(obj.map(resolveCompletely)) if Array.isArray(obj)

    keys = Q.all(_.keys(obj))
    values = Q.all(_.values(obj).map(resolveCompletely))

    Q.all([keys, values]).then ([ks, vs]) ->
      _.object(_.zip(ks, vs))



module.exports = Z = (obj) ->
  p = resolveCompletely(obj)

  def = (name, f) ->
    p[name] = (args...) ->
      Z p.then (resolved) ->
        f(resolved, args...)
  
  zeeify = (name) ->
    superMethod = p[name]
    p[name] = (args...) ->
      Z superMethod.apply(this, args)

  arrayMethods = ['reverse', 'concat', 'join', 'slice', 'indexOf', 'lastIndexOf', 'every', 'some', 'filter', 'find', 'findIndex', 'map', 'reduce', 'reduceRight']
  stringMethods = ['split']
  underscoreMethods = ['object', 'sortBy', 'omit', 'map', 'keys', 'pick']
  underscoreEachMethods = ['omit']

  underscoreMethods.forEach (methodName) ->
    def methodName, (resolved, args...) ->
      _(resolved)[methodName](args...)

  underscoreEachMethods.forEach (methodName) ->
    def (methodName + 'Each'), (resolved, args...) ->
      resolved.map (e) -> _(e)[methodName](args...)

  arrayMethods.forEach (methodName) ->
    def methodName, (resolved, args...) ->
      if !Array.isArray(resolved)
        throw new Error("Object must be an array in order to invoke '#{methodName}'")
      resolved[methodName].apply(resolved, args)

  stringMethods.forEach (methodName) ->
    def methodName, (resolved, args...) ->
      if typeof resolved != 'string'
        throw new Error("Object must be a string in order to invoke '#{methodName}'")
      resolved[methodName].apply(resolved, args)

  def 'log', (resolved, shallow) ->
    if shallow
      if Array.isArray(resolved)
        console.log(resolved...)
      else
        console.log(resolved)
    else
      console.log(util.inspect(resolved, { depth: null }))
  
  def 'inspect', (resolved, options) ->
    utils.inspect(resolved, options)

  zeeify('get')

  p
