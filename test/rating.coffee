vows = require 'vows'
assert = require 'assert'

Rating = require('../lib/rating').Rating

suite = vows.describe('Result').addBatch(
  'Rating':
    topic: -> new Rating()
    'a correct draw should give two points': (rating) ->
      estimated =
        1: [0,0]
      real =
        1: [0,0]
      points = rating.score estimated, real
      assert.equal points, 2
      # Test the result of the topic
    'A sub-context': ->
      # Executed when the tests above finish running
    'Another context': ->
      # Executed in parallel to 'A context'
)
suite.export module