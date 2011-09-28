(function() {
  var cache, getCached;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  $.widget('stats.guessesByGroup', {
    _create: function() {
      return google.load('visualization', '1', {
        packages: ['corechart', 'table'],
        callback: __bind(function() {
          this.element.find('.options select').change(function() {
            return window.location = $(this).val();
          });
          return this._load();
        }, this)
      });
    },
    _season: function() {
      return this.element.data('season');
    },
    _group: function() {
      return this.element.data('group');
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
    _cols: function(data) {
      var match, result, _i, _len, _ref;
      result = [
        {
          id: 'bots',
          label: '',
          type: 'string'
        }
      ];
      _ref = data.matches;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        match = _ref[_i];
        result.push({
          id: "match_" + match.id,
          label: "<div class='team team-" + match.hostId + "' title='" + match.hostName + "'></div><div class='team team-" + match.guestId + "' title='" + match.guestName + "'></div><br>" + match.hostGoals + ":" + match.guestGoals,
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
    _rows: function(data) {
      var bot, guess, match, result, row, _i, _j, _len, _len2, _ref, _ref2;
      result = [];
      _ref = this._bots(data.matches);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        bot = _ref[_i];
        row = {
          c: [
            {
              v: "<a href='https://github.com/" + bot + "'>" + bot + "</a>"
            }
          ]
        };
        _ref2 = data.matches;
        for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
          match = _ref2[_j];
          guess = _(match.guesses).detect(function(guess) {
            return bot === guess.bot;
          });
          if (guess != null) {
            row.c.push({
              v: guess.points || 0,
              f: "" + guess.hostGoals + ":" + guess.guestGoals + " <strong>" + (guess.points != null ? guess.points : '') + "</strong>"
            });
          } else {
            row.c.push({
              v: 0,
              f: ""
            });
          }
        }
        row.c.push({
          v: data.points[bot]
        });
        result.push(row);
      }
      return _(result).sortBy(function(r) {
        return r.c[r.c.length - 1].v * -1;
      });
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
  $.widget('stats.resultScatter', {
    options: {
      botName: ''
    },
    _create: function() {
      return google.load('visualization', '1', {
        packages: ['corechart'],
        callback: __bind(function() {
          return this._load();
        }, this)
      });
    },
    _season: function() {
      return this.element.data('season');
    },
    _load: function() {
      var url;
      url = "/api/bot/" + this.options.botName + "/results/" + (this._season());
      return $.get(url, __bind(function(data) {
        var model;
        model = this._model(data);
        return this._render(model);
      }, this));
    },
    _model: function(data) {
      var count, d, guest, home, result, _ref;
      d = new google.visualization.DataTable();
      d.addColumn('number', 'Heim-Tore');
      d.addColumn('number', 'Auswärts-Tore');
      for (result in data) {
        count = data[result];
        _ref = result.split(':'), home = _ref[0], guest = _ref[1];
        d.addRow([parseInt(home, 10), parseInt(guest, 10)]);
      }
      return d;
    },
    _render: function(model) {
      var chart;
      chart = new google.visualization.ScatterChart(this.element.find('.chart')[0]);
      return chart.draw(model, {
        width: 300,
        height: 300,
        vAxis: {
          title: "Heim-Tore",
          minValue: 0,
          maxValue: 8
        },
        hAxis: {
          title: "Auswärts-Tore",
          minValue: 0,
          maxValue: 8
        }
      });
    }
  });
  $.widget('bot.profile', {
    options: {
      botName: ''
    },
    _create: function() {
      return $.get("/bot/profil/" + this.options.botName, __bind(function(data) {
        return this._show(data);
      }, this));
    },
    _show: function(data) {
      this.element.html(data);
      this._details();
      return $("#botScatterChart").resultScatter({
        botName: this.options.botName
      });
    },
    _details: function() {
      return $.getJSON("https://api.github.com/repos/" + this.options.botName + "?callback=?", __bind(function(res) {
        return this.element.find('.description').text(res.data.description);
      }, this));
    },
    _scatter: function() {}
  });
  cache = {};
  getCached = function(url, cb) {
    if (cache[url] != null) {
      return cache[url].push(cb);
    } else {
      cache[url] = [cb];
      return $.get(url, function(data) {
        var callback, _i, _len, _ref;
        _ref = cache[url];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          callback = _ref[_i];
          callback(data);
        }
        return delete cache[url];
      });
    }
  };
  $.widget('stats.pointsBySeasonTable', {
    _create: function() {
      return google.load('visualization', '1', {
        packages: ['corechart', 'table'],
        callback: __bind(function() {
          return this._load();
        }, this)
      });
    },
    _season: function() {
      return this.element.data("season");
    },
    _load: function() {
      var url;
      url = "/api/points/" + (this._season());
      return getCached(url, __bind(function(data) {
        var result;
        data = _(data).sortBy(function(i) {
          return i.bot;
        });
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
    _cols: function(data) {
      var group, result;
      result = [
        {
          id: 'bots',
          label: '',
          type: 'string'
        }
      ];
      for (group = 1; group <= 34; group++) {
        result.push({
          id: "group_" + group,
          label: group,
          type: 'number'
        });
      }
      result.push({
        id: "group_total",
        label: "gesamt",
        type: 'number'
      });
      return result;
    },
    _rows: function(data) {
      var entry, group, result, row, _i, _len;
      result = [];
      for (_i = 0, _len = data.length; _i < _len; _i++) {
        entry = data[_i];
        row = {
          c: [
            {
              v: "<a href='https://github.com/" + entry.bot + "'>" + entry.bot + "</a>"
            }
          ]
        };
        for (group = 1; group <= 34; group++) {
          row.c.push({
            v: entry.points[group] || 0
          });
        }
        row.c.push({
          v: entry.points.total || 0
        });
        result.push(row);
      }
      return _(result).sortBy(function(r) {
        return r.c[r.c.length - 1].v * -1;
      });
    }
  });
  $.widget('stats.pointsBySeasonChart', {
    _create: function() {
      return google.load('visualization', '1', {
        packages: ['corechart', 'table'],
        callback: __bind(function() {
          return this._load();
        }, this)
      });
    },
    _season: function() {
      return this.element.data('season');
    },
    _load: function() {
      var url;
      url = "/api/points/" + (this._season());
      return getCached(url, __bind(function(data) {
        var result;
        result = {
          cols: this._cols(data),
          rows: this._rows(data)
        };
        return this._render(result);
      }, this));
    },
    _render: function(data) {
      var chart, dataTable;
      dataTable = new google.visualization.DataTable(data);
      chart = new google.visualization.LineChart(this.element.find('.chart')[0]);
      return chart.draw(dataTable, {
        width: "100%",
        height: 480,
        fontSize: 12,
        pointSize: 2,
        hAxis: {
          maxAlternation: 2,
          textStyle: {
            fontSize: 11
          }
        },
        chartArea: {
          left: 60,
          top: 35,
          width: "70%",
          height: 400
        },
        legend: "right"
      });
    },
    _cols: function(data) {
      var bot, botNames, entry, result, _i, _len;
      result = [
        {
          id: 'group',
          label: 'Spieltag',
          type: 'string'
        }
      ];
      botNames = (function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = data.length; _i < _len; _i++) {
          entry = data[_i];
          _results.push(entry.bot);
        }
        return _results;
      })();
      for (_i = 0, _len = botNames.length; _i < _len; _i++) {
        bot = botNames[_i];
        result.push({
          id: "bot_" + bot,
          label: "" + bot,
          type: 'number'
        });
      }
      return result;
    },
    _rows: function(data) {
      var botPoints, entry, group, result, row, _i, _len, _name;
      result = [];
      botPoints = {};
      for (group = 1; group <= 8; group++) {
        row = {
          c: [
            {
              v: "" + group + "."
            }
          ]
        };
        for (_i = 0, _len = data.length; _i < _len; _i++) {
          entry = data[_i];
          botPoints[_name = entry.bot] || (botPoints[_name] = 0);
          botPoints[entry.bot] += entry.points[group] || 0;
          row.c.push({
            v: botPoints[entry.bot],
            f: "+" + (entry.points[group] || 0) + " (" + botPoints[entry.bot] + ")"
          });
        }
        result.push(row);
      }
      return result;
    }
  });
}).call(this);
