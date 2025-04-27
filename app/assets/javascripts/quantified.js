function addDownloadSVGButtons() {
	document.querySelectorAll('#canvas svg').forEach((o) => {
		const button = document.createElement('button');
		button.textContent = 'Download SVG';
		button.classList.add('download-svg');
		o.closest('div').after(button);
		button.addEventListener('click', function(event) {
			const element = document.createElement('a');
			const blob = new Blob([o.outerHTML.toString()]);
			element.download = 'time.svg';
			element.href = window.URL.createObjectURL(blob);
			document.body.appendChild(element);
			element.click();
			element.remove();
		});
	});
}
$(document).ready(function() {
	$('.datepicker').datepicker({dateFormat: 'yy-m-d'});
	$('.sparkline-bar').sparkline('html', {type: 'bar', barColor: '#85acaa', chartRangeMin: 0});
	$('.sparkline').sparkline('html', {enableTagOptions: true, type: 'bullet'});
	$('.spark').sparkline('html', { type: 'bar', barColor: '#85acaa', chartRangeMin: 0});
	$('.collapsed .details').hide();
	$('.collapsible legend').unbind('click').click(function() { $(this).next('.details').slideToggle(500); });
	jQuery('time.timeago').timeago();
	$('.tooltip-fixed').qtip({fixed: true, hide: { delay: 1000, event: 'mouseout' }, content: { text: 'Loading...', ajax: { url: $(this).attr('rel') }}});
	addDownloadSVGButtons();
});
