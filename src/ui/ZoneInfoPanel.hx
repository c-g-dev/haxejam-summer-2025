package ui;

import h2d.Object;
import h2d.Text;
import h2d.Bitmap;
import ludi.heaps.box.Box;
import data.Data.World;
import data.Data.TriZone;
import data.Data.SoilType;
import data.Data.PlantState;
import ui.Icons;

class ZoneInfoPanel extends Object {
    public var totalWidth(default, null):Int;
    public var totalHeight(default, null):Int;

    var root:Box;
    var headerBox:Box;
    var headerTitle:Text;
    var bodyBox:Box;

    var plantLine:Text;
    var rowSoil:ZoneRow;
    var rowHeat:ZoneRow;
    var rowWater:ZoneRow;
    var rowMonsters:ZoneRow;

    public function new(width:Int, height:Int) {
        super();
        totalWidth = width;
        totalHeight = height;

        var rootBox = Box.build(width, height);
        rootBox.backgroundColor(0x1E1E1E);
        root = rootBox.get();
        addChild(root);

        var headerH = 36;
        var hb = Box.build(width, headerH);
        hb.verticalGradient(0x2B3A42, 0x1F2A30);
        hb.roundedCorners(0);
        headerBox = hb.get();
        root.addChild(headerBox);

        headerTitle = new Text(hxd.Res.fonts.plex_mono_64.toFont(), headerBox);
        headerTitle.text = "Zone";
        headerTitle.textColor = 0xFFFFFF;
        headerTitle.scaleX = 0.32;
        headerTitle.scaleY = 0.32;
        headerTitle.x = 10;
        headerTitle.y = Std.int((headerH - headerTitle.textHeight * headerTitle.scaleY) / 2);

        var bb = Box.build(width, height - headerH);
        bb.backgroundColor(0x202020);
        bb.verticalGradient(0x2A2A2A, 0x151515);
        bb.roundedCorners(6);
        bb.roundedBorder(2, 0x000000, 6);
        bodyBox = bb.get();
        root.addChild(bodyBox);
        bodyBox.y = headerH;

                plantLine = new Text(hxd.Res.fonts.plex_mono_64.toFont(), bodyBox);
        plantLine.textColor = 0xCCCCCC;
        plantLine.scaleX = 0.28;
        plantLine.scaleY = 0.28;
        plantLine.maxWidth = Std.int(width - 20);
        plantLine.x = 10;
        plantLine.y = 10;

                rowSoil = new ZoneRow(bodyBox, Soil);
        rowHeat = new ZoneRow(bodyBox, Sun);
        rowWater = new ZoneRow(bodyBox, Droplet);
        rowMonsters = new ZoneRow(bodyBox, Monster);

        layoutRows();
    }

    function layoutRows() {
        var x = 10;
        var y = Std.int(plantLine.y + plantLine.textHeight * plantLine.scaleY + 8);
        var w = Std.int(totalWidth - 20);

        rowSoil.setPosition(x, y); rowSoil.setWidth(w); y += rowSoil.height();
        rowHeat.setPosition(x, y); rowHeat.setWidth(w); y += rowHeat.height();
        rowWater.setPosition(x, y); rowWater.setWidth(w); y += rowWater.height();
        rowMonsters.setPosition(x, y); rowMonsters.setWidth(w);
    }

    public function setZone(world:World, zoneId:Int) {
        if (world == null || world.zones == null) return;
        if (zoneId < 0 || zoneId >= world.zones.length) return;
        var z = world.zones[zoneId];

        headerTitle.text = "Zone #" + zoneId + (z.isHostile ? " — Hostile" : " — Safe");
        headerTitle.x = 10;

        if (z.plant != null) {
            var p = z.plant;
            plantLine.text = "Plant: " + p.type.name + "  (" + p.hp + "/" + p.type.maxHp + ")";
        } else {
            plantLine.text = "Plant: —";
        }

        rowSoil.setText("Soil: " + soilText(z.env.soil));
        rowHeat.setText("Heat: " + Std.int(z.env.baseHeat) + " °C");
        rowWater.setText("Water: " + Std.int(z.env.waterLevel * 100) + "%");
        var mc = z.monsters != null ? z.monsters.length : 0;
        rowMonsters.setText(mc == 0 ? "No monsters" : (mc + (mc == 1 ? " monster" : " monsters")));

        layoutRows();
    }

    static inline function soilText(s:SoilType):String {
        return Std.string(s);
    }

    static inline function plantStateText(s:PlantState):String {
        return Std.string(s);
    }
}

private enum ZIconKind { Sun; Droplet; Soil; Monster; }

private class ZoneRow {
    var root:Object;
    var iconBmp:Bitmap;
    var text:Text;
    var iconKind:ZIconKind;
    var rowH:Int = 26;
    var iconSize:Int = 18;
    var _x:Int = 0;
    var _y:Int = 0;
    var _w:Int = 0;

    public function new(parent:Object, iconKind:ZIconKind) {
        root = new Object(parent);
        iconBmp = new Bitmap(null, root);
        text = new Text(hxd.Res.fonts.plex_mono_64.toFont(), root);
        text.textColor = 0xE0E0E0;
        text.scaleX = 0.28;
        text.scaleY = 0.28;
        this.iconKind = iconKind;
    }

    public function setText(t:String) {
        text.text = t;
        layout();
    }

    public function setPosition(x:Int, y:Int) {
        _x = x; _y = y; layout();
    }

    public function setWidth(w:Int) {
        _w = w; layout();
    }

    public function height():Int return rowH;
    public function y():Int return _y;

    function layout() {
        root.x = _x;
        root.y = _y;
        var tile = switch (iconKind) {
            case Sun: Icons.sun();
            case Droplet: Icons.water();
            case Soil: Icons.soil();
            case Monster: Icons.getTile("monster");
        }
        iconBmp.tile = tile;
        var scale = iconSize / tile.width;
        iconBmp.scaleX = scale;
        iconBmp.scaleY = scale;
        iconBmp.x = 0;
        iconBmp.y = Std.int((rowH - iconSize) / 2);

        text.x = iconSize + 8;
        text.y = Std.int((rowH - text.textHeight * text.scaleY) / 2);
    }
} 