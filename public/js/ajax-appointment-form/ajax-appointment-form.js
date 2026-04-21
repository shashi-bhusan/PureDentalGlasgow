(function($) {

	'use strict';
	
	var appointmentFormXML;
	var appointmentFormRequestHandler;
	
	//var templateDir = '/idigital'; //local testing only
	
	if (window.XMLHttpRequest){// code for IE7+, Firefox, Chrome, Opera, Safari
	  appointmentFormXML=new XMLHttpRequest();
	} else {// code for IE6, IE5
	  appointmentFormXML=new ActiveXObject("Microsoft.XMLHTTP");
	}
	
	function sendAppointmentInfo() {
	
		appointmentFormXML.open("POST", "js/ajax-appointment-form/send_email.php",true);
		appointmentFormXML.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
		var form = $('#pm-appointment-form');
		appointmentFormXML.send(form.serialize());
		appointmentFormXML.onreadystatechange=appointmentFormRequestHandler;
	}
	
	appointmentFormRequestHandler=function(data){
	
		if (appointmentFormXML.readyState==4 && appointmentFormXML.status==200)	{
			
			var responseTextObject = jQuery.parseJSON(appointmentFormXML.responseText);
				
			if(responseTextObject.status == "name_error") {
				
				$('#pm-appointment-form-response').html('* Please fill in your name.');
				$('#pm_app_form_name').addClass('invalid_field');
				bindClickEvent();
				
			} else if(responseTextObject.status == "email_error") {
				
				$('#pm-appointment-form-response').html('* Please provide a valid email address.');
				$('#pm_app_form_email').addClass('invalid_field');
				bindClickEvent();
				
			} else if(responseTextObject.status == "phone_error") {
				
				$('#pm-appointment-form-response').html('* Please provide your phone number.');
				$('#pm_app_form_phone').addClass('invalid_field');
				bindClickEvent();
				
			} else if(responseTextObject.status == "date_error") {
				
				$('#pm-appointment-form-response').html('* Please select a date for your appointment.');
				$('#pm_app_form_date').addClass('invalid_field');
				bindClickEvent();
				
			} else if(responseTextObject.status == "time_error") {
				
				$('#pm-appointment-form-response').html('* Please provide a time for your appointment.');
				$('#pm_app_form_time').addClass('invalid_field');
				bindClickEvent();
				
			} else if(responseTextObject.status == "success"){
				
				$('#pm-appointment-form-response').html('Your inquiry has been received, thank you.');
				$('#pm-appointment-form-btn').fadeOut();
				
			} else if(responseTextObject.status == "failed"){
				
				$('#pm-appointment-form-response').html('A system error occurred. Please try again later.');
				$('#pm-appointment-form-btn').fadeOut();
				
			}
	
		}
	
	}
	
	$(document).ready(function(e) {
		
		bindClickEvent();
		
		$('#pm_app_form_name').focus(function(e) {
			$(this).removeClass('invalid_field');
		});
		
		$('#pm_app_form_email').focus(function(e) {
			$(this).removeClass('invalid_field');
		});
		
		$('#pm_app_form_phone').focus(function(e) {
			$(this).removeClass('invalid_field');
		});
		
		$('#pm_app_form_date').focus(function(e) {
			$(this).removeClass('invalid_field');
		});
		
		$('#pm_app_form_time').focus(function(e) {
			$(this).removeClass('invalid_field');
		});
		
		$('#pm_app_form_security_code').focus(function(e) {
			$(this).removeClass('invalid_field');
		});
	
	});//end of jQuery
	
	function bindClickEvent() {
			
		$('#pm-appointment-form-btn').click(function(e) {
		
			sendAppointmentInfo();
		
			$(this).unbind("click");
			
			$('#pm-appointment-form-response').html("Validating message, please wait...");
						
			//$('#form_response').show();
			
			//alert('submit form');
			e.preventDefault();
		});
			
	}
	
})(jQuery);


