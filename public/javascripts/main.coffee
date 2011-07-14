head ->
  $('#guessesByGroup').guessesByGroup()
  $('#pointsBySeasonTable').pointsBySeasonTable()
  $('#pointsBySeasonChart').pointsBySeasonChart()
  $('#guessesByGroup .google-visualization-table-table tbody tr td:first-child:not(.google-visualization-table-sorthdr)').live 'click', (e) ->
    e.preventDefault()
    botName = $(@).text()
    $layer = $('<div />').attr('id', 'botProfileLayer')
    $('#botProfileLayer').remove()
    $('#overall').append $layer
    $layer.profile
      botName: botName