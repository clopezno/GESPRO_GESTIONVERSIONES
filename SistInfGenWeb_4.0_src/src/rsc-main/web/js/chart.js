google.load("visualization", "1", {	packages : [ "corechart" ]});
function drawGraf(datosGraf, id, titulo) {
	var data = google.visualization
			.arrayToDataTable(datosGraf);
	var options = {
		title : titulo,
		curveType: 'function',
        legend: { position: 'bottom' },

	};
	var chart = new google.visualization.LineChart(document
			.getElementById(id));
	chart.draw(data, options);
	
}

function drawChart(datosGraf, id, titulo) {
//	alert("It's a method");
	drawGraf(datosGraf, id, titulo);
}