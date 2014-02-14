Q = require 'q'
_ = require 'underscore'
_s = require 'underscore.string'
jscov = require 'jscov'
Z = require(jscov.cover('..', 'src', 'index')).init()


genericMethods = ['toString']
arrayMethods = ['reverse', 'concat', 'join', 'slice', 'findIndex']
stringMethods = ['split']

underscoreStringMethods = ['startsWith']
underscoreEachMethods = ['omit', 'pick', 'keys']
underscoreMethods = [
  # COLLECTIONS
  'each', 'forEach'
  'map', 'collect'
  'reduce', 'inject', 'foldl', 'fold'
  'reduceRight', 'foldr'
  'find', 'detect'
  'filter', 'select'
  'where'
  'findWhere'
  'reject'
  'every', 'all'
  'some', 'any'
  'contains', 'include'
  'invoke'
  'pluck'
  'max'
  'min'
  'sortBy'
  'groupBy'
  'indexBy'
  'countBy'
  'shuffle'
  'sample'
  'toArray'
  'size'

  # ARRAYS
  'first', 'head', 'take'
  'initial'
  'last'
  'rest', 'tail', 'drop'
  'compact'
  'flatten'
  'without'
  'union'
  'intersection'
  'difference'
  'uniq', 'unique'
  'zip'
  'object'
  'indexOf'
  'lastIndexOf'
  'sortedIndex'
  'range'

  # FUNCTIONS
  'bind'
  'bindAll'
  'partial'
  'memoize'
  'delay'
  'defer'
  'throttle'
  'debounce'
  'once'
  'after'
  'wrap'
  'compose'

  # OBJECTS
  'keys'
  'values'
  'pairs'
  'invert'
  'functions', 'methods'
  'extend'
  'pick'
  'omit'
  'defaults'
  'clone'
  'tap'
  'has'
  'isEqual'
  'isEmpty'
  'isElement'
  'isArray'
  'isObject'
  'isArguments'
  'isFunction'
  'isString'
  'isNumber'
  'isFinite'
  'isBoolean'
  'isDate'
  'isRegExp'
  'isNaN'
  'isNull'
  'isUndefined'

  # UTILITY
  # 'noConflict' -- not applicable
  'identity'
  'times'
  'random'
  # 'mixin' -- I have no idea how this would affect things
  'uniqueId'
  'escape'
  'unescape'
  'result'
  'template'

  # CHAINING -- Z has its own chaining
  # 'chain'
  # 'value'
]

exts = {}

underscoreStringMethods.forEach (method) ->
  exts[method] = (args...) ->
    _s[method](@value, args...)

underscoreEachMethods.forEach (method) ->
  exts[method + 'Each'] = (args...) ->
    @value.map (e) -> _(e)[method](args...)

underscoreMethods.forEach (method) ->
  exts[method] = (args...) ->
    _(@value)[method](args...)

genericMethods.forEach (methodName) ->
  exts[methodName] = (args...) ->
    @value[methodName](args...)

arrayMethods.forEach (methodName) ->
  exts[methodName] = (args...) ->
    if !Array.isArray(@value)
      throw new Error("Object must be an array in order to invoke '#{methodName}'")
    @value[methodName](args...)

stringMethods.forEach (methodName) ->
  exts[methodName] = (args...) ->
    if typeof @value != 'string'
      throw new Error("Object must be a string in order to invoke '#{methodName}'")
    @value[methodName](args...)




Z.mixin(exts)



methodsList = []
Object.keys(exts).forEach (name) ->
  methodsList.push(name)



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

  describe 'bind', ->

    it 'binds a function to the given context', ->
      f = Z((x) -> @ + x).bind(100)
      result = f.then (fResolved) -> fResolved(2)
      result.should.become 102

  describe 'contains', ->

    it 'returns true when an array contains the given value', ->
      Z([1, 2, 3]).contains(2).should.become true

    it 'returns false when an array contains the given value', ->
      Z([1, 2, 3]).contains(4).should.become false



describe 'underscore.string method', ->

  describe 'startsWith', ->

    it 'returns true if the given string starts with the given argument', ->
      Z("foobar").startsWith('foo').should.become true

    it 'returns false if the given string does not start with the given argument', ->
      Z("foobar").startsWith('bar').should.become false



describe 'underscore method each', ->

  describe 'omit', ->

    it 'returns the keys of an object', ->
      Z([{ a: 1, b: 2 }, {}, { x: 1 }]).omitEach('a').should.become [{ b: 2 }, {}, { x: 1 }]



describe 'generic method', ->

  describe 'toString', ->

    it 'turns the value into a string', ->
      Z(1).toString().should.become "1"
