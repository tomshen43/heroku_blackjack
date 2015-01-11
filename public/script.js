$(document).ready(function() {
  player_hit();
  player_stay();
  dealer_hit();
});

function player_hit() {
  $(document).on('click', '#hit_form input',function(){
    $.ajax({
      type: 'POST',
      url: '/game/hit'
    }).done(function(msg) {
      $('div#game').replaceWith(msg);
    });
  return false;
  });
}

function player_stay() {
  $(document).on('click', '#stay_form input',function(){
    $.ajax({
      type: 'POST',
      url: '/game/stay'
    }).done(function(msg) {
      $('div#game').replaceWith(msg);
    });
  return false;
  });
}

function dealer_hit() {
  $(document).on('click', '#dealer_hit input',function(){
    $.ajax({
      type: 'POST',
      url: '/game/dealer/hit'
    }).done(function(msg) {
      $('div#game').replaceWith(msg);
    });
  return false;
  });
}
