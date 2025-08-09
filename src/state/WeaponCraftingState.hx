package state;

import heaps.coroutine.Future;
import state.HState;
import state.HState.HStateLifeCycle;
import ui.Nav.ArrowNav;
import ui.Nav.ArrowNavEvent;
import ludi.heaps.box.Box;
import ui.NavScrollBox;
import engine.Game;
import engine.WorldEngine;
import engine.EventImpl.CraftWeaponEvent;
import data.Data.WeaponType;
import data.Data.SlotKind;
import data.Data.Stats;
import data.Data.MaterialType;
import hxd.Key;

typedef WeaponSpec = {
    var type: WeaponType;
    var cost: Map<MaterialType, Int>;
}

class WeaponCraftingState extends HState {

    //left side: a list of available weapons to craft
    //arrow nav through the list
    //if you don't have the necessary materials to craft a weapon its text is greyed out
    //if you do you can action the item to craft it
    //right side: a panel describing the weapon and it's cost

    var root: h2d.Object;
    var headerBox: Box;
    var footerBox: Box;
    var listBox: NavScrollBox;
    var detailBox: Box;
    var nav: ArrowNav;

    var titleText: h2d.Text;
    var slotText: h2d.Text;
    var statsText: h2d.Text;
    var costText: h2d.Text;
    var footerHint: h2d.Text;

    var catalog: Array<WeaponSpec> = [];
    var buttonRefs: Map<Box, WeaponSpec> = new Map();
    var selected: WeaponSpec = null;

    function setup(): Void {
        buildCatalog();

        root = new h2d.Object();
        this.app.s2d.add(root);

        var s2dW = this.app.s2d.width;
        var s2dH = this.app.s2d.height;
        var headerH = 44;
        var footerH = 36;
        var listW = Std.int(s2dW * 0.45);

        var header = Box.build(s2dW, headerH);
        header.verticalGradient(0x2B3A42, 0x1F2A30);
        headerBox = header.get();
        root.addChild(headerBox);

        var font = hxd.Res.fonts.plex_mono_64.toFont();
        var ht = new h2d.Text(font, headerBox);
        ht.text = "Craft Weapons";
        ht.textColor = 0xFFFFFF;
        ht.scale(0.35);
        ht.x = 12;
        ht.y = Std.int((headerH - ht.textHeight * 0.35) / 2);

        var footer = Box.build(s2dW, footerH);
        footer.verticalGradient(0x1F2A30, 0x151A1E);
        footerBox = footer.get();
        root.addChild(footerBox);
        footerBox.y = s2dH - footerH;

        footerHint = new h2d.Text(font, footerBox);
        footerHint.text = "Enter: Craft    Esc: Back";
        footerHint.textColor = 0x99C9FF;
        footerHint.scale(0.3);
        footerHint.x = 12;
        footerHint.y = Std.int((footerH - footerHint.textHeight * 0.3) / 2);

        listBox = new NavScrollBox(listW, Std.int(s2dH - headerH - footerH));
        listBox.addPlugin(new ludi.heaps.box.Plugins.BackgroundColorPlugin(0x262626));
        root.addChild(listBox);
        listBox.y = headerH;

        var db = Box.build(Std.int(s2dW - listW), Std.int(s2dH - headerH - footerH));
        db.backgroundColor(0x202020);
        db.verticalGradient(0x2A2A2A, 0x151515);
        db.roundedCorners(6);
        db.roundedBorder(2, 0x000000, 6);
        detailBox = db.get();
        root.addChild(detailBox);
        detailBox.x = listW;
        detailBox.y = headerH;

        nav = new ArrowNav();

        // Detail texts
        titleText = new h2d.Text(font, detailBox);
        titleText.textColor = 0xFFFFFF;
        titleText.scale(0.5);
        titleText.x = 12;
        titleText.y = 12;

        slotText = new h2d.Text(font, detailBox);
        slotText.textColor = 0xCCCCCC;
        slotText.scale(0.35);
        slotText.x = 12;
        slotText.y = 54;

        statsText = new h2d.Text(font, detailBox);
        statsText.textColor = 0xCCCCCC;
        statsText.scale(0.35);
        statsText.x = 12;
        statsText.y = 90;

        costText = new h2d.Text(font, detailBox);
        costText.textColor = 0xFFD166;
        costText.scale(0.4);
        costText.x = 12;
        costText.y = Std.int(detailBox.height) - 110;

        populateList();
        updateDetail(null);
    }

    function populateList(): Void {
        listBox.clear();
        buttonRefs = new Map();

        for (spec in catalog) {
            var btn: Box = (new ludi.heaps.form.controls.FormButton(spec.type.name) : Box);
            listBox.addChild(btn);
            buttonRefs.set(btn, spec);

            updateButtonCraftable(btn, spec);

            btn.onClick(_ -> attemptCraft(spec));

            nav.bind(btn, (e:ArrowNavEvent) -> {
                switch e {
                    case Enter:
                        selected = spec;
                        updateDetail(spec);
                    case Leave:
                    case Selected:
                        attemptCraft(spec);
                }
            });
        }
    }

    function updateButtonCraftable(btn: Box, spec: WeaponSpec): Void {
        btn.alpha = canCraft(spec) ? 1.0 : 0.5;
    }

    function attemptCraft(spec: WeaponSpec): Void {
        if (!canCraft(spec)) return;
        WorldEngine.enqueue(new CraftWeaponEvent(spec.type, spec.cost));
        // After crafting, reflect inventory changes
        refreshCraftability();
        updateDetail(spec);
    }

    function refreshCraftability(): Void {
        for (btn => spec in buttonRefs) {
            updateButtonCraftable(btn, spec);
        }
    }

    function updateDetail(spec: WeaponSpec): Void {
        if (spec == null) {
            titleText.text = "Select a weapon";
            slotText.text = "";
            statsText.text = "";
            costText.text = "";
            return;
        }

        var wt = spec.type;
        titleText.text = wt.name;
        slotText.text = 'Slot: ' + slotToString(wt.slotKind) + '   Max Lvl: ' + wt.maxLevel;
        statsText.text = 'Passive: +' + wt.passiveStats.hp + ' HP, +' + wt.passiveStats.power + ' Power, +' + wt.passiveStats.defense + ' Defense';

        var lines:Array<String> = [];
        lines.push("Cost:");
        for (mat => need in spec.cost) {
            var have = 0;
            if (Game.world != null && Game.world.inventory != null && Game.world.inventory.materials.exists(mat))
                have = Game.world.inventory.materials.get(mat);
            lines.push(' - ' + mat + ': ' + have + '/' + need);
        }
        costText.text = lines.join("\n");
        costText.textColor = canCraft(spec) ? 0xA0FFA0 : 0xFFD166;
    }

    function canCraft(spec: WeaponSpec): Bool {
        if (Game.world == null || Game.world.inventory == null) return false;
        for (mat => need in spec.cost) {
            var have = Game.world.inventory.materials.exists(mat) ? Game.world.inventory.materials.get(mat) : 0;
            if (have < need) return false;
        }
        return true;
    }

    function slotToString(s: SlotKind): String {
        return switch (s) {
            case Core: "Core";
            case Arm: "Arm";
            case Auxiliary: "Auxiliary";
            default: Std.string(s);
        }
    }

    function buildCatalog(): Void {
        // Minimal demo catalog; real game should source this from data
        var specs:Array<WeaponSpec> = [];

        // Light Blade (Arm)
        var blade = new WeaponType("w_blade_light");
        blade.name = "Light Blade";
        blade.slotKind = SlotKind.Arm;
        blade.passiveStats = new Stats();
        blade.passiveStats.power = 2;
        blade.passiveStats.hp = 0;
        blade.passiveStats.defense = 0;
        blade.attacks = []; // populate later
        blade.maxLevel = 3;
        var bladeCost:Map<MaterialType, Int> = new Map();
        bladeCost.set("metal", 3);
        bladeCost.set("wire", 1);
        specs.push({ type: blade, cost: bladeCost });

        // Core Plating (Core)
        var core = new WeaponType("w_core_plating");
        core.name = "Core Plating";
        core.slotKind = SlotKind.Core;
        core.passiveStats = new Stats();
        core.passiveStats.defense = 3;
        core.passiveStats.hp = 2;
        core.passiveStats.power = 0;
        core.attacks = [];
        core.maxLevel = 5;
        var coreCost:Map<MaterialType, Int> = new Map();
        coreCost.set("metal", 5);
        specs.push({ type: core, cost: coreCost });

        // Aux Battery (Auxiliary)
        var aux = new WeaponType("w_aux_battery");
        aux.name = "Aux Battery";
        aux.slotKind = SlotKind.Auxiliary;
        aux.passiveStats = new Stats();
        aux.passiveStats.hp = 4;
        aux.passiveStats.power = 1;
        aux.passiveStats.defense = 0;
        aux.attacks = [];
        aux.maxLevel = 4;
        var auxCost:Map<MaterialType, Int> = new Map();
        auxCost.set("circuit", 2);
        auxCost.set("metal", 2);
        specs.push({ type: aux, cost: auxCost });

        catalog = specs;
    }

    public function lifecycle(e: HStateLifeCycle) : Future {
        switch e {
            case Create: {
                setup();
                return Future.immediate();
            }
            case Activate: {
                refreshCraftability();
                updateDetail(selected);
                return Future.immediate();
            }
            case Deactivate: {
                return Future.immediate();
            }
            case Destroy: {
                if (root != null) {
                    this.app.s2d.removeChild(root);
                    root = null;
                }
                return Future.immediate();
            }
        }
    }

    public function onUpdate(dt:Float): Void {
        if (nav != null) nav.update();
        if (Key.isPressed(Key.ESCAPE)) {
            exitState();
        }
    }
}