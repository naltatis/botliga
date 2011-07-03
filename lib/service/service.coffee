m = require "../model/model"
MatchScorer = require("../rating").MatchScorer
Seq = require "seq"

class GuessService
  set: (token, matchId, hostGoals, guestGoals, callback) ->
    Seq()
      .par ->
        m.Bot.findOne {apiToken: token}, @
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
          callback err, guess, created
          
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
  getBySeasonAndGroup: (season, group, callback) ->
    matchKeys = ['id', 'hostName', 'hostId', 'guestName', 'guestId', 'date']
    guessKeys = ['hostGoals', 'guestGoals', 'points']
    botIds = []
    Seq()
      .seq 'bots', ->
        self = @
        m.Bot.find({name: {'$exists': true}}).find (err, bots) ->
          result = {}
          for bot in bots
            result[bot._id] = bot.name
          self null, result
      .seq ->
        m.Match.find {season: season, group: group}, @
      .flatten()
      .seqMap (match) ->
        self = @
        m.Guess.find {match: match._id}, (err, guesses) ->
          _match = {}
          for key in matchKeys
            _match[key] = match[key]
          _match.hostGoals = if match.hostGoals? then match.hostGoals else '-'
          _match.guestGoals = if match.guestGoals? then match.guestGoals else '-'
          
          _match.guesses = []
          for guess in guesses
            _guess = {}
            for key in guessKeys
              _guess[key] = guess[key]
            
            # only include guesses for passed matches
            if not match.date.isBefore(new Date())  
              _guess.hostGoals = _guess.guestGoals = '-'
              
            _guess.bot = self.vars.bots[guess.bot]
            _match.guesses.push _guess
            
          self null, _match
      .seq (matches...) ->
        callback null, matches
    
class BotService
  getByUser: (userId, callback) ->
    m.Bot.find({user: userId}).sort('id', 'ascending').find callback
  getByUserAndId: (userId, botId, callback) ->
    m.Bot.findOne {user: userId, _id: botId}, callback
  getAll: (callback) ->
    m.Bot.find({name: {'$exists': true}}).find callback
  getAllWithPull: (callback) ->
    m.Bot.find({url: {'$exists': true}, url: {'$ne': ''}, usePullApi: true}).find callback
    
class MatchService
  getBySeason: (season, callback) ->
    m.Match.find({season: season}).sort('date', 'ascending').find callback

class RatingService
  constructor: ->
    @scorer = new MatchScorer()
  updateForGuess: (guess, callback) ->
    m.Match.findOne { _id: guess.match }, (err, match) =>
      if match? && match.hostGoals >= 0 && match.guestGoals >= 0
        guess.points = @scorer.score(
          [guess.hostGoals, guess.guestGoals]
          [match.hostGoals, match.guestGoals]
        )
        guess.save (err, guess) ->
          callback err, guess
      else
        callback(new Error 'match not found or not ended')

(exports ? this).guess = new GuessService()
(exports ? this).rating = new RatingService()
(exports ? this).bot = new BotService()
(exports ? this).match = new MatchService()