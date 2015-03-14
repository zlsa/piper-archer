
function ui_init() {
  $('nav a').click(ui_tab_clicked);
//  $(window).scroll(ui_onscroll);

  $('input.download.url').click(function() {
    $(this).select();
  });
}

function ui_onscroll() {
  var height = $('header').outerHeight();
  if($(window).width() > 1200) {
    height = 30;
  }
  if($(window).scrollTop() > height) {
    $('html').addClass('nav-fixed');
  } else {
    $('html').removeClass('nav-fixed');
  }
}

function ui_tab_clicked(e) {
  var tab = $(this).attr('data-tab');
  return false;
}
