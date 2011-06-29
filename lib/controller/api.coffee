s = require "../service/service"

guess = {}

guess.post = (req, res) ->
  token = req.param 'token'
  matchId = req.param 'match_id'
  result = req.param('result').split ':'
  
  s.guess.set token, matchId, result[0], result[1], (err, guess, created)->
    if err
      res.send 500
    else
      res.send if created then 201 else 200
      # update rating if match has ended
      s.rating.updateForGuess guess, (err, guess) ->
        if err
          console.log "error: #{err}"
        else
          console.log "updated score for guess #{guess._id} >> #{guess.points} points"

guess.get = (req, res) ->
  botId = req.param "bot_id"
  matchId = req.param "match_id"

  s.guess.get botId, matchId, (err, guess)->
    if err
      res.send 404
    else
      res.send "#{guess.hostGoals}:#{guess.guestGoals}", 200

stats = {}


(exports ? this).guess = guess