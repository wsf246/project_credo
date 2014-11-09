function updateCountdown() {
  var left = 140 - $('.short_verdict').val().length;
  if(left == 1) {
    var charactersLeft = ' character left.'
  }
  else if(left < 0){
    var charactersLeft = ' characters too many.'
  }
  else{
    var charactersLeft = ' characters left.'
  }
  jQuery('.countdown').text(Math.abs(left) + charactersLeft);
}

$(document).ready(function() {
    updateCountdown();
    $('.short_verdict').change(updateCountdown);
    $('.short_verdict').keyup(updateCountdown);
});