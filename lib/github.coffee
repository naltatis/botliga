rest = require "restler"
_ = require "underscore"

apiHost = "https://github.com/api/v2/json/"

repositories = (username, callback) ->
  console.log "#{apiHost}repos/show/#{username}"
  rest.get("#{apiHost}repos/show/#{username}").on 'complete', (data) ->
    callback null, data.repositories.reverse()
    
(exports ? this).repositories = repositories