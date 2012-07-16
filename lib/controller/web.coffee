s = require "../service/service"
github = require("../service/github").github
stats = require "../service/stats"
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
      console.log req.user._id, req.param('id'), bot
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
      s.match.getBySeason "2012", @
    .par ->
      s.match.getBySeason "2010", @
    .seq (currentMatches, lastMatches) ->
      data = 
        navigation: 'datasources'
        currentMatches: currentMatches
        lastMatches: lastMatches
    
      res.render 'datasources', data

results = (req, res) ->
  model =
    season: req.param 'season'
    group: req.param 'group'
    navigation: 'results'
    
  model.season or= '2011'
  model.group or= '34'
  
  if model.group?
    res.render 'results', model    
  else
    s.match.getCurrentGroup (err, group) ->
      model.group = group
      res.render 'results', model    
      
botProfile = (req, res) ->
  name = "#{req.params.user}/#{req.params.bot}"
  
  Seq()
    .seq ->
      s.bot.getByName name, (err, bot) =>
        err = new Error("bot not found") if err? || !bot?
        @ err, bot
    .par (bot) ->
      github.getRepoDetails bot.name, @
    .par (bot) ->
      github.getRepoCommits bot.name, @
    .seq (bot, details, commits) ->
      data = 
        bot: bot
        details: details
        commits: commits
        navigation: 'results'
      res.render 'bot-profile', data
    .catch (err) ->
      res.send 404
      
matchesBySeason = (req, res) ->
  s.match.getBySeason req.params.season, (err, data) -> res.send data

guessesBySeasonAndGroup = (req, res) ->
  return res.send 400 if !parseInt(req.params.season, 10) || !parseInt(req.params.group, 10)
  return res.send 404 if not req.params.season? && req.params.group?
  s.guess.getBySeasonAndGroup req.params.season, req.params.group, (err, data) -> res.send data


(exports ? this).settings = settings
(exports ? this).updateBot = updateBot
(exports ? this).results = results
(exports ? this).datasources = datasources
(exports ? this).matchesBySeason = matchesBySeason
(exports ? this).guessesBySeasonAndGroup = guessesBySeasonAndGroup
(exports ? this).botProfile = botProfile
