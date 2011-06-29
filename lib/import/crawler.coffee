s = require "../service/service"
rest = require "restler"
Seq = require "seq"

class Crawler
  updateAll: (callback) ->
    Seq()
      .par ->
        s.bot.getAllWithPull @
      .par ->
        s.match.getBySeason 2011, @
      .seq (bots, matches) ->
        for bot in bots
          for match in matches
            console.log "#{bot.name} #{bot.url} #{match.id}"
        callback()
        
(exports ? this).crawler = new Crawler()