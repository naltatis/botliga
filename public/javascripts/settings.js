(function() {
  $(function() {
    var login;
    login = $('body').data('login');
    $.getJSON("https://github.com/api/v2/json/repos/show/" + login + "?callback=?", function(data) {
      var $option, repo, _i, _len, _ref;
      _ref = data.repositories;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        repo = _ref[_i];
        $option = $("<option>").text(repo.name).attr('value', repo.name).data('repository', repo.url);
        $('#botList select').append($option);
      }
      return $('#botList select').val(function() {
        return $(this).closest('.bot').data('name');
      });
    });
    $('#botList .noApi input').live('change', function() {
      var $bot, $el, data;
      $el = $(this);
      $bot = $el.closest('.bot');
      data = {
        id: $bot.data('id'),
        usePullApi: $el.prop("checked")
      };
      $.post("/bot", data, function() {
        var animation;
        animation = $el.prop("checked") ? "slideDown" : "slideUp";
        return $bot.find('.noApiDetails')[animation]('fast');
      });
      return $('#botList .noApiDetails input').live('change', function() {
        data = {
          id: $el.closest('.bot').data('id'),
          url: $(this).val()
        };
        return $.post("/bot", data);
      });
    });
    $('#botList .noApi input:checked').each(function() {
      return $(this).closest('.bot').find('.noApiDetails').show();
    });
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
