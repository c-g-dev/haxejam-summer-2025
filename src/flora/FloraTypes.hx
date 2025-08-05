package flora;

typedef SeedType = {};
typedef PlantUpgrade = {};
typedef OnDayAdvance = Void -> Void;

new FloraType("Sunflower", 
    new SeedType(Common, 1),
    new Environmental([Temp(3, 12), Water(3, 15), Soil(-1)])
    [
        Upgrade("Mammoth Sunflower", [Nitrogen(10)]);
    ],
    new OnDayAdvance((ctx) -> {
        if(ctx.day){
            addResource(Helios, 3);
        }
    });
);

//increase power/defense/stats
//increase rare drops
//reduce monster spawns in area
//add resources
//multiplying other adjacent abilities
//accumulate (i.e. feed mangos for permenant boosts)
//slot machine plant (gives indeterminant rewards)
//bad plants with negative effects
//mining/sea salvaging
//duplicate
//change other plants
//allows use of certain weapons
//convert things into other things