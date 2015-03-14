
var repo="piper-archer";

function tab(t) {
  return;
  $(".tab").removeClass("active");
  $("#tab-"+t).addClass("active");
  $("#tab-"+t).css("display", "block");
  $("#tabs a").removeClass("active");
  $("#tabs a."+t).addClass("active");
  $(".tab").not(".active").css("display", "none");
  location.hash = t;
  console.log(t);
}

$(document).ready(function() {
  
  ui_init();
  
});
