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
  _mapReduce 'matches', map, reduce, query: {season: season}, {}, cb

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
  console.log matches
  _mapReduce 'guesses', map, reduce, scope: {matches: matches}, {}, cb


botRatingByGroup = (season, cb) ->
  _matchesPerGroupBySeason season, (err, data) ->
    matches = {}
    for d in data
      for match in d.value.matches
        matches[match] = d._id
        
    _pointsPerBotAndGroup matches, (err, points) ->
      res = {}
      for bot in points
        res[bot._id] = bot.value
      cb err, res

popularResults = (cb) ->
  map = ->
    if this.hostGoals >= 0 && this.guestGoals >= 0 && this.hostGoals? && this.guestGoals?
      emit "#{this.hostGoals}:#{this.guestGoals}", {count: 1}

  reduce = (key, values) ->
    count = 0
    values.forEach (value) ->
      count += value.count
    {count: count}

  _mapReduce 'matches', map, reduce, {}, 'value.count': -1, cb

tendency = (cb) ->
  map = ->
    return unless this.hostGoals >= 0 && this.guestGoals >= 0 && this.hostGoals? && this.guestGoals?
    if this.hostGoals > this.guestGoals
      tendency = "home"
    else if this.hostGoals < this.guestGoals
      tendency = "guest"
    else
      tendency = "draw"
    emit tendency, {count: 1}

  reduce = (key, values) ->
    count = 0
    values.forEach (value) ->
      count += value.count
    {count: count}
    
  _mapReduce 'matches', map, reduce, {}, 'value.count': -1, cb
  

tendencyHistory = (cb) ->
  map = ->
    return unless this.hostGoals >= 0 && this.guestGoals >= 0 && this.hostGoals? && this.guestGoals?
    
    if this.hostGoals > this.guestGoals
      tendency = "home"
    else if this.hostGoals < this.guestGoals
      tendency = "guest"
    else
      tendency = "draw"
      
    emit this.season, tendency: tendency if this.season?

  reduce = (key, values) ->
    result =
      home: 0
      draw: 0
      guest: 0
                  
    values.forEach (value) ->
      result[value.tendency]++ if tendency in ["draw", "home", "guest"]
      
    result

  _mapReduce 'matches', map, reduce, {}, '_id': 1, cb

(exports ? this).popularResults = popularResults
(exports ? this).tendency = tendency
(exports ? this).tendencyHistory = tendencyHistory
(exports ? this).botRatingByGroup = botRatingByGroup