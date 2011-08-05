model = require "../model/model"
require '../vendor/scheduler'

class Updater
  constructor: ->
    @scheduler = new Scheduler()
    @scheduler.init()
  start: ->
    @upcomingMatches()
  _task: (season, group) ->
    console.log "#{group}/#{season}"
  upcomingMatches: ->
    model.Match.find date: {$gt: new Date()}, (err, matches) =>
      dates = {}
      for match in matches
        dates[match.date.getTime()] = match.group
      for time, group of dates
        @_addTasks parseInt(time), group
  _addTasks: (time, group) ->
    for i in [0..4]
      task = => @_task "2011", group
      offset = 30 * 60 * 1000 * i
      @scheduler.addJob time + offset, task
(exports ? this).Updater = Updater