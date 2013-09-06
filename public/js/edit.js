$(function() {
	// callback for loading course names
	$(".coursenum").change(function() {
		var index = $(this).data("block");
		var cnum = this.value;
		if (this.value == '') {
			$('.coursename[data-block='+index+']').text('');
		} else {
			// load the course name
			$.get("/coursename/" + this.value, function(data) {
				// update DOM
				$(".coursename[data-block="+index+"]").text(data);
				if (index < 9) {
					// update second semester course data if empty
					var coursenum_sem2 = $(".coursenum[data-block="+(index+8)+"]");
					if (coursenum_sem2.val() == "") {
						$(".coursename[data-block="+(index+8)+"]").text(data);
						coursenum_sem2.val(cnum);
					}
				}
			});
		}
	});
});