Q = require 'q'
_ = require 'underscore'
util = require 'util'

resolveCompletely = (unresolved) ->
  Q.when(unresolved).then (resolved) ->

    return resolved if !resolved? || typeof resolved in ['boolean', 'string', 'number', 'function']
    return Q.all(resolved.map(resolveCompletely)) if Array.isArray(resolved)

    unresolvedKeys = Q.all(_.keys(resolved))
    unresolvedValues = Q.all(_.values(resolved).map(resolveCompletely))

    Q.all([unresolvedKeys, unresolvedValues]).then ([resolvedKeys, resolvedValues]) ->
      _.object(_.zip(resolvedKeys, resolvedValues))





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

  genericMethods = ['toString']
  arrayMethods = ['reverse', 'concat', 'join', 'slice', 'indexOf', 'lastIndexOf', 'every', 'some', 'filter', 'find', 'findIndex', 'map', 'reduce', 'reduceRight']
  stringMethods = ['split']
  underscoreMethods = [
    # COLLECTIONS
    'each'
    # 'map' -- ignored in favor of the native method
    # 'reduce' -- ignored in favor of the native method
    # 'reduceRight' -- ignored in favor of the native method
    # 'find' -- ignored in favor of the native method
    'filter'
    'where'
    'findWhere'
    'reject'
    # 'every' -- ignored in favor of the native method
    # 'some' -- ignored in favor of the native method
    'contains'
    'invoke'
    'pluck'
    'max'
    'min'
    'sortBy'
    'groupBy'
    'indexBy'
    'countBy'
    'shuffle'
    'sample'
    'toArray'
    'size'

    # ARRAYS
    'first'
    'initial'
    'last'
    'rest'
    'compact'
    'flatten'
    'without'
    'union'
    'intersection'
    'difference'
    'uniq'
    'zip'
    'object'
    'indexOf'
    'lastIndexOf'
    'sortedIndex'
    'range'

    # FUNCTIONS -- not sure if these makes sense yet
    # 'bind'
    # 'bindAll'
    # 'partial'
    # 'memoize'
    # 'delay'
    # 'defer'
    # 'throttle'
    # 'debounce'
    # 'once'
    # 'after'
    # 'wrap'
    # 'compose'

    # OBJECTS
    'keys'
    'values'
    'pairs'
    'invert'
    'functions'
    'extend'
    'pick'
    'omit'
    'defaults'
    'clone'
    'tap'
    'has'
    'isEqual'
    'isEmpty'
    'isElement'
    'isArray'
    'isObject'
    'isArguments'
    'isFunction'
    'isString'
    'isNumber'
    'isFinite'
    'isBoolean'
    'isDate'
    'isRegExp'
    'isNaN'
    'isNull'
    'isUndefined'

    # UTILITY
    # 'noConflict' -- not applicable
    'identity'
    'times'
    'random'
    # 'mixin' -- I have no idea how this would affect things
    'uniqueId'
    'escape'
    'unescape'
    'result'
    'template'

    # CHAINING -- zee has its own chaining
    # 'chain'
    # 'value'
  ]

  underscoreEachMethods = ['omit', 'pick', 'keys']

  underscoreMethods.forEach (methodName) ->
    def methodName, (resolved, args...) ->
      _(resolved)[methodName](args...)

  underscoreEachMethods.forEach (methodName) ->
    def (methodName + 'Each'), (resolved, args...) ->
      resolved.map (e) -> _(e)[methodName](args...)

  genericMethods.forEach (methodName) ->
    def methodName, (resolved, args...) ->
      resolved[methodName].apply(resolved, args)

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
