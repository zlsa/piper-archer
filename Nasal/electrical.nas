#      Piper Archer
#    Electrical system
###########################

var config_path="/sim/systems/electrical";

var devices={};

var source_props=props.globals.getNode(config_path).getChildren("source");
var component_props=props.globals.getNode(config_path).getChildren("component");
var switch_props=props.globals.getNode(config_path).getChildren("switch");

var update_electrical=func {

  var delta=1/30;

  foreach(var i;keys(devices)) {
    var device=devices[i];
    var role = device.role;

    var switch=true;
    if(device.switch != nil) {
      switch=getprop(device.switch);
    }

    if(role == "source" or role == "switch") {
      device.draw = 0;
    }

    if(role == "source") {
      var voltage = 0;
      var type = device.type;

      if(type == "alternator") {
        var rpm   = getprop(device.rpm_source, "rpm");
        var power = crange(device.min_rpm, rpm, device.max_rpm, 0, device.power);

        if(switch == false) power=0;

        voltage = crange(0, power, device.power/4, device.min_voltage, device.max_voltage);

        if(power < 0.01) voltage=0;

        setprop(device.prop, "power", power);
      } else if(type == "battery") {

        for(var j=0;j<size(device.inputs);j+=1) {
          var input_device=devices[device.inputs[j].getValue()];
          if(input_device.role == "source" and input_device.type == "alternator") {
            if(input_device.voltage > device.voltage_lowpass.get() and switch) {
              device.charge += (input_device.power / device.capacity) * delta;
              device.charge = min(device.charge, 1);
            }
          }
        }

        voltage = crange(0, device.charge, 1, device.empty_voltage, device.full_voltage);

        if(switch == false) voltage=0;

        setprop(device.prop, "charge", device.charge);
      } else {
        power=42;
      }

      device.voltage = voltage;

      setprop(device.prop, "switch", switch);
    }
  }

  foreach(var i;keys(devices)) {
    var device=devices[i];
    var role = device.role;

    if(role == "switch") {
      var switch=true;

      if(device.switch != nil) {
        switch=getprop(device.switch);
      }

      device.voltage = 0;
      if(switch == false) {
        device.draw=0;
      } else {
        for(var j=0;j<size(device.inputs);j+=1) {
          var input_device=devices[device.inputs[j].getValue()];
          var voltage=input_device.voltage;
          if(input_device.role == "source" and input_device.type == "battery")
            voltage=input_device.voltage_lowpass.get();
          if(voltage > device.voltage) {
            device.voltage=max(voltage, device.voltage); # choose the highest voltage device
          }
        }
      }

      if(device.voltage > 0) device.powered=0;

    }
  }

  foreach(var i;keys(devices)) {
    var device=devices[i];
    var role = device.role;

    if(role == "component") {
      var switch=true;

      if(device.switch != nil) {
        switch=getprop(device.switch);
      }

      device.draw=0;
      device.voltage=0;
      for(var j=0;j<size(device.inputs);j+=1) {
        var input_device=devices[device.inputs[j].getValue()];
        var voltage=input_device.voltage_lowpass.get();
        if(voltage > device.min_voltage) {
          device.voltage=max(voltage, device.voltage); # choose the highest voltage device
        }
      }

      if(device.voltage > 0.01) {
        device.voltage = crange(0, switch, 1, device.min_voltage, device.voltage);
      }
      
      if(switch < 0.01) device.voltage=0;

      device.powered=false;

      if(device.voltage > 0.1) {
        device.powered=true;
        device.draw=crange(device.min_voltage, device.voltage, device.nominal_voltage, 0, device.power);
      }

      for(var j=0;j<size(device.inputs);j+=1) {
        devices[device.inputs[j].getValue()].draw += device.draw;
      }

      if(device.output) {
        setprop(device.output, device.powered);
      }

      setprop(device.prop, "voltage", device.voltage);
      setprop(device.prop, "powered", device.powered);
      setprop(device.prop, "draw", device.draw);
      setprop(device.prop, "switch", switch);
    }
  }

  foreach(var i;keys(devices)) {
    var device=devices[i];
    var role = device.role;

    if(role == "switch") {
      var switch=true;

      if(device.switch != nil) {
        if(getprop(device.switch) == false) switch=false;
      }

      device.voltage = 0;

      if(switch == false) {
        device.draw=0;
      } else {
        for(var j=0;j<size(device.inputs);j+=1) {
          var input_device=devices[device.inputs[j].getValue()];
          var voltage=input_device.voltage_lowpass.get();
          if(input_device.voltage > device.voltage) {
            device.voltage=max(voltage, device.voltage); # choose the highest voltage
            devices[device.inputs[j].getValue()].draw += device.draw * 1.1 + 1;
            continue;
          }
        }
      }

      if(device.voltage > 0) device.powered=0;

      device.voltage_lowpass.filter(device.voltage);

      setprop(device.prop, "voltage", device.voltage_lowpass.get());
      setprop(device.prop, "powered", device.powered);
      setprop(device.prop, "draw", device.draw);
      setprop(device.prop, "switch", switch);
    }
  }

  foreach(var i;keys(devices)) {
    var device=devices[i];
    var role = device.role;

    var switch=1;
    if(device.switch) {
      switch=getprop(device.switch);
    }

    if(role == "source") {
      var voltage = 0;
      var type = device.type;

      if(type == "alternator") {
        voltage = crange(0, device.draw, device.power, device.voltage, 0);
        device.voltage = voltage;

        setprop(device.prop, "draw", device.draw);
      } else if(type == "battery") {

        voltage = crange(0, device.draw, device.power, device.voltage, device.voltage-device.drop);
        device.voltage = voltage;

        var draw = device.draw * delta;
        draw /= device.capacity;
        device.charge -= draw;
        
        setprop(device.prop, "draw", device.draw);
      }

      if(switch <= false) device.voltage=0;

      device.voltage_lowpass.filter(device.voltage);

      setprop(device.prop, "voltage", device.voltage_lowpass.get());
      setprop(device.prop, "real-voltage", device.voltage);
    }
  }

};

var init_electrical=func {

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
        print("! Expected watt-second capacity of battery source '" ~ device.name ~ "'");
        continue;
      }
      device.capacity = source.getNode("capacity").getValue();

      if(source.getNode("power") == nil) {
        print("! Expected maximum draw in watts of battery source '" ~ device.name ~ "'");
        continue;
      }
      device.power = source.getNode("power").getValue();

      if(source.getNode("drop") == nil) {
        print("! Expected voltage drop with maximum draw in watts of battery source '" ~ device.name ~ "'");
        continue;
      }
      device.drop = source.getNode("drop").getValue();

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

      if(source.getNode("charge") == nil) {
        device.charge = 1;
      } else {
        device.charge = source.getNode("charge").getValue();
      }

      props.globals.getNode(device.prop).initNode("charge", 0, "DOUBLE");
      
    } else if(device.type == "alternator") {
      if(source.getNode("max-voltage") == nil) {
        print("! Expected 25% RPM voltage of source '" ~ device.name ~ "'");
        continue;
      }
      device.max_voltage = source.getNode("max-voltage").getValue();

      if(source.getNode("min-voltage") == nil) {
        print("! Expected nominal min-voltage of source '" ~ device.name ~ "'");
        continue;
      }
      device.min_voltage = source.getNode("min-voltage").getValue();

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

    device.voltage_lowpass = aircraft.lowpass.new(0.1);
    device.voltage_lowpass.set(0);

    props.globals.getNode(device.prop).initNode("switch", 0);
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

    if(component.getNode("output") == nil) {
      device.output=nil;
    } else {
      device.output=component.getNode("output").getValue();
    }

    if(component.getNode("type") == nil) {
      print("! Expected type of device '" ~ device.name ~ "'");
      continue;
    }
    device.type = component.getNode("type").getValue();

    if(component.getNode("power") == nil) {
      print("! Expected maximum power draw of component '" ~ device.name ~ "'");
      continue;
    }
    device.power = component.getNode("power").getValue();

    if(component.getNode("min-voltage") == nil) {
      print("! Expected minimum voltage of device '" ~ device.name ~ "'");
      continue;
    }
    device.min_voltage = component.getNode("min-voltage").getValue();

    if(component.getNode("nominal-voltage") == nil) {
      print("! Expected nominal voltage of device '" ~ device.name ~ "'");
      continue;
    }
    device.nominal_voltage = component.getNode("nominal-voltage").getValue();

    props.globals.getNode(device.prop).initNode("powered", 0, "BOOL");
    props.globals.getNode(device.prop).initNode("switch", 0);
    props.globals.getNode(device.prop).initNode("voltage", 0);

    device.powered=false;
    device.voltage=0;

    device.voltage_lowpass = aircraft.lowpass.new(0.1);
    device.voltage_lowpass.set(0);

    devices[device.name]=device;
  }

##############
# SWITCHES
##############

  for(var i=0;i<size(switch_props);i+=1) {
    var switch=switch_props[i];
    var device={};
    device.role = "switch";

    if(switch.getNode("name") == nil) {
      print("! Expected name of switch ", i);
      continue;
    }
    device.name = switch.getNode("name").getValue();

    device.inputs = switch.getChildren("input");

    if(contains(devices, device.name)) {
      print("! Duplicate device '" ~ device.name ~ "'");
      continue;
    }

    if(switch.getNode("prop") == nil) {
      print("! Expected destination property root for device '" ~ device.name ~ "'");
      continue;
    }
    device.prop=switch.getNode("prop").getValue();
    props.globals.initNode(device.prop);

    if(switch.getNode("switch") == nil) {
      device.switch=nil;
    } else {
      device.switch=switch.getNode("switch").getValue();
    }

# if(switch.getNode("type") == nil) {
#     print("! Expected type of switch '" ~ device.name ~ "'");
#     continue;
# }
# device.type = switch.getNode("type").getValue();

    props.globals.getNode(device.prop).initNode("powered", 0, "BOOL");
    props.globals.getNode(device.prop).initNode("switch", 0, "BOOL");
    props.globals.getNode(device.prop).initNode("voltage", 0);

    device.powered=false;
    device.voltage=0;

    device.voltage_lowpass = aircraft.lowpass.new(0.1);
    device.voltage_lowpass.set(0);

    devices[device.name]=device;
  }

  print("Piper Archer electrical system initialized");
};

