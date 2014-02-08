chai = require 'chai'
jscov = require 'jscov'
chaiAsPromised = require 'chai-as-promised'
mochaAsPromised = require 'mocha-as-promised'

chai.should()
chai.use(chaiAsPromised)
mochaAsPromised()


Z = require jscov.cover('..', 'src', 'index')

describe 'array method', ->

  describe 'filter', ->

    it 'works', ->
      arr = Z([{ a: 1 }, { a: 2 }, { a: 3 }])
      small = arr.filter (x) -> x.a <= 2
      small.should.become [{ a: 1 }, { a: 2 }]



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



describe 'string method', ->

  describe 'split', ->

    it 'works', ->
      Z("jakob mattsson").split('a').should.become ["j", "kob m", "ttsson"]



describe 'underscore method', ->

  describe 'keys', ->

    it 'returns the keys of an object', ->
      Z({ a: 1, b: 2 }).keys().should.become ["a", "b"]

    it 'returns the keys of an array', ->
      Z([1,2,3]).keys().should.become ["0", "1", "2"]

    it 'fails when executed on a string', ->
      Z("foobar").keys().should.be.rejected
