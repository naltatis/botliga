$ ->
  login = $('body').attr('data-login')

  return unless login
  
  $.getJSON "https://api.github.com/users/#{login}/repos?callback=?", (response) ->
    for repo in response.data
      $option = $("<option>").text(repo.name).attr('value', repo.owner.login + "/" + repo.name).data('repository', repo.html_url)
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