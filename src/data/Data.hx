package data;


enum abstract Quarter(Int) {
	var OccindentalRising = 0;
	var Occindental = 1;
	var OrientalRising = 2;
	var Oriental = 3;
}

typedef MaterialType = String;

enum abstract ResourceType(Int) {
	var Sun = 0;
	var Nitrogen = 1;
	var Potassium = 2;
	var Phosphorous = 3;
}

enum abstract SoilType(Int) {
	var Sandy = 0;
	var Loamy = 1;
	var Clay = 2;
	var Peat = 3;
	var Silt = 4;
}

enum abstract WeatherType(Int) {
	var Clear = 0;
	var Rain = 1;
	var Storm = 2;
	var Overcast = 3;
}

enum abstract Rarity(Int) {
	var Common = 0;
	var Uncommon = 1;
	var Rare = 2;
	var Epic = 3;
	var Legendary = 4;
}

typedef Chance<T> = {
	chance: Float,
	value: T
}

typedef Range = {min:Float, max:Float};
typedef ResourceBundle = Map<ResourceType, Int>; // Generic cost / reward bag

// ──────────────────────────────────────────────────────
// 2.  WORLD
// ──────────────────────────────────────────────────────
class World {
	public var dayCount:Int = 0; // How many full days elapsed
	public var quarter:Quarter = Dawn; // Current quarter of the day
	public var zones:Array<TriZone>; // Fixed length = 80
	public var seedPool:SeedPool; // Gives the “3-pack” each quarter
	public var player:Mech; // The player’s mech
	public var inventory:Inventory; // Global player inventory

	public function new() {
		zones = [];
		seedPool = new SeedPool();
		player = new Mech();
		inventory = new Inventory();
	}
}

// ──────────────────────────────────────────────────────
// 3.  TRIANGULAR ZONE (“trizone”)
// ──────────────────────────────────────────────────────
class TriZone {
	public var id:Int;
	public var neighbours:Array<Int>; // Ids of adjacent triangles
	public var env:Environment; // Static + dynamic properties
	public var plant:PlantInstance; // Null if nothing planted
	public var monsters:Array<Monster>; // 0..n monsters
	public var isHostile(get, never):Bool; // Derived flag

	public inline function new(id:Int) {
		this.id = id;
		neighbours = [];
		env = new Environment();
		monsters = [];
	}

	inline function get_isHostile()
		return monsters.length > 0;
}

// Environmental information which may change with time
class Environment {
	public var baseHeat:Float = 0; // Average °C
	public var dailyVariance:Float = 0; // How much it swings each day
	public var waterLevel:Float = 0; // 0-1
	public var soil:SoilType = Sandy;
	public var materialYield:Array<Chance<Material>>;
	public var weatherPattern:Array<WeatherType> = []; // e.g. 16 values per day
	public var currentWeather:WeatherType = Clear;

	public function new() {}
}

// ──────────────────────────────────────────────────────
// 4.  SEEDS, PLANTS & THEIR INSTANCES
// ──────────────────────────────────────────────────────
class SeedType {
	public var id:String;
	public var name:String;
	public var rarity:Rarity;

	// Germination requirements
	public var heatReq:Range;
	public var waterReq:Range;
	public var soilWhitelist:Array<SoilType>;
	public var sunNeeded:Int; // Sun points consumed while still a seed
	public var germTimeQD:Int; // Quarter-days before sprouting

	public var resultPlant:PlantType; // What this seed becomes

	public function new(id:String)
		this.id = id;
}

class PlantType {
	public var id:String;
	public var name:String;
	public var maxHp:Int;
	public var effect:PlantEffect; // Automatic or activatable

	public function new(id:String)
		this.id = id;
}

enum PlantEffectKind {
	Passive;
	OnDayTick;
	Activatable;
	Combat;
}

class PlantEffect {
	public var kind:PlantEffectKind;
	public var cooldownQD:Int; // Only for activatable
	public var payload:ResourceBundle; // What it grants OR damages etc.
}

enum PlantState {
	Seed;
	Sprouted;
	Dead;
}

class PlantInstance {
	public var type:PlantType;
	public var zoneId:Int;
	public var hp:Int;
	public var sunAccum:Int = 0; // Sun collected while still a seed
	public var ageQD:Int = 0; // Quarter-days since planting
	public var state:PlantState = Seed;
	public var cdLeft:Int = 0; // Cool-down remaining (activatable)

	public inline function new(t:PlantType, zoneId:Int) {
		type = t;
		this.zoneId = zoneId;
		hp = t.maxHp;
	}
}

// ──────────────────────────────────────────────────────
// 5.  MONSTERS
// ──────────────────────────────────────────────────────
class MonsterType {
	public var id:String;
	public var name:String;
	public var maxHp:Int;
	public var defense:Int;
	public var attacks:Array<AttackDef>;
	public var loot:LootTable;

	public function new(id:String)
		this.id = id;
}

class Monster {
	public var type:MonsterType;
	public var zoneId:Int;
	public var hp:Int;

	public function new(t:MonsterType, zoneId:Int) {
		type = t;
		this.zoneId = zoneId;
		hp = t.maxHp;
	}
}

// ──────────────────────────────────────────────────────
// 6.  COMBAT BUILDING BLOCKS
// ──────────────────────────────────────────────────────
class AttackDef {
	public var id:String;
	public var name:String;
	public var cost:ResourceBundle;
	public var damage:Int; // Could be formula later
	public var hitsAll:Bool = false; // Meant for AoE
	public var special:String; // Free-form tag/effect id
}

typedef LootTable = Array<{
	item:Material,
	min:Int,
	max:Int,
	chance:Float
}>;

typedef DamageEvent = {
	attackerId:String,
	defenderId:String,
	damage:Int,
	killed:Bool
};

// ──────────────────────────────────────────────────────
// 7.  PLAYER MECH, WEAPONS, SKILLS
// ──────────────────────────────────────────────────────
class Mech {
	public var baseStats:Stats = new Stats();
	public var currentStats:Stats = new Stats();
	public var weaponSlots:Array<WeaponInstance> = [];
	public var skillTree:SkillTree = new SkillTree();

	// Apply a permanent base stat upgrade (skill, crafting, etc.)
	public inline function addBase(stat:StatKind, amount:Int) {
		baseStats.add(stat, amount);
		refresh();
	}

	// Re-calc current stats (equipment, skill nodes etc.)
	public function refresh() {
		currentStats.copy(baseStats);
		for (slot in weaponSlots)
			slot.applyStats(currentStats);
		skillTree.applyPassives(currentStats);
	}
}

enum abstract StatKind(Int) {
	var Hp = 0;
	var Power = 1;
	var Defense = 2;
}

class Stats {
	public var hp:Int = 0;
	public var power:Int = 0;
	public var defense:Int = 0;

	public function new() {}

	public inline function add(kind:StatKind, v:Int)
		switch (kind) {
			case Hp:
				hp += v;
			case Power:
				power += v;
			case Defense:
				defense += v;
		}

	public inline function copy(other:Stats) {
		hp = other.hp;
		power = other.power;
		defense = other.defense;
	}
}

enum abstract SlotKind(Int) {
	var Core = 0;
	var Arm = 1;
	var Auxiliary = 2;
}

class WeaponType {
	public var id:String;
	public var name:String;
	public var slotKind:SlotKind;
	public var passiveStats:Stats; // Added when equipped
	public var attacks:Array<AttackDef>; // The active skills it grants
	public var maxLevel:Int = 5;

	public function new(id:String)
		this.id = id;
}

class WeaponInstance {
	public var type:WeaponType;
	public var level:Int = 1;

	public function new(t:WeaponType)
		this.type = t;

	// Stat contribution scaled by level
	public inline function applyStats(out:Stats) {
		var mul = level;
		out.hp += type.passiveStats.hp * mul;
		out.power += type.passiveStats.power * mul;
		out.defense += type.passiveStats.defense * mul;
	}
}

class SkillNode {
	public var id:String;
	public var name:String;
	public var description:String;
	public var costPoints:Int;
	public var prerequisites:Array<String>; // Node ids
	public var effect:(Stats) -> Void;
	public var purchased:Bool = false;
}

class SkillTree {
	public var nodes:Map<String, SkillNode> = new Map();
	public var points:Int = 0;

	public function applyPassives(out:Stats) {
		for (n in nodes)
			if (n.purchased)
				n.effect(out);
	}
}

// ──────────────────────────────────────────────────────
// 8.  INVENTORY
// ──────────────────────────────────────────────────────
class Inventory {
	public var resources:ResourceBundle = new Map();
	public var materials:Map<MaterialType, Int> = new Map();
	public var seeds:Map<SeedType, Int> = new Map();

}

// ──────────────────────────────────────────────────────
// 9.  SEED POOL (THE “CARD PACK” EACH QUARTER‐DAY)
// ──────────────────────────────────────────────────────
class SeedPool {
	public var catalog:Array<SeedType>; // All possible seeds

	
}

// ──────────────────────────────────────────────────────
// 11. MATERIALS (FOR COMPLETENESS)
// ──────────────────────────────────────────────────────
class Material {
	public var id:String;
	public var name:String;
	public var description:String;
	public var rarity:Rarity;
}

// ───────────────────────────────
