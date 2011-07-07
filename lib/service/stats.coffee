model = require "../model/model"

_mapReduce = (collection, map, reduce, opt, sort, cb) ->
  model.db.collection collection, (err, matches) ->
    matches.mapReduce map, reduce, opt, (err, collection) ->
      collection.find().sort(sort).toArray (err, docs) ->
        cb err, docs

_matchesPerGroupBySeason = (season, cb) ->
  map = ->
    emit this.group, {match: this._id}
  reduce = (key, values) ->
    matches = (val.match for val in values)
    {matches: matches}
  _mapReduce 'matches', map, reduce, {query: {season: season}, out: 'matchesPerGroupBySeason'}, {}, cb

_pointsPerBotAndGroup = (matches, cb) ->
  map = ->
    if matches[this.match]?
      emit this.bot, {group: matches[this.match], points: this.points}
  reduce = (key, values) ->
    res = {}
    for value in values
      res[value.group] or= 0
      res[value.group] = res[value.group] + parseInt(value.points, 10)
    res
  _mapReduce 'guesses', map, reduce, {scope: {matches: matches}, out: 'pointsPerBotAndGroup'}, {}, cb


botPointsBySeason = (season, cb) ->
  model.Bot.find().find (err, bots) ->
    botMap = {}
    for bot in bots
      botMap[bot._id] = bot.name if bot.name?
      
    _matchesPerGroupBySeason season, (err, data) ->
      matches = {}
      for d in data
        for match in d.value.matches
          matches[match] = d._id
        
      _pointsPerBotAndGroup matches, (err, points) ->
        res = {}
        for bot in points
          botName = botMap[bot._id]
          if botName?
            res[botName] = bot.value 
            total = 0
            for g, p of bot.value
              total += p 
            res[botName].total = total
        cb err, res

popularResults = (season, cb) ->
  map = ->
    if this.hostGoals? && this.guestGoals?
      emit "#{this.hostGoals}:#{this.guestGoals}", count: 1

  reduce = (key, values) ->
    {count: values.length}

  _mapReduce 'matches', map, reduce, {query: {season: season}, out: 'popularResults'}, ['_id'], (err, data) ->
    data = ({result: entry._id, count: entry.value.count} for entry in data)
    cb err, data

tendency = (season, cb) ->
  map = ->
    return unless this.hostGoals? && this.guestGoals?
    
    if this.hostGoals > this.guestGoals
      tendency = "home"
    else if this.hostGoals < this.guestGoals
      tendency = "guest"
    else
      tendency = "draw"
      
    emit tendency, count: 1

  reduce = (key, values) ->
    {count: values.length}

  _mapReduce 'matches', map, reduce, {query: {season: season}, out: 'tendency'}, [], (err, data) ->
    data = ({tendency: entry._id, count: entry.value.count} for entry in data)
    cb err, data

(exports ? this).popularResults = popularResults
(exports ? this).tendency = tendency
(exports ? this).botPointsBySeason = botPointsBySeason