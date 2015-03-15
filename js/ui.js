
var NAME = "piper-archer";

function ui_init() {
  $('nav a').click(ui_tab_clicked);
//  $(window).scroll(ui_onscroll);

  $('input.download.url').click(function() {
    $(this).select();
  });

  ui_past_releases();

  ui_tab(location.hash.substr(1) || "features", false);

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
  ui_tab(tab);
  e.preventDefault();
  return false;
}

function ui_past_releases() {
  for(var i=info.releases.length-1; i>=0; i--) {
    var release = info.releases[i];
    var filename = release[0];
    var date     = release[1];
    var filesize = release[2];
    
    if(filename == NAME + "-latest.zip") {

    } else {
      var li = $('<li></li>');
      li.append('<a class="button"></a>');
      li.find('.button').text(filename);
      li.find('.button').href = "http://zlsa.github.io/piper-archer/releases/" + filename;
      li.append('<span class="filesize"></span> MB');
      li.find('span.filesize').text(filesize.toFixed(2));
      $('.from-latest ul').append(li);
    }
  }
  
  $('.from-latest ul li.loading').remove();
}

function ui_tab(t, hash) {
  $("nav .tab").removeClass("active");
  $("nav .tab[data-tab=" + t + "]").addClass("active");
  $("#tabs .tab").removeClass("active");
  $("#tabs #tab-" + t).addClass("active");
  if(hash != false)
    location.hash = t;
  $(window).scrollTop(0);
  console.log(t);
}

