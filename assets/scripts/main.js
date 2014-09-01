
var repo="pa28-181";

$(document).ready(function() {
  $.get("https://api.github.com/repos/zlsa/"+repo+"/commits/master", function(data) {
    console.log(data);
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
