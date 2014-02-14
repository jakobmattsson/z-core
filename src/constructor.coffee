tools = require './tools'
{pairs, keys, values, object, resolveAll, isPrimitive, isArray, objectCreate, proc} = tools

resolveCompletely = (unresolved) ->
  resolveAll([unresolved]).then ([resolved]) ->

    return resolved if !resolved? || isPrimitive(resolved)
    return resolveAll(resolved.map(resolveCompletely)) if isArray(resolved)

    unresolvedKeys = resolveAll(keys(resolved))
    unresolvedValues = resolveAll(values(resolved).map(resolveCompletely))

    resolveAll([unresolvedKeys, unresolvedValues]).then ([resolvedKeys, resolvedValues]) ->
      object(resolvedKeys, resolvedValues)


overrides = ['get', 'then']


init = ->

  mixedIn = {}

  Z = (obj) ->
    resolvedObject = resolveCompletely(obj)
    overrideLayer = objectCreate(resolvedObject)
    resultingPromise = objectCreate(overrideLayer)

    overrides.forEach (name) ->
      overrideLayer[name] = (args...) ->
        Z resolvedObject[name].apply(this, args)

    pairs(mixedIn).forEach ([name, func]) ->
      resultingPromise[name] = (args...) ->
        Z resultingPromise.then (resolved) ->
          func.apply({ value: resolved }, args)

    resultingPromise

  Z.mixin = proc (hash) ->
    pairs(hash).forEach ([name, func]) ->
      oldOne = mixedIn[name]
      mixedIn[name] = ->
        context = { value: @value }
        context.base = oldOne if oldOne
        func.apply(context, arguments)

  Z



module.exports = do ->
  Z = init()
  Z.init = init
  Z
