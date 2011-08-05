m = require "../model/model"
MatchScorer = require("../rating").MatchScorer
openligadb = require "../import/openligadb"
Seq = require "seq"

requireSecret = (req, res, callback) ->
  if req.param('secret') == process.env.MAINTENANCE
    callback()
  else
    res.send 403

refreshPoints = (req, res) ->
  requireSecret req, res, ->
    scorer = new MatchScorer()
      
    updateGuess = (guess, cb) ->
      scorer = new MatchScorer()
      m.Match.findOne { _id: guess.match }, (err, match) ->
        updatePoints guess, match, cb
        
          
    updatePoints = (guess, match, cb) ->
      if match? && match.hostGoals? && match.guestGoals?
        guess.points = scorer.score(
          [guess.hostGoals, guess.guestGoals]
          [match.hostGoals, match.guestGoals]
        )
        console.log [guess.hostGoals, guess.guestGoals], [match.hostGoals, match.guestGoals], guess.points
      else
        guess.points = null
        console.log "match hasn't ended yet"
      guess.save cb

    Seq()
      .seq ->
        m.Guess.find {}, @
      .flatten()
      .parMap (guess) ->
        updateGuess guess, @
      .seq ->
        res.send 200

importSeason = (req, res) ->
  requireSecret req, res, ->
    season = req.param 'season'
    if season?
      importer = new openligadb.MatchImporter()
      importer.importBySeason season, ->
        res.send "imported #{season}"
    else
      res.send "season required"

importGroup = (req, res) ->
  requireSecret req, res, ->
    season = req.param 'season'
    group = req.param 'group'
    if season? && group?
      importer = new openligadb.MatchImporter()
      importer.importBySeasonAndGroup season, group, ->
        res.send "imported #{group}/#{season}"
    else
      res.send "season and group required"


(exports ? this).importSeason = importSeason
(exports ? this).importGroup = importGroup
(exports ? this).refreshPoints = refreshPoints
