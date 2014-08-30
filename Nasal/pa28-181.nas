#     Piper PA-28-181
#     Main Nasal file
###########################

var update=func {
    update_electrical();
    update_fuel();
    update_lighting();
    settimer(update, 0);
};

var reinit=func {
    init_scenario();
};

var init=func {
    init_scenario();

    init_electrical();

    settimer(update, 0);
};

setlistener("/sim/signals/reinit", reinit);
setlistener("/sim/signals/fdm-initialized", init);
