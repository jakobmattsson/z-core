var chai = require('chai');
var jscov = require('jscov');
var chaiAsPromised = require('chai-as-promised');
var global = (function() { return this; }());

chai.use(chaiAsPromised);

global.expect = chai.expect;
global.Z = require(jscov.cover('../..', 'lib', 'index'));
