express = require "express"
stylus = require "stylus"
nib = require "nib"
auth = require('./lib/model/auth').auth
crawler = require("./lib/import/crawler").crawler
stats = require "./lib/service/stats"
api = require "./lib/controller/api"
web = require "./lib/controller/web"
maintenance = require "./lib/controller/maintenance"
require "express-namespace"
require "date-utils"

app = express.createServer()
app.set 'view engine', 'jade'
app.use express.bodyParser()
app.use express.cookieParser()
app.use express.session(secret: process.env.SECRET || "soadh89g2OHA")
app.use auth.middleware()
app.use app.router
app.use express.static(__dirname + '/public')
app.use require('connect-assets')()

auth.helpExpress app

app.get "/", (req, res) ->
  res.render 'index', navigation: 'home'

app.get "/auswertung", web.results
app.get "/auswertung/:season", web.results
app.get "/auswertung/:season/:group", web.results
app.get "/bot/:user/:bot", web.botProfile
app.get "/einstellungen", web.settings
app.get "/datenquellen", web.datasources
app.post "/bot", web.updateBot
app.get "/impressum", (req, res) -> res.render 'impressum', navigation: 'impressum'

app.namespace "/maintenance", ->
  app.get "/refresh-points", maintenance.refreshPoints
  app.get "/import/:season", maintenance.importSeason
  app.get "/import/:season/:group", maintenance.importGroupController
  
app.namespace "/api", ->
  app.post "/guess", api.guess.post

  #app.get "/crawl", (req, res) ->
  #  crawler.updateAll ->
  #    res.send(200)
  
  app.get "/guesses/:season/:group", web.guessesBySeasonAndGroup

  app.get "/points/:season", (req, res) ->
    stats.botPointsBySeason req.params.season, (err, data) -> res.send data

  app.get "/matches/:season", web.matchesBySeason
  
  app.get "/bot/:user/:bot/results/:season", (req, res) ->
    stats.guessesByBotNameAndSeason "#{req.params.user}/#{req.params.bot}", req.params.season, (err, data) -> res.send data || err

  app.namespace "/stats", ->
    app.get "/popular-results/:season", (req, res) ->
      stats.popularResults req.params.season, (err, data) -> res.send data || err

    app.get "/tendency/:season", (req, res) ->
      stats.tendency req.params.season, (err, data) -> res.send data || err

port = process.env.PORT || 3000
app.listen port, ->
  console.log "Listening on #{port}"
  
#updater = new Updater()
#updater.start()