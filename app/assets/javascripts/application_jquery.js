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
   $('#question_descr').prop('disabled', true);

$('#question_question_type option:selected').keyup(function(){
      if($('#question_question_type option:selected').text() !=  "Yes/No") 
           $('#question_descr').prop('disabled', false);    
  else
     $('#question_descr').prop('disabled', true);   
});
 });



