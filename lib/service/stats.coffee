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
    
    model.Match.find {season: season}, (err, matches) ->
      matchIds = (match._id for match in matches)
      matchToGroup = {}
      for match in matches
        matchToGroup[match._id] = match.group

      model.Guess.find({match: {$in: matchIds}}).find (err, guesses) ->
        res = {}
        for guess in guesses
          botName = botMap[guess.bot]
          group = matchToGroup[guess.match]
          if botName? && group?
            res[botName] or= {total: 0}
            res[botName][group] or= 0
            res[botName][group] += guess.points || 0
            res[botName].total += guess.points
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