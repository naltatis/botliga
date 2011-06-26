(function() {
  $(function() {
    var $table, axisx, axisy, col, cols, data, options, r, row, rows, xs, ys, _i, _ref, _results;
    $table = $("#botsByGroups");
    if ($table.length === 0) {
      return;
    }
    r = Raphael("botsByGroupsChart");
    cols = $table.find("thead th").length;
    rows = $table.find("tr:gt(0)").length;
    xs = [];
    for (row = 0; 0 <= rows ? row < rows : row > rows; 0 <= rows ? row++ : row--) {
      for (col = 0; 0 <= cols ? col < cols : col > cols; 0 <= cols ? col++ : col--) {
        xs.push(col);
      }
    }
    ys = [];
    for (row = _ref = rows - 1; _ref <= 0 ? row <= 0 : row >= 0; _ref <= 0 ? row++ : row--) {
      for (col = 0; 0 <= cols ? col < cols : col > cols; 0 <= cols ? col++ : col--) {
        ys.push(row);
      }
    }
    data = [];
    $table.find(".points").each(function() {
      return data.push(parseInt($(this).text(), 10) || 0);
    });
    axisx = (function() {
      _results = [];
      for (var _i = 1; 1 <= cols ? _i <= cols : _i >= cols; 1 <= cols ? _i++ : _i--){ _results.push(_i); }
      return _results;
    }).apply(this, arguments);
    axisy = [];
    $table.find("tr:gt(0) th").each(function() {
      return axisy.push($(this).text());
    });
    console.log(axisy);
    options = {
      symbol: "o",
      heat: true,
      axis: "0 0 1 1",
      axisxstep: cols,
      axisystep: rows - 1,
      axisxlabels: axisx,
      axisxtype: " ",
      axisytype: " ",
      max: Math.max.apply(Math, data) - 10,
      axisylabels: axisy
    };
    return r.g.dotchart(10, 10, 950, 400, xs, ys, data, options).hover(function() {
      this.tag = this.tag || r.g.tag(this.x, this.y, this.value, 0, this.r + 2).insertBefore(this);
      return this.tag.show();
    }, function() {
      return this.tag && this.tag.hide();
    });
  });
}).call(this);
