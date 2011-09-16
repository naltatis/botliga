model = require "../model/model"
require '../vendor/scheduler'
maintenance = require "../controller/maintenance"

class Updater
  constructor: ->
    @scheduler = new Scheduler()
    @scheduler.init()
  start: ->
    @upcomingMatches()
  _task: (season, group) ->
    maintenance.importGroup season, group, ->
      console.log "imported #{season}/#{group}"
  upcomingMatches: ->
    model.Match.find date: {$gt: new Date()}, (err, matches) =>
      dates = {}
      for match in matches
        dates[match.date.getTime()] = match.group
      for time, group of dates
        @_addTasks parseInt(time), group
  _addTasks: (time, group) ->
    for i in [0..20]
      task = => @_task "2011", group
      offset = 10 * 60 * 1000 * i
      @scheduler.addJob time + offset, task
(exports ? this).Updater = Updater