(function() {
  var assert, rating, vows;
  vows = require('vows');
  assert = require('assert');
  rating = require('../lib/rating');
  vows.describe('rating for').addBatch({
    'one match with': {
      topic: function() {
        return new rating.MatchScorer();
      },
      'exact draw should give 4 points': function(match) {
        assert.equal(match.score([0, 0], [0, 0]), 4);
        return assert.equal(match.score([3, 3], [3, 3]), 4);
      },
      'exact home win shouldgive 4 points': function(match) {
        return assert.equal(match.score([1, 0], [1, 0]), 4);
      },
      'exact away win should give 4 points': function(match) {
        return assert.equal(match.score([0, 2], [0, 2]), 4);
      },
      'correct draw tendency gives 2 points': function(match) {
        return assert.equal(match.score([2, 2], [1, 1]), 2);
      },
      'wrong tendency doesnt give any points': function(match) {
        assert.equal(match.score([1, 2], [0, 0]), 0);
        assert.equal(match.score([3, 2], [0, 1]), 0);
        assert.equal(match.score([0, 0], [0, 1]), 0);
        return assert.equal(match.score([0, 0], [2, 0]), 0);
      },
      'home win tendency should give 2 points': function(match) {
        return assert.equal(match.score([8, 1], [2, 1]), 2);
      },
      'away win tendency should give 2 points': function(match) {
        return assert.equal(match.score([0, 2], [0, 3]), 2);
      },
      'draw tendency should give 2 points': function(match) {
        return assert.equal(match.score([2, 2], [0, 0]), 2);
      },
      'correct home win goal difference should give 3 points': function(match) {
        assert.equal(match.score([3, 1], [2, 0]), 3);
        return assert.equal(match.score([4, 3], [3, 2]), 3);
      },
      'correct away win goal difference should give 3 points': function(match) {
        assert.equal(match.score([0, 1], [1, 2]), 3);
        return assert.equal(match.score([1, 4], [0, 3]), 3);
      }
    }
  }).addBatch({
    'multipe matchs with': {
      topic: function() {
        var scorer;
        scorer = new rating.MatchScorer();
        return new rating.GroupScorer(scorer);
      },
      'two exact matches should give 8 points': function(group) {
        var estimated, real;
        estimated = {
          1: [0, 0],
          2: [2, 0]
        };
        real = {
          1: [0, 0],
          2: [2, 0]
        };
        return assert.equal(group.score(estimated, real), 8);
      },
      'no correct results should give 0 points': function(group) {
        var estimated, real;
        estimated = {
          1: [0, 0],
          2: [2, 0]
        };
        real = {
          1: [1, 0],
          2: [0, 0]
        };
        return assert.equal(group.score(estimated, real), 0);
      },
      'two tendencies and one exact draw 8 points': function(group) {
        var estimated, real;
        estimated = {
          1: [2, 0],
          2: [1, 2],
          3: [4, 4]
        };
        real = {
          1: [1, 0],
          2: [3, 6],
          3: [4, 4]
        };
        return assert.equal(group.score(estimated, real), 8);
      },
      'no match should give 0 points': function(group) {
        var estimated, real;
        estimated = {};
        real = {};
        return assert.equal(group.score(estimated, real), 0);
      }
    }
  })["export"](module);
}).call(this);
