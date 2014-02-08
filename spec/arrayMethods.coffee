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
