var updating = false;
var status;
var lastID = null;

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

// We need to make sure that we don't submit this multiple times.
// This function gets called when you click on the link, when you go online, and after you update.
// It also calls itself after a timeout.
// We want to:
//   Retrieve the first item.
//   Attempt to post it.
//   If it succeeds, 
function synchronize() {
	if (!navigator.onLine) return false;
	var pendingItems = $.parseJSON(localStorage["pendingItems"]);
	updateMessage();
	if (pendingItems.length > 0) {
		var item = pendingItems[0];
		$.post("/api/offline/v1/bulk_track.json", item, function(data) {
				var pendingItems = $.parseJSON(localStorage["pendingItems"]);
				pendingItems.shift();
				localStorage["pendingItems"] = JSON.stringify(pendingItems);
				status = 200;
				if (lastID == null) {
					lastID = data;
				}
				setTimeout(synchronize, 100);
			}).error(function(xhr, ajaxOptions, thrownError) {
					status = xhr.status;
					updateMessage();
				});
	}
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

function updateRecord(event) {
	var pendingItems = $.parseJSON(localStorage["pendingItems"]);
	// Queue an update if we have already synchronized
	if (lastID != null) {
		// The latest entry has already been synchronized, so attempt to update it
		pendingItems.push({type: 'edit', id: lastID.id, data: $('#form').serializeArray()});
		localStorage["pendingItems"] = JSON.stringify(pendingItems);
	} else {
		// Update the latest record if it has not yet been sent
		// Pop the last entry off the list
		var item = pendingItems[0];
		item.data = $('#form').serializeArray();
		pendingItems[0] = item;
		localStorage["pendingItems"] = JSON.stringify(pendingItems);
	}
	synchronize();
	$('#form').html('');
	event.preventDefault();
}

function trackCategory(event) {
	var pendingItems = $.parseJSON(localStorage["pendingItems"]);
	var data = {date: new Date().getTime(), record_category_id: $(this).attr('data-id'), name: $(this).html()};
	pendingItems.push(data);
	localStorage["lastEntry"] = JSON.stringify(data);
	localStorage["pendingItems"] = JSON.stringify(pendingItems);
	lastID = null;
	// Display the form
	var form_data = unescape($(this).attr('data-form'));
	$('#form').html();
	if (form_data != '{}' && form_data != 'null') {
		var form = $.parseJSON(form_data);
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
		$('#form').submit(updateRecord);
	});

