tools = require './tools'
{Promise} = require 'es6-promise'
{pairs, keys, values, object, resolveAll, isPrimitive, isArray, objectCreate, proc} = tools

resolveCompletely = (unresolved) ->
  resolveAll([unresolved]).then ([resolved]) ->

    return resolved if !resolved? || isPrimitive(resolved)
    return resolveAll(resolved.map(resolveCompletely)) if isArray(resolved)

    unresolvedKeys = resolveAll(keys(resolved))
    unresolvedValues = resolveAll(values(resolved).map(resolveCompletely))

    resolveAll([unresolvedKeys, unresolvedValues]).then ([resolvedKeys, resolvedValues]) ->
      object(resolvedKeys, resolvedValues)


overrides = ['then']


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
        resultingPromise.then (resolved) ->
          resolveCompletely(args).then (args) ->
            func.apply({ value: resolved }, args)

    resultingPromise

  Z.mixin = proc (hash) ->
    pairs(hash).forEach ([name, func]) ->
      oldOne = mixedIn[name]
      mixedIn[name] = ->
        context = { value: @value }
        context.base = oldOne if oldOne
        func.apply(context, arguments)

  Z.bindSync = (func, context) ->
    (unresolvedArgs...) ->
      Z(unresolvedArgs).then (args) =>
        func.apply(context ? this, args)

  Z.bindAsync = (func, context) ->

    (unresolvedArgs...) ->
      ctx = context ? this

      Z(unresolvedArgs).then (args) ->
        new Promise (resolve, reject) ->

          args.push (err, result...) ->
            if err?
              reject(err)
            else if result.length == 1
              resolve(result[0])
            else
              resolve(result)

          try
            func.apply(ctx, args)
          catch ex
            reject(ex)

  Z



makeZ = ->
  Z = init()
  Z.init = init
  Z



if typeof window != 'undefined' && typeof window.require == 'undefined'
  window.Z = makeZ()

if typeof module != 'undefined'
  module.exports = makeZ()
