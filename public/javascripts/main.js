(function() {
  head(function() {
    $('#guessesByGroup').guessesByGroup();
    $('#pointsBySeasonTable').pointsBySeasonTable();
    return $('#pointsBySeasonChart').pointsBySeasonChart();
  });
}).call(this);
