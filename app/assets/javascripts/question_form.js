$(document).ready(function() {
  $('#question_question_type').change(function(){
    var value = $(this).val(); 
    if(value == "Yes/No") {
      $('#question_answers').prop('disabled', true);
    }
    else if(value == "Multiple Answers") {
      $('#question_answers').prop('disabled', false);
    }
  });
});

