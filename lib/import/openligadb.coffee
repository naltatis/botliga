model = require "../model/model"
rest = require "restler"
_ = require "underscore"
Seq = require "seq"

apiHost = "http://openligadb-json.heroku.com/api/"

class MatchImporter
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
        
    Seq()
      .seq ->
        rest.get(url, options).on 'complete', (data) =>
          console.log "---->", season, group
          @ null, data.matchdata
      .flatten()
      .parMap (result) ->
        if result?
          data = self._match result
          console.log "importing\t#{data.hostName}\t\t#{data.guestName}"
          model.Match.update {id: data.id}, data, {upsert: true}, (err) =>
            console.log err if err
            @ err
        else
          @ null
      .seq cb

  importBySeason: (season, cb = ->) ->
    self = @
    Seq()
      .seq ->
        self._groupsBySeason season, @
      .flatten()
      .parMap (group) ->
        self.importBySeasonAndGroup season, group, @
      .seq cb
    
  _groupsBySeason: (season, cb) ->
    rest
      .get("#{apiHost}avail_groups?league_saison=#{season}&league_shortcut=bl1")
      .on 'complete', (data) =>
        res = (group.group_order_id for group in data.group)
        cb null, res
             
  _match: (result) ->
    result.points_team1 = parseInt(result.points_team1, 10)
    result.points_team2 = parseInt(result.points_team2, 10)
    {
      id: result.match_id
      hostId: result.id_team1
      guestId: result.id_team2
      hostName: result.name_team1
      guestName: result.name_team2
      hostGoals: result.points_team1 if result.points_team1 >= 0
      guestGoals: result.points_team2 if  result.points_team2 >= 0
      season: result.league_saison
      group: result.group_order_id
      date: new Date(result.match_date_time_utc)
    }

(exports ? this).MatchImporter = MatchImporter