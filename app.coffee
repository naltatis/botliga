express = require "express"
stylus = require "stylus"
auth = require('./lib/auth').auth
openligadb = require "./lib/openligadb"
stats = require "./lib/stats"
s = require "./lib/service"
require "express-namespace"

app = express.createServer()
app.set 'view engine', 'jade'
app.use express.bodyParser()
app.use express.cookieParser()
app.use express.session(secret: "soadh89g2OHA")
app.use app.router
app.use express.static(__dirname + '/public')
app.use auth.middleware()

app.use stylus.middleware(
  src: "#{__dirname}/views"
  dest: "#{__dirname}/public"
  compile: (str, path, fn) ->
    console.log str
    stylus(str).set('compress', false)
)
auth.helpExpress app

app.get "/", (req, res) ->
  res.render 'index'
  
app.get "/stats", (req, res) ->
  stats.popularResults (data) ->
    popularResults = for i, entry of data
      { result: entry._id, count: entry.value.count }
    stats.tendency (data) ->
      tendency = for i, entry of data
        { result: entry._id, count: entry.value.count }
      stats.tendencyHistory (data) ->
        tendencyHistory = for i, entry of data
          { year: entry._id, tendency: entry.value }
          
        res.render 'stats', {
          popularResults: JSON.stringify(popularResults)
          tendency: JSON.stringify(tendency)
          tendencyHistory: JSON.stringify(tendencyHistory[2..])
        }

app.namespace "/api", ->
  app.post "/guess", (req, res) ->
    botId = req.param 'bot_id'
    matchId = req.param 'match_id'
    result = req.param('result').split ':'
    
    s.guess.set botId, matchId, result[0], result[1], (err, created)->
      if err
        res.send 500
      else
        res.send if created then 201 else 200

  app.get "/guess", (req, res) ->
    botId = req.param "bot_id"
    matchId = req.param "match_id"
    
    s.guess.get botId, matchId, (err, guess)->
      if err
        res.send 404
      else
        res.send "#{guess.hostGoals}:#{guess.guestGoals}", 200

  app.get "/import", (req, res) ->
    importer = new openligadb.MatchImporter()
    importer.importBySeason season for season in [2003..2010]

  app.namespace "/stats", ->
    app.get "/popular-results", (req, res) ->
      stats.popularResults (data) ->
        res.send data

    app.get "/tendency", (req, res) ->
      stats.tendency (data) ->
        res.send data

    app.get "/tendency-history", (req, res) ->
      stats.tendencyHistory (data) ->
        res.send data

  app.get "/evaluate", (req, res) ->
    res.send "Hello World"

port = process.env.PORT || 3000
app.listen port, ->
  console.log "Listening on #{port}"