(function() {
  var Rating, assert, suite, vows;
  vows = require('vows');
  assert = require('assert');
  Rating = require('../lib/rating').Rating;
  suite = vows.describe('Result').addBatch({
    'Rating': {
      topic: function() {
        return new Rating();
      },
      'a correct draw should give two points': function(rating) {
        var estimated, points, real;
        estimated = {
          1: [0, 0]
        };
        real = {
          1: [0, 0]
        };
        points = rating.score(estimated, real);
        return assert.equal(points, 2);
      },
      'A sub-context': function() {},
      'Another context': function() {}
    }
  });
  suite["export"](module);
}).call(this);
