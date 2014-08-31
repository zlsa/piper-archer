#     Piper PA-28-181
#     Fuel handling
###########################

var init_scenario=func {
    setprop("/consumables/fuel/tank[2]/level-gal_us", 0.08);
    setprop("/controls/switches/battery", true);
    setprop("/controls/switches/alternator", true);
    setprop("/controls/switches/panel-lights", 0.0);
    setprop("/controls/fuel-selector", 0);
};

var autostart=func {
    setprop("/consumables/fuel/tank[2]/level-gal_us", 0.08);
    setprop("/controls/switches/battery", true);
    setprop("/controls/switches/alternator", false);
    setprop("/controls/switches/panel-lights", 0.5);
    setprop("/controls/fuel-selector", 0);
    setprop("/controls/key", 3);
}
