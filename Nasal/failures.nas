#     Piper PA-28-181
#   Non-random failures
###########################

var INIT=false;

var failure=nil;

var update_failures=func {
    
};

var parse_failures=func {
    
};

var init=func {
    set_start_conditions();
    if(!INIT) {
        INIT=true;
        parse_failures();
        settimer(update_failures, 0);
    }
};

setlistener("/sim/signals/fdm-initialized", init);
