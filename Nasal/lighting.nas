#     Piper PA-28-181
#        Lighting
###########################

var panel_brightness=aircraft.lowpass.new(0.05);

var update_lighting=func {
  var panel = 0;

  panel = crange(8, getprop("/electrical/outputs/panel-lights/voltage"), 13, 0, 4);

  panel_brightness.filter(panel);

  setprop("/electrical/outputs/panel-lights/brightness", panel_brightness.get());
  setprop("/electrical/outputs/cockpit-lights/brightness", panel_brightness.get() * 4);

};

