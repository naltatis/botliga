express = require "express"
model = require "./lib/model"
require "express-namespace"
app = express.createServer()

app.get "/", (req, res) ->
  res.send "Hello World"

app.namespace "/api", ->
  app.get "/", (req, res) ->
    instance = new model.Match()
    instance.id = 7
    instance.team1 = "Werder"
    instance.team2 = "Hamburg"
    instance.save (err) -> 
      res.send "saved"
  app.get "/evaluate", (req, res) ->
    res.send "Hello World"

app.listen 3000