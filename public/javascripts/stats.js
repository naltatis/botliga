google.load("visualization", "1", {packages:["corechart"]});
google.setOnLoadCallback(function () {
  
  /* Popular Results */
  var data = new google.visualization.DataTable();
  data.addColumn('string', 'Ergebnis');
  data.addColumn('number', 'Anzahl');
  
  var popularResults = $("#popularResults").data('data');
  
  data.addRows(popularResults.length);
  
  $.each(popularResults, function (i, entry) {
    data.setValue(i, 0, entry.result);
    data.setValue(i, 1, entry.count);
  });
  
  var chart = new google.visualization.ColumnChart(document.getElementById('popularResults'));
  chart.draw(data, {
    width: "100%",
    height: 300,
    title: 'Häufige Endergebnisse',
    legend: "none",
    hAxis: {
      slantedTextAngle: 90,
      slantedText: true,
      textStyle: { fontSize: 12 }
    }
  });


  /* Tendency */
  data = new google.visualization.DataTable();
  data.addColumn('string', 'Ergebnis');
  data.addColumn('number', 'Anzahl');
  
  var tendency = $("#tendency").data('data');
  
  data.addRows(tendency.length);

  var legend = {home: "Heimsieg", draw: "Gleichstand", guest: "Auswärtssieg"};
  
  $.each(tendency, function (i, entry) {
    data.setValue(i, 0, legend[entry.result]);
    data.setValue(i, 1, entry.count);
  });
  
  chart = new google.visualization.PieChart(document.getElementById('tendency'));
  chart.draw(data, {
    width: "100%",
    height: 300,
    title: 'Tendenz',
    hAxis: {
      slantedTextAngle: 90,
      slantedText: true,
      textStyle: { fontSize: 12 }
    }
  });

  /* Tendency History */
  data = new google.visualization.DataTable();
  data.addColumn('string', 'Jahr');
  data.addColumn('number', 'Heimsieg');
  data.addColumn('number', 'Gleichstand');
  data.addColumn('number', 'Auswärtssieg');
  
  var tendencyHistory = $("#tendencyHistory").data('data');
  
  data.addRows(tendencyHistory.length);
  
  $.each(tendencyHistory, function (i, entry) {
	var per = 100 / (entry.tendency.home + entry.tendency.draw + entry.tendency.guest);
    data.setValue(i, 0, entry.year);
    data.setValue(i, 1, entry.tendency.home * per);
    data.setValue(i, 2, entry.tendency.draw * per);
    data.setValue(i, 3, entry.tendency.guest * per);
  });
  
  chart = new google.visualization.LineChart(document.getElementById('tendencyHistory'));
  chart.draw(data, {
    width: "100%",
    height: 300,
    title: 'Tendenz Historie (in %)',
  });

});