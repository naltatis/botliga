model = require "./model"

_mapReduce = (map, reduce, cb) ->
  model.db.collection 'matches', (err, matches) ->
    matches.mapReduce map, reduce, {}, (err, collection) ->
      collection.find().sort('value.count': -1).toArray (err, docs) ->
        cb docs

popularResults = (cb) ->
  map = ->
    if this.hostGoals >= 0 && this.guestGoals >= 0 && this.hostGoals? && this.guestGoals?
      emit "#{this.hostGoals}:#{this.guestGoals}", {count: 1}
  
  reduce = (key, values) ->
    count = 0
    values.forEach (value) ->
      count += value.count
    {count: count}

  _mapReduce map, reduce, cb

tendency = (cb) ->
  map = ->
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
    
  _mapReduce map, reduce, cb

(exports ? this).popularResults = popularResults
(exports ? this).tendency = tendency