
var repo="pa28-181";

function tab(t) {
  $(".tab").removeClass("active");
  $("#tab-"+t).addClass("active");
  $("#tab-"+t).css("display", "block");
  $("#tabs a").removeClass("active");
  $("#tabs a."+t).addClass("active");
  $(".tab").not(".active").css("display", "none");
  console.log(t);
}

$(document).ready(function() {
  $.get("https://api.github.com/repos/zlsa/"+repo+"/commits/master", function(data) {
    if(data.length >= 1) {
      var c = data[0];
    } else {
      var c = data;
    }
    var commit = c.commit.message;
    var time   = new Date(Date.parse(c.commit.committer.date));
    $("#last-commit .message").text(commit);
    $("#last-commit").removeClass("fetching");
    var s      = "";
    var months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
    s         += time.getDate() + " ";
    s         += months[time.getMonth()] + " ";
    s         += time.getFullYear();
    $(".last-update .date").text(s);
  });
});
