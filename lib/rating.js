(function() {
  var GroupScorer, MatchScorer;
  MatchScorer = (function() {
    function MatchScorer() {}
    MatchScorer.prototype.score = function(estimated, real) {
      var points;
      estimated = this._analyse(estimated);
      real = this._analyse(real);
      if (estimated[0] === real[0] && estimated[1] === real[1]) {
        points = 4;
      } else if (estimated.draw && real.draw) {
        points = 2;
      } else if (estimated.diff === real.diff) {
        points = 3;
      } else if (estimated.home && real.home) {
        points = 2;
      } else if (estimated.away && real.away) {
        points = 2;
      } else {
        points = 0;
      }
      return points;
    };
    MatchScorer.prototype._analyse = function(result) {
      return {
        0: result[0],
        1: result[1],
        diff: result[0] - result[1],
        draw: result[0] === result[1],
        home: result[0] > result[1],
        away: result[0] < result[1]
      };
    };
    return MatchScorer;
  })();
  GroupScorer = (function() {
    function GroupScorer(scorer) {
      this.scorer = scorer;
    }
    GroupScorer.prototype.score = function(estimated, real) {
      var matchId, points, result;
      points = 0;
      for (matchId in estimated) {
        result = estimated[matchId];
        points += this.scorer.score(result, real[matchId]);
      }
      return points;
    };
    return GroupScorer;
  })();
  (typeof exports !== "undefined" && exports !== null ? exports : this).MatchScorer = MatchScorer;
  (typeof exports !== "undefined" && exports !== null ? exports : this).GroupScorer = GroupScorer;
}).call(this);
