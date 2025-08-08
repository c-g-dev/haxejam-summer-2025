package ui;

import engine.Game;
import data.Data.SeedType;
import ui.Nav.ArrowNav;
import ui.Nav.ArrowNavEvent;
import ui.NavScrollBox;
import ludi.heaps.box.Box;
import ludi.heaps.box.Containers.VBox;

class SeedListItem extends h2d.Object {
    public var seed:SeedType;
    var label:h2d.Text;

    public function new(seed:SeedType, count:Int) {
        super();
        this.seed = seed;
        label = new h2d.Text(hxd.Res.fonts.plex_mono_64.toFont(), this);
        label.text = seed.name + " x" + count;
        label.textColor = 0xCCCCCC;
        label.x = 8;
        label.y = 8;
        this.scaleX = 0.5;
        this.scaleY = 0.5;
    }

    public function setSelected(selected:Bool) {
        label.textColor = selected ? 0xFFFFFF : 0x999999;
    }
}

class SeedListView extends h2d.Object {
    public var totalWidth(default, null):Float;
    public var totalHeight(default, null):Float;

    var nav:ArrowNav;
    var listBox:NavScrollBox;
    var detailBox:Box;
    var detailTitle:h2d.Text;
    var detailBody:h2d.Text;

    public function new(width:Float, height:Float) {
        super();

        this.totalWidth = width;
        this.totalHeight = height;

        var root = Box.build(Std.int(width), Std.int(height));
        root.backgroundColor(0x1E1E1E);
        addChild(root.get());

        // Left: list
        listBox = new NavScrollBox(Std.int(width * 0.45), Std.int(height));
        listBox.addPlugin(new ludi.heaps.box.Plugins.BackgroundColorPlugin(0x262626));
        root.get().addChild(listBox);

        // Right: detail panel
        var db = Box.build(Std.int(width * 0.55), Std.int(height));
        db.backgroundColor(0x202020);
        db.verticalGradient(0x2A2A2A, 0x151515);
        db.roundedCorners(6);
        db.roundedBorder(2, 0x000000, 6);
        detailBox = db.get();
        root.get().addChild(detailBox);
        detailBox.x = listBox.width;

        detailTitle = new h2d.Text(hxd.Res.fonts.plex_mono_64.toFont(), detailBox);
        detailTitle.text = "Select a seed";
        detailTitle.textColor = 0xFFFFFF;
        detailTitle.x = 12;
        detailTitle.y = 12;
        detailTitle.scaleX = 0.6;
        detailTitle.scaleY = 0.6;

        detailBody = new h2d.Text(hxd.Res.fonts.plex_mono_64.toFont(), detailBox);
        detailBody.text = "";
        detailBody.textColor = 0xCCCCCC;
        detailBody.x = 12;
        detailBody.y = 48;
        detailBody.maxWidth = Std.int(detailBox.width - 24);
        detailBody.scaleX = 0.45;
        detailBody.scaleY = 0.45;

        nav = new ArrowNav();

        populateFromInventory();
    }

    function populateFromInventory() {
        listBox.clear();
        if (Game.world == null || Game.world.inventory == null) return;

        for (seed => count in Game.world.inventory.seeds) {
            if (count <= 0) continue;
            var item = new SeedListItem(seed, count);
            listBox.addChild(item);
            nav.bind(item, (e:ArrowNavEvent) -> {
                switch e {
                    case Enter:
                        item.setSelected(true);
                        showDetails(seed, count);
                    case Leave:
                        item.setSelected(false);
                    case Selected:
                        // Could emit a callback in future
                }
            });
        }
    }

    function showDetails(seed:SeedType, count:Int) {
        detailTitle.text = seed.name + " (x" + count + ")";
        var lines = [];
        lines.push("Rarity: " + Std.string(seed.rarity));
        lines.push("Heat: " + seed.heatReq.min + "-" + seed.heatReq.max + " °C");
        lines.push("Water: " + seed.waterReq.min + "-" + seed.waterReq.max);
        var soils = seed.soilWhitelist == null || seed.soilWhitelist.length == 0 ? "Any" : seed.soilWhitelist.map(s -> Std.string(s)).join(", ");
        lines.push("Soil: " + soils);
        lines.push("Sun needed: " + seed.sunNeeded);
        lines.push("Germinates in: " + seed.germTimeQD + " QD");
        if (seed.resultPlant != null) {
            lines.push("");
            lines.push("Becomes: " + seed.resultPlant.name);
        }
        detailBody.text = lines.join("\n");
    }

    public function update(dt:Float) {
        if (nav != null) nav.update();
    }
} 