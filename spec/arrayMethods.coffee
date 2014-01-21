jscov = require 'jscov'
Z = require jscov.cover('..', 'src', 'index')

describe 'array method', ->

  describe 'filter', ->

    it 'works', (done) ->
      arr = Z([{ a: 1 }, { a: 2 }, { a: 3 }])
      filtered = arr.filter (x) -> x.a <= 2
      filtered.then (data) ->
        data.should.eql [{ a: 1 }, { a: 2 }]
        done()
