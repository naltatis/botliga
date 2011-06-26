$ ->
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
  console.log axisy
  
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