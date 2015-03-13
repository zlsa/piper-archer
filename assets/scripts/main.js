
var repo="piper-archer";

function tab(t) {
  $(".tab").removeClass("active");
  $("#tab-"+t).addClass("active");
  $("#tab-"+t).css("display", "block");
  $("#tabs a").removeClass("active");
  $("#tabs a."+t).addClass("active");
  $(".tab").not(".active").css("display", "none");
  location.hash = t;
  console.log(t);
}

function convert_date(d) {
  var date = moment();
  date.year(  d.substr(0, 4));
  date.month( d.substr(4, 2));
  date.date(  d.substr(6, 2));
  date.hour(  0);
  date.minute(0);
  date.second(0);
  if(moment().diff(date, 'days') < 1)
    return "today";
  return date.fromNow();
}

$(document).ready(function() {
  $(".github").click(function() {
    $(this).select();
  });
  for(var i=info.releases.length-1;i>=0;i--) {
    var release = info.releases[i];
    if(release[0] == "piper-archer-latest.zip") {
      $(".last-update .date").text(convert_date(release[1]));
      $(".size").text(release[2] + " MB");
    } else {
      $("#tab-releases").append("<div class='release'><a class='download' href='http://zlsa.github.io/piper-archer/releases/"+release[0]+"' title='Download this older release'>"+release[0]+"</a><span class='size'>"+release[2]+" MB</span></div>");
    }
  }
  if(location.hash) tab(location.hash.substr(1))
});
