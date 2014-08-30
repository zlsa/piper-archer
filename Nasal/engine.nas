#     Piper PA-28-181
#       Engine file
###########################

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
    push=direction;

    var position = get_key();

    position=clamp(0, position + direction, 4);
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
}

var starter_changed=func {
    setprop("/controls/engines/engine[0]/starter", getprop("/electrical/outputs/starter/powered"));
};

setlistener("/electrical/outputs/starter/powered", starter_changed);
