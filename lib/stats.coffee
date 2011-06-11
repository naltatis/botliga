model = require "./model"

_mapReduce = (map, reduce, cb) ->
  model.db.collection 'matches', (err, matches) ->
    matches.mapReduce map, reduce, {}, (err, collection) ->
      collection.find().sort('value.count': -1).toArray (err, docs) ->
        cb docs

popularResults = (cb) ->
  map = ->
    if this.team1Goals >= 0 && this.team2Goals >= 0 && this.team1Goals? && this.team2Goals?
      emit "#{this.team1Goals}:#{this.team2Goals}", {count: 1}
  
  reduce = (key, values) ->
    count = 0
    values.forEach (value) ->
      count += value.count
    {count: count}

  _mapReduce map, reduce, cb

tendency = (cb) ->
  map = ->
    if this.team1Goals > this.team2Goals
      tendency = "home"
    else if this.team1Goals < this.team2Goals
      tendency = "guest"
    else
      tendency = "draw"
    emit tendency, {count: 1}

  reduce = (key, values) ->
    count = 0
    values.forEach (value) ->
      count += value.count
    {count: count}
    
  _mapReduce map, reduce, cb

(exports ? this).popularResults = popularResults
(exports ? this).tendency = tendency