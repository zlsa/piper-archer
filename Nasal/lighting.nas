#     Piper PA-28-181
#        Lighting
###########################

var panel_brightness=aircraft.lowpass.new(0.01);
var navigation_lights_brightness=aircraft.lowpass.new(0.05);
var landing_lights_brightness=aircraft.lowpass.new(0.05);

var update_lighting=func {
  var bright = 0;

  bright = crange(8, getprop("/electrical/outputs/navigation-lights/voltage"), 13, 0, 1);
  navigation_lights_brightness.filter(bright);

  setprop("/electrical/outputs/navigation-lights/brightness", navigation_lights_brightness.get());


  bright = crange(8, getprop("/electrical/outputs/panel-lights/voltage"), 13, 0, 1);
  panel_brightness.filter(bright);

  setprop("/electrical/outputs/panel-lights/brightness", panel_brightness.get());
  setprop("/electrical/outputs/cockpit-lights/brightness", panel_brightness.get());


  bright = crange(8, getprop("/electrical/outputs/landing-lights/voltage"), 13, 0, 1);
  landing_lights_brightness.filter(bright);

  setprop("/electrical/outputs/landing-lights/brightness", landing_lights_brightness.get());

};

