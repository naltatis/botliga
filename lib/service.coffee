m = require "./model"
Seq = require "seq"

class GuessService
  set: (botId, matchId, hostGoals, guestGoals, callback) ->
    
    Seq()
      .par -> m.Bot.findOne {id: botId}, @
      .par -> m.Match.findOne {id: matchId}, @
      .seq (bot, match) ->
        if bot? && match?
          m.Guess.findOne {match: match._id, bot: bot._id}, @
      .seq (guess) ->
        if not guess?
          guess = new model.Guess()
          guess.match = match._id
          guess.bot = bot._id
        guess.hostGoals = hostGoals
        guess.guestGoals = guestGoals
        guess.save callback

(exports ? this).guess = new GuessService()