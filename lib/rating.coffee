class MatchScorer
  constructor: ->
  score: (estimated, real) ->
    estimated = @_analyse estimated
    real = @_analyse real
    
    if estimated[0] == real[0] && estimated[1] == real[1]
      points = 4 # exact match
    else if estimated.draw && real.draw
      points = 2 # draw tendency
    else if estimated.diff == real.diff
      points = 3 # goal diff
    else if estimated.home && real.home
      points = 2 # home win tendency
    else if estimated.away && real.away
      points = 2 # away win tendency
    else
      points = 0
    points
    
  _analyse: (result) ->
    {
      0: result[0]
      1: result[1]
      diff: result[0] - result[1]
      draw: result[0] == result[1]
      home: result[0] > result[1]
      away: result[0] < result[1]
    }
    
class GroupScorer
    constructor: (@scorer) ->
    score: (estimated, real) ->
      points = 0
      for matchId, result of estimated
        points += @scorer.score result, real[matchId]
      points

(exports ? this).MatchScorer = MatchScorer
(exports ? this).GroupScorer = GroupScorer