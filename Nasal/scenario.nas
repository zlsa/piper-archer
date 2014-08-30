#     Piper PA-28-181
#     Fuel handling
###########################

var init_scenario=func {
    setprop("/consumables/fuel/tank[2]/level-gal_us", 0.16);
    setprop("/controls/switches/battery", true);
    setprop("/controls/switches/alternator", true);
    setprop("/controls/switches/panel-lights", 0.0);
    setprop("/controls/fuel-selector", 0);
};

