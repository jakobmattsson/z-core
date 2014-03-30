var expect = chai.expect;




(function() {
  var objectCreate = Object.create || function(obj) {
    var F = function() {};
    F.prototype = obj;
    return new F();
  };

  var oldMocha = mocha;
  mocha = objectCreate(oldMocha);

  mocha.run = function() {
    var runner = oldMocha.run();

    var failedTests = [];
    runner.on('end', function() {
      window.mochaResults = runner.stats;
      window.mochaResults.reports = failedTests;
    });

    runner.on('fail', logFailure);

    function logFailure(test, err) {

      var flattenTitles = function(test) {
        var titles = [];
        while (test.parent.title) {
          titles.push(test.parent.title);
          test = test.parent;
        }
        return titles.reverse();
      };

      failedTests.push({
        name: test.title,
        result: false,
        message: err.message,
        stack: err.stack,
        titles: flattenTitles(test)
      });
    };
  };
}());
