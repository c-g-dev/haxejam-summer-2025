package data;

package data;

import data.Data.PlantType;
import data.Data.PlantEffect;
import data.Data.PlantEffectKind;
import data.Data.ResourceBundle;
import data.Data.ResourceType;
import data.Data.Range;
import data.Data.Rarity;
import data.Data.SoilType;

class PlantTypes {
	public static function catalog():Array<PlantType> {
		var list = new Array<PlantType>();

		inline function rb(sun:Int=0, n:Int=0, k:Int=0, p:Int=0):ResourceBundle {
			var m:ResourceBundle = new Map();
			if (sun > 0) m.set(ResourceType.Sun, sun);
			if (n > 0)   m.set(ResourceType.Nitrogen, n);
			if (k > 0)   m.set(ResourceType.Potassium, k);
			if (p > 0)   m.set(ResourceType.Phosphorous, p);
			return m;
		}
		inline function r(min:Float, max:Float):Range return {min:min, max:max};
		inline function pe(kind:PlantEffectKind, cd:Int, payload:ResourceBundle):PlantEffect {
			var e = new PlantEffect();
			e.kind = kind; e.cooldownQD = cd; e.payload = payload;
			return e;
		}
		inline function pt(
			id:String, name:String, hp:Int, rarity:Rarity,
			heat:Range, water:Range, soils:Array<SoilType>,
			sunNeeded:Int, germQD:Int, effect:PlantEffect
		):PlantType {
			var t = new PlantType(id);
			t.name = name;
			t.maxHp = hp;
			t.rarity = rarity;
			t.heatReq = heat;
			t.waterReq = water;
			t.soilWhitelist = soils;
			t.sunNeeded = sunNeeded;
			t.germTimeQD = germQD;
			t.effect = effect;
			return t;
		}

				list.push(pt(
			"clockvine_bureau", "Clockvine Bureau", 6, Rarity.Uncommon,
			r(8, 22), r(0.3, 0.7), [SoilType.Fertile, SoilType.Sand],
			5, 3, pe(PlantEffectKind.OnDayTick, 0, rb(1,0,0,1))
		));

				list.push(pt(
			"apology_fern", "Apology Fern", 5, Rarity.Common,
			r(4, 28), r(0.2, 0.8), [SoilType.Poor, SoilType.Fertile],
			3, 2, pe(PlantEffectKind.OnDayTick, 0, rb(0,1,0,0))
		));

				list.push(pt(
			"echo_marrow", "Echo Marrow", 7, Rarity.Rare,
			r(10, 30), r(0.1, 0.5), [SoilType.Sand],
			7, 4, pe(PlantEffectKind.Activatable, 3, rb(2,0,0,2))
		));

				list.push(pt(
			"humidity_statue", "Humidity Statue", 8, Rarity.Uncommon,
			r(0, 18), r(0.5, 1.0), [SoilType.Water, SoilType.Fertile],
			4, 3, pe(PlantEffectKind.OnDayTick, 0, rb(0,2,0,0))
		));

				list.push(pt(
			"boredom_orchard", "Boredom Orchard", 9, Rarity.Rare,
			r(6, 26), r(0.3, 0.9), [SoilType.Fertile],
			8, 5, pe(PlantEffectKind.Passive, 0, rb(0,0,1,0))
		));

				list.push(pt(
			"paradox_lichen", "Paradox Lichen", 4, Rarity.Epic,
			r(-4, 12), r(0.0, 0.6), [SoilType.Poor, SoilType.Sand],
			6, 2, pe(PlantEffectKind.Activatable, 2, rb(1,1,1,1))
		));

				list.push(pt(
			"ghost_of_compost", "Ghost of Compost", 10, Rarity.Uncommon,
			r(0, 24), r(0.4, 1.0), [SoilType.Fertile, SoilType.Water],
			4, 4, pe(PlantEffectKind.OnDayTick, 0, rb(0,1,1,0))
		));

				list.push(pt(
			"bureaucratic_cactus", "Bureaucratic Cactus", 12, Rarity.Common,
			r(18, 40), r(0.0, 0.3), [SoilType.Sand, SoilType.Poor],
			2, 3, pe(PlantEffectKind.Passive, 0, rb(0,0,1,1))
		));

				list.push(pt(
			"hunger_metronome", "Hunger Metronome", 6, Rarity.Rare,
			r(8, 28), r(0.2, 0.8), [SoilType.Fertile],
			6, 2, pe(PlantEffectKind.OnDayTick, 0, rb(1,1,0,0))
		));

				list.push(pt(
			"tired_thunderhead", "Tired Thunderhead", 7, Rarity.Epic,
			r(12, 34), r(0.6, 1.0), [SoilType.Water],
			9, 6, pe(PlantEffectKind.Activatable, 4, rb(0,0,0,4))
		));

				list.push(pt(
			"museum_of_crumbs", "Museum of Crumbs", 11, Rarity.Legendary,
			r(2, 22), r(0.2, 0.9), [SoilType.Fertile, SoilType.Poor],
			10, 6, pe(PlantEffectKind.OnDayTick, 0, rb(0,2,0,2))
		));

				list.push(pt(
			"accordion_moss", "Accordion Moss", 4, Rarity.Common,
			r(-6, 16), r(0.3, 1.0), [SoilType.Poor, SoilType.Water],
			2, 1, pe(PlantEffectKind.OnDayTick, 0, rb(1,0,0,0))
		));

				list.push(pt(
			"syntax_petunia", "Syntax Petunia", 5, Rarity.Uncommon,
			r(6, 26), r(0.1, 0.7), [SoilType.Sand, SoilType.Fertile],
			5, 2, pe(PlantEffectKind.Activatable, 2, rb(0,1,0,1))
		));

				list.push(pt(
			"lunar_soup", "Lunar Soup", 13, Rarity.Rare,
			r(-10, 10), r(0.7, 1.0), [SoilType.Water],
			7, 5, pe(PlantEffectKind.OnDayTick, 0, rb(2,0,0,0))
		));

				list.push(pt(
			"beige_fire", "Beige Fire", 6, Rarity.Rare,
			r(20, 44), r(0.0, 0.4), [SoilType.Sand],
			6, 3, pe(PlantEffectKind.Passive, 0, rb(0,0,0,2))
		));

				list.push(pt(
			"nostalgia_stalk", "Nostalgia Stalk", 9, Rarity.Uncommon,
			r(4, 24), r(0.2, 0.9), [SoilType.Fertile],
			4, 3, pe(PlantEffectKind.OnDayTick, 0, rb(0,0,2,0))
		));

				list.push(pt(
			"piano_marrow", "Piano Marrow", 8, Rarity.Epic,
			r(8, 32), r(0.3, 0.8), [SoilType.Fertile, SoilType.Poor],
			8, 4, pe(PlantEffectKind.Activatable, 3, rb(3,0,0,1))
		));

				list.push(pt(
			"umbrella_root", "Umbrella Root", 7, Rarity.Common,
			r(0, 20), r(0.5, 1.0), [SoilType.Water, SoilType.Fertile],
			3, 2, pe(PlantEffectKind.OnDayTick, 0, rb(0,1,1,0))
		));

				list.push(pt(
			"paper_moonseed", "Paper Moonseed", 5, Rarity.Rare,
			r(-2, 18), r(0.2, 0.6), [SoilType.Poor, SoilType.Sand],
			5, 2, pe(PlantEffectKind.Passive, 0, rb(2,0,0,0))
		));

				list.push(pt(
			"directory_lotus", "Directory Lotus", 14, Rarity.Legendary,
			r(10, 34), r(0.1, 0.9), [SoilType.Fertile],
			12, 7, pe(PlantEffectKind.Activatable, 5, rb(1,2,1,2))
		));

		return list;
	}
}