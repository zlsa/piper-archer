#     Piper Archer
#     Main Nasal file
###########################

var INIT=false;

var version_gt_3_4 = substr(getprop("/sim/version/flightgear"), 0, 3) > 3.4;

var update = func {
  update_electrical();
  update_fuel();
  update_lighting();
  update_engine();
  
  if(getprop("/sim/current-view/internal")) {
    setprop("/sim/rendering/precipitation-aircraft-enable", false);
  } else {
    setprop("/sim/rendering/precipitation-aircraft-enable", true);
  }
  
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

    if(version_gt_3_4)
      settimer(update_glass, 1);
  
    settimer(update, 1);
  }
};

setlistener("/sim/signals/reinit", init);
setlistener("/sim/signals/fdm-initialized", init);
