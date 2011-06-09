express = require "express"
openligadb = require "./lib/openligadb"
require "express-namespace"
app = express.createServer()

app.get "/", (req, res) ->
  res.send "Hello World"

app.namespace "/api", ->
  app.get "/", (req, res) ->
    importer = new openligadb.MatchImporter()
    importer.importBySeason 2009
    importer.importBySeason 2010

  app.get "/evaluate", (req, res) ->
    res.send "Hello World"

app.listen 3000