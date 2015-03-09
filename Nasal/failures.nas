#      Piper Archer
#   Non-random failures
###########################

var INIT=false;

var failure=nil;
var fail_agl=0;

var fail_engine = func(fail) {
    return;
    if(fail)
        setprop("/controls/engines/engine[0]/magnetos", 0);
    else
        setprop("/controls/engines/engine[0]/magnetos", 3);
};

var update_failures=func {
    if(getprop("/position/altitude-agl-ft") > fail_agl) {
        fail_engine(true);
    }
    settimer(update_failures, 0);
};

var setup=func {
    fail_agl = crange(0, rand(), 1, 300, 1500);
}

var init=func {
    fail_engine(false);
    setup();
    if(!INIT) {
        INIT=true;
        settimer(update_failures, 0);
    }
};

setlistener("/sim/signals/fdm-initialized", init);
