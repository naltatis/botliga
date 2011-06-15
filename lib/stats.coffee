model = require "./model"

_mapReduce = (map, reduce, sort, cb) ->
  model.db.collection 'matches', (err, matches) ->
    matches.mapReduce map, reduce, {}, (err, collection) ->
      collection.find().sort(sort).toArray (err, docs) ->
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

  _mapReduce map, reduce, 'value.count': -1, cb

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
    
  _mapReduce map, reduce, 'value.count': -1, cb
  

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

  _mapReduce map, reduce, '_id': 1, cb

(exports ? this).popularResults = popularResults
(exports ? this).tendency = tendency
(exports ? this).tendencyHistory = tendencyHistory