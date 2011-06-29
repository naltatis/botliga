model = require "../model/model"
rest = require "restler"
_ = require "underscore"

apiHost = "http://openligadb-json.heroku.com/api/"

class MatchImporter
  constructor: ->
    
  importBySeasonAndGoup: (season, group) ->
    console.log "importing #{season}/#{group}"
    url = "#{apiHost}matchdata_by_group_league_saison"
    options =
      query:
        league_shortcut: 'bl1'
        group_order_id: group
        league_saison: season
    rest.get(url, options).on 'complete', (data) =>
      console.log "--------------->", season, group
      _(data.matchdata).each (result, i) =>
        if result?
          data = @_match result
          console.log data
          model.Match.update {id: data.id}, data, {upsert: true}, (err) ->
            console.log "imported #{season}/#{group}", err

  importBySeason: (season) ->
    @_groupsBySeason season, (groups) =>
      _(groups).each (group, i) =>
        @importBySeasonAndGoup season, group
    
  _groupsBySeason: (season, cb) ->
    rest
      .get("#{apiHost}avail_groups?league_saison=#{season}&league_shortcut=bl1")
      .on 'complete', (data) =>
        cb(group.group_order_id for group in data.group)
             
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
      date: result.match_date_time
    }

(exports ? this).MatchImporter = MatchImporter