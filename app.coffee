express = require "express"
openligadb = require "./lib/openligadb"
stats = require "./lib/stats"
require "express-namespace"

app = express.createServer()
app.set 'view engine', 'jade'
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