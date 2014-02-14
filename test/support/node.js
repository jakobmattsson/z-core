var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');
var mochaAsPromised = require('mocha-as-promised');

chai.should();
chai.use(chaiAsPromised);
mochaAsPromised();

var global = (function() { return this; }());

var jscov = require('jscov');

global.requireSource = function(name) {
  return require(jscov.cover('../..', 'lib', name));
};
