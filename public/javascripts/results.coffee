$.widget 'stats.guessesByGroup',
  _create: ->
    google.load 'visualization', '1',
      packages: ['corechart', 'table']
      callback: => @_load()
    @element.find('.options select').change =>
      location.hash = "#{@_group()}/#{@_season()}"
    $(window).hashchange => @_hashchange()
    @_hashchange()
  _hashchange: ->
    [group, season] = location.hash.replace('#','').split '/'
    @season season
    @group group
    @_load()
  _season: ->
    @element.find('select.season').val()
  _group: ->
    @element.find('select.group').val()
  season: (val) ->
    @element.find('select.season').val(val)
  group: (val) ->
    @element.find('select.group').val(val)
  _load: ->
    url = "/api/guesses/#{@_season()}/#{@_group()}"
    $.get url, (data) =>
      result =
        cols: @_cols(data)
        rows: @_rows(data)
      @_render result
  _render: (data) ->
    dataTable = new google.visualization.DataTable data
    table = new google.visualization.Table @element.find('.table')[0]
    formatter = new google.visualization.TableBarFormat width: 30
    formatter.format dataTable, data.cols.length-1
    table.draw dataTable, {allowHtml: true}
  _cols: (matches) ->
    result = [{id:'bots', label: '', type: 'string'}]
    for match in matches
      result.push
        id: "match_#{match.id}"
        label: "<img src='/images/teams/#{match.hostId}.gif' title='#{match.hostName}'><img src='/images/teams/#{match.guestId}.gif' title='#{match.guestName}'><br>#{match.hostGoals}:#{match.guestGoals}"
        type: 'number'
    result.push
      id:'total'
      label: 'gesamt'
      type: 'number'
    result
  _rows: (matches) ->
    result = []
    for bot in @_bots(matches)
      row = 
        c: [v: bot]
      total = 0
      for match in matches
        guess = _(match.guesses).detect (guess) -> bot == guess.bot
        row.c.push
          v: guess.points
          f: "#{guess.hostGoals}:#{guess.guestGoals} <strong>#{guess.points}</strong>"
        total += guess.points
      row.c.push
        v: total
      result.push row
    result
  _bots: (matches) ->
    result = []
    for match in matches
      for guess in match.guesses
        result.push guess.bot if guess.bot? && !_(result).contains guess.bot
    result
###
$ ->
  $('#guessesByGroup').each ->
    $el = $(@)
    $.get $el.data('url'), (matches) ->

  $table = $("#botsByGroups")
  return if $table.length == 0
  
  r = Raphael "botsByGroupsChart"

  cols = $table.find("thead th").length
  rows = $table.find("tr:gt(0)").length
  
  xs = []
  for row in [0...rows]
    for col in [0...cols]
      xs.push col

  ys = []
  for row in [rows-1..0]
    for col in [0...cols]
      ys.push row

  data = []
  $table.find(".points").each ->
    data.push parseInt($(@).text(), 10) || 0

  axisx = [1..cols]
  axisy = []
  $table.find("tr:gt(0) th").each ->
    axisy.push $(@).text()
  
  options =
    symbol: "o"
    heat: true
    axis: "0 0 1 1"
    axisxstep: cols
    axisystep: rows-1
    axisxlabels: axisx
    axisxtype: " "
    axisytype: " "
    max: Math.max.apply(Math, data) - 10
    axisylabels: axisy
  r.g.dotchart(10, 10, 950, 400, xs, ys, data, options).hover ->
    @tag = @tag || r.g.tag(@x, @y, @value, 0, this.r + 2).insertBefore(@)
    @tag.show()
  , ->
    @tag && @tag.hide()
  ###