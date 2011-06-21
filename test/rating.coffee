vows = require 'vows'
assert = require 'assert'
rating = require '../lib/rating'

vows.describe('rating for').addBatch(
  'one match with':
    topic: -> new rating.MatchScorer()
    'exact draw should give 5 points': (match) ->
      assert.equal match.score([0,0], [0,0]), 5
      assert.equal match.score([3,3], [3,3]), 5
    'exact home win shouldgive 5 points': (match) ->
      assert.equal match.score([1,0], [1,0]), 5
    'exact away win should give 5 points': (match) ->
      assert.equal match.score([0,2], [0,2]), 5
    'correct draw tendency gives 2 points': (match) ->
      assert.equal match.score([2,2], [1,1]), 2
    'wrong tendency doesnt give any points': (match) ->
      assert.equal match.score([1,2], [0,0]), 0
      assert.equal match.score([3,2], [0,1]), 0
      assert.equal match.score([0,0], [0,1]), 0
      assert.equal match.score([0,0], [2,0]), 0
    'home win tendency should give 2 points': (match) ->
      assert.equal match.score([8,1], [2,1]), 2
    'away win tendency should give 2 points': (match) ->
      assert.equal match.score([0,2], [0,3]), 2
    'draw tendency should give 2 points': (match) ->
      assert.equal match.score([2,2], [0,0]), 2
    'correct home win goal difference should give 3 points': (match) ->
      assert.equal match.score([3,1], [2,0]), 3
      assert.equal match.score([4,3], [3,2]), 3
    'correct away win goal difference should give 3 points': (match) ->
      assert.equal match.score([0,1], [1,2]), 3
      assert.equal match.score([1,4], [0,3]), 3
).addBatch(
  'multipe matchs with':
    topic: ->
      scorer = new rating.MatchScorer()
      new rating.GroupScorer(scorer)
    'two exact matches should give 10 points': (group) ->
      estimated = 1: [0,0], 2: [2,0]
      real      = 1: [0,0], 2: [2,0]
      assert.equal group.score(estimated, real), 10
    'no correct results should give 0 points': (group) ->
      estimated = 1: [0,0], 2: [2,0]
      real      = 1: [1,0], 2: [0,0]
      assert.equal group.score(estimated, real), 0
    'two tendencies and one exact draw 9 points': (group) ->
      estimated = 1: [2,0], 2: [1,2], 3: [4,4]
      real      = 1: [1,0], 2: [3,6], 3: [4,4]
      assert.equal group.score(estimated, real), 9
    'no match should give 0 points': (group) ->
      estimated = {}
      real      = {}
      assert.equal group.score(estimated, real), 0


).export module