s = require "./service"
stats = require "./stats"
Seq = require "seq"

requireLogin = (req, res, callback) ->
  if req.loggedIn
    callback()
  else
    res.redirect '/auth/github'

settings = (req, res) ->
  requireLogin req, res, ->
    s.bot.getByUser req.user._id, (err, bots) ->
      res.render 'settings',
        navigation: 'settings'
        bots: bots
        
updateBot = (req, res) ->
  requireLogin req, res, ->
    s.bot.getByUserAndId req.user._id, req.param('id'), (err, bot) ->
      return res.send 500 if err
      return res.send 404 if not bot?
      bot.name = req.param('name') if req.param('name')?
      bot.url = req.param('url') if req.param('url')?
      bot.repository = req.param('repository') if req.param('repository')?
      bot.usePullApi = req.param('usePullApi') == "true" if req.param('usePullApi')?
      bot.save (err, bot) ->
        res.send if err then 500 else 200

datasources = (req, res) ->
  Seq()
    .par ->
      s.match.getBySeason "2011", @
    .par ->
      s.match.getBySeason "2010", @
    .seq (currentMatches, lastMatches) ->
      data = 
        navigation: 'datasources'
        currentMatches: currentMatches
        lastMatches: lastMatches
    
      res.render 'datasources', data

results = (req, res) ->
  Seq()
    .par ->
      stats.botRatingByGroup "2010", @
    .par ->
      s.bot.getAll @
    .seq (botsByGroups, bots) ->
      data = 
        navigation: 'results'
        botsByGroups: botsByGroups
        groups: [1..34]
        bots: bots
      console.log botsByGroups
      res.render 'results', data
      
matchesBySeason = (req, res) ->
  s.match.getBySeason req.params.season, (err, data) -> res.send data

(exports ? this).settings = settings
(exports ? this).updateBot = updateBot
(exports ? this).results = results
(exports ? this).datasources = datasources
(exports ? this).matchesBySeason = matchesBySeason
