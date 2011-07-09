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
      if match? && match.hostGoals >= 0 && match.guestGoals >= 0
        guess.points = scorer.score(
          [guess.hostGoals, guess.guestGoals]
          [match.hostGoals, match.guestGoals]
        )
        console.log [guess.hostGoals, guess.guestGoals], [match.hostGoals, match.guestGoals], guess.points
        guess.save cb
      else
        console.log "match hasn't ended yet"
        cb()

    Seq()
      .seq ->
        m.Guess.find {}, @
      .flatten()
      .parMap (guess) ->
        updateGuess guess, @
      .seq ->
        res.send 200

importer = (req, res) ->
  requireSecret req, res, ->
    importer = new openligadb.MatchImporter()
    importer.importBySeason season for season in [req.params.season]

(exports ? this).importer = importer
(exports ? this).refreshPoints = refreshPoints
