express = require "express"
stylus = require "stylus"
nib = require "nib"
auth = require('./lib/auth').auth
openligadb = require "./lib/openligadb"
stats = require "./lib/stats"
api = require "./lib/api"
web = require "./lib/web"
github = require "./lib/github"
require "express-namespace"


# stylus compiler
compile = (str, path) ->
  stylus(str)
    .set('filename', path)
    .include(nib.path)

app = express.createServer()
app.set 'view engine', 'jade'
app.use express.bodyParser()
app.use express.cookieParser()
app.use express.session(secret: "soadh89g2OHA")
app.use auth.middleware()
app.use app.router
app.use stylus.middleware(src: __dirname + '/public', compile: compile)
app.use express.static(__dirname + '/public')

app.use stylus.middleware(
  src: "#{__dirname}/views"
  dest: "#{__dirname}/public"
  compile: (str, path, fn) ->
    console.log str
    stylus(str).set('compress', false)
)
auth.helpExpress app

app.get "/", (req, res) ->
  res.render 'index', navigation: 'home'

app.get "/einstellungen", web.settings

app.namespace "/api", ->
  app.post "/guess", api.guess.post
  app.get "/guess", api.guess.get

  app.get "/import", (req, res) ->
    importer = new openligadb.MatchImporter()
    importer.importBySeason season for season in [2011]

  app.namespace "/stats", ->
    app.get "/popular-results", (req, res) ->
      stats.popularResults (data) -> res.send data

    app.get "/tendency", (req, res) ->
      stats.tendency (data) -> res.send data

    app.get "/tendency-history", (req, res) ->
      stats.tendencyHistory (data) -> res.send data

port = process.env.PORT || 3000
app.listen port, ->
  console.log "Listening on #{port}"