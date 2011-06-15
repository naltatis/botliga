m = require "./model"
Seq = require "seq"

class GuessService
  set: (botId, matchId, hostGoals, guestGoals, callback) ->
    Seq()
      .par ->
        m.Bot.findOne {id: botId}, @
      .par ->
        m.Match.findOne {id: matchId}, @
      .seq (bot, match) ->
        if bot? && match?
          m.Guess.findOne {match: match._id, bot: bot._id}, (err, guess) =>
            this err, guess, bot, match
        else
          callback new Error('not found')
      .seq (guess, bot, match) ->
        created = false
        if not guess?
          guess = new m.Guess()
          guess.match = match._id
          guess.bot = bot._id
          created = true
        guess.hostGoals = hostGoals
        guess.guestGoals = guestGoals
        guess.save (err, guess) ->
          callback err, created  
          
  get: (botId, matchId, callback) ->
    Seq()
      .par ->
        m.Bot.findOne {id: botId}, @
      .par ->
        m.Match.findOne {id: matchId}, @
      .seq (bot, match) ->
        if bot? && match?
          m.Guess.findOne {match: match._id, bot: bot._id}, callback
        else
          callback(new Error 'not found')

(exports ? this).guess = new GuessService()