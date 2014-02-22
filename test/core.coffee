coreZ = requireSource 'index'

describe 'root Z', ->

  it 'is a function', ->
    coreZ.should.be.a 'function'

  it 'has an init and a mixin function', ->
    expectedFunctions = ['bindAsync', 'bindSync', 'init', 'mixin']

    keys = Object.keys(coreZ)
    sortedKeys = keys.sort()
    sortedKeys.should.eql expectedFunctions

    expectedFunctions.forEach (expectedFunction) ->
      coreZ[expectedFunction].should.be.a 'function'



describe 'Z bind async', ->

  beforeEach ->
    @Z = coreZ.init()

  global = do -> this

  divider = (a, b, callback) ->
    throw new Error("Division by zero") if b == 0
    setTimeout =>
      extra = this?.extraValue || 0
      callback(null, extra + a / b)
    , 10

  it 'wraps a function to return a promise', ->
    pDivider = @Z.bindAsync(divider)
    pDivider(10, 2).should.become 5

  it 'wraps a function with a bound context to return a promise', ->
    pDivider = @Z.bindAsync(divider, { extraValue: 6 })
    pDivider(20, 2).should.become 16

  it 'resolves promise arguments before calling the function', ->
    pDivider = @Z.bindAsync(divider)
    value1 = @Z(10)
    pDivider(value1, 2).should.become 5

  it 'rejects the returned promise if the function throws', ->
    pDivider = @Z.bindAsync(divider)
    pDivider(10, 0).should.be.rejected



describe 'Z bind sync', ->

  beforeEach ->
    @Z = coreZ.init()

  global = do -> this

  divider = (a, b) ->
    throw new Error("Division by zero") if b == 0
    extra = this.extraValue || 0
    extra + a / b

  it 'wraps a function to return a promise', ->
    pDivider = @Z.bindSync(divider)
    pDivider(10, 2).should.become 5

  it 'wraps a function with a bound context to return a promise', ->
    pDivider = @Z.bindSync(divider, { extraValue: 1 })
    pDivider(20, 2).should.become 11

  it 'resolves promise arguments before calling the function', ->
    pDivider = @Z.bindSync(divider)
    value1 = @Z(10)
    pDivider(value1, 2).should.become 5

  it 'rejects the returned promise if the function throws', ->
    pDivider = @Z.bindSync(divider)
    pDivider(10, 0).should.be.rejected



describe 'Z method', ->
  
  beforeEach ->
    @Z = coreZ.init()

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
    result = obj.then (p) -> p.f(2)
    result.should.become 4

  it 'retains top-level regexps', ->
    f = @Z(/foo/)
    result = f.then (fResolved) -> fResolved.test("foobar")
    result.should.become true

  it 'retains nested regexps', ->
    obj = @Z({ a: 1, f: /foo/ })
    result = obj.then (fResolved) -> fResolved.f.test("foobar")
    result.should.become true

  it 'retains top-level dates', ->
    f = @Z(new Date())
    result = f.then (d) -> d.getTime()
    result.should.eventually.be.a 'number'

  it 'retains nested dates', ->
    obj = @Z({ a: 1, f: new Date()})
    result = obj.then (d) -> d.f.getTime()
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

  it 'returns an object without direct properties', ->
    x = @Z(1)
    keys = Object.keys(x)
    keys.should.eql []

  describe 'then', ->

    it 'returns an object that has the expected functions', ->
      @Z.mixin({
        f1: ->
        f2: ->
      })
      methodsList = ['f1', 'f2']
      x = @Z(5).then((x) -> x * 10)
      keys = Object.keys(x).sort (a, b) -> a.localeCompare(b)
      mets = methodsList.sort (a, b) -> a.localeCompare(b)
      keys.should.eql mets

  describe 'mixin', ->

    it 'returns undefined', ->
      ret = @Z.mixin({
        f1: -> 1
      })
      [ret].should.eql [undefined]

    it 'allows new method to be added to the resulting promise', ->
      @Z.mixin({
        f1: (a1, a2) -> [@value, a1, a2]
      })
      x = @Z(50)
      val = x.f1(100, 200)
      Object.keys(x).should.eql ['f1']
      val.should.become [50, 100, 200]

    it 'can be called multiple times to add multiple methods (1)', ->
      @Z.mixin({
        f1: (a1, a2) -> [@value, a1, a2]
      })
      @Z.mixin({
        f2: (a1, a2) -> @value + a1 + a2
      })
      x = @Z(50)
      v1 = x.f1(100, 200)
      v2 = x.f2(10, 20)
      Object.keys(x).should.eql ['f1', 'f2']
      v1.should.become [50, 100, 200]

    it 'can be called multiple times to add multiple methods (2)', ->
      @Z.mixin({
        f1: (a1, a2) -> [@value, a1, a2]
      })
      @Z.mixin({
        f2: (a1, a2) -> @value + a1 + a2
      })
      x = @Z(50)
      v1 = x.f1(100, 200)
      v2 = x.f2(10, 20)
      Object.keys(x).should.eql ['f1', 'f2']
      v2.should.become 80

    it 'can mixin the same function multiple times and passes the previous as context to the next', ->
      @Z.mixin({
        f1: (a1, a2) -> @value + a1 + a2
      })
      @Z.mixin({
        f1: (a1, a2) -> @base.call({ value: 1 }, 2, @value + a1 + a2)
      })

      x = @Z(50)
      v1 = x.f1(100, 200)

      Object.keys(x).should.eql ['f1']
      v1.should.become 353

    it 'can mixin more than two of the same function', ->
      @Z.mixin({
        f1: (a1, a2) -> [@value, Object.keys(@)]
      })
      @Z.mixin({
        f1: (a1, a2) -> [@value, Object.keys(@), @base.call({ value: 2 })]
      })
      @Z.mixin({
        f1: (a1, a2) -> [@value, Object.keys(@), @base.call({ value: 3 })]
      })
      @Z(50).f1(100, 200).should.become [50,["value","base"],[3,["value","base"],[2,["value"]]]]

    it 'never mixes in an alternative base function', ->
      @Z.mixin({
        f1: (a1, a2) -> [@value, Object.keys(@)]
      })
      @Z.mixin({
        f1: (a1, a2) -> [@value, Object.keys(@), @base.call({ value: 2, base: -> 1000 })]
      })
      @Z.mixin({
        f1: (a1, a2) -> [@value, Object.keys(@), @base.call({ value: 3, base: -> 1000 })]
      })
      @Z(50).f1(100, 200).should.become [50,["value","base"],[3,["value","base"],[2,["value"]]]]
