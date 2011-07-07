$.widget 'stats.guessesByGroup',
  _create: ->
    google.load 'visualization', '1',
      packages: ['corechart', 'table']
      callback: =>
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
  _cols: (data) ->
    result = [{id:'bots', label: '', type: 'string'}]
    for match in data.matches
      result.push
        id: "match_#{match.id}"
        label: "<img src='/images/teams/#{match.hostId}.gif' title='#{match.hostName}'><img src='/images/teams/#{match.guestId}.gif' title='#{match.guestName}'><br>#{match.hostGoals}:#{match.guestGoals}"
        type: 'number'
    result.push
      id: 'total'
      label: 'gesamt'
      type: 'number'
    result
  _rows: (data) ->
    result = []
    for bot in @_bots(data.matches).sort()
      row = 
        c: [v: "<a href='https://github.com/#{bot}'>#{bot}</a>"]
      for match in data.matches
        guess = _(match.guesses).detect (guess) -> bot == guess.bot
        row.c.push
          v: guess.points
          f: "#{guess.hostGoals}:#{guess.guestGoals} <strong>#{guess.points}</strong>"
      row.c.push
        v: data.points[bot]
      result.push row
    result
  _bots: (matches) ->
    result = []
    for match in matches
      for guess in match.guesses
        result.push guess.bot if guess.bot? && !_(result).contains guess.bot
    result


$.widget 'stats.pointsBySeasonTable',
  _create: ->
    google.load 'visualization', '1',
      packages: ['corechart', 'table']
      callback: => @_load()
  _load: ->
    url = "/api/points/2010"
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
  _cols: (data) ->
    result = [{id:'bots', label: '', type: 'string'}]
    bots = (bot for bot, points of data)
    for group, points of data[bots[0]]
      result.push
        id: "group_#{group}"
        label: "<a href='##{group}/2010'>#{group}</a>"
        type: 'number'
    result
  _rows: (data) ->
    result = []
    botNames = (bot for bot, points of data)
    for bot in botNames.sort()
      row = c: [v: "<a href='https://github.com/#{bot}'>#{bot}</a>"]
      for group, point of data[bot]
        row.c.push {v: point}
      result.push row
    result
    
$.widget 'stats.pointsBySeasonChart',
  _create: ->
    google.load 'visualization', '1',
      packages: ['corechart', 'table']
      callback: => @_load()
  _load: ->
    url = "/api/points/2010"
    $.get url, (data) =>
      result =
        cols: @_cols(data)
        rows: @_rows(data)
      @_render result
  _render: (data) ->
    dataTable = new google.visualization.DataTable data
    chart = new google.visualization.LineChart @element.find('.chart')[0]
    chart.draw dataTable,
      width: "100%"
      height: 450
      fontSize: 12
      pointSize: 2
      hAxis:
        maxAlternation: 2
        textStyle:
          fontSize: 11
      chartArea:
        left: 60
        top: 35
        width: "90%"
        height: 300
      legend: "bottom"
  _cols: (data) ->
    result = [{id:'group', label: 'Spieltag', type: 'string'}]
    botNames = (bot for bot, points of data)
    for bot in botNames.sort()
      result.push
        id: "bot_#{bot}"
        label: "#{bot}"
        type: 'number'
    result
  _rows: (data) ->
    result = []
    botNames = (bot for bot, points of data)
    botPoints = {}
    for group, points of data[botNames[0]]
      unless group == "total"
        row = c: [{v: "#{group}."}]
        for bot in botNames
          botPoints[bot] or= 0
          botPoints[bot] += data[bot][group]
          row.c.push {v: botPoints[bot]}
      result.push row
    result