(function() {
  head(function() {
    $('#guessesByGroup').guessesByGroup();
    $('#pointsBySeasonTable').pointsBySeasonTable();
    $('#pointsBySeasonChart').pointsBySeasonChart();
    return $('#guessesByGroup .google-visualization-table-table tbody tr td:first-child:not(.google-visualization-table-sorthdr)').live('click', function(e) {
      var $layer, botName;
      e.preventDefault();
      botName = $(this).text();
      $layer = $('<div />').attr('id', 'botProfileLayer');
      $('#botProfileLayer').remove();
      $('#overall').append($layer);
      return $layer.profile({
        botName: botName
      });
    });
  });
}).call(this);
