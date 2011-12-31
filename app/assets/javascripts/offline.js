var updating = false;
var status;

function pad(n){ return n < 10 ? '0' + n : n }
// https://developer.mozilla.org/en/Core_JavaScript_1.5_Reference/Objects/Date#Example.3a_ISO_8601_formatted_dates
function ISODateString(d) {
	return d.getUTCFullYear()+'-'
		+ pad(d.getUTCMonth()+1)+'-'
		+ pad(d.getUTCDate())+'T'
		+ pad(d.getUTCHours())+':'
		+ pad(d.getUTCMinutes())+':'
		+ pad(d.getUTCSeconds())+'Z'
 }

function synchronize() {
	if (updating) return false;
	updating = true;
	var pendingItems = $.parseJSON(localStorage["pendingItems"]);
	updateMessage();
	if (pendingItems.length > 0) {
		var item = pendingItems[0];
		$.post("/api/offline/v1/bulk_track.json", item, function(data) {
				var pendingItems = $.parseJSON(localStorage["pendingItems"]);
				pendingItems.shift();
				localStorage["pendingItems"] = JSON.stringify(pendingItems)
					setTimeout(synchronize, 100);
				status = 200;
			}).error(function(xhr, ajaxOptions, thrownError) {
					status = xhr.status;
					updateMessage();
				});
	}
	updating = false;
}

function updateMessage() {
	var pendingItems = $.parseJSON(localStorage["pendingItems"]);
	var lastEntry = $.parseJSON(localStorage["lastEntry"]);
	var message = '';
	var date = new Date(lastEntry.date);
	if (lastEntry) {
		message = "Last entry: <strong>" + lastEntry.name + "</strong> ("
			+ date.getHours() + ":" + pad(date.getMinutes()) + ', <time class="timeago" datetime="' + ISODateString(date) + '">' + ISODateString(date) + '</time>). ';
	}
	if (pendingItems.length == 1) {
		message += '1 item to synchronize... ';
	}
	else {
		message += (pendingItems.length + ' items to synchronize... ');
	}
	if (status && status != 200) {
		if (status == 403) {
			message += ' Your session has expired. <a href="/d/users/sign_in?destination=/api/offline/v1/track">Please log in again.</a>';
		}
	}
	$('.message').html(message);
	jQuery('time.timeago').timeago();
}

$(document).ajaxSend(function(e, xhr, options) {
		var token = $("meta[name='csrf-token']").attr("content");
		xhr.setRequestHeader("X-CSRF-Token", token);
	});

$(document).ready(function() {
		if (!localStorage["pendingItems"]) {
			localStorage["pendingItems"] = JSON.stringify([]);
		}
		$('a.category').click(function(event) {
				var pendingItems = $.parseJSON(localStorage["pendingItems"]);
				var data = {date: new Date(), record_category_id: $(this).attr('data-id'), name: $(this).html()};
				pendingItems.push(data);
				localStorage["lastEntry"] = JSON.stringify(data);
				localStorage["pendingItems"] = JSON.stringify(pendingItems);
				synchronize();
				event.preventDefault();
		});
		$('#sync').click(synchronize);
		$('#clear').click(function() { localStorage["lastEntry"] = ''; localStorage['pendingItems'] = ''; updateMessage(); });
		updateMessage();
		$(window).bind('online', synchronize);
    synchronize();
	});

