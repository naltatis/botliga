s = require "../service/service"

guess = {}

guess.post = (req, res) ->

  token = req.param 'token'
  return res.send "missing token parameter", 400 if not token?
  
  matchId = req.param 'match_id'
  return res.send "missing match_id parameter", 400 if not matchId?
  
  result = req.param 'result'
  return res.send "missing result parameter", 400 if not result?
  return res.send "invalid result format", 400 if not result.match(/^\d+:\d+$/)?
  
  result = result.split ':'
  
  # god mode for manipulating guesses
  force = req.param('secret') == process.env.MAINTENANCE
  
  s.guess.set token, matchId, result[0], result[1], force, (err, guess, created)->
    if err
      res.send err.message, 500
    else
      res.send if created then 201 else 200
      # update rating if match has ended
      s.rating.updateForGuess guess, (err, guess) ->
        if err
          console.log "error: #{err}"
        else
          console.log "updated score for guess #{guess._id} >> #{guess.points} points"


stats = {}


(exports ? this).guess = guess