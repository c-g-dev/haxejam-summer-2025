package data;


import data.Data.WeaponType;
import data.Data.AttackDef;
import data.Data.SlotKind;
import data.Data.Stats;
import data.Data.ResourceType;
import data.Data.ResourceBundle;

class WeaponTypes {
	public static function catalog():Array<WeaponType> {
		var list = new Array<WeaponType>();

		inline function rb(sun:Int=0, n:Int=0, k:Int=0, p:Int=0):ResourceBundle {
			var m:ResourceBundle = new Map();
			if (sun > 0) m.set(ResourceType.Sun, sun);
			if (n > 0)   m.set(ResourceType.Nitrogen, n);
			if (k > 0)   m.set(ResourceType.Potassium, k);
			if (p > 0)   m.set(ResourceType.Phosphorous, p);
			return m;
		}
		inline function atk(id:String, name:String, dmg:Int, cost:ResourceBundle, ?hitsAll:Bool=false, ?special:String=""):AttackDef {
			var a = new AttackDef();
			a.id = id; a.name = name; a.damage = dmg; a.cost = cost; a.hitsAll = hitsAll; a.special = special;
			return a;
		}
		inline function stats(hp:Int, pow:Int, def:Int):Stats {
			var s = new Stats(); s.hp = hp; s.power = pow; s.defense = def; return s;
		}
		inline function wt(id:String, name:String, slot:SlotKind, pass:Stats, attacks:Array<AttackDef>):WeaponType {
			var w = new WeaponType(id);
			w.name = name; w.slotKind = slot; w.passiveStats = pass; w.attacks = attacks;
			return w;
		}

				list.push(wt("solar_scythe", "Solar Scythe", SlotKind.Arm, stats(0, 2, 0), [
			atk("sun_cleave", "Sun Cleave", 6, rb(2,0,0,0), false, "bleed:1"),
			atk("flare_combo", "Flare Combo", 3, rb(1,0,0,0), false, "multi:2")
		]));

				list.push(wt("nitrogen_lance", "Nitrogen Lance", SlotKind.Arm, stats(0, 3, 0), [
			atk("pierce_thrust", "Pierce Thrust", 7, rb(0,2,0,0), false, "pierce"),
			atk("overpressure", "Overpressure", 10, rb(0,3,0,0), false, "")
		]));

				list.push(wt("phosphor_rail", "Phosphor Rail", SlotKind.Arm, stats(0, 2, 0), [
			atk("rail_shot", "Rail Shot", 4, rb(0,0,0,2), true, "line"),
			atk("irradiate", "Irradiate", 3, rb(0,0,0,3), false, "burn:2")
		]));

				list.push(wt("potassium_bulwark", "Potassium Bulwark", SlotKind.Auxiliary, stats(0, 0, 3), [
			atk("ionic_bash", "Ionic Bash", 3, rb(0,0,1,0), false, "guard:2"),
			atk("reinforce", "Reinforce", 0, rb(0,0,2,0), false, "shield:5")
		]));

				list.push(wt("bloom_core", "Bloom Core", SlotKind.Core, stats(8, 1, 0), [
			atk("photosynthesis", "Photosynthesis", 0, rb(), false, "gain:Sun:2"),
			atk("bloom_surge", "Bloom Surge", 5, rb(0,1,0,1), false, "")
		]));

				list.push(wt("thorn_harpoon", "Thorn Harpoon", SlotKind.Arm, stats(0, 2, 0), [
			atk("barbed_harpoon", "Barbed Harpoon", 4, rb(0,0,0,1), false, "pull"),
			atk("thorn_rend", "Thorn Rend", 2, rb(1,0,0,0), false, "bleed:2")
		]));

				list.push(wt("myco_drone", "Myco Drone", SlotKind.Auxiliary, stats(0, 1, 1), [
			atk("spore_burst", "Spore Burst", 3, rb(0,2,0,0), true, "poison:2"),
			atk("symbiosis", "Symbiosis", 0, rb(0,1,0,0), false, "heal:3")
		]));

				list.push(wt("seed_mortar", "Seed Mortar", SlotKind.Arm, stats(2, 2, 0), [
			atk("seed_cluster", "Seed Cluster", 2, rb(0,0,0,2), true, "multi:3"),
			atk("germ_bomb", "Germ Bomb", 5, rb(1,0,0,1), false, "stun:1")
		]));

				list.push(wt("tectonic_knuckle", "Tectonic Knuckle", SlotKind.Arm, stats(0, 2, 1), [
			atk("seismic_punch", "Seismic Punch", 6, rb(0,0,2,0), false, "stun:1"),
			atk("faultline", "Faultline", 4, rb(0,0,3,0), true, "shred:2")
		]));

				list.push(wt("nectar_injector", "Nectar Injector", SlotKind.Auxiliary, stats(2, 0, 0), [
			atk("vamp_strike", "Vamp Strike", 4, rb(0,1,0,0), false, "lifesteal:50"),
			atk("sugar_rush", "Sugar Rush", 0, rb(0,0,1,0), false, "haste:1")
		]));

		return list;
	}
}