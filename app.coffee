express = require "express"
openligadb = require "./lib/openligadb"
stats = require "./lib/stats"
model = require "./lib/model"
require "express-namespace"

app = express.createServer()
app.set 'view engine', 'jade'
app.use express.bodyParser()
app.use app.router
app.use express.static(__dirname + '/public')

app.get "/", (req, res) ->
  res.send "Hello World"
  
app.get "/stats", (req, res) ->
  stats.popularResults (data) ->
    popularResults = for i, entry of data
      { result: entry._id, count: entry.value.count }
    stats.tendency (data) ->
      tendency = for i, entry of data
        { result: entry._id, count: entry.value.count }
      res.render 'stats', {
        popularResults: JSON.stringify(popularResults)
        tendency: JSON.stringify(tendency)
      }

app.namespace "/api", ->
  app.post "/guess", (req, res) ->
    botId = req.param 'bot_id'
    matchId = req.param 'match_id'
    result = req.param('result').split ':'
    
    model.Bot.findOne {id: botId}, (err, bot) ->
      return res.send("bot ##{botId} does not exist", 404) unless bot?
      model.Match.findOne {id: matchId}, (err, match) ->
        return res.send("match ##{matchId} does not exist", 404) unless match?
        console.log match._id

        for g in bot.guesses
          if "#{g.match}" == "#{match._id}"
            g.hostGoal = result[0]
            g.guestGoal = result[1]
            updated = true
        if not updated
          bot.guesses.push {
            hostGoal: result[0]
            guestGoal: result[1]
            match: match._id
          }

        bot.save (err, bot)->
          res.send 'ok'
  
  app.get "/guess", (req, res) ->
    botId = req.param "bot_id"
    matchId = req.param "match_id"

    model.Bot.findOne {id: botId}, (err, bot) ->
      return res.send("bot ##{botId} does not exist", 404) unless bot?
      model.Match.findOne {id: matchId}, (err, match) ->
        return res.send("match ##{matchId} does not exist", 404) unless match?
        for g in bot.guesses
          if "#{g.match}" == "#{match._id}"
            return res.send "#{g.hostGoal}:#{g.guestGoal}", 200
        res.send "not found", 404

  app.get "/import", (req, res) ->
    importer = new openligadb.MatchImporter()
    importer.importBySeason season for season in [2003..2010]

  app.namespace "/stats", ->
    app.get "/popular_results", (req, res) ->
      stats.popularResults (data) ->
        res.send data

    app.get "/tendency", (req, res) ->
      stats.tendency (data) ->
        res.send data


  app.get "/evaluate", (req, res) ->
    res.send "Hello World"

app.listen 3000