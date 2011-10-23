#= require lib/jquery
#= require lib/jquery.ui.widget
#= require lib/underscore
#= require results
#= require settings

$ ->
  $('#guessesByGroup').guessesByGroup()
  $('#pointsBySeasonChart').pointsBySeasonChart()
  $('#scatterChart').scatterChart()
  
  $('#results a.seasonChart').click (e) ->
    e.preventDefault()
    $(@).parent().siblings().find('a').removeClass('current')
    $(@).addClass('current')
    $('#pointsBySeasonChart').show()
    $('#pointsBySeasonTable').hide()  
  $('#results a.seasonTable').click (e) ->
    e.preventDefault()
    $(@).parent().siblings().find('a').removeClass('current')
    $(@).addClass('current')
    $('#pointsBySeasonTable').pointsBySeasonTable().show()
    $('#pointsBySeasonChart').hide()
    
  $(window).scroll (e) ->
    top = $(@).scrollTop() / 30
    $("body").css 'backgroundPosition', "center -#{top}px"