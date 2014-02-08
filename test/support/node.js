var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');
var mochaAsPromised = require('mocha-as-promised');

chai.should();
chai.use(chaiAsPromised);
mochaAsPromised();
