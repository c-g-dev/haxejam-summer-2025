package engine;

import data.Data.AttackDef;
import data.Data.SeedPool;
import heaps.coroutine.Future;

import data.Data.World;
import data.Data.ResourceType;
import data.Data.MaterialType;
import data.Data.SoilType;
import data.Data.Quarter;
import data.Data.WeatherType;
import data.Data.Rarity;
import data.Data.Range;
import data.Data.PlantType;
import data.Data.PlantInstance;
import data.Data.PlantState;
import data.Data.PlantEffectKind;
import data.Data.TriZone;
import data.Data.WeaponType;
import data.Data.WeaponInstance;
import data.Data.Stats;
import data.Data.Monster;
import data.Data.MonsterType;
import engine.WorldEngine.IWorldEvent;

class WorldTools {
	public static inline function addResource(w:World, t:ResourceType, v:Int) {
		var m = w.inventory.resources;
		m.set(t, (m.exists(t) ? m.get(t) : 0) + v);
	}

	public static inline function removeResource(w:World, t:ResourceType, v:Int):Bool {
		var m = w.inventory.resources;
		var cur = m.exists(t) ? m.get(t) : 0;
		if (cur < v) return false;
		m.set(t, cur - v);
		return true;
	}

	public static inline function addMaterial(w:World, mat:MaterialType, v:Int) {
		var m = w.inventory.materials;
		m.set(mat, (m.exists(mat) ? m.get(mat) : 0) + v);
	}

	public static inline function removeMaterial(w:World, mat:MaterialType, v:Int):Bool {
		var m = w.inventory.materials;
		var cur = m.exists(mat) ? m.get(mat) : 0;
		if (cur < v) return false;
		m.set(mat, cur - v);
		return true;
	}

    public static inline function addSeed(w:World, s:PlantType, v:Int) {
		var m = w.inventory.seeds;
		m.set(s, (m.exists(s) ? m.get(s) : 0) + v);
	}

    public static inline function removeSeed(w:World, s:PlantType, v:Int):Bool {
		var m = w.inventory.seeds;
		var cur = m.exists(s) ? m.get(s) : 0;
		if (cur < v) return false;
		m.set(s, cur - v);
		return true;
	}
}

class PlantService {
    
    public static function canPlant(plant:PlantType, zone:TriZone, world:World):Bool {
				if (zone.plant != null) return false;
		if (zone.isHostile) return false;

		        if (plant.soilWhitelist != null && plant.soilWhitelist.length > 0)
            if (!Lambda.exists(plant.soilWhitelist, s -> s == zone.env.soil))
				return false;

				var heat = zone.env.baseHeat;         if (heat < plant.heatReq.min || heat > plant.heatReq.max)
			return false;

		var water = zone.env.waterLevel;
        if (water < plant.waterReq.min || water > plant.waterReq.max)
			return false;

		        var owned = world.inventory.seeds.exists(plant) ? world.inventory.seeds.get(plant) : 0;
		if (owned <= 0) return false;

		return true;
	}
}

class ZoneService {

	public static function getPlayerActionsOnZone(z:TriZone, world:World):Array<String> {
		var out = new Array<String>();

		if (!z.isHostile) {
			if (z.plant == null)
				out.push("Plant Seed");
			else {
				out.push("Remove Plant");
                if (z.plant.state == PlantState.Sprouted && z.plant.type.effect != null
                    && z.plant.type.effect.kind == PlantEffectKind.Activatable && z.plant.cdLeft <= 0)
					out.push("Use Plant Effect");
			}
		}

						if (z.isHostile) {
			out.push("Attack");
		} else {
			for (nid in z.neighbours)
				if (world.zones[nid].isHostile) {
					out.push("Attack");
					break;
				}
		}
		return out;
	}
}

class RandomService {
	static function weightForRarity(r:Rarity):Float
		return switch (r) {
			case Common:      60;
			case Uncommon:    25;
			case Rare:        10;
			case Epic:         4;
			case Legendary:    1;
		}

    
    public static function rollSeedPulls(pool:SeedPool):Array<PlantType> {
        var picks = new Array<PlantType>();
		if (pool.catalog == null || pool.catalog.length == 0) return picks;

				var cum:Array<Float> = [];
		var total = 0.0;
        for (p in pool.catalog) {
            total += weightForRarity(p.rarity);
			cum.push(total);
		}

		for (i in 0...3) {
			var r = Math.random() * total;
			for (idx in 0...cum.length)
				if (r <= cum[idx]) {
					picks.push(pool.catalog[idx]);
					break;
				}
		}
		return picks;
	}

	
	public static function rollMonsterSpawn(zone:TriZone, world:World):Bool {
		if (!zone.isHostile || zone.monsters.length >= 3) return false;

		var base = 0.20;
		for (nid in zone.neighbours)
			if (!world.zones[nid].isHostile && world.zones[nid].plant != null)
				base += 0.05;
		if (base > 0.60) base = 0.60;

		return Math.random() < base;
	}
}

class BaseWorldEvent implements IWorldEvent {
	@:call
	public inline function invoke(w:World):Future
		return changeWorld(w);

    public function changeWorld(world:World):Future
        return Future.immediate(); }

class PlantSeedEvent extends BaseWorldEvent {
	public final zoneId:Int;
    public final plant:PlantType;

    public function new(zoneId:Int, plant:PlantType) {
        this.zoneId = zoneId;
        this.plant   = plant;
	}

	override public function changeWorld(w:World):Future {
		var z = w.zones[zoneId];
        if (!PlantService.canPlant(plant, z, w))
            throw "Cannot plant " + plant.id + " on zone #" + zoneId;

		        if (!WorldTools.removeSeed(w, plant, 1))
			throw "Seed missing in inventory";

		        var p = new PlantInstance(plant, zoneId);
        p.state      = PlantState.Seed;
		p.sunAccum   = 0;
		p.ageQD      = 0;
		p.cdLeft     = 0;

        z.plant = p;
        return Future.immediate();
	}
}

class UpgradePlantEvent extends BaseWorldEvent {
	public final zoneId:Int;
	public final addHp:Int; 
    public function new(zoneId:Int, addHp:Int = 10) {
        this.zoneId = zoneId;
        this.addHp = addHp;
    }

	override public function changeWorld(w:World):Future {
		var z = w.zones[zoneId];
        if (z.plant == null || z.plant.state != PlantState.Sprouted)
			throw "No upgradeable plant on zone";

		z.plant.hp += addHp;
		if (z.plant.hp > z.plant.type.maxHp)
			z.plant.hp = z.plant.type.maxHp;
		return Future.immediate();
	}
}

class RemovePlantEvent extends BaseWorldEvent {
	public final zoneId:Int;
    public function new(zoneId:Int) { this.zoneId = zoneId; }

	override public function changeWorld(w:World):Future {
		var z = w.zones[zoneId];
        if (z.plant == null) return Future.immediate();
        z.plant = null;
        return Future.immediate();
	}
}

class InitiateCombatEvent extends BaseWorldEvent {
	public final zoneId:Int;
    public function new(zoneId:Int) { this.zoneId = zoneId; }

	override public function changeWorld(w:World):Future {
		var z = w.zones[zoneId];
		if (!z.isHostile) throw "Zone not hostile";

				if (z.monsters.length == 0) throw "No monster to fight";

		        Reflect.setField(z.monsters[0], "_inCombat", true);
        return Future.immediate();
	}
}

class ExecuteAttackEvent extends BaseWorldEvent {
	public final zoneId:Int;
	public final attackId:String; 
	public function new(zoneId:Int, attackId:String) {
		this.zoneId  = zoneId;
		this.attackId = attackId;
	}

	override public function changeWorld(w:World):Future {
		var z = w.zones[zoneId];
		var m:Monster = null;
		for (mon in z.monsters)
			if (Reflect.hasField(mon, "_inCombat")) { m = mon; break; }
		if (m == null) throw "Combat was not initiated";

				var atk:AttackDef = null;
		for (slot in w.player.weaponSlots)
			for (a in slot.type.attacks)
				if (a.id == attackId) { atk = a; break; }
		if (atk == null) throw "Unknown attack id";

				for (type => cost in atk.cost)
			if (!WorldTools.removeResource(w, type, cost))
				throw "Not enough " + Std.string(type);

				var dmg = atk.damage + w.player.currentStats.power - m.type.defense;
		if (dmg < 0) dmg = 0;

		m.hp -= dmg;
		if (m.hp <= 0) {
						for (entry in m.type.loot)
				if (Math.random() < entry.chance)
					WorldTools.addMaterial(
						w, entry.item.id, entry.min + Std.int(Math.random() * (entry.max - entry.min + 1)));

			z.monsters.remove(m);
		}

						if (z.monsters.length > 0)
			WorldEngine.enqueue(new MonsterTurnEvent(zoneId));

        return Future.immediate();
	}
}


class MonsterTurnEvent extends BaseWorldEvent {
	public final zoneId:Int;
    public function new(zoneId:Int) { this.zoneId = zoneId; }

	override public function changeWorld(w:World):Future {
		var z = w.zones[zoneId];
        if (!z.isHostile) return Future.immediate();

		var mon = z.monsters[0];
		var atk = mon.type.attacks[Std.random(mon.type.attacks.length)];

				var dmg = atk.damage - w.player.currentStats.defense;
		if (dmg < 0) dmg = 0;

		w.player.currentStats.hp -= dmg;
		if (w.player.currentStats.hp <= 0)
			throw "Player defeated!"; 
        return Future.immediate();
	}
}

class EndCombatEvent extends BaseWorldEvent {
	public final zoneId:Int;
	public function new(zoneId:Int) this.zoneId = zoneId;

	override public function changeWorld(w:World):Future {
		var z = w.zones[zoneId];
		for (mon in z.monsters)
			if (Reflect.hasField(mon, "_inCombat"))
				Reflect.deleteField(mon, "_inCombat");
        return Future.immediate();
	}
}

class IncrementResourceEvent extends BaseWorldEvent {
	public final t:ResourceType;
	public final v:Int;
    public function new(t, v) { this.t = t; this.v = v; }

	override public function changeWorld(w:World):Future {
		WorldTools.addResource(w, t, v);
		return Future.immediate();
	}
}

class DecrementResourceEvent extends BaseWorldEvent {
	public final t:ResourceType;
	public final v:Int;
    public function new(t, v) { this.t = t; this.v = v; }

	override public function changeWorld(w:World):Future {
		if (!WorldTools.removeResource(w, t, v))
			throw "Resource underflow";
		return Future.immediate();
	}
}

class GetMaterialEvent extends BaseWorldEvent {
	public final mat:MaterialType;
	public final amount:Int;
    public function new(mat, amount) { this.mat = mat; this.amount = amount; }

	override public function changeWorld(w:World):Future {
		WorldTools.addMaterial(w, mat, amount);
		return Future.immediate();
	}
}

class RemoveMaterialEvent extends BaseWorldEvent {
	public final mat:MaterialType;
	public final amount:Int;
    public function new(mat, amount) { this.mat = mat; this.amount = amount; }

	override public function changeWorld(w:World):Future {
		if (!WorldTools.removeMaterial(w, mat, amount))
			throw "Material underflow";
		return Future.immediate();
	}
}

class ActivateSkillTreeNodeEvent extends BaseWorldEvent {
	public final nodeId:String;
    public function new(nodeId) { this.nodeId = nodeId; }

	override public function changeWorld(w:World):Future {
		var node = w.player.skillTree.nodes.get(nodeId);
		if (node == null) throw "Unknown node";
        if (node.purchased) return Future.immediate();

		if (w.player.skillTree.points < node.costPoints)
			throw "Not enough skill points";

				for (pre in node.prerequisites)
			if (!w.player.skillTree.nodes.get(pre).purchased)
				throw "Missing prerequisite " + pre;

		w.player.skillTree.points -= node.costPoints;
		node.purchased = true;
		w.player.refresh();
        return Future.immediate();
	}
}

class CraftWeaponEvent extends BaseWorldEvent {
	public final weaponType:WeaponType;
	public final requiredMats:Map<MaterialType, Int>;

    public function new(type:WeaponType, mats:Map<MaterialType, Int>) {
        this.weaponType = type;
        this.requiredMats = mats;
    }

	override public function changeWorld(w:World):Future {
					for (mat => amt in requiredMats)
				if (!WorldTools.removeMaterial(w, mat, amt))
					throw "Not enough material " + mat;

				w.player.weaponSlots.push(new WeaponInstance(weaponType));
		w.player.refresh();
        return Future.immediate();
	}
}

class UpgradeWeaponEvent extends BaseWorldEvent {
	public final slotIdx:Int;
	public final mats:Map<MaterialType, Int>;

    public function new(slotIdx, mats) {
        this.slotIdx = slotIdx;
        this.mats = mats;
    }

	override public function changeWorld(w:World):Future {
		if (slotIdx < 0 || slotIdx >= w.player.weaponSlots.length)
			throw "Invalid slot";

		var inst = w.player.weaponSlots[slotIdx];
		if (inst.level >= inst.type.maxLevel)
			throw "Already at max level";

		for (mat => amt in mats)
			if (!WorldTools.removeMaterial(w, mat, amt))
				throw "Missing mats";

		inst.level++;
		w.player.refresh();
        return Future.immediate();
	}
}

class SpawnMonsterEvent extends BaseWorldEvent {
	public final zoneId:Int;
	public final monsterType:MonsterType;

    public function new(zoneId, mt) { this.zoneId = zoneId; this.monsterType = mt; }

	override public function changeWorld(w:World):Future {
		var z = w.zones[zoneId];
		if (z.monsters.length >= 3)
			throw "Zone already full";
		z.monsters.push(new Monster(monsterType, zoneId));
		return Future.immediate();
	}
}

class RemoveMonsterEvent extends BaseWorldEvent {
	public final zoneId:Int;
	public final monster:Monster;

    public function new(zoneId, m) { this.zoneId = zoneId; this.monster = m; }

	override public function changeWorld(w:World):Future {
		w.zones[zoneId].monsters.remove(monster);
		return Future.immediate();
	}
}

class InitiateRaidEvent extends BaseWorldEvent {
	public final fromZone:Int;
	public final targetZone:Int;
	public var monster:Monster; 
    public function new(fromZone:Int, targetZone:Int) {
        this.fromZone = fromZone;
        this.targetZone = targetZone;
    }

	override public function changeWorld(w:World):Future {
		monster = w.zones[fromZone].monsters[1]; 		return Future.immediate();
	}
}

class ExecuteRaidEvent extends BaseWorldEvent {
	public final raid:InitiateRaidEvent;
    public function new(raid) { this.raid = raid; }

	override public function changeWorld(w:World):Future {
		var z = raid.targetZone;
		var targetZ = w.zones[z];
		var p = targetZ.plant;
        if (p == null) return Future.immediate();

				var dmg = raid.monster.type.attacks[0].damage;
		p.hp -= dmg;

		if (p.hp <= 0) {
			targetZ.plant = null; 						targetZ.monsters.push(raid.monster);
			raid.monster.zoneId = targetZ.id;
						w.zones[raid.fromZone].monsters.remove(raid.monster);
		}
        return Future.immediate();
	}
}

class EndRaidEvent extends BaseWorldEvent {
    override public function changeWorld(w:World):Future
        return Future.immediate(); }

class DayAdvanceEvent extends BaseWorldEvent {
	override public function changeWorld(w:World):Future {
				w.quarter = switch (w.quarter) {
			case Quarter.OccindentalRising: Quarter.Occindental;
			case Quarter.Occindental:       Quarter.OrientalRising;
			case Quarter.OrientalRising:    Quarter.Oriental;
			case Quarter.Oriental:
				w.dayCount++;
				Quarter.OccindentalRising;
		}

				for (z in w.zones) {
						if (z.env.weatherPattern != null && z.env.weatherPattern.length > 0) {
				var step = (w.dayCount * 4 + cast w.quarter) % z.env.weatherPattern.length;
				z.env.currentWeather = z.env.weatherPattern[step];
			}

						if (RandomService.rollMonsterSpawn(z, w))
				WorldEngine.enqueue(new SpawnMonsterEvent(z.id, z.monsters[0].type)); 
							if (z.plant != null)
                handlePlantQuarter(z, w);
		}

                var pulls = RandomService.rollSeedPulls(w.seedPool);
        for (p in pulls)
            WorldTools.addSeed(w, p, 1);

		return Future.immediate();
	}

	public function new() {}

    static function handlePlantQuarter(z:TriZone, w:World) {
		var p = z.plant;
		p.ageQD++;

		switch (p.state) {
            case PlantState.Seed:
				p.sunAccum++;

				                if (p.sunAccum >= p.type.sunNeeded && p.ageQD >= p.type.germTimeQD)
					p.state = PlantState.Sprouted;
            case PlantState.Sprouted:
								if (w.quarter == Quarter.Oriental && p.type.effect != null
					&& p.type.effect.kind == PlantEffectKind.OnDayTick)
					for (rt => amt in p.type.effect.payload)
                        WorldTools.addResource(w, rt, amt);

								if (p.cdLeft > 0) p.cdLeft--;
            case PlantState.Dead:
						}
	}
}

class ChangeWeatherEvent extends BaseWorldEvent {
	public final zoneId:Int;
	public final weather:WeatherType;
    public function new(zoneId, w) { this.zoneId = zoneId; this.weather = w; }

	override public function changeWorld(w:World):Future {
		w.zones[zoneId].env.currentWeather = weather;
		return Future.immediate();
	}
}

class ChangeHeatVarianceEvent extends BaseWorldEvent {
	public final zoneId:Int;
	public final base:Float;
	public final variance:Float;

    public function new(zoneId, base, variance) {
        this.zoneId = zoneId;
        this.base = base;
        this.variance = variance;
    }

	override public function changeWorld(w:World):Future {
		var env = w.zones[zoneId].env;
		env.baseHeat      = base;
		env.dailyVariance = variance;
        return Future.immediate();
	}
}