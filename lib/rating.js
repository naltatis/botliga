(function() {
  var Rating;
  Rating = (function() {
    function Rating() {}
    Rating.prototype.score = function(estimated, real) {
      return 2;
    };
    return Rating;
  })();
  (typeof exports !== "undefined" && exports !== null ? exports : this).Rating = Rating;
}).call(this);
