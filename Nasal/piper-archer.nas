#     Piper Archer
#     Main Nasal file
###########################

var INIT=false;

var oil_pressure_lowpass=aircraft.lowpass.new(0.5);

var update=func {
  update_electrical();
  update_fuel();
  update_lighting();

  oil_pressure_lowpass.filter(crange(600, getprop("/engines/engine[0]/rpm"), 2700, 30, 75));
  setprop("/engines/engine[0]/oil-pressure", oil_pressure_lowpass.get());

  settimer(update, 0);
};

var reinit=func {
  init_scenario();
};

var init=func {
  if(INIT) {
    init_scenario();
  } else {
    INIT=true;

    init_scenario();

    init_electrical();

    settimer(update, 0);
  }
};

setlistener("/sim/signals/reinit", init);
setlistener("/sim/signals/fdm-initialized", init);
