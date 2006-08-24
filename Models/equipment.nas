dialog = nil;

showDialog = func {
	name = "equipment-config";
	if (dialog != nil) {
		fgcommand("dialog-close", props.Node.new({ "dialog-name" : name }));
		dialog = nil;
		return;
	}

	dialog = gui.Widget.new();
	dialog.set("layout", "vbox");
	dialog.set("name", name);
	dialog.set("x", 40);
	dialog.set("y", 40);
	dialog.set("width", 550);
	dialog.set("height", 300);

	# "window" titlebar
	titlebar = dialog.addChild("group");
	titlebar.set("layout", "hbox");
	titlebar.addChild("empty").set("stretch", 1);
	titlebar.addChild("text").set("label", "Equipment Selection");
	titlebar.addChild("empty").set("stretch", 1);
	dialog.addChild("hrule").addChild("dummy");

	w = titlebar.addChild("button");
	w.set("pref-width", 16);
	w.set("pref-height", 16);
	w.set("legend", "");
	w.set("default", 1);
	w.set("keynum", 27);
	w.set("border", 1);
	w.prop().getNode("binding[0]/command", 1).setValue("nasal");
	w.prop().getNode("binding[0]/script", 1).setValue("equipment.dialog = nil");
	w.prop().getNode("binding[1]/command", 1).setValue("dialog-close");

	combo = func {
		group = dialog.addChild("group");
		group.set("layout", "hbox");

		label = group.addChild("text");
		label.set("label",arg[0]);
		label.set("halign","left");

		box = group.addChild("combo");
		box.set("pref-width",300);
		box.set("halign","right");

		i=0;
		foreach(choice;arg[1]) {
			box.set("value["~i~"]",choice);
			i+=1;
		}
		label;
		box;
	}

	checkbox = func {
		group = dialog.addChild("group");
		group.set("layout", "hbox");
		group.addChild("empty").set("pref-width", 4);
		box = group.addChild("checkbox");
		group.addChild("empty").set("stretch", 1);

		box.set("halign", "left");
		box.set("label", arg[0]);
		box;
	}

	# Pylon 1 and 5 
	w = combo("Pylons 1 and 5 (wingtips)",["none",
						"Sidewinder AAM"]);
	w.set("property", "systems/equipment/Pylon1/reset");
	w.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");

	# Pylon 2 and 4 
	w = combo("Pylons 2 and 4 (wingroots)",["none",
						"External Fuel Tanks",
						"606lb Paveway II Laser Guided Bombs",
						"Sidewinder AAM",
						"ALARM Anti-radar",
						"AIM-120 AMRAAM"]);
	w.set("property[0]", "systems/equipment/Pylon2/reset");
	w.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");

	# Pylon 3
	w = combo("Pylon 3 (fuselage)",["none",
					"1092lb Paveway II Laser Guided Bomb",
					"Sea Eagle AShM"]);

	w.set("property", "systems/equipment/Pylon3/reset");
	w.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");

	# Gun PODS
	w = combo("Gun PODS",["none",
				"ADEN Cannons",
				"AIM-120 AMRAAM"]);
        w.set("property", "systems/equipment/GunPod1/reset");
	w.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");

	dialog.addChild("hrule").addChild("dummy");

	# AAR BOOM
	w = checkbox("In-flight Refuel Boom");
	w.set("property", "systems/equipment/AARBoom");
	w.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");	

	dialog.addChild("hrule").addChild("dummy");

	w = dialog.addChild("group");
	w.set("layout", "vbox");
	txt = w.addChild("text");
	txt.set("halign","left");
        txt.set("label", "0123456789");
        txt.set("format", "Gross Aircraft Weight: %.0f lb");
        txt.set("property", "yasim/gross-weight-lbs");
        txt.set("live", 1);
	
	txt=w.addChild("text");
	txt.set("halign","left");
	txt.set("label","Maximum *Horizontal* Takeoff Weight: 26,500 lb");
	txt=w.addChild("text");
	txt.set("halign","left");
	txt.set("label","Maximum *Vertical* Takeoff/Landing Weight: 20,500 lb");

	# finale
	dialog.addChild("empty").set("pref-width", 4);
	fgcommand("dialog-new", dialog.prop());
	gui.showDialog(name);
}

getWeight = func {
	if (arg[0] == "Sidewinder AAM") {return 155.2};
	if (arg[0] == "606lb Paveway II Laser Guided Bombs") {return 606};
	if (arg[0] == "ALARM Anti-radar") {return 590};
	if (arg[0] == "1092lb Paveway II Laser Guided Bomb") {return 1092};
	if (arg[0] == "Sea Eagle AShM") {return 1323};
	if (arg[0] == "ADEN Cannons") {return 87};
	if (arg[0] == "AIM-120 AMRAAM") {return 335};
	return 0.00; #either 'none' or 'external fuel tanks' because fuel weight is done automatically
}

newEquipment15 = func {
	newObject = cmdarg().getValue();
	weight = getWeight(newObject);
	setprop("systems/equipment/Pylon1/object",newObject);
	setprop("systems/equipment/Pylon5/object",newObject);
	setprop("systems/equipment/Pylon1/weight-lbs",weight);
	setprop("systems/equipment/Pylon5/weight-lbs",weight);
}
newEquipment24 = func {
	newObject = cmdarg().getValue();
	weight = getWeight(newObject);
	wasExternal = (getprop("systems/equipment/Pylon2/object")=="External Fuel Tanks");

	setprop("systems/equipment/Pylon2/object",newObject);
	setprop("systems/equipment/Pylon4/object",newObject);
	setprop("systems/equipment/Pylon2/weight-lbs",weight);
	setprop("systems/equipment/Pylon4/weight-lbs",weight);

	if(newObject == "External Fuel Tanks"){
		addTanks();
	}
	if(wasExternal) {
		killTanks();
	}
}
newEquipment3 = func {
	newObject = cmdarg().getValue();
	weight = getWeight(newObject);
	setprop("systems/equipment/Pylon3/object",newObject);
	setprop("systems/equipment/Pylon3/weight-lbs",weight);
}
newEquipmentGP = func {
	newObject = cmdarg().getValue();
	weight = getWeight(newObject);
	setprop("systems/equipment/GunPod1/object",newObject);
	setprop("systems/equipment/GunPod2/object",newObject);
	setprop("systems/equipment/GunPod1/weight-lbs",weight);
	setprop("systems/equipment/GunPod2/weight-lbs",weight);
}


addTanks = func {
	delayedRefill = func {
		#half tank so that vertical takeoff/landing is possible 
		setprop("consumables/fuel/tank[1]/level-gal_us",194);
		setprop("consumables/fuel/tank[2]/level-gal_us",194);
		setprop("consumables/fuel/tank[1]/capacity-gal_us",387.95);
		setprop("consumables/fuel/tank[2]/capacity-gal_us",387.95);
	}
	setprop("consumables/fuel/tank[1]/selected",1);
	setprop("consumables/fuel/tank[2]/selected",1);
	settimer(delayedRefill, 2.0);
}
killTanks = func {
	delayedCapacity = func {
		setprop("consumables/fuel/tank[1]/capacity-gal_us",0.01);
		setprop("consumables/fuel/tank[2]/capacity-gal_us",0.01);
	}
	setprop("consumables/fuel/tank[1]/level-gal_us",0.00);
	setprop("consumables/fuel/tank[2]/level-gal_us",0.00);
	settimer(delayedCapacity, 2.0);
}

settimer(setlistener("systems/equipment/Pylon1/reset", newEquipment15), 0);
settimer(setlistener("systems/equipment/Pylon2/reset", newEquipment24), 0);
settimer(setlistener("systems/equipment/Pylon3/reset", newEquipment3), 0);
settimer(setlistener("systems/equipment/GunPod1/reset", newEquipmentGP), 0);