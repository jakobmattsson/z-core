tools = require './tools'
{Promise} = require 'es6-promise'
{pairs, keys, values, object, resolveAll, isPrimitive, isArray, objectCreate, proc} = tools

## Lägg in något som stoppar ALLDELES för djup rekursion. Man kan ju inte avsiktligt mena att man
## vill rekursera mer än 1000 steg tex.


## Bästa vore kanske att inte köra rekursiva algoritmen alls som default, utan bara försöka detecta om den rekursiv.
## Om den är det, då avbryter man och kör den rekursiva.


resolveCompletely = (__unresolved, __depth) ->

  console.log "started resolve completely"

  counter = 0
  objs = {}
  endResult = {}

  TempType = (val) ->
    this.val = val


  # Alla objekt får en property som heter __objectIndex
  # När man hittar ett objekt lägre ner i kedjan som redan har denna så betyder det att man påbörjat
  # en resolving av det objektet. Istället för att returnera det riktiga objektet så returnerar
  # vi en specialtyp som innehåller IDt till den verkliga typen som det gäller.

  # Som ett slutsteg i algoritmen så substituerar man in alla verkliga objekt där.


  rebuild = (obj) ->
    # TODO: om obj är TempType, returnera verkligt värde
    return obj if isPrimitive(obj)
    return obj.map((x) -> rebuild(x)) if isArray(obj)
    vals = values(obj).map(rebuild)
    object(keys(obj), vals)

  strip = (obj) ->
    return obj if isPrimitive(obj)
    return obj.map((x) -> strip(x)) if isArray(obj)

    if obj.__objectIndex?
      delete obj.__objectIndex

    vals = values(obj).map(strip)
    object(keys(obj), vals)



  resolveCom = (unresolved, depth) ->

    resolveAll([unresolved]).then ([resolved]) ->

      return resolved if depth <= 0 || !resolved? || isPrimitive(resolved)

      if counter > 1000
        throw new Error("WHAT")

      if resolved.__objectIndex?
        console.log "has one", resolved
        return new TempType(resolved.__objectIndex)
        # throw new "fail"

      thisValue = counter++

      resolved.__objectIndex = thisValue
      objs[thisValue] = resolved

      console.log resolved

      # För varje value, plocka ut deras resolvade värde
      # I en iteration så kommer jag se att ett 

      return resolveAll(resolved.map((x) -> resolveCom(x, depth-1) )) if isArray(resolved)

      unresolvedValues = resolveAll(values(resolved).map((x) -> resolveCom(x, depth-1)))

      unresolvedValues.then (resolvedValues) ->
        result = object(keys(resolved), resolvedValues)
        #result.__objectIndex = thisValue
        endResult[thisValue] = result
        result

  # behöver plocka bort alla __objectIndex i slutsteget också
  rr = resolveCom(__unresolved, __depth)
  
  rr2 = strip(rebuild(rr))


  console.log "RRRRRRRRRRRR", rr2
  rr2



init = (defaultConf) ->

  mixedIn = {}
  mixinObj = {}
  depth = if defaultConf?.depth? then defaultConf?.depth else 1000000

  updateMixinObj = ->
    pairs(mixedIn).forEach ([name, func]) ->
      mixinObj[name] = (args...) ->
        @then (resolved) ->
          resolveCompletely(args, depth).then (args) ->
            func.apply({ value: resolved }, args)

  Z = (obj) ->
    resolvedObject = resolveCompletely(obj, depth)
    overrideLayer = objectCreate(resolvedObject)
    resultingPromise = objectCreate(overrideLayer)

    overrideLayer.then = (args...) ->
      Z resolvedObject.then.apply(resolvedObject, args)

    for key, value of mixinObj
      resultingPromise[key] = value

    resultingPromise

  Z.mixin = proc (hash) ->
    pairs(hash).forEach ([name, func]) ->
      oldOne = mixedIn[name]
      mixedIn[name] = ->
        context = { value: @value }
        context.base = oldOne if oldOne
        func.apply(context, arguments)
    updateMixinObj()

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
