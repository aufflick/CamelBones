window.addEvent('domready', function() {
	var status = {
		'true': 'Hide Menu',
		'false': 'Show Menu'
	};
	
	//-vertical

	var myVerticalSlide = new Fx.Slide('menulist');
    $('menu_status').set('html', status[myVerticalSlide.open]);

	$('toggle_menu').addEvent('click', function(e){
		e.stop();
		myVerticalSlide.toggle();
	});

	// When Vertical Slide ends its transition, we check for its status
	// note that complete will not affect 'hide' and 'show' methods
	myVerticalSlide.addEvent('complete', function() {
		$('menu_status').set('html', status[myVerticalSlide.open]);
	});
});
