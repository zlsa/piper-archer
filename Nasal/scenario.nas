#     Piper PA-28-181
#     Fuel handling
###########################

var init_scenario=func {
    setprop("/consumables/fuel/tank[2]/level-gal_us", 0.08);
    setprop("/controls/switches/battery", true);
    setprop("/controls/switches/alternator", true);
    setprop("/controls/switches/panel-lights", 0.0);
    setprop("/controls/fuel-selector", 0);

    if(getprop("/position/altitude-agl-ft") > 10) {
        setprop("/controls/key", 3);
        engine.key(0);
        setprop("/engines/engine[0]/rpm", 1000);
        setprop("/velocities/airspeed-kt", 70);
        setprop("/engines/engine[0]/running", 1);
    }
};

var autostart=func {
    setprop("/consumables/fuel/tank[2]/level-gal_us", 0.08);
    setprop("/controls/switches/battery", true);
    setprop("/controls/switches/alternator", false);
    setprop("/controls/switches/panel-lights", 0.5);
    setprop("/controls/fuel-selector", 0);
    setprop("/controls/key", 3);
}
