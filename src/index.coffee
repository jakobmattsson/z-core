Z = require './constructor'

module.exports = Z.creator({
  log: (value) ->
    if console?.log?
      console.log(value)
    else if alert?
      alert(value)
})
