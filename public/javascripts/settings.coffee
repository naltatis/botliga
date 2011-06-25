$ ->
  login = $('body').data('login')
  $.getJSON "https://github.com/api/v2/json/repos/show/#{login}?callback=?", (data) ->
    for repo in data.repositories
      $option = $("<option>").text(repo.name).attr('value', repo.name).data('repository', repo.url)
      $('#botList select').append $option
    $('#botList select').val ->
      $(@).closest('.bot').data('name')

  $('#botList .noApi input').live 'change', ->
    $el = $(@)
    $bot = $el.closest('.bot')
    
    data = 
      id: $bot.data('id')
      usePullApi: $el.prop("checked")
      
    $.post "/einstellungen/bot", data, ->
      animation = if $el.prop("checked") then "slideDown" else "slideUp"
      $bot.find('.noApiDetails')[animation]('fast')

    $('#botList .noApiDetails input').live 'change', ->
      data = 
        id: $el.closest('.bot').data('id')
        url: $(@).val()

      $.post "/einstellungen/bot", data

  $('#botList .noApi input:checked').each ->
    $(@).closest('.bot').find('.noApiDetails').show()
      
  $('#botList select').live 'change', ->
    $select = $(@)
    $bot = $select.closest('.bot')
    
    data =
      id: $bot.data('id')
      name: $select.val()
      repository: $select.find('option:selected').data('repository') || ''

    $.post "/einstellungen/bot", data, ->
      $bot.find('.name').text(data.name)