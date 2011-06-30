s = require "../service/service"
rest = require "restler"
Seq = require "seq"
Narrow = require "narrow"

class Crawler
  updateAll: (callback) ->
    self = @
    Seq()
      .seq ->
        s.bot.getAllWithPull @
      .flatten()
      .parEach (bot) ->
        console.log ">> starting bot #{bot.name}"
        self.update bot, @
      .seq ->
        console.log "all done"
        callback()

  update: (bot, callback) ->
    Seq()
      .seq ->
        s.match.getBySeason 2011, @
      .flatten()
      .seqEach (match) ->
        setTimeout( =>
          console.log "-- #{bot.name} - #{match.id}"
          @()
        , 10)
      .seq ->
        console.log "<< #{bot.name} finished"
        callback()

(exports ? this).crawler = new Crawler()