$(document).ajaxError(function (e, xhr, settings) {
      if (xhr.status == 401) {
        $('#error_explanation').html(xhr.responseText).attr('class', 'alert alert-alert');
        $('#modal_error_explanation').html(xhr.responseText).attr('class', 'alert alert-alert');
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



