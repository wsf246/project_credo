function remove_fields(link) {
  $(link).prev("input[type=hidden]").val("1");
  $(link).closest(".fields").hide();
}

function add_fields(link, association, content) {
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association, "g")
  $(link).parent().before(content.replace(regexp, new_id));
}

$(document).ajaxError(function (e, xhr, settings) {
        if (xhr.status == 401) {
           $('#error_explanation').html(xhr.responseText);
        }
        else {
           $('#modal_error_explanation').html("<h5>Please sign in or sign up to continue</h5>");
        }
    });


$(document).ready(function() {
if($('#question_question_type option:selected').text() ==  "Yes/No") 
   $('#question_description').prop('disabled', true);

$('#question_question_type option:selected').keyup(function(){
      if($('#question_question_type option:selected').text() !=  "Yes/No") 
           $('#question_description').prop('disabled', false);    
  else
     $('#question_description').prop('disabled', true);   
});
 });