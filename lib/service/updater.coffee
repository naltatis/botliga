model = require "../model/model"
require '../vendor/scheduler'
maintenance = require "../controller/maintenance"
log = require('util').log

class Updater
  constructor: ->
    @scheduler = new Scheduler()
    @scheduler.init()
  start: ->
    @upcomingMatches()
  _task: (season, group) ->
    log "automatically importing #{season}/#{group} ..."
    maintenance.importGroup season, group, ->
      log "... finished"
  upcomingMatches: ->
    model.Match.find date: {$gt: new Date()}, (err, matches) =>
      dates = {}
      for match in matches
        dates[match.date.getTime()] = match.group
      for time, group of dates
        @_addTasks parseInt(time), group
      log "#{Object.keys(dates).length} scheduled updates for #{matches.length} upcoming matches created"
  _addTasks: (time, group) ->
    for i in [0..50]
      task = => @_task "2011", group
      offset = 5 * 60 * 1000 * i
      @scheduler.addJob time + offset, task
(exports ? this).Updater = Updater