describe 'Z bind async', ->

  beforeEach ->
    @Z = Z.init()

  divider = (a, b, callback) ->
    throw new Error("Division by zero") if b == 0
    setTimeout (=>
      extra = this?.extraValue || 0
      callback(null, extra + a / b)
    ), 10

  it 'wraps a function to return a promise', ->
    pDivider = @Z.bindAsync(divider)
    expect(pDivider(10, 2)).to.become 5

  it 'wraps a function with a bound context to return a promise', ->
    pDivider = @Z.bindAsync(divider, { extraValue: 6 })
    expect(pDivider(20, 2)).to.become 16

  it 'resolves promise arguments before calling the function', ->
    pDivider = @Z.bindAsync(divider)
    value1 = @Z(10)
    expect(pDivider(value1, 2)).to.become 5

  it 'rejects the returned promise if the function throws', ->
    pDivider = @Z.bindAsync(divider)
    expect(pDivider(10, 0)).to.be.rejected



describe 'Z bind sync', ->

  beforeEach ->
    @Z = Z.init()

  divider = (a, b) ->
    throw new Error("Division by zero") if b == 0
    extra = this.extraValue || 0
    extra + a / b

  it 'wraps a function to return a promise', ->
    pDivider = @Z.bindSync(divider)
    expect(pDivider(10, 2)).to.become 5

  it 'wraps a function with a bound context to return a promise', ->
    pDivider = @Z.bindSync(divider, { extraValue: 1 })
    expect(pDivider(20, 2)).to.become 11

  it 'resolves promise arguments before calling the function', ->
    pDivider = @Z.bindSync(divider)
    value1 = @Z(10)
    expect(pDivider(value1, 2)).to.become 5

  it 'rejects the returned promise if the function throws', ->
    pDivider = @Z.bindSync(divider)
    expect(pDivider(10, 0)).to.be.rejected



describe 'Z method', ->
  
  beforeEach ->
    @Z = Z.init()

  it 'returns an object without direct properties', ->
    x = @Z(1)
    keys = Object.keys(x)
    expect(keys).to.eql []

  it 'retains top-level functions', ->
    f = @Z((x) -> x*x)
    result = f.then (fResolved) -> fResolved(2)
    expect(result).to.become 4

  it 'retains nested functions', ->
    obj = @Z({ a: 1, f: (x) -> x*x })
    result = obj.then (p) -> p.f(2)
    expect(result).to.become 4

  it 'retains top-level regexps', ->
    f = @Z(/foo/)
    result = f.then (fResolved) -> fResolved.test("foobar")
    expect(result).to.become true

  it 'retains nested regexps', ->
    obj = @Z({ a: 1, f: /foo/ })
    result = obj.then (fResolved) -> fResolved.f.test("foobar")
    expect(result).to.become true

  it 'retains top-level dates', ->
    f = @Z(new Date())
    result = f.then (d) -> d.getTime()
    expect(result).to.eventually.be.a 'number'

  it 'retains nested dates', ->
    obj = @Z({ a: 1, f: new Date()})
    result = obj.then (d) -> d.f.getTime()
    expect(result).to.eventually.be.a 'number'

  it 'does not copy protoype chains when wrapping objects', ->
    a = {}
    b = Object.create(a)

    @Z(b).then (resolved) ->
      proto = Object.getPrototypeOf(resolved)
      expect(proto).to.eql Object.prototype

  it 'does not copy properties from up the prototype chain when wrapping objects', ->
    a = { v1: 1 }
    b = Object.create(a)
    b.v2 = 2

    @Z(b).then (resolved) ->
      expect(resolved).to.have.keys ['v2']

  it 'returns an object without direct properties', ->
    x = @Z(1)
    keys = Object.keys(x)
    expect(keys).to.eql []

  it 'does not get stuck in native recursive objects', ->
    obj1 = { v: 10 }
    obj2 = { v: 20, o: obj1 }
    obj1.o = obj2

    @Z(obj1).then(((resolved) -> "worked"), ((err) -> err.message)).then (res) ->
      expect(res).to.eql 'Cyclic object detected'

  it 'does not get stuck in promised recursive objects', ->
    obj1 = { v: @Z(10) }
    obj2 = { v: @Z(20), o: @Z(obj1) }
    obj1.o = @Z(obj2)

    @Z(obj1).then(((resolved) -> "worked"), ((err) -> err.message)).then (res) ->
      expect(res).to.eql 'Cyclic object detected'

  describe 'conf arg', ->

    it 'given depth 0 does not resolve nested properties, but leaves them as promises', ->
      Z2 = Z.init({ depth: 0 })
      v = Z2({ b: 2 })
      Z2({ a: v }).then (res) ->
        expect(res.a.then).to.exist

    it 'given depth 1 resolves one level of promises and leaves the deeper ones intact', ->
      Z0 = Z.init({ depth: 0 })
      Z1 = Z.init({ depth: 1 })

      v = Z0({ b: 2, c: Z0(1) })
      Z1({ a: v }).then (res) ->
        expect(res.a.b).to.eql 2
        expect(res.a.b).to.not.eql 1
        expect(res.a.c.then).to.exist

    it 'given no depth it defaults to resolving infinitely deep', ->
      v = @Z({ b: 2, c: @Z(1) }, { depth: 0 })
      @Z({ a: v }, { }).then (res) ->
        expect(res.a.b).to.eql 2
        expect(res.a.b).to.not.eql 1
        expect(res.a.c).to.eql 1

    it 'given no config at all it defaults to resolving infinitely deep', ->
      v = @Z({ b: 2, c: @Z(1) }, { depth: 0 })
      @Z({ a: v }).then (res) ->
        expect(res.a.b).to.eql 2
        expect(res.a.b).to.not.eql 1
        expect(res.a.c).to.eql 1

    it 'given depth null resolves all promises at all levels', ->
      v = @Z({ b: 2, c: @Z(1) }, { depth: 0 })
      @Z({ a: v }, { depth: null }).then (res) ->
        expect(res).to.eql { a: { b: 2, c: 1 }}

    it 'uses the config given at init if none is passed at Z-invokation', ->
      localZ = Z.init({ depth: null })
      v = @Z({ b: 2, c: @Z(1) }, { depth: 0 })
      localZ({ a: v }).then (res) ->
        expect(res).to.eql { a: { b: 2, c: 1 }}

  describe 'then', ->

    it 'fucks up', ->
      assertionResult = expect(@Z(42)).to.eventually.deep.equal(42)
      expect(assertionResult).to.be.fulfilled

    it 'returns an object that has the expected functions', ->
      @Z.mixin({
        f1: ->
        f2: ->
      })
      methodsList = ['f1', 'f2']
      x = @Z(5).then((x) -> x * 10)
      keys = Object.keys(x).sort (a, b) -> a.localeCompare(b)
      mets = methodsList.sort (a, b) -> a.localeCompare(b)
      expect(keys).to.eql mets

  describe 'mixin', ->

    it 'returns undefined', ->
      ret = @Z.mixin({
        f1: -> 1
      })
      expect(ret).to.not.exist

    it 'allows new method to be added to the resulting promise', ->
      @Z.mixin({
        f1: (a1, a2) -> [@value, a1, a2]
      })
      x = @Z(50)
      val = x.f1(100, 200)
      expect(Object.keys(x)).to.eql ['f1']
      expect(val).to.become [50, 100, 200]

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
      expect(Object.keys(x)).to.eql ['f1', 'f2']
      expect(v1).to.become [50, 100, 200]

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
      expect(Object.keys(x)).to.eql ['f1', 'f2']
      expect(v2).to.become 80

    it 'can mixin the same function multiple times and passes the previous as context to the next', ->
      @Z.mixin({
        f1: (a1, a2) -> @value + a1 + a2
      })
      @Z.mixin({
        f1: (a1, a2) -> @base.call({ value: 1 }, 2, @value + a1 + a2)
      })

      x = @Z(50)
      v1 = x.f1(100, 200)

      expect(Object.keys(x)).to.eql ['f1']
      expect(v1).to.become 353

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
      expect(@Z(50).f1(100, 200)).to.become [50,["value","base"],[3,["value","base"],[2,["value"]]]]

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
      expect(@Z(50).f1(100, 200)).to.become [50,["value","base"],[3,["value","base"],[2,["value"]]]]

    it 'resolves arguments that are promises before running the mixin', ->
      @Z.mixin({
        f: (v) -> expect(v).to.eql 56
      })
      @Z(1).f(@Z(56))

    it 'resolves arguments that are promises before running the mixin several levels deep', ->
      @Z.mixin({
        f: (v) -> expect(v.a.b.c).to.eql 57
      })
      @Z(1).f(({ a: b: c: @Z(57) }))
