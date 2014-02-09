tools = require './tools'

resolveCompletely = (unresolved) ->
  tools.resolveAll([unresolved]).then ([resolved]) ->

    return resolved if !resolved? || tools.isPrimitive(resolved)
    return tools.resolveAll(resolved.map(resolveCompletely)) if tools.isArray(resolved)

    unresolvedKeys = tools.resolveAll(tools.keys(resolved))
    unresolvedValues = tools.resolveAll(tools.values(resolved).map(resolveCompletely))

    tools.resolveAll([unresolvedKeys, unresolvedValues]).then ([resolvedKeys, resolvedValues]) ->
      tools.object(resolvedKeys, resolvedValues)


overrides = ['get']


init = ->

  mixedIn = {}

  Z = (obj) ->
    resolvedObject = resolveCompletely(obj)
    overrideLayer = tools.objectCreate(resolvedObject)
    resultingPromise = tools.objectCreate(overrideLayer)

    overrides.forEach (name) ->
      overrideLayer[name] = (args...) ->
        Z resolvedObject[name].apply(this, args)

    tools.pairs(mixedIn).forEach ([name, func]) ->
      resultingPromise[name] = (args...) ->
        Z resultingPromise.then (resolved) ->
          func.apply({ value: resolved }, args)

    resultingPromise

  Z.mixin = tools.proc (hash) ->
    tools.pairs(hash).forEach ([name, func]) ->
      mixedIn[name] = func

  Z



module.exports = do ->
  Z = init()
  Z.init = init
  Z
