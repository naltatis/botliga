s = require "./service"

requireLogin = (req, res, callback) ->
  if req.loggedIn
    callback()
  else
    res.redirect '/auth/github'

settings = (req, res) ->
  requireLogin req, res, ->
    console.log 
    s.guess.getByUser req.user._id, (err, bots) ->
      res.render 'settings',
        navigation: 'settings'
        bots: bots
  
(exports ? this).settings = settings