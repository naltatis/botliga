s = require "./service"

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

(exports ? this).settings = settings
(exports ? this).updateBot = updateBot