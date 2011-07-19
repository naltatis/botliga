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
        if guess?
          row.c.push
            v: guess.points
            f: "#{guess.hostGoals}:#{guess.guestGoals} <strong>#{guess.points}</strong>"
        else
          row.c.push
            v: 0
            f: "-:- <strong>0</strong>"
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

$.widget 'stats.resultScatter'
  options:
    botName: ''
    
  _create: ->
    google.load 'visualization', '1',
      packages: ['corechart']
      callback: => @_load()
  _load: ->
    url = "/api/bot/#{@options.botName}/results/2010"
    $.get url, (data) =>
      model = @_model data
      @_render model
  _model: (data) ->
    d = new google.visualization.DataTable()
    d.addColumn 'number', 'Heim-Tore'
    d.addColumn 'number', 'Auswärts-Tore'
    for result, count of data
      [home, guest] = result.split ':'
      d.addRow [parseInt(home, 10), parseInt(guest, 10)]
    d
    
  _render: (model) ->
    chart = new google.visualization.ScatterChart @element.find('.chart')[0]
    chart.draw model,
      width: 300
      height: 300
      vAxis: 
        title: "Heim-Tore"
        minValue: 0
        maxValue: 8
      hAxis: 
        title: "Auswärts-Tore"
        minValue: 0
        maxValue: 8

$.widget 'bot.profile'
  options:
    botName: ''
    
  _create: ->
    $.get "/bot/profil/#{@options.botName}", (data) => @_show data
    
  _show: (data) ->
    @element.html data
    @_details()
    $("#botScatterChart").resultScatter botName: @options.botName
  
  _details: ->
    $.getJSON "https://api.github.com/repos/#{@options.botName}?callback=?", (res) =>
      @element.find('.description').text res.data.description
    
  _scatter: ->
    #$.get "/api/bot/#{@options.botName}/results/2010", (data) => @_show data
    

$.widget 'stats.pointsBySeasonTable',
  _create: ->
    google.load 'visualization', '1',
      packages: ['corechart', 'table']
      callback: => @_load()
  _load: ->
    url = "/api/points/2010"
    $.get url, (data) =>
      data = _(data).sortBy (i) -> i.bot
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
    for group in [1..34]
      result.push
        id: "group_#{group}"
        label: "<a href='##{group}/2010'>#{group}</a>"
        type: 'number'
    result.push
      id: "group_total"
      label: "gesamt"
      type: 'number'
    result
  _rows: (data) ->
    result = []
    for entry in data
      row = c: [v: "<a href='https://github.com/#{entry.bot}'>#{entry.bot}</a>"]
      for group in [1..34]
        row.c.push {v: entry.points[group] || 0}
      row.c.push {v: entry.points.total || 0}
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
      height: 480
      fontSize: 12
      pointSize: 2
      vAxis:
        viewWindowMode: "maximized"
      hAxis:
        maxAlternation: 2
        textStyle:
          fontSize: 11
      chartArea:
        left: 60
        top: 35
        width: "70%"
        height: 400
      legend: "right"
  _cols: (data) ->
    result = [{id:'group', label: 'Spieltag', type: 'string'}]
    botNames = (entry.bot for entry in data)
    for bot in botNames
      result.push
        id: "bot_#{bot}"
        label: "#{bot}"
        type: 'number'
    result
  _rows: (data) ->
    result = []
    botPoints = {}
    for group in [1..34]
      row = c: [{v: "#{group}."}]
      for entry in data
        botPoints[entry.bot] or= 0
        botPoints[entry.bot] += entry.points[group] || 0
        row.c.push {v: botPoints[entry.bot]}
      result.push row
    result