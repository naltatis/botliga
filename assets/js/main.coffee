#= require lib/jquery
#= require lib/jquery.ui.widget
#= require lib/underscore
#= require results
#= require settings

$ ->
  $('#guessesByGroup').guessesByGroup()
  $('#pointsBySeasonTable').pointsBySeasonTable()
  $('#pointsBySeasonChart').pointsBySeasonChart()
