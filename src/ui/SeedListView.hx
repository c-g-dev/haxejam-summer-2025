package ui;

import engine.Game;
import data.Data.PlantType;
import ui.Nav.ArrowNav;
import ui.Nav.ArrowNavEvent;
import ui.NavScrollBox;
import ludi.heaps.box.Box;
import ludi.heaps.box.Containers.VBox;
import h2d.Graphics;

class SeedListItem extends h2d.Object {
    public var seed:PlantType;
    var nameText:h2d.Text;
    var countText:h2d.Text;
    var bg:Graphics;
    var border:Graphics;
    var rowWidth:Int;
    var rowHeight:Int;
    var padding:Int = 8;
    var textScale:Float = 0.25;

    public function new(seed:PlantType, count:Int, rowWidth:Int, rowHeight:Int) {
        super();
        this.seed = seed;
        this.rowWidth = rowWidth;
        this.rowHeight = rowHeight;

        bg = new Graphics(this);
        border = new Graphics(this);

        nameText = new h2d.Text(hxd.Res.fonts.plex_mono_64.toFont(), this);
        nameText.text = seed.name;
        nameText.textColor = 0xCCCCCC;
        nameText.scaleX = textScale;
        nameText.scaleY = textScale;

        countText = new h2d.Text(hxd.Res.fonts.plex_mono_64.toFont(), this);
        countText.text = "x" + count;
        countText.textColor = 0xAAAAAA;
        countText.scaleX = textScale;
        countText.scaleY = textScale;

        updateLayout();
    }

    function updateLayout() {
        // Ensure the item reports its full bounds to the layout
        bg.clear();
        bg.beginFill(0x000000, 0);
        bg.drawRect(0, 0, rowWidth, rowHeight);
        bg.endFill();

        border.clear();

        nameText.x = padding;
        nameText.y = Std.int((rowHeight - nameText.textHeight * textScale) / 2);

        countText.x = Std.int(rowWidth - padding - countText.textWidth * textScale);
        countText.y = nameText.y;
    }

    public function setSelected(selected:Bool) {
        if (selected) {
            bg.clear();
            bg.beginFill(0x77D7FF, 0.3);
            bg.drawRect(0, 0, rowWidth, rowHeight);
            bg.endFill();

            border.clear();
            border.lineStyle(2, 0x00E1FF, 1);
            border.drawRect(1, 1, rowWidth - 2, rowHeight - 2);

            nameText.textColor = 0xFFFFFF;
            countText.textColor = 0xFFFFFF;
        } else {
            bg.clear();
            bg.beginFill(0x000000, 0);
            bg.drawRect(0, 0, rowWidth, rowHeight);
            bg.endFill();

            border.clear();
            nameText.textColor = 0xCCCCCC;
            countText.textColor = 0xAAAAAA;
        }
    }
}

class SeedListView extends h2d.Object {
    public var totalWidth(default, null):Float;
    public var totalHeight(default, null):Float;
    public dynamic function onSeedSelected(seed:PlantType):Void {}

    var nav:ArrowNav;
    var listBox:NavScrollBox;
    var detailBox:Box;
    var detail:SeedDetailView;
    var headerBox:Box;
    var headerTitle:h2d.Text;
    var footerBox:Box;
    var footerHint:h2d.Text;
    var rowHeight:Int = 56;

    public function new(width:Float, height:Float) {
        super();

        this.totalWidth = width;
        this.totalHeight = height;

        var root = Box.build(Std.int(width), Std.int(height));
        root.backgroundColor(0x1E1E1E);
        addChild(root.get());

        // Header bar
        var headerH = 44;
        var footerH = 36;
        var listW = Std.int(width * 0.45);
        var detailW = Std.int(width * 0.55);

        var hb = Box.build(Std.int(width), headerH);
        hb.verticalGradient(0x2B3A42, 0x1F2A30);
        hb.roundedCorners(0);
        headerBox = hb.get();
        root.get().addChild(headerBox);

        headerTitle = new h2d.Text(hxd.Res.fonts.plex_mono_64.toFont(), headerBox);
        headerTitle.text = "Seed Inventory";
        headerTitle.textColor = 0xFFFFFF;
        headerTitle.scaleX = 0.35;
        headerTitle.scaleY = 0.35;
        headerTitle.x = 12;
        headerTitle.y = Std.int((headerH - headerTitle.textHeight * 0.35) / 2);

        // Footer bar
        var fb = Box.build(Std.int(width), footerH);
        fb.verticalGradient(0x1F2A30, 0x151A1E);
        fb.roundedCorners(0);
        footerBox = fb.get();
        root.get().addChild(footerBox);
        footerBox.y = height - footerH;

        footerHint = new h2d.Text(hxd.Res.fonts.plex_mono_64.toFont(), footerBox);
        footerHint.text = "Enter: Plant   Esc: Back";
        footerHint.textColor = 0x99C9FF;
        footerHint.scaleX = 0.3;
        footerHint.scaleY = 0.3;
        footerHint.x = 12;
        footerHint.y = Std.int((footerH - footerHint.textHeight * 0.3) / 2);

        // Left: list (below header, above footer)
        listBox = new NavScrollBox(listW, Std.int(height - headerH - footerH));
        listBox.addPlugin(new ludi.heaps.box.Plugins.BackgroundColorPlugin(0x262626));
        root.get().addChild(listBox);
        listBox.y = headerH;

        // Right: detail panel
        var db = Box.build(detailW, Std.int(height - headerH - footerH));
        db.backgroundColor(0x202020);
        db.verticalGradient(0x2A2A2A, 0x151515);
        db.roundedCorners(6);
        db.roundedBorder(2, 0x000000, 6);
        detailBox = db.get();
        root.get().addChild(detailBox);
        detailBox.x = listW;
        detailBox.y = headerH;

        detail = new SeedDetailView(Std.int(detailBox.width), Std.int(detailBox.height));
        detailBox.addChild(detail);

        nav = new ArrowNav();

        populateFromInventory();
    }

    function populateFromInventory() {
        listBox.clear();
        if (Game.world == null || Game.world.inventory == null) return;

        for (seed => count in Game.world.inventory.seeds) {
            if (count <= 0) continue;
            var item = new SeedListItem(seed, count, Std.int(listBox.width), rowHeight);
            listBox.addChild(item);
            nav.bind(item, (e:ArrowNavEvent) -> {
                switch e {
                    case Enter:
                        item.setSelected(true);
                        showDetails(seed, count);
                    case Leave:
                        item.setSelected(false);
                    case Selected:
                        if (onSeedSelected != null) onSeedSelected(seed);
                }
            });
        }
    }

    function showDetails(seed:PlantType, count:Int) {
        detail.setSeed(seed, count);
    }

    public function update(dt:Float) {
        if (nav != null) nav.update();
    }
} 