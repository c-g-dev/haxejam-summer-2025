package data;

//services are for "querying" the world

class PlantService {

    public static function canPlant(seed, zone, world) {

    }
}


class ZoneService {

    public static function getPlayerActionsOnZone(zone, world): Array<PlayerAction> {
        //if zone is not friendly, none
        //if zone is friendly, can plant, remove plant, activate plant manual effect if applicable
        //if friendly zone is adjacent to a hostile zone, attack zone
    }

}


class RandomService {

    public static function rollSeedPulls() {

    }

    public static function rollMonsterSpawns() {

    }

}


//etc