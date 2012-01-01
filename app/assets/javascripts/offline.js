var updating = false;
var status;
// %li= link_to c.full_name, c, :class => :category, :'data-id' => c.id
function loadCategories() {
	$.retrieveJSON("/record_categories/tree.json", function(data) {
			// Fill in the categories list
			$('#categories').html($('#category_template').tmpl(data));
			$('#categories a').click(trackCategory);
		});
}

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
	if (lastEntry) {
		var date = new Date(lastEntry.date);
		console.log(date.getMinutes());
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

function trackCategory(event) {
	var pendingItems = $.parseJSON(localStorage["pendingItems"]);
	var data = {date: new Date().getTime(), record_category_id: $(this).attr('data-id'), name: $(this).html()};
	pendingItems.push(data);
	localStorage["lastEntry"] = JSON.stringify(data);
	localStorage["pendingItems"] = JSON.stringify(pendingItems);
	// Display the form
	if ($(this).attr('data-form')) {
		var form = $.parseJSON(unescape($(this).attr('data-form')));
		var new_form = $('#form_template').tmpl({data: form});
		$('#form').html(new_form);
		scroll(0, 0);
	}
	synchronize();
	event.preventDefault();
}

$(document).ready(function() {
		if (!localStorage["pendingItems"]) {
			localStorage["pendingItems"] = JSON.stringify([]);
		}
		$('#sync').click(synchronize);
		$('#clear').click(function() { localStorage["lastEntry"] = ''; localStorage['pendingItems'] = ''; updateMessage(); });
		updateMessage();
		loadCategories();
		$(window).bind('online', synchronize);
    synchronize();
	});

