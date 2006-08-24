# turn off hud in external views
setlistener("/sim/current-view/view-number", func { setprop("/sim/hud/visibility[1]", cmdarg().getValue() == 0) },1);