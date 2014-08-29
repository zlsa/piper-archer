# Piper PA-28-181 Archer LX
#    Electrical system
###########################

var true=1;
var false=0;

var trange=func(il,i,ih,ol,oh) {
    i=(i-il)/(ih-il);
    return((i*(oh-ol))+ol);
};

var clamp=func(il,i,ih) {
    if(il > ih) {
	var temp=il;
	il=ih;
	ih=temp;
    }
    if(i < il) {
	i=il;
    } else if(i > ih) {
	i=ih;
    }
    return(i);
}

var crange=func(il,i,ih,ol,oh) {
    i=trange(il,i,ih,ol,oh);
    i=clamp(ol,i,oh);
    return(i);
}

var config_path="/sim/systems/electrical";

var sources={};
var components={};
var buses={};

var source_props=props.globals.getNode(config_path).getChildren("source");
var component_props=props.globals.getNode(config_path).getChildren("components");
var bus_props=props.globals.getNode(config_path).getChildren("bus");

var update_elec=func {
#    var ts=1/getprop("/sim/fps");
    var ts=1/20;
    foreach(var i;keys(sources)) {
        var source=sources[i];
        var voltage=0;
        var power=0; # wattage
        source.draw=max(0,source.draw);
        if(source.type == "alternator") {
            voltage=crange(0,getprop(source.rpm_source),source.ideal_rpm,
                           0,source.nominal_voltage);
            power=crange(0,getprop(source.rpm_source),source.ideal_rpm,
                         0,source.power);
        } else if(source.type == "battery") {
            var deviation=source.nominal_voltage/3;
            source.charge-=source.draw*ts;
            source.charge=clamp(0,source.charge,1);
            voltage=crange(0,source.charge,1,
                           source.nominal_voltage-deviation,source.nominal_voltage+deviation);
            voltage-=crange(0,source.draw,source.capacity);
        } else if(source.type == "bus") {
            var bus=buses[i];
            voltage=bus.voltage;
        }
        source.draw=0;
        source.voltage=voltage;
        source.power=power;
    }

    foreach(var i;keys(buses)) {
        var bus=buses[i];
        var voltage=0;
        var max_power=0;
        var battery_power=0;
        foreach(var input;bus.inputs) {
            var source=sources[input];
            voltage=max(voltage,source.voltage);
            source.draw+=bus.draw/size(bus.inputs);
            max_power+=source.power;
            if(source.type == "battery")
                battery_power+=source.power;
            source.power-=bus.draw/size(bus.inputs);
        }
        bus.powered=1;
        if(!getprop(bus.switch) or bus.switch == -1) {
            voltage=0;
            bus.powered=0;
        }
        bus.draw=0;
        var battery_number=0;
        foreach(var output;bus.outputs) {
            var component=components[output];
            if(component.type == "battery") {
                battery_number+=1;
                continue;
            }
            component.voltage=voltage;
            if(voltage > component.min_voltage) {
                bus.draw+=getprop(component.draw);
                component.voltage=voltage;
            } else {
                component.voltage=0;
            }
        }
        var power_remaining=max_power-bus.draw-battery_power;
        if(power_remaining > 0) {
            foreach(var output;bus.outputs) {
                var component=components[output];
                if(component.type == "battery") {
                    var battery=sources[output];
                    if(voltage > battery.voltage) {
                        battery.draw-=power_remaining/battery_number;
                    }
                }
            }
        }
        bus.voltage=voltage;
    }

    foreach(var i;keys(sources)) {
        var source=sources[i];
        setprop(component.output_prop~"/voltage",source.voltage);
        setprop(component.output_prop~"/current",source.current);
        var charge=0;
        if(source.type == "battery")
            charge=source.charge;
        setprop(component.output_prop~"/charge",charge);
    }

    foreach(var i;keys(components)) {
        if(component.type == "bus") {
            buses[i].voltage=component.voltage;
            buses[i].powered=component.powered;
        }
        var component=components[i];
        setprop(component.output_prop~"/voltage",component.voltage);
        var powered=0;
        if(component.voltage != 0)
            component.powered=1;
        setprop(component.output_prop~"/powered",powered);
    }
    
    settimer(update_elec,0);
};

var init_elec=func {
    print("Electrical init...");

    for(var i=0;i<size(component_props);i+=1) {
        var c=component_props[i];
        var component={};
        if(c.getNode("name") == nil) {
            print("! Expected name of component ",i);
            continue;
        }
        component.name=c.getNode("name").getValue();
        if(contains(components,name)) {
            print("! Duplicate component '"~name~"'");
            continue;
        }
        if(c.getNode("current") == nil) {
            print("! Expected current draw of component ",name);
            continue;
        }
        component.current=c.getNode("current").getValue();
        if(c.getNode("min-voltage") == nil) {
            print("! Expected minimum voltage of component ",name);
            continue;
        }
        if(c.getNode("prop") == nil) {
            print("! Expected destination property root of component ",name);
            continue;
        }
        component.prop=c.getNode("prop").getValue();
        component.powered=0;
        component.voltage=0;
        components[component.name]=component;
    }

    for(var i=0;i<size(source_props);i+=1) {
        var c=source_props[i];
        var source={};
        if(c.getNode("name") == nil) {
            print("! Expected name of source ",i);
            continue;
        }
        source.name=c.getNode("name").getValue();
        if(contains(sources,name)) {
            print("! Duplicate source '"~name~"'");
            continue;
        }
        if(c.getNode("type") == nil) {
            print("! Expected type of source ",name);
            continue;
        }
        source.type=c.getNode("type").getValue();
        if(c.getNode("prop") == nil) {
            print("! Expected destination property root of source ",name);
            continue;
        }
        source.prop=c.getNode("prop").getValue();
        if(source.type != "battery" and
           source.type != "alternator") {
            print("! Expected valid type of source ",name);
            continue;
        }
        if(source.type == "battery") {
            if(c.getNode("capacity") == nil) {
                print("! Expected capacity (aH) of battery ",name);
                continue;
            }
            if(c.getNode("voltage") == nil) {
                print("! Expected voltage of battery ",name);
                continue;
            }
            if(c.getNode("charge") != nil) {
                source.charge=c.getNode("charge").getValue();
            } else {
                source.charge=0.8;
            }
            source.capacity=c.getNode("capacity").getValue();
            source.nominal_voltage=c.getNode("voltage").getValue();
            components[source.name]={
              name:source.name,
              type:"battery",
              min_voltage:-1,
              current:-1,
              voltage:0,
            };
        } else if(source.type == "alternator") {
            if(c.getNode("power") == nil) {
                print("! Expected power (W) of alternator ",i);
                continue;
            }
            if(c.getNode("rpm-source") == nil) {
                print("! Expected RPM source of alternator ",i);
                continue;
            }
            if(c.getNode("ideal-rpm") == nil) {
                print("! Expected best RPM of alternator ",i);
                continue;
            }
            if(c.getNode("voltage") == nil) {
                print("! Expected voltage of alternator ",i);
                continue;
            }
            source.power=c.getNode("power").getIntValue();
            source.nominal_voltage=c.getNode("voltage").getValue();
            source.voltage=0;
            source.rpm_source=c.getNode("rpm-source").getValue();
            source.ideal_rpm=c.getNode("ideal-rpm").getValue();
        }
        sources[source.name]=source;
    }
    
    for(var i=0;i<size(bus_props);i+=1) {
        var c=bus_props[i];
        var bus={};
        if(c.getNode("name") == nil) {
            print("! Expected name of bus ",i);
            continue;
        }
        bus.name=c.getNode("name").getValue();
        if(contains(buses,name)) {
            print("! Duplicate bus '"~name~"'");
            continue;
        }
        # if(c.getNode("type") == nil) {
        #     print("! Expected type of bus ",name);
        #     continue;
        # }
        # bus.type=c.getNode("type").getValue();
        # if(bus.type != "toggle-power" && # needed to toggle power; gear for example
        #    bus.type != "needs-power") {  # drops to 0 if no power
        #     print("! Expected valid type of bus ",name);
        #     continue;
        # }
        if(c.getNode("switch") == nil) {
            bus.switch=-1;
        } else {
            bus.switch=c.getNode("switch").getValue();
        }
        if(size(c.getChildren("input")) == 0) {
            print("! Expected at least one input for bus ",name);
            continue;
        }
        var inputs=c.getChildren("input");
        bus.inputs=[];
        for(var j=0;j<size(inputs);j+=1) {
            append(bus.inputs,inputs[j].getValue());
        }
        var outputs=c.getChildren("output");
        bus.outputs=[];
        for(var j=0;j<size(outputs);j+=1) {
            append(bus.outputs,outputs[j].getValue());
        }
        bus.voltage=0;
        bus.powered=0;
        buses[bus.name]=bus;
        sources[bus.name]={
          name:bus.name,
          type:"bus"
        };
    }
    
    print("Electrical init done");

    settimer(update_elec,0);
};

init_elec();
