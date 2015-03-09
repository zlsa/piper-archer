#      Piper Archer
#        Lighting
###########################

var panel_brightness             = aircraft.lowpass.new(0.01);
var navigation_lights_brightness = aircraft.lowpass.new(0.05);
var landing_lights_brightness    = aircraft.lowpass.new(0.05);
var beacon_brightness            = aircraft.lowpass.new(0.05);
var avionics_brightness          = aircraft.lowpass.new(0.05);

var strobe_lights                = aircraft.light.new("/electrical/outputs/strobe/light", [0.05, 1.0, 0.05, 0.08], "/electrical/outputs/strobe/powered");

var update_lighting = func {
  var bright = 0;

  bright = crange(8, getprop("/electrical/outputs/navigation-lights/voltage"), 14, 0, 1);
  navigation_lights_brightness.filter(bright);

  setprop("/electrical/outputs/navigation-lights/brightness", navigation_lights_brightness.get());


  bright = crange(8, getprop("/electrical/outputs/panel-lights/voltage"), 14, 0, 1.5);
  panel_brightness.filter(bright);

  setprop("/electrical/outputs/panel-lights/brightness", panel_brightness.get());
  setprop("/electrical/outputs/cockpit-lights/brightness", panel_brightness.get());


  bright = crange(8, getprop("/electrical/outputs/landing-lights/voltage"), 13, 0, 1);
  landing_lights_brightness.filter(bright);

  setprop("/electrical/outputs/landing-lights/brightness", landing_lights_brightness.get());
  if(landing_lights_brightness.get() > 0.001 and getprop("/sim/current-view/internal")) {
    setprop("/sim/rendering/als-secondary-lights/use-landing-light", true);
    setprop("/sim/rendering/als-secondary-lights/use-alt-landing-light", true);
  } else {
    setprop("/sim/rendering/als-secondary-lights/use-landing-light", false);
    setprop("/sim/rendering/als-secondary-lights/use-alt-landing-light", false);
  }

  bright = crange(8, getprop("/electrical/outputs/strobe/voltage"), 14, 0, 1);
  beacon_brightness.filter(bright);

  setprop("/electrical/outputs/beacon/brightness", beacon_brightness.get());

  bright = crange(10, getprop("/electrical/outputs/avionics/voltage"), 14, 0, 1);
  avionics_brightness.filter(bright);

  setprop("/electrical/outputs/avionics/brightness", avionics_brightness.get());

};

