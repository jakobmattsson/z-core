describe 'root Z', ->

  it 'is a function', ->
    expect(Z).to.be.a 'function'

  it 'has an init and a mixin function', ->
    expectedFunctions = ['bindAsync', 'bindSync', 'init', 'mixin', 'mixinAsync']

    keys = Object.keys(Z)
    sortedKeys = keys.sort()
    expect(sortedKeys).to.eql expectedFunctions

    expectedFunctions.forEach (expectedFunction) ->
      expect(Z[expectedFunction]).to.be.a 'function'
