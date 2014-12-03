function updateCountdown() {
  var left = 140 - $('#verdict_short').val().length;
  if(left == 1) {
    var charactersLeft = ' character left.'
  }
  else if(left < 0){
    var charactersLeft = ' characters too many.'
  }
  else{
    var charactersLeft = ' characters left.'
  }
  $('.countdown').text(Math.abs(left) + charactersLeft);
}
