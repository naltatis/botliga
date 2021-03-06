m = require "../model/model"
MatchScorer = require("../rating").MatchScorer
Seq = require "seq"
_ = require "underscore"

class GuessService
  training_season: '2010'
  set: (token, matchId, hostGoals, guestGoals, force, callback) ->
    console.log force
    self = @
    Seq()
      .par ->
        m.Bot.findOne {apiToken: token}, @
      .par ->
        m.Match.findOne {id: matchId}, @
      .seq (bot, match) ->
        return callback new Error('invalid token') if not bot?
        return callback new Error('match not found') if not match?
        return callback new Error('match has already started') if not self._isMatchEditable match, force

        m.Guess.findOne {match: match._id, bot: bot._id}, (err, guess) =>
          this err, guess, bot, match
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
          
  _isMatchEditable: (match, force) ->
    return true if force
    return true if match.season == @training_season
    if match.date.isBefore(new Date())
      return false
    else
      return true

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
  getByMatchId: (matchId, callback) ->
    m.Guess.find {match: matchId}, callback
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
            if self.vars.bots[guess.bot]?
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
        points = {}
        matches =  _(matches).sortBy (e) -> e.date.getTime()
        for match in matches
          for guess in match.guesses
            points[guess.bot] or= 0
            points[guess.bot] += guess.points if guess.points?
        callback null, {matches: matches, points: points}
    
class BotService
  getByUser: (userId, callback) ->
    m.Bot.find({user: userId}).sort('id', 'ascending').find callback
  getByUserAndId: (userId, botId, callback) ->
    m.Bot.findOne {user: userId, _id: botId}, callback
  getByName: (botName, callback) ->
    m.Bot.findOne {name: botName}, callback
  getAll: (callback) ->
    m.Bot.find({name: {'$exists': true}}).find callback
  getAllWithPull: (callback) ->
    m.Bot.find({url: {'$ne': ''}, usePullApi: true}).find callback
    #m.Bot.find({url: {'$exists': true}, url: {'$ne': ''}, usePullApi: true}).find callback
    
class MatchService
  getBySeason: (season, callback) ->
    m.Match.find({season: season}).sort('date', 'ascending').find callback
  getCurrentGroup: (callback) ->
    date = new Date().addDays(-2)
    m.Match.find({date:{$gt: date}}).sort('date', 'ascending').find (err, matches) ->
      callback err, matches[0].group

class RatingService
  constructor: ->
    @scorer = new MatchScorer()
  updateForGuess: (guess, callback) ->
    m.Match.findOne { _id: guess.match }, (err, match) =>
      if match? && match.hostGoals? && match.guestGoals?
        guess.points = @scorer.score(
          [guess.hostGoals, guess.guestGoals]
          [match.hostGoals, match.guestGoals]
        )
        guess.save (err, guess) ->
          callback err, guess
      else
        callback()

(exports ? this).guess = new GuessService()
(exports ? this).rating = new RatingService()
(exports ? this).bot = new BotService()
(exports ? this).match = new MatchService()