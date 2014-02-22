{Promise} = require 'es6-promise'

exports.pairs = (obj) ->
  for own key, value of obj
    [key, value]
  
exports.keys = (obj) ->
  for own key, value of obj
    key

exports.values = (obj) ->
  for own key, value of obj
    value

exports.object = (keys, values) ->
  out = {}
  for key, i in keys
    out[key] = values[i]
  out

exports.resolveAll = (list) ->
  Promise.all(list)

exports.isPrimitive = (obj) ->
  types = ['Function', 'String', 'Number', 'Date', 'RegExp', 'Boolean']
  return true if obj == true || obj == false # as per underscore.js. Not sure why it's needed.
  types.some (type) -> Object.prototype.toString.call(obj) == "[object #{type}]"

exports.isArray = Array.isArray || (obj) -> Object.prototype.toString.call(obj) == "[object Array]"

exports.objectCreate = Object.create || (obj) ->
    F = ->
    F.prototype = obj
    new F

exports.proc = (f) ->
  ->
    f.apply(this, arguments)
    undefined
