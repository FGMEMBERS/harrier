#HARRIER AAR
# changes from default AAR script:
#   1) does the adding of the fuel since we are using yasim
#   2) does extra check to see if the harrier is carrying its AAR boom

# Properties under /consumables/fuel/tank[n]:
# + level-gal_us    - Current fuel load.  Can be set by user code.
# + level-lbs       - OUTPUT ONLY property, do not try to set
# + selected        - boolean indicating tank selection.
# + density-ppg     - Fuel density, in lbs/gallon.
# + capacity-gal_us - Tank capacity 
#
# Properties under /engines/engine[n]:
# + fuel-consumed-lbs - Output from the FDM, zeroed by this script
# + out-of-fuel       - boolean, set by this code.


# set constants
UPDATE_PERIOD = 0.3;
AAR_FUEL_GAL_PER_MIN = 600;

#variables
initialized = 0;
enabled = 0;

# print ("running harrier aar");
# print (" enabled " , enabled,  " initialized ", initialized);

updateTanker = func {
    # print ("tanker update running ");
    #if (!initialized ) {
    # print("calling initialize");
    # initialize();
    #}

    Refueling = props.globals.getNode("/systems/refuel/contact");
    AllAircraft = props.globals.getNode("ai/models").getChildren("aircraft");
    AllMultiplayer = props.globals.getNode("ai/models").getChildren("multiplayer");
    Aircraft = props.globals.getNode("ai/models/aircraft");

    #  select all tankers which are in contact. For now we assume that it must be in 
    #  contact with us.

    selectedTankers = [];

    if ( enabled ) { # check that AI Models are enabled, otherwise don't bother
        foreach(a; AllAircraft) {
            contact_node = a.getNode("refuel/contact");
            tanker_node = a.getNode("tanker");

            if (contact_node != nil and tanker_node != nil){
                contact = contact_node.getValue();
                tanker = tanker_node.getValue();

                if (tanker and contact) {
                    #print ("contact ", contact , " tanker " , tanker );
                    append(selectedTankers, a);
                }
            }
        }
        foreach(m; AllMultiplayer) {
            contact_node = m.getNode("refuel/contact");
            tanker_node = m.getNode("tanker");

            if (contact_node != nil and tanker_node != nil){
                contact = contact_node.getValue();
                tanker = tanker_node.getValue();

                if (tanker and contact) {
                   #print (" mp contact ", contact , " tanker " , tanker );
                   append(selectedTankers, m);
                }
            }
        }
    }

    #print ("tankers ", size(selectedTankers) );
    addFuel = func {
        fuelAmount = AAR_FUEL_GAL_PER_MIN / 60 * UPDATE_PERIOD;
        numDuds = 0;
        tanks = props.globals.getNode("consumables/fuel").getChildren("tank");
        foreach (w;tanks) {
            currentFuel = w.getNode("level-gal_us").getValue();
            capacity = w.getNode("capacity-gal_us").getValue();
            if (capacity < 2 or (currentFuel+fuelAmount)>capacity) {
                numDuds+=1;
            }
        }
        #print(size(tanks)-numDuds);
        addedFuel= fuelAmount / (size(tanks)-numDuds);
        foreach (w;tanks) {
            string="consumables/fuel/"~w.getName()~"["~w.getIndex()~"]/";
            currentFuel = w.getNode("level-gal_us").getValue();
            capacity = w.getNode("capacity-gal_us").getValue();
            if ((currentFuel + addedFuel)  < capacity) {
                setprop(string,"level-gal_us",currentFuel + addedFuel);
            }
        }
    }

    hasAARBoom = getprop("sim/weight[7]/selected") != "none";
    if ( size(selectedTankers) >= 1 and hasAARBoom){
        Refueling.setBoolValue(1);
        addFuel();
    } else {
        Refueling.setBoolValue(0);
    }

    settimer(updateTanker,UPDATE_PERIOD);
}




# Initalize: Make sure all needed properties are present and accounted
# for, and that they have sane default values.

initialize = func {

    AI_Enabled = props.globals.getNode("sim/ai/enabled");
    Refueling = props.globals.getNode("/systems/refuel/contact",1);

    Refueling.setBoolValue(0);
    enabled = AI_Enabled.getValue();

    initialized = 1;
}

registerTimer = func {
    settimer(arg[0],UPDATE_PERIOD);
} 

# Fire it up
if (!initialized) {initialize();}
settimer(updateTanker,10);
