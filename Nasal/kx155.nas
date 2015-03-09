#      Piper Archer
#       KX155 logic
###########################

var INIT=false;

var update = func(prop) {
    var root = props.globals.getNode("instrumentation").getNode(prop);

    var selected = sprintf("%0.3f", root.getNode("frequencies/selected-mhz").getValue());
    var standby  = sprintf("%0.3f", root.getNode("frequencies/standby-mhz").getValue());

#    print(selected);
#    print(standby);

    root.setValue("display/digit-00", substr(selected, 0, 1));
    root.setValue("display/digit-01", substr(selected, 1, 1));
    root.setValue("display/digit-02", substr(selected, 2, 1));
    root.setValue("display/digit-03", substr(selected, 4, 1));
    root.setValue("display/digit-04", substr(selected, 5, 1));
    root.setValue("display/digit-05", substr(selected, 6, 1));

    root.setValue("display/digit-10", substr(standby, 0, 1));
    root.setValue("display/digit-11", substr(standby, 1, 1));
    root.setValue("display/digit-12", substr(standby, 2, 1));
    root.setValue("display/digit-13", substr(standby, 4, 1));
    root.setValue("display/digit-14", substr(standby, 5, 1));
    root.setValue("display/digit-15", substr(standby, 6, 1));
};

var update_comm_0 = func {
    update("comm[0]");
};

var update_nav_0 = func {
    update("nav[0]");
};

var update_comm_1 = func {
    update("comm[1]");
};

var update_nav_1 = func {
    update("nav[1]");
};

setlistener("instrumentation/comm[0]/frequencies/selected-mhz", update_comm_0);
setlistener("instrumentation/comm[0]/frequencies/standby-mhz",  update_comm_0);

setlistener("instrumentation/nav[0]/frequencies/selected-mhz", update_nav_0);
setlistener("instrumentation/nav[0]/frequencies/standby-mhz",  update_nav_0);

setlistener("instrumentation/comm[1]/frequencies/selected-mhz", update_comm_1);
setlistener("instrumentation/comm[1]/frequencies/standby-mhz",  update_comm_1);

setlistener("instrumentation/nav[1]/frequencies/selected-mhz", update_nav_1);
setlistener("instrumentation/nav[1]/frequencies/standby-mhz",  update_nav_1);

setlistener("/sim/signals/fdm-initialized", func {
    update_comm_0();
    update_comm_1();
    update_nav_0();
    update_nav_1();
            });
