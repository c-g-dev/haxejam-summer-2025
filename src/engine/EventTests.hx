package engine;

import engine.EventImpl.ActivateSkillTreeNodeEvent;
import engine.EventImpl.ExecuteAttackEvent;
import engine.EventImpl.InitiateCombatEvent;
import engine.EventImpl.DayAdvanceEvent;
import engine.EventImpl.PlantSeedEvent;
import engine.EventImpl.DecrementResourceEvent;
import engine.EventImpl.IncrementResourceEvent;
import engine.EventImpl.WorldTools;
import utest.Assert;
import utest.Test;

import data.Data.World;
import data.Data.PlantType;
import data.Data.WeaponType;
import data.Data.MonsterType;
import data.Data.Material;
import data.Data.SoilType;
import data.Data.Rarity;
import data.Data.Stats;
import data.Data.SlotKind;
import data.Data.WeaponInstance;
import data.Data.Monster;
import data.Data.SkillNode;
import data.Data.ResourceType;
import data.Data.PlantState;
import data.Data.AttackDef;
import data.Data.TriZone;

import engine.WorldEngine;


using Lambda;

class EventTests extends Test {
		var world:World;
    var seedT:PlantType;
	var plantT:PlantType;
	var weaponT:WeaponType;
	var monsterT:MonsterType;
	var matT:Material;

	    function setup() {
				world = buildWorld();
		WorldEngine.world = world;
		WorldEngine.queue  = [];
		WorldEngine.isProcessing = false;
	}

				function testPlantSeedSuccess() {
        WorldTools.addSeed(world, seedT, 1);
        WorldEngine.enqueue(new PlantSeedEvent(0, seedT));

		Assert.notNull(world.zones[0].plant);
		Assert.equals(0, world.inventory.seeds.get(seedT));
	}

				function testPlantSeedWrongSoil() {
		        world.zones[1].env.soil = SoilType.Sand;
		WorldTools.addSeed(world, seedT, 1);

		Assert.raises(
			() -> WorldEngine.enqueue(new PlantSeedEvent(1, seedT)),
			'Expected planting to fail');
	}

				function testGermination() {
        WorldTools.addSeed(world, seedT, 1);
        WorldEngine.enqueue(new PlantSeedEvent(0, seedT));

		for (i in 0...2)
			WorldEngine.enqueue(new DayAdvanceEvent());

		Assert.equals(PlantState.Sprouted, world.zones[0].plant.state);
	}

				function testResourceIncDec() {
		WorldEngine.enqueue(new IncrementResourceEvent(ResourceType.Nitrogen, 5));
		Assert.equals(5, world.inventory.resources.get(ResourceType.Nitrogen));

		WorldEngine.enqueue(new DecrementResourceEvent(ResourceType.Nitrogen, 3));
		Assert.equals(2, world.inventory.resources.get(ResourceType.Nitrogen));

				Assert.raises(
			() -> WorldEngine.enqueue(new DecrementResourceEvent(ResourceType.Nitrogen, 5)));
	}

				function testCombatKillMonster() {
				WorldTools.addResource(world, ResourceType.Sun, 10);

				world.zones[0].monsters.push(new Monster(monsterT, 0));

		WorldEngine.enqueue(new InitiateCombatEvent(0));
		WorldEngine.enqueue(new ExecuteAttackEvent(0, "shoot"));

		Assert.equals(0, world.zones[0].monsters.length);
		Assert.isTrue(world.player.currentStats.hp > 0);
	}

				function testSkillActivation() {
		var node = createHpNode();
		world.player.skillTree.nodes.set(node.id, node);
		world.player.skillTree.points = 3;

		WorldEngine.enqueue(new ActivateSkillTreeNodeEvent(node.id));

		Assert.isTrue(node.purchased);
		Assert.equals(10, world.player.currentStats.hp);
	}

				function buildWorld():World {
		var w = new World();

		        seedT = new PlantType("basicPlant");
        seedT.name           = "Basic Plant";
        seedT.maxHp          = 10;
        seedT.effect         = null;
        seedT.rarity         = Rarity.Common;
        seedT.heatReq        = {min:0, max:40};
        seedT.waterReq       = {min:0, max:1};
        seedT.soilWhitelist  = [SoilType.Loamy];
        seedT.sunNeeded      = 2;
        seedT.germTimeQD     = 2;

        plantT = seedT;

        w.seedPool.catalog = [seedT];

		var attack = new AttackDef();
		attack.id     = "shoot";
		attack.name   = "Shoot";
		attack.cost   = new Map();
		attack.damage = 10;

		weaponT = new WeaponType("blaster");
		weaponT.name          = "Blaster";
		weaponT.slotKind      = SlotKind.Arm;
		weaponT.passiveStats  = new Stats();
		weaponT.attacks       = [attack];

		w.player.weaponSlots.push(new WeaponInstance(weaponT));
		w.player.baseStats.hp = 100;
		w.player.refresh();

		var monAtk = new AttackDef();
		monAtk.id     = "bite";
		monAtk.name   = "Bite";
		monAtk.cost   = new Map();
		monAtk.damage = 3;

		matT = new Material();
		matT.id   = "wood";
		matT.name = "Wood";
		matT.rarity = Rarity.Common;

		monsterT = new MonsterType("slime");
		monsterT.name      = "Slime";
		monsterT.maxHp     = 10;
		monsterT.defense   = 0;
		monsterT.attacks   = [monAtk];
		monsterT.loot      = [ { item:matT, min:1, max:1, chance:0 } ];

				for (i in 0...80) {
			var z = new TriZone(i);
            z.env.soil        = SoilType.Fertile;
			z.env.baseHeat    = 20;
			z.env.waterLevel  = 0.5;
			w.zones.push(z);
		}

		return w;
	}

		function createHpNode():SkillNode {
		var n = new SkillNode();
		n.id            = "hpBoost1";
		n.name          = "Green Thumb I";
		n.costPoints    = 2;
		n.prerequisites = [];
		n.effect        = s -> s.hp += 10;
		return n;
	}

	static function main() {
		utest.UTest.run([
			new EventTests()
		]);
	}
}

