describe 'root Z', ->

  it 'is a function', ->
    Z.should.be.a 'function'

  it 'has an init and a mixin function', ->
    expectedFunctions = ['bindAsync', 'bindSync', 'init', 'mixin']

    keys = Object.keys(Z)
    sortedKeys = keys.sort()
    sortedKeys.should.eql expectedFunctions

    expectedFunctions.forEach (expectedFunction) ->
      Z[expectedFunction].should.be.a 'function'
