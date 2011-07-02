$ ->
  login = $('body').data('login')
  
  $.getJSON "https://github.com/api/v2/json/repos/show/#{login}?callback=?", (data) ->
    for repo in data.repositories
      $option = $("<option>").text(repo.name).attr('value', repo.owner + "/" + repo.name).data('repository', repo.url)
      $('#botList select').append $option
    $('#botList select').val ->
      $(@).closest('.bot').data('name')
      
  $('#settings .addBot').live 'click', (e) ->
    e.preventDefault()
    $hidden = $("#botList > li.hidden")
    if $hidden.length == 1
      $(@).fadeOut 'fast'
    
    if $hidden.length > 0
      $hidden.first().slideDown 'slow', ->
        $(@).removeClass 'hidden'
        
  $('#settings .addBot').hide() if $('#botList > li.hidden').length == 0

  $('#botList select').live 'change', ->
    $select = $(@)
    $bot = $select.closest('.bot')
    
    data =
      id: $bot.data('id')
      name: $select.val()
      repository: $select.find('option:selected').data('repository') || ''

    $.post "/bot", data, ->
      $bot.find('.name').text(data.name)