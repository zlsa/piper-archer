# Piper PA-28-181 Archer TX
#        Lighting
###########################

var PRESSURE=0;

var panel_brightness=aircraft.lowpass.new(0.05);

var update=func {
  var panel = 0;

  panel = crange(8, getprop("/electrical/outputs/panel-lights/voltage"), 14, 0.2, 1);

  panel_brightness.filter(panel);

  setprop("/electrical/outputs/panel-lights/brightness", panel_brightness.get());
  settimer(update, 0);

};

var reinit=func {

};

var init=func {
  update();
};

setlistener("/sim/signals/reinit",reinit);
setlistener("/sim/signals/fdm-initialized",init);
