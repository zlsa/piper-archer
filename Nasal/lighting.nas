# Piper PA-28-181 Archer TX
#        Lighting
###########################

var panel_brightness=aircraft.lowpass.new(0.05);

var update=func {
  var panel = 0;

  panel = crange(8, getprop("/electrical/outputs/panel-lights/voltage"), 14, 0, 3);

  panel_brightness.filter(panel);

  setprop("/electrical/outputs/panel-lights/brightness", panel_brightness.get());
  setprop("/electrical/outputs/cockpit-lights/brightness", panel_brightness.get() * 2);
  settimer(update, 0);

};

var reinit=func {

};

var init=func {
  update();
};

setlistener("/sim/signals/reinit",reinit);
setlistener("/sim/signals/fdm-initialized",init);
