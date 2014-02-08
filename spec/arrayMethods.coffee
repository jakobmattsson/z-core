require('./support/node')
Q = require 'q'
jscov = require 'jscov'
{zeeCreator, methods} = require jscov.cover('..', 'src', 'constructor')
Z = zeeCreator({ log: -> })



describe 'array method', ->

  describe 'filter', ->

    it 'works given an array', ->
      arr = Z([{ a: 1 }, { a: 2 }, { a: 3 }])
      small = arr.filter (x) -> x.a <= 2
      small.should.become [{ a: 1 }, { a: 2 }]

  describe 'join', ->

    it 'works given an array', ->
      Z(["abc", 56, {}]).join('').should.become "abc56[object Object]"

    it 'fails given an object', ->
      Z({}).join('').should.be.rejected



describe 'Z method', ->

  it 'returns an object that is inherited from Q', ->
    prototypeOfQ = Q.makePromise.prototype
    x = Z(1)
    prototypeOfQ.isPrototypeOf(x).should.eql true

  it 'returns an object that has the expected functions', ->
    x = Z(1)
    keys = Object.keys(x).sort (a, b) -> a.localeCompare(b)
    mets = methods().sort (a, b) -> a.localeCompare(b)
    keys.should.eql mets



describe 'Q method', ->

  describe 'get', ->

    it 'retrieves the value of a property (just like in Q)', ->
      bValue = [1,2]
      arr = Z({ a: { b: bValue } })
      filtered = arr.get('a')
      filtered.should.become { b: bValue }

    it 'retrieves the value of a property as a reference (just like in Q)', ->
      bValue = [1,2]
      arr = Z({ a: { b: bValue } })
      filtered = arr.get('a')
      bValue.push(3)
      filtered.should.become { b: bValue }

    it 'returns an object that is inherited from Q', ->
      prototypeOfQ = Q.makePromise.prototype
      x = Z({ a: { b: 1 } }).get('a')
      prototypeOfQ.isPrototypeOf(x).should.eql true

    it 'returns an object that is inherited from Q even when called multiple times', ->
      prototypeOfQ = Q.makePromise.prototype
      x = Z({ a: { b: { c: 1 } } }).get('a').get('b')
      prototypeOfQ.isPrototypeOf(x).should.eql true

    it 'returns an object that has the expected functions', ->
      x = Z({ a: { b: 1 }}).get('a')
      keys = Object.keys(x).sort (a, b) -> a.localeCompare(b)
      mets = methods().sort (a, b) -> a.localeCompare(b)
      keys.should.eql mets

    it 'returns an object that has the expected functions even when called multiple times', ->
      x = Z({ a: { b: { c: 1 } }}).get('a').get('b')
      keys = Object.keys(x).sort (a, b) -> a.localeCompare(b)
      mets = methods().sort (a, b) -> a.localeCompare(b)
      keys.should.eql mets



describe 'string method', ->

  describe 'split', ->

    it 'works given a string', ->
      Z("jakob mattsson").split('a').should.become ["j", "kob m", "ttsson"]

    it 'fails given an object', ->
      Z({}).split('a').should.be.rejected



describe 'underscore method', ->

  describe 'keys', ->

    it 'returns the keys of an object', ->
      Z({ a: 1, b: 2 }).keys().should.become ["a", "b"]

    it 'returns the keys of an array', ->
      Z([1,2,3]).keys().should.become ["0", "1", "2"]

    it 'fails when executed on a string', ->
      Z("foobar").keys().should.be.rejected



describe 'underscore method each', ->

  describe 'keys', ->

    it 'returns the keys of an object', ->
      Z([{ a: 1, b: 2 }, {}, { x: 1 }]).omitEach('a').should.become [{ b: 2 }, {}, { x: 1 }]



describe 'generic method', ->

  describe 'toString', ->

    it 'turns the value into a string', ->
      Z(1).toString().should.become "1"
