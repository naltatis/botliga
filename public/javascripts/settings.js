(function() {
  $(function() {
    var login;
    login = $('body').data('login');
    if (!login) {
      return;
    }
    $.getJSON("https://github.com/api/v2/json/repos/show/" + login + "?callback=?", function(data) {
      var $option, repo, _i, _len, _ref;
      _ref = data.repositories;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        repo = _ref[_i];
        $option = $("<option>").text(repo.name).attr('value', repo.owner + "/" + repo.name).data('repository', repo.url);
        $('#botList select').append($option);
      }
      return $('#botList select').val(function() {
        return $(this).closest('.bot').data('name');
      });
    });
    $('#settings .addBot').live('click', function(e) {
      var $hidden;
      e.preventDefault();
      $hidden = $("#botList > li.hidden");
      if ($hidden.length === 1) {
        $(this).fadeOut('fast');
      }
      if ($hidden.length > 0) {
        return $hidden.first().slideDown('slow', function() {
          return $(this).removeClass('hidden');
        });
      }
    });
    if ($('#botList > li.hidden').length === 0) {
      $('#settings .addBot').hide();
    }
    return $('#botList select').live('change', function() {
      var $bot, $select, data;
      $select = $(this);
      $bot = $select.closest('.bot');
      data = {
        id: $bot.data('id'),
        name: $select.val(),
        repository: $select.find('option:selected').data('repository') || ''
      };
      return $.post("/bot", data, function() {
        return $bot.find('.name').text(data.name);
      });
    });
  });
}).call(this);
