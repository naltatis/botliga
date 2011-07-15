root = exports ? this

rest = require 'restler'
cache = require('../vendor/node-cache')

class GitHub
  constructor: ->
    @cacheTime = 1000*60*10
    
  getRepoDetails: (repoName, cb) ->
    url = "https://api.github.com/repos/#{repoName}"
    @_request url, cb

  getRepoCommits: (repoName, cb) ->
    url = "https://api.github.com/repos/#{repoName}/commits"
    @_request url, cb
      
  _request: (url, cb) ->
    self = @
    
    return cb(null, cache.get(url)) if cache.get(url)?
    
    rest.get(url).on('complete', (data) ->
      cache.put url, data, self.cacheTime
      cb null, data
    ).on('error', (err) ->
      cb err
    )
      
root.github = new GitHub()