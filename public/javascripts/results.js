(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  $.widget('stats.guessesByGroup', {
    _create: function() {
      return google.load('visualization', '1', {
        packages: ['corechart', 'table'],
        callback: __bind(function() {
          this.element.find('.options select').change(__bind(function() {
            return location.hash = "" + (this._group()) + "/" + (this._season());
          }, this));
          $(window).hashchange(__bind(function() {
            return this._hashchange();
          }, this));
          return this._hashchange();
        }, this)
      });
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
    _rows: function(data) {
      var bot, guess, match, result, row, _i, _j, _len, _len2, _ref, _ref2;
      result = [];
      _ref = this._bots(data.matches).sort();
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
              v: guess.points,
              f: "" + guess.hostGoals + ":" + guess.guestGoals + " <strong>" + guess.points + "</strong>"
            });
          } else {
            row.c.push({
              v: 0,
              f: "-:- <strong>0</strong>"
            });
          }
        }
        row.c.push({
          v: data.points[bot]
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
  $.widget('stats.pointsBySeasonTable', {
    _create: function() {
      return google.load('visualization', '1', {
        packages: ['corechart', 'table'],
        callback: __bind(function() {
          return this._load();
        }, this)
      });
    },
    _load: function() {
      var url;
      url = "/api/points/2010";
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
          label: "<a href='#" + group + "/2010'>" + group + "</a>",
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
      var bot, botNames, group, points, result, row, _i, _len, _ref;
      result = [];
      botNames = (function() {
        var _results;
        _results = [];
        for (bot in data) {
          points = data[bot];
          _results.push(bot);
        }
        return _results;
      })();
      _ref = botNames.sort();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        bot = _ref[_i];
        row = {
          c: [
            {
              v: "<a href='https://github.com/" + bot + "'>" + bot + "</a>"
            }
          ]
        };
        for (group = 1; group <= 34; group++) {
          row.c.push({
            v: data[bot][group] || 0
          });
        }
        row.c.push({
          v: data[bot].total || 0
        });
        result.push(row);
      }
      return result;
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
    _load: function() {
      var url;
      url = "/api/points/2010";
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
      var chart, dataTable;
      dataTable = new google.visualization.DataTable(data);
      chart = new google.visualization.LineChart(this.element.find('.chart')[0]);
      return chart.draw(dataTable, {
        width: "100%",
        height: 450,
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
          width: "90%",
          height: 300
        },
        legend: "bottom"
      });
    },
    _cols: function(data) {
      var bot, botNames, points, result, _i, _len, _ref;
      result = [
        {
          id: 'group',
          label: 'Spieltag',
          type: 'string'
        }
      ];
      botNames = (function() {
        var _results;
        _results = [];
        for (bot in data) {
          points = data[bot];
          _results.push(bot);
        }
        return _results;
      })();
      _ref = botNames.sort();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        bot = _ref[_i];
        result.push({
          id: "bot_" + bot,
          label: "" + bot,
          type: 'number'
        });
      }
      return result;
    },
    _rows: function(data) {
      var bot, botNames, botPoints, group, points, result, row, _i, _len, _ref;
      result = [];
      botNames = (function() {
        var _results;
        _results = [];
        for (bot in data) {
          points = data[bot];
          _results.push(bot);
        }
        return _results;
      })();
      botPoints = {};
      _ref = data[botNames[0]];
      for (group in _ref) {
        points = _ref[group];
        if (group !== "total") {
          row = {
            c: [
              {
                v: "" + group + "."
              }
            ]
          };
          for (_i = 0, _len = botNames.length; _i < _len; _i++) {
            bot = botNames[_i];
            botPoints[bot] || (botPoints[bot] = 0);
            botPoints[bot] += data[bot][group];
            row.c.push({
              v: botPoints[bot]
            });
          }
        }
        result.push(row);
      }
      return result;
    }
  });
}).call(this);
