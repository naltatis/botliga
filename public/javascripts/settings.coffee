$ ->
  $.getJSON "https://github.com/api/v2/json/repos/show/naltatis?callback=?", (data) ->
    for repo in data.repositories
      $('#botRepository').append("<option>#{repo.name}</option>")