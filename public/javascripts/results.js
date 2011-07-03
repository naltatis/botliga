(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  $.widget('stats.guessesByGroup', {
    _create: function() {
      google.load('visualization', '1', {
        packages: ['corechart', 'table'],
        callback: __bind(function() {
          return this._load();
        }, this)
      });
      this.element.find('.options select').change(__bind(function() {
        return location.hash = "" + (this._group()) + "/" + (this._season());
      }, this));
      $(window).hashchange(__bind(function() {
        return this._hashchange();
      }, this));
      return this._hashchange();
    },
    _hashchange: function() {
      var group, season, _ref;
      _ref = location.hash.replace('#', '').split('/'), group = _ref[0], season = _ref[1];
      this.season(season);
      this.group(group);
      return this._load();
    },
    _season: function() {
      return this.element.find('select.season').val();
    },
    _group: function() {
      return this.element.find('select.group').val();
    },
    season: function(val) {
      return this.element.find('select.season').val(val);
    },
    group: function(val) {
      return this.element.find('select.group').val(val);
    },
    _load: function() {
      var url;
      url = "/api/guesses/" + (this._season()) + "/" + (this._group());
      return $.get(url, __bind(function(data) {
        var result;
        result = {
          cols: this._cols(data),
          rows: this._rows(data)
        };
        return this._render(result);
      }, this));
    },
    _render: function(data) {
      var dataTable, formatter, table;
      dataTable = new google.visualization.DataTable(data);
      table = new google.visualization.Table(this.element.find('.table')[0]);
      formatter = new google.visualization.TableBarFormat({
        width: 30
      });
      formatter.format(dataTable, data.cols.length - 1);
      return table.draw(dataTable, {
        allowHtml: true
      });
    },
    _cols: function(matches) {
      var match, result, _i, _len;
      result = [
        {
          id: 'bots',
          label: '',
          type: 'string'
        }
      ];
      for (_i = 0, _len = matches.length; _i < _len; _i++) {
        match = matches[_i];
        result.push({
          id: "match_" + match.id,
          label: "<img src='/images/teams/" + match.hostId + ".gif' title='" + match.hostName + "'><img src='/images/teams/" + match.guestId + ".gif' title='" + match.guestName + "'><br>" + match.hostGoals + ":" + match.guestGoals,
          type: 'number'
        });
      }
      result.push({
        id: 'total',
        label: 'gesamt',
        type: 'number'
      });
      return result;
    },
    _rows: function(matches) {
      var bot, guess, match, result, row, total, _i, _j, _len, _len2, _ref;
      result = [];
      _ref = this._bots(matches);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        bot = _ref[_i];
        row = {
          c: [
            {
              v: bot
            }
          ]
        };
        total = 0;
        for (_j = 0, _len2 = matches.length; _j < _len2; _j++) {
          match = matches[_j];
          guess = _(match.guesses).detect(function(guess) {
            return bot === guess.bot;
          });
          row.c.push({
            v: guess.points,
            f: "" + guess.hostGoals + ":" + guess.guestGoals + " <strong>" + guess.points + "</strong>"
          });
          total += guess.points;
        }
        row.c.push({
          v: total
        });
        result.push(row);
      }
      return result;
    },
    _bots: function(matches) {
      var guess, match, result, _i, _j, _len, _len2, _ref;
      result = [];
      for (_i = 0, _len = matches.length; _i < _len; _i++) {
        match = matches[_i];
        _ref = match.guesses;
        for (_j = 0, _len2 = _ref.length; _j < _len2; _j++) {
          guess = _ref[_j];
          if ((guess.bot != null) && !_(result).contains(guess.bot)) {
            result.push(guess.bot);
          }
        }
      }
      return result;
    }
  });
  /*
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
    */
}).call(this);
