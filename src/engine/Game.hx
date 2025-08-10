package engine;

import data.Data.World;
import data.Data.TriZone;
import data.Data.MonsterType;
import data.Data.Monster;
import data.Data.PlantType;
import data.Data.Rarity;
import data.Data.Range;
import data.Data.SoilType;
import engine.EventImpl.WorldTools;

class Game {
    public static var world(default, null): World;

    public static function seedInitialWorld(): Void {
        world = new World();

                for (zoneId in 0...80) {
            world.zones.push(new TriZone(zoneId));
        }

                var neighboursById = new Map<Int, Array<Int>>();
        neighboursById.set(74, [22, 75, 77]);
        neighboursById.set(37, [34, 39, 18]);
        neighboursById.set(0, [32, 3, 50]);
        neighboursById.set(75, [73, 74, 72]);
        neighboursById.set(38, [21, 39, 33]);
        neighboursById.set(1, [64, 3, 34]);
        neighboursById.set(76, [30, 79, 13]);
        neighboursById.set(39, [37, 38, 36]);
        neighboursById.set(2, [48, 3, 66]);
        neighboursById.set(77, [74, 79, 29]);
        neighboursById.set(40, [8, 43, 12]);
        neighboursById.set(3, [1, 2, 0]);
        neighboursById.set(78, [14, 79, 73]);
        neighboursById.set(41, [45, 43, 10]);
        neighboursById.set(4, [53, 7, 32]);
        neighboursById.set(79, [77, 78, 76]);
        neighboursById.set(42, [13, 43, 46]);
        neighboursById.set(5, [73, 7, 52]);
        neighboursById.set(43, [41, 42, 40]);
        neighboursById.set(6, [33, 7, 72]);
        neighboursById.set(44, [24, 47, 28]);
        neighboursById.set(7, [5, 6, 4]);
        neighboursById.set(45, [41, 47, 25]);
        neighboursById.set(8, [49, 11, 40]);
        neighboursById.set(46, [30, 47, 42]);
        neighboursById.set(9, [69, 11, 48]);
        neighboursById.set(47, [45, 46, 44]);
        neighboursById.set(10, [41, 11, 68]);
        neighboursById.set(48, [9, 51, 2]);
        neighboursById.set(11, [9, 10, 8]);
        neighboursById.set(49, [54, 51, 8]);
        neighboursById.set(12, [40, 15, 54]);
        neighboursById.set(50, [0, 51, 53]);
        neighboursById.set(13, [76, 15, 42]);
        neighboursById.set(14, [52, 15, 78]);
        neighboursById.set(51, [49, 50, 48]);
        neighboursById.set(15, [13, 14, 12]);
        neighboursById.set(52, [5, 55, 14]);
        neighboursById.set(16, [57, 19, 36]);
        neighboursById.set(53, [50, 55, 4]);
        neighboursById.set(54, [12, 55, 49]);
        neighboursById.set(17, [65, 19, 56]);
        neighboursById.set(55, [53, 54, 52]);
        neighboursById.set(18, [37, 19, 64]);
        neighboursById.set(56, [17, 59, 26]);
        neighboursById.set(19, [17, 18, 16]);
        neighboursById.set(57, [62, 59, 16]);
        neighboursById.set(20, [36, 23, 62]);
        neighboursById.set(58, [24, 59, 61]);
        neighboursById.set(21, [72, 23, 38]);
        neighboursById.set(59, [57, 58, 56]);
        neighboursById.set(22, [60, 23, 74]);
        neighboursById.set(60, [29, 63, 22]);
        neighboursById.set(23, [21, 22, 20]);
        neighboursById.set(61, [58, 63, 28]);
        neighboursById.set(24, [44, 27, 58]);
        neighboursById.set(62, [20, 63, 57]);
        neighboursById.set(25, [68, 27, 45]);
        neighboursById.set(63, [61, 62, 60]);
        neighboursById.set(26, [56, 27, 70]);
        neighboursById.set(64, [18, 67, 1]);
        neighboursById.set(27, [25, 26, 24]);
        neighboursById.set(65, [70, 67, 17]);
        neighboursById.set(28, [61, 31, 44]);
        neighboursById.set(66, [2, 67, 69]);
        neighboursById.set(29, [77, 31, 60]);
        neighboursById.set(67, [65, 66, 64]);
        neighboursById.set(30, [46, 31, 76]);
        neighboursById.set(68, [10, 71, 25]);
        neighboursById.set(31, [29, 30, 28]);
        neighboursById.set(69, [66, 71, 9]);
        neighboursById.set(32, [4, 35, 0]);
        neighboursById.set(70, [26, 71, 65]);
        neighboursById.set(33, [38, 35, 6]);
        neighboursById.set(71, [69, 70, 68]);
        neighboursById.set(34, [1, 35, 37]);
        neighboursById.set(72, [6, 75, 21]);
        neighboursById.set(35, [33, 34, 32]);
        neighboursById.set(73, [78, 75, 5]);
        neighboursById.set(36, [16, 39, 20]);

                for (zoneId in 0...80) {
            var neighbours = neighboursById.get(zoneId);
            if (neighbours != null) {
                world.zones[zoneId].neighbours = neighbours;
            }
        }

                var safeZoneIds = new haxe.ds.IntMap<Bool>();
        safeZoneIds.set(0, true);
        for (n in neighboursById.get(0)) safeZoneIds.set(n, true);

                var basicMonsterType = new MonsterType("slime");
        basicMonsterType.name = "Slime";
        basicMonsterType.maxHp = 10;
        basicMonsterType.defense = 0;
        basicMonsterType.attacks = [];
        basicMonsterType.loot = [];

                for (zoneId in 0...80) {
            if (!safeZoneIds.exists(zoneId)) {
                world.zones[zoneId].monsters.push(new Monster(basicMonsterType, zoneId));
            }
        }

                initializeSeeddata();
    }

    public static function initializeSeeddata(): Void {
                var testPlant = new PlantType("test_plant");
        testPlant.name = "Test Plant";
        testPlant.maxHp = 10;
        testPlant.effect = null;
        testPlant.rarity = Rarity.Common;
        testPlant.heatReq = { min: -100, max: 100 };
        testPlant.waterReq = { min: 0, max: 1 };
        testPlant.soilWhitelist = [SoilType.Sand, SoilType.Fertile, SoilType.Poor, SoilType.Water];
        testPlant.sunNeeded = 0;
        testPlant.germTimeQD = 1;

        var waterPlant = new PlantType("water_plant");
        waterPlant.name = "Water Plant";
        waterPlant.maxHp = 10;
        waterPlant.effect = null;
        waterPlant.rarity = Rarity.Common;
        waterPlant.heatReq = { min: -50, max: 60 };
        waterPlant.waterReq = { min: 0.2, max: 1 };
        waterPlant.soilWhitelist = [SoilType.Water, SoilType.Fertile];
        waterPlant.sunNeeded = 0;
        waterPlant.germTimeQD = 1;

        world.seedPool.catalog = [testPlant, waterPlant];
        WorldTools.addSeed(world, testPlant, 5);
        WorldTools.addSeed(world, waterPlant, 3);
    }
}