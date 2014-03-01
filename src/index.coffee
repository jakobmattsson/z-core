tools = require './tools'
{Promise} = require 'es6-promise'
{pairs, keys, values, object, resolveAll, isPrimitive, isArray, objectCreate, proc} = tools

resolveCompletely = (unresolved, depth) ->
  resolveAll([unresolved]).then ([resolved]) ->

    return resolved if depth <= 0 || !resolved? || isPrimitive(resolved)
    return resolveAll(resolved.map((x) -> resolveCompletely(x, depth-1) )) if isArray(resolved)

    unresolvedValues = resolveAll(values(resolved).map((x) -> resolveCompletely(x, depth-1)))

    unresolvedValues.then (resolvedValues) ->
      object(keys(resolved), resolvedValues)


overrides = ['then']


init = ->

  mixedIn = {}

  Z = (obj, conf = {}) ->
    conf.depth = 1 if typeof conf.depth == 'undefined'
    conf.depth = 1000000 if conf.depth == null

    resolvedObject = resolveCompletely(obj, conf.depth)
    overrideLayer = objectCreate(resolvedObject)
    resultingPromise = objectCreate(overrideLayer)

    overrides.forEach (name) ->
      overrideLayer[name] = (args...) ->
        Z resolvedObject[name].apply(this, args)

    pairs(mixedIn).forEach ([name, func]) ->
      resultingPromise[name] = (args...) ->
        resultingPromise.then (resolved) ->
          resolveCompletely(args, 1).then (args) ->
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
