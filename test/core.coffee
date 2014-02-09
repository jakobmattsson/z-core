Q = require 'q'
jscov = require 'jscov'
coreZ = require jscov.cover('..', 'src', 'constructor')

describe 'root Z', ->

  it 'is a function', ->
    coreZ.should.be.a 'function'

  it 'has an init and a mixin function', ->
    expectedFunctions = ['init', 'mixin']

    keys = Object.keys(coreZ)
    sortedKeys = keys.sort()
    sortedKeys.should.eql expectedFunctions

    expectedFunctions.forEach (expectedFunction) ->
      coreZ[expectedFunction].should.be.a 'function'



describe 'Z method', ->
  
  beforeEach ->
    @Z = coreZ.init()

  it 'returns an object with a single method', ->
    prototypeOfQ = Q.makePromise.prototype
    x = @Z(1)
    prototypeOfQ.isPrototypeOf(x).should.eql true

  it 'returns an object that is inherited from Q', ->
    prototypeOfQ = Q.makePromise.prototype
    x = @Z(1)
    prototypeOfQ.isPrototypeOf(x).should.eql true

  it 'returns an object without direct properties', ->
    x = @Z(1)
    keys = Object.keys(x)
    keys.should.eql []

  it 'retains top-level functions', ->
    f = @Z((x) -> x*x)
    result = f.then (fResolved) -> fResolved(2)
    result.should.become 4

  it 'retains nested functions', ->
    obj = @Z({ a: 1, f: (x) -> x*x })
    result = obj.get('f').then (fResolved) -> fResolved(2)
    result.should.become 4

  it 'retains top-level regexps', ->
    f = @Z(/foo/)
    result = f.then (fResolved) -> fResolved.test("foobar")
    result.should.become true

  it 'retains nested regexps', ->
    obj = @Z({ a: 1, f: /foo/ })
    result = obj.get('f').then (fResolved) -> fResolved.test("foobar")
    result.should.become true

  it 'retains top-level dates', ->
    f = @Z(new Date())
    result = f.then (d) -> d.getTime()
    result.should.eventually.be.a 'number'

  it 'retains nested dates', ->
    obj = @Z({ a: 1, f: new Date()})
    result = obj.get('f').then (d) -> d.getTime()
    result.should.eventually.be.a 'number'

  it 'does not copy protoype chains when wrapping objects', ->
    a = {}
    b = Object.create(a)

    @Z(b).then (resolved) ->
      Object.getPrototypeOf(resolved).should.eql Object.prototype

  it 'does not copy properties from up the prototype chain when wrapping objects', ->
    a = { v1: 1 }
    b = Object.create(a)
    b.v2 = 2

    @Z(b).then (resolved) ->
      resolved.should.have.keys ['v2']
  
  describe 'mixin', ->
    
    it 'returns an object without direct properties', ->
      x = @Z(1)
      keys = Object.keys(x)
      keys.should.eql []



describe 'Q method', ->

  beforeEach ->
    @Z = coreZ.init()

  describe 'get', ->

    it 'retrieves the value of a property (just like in Q)', ->
      bValue = [1,2]
      arr = @Z({ a: { b: bValue } })
      filtered = arr.get('a')
      filtered.should.become { b: bValue }

    it 'retrieves the value of a property as a reference (just like in Q)', ->
      bValue = [1,2]
      arr = @Z({ a: { b: bValue } })
      filtered = arr.get('a')
      bValue.push(3)
      filtered.should.become { b: bValue }

    it 'returns an object that is inherited from Q', ->
      prototypeOfQ = Q.makePromise.prototype
      x = @Z({ a: { b: 1 } }).get('a')
      prototypeOfQ.isPrototypeOf(x).should.eql true

    it 'returns an object that is inherited from Q even when called multiple times', ->
      prototypeOfQ = Q.makePromise.prototype
      x = @Z({ a: { b: { c: 1 } } }).get('a').get('b')
      prototypeOfQ.isPrototypeOf(x).should.eql true

    it 'returns an object that has the expected functions', ->
      @Z.mixin({
        f1: ->
        f2: ->
      })
      methodsList = ['f1', 'f2']
      x = @Z({ a: { b: 1 }}).get('a')
      keys = Object.keys(x).sort (a, b) -> a.localeCompare(b)
      mets = methodsList.sort (a, b) -> a.localeCompare(b)
      keys.should.eql mets

    it 'returns an object that has the expected functions even when called multiple times', ->
      @Z.mixin({
        f1: ->
        f2: ->
      })
      methodsList = ['f1', 'f2']
      x = @Z({ a: { b: { c: 1 } }}).get('a').get('b')
      keys = Object.keys(x).sort (a, b) -> a.localeCompare(b)
      mets = methodsList.sort (a, b) -> a.localeCompare(b)
      keys.should.eql mets
