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
				var data = {date: new Date(), record_category_id: $(this).attr('data-id')};
				pendingItems.push(data);
				localStorage["pendingItems"] = JSON.stringify(pendingItems);
				updateMessage(pendingItems);
				synchronize();
				event.preventDefault();
		});
    synchronize();
	});


var updating = false;
function synchronize() {
	var pendingItems = $.parseJSON(localStorage["pendingItems"]);
	if (!window.navigator.onLine) return false;
	updateMessage(pendingItems);
	if (pendingItems.length > 0) {
		var item = pendingItems[0];
		$.post("/api/offline/v1/bulk_track", item, function(data) {
				var pendingItems = $.parseJSON(localStorage["pendingItems"]);
				pendingItems.shift();
				localStorage["pendingItems"] = JSON.stringify(pendingItems)
				setTimeout(synchronize, 100);
			});
	}
}

function updateMessage(pendingItems) {
	if (pendingItems.length == 1) {
		$('.message').html('1 item to synchronize...');
	}
	else {
		$('.message').html(pendingItems.length + ' items to synchronize...');
	}
}
$(window).bind('online', synchronize);
