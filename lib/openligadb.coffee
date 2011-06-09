model = require "./model"
rest = require "restler"
_ = require "underscore"

apiHost = "http://openligadb-json.heroku.com/api/"

class MatchImporter
  constructor: ->
    
  importBySeasonAndGoup: (season, group) ->
    console.log "importing #{season}/#{group}"
    rest
      .get("#{apiHost}matchdata_by_group_league_saison?league_shortcut=bl1&group_order_id=#{group}&league_saison=#{season}")
      .on 'complete', (data) =>
         _(data.matchdata).each (result, i) =>
           match = @_createMatch result
           match.save if match.team1Goals? && match.team2Goals?
         console.log "imported #{season}/#{group}"
           
  importBySeason: (season) ->
    @_groupsBySeason season, (groups) =>
      _(groups).each (group, i) =>
        @importBySeasonAndGoup season, group
    
  _groupsBySeason: (season, cb) ->
    rest
      .get("#{apiHost}avail_groups?league_saison=#{season}&league_shortcut=bl1")
      .on 'complete', (data) =>
        cb(group.group_order_id for group in data.group)
             
  _createMatch: (result) ->
    match = new model.Match()
    match.id = result.match_id
    match.team1 = result.id_team1
    match.team2 = result.id_team2
    match.team1Name = result.name_team1
    match.team2Name = result.name_team2
    match.team1Goals = result.points_team1
    match.team2Goals = result.points_team2
    match.season = result.league_saison
    match.group = result.group_id
    match.date = result.match_date_time
    match
    
(exports ? this).MatchImporter = MatchImporter