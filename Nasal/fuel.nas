# Piper PA-28-181 Archer TX
#     Fuel handling
###########################

var PRESSURE=0;

var fuel_pressure=aircraft.lowpass.new(2.0);

var update=func {
  var selected  = getprop("/controls/fuel_selector");
  var level     = 0;
  setprop("/consumables/fuel/tank[0]/selected", false);
  setprop("/consumables/fuel/tank[1]/selected", false);
  if(selected == 0 or selected == 1) {
      setprop("/consumables/fuel/tank[" ~ selected ~ "]/selected", true);
      level     = getprop("/consumables/fuel/tank[" ~ selected ~ "]/level-gal_us");
  } else {
#      setprop("/engines/engine[0]/magnetos", 0);
  }
  var running   = getprop("/engines/engine[0]/running");

  var fuel_pump = getprop("/controls/switches/fuel");

  var engine_running = getprop("/engines/engine[0]/running");

  var pressure  = 0;

  if(level > 0.3) {
      if(running)   pressure = crange(200, getprop("/engines/engine[0]/rpm"), 2600, 4, 6);
      if(fuel_pump) pressure = 7;
  }

  fuel_pressure.filter(pressure);
  setprop("/engines/engine[0]/fuel-pressure_psi", fuel_pressure.get());
  settimer(update, 0);

};

var reinit=func {

};

var init=func {
  update();
};

setlistener("/sim/signals/reinit",reinit);
setlistener("/sim/signals/fdm-initialized",init);
