zee = require './constructor'

module.exports = zee.zeeCreator({
  log: (value) ->
    if console?.log?
      console.log(value)
    else if alert?
      alert(value)
})
