package data;

class PlantService {

    public static function canPlant(seed, zone, world) {

    }

    public static function plant(seed, zone, world) {
        
    }

    public static function removePlant(zone, world) {
    }

}


class ZoneService {

    public static function getPlayerActionsOnZone(zone, world): Array<PlayerAction> {
        //if zone is not friendly, none
        //if zone is friendly, can plant, remove plant, activate plant manual effect if applicable
        //if friendly zone is adjacent to a hostile zone, attack zone
    }

}

typedef DayStepActions = World -> Void;

class DayService {

    public static function collectDayStepActions(world): Array<DayStepActions> {
        
    }

    public static function incrementDayStep(world){

    }
}

class RandomService {

    public static function rollSeedPulls() {

    }

    public static function rollMonsterSpawns() {

    }



}

class CombatService {

    public static function useAttack(){

    }
   
}

class RaidService {
    public static function doRaid() {
        
    }
}