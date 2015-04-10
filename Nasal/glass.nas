#     Piper Archer
#    Glass effects
###########################

# ubody = forwards
# vbody = right
# wbody = down

var ubody_lowpass = aircraft.lowpass.new(10);
var vbody_lowpass = aircraft.lowpass.new(10);
var wbody_lowpass = aircraft.lowpass.new(10);

var window_temperature_lowpass = aircraft.lowpass.new(100);
var frost_lowpass              = aircraft.lowpass.new(100);
var fog_lowpass                = aircraft.lowpass.new(100);

var update_rain = func {

  ubody_lowpass.filter(getprop("/velocities/uBody-fps"));
  vbody_lowpass.filter(getprop("/velocities/vBody-fps"));
  wbody_lowpass.filter(getprop("/velocities/wBody-fps"));
  
  var ubody = squared(ubody_lowpass.get());
  var vbody = squared(vbody_lowpass.get());
  var wbody = squared(wbody_lowpass.get());

  var magnitude = math.sqrt(squared(ubody) + squared(vbody) + squared(wbody));

  var length = crange(0, magnitude, 40000, 0.2, 2);
  magnitude = magnitude / length;

  # x = forwards
  # y = left
  # z = up

  var splash_x =    -(ubody / magnitude) * 1.1;
  var splash_y =     (vbody / magnitude) * 0.05;
  var splash_z = max(-wbody / magnitude, 1.0);

  setprop("/environment/aircraft-effects/splash-vector-x", splash_x);
  setprop("/environment/aircraft-effects/splash-vector-y", splash_y);
  setprop("/environment/aircraft-effects/splash-vector-z", splash_z);

};

var update_frost = func {

  var window_temperature       = getprop("/environment/temperature-degc");

  window_temperature_lowpass.filter(window_temperature);
  var dewpoint_degc            = getprop("/environment/dewpoint-degc");

  var frost = crange(-5, -30, window_temperature_lowpass.get(), 0, 1);
  var fog   = crange(dewpoint_degc - 5, dewpoint_degc - 20, window_temperature_lowpass.get(), 0, 0.4);
  
  setprop("/environment/aircraft-effects/frost-level", frost_lowpass.filter(frost));
  setprop("/environment/aircraft-effects/fog-level",   fog_lowpass.filter(fog));
  setprop("/environment/aircraft-effects/window-temperature", window_temperature_lowpass.get());

};

var update_glass = func {
  
  if(getprop("/environment/rain-norm") > 0.05) {
    update_rain();
  }
  
  update_frost();
  
  settimer(update_glass, 0);
};
