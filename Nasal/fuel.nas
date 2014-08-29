# Piper PA-28-181 Archer TX
#     Fuel handling
###########################

var PRESSURE=0;

var fuel_pressure=aircraft.lowpass.new(2.0);

var update=func {
  var pressure  = 0;

  var selected  = getprop("/controls/fuel_selector");
  var level     = 0;

  setprop("/consumables/fuel/tank[0]/selected", false);
  setprop("/consumables/fuel/tank[1]/selected", false);
  setprop("/consumables/fuel/tank[2]/selected", false);

  if(selected == 0 or selected == 1) {
      setprop("/consumables/fuel/tank[" ~ selected ~ "]/selected", true);
  }

  level         = getprop("/consumables/fuel/tank[2]/level-gal_us");
  var running   = getprop("/engines/engine[0]/running");

  var fuel_pump = getprop("/controls/switches/fuel");

  if(level > 0.0001 and running) {
      pressure = crange(200, getprop("/engines/engine[0]/rpm"), 2600, 4, 6);
  }

  if(fuel_pump) {
      pressure = 7;
  }

  setprop("/fdm/jsbsim/propulsion/fuel-pump", fuel_pump);

  setprop("/fdm/jsbsim/propulsion/fuel-selector", selected);

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
