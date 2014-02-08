chai = require 'chai'
chaiAsPromised = require 'chai-as-promised'
mochaAsPromised = require 'mocha-as-promised'

chai.should()
chai.use(chaiAsPromised)
mochaAsPromised()