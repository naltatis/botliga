(function() {
  $(function() {
    return $.getJSON("https://github.com/api/v2/json/repos/show/naltatis?callback=?", function(data) {
      var repo, _i, _len, _ref, _results;
      _ref = data.repositories;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        repo = _ref[_i];
        _results.push($('#botRepository').append("<option>" + repo.name + "</option>"));
      }
      return _results;
    });
  });
}).call(this);
