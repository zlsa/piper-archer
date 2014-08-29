# Piper PA-28-181 Archer TX
#    Electrical system
###########################

var config_path="/sim/systems/electrical";

var devices={};

var source_props=props.globals.getNode(config_path).getChildren("source");
var component_props=props.globals.getNode(config_path).getChildren("component");

var update_elec=func {
    foreach(var i;keys(devices)) {
        var device=devices[i];
        var role = device.role;

        var switch=true;
        if(device.switch) {
            if(getprop(device.switch) == false) switch=false;
        }

        if(role == "source") {
            var voltage = 0;
            var type = device.type;

            device.draw = 0; # watts being pulled out of the device

            if(type == "alternator") {
                var rpm   = getprop(device.rpm_source);
                var power = crange(device.min_rpm, rpm, device.max_rpm, 0, device.power);

                if(switch == false) power=0;

                if(power > 0) voltage = device.max_voltage;

                setprop(device.prop, "power", power);
            } else if(type == "battery") {

                voltage = crange(0, device.charge, 1, device.empty_voltage, device.full_voltage);

                if(switch == false) voltage=0;

                device.voltage = voltage;

                setprop(device.prop, "charge", device.charge);
            } else {
                power=42;
            }

            setprop(device.prop, "voltage", voltage);
            setprop(device.prop, "switch", switch);
        }
    }

    foreach(var i;keys(devices)) {
        var device=devices[i];
        var role = device.role;

        var switch=true;
        if(device.switch) {
            if(getprop(device.switch) == false) switch=false;
        }

        if(role == "component") {
            device.powered=false;
            for(var j=0;j<size(device.inputs);j+=1) {
                var input_device=devices[device.inputs[j].getValue()];
                if(input_device.voltage > device.min_voltage) {
                    device.voltage=max(input_device.voltage, device.voltage); # choose the highest voltage device
                }
            }
            if(switch == false) device.voltage=0;
            if(device.voltage > 0) device.powered=true;
            setprop(device.prop, "voltage", device.voltage);
            setprop(device.prop, "powered", device.powered);
            setprop(device.prop, "switch", switch);
        }
    }
    
    settimer(update_elec, 0);
};

var init_elec=func {
    print("Electrical init...");

    for(var i=0;i<size(source_props);i+=1) {
        var source=source_props[i];
        var device={};
        device.role = "source";

        if(source.getNode("name") == nil) {
            print("! Expected name of source ", i);
            continue;
        }
        device.name = source.getNode("name").getValue();

        device.inputs = source.getChildren("input");
        device.outputs = source.getChildren("output");

        if(contains(devices, device.name)) {
            print("! Duplicate device '" ~ device.name ~ "'");
            continue;
        }

        if(source.getNode("prop") == nil) {
            print("! Expected destination property root for source '" ~ device.name ~ "'");
            continue;
        }
        device.prop=source.getNode("prop").getValue();
        props.globals.initNode(device.prop);

        if(source.getNode("switch") == nil) {
            device.switch=nil;
        } else {
            device.switch=source.getNode("switch").getValue();
        }

        if(source.getNode("type") == nil) {
            print("! Expected type of source '" ~ device.name ~ "'");
            continue;
        }
        device.type = source.getNode("type").getValue();

        if(device.type == "battery") {
            if(source.getNode("capacity") == nil) {
                print("! Expected amp-hour capacity of battery source '" ~ device.name ~ "'");
                continue;
            }
            device.capacity = source.getNode("capacity").getValue();

            if(source.getNode("empty-voltage") == nil) {
                print("! Expected empty voltage of battery source '" ~ device.name ~ "'");
                continue;
            }
            device.empty_voltage = source.getNode("empty-voltage").getValue();

            if(source.getNode("full-voltage") == nil) {
                print("! Expected full voltage of battery source '" ~ device.name ~ "'");
                continue;
            }
            device.full_voltage = source.getNode("full-voltage").getValue();

            device.charge = 1;

            props.globals.getNode(device.prop).initNode("charge", 0, "DOUBLE");
            
        } else if(device.type == "alternator") {
            if(source.getNode("voltage") == nil) {
                print("! Expected nominal voltage of source '" ~ device.name ~ "'");
                continue;
            }
            device.max_voltage = source.getNode("voltage").getValue();
            if(source.getNode("rpm-source") == nil) {
                print("! Expected RPM source property name for alternator source '" ~ device.name ~ "'");
                continue;
            }
            device.rpm_source = source.getNode("rpm-source").getValue();

            if(source.getNode("min-rpm") == nil) {
                print("! Expected minimum RPM of alternator source '" ~ device.name ~ "'");
                continue;
            }
            device.min_rpm = source.getNode("min-rpm").getValue();

            if(source.getNode("max-rpm") == nil) {
                print("! Expected maximum RPM of alternator source '" ~ device.name ~ "'");
                continue;
            }
            device.max_rpm = source.getNode("max-rpm").getValue();

            if(source.getNode("power") == nil) {
                print("! Expected wattage of alternator source '" ~ device.name ~ "'");
                continue;
            }
            device.power = source.getNode("power").getValue();

            props.globals.getNode(device.prop).initNode("power", 0);

        }

        props.globals.getNode(device.prop).initNode("switch", 0, "BOOL");
        props.globals.getNode(device.prop).initNode("voltage", 0);

        device.powered=0;
        device.voltage=0;
        devices[device.name]=device;
    }

    ##############
    # COMPONENTS
    ##############

    for(var i=0;i<size(component_props);i+=1) {
        var component=component_props[i];
        var device={};
        device.role = "component";

        if(component.getNode("name") == nil) {
            print("! Expected name of component ", i);
            continue;
        }
        device.name = component.getNode("name").getValue();

        device.inputs = component.getChildren("input");
        device.outputs = component.getChildren("output");

        if(contains(devices, device.name)) {
            print("! Duplicate device '" ~ device.name ~ "'");
            continue;
        }

        if(component.getNode("prop") == nil) {
            print("! Expected destination property root for device '" ~ device.name ~ "'");
            continue;
        }
        device.prop=component.getNode("prop").getValue();
        props.globals.initNode(device.prop);

        if(component.getNode("switch") == nil) {
            device.switch=nil;
        } else {
            device.switch=component.getNode("switch").getValue();
        }

        if(component.getNode("type") == nil) {
            print("! Expected type of device '" ~ device.name ~ "'");
            continue;
        }
        device.type = component.getNode("type").getValue();

        if(component.getNode("min-voltage") == nil) {
            print("! Expected minimum voltage of device '" ~ device.name ~ "'");
            continue;
        }
        device.min_voltage = component.getNode("min-voltage").getValue();

        props.globals.getNode(device.prop).initNode("powered", 0, "BOOL");
        props.globals.getNode(device.prop).initNode("switch", 0, "BOOL");
        props.globals.getNode(device.prop).initNode("voltage", 0);

        device.powered=false;
        device.voltage=0;
        devices[device.name]=device;
    }

    print("Electrical init done");

    settimer(update_elec, 0);
};

init_elec();
