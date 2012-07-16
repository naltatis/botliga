model = require "../model/model"
rest = require "restler"
_ = require "underscore"
Seq = require "seq"
{EventEmitter} = require "events"

apiHost = "http://openligadb-json.heroku.com/api/"

class MatchImporter extends EventEmitter
  constructor: ->
    
  importBySeasonAndGroup: (season, group, cb = ->) ->
    self = @
    console.log "importing #{season}/#{group}"
    url = "#{apiHost}matchdata_by_group_league_saison"
    options =
      query:
        league_shortcut: 'bl1'
        group_order_id: group
        league_saison: season
    console.log url, options
        
    Seq()
      .seq ->
        rest
          .get(url, options)
          .on 'success', (data) =>
            console.log "---->", season, group
            @ null, data.matchdata
          .on 'error', (error) =>
            @ error
      .flatten()
      .parMap (result) ->
        if result?
          data = self._match result
          console.log "importing\t#{data.hostName}\t\t#{data.guestName}"
          model.Match.update {id: data.id}, data, {upsert: true}, (err) =>
            console.log err if err
            model.Match.findOne {id: data.id}, (err, match) =>
              self.emit "match", match
              @ err
        else
          @ null
      .seq(cb)
      .catch (err) ->
        console.log "error while importing #{season}/#{group}: #{err}"
        cb err

  importBySeason: (season, cb = ->) ->
    self = @
    Seq()
      .seq ->
        self._groupsBySeason season, @
      .flatten()
      .parMap (group) ->
        self.importBySeasonAndGroup season, group, @
      .seq(cb)
      .catch (err) ->
        console.log err
        cb err
    
  _groupsBySeason: (season, cb) ->
    rest
      .get("#{apiHost}avail_groups?league_saison=#{season}&league_shortcut=bl1")
      .on 'success', (data) =>
        res = (group.group_order_id for group in data.group)
        cb null, res
      .on 'error', (err) =>
        cb err
             
  _match: (result) ->
    result.points_team1 = parseInt(result.points_team1, 10)
    result.points_team2 = parseInt(result.points_team2, 10)
    {
      id: result.match_id
      hostId: result.id_team1
      guestId: result.id_team2
      hostName: result.name_team1
      guestName: result.name_team2
      hostGoals: if result.points_team1 >= 0 then result.points_team1 else null
      guestGoals: if result.points_team2 >= 0 then result.points_team2 else null
      season: result.league_saison
      group: result.group_order_id
      date: new Date(result.match_date_time_utc)
    }

(exports ? this).MatchImporter = MatchImporter