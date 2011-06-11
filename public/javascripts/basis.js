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
  
  $.each(tendency, function (i, entry) {
    data.setValue(i, 0, entry.result);
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

});