package ui;

import h2d.Object;
import h2d.Text;
import h2d.Bitmap;
import ui.Icons;
import data.Data.PlantType;
import data.Data.Rarity;
import data.Data.SoilType;

class SeedDetailView extends Object {
    var widthPx:Int;
    var heightPx:Int;

    var title:Text;
    var image:Bitmap;

    var rowSun:DetailRow;
    var rowWater:DetailRow;
    var rowSoil:DetailRow;
    var rowClock:DetailRow;
    var effectText:Text;

    public function new(width:Int, height:Int) {
        super();
        widthPx = width;
        heightPx = height;

        title = new Text(hxd.Res.fonts.plex_mono_64.toFont(), this);
        title.scaleX = 0.40;
        title.scaleY = 0.40;
        title.dropShadow = { dx: 1, dy: 1, color: 0x000000, alpha: 0.9 };

        image = new Bitmap(hxd.Res.sprite_placeholder.toTile(), this);

        rowSun = new DetailRow(this, Sun);
        rowWater = new DetailRow(this, Droplet);
        rowSoil = new DetailRow(this, Map);
        rowClock = new DetailRow(this, Clock);

        effectText = new Text(hxd.Res.fonts.plex_mono_64.toFont(), this);
        effectText.textColor = 0xCCCCCC;
        effectText.scaleX = 0.30;
        effectText.scaleY = 0.30;
        effectText.maxWidth = Std.int(widthPx - 24);
    }

    public function setSeed(seed:PlantType, count:Int) {
                title.text = seed.name + " (x" + count + ")";
        title.textColor = rarityColor(seed.rarity);
        title.x = Std.int((widthPx - title.textWidth * title.scaleX) / 2);
        title.y = 12;

                var imgScale = Math.min((widthPx * 0.5) / image.tile.width, (heightPx * 0.35) / image.tile.height);
        image.scaleX = imgScale;
        image.scaleY = imgScale;
        image.x = Std.int((widthPx - image.tile.width * imgScale) / 2);
        image.y = Std.int(title.y + title.textHeight * title.scaleY + 10);

        var rowsStartY = Std.int(image.y + image.tile.height * imgScale + 10);
        var rowGap = 8;

        rowSun.setText(sunText(seed.sunNeeded));
        rowSun.setPosition(12, rowsStartY);
        rowSun.setWidth(Std.int(widthPx - 24));

        rowWater.setText(waterText(seed));
        rowWater.setPosition(12, rowsStartY + rowSun.height() + rowGap);
        rowWater.setWidth(Std.int(widthPx - 24));

        rowSoil.setText(soilText(seed));
        rowSoil.setPosition(12, rowWater.y() + rowWater.height() + rowGap);
        rowSoil.setWidth(Std.int(widthPx - 24));

        rowClock.setText("Germinates in " + seed.germTimeQD + " QD");
        rowClock.setPosition(12, rowSoil.y() + rowSoil.height() + rowGap);
        rowClock.setWidth(Std.int(widthPx - 24));

        effectText.text = effectTextFor(seed);
        effectText.x = 12;
        effectText.y = rowClock.y() + rowClock.height() + 10;
    }

    static function rarityColor(r:Rarity):Int {
        return switch (r) {
            case Common:    0xB0C4DE;             case Uncommon:  0x67E480;             case Rare:      0x5EA0FF;             case Epic:      0xC77DFF;             case Legendary: 0xFFD700;         }
    }

    static function sunText(sunNeeded:Int):String {
        if (sunNeeded <= 3) return "Low Sun";
        if (sunNeeded <= 6) return "Normal Sun";
        return "High Sun";
    }

    static function waterText(seed:PlantType):String {
        if (seed.soilWhitelist != null)
            for (s in seed.soilWhitelist) if (s == SoilType.Water) return "Hydrophyte";
        var min = seed.waterReq.min;
        var max = seed.waterReq.max;
        if (max <= 0.3) return "Dry";
        if (min >= 0.7) return "Wet";
        return "Normal";
    }

    static function soilText(seed:PlantType):String {
        if (seed.soilWhitelist == null || seed.soilWhitelist.length == 0) return "Any";
        return seed.soilWhitelist.map(s -> Std.string(s)).join(", ");
    }

    static function effectTextFor(seed:PlantType):String {
        if (seed.effect == null)
            return "No special effect.";
        var e = seed.effect;
        return switch (e.kind) {
            case Passive: "Passive effect.";
            case OnDayTick: "Triggers each day.";
            case Activatable:
                var cd = e.cooldownQD;
                (cd > 0 ? "Activatable (" + cd + " QD cooldown)." : "Activatable.");
            case Combat: "Combat effect.";
        }
    }
}

private enum DetailIconKind { Sun; Droplet; Map; Clock; }

private class DetailRow {
    var root:Object;
    var iconBmp:Bitmap;
    var text:Text;
    var iconKind:DetailIconKind;
    var rowH:Int = 28;
    var iconSize:Int = 20;
    var _x:Int = 0;
    var _y:Int = 0;
    var _w:Int = 0;

    public function new(parent:Object, iconKind:DetailIconKind) {
        root = new Object(parent);
        iconBmp = new Bitmap(null, root);
        text = new Text(hxd.Res.fonts.plex_mono_64.toFont(), root);
        text.textColor = 0xE0E0E0;
        text.scaleX = 0.30;
        text.scaleY = 0.30;
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
            case Map: Icons.soil();
            case Clock: Icons.time();
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

