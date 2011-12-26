$(document).ready(function() {
		$('.datepicker').datepicker({dateFormat: 'yy-m-d'});
		$('.sparkline-bar').sparkline('html', {type: 'bar', barColor: '#85acaa', chartRangeMin: 0});
		$('.collapsed .details').hide();
		$('.collapsible legend').click(function() { $(this).next('.details').slideToggle(500); });		
	});
