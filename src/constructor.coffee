tools = require './tools'

resolveCompletely = (unresolved) ->
  tools.resolveAll([unresolved]).then ([resolved]) ->

    return resolved if !resolved? || tools.isPrimitive(resolved)
    return tools.resolveAll(resolved.map(resolveCompletely)) if tools.isArray(resolved)

    unresolvedKeys = tools.resolveAll(tools.keys(resolved))
    unresolvedValues = tools.resolveAll(tools.values(resolved).map(resolveCompletely))

    tools.resolveAll([unresolvedKeys, unresolvedValues]).then ([resolvedKeys, resolvedValues]) ->
      tools.object(resolvedKeys, resolvedValues)



exports.creator = ({ log, extensions }) -> (obj) ->

  extensions ?= {}
  Z = exports.creator({ log, extensions })
  overrideLayer = tools.objectCreate(resolveCompletely(obj))
  p = tools.objectCreate(overrideLayer)

  zeeify = (name) ->
    superMethod = p[name]
    overrideLayer[name] = (args...) ->
      Z superMethod.apply(this, args)

  tools.pairs(extensions).forEach ([name, func]) ->
    p[name] = (args...) ->
      Z p.then (resolved) ->
        func.apply({ value: resolved }, args)

  zeeify('get')

  p
