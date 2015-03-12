#      Piper Archer
#       Engine file
###########################

var oil_pressure_lowpass=aircraft.lowpass.new(0.5);

var push=0;

var get_key=func {
  var position=getprop("/controls/key");
  return position;
  if(position == 0)      return "off";
  else if(position == 1) return "left";
  else if(position == 2) return "right";
  else if(position == 3) return "both";
  else if(position >= 4) return "start";
};

var key=func(direction) {
  var push = direction;

  var position = get_key();

  position = clamp(0, position + direction, 4);
  setprop("/controls/key", position);

  if(push == 1 and position == 4) {
    start(1);
  } else if(push == 0 and position == 4) {
    key(-1);
    start(0);
  }
  
  setprop("/controls/engines/engine[0]/magnetos", clamp(0, position, 3));

};

var start=func(mode) {
  if(mode == 1) {
    setprop("/controls/start", 1);
  } else {
    setprop("/controls/start", 0);
  }
};

var starter_changed = func {
  setprop("/controls/engines/engine[0]/starter", getprop("/electrical/outputs/starter/powered"));
};

var update_engine = func {
  oil_pressure_lowpass.filter(crange(600, getprop("/engines/engine[0]/rpm"), 2700, 30, 75));
  setprop("/engines/engine[0]/oil-pressure", oil_pressure_lowpass.get());
};

setlistener("/electrical/outputs/starter/powered", starter_changed);
