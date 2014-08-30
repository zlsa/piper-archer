#     Piper PA-28-181
#    Performance tests
###########################

var tests={};

tests.climb={};
tests.climb.run_time=30; # 30 seconds

tests.climb.start=func {
    tests.climb.samples=[];
    settimer(tests.climb.sample,1);
    print("Started climb performance test");
};

tests.climb.sample=func {
    var altitude=getprop("/positions/altitude-ft");
    var speed=getprop("/velocities/airspeed-kt");
    append(tests.climb.samples,[altitude,speed]);
    if(size(tests.climb.samples) >= tests.climb.run_time)
        tests.climb.done();
    else
        settimer(tests.climb.sample,1);
};

tests.climb.done=func {
    var first_sample=tests.climb.samples[0];
    var last_sample=tests.climb.samples[size(tests.climb.samples)-1];
    var alt_gain=last_sample[0]-first_sample[0];
    var average_speed=last_sample[1]+first_sample[1]/2;
    var fpm=(60/tests.climb.run_time)*alt_gain;
    print(alt_gain~" feet over "~tests.climb.run_time~" seconds @ "~average_speed~"="~fpm);
    print("Stopped climb performance test");
};

tests.started=false;

var init=func {
    aircraft.teleport(airport="kmpi",runway=26,alt=2300,speed=74,glideslope=-2);
    setprop("/engines/engine[0]/rpm",2000);
    setprop("/controls/engines/engine[0]/throttle",1);
    setprop("/controls/engines/engine[0]/magnetos",3);
    tests.climb.start();
};

setlistener("/sim/signals/fdm-initialized",init);
