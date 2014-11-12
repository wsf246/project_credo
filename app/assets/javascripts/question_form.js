var ready;
ready = function() {
  $('#question_question_type').on('click', "option[value='Yes/No']", function(){
    $('#question_answers').prop('disabled', true);
  });
  $('#question_question_type').on('click', "option[value='Multiple Answers']", function(){
    $('#question_answers').prop('disabled', false);
  });
};

$(document).ready(ready);
$(document).on('page:load', ready);