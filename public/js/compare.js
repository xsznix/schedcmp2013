$(function() {
	// init page
	var body = $(document.body);
	body.addClass("normal");

	// list view toggling
	$("[name=view]").change(function() {
		body.removeClass("normal icons compact");
		body.addClass(this.value);
	});
});