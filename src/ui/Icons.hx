package ui;

var _ICONS = [
    "water",
    "sun",
    "time",
    "soil",
    "phosphorus",
    "nitrogen",
    "potassium"
];

class Icons {
    private static var _TILE: h2d.Tile;
    private static var didInit = false;
    private static inline var ICON_SIZE: Int = 32;

    public static function init(){
        _TILE = hxd.Res.icons.toTile();
        didInit = true;
    }

    public static function getTile(name: String): h2d.Tile{
        if(!didInit) init();
        var index = _ICONS.indexOf(name);
        if(index < 0) throw 'Unknown icon: ' + name;

        var columns = Std.int(_TILE.width / ICON_SIZE);
        if(columns <= 0) throw 'Invalid icons texture width: ' + _TILE.width;

        var x = (index % columns) * ICON_SIZE;
        var y = Std.int(index / columns) * ICON_SIZE;
        return _TILE.sub(x, y, ICON_SIZE, ICON_SIZE);
    }

    public static function water(): h2d.Tile{
        return getTile("water");
    }

    public static function sun(): h2d.Tile{
        return getTile("sun");
    }

    public static function time(): h2d.Tile{
        return getTile("time");
    }

    public static function soil(): h2d.Tile{
        return getTile("soil");
    }

    public static function phosphorus(): h2d.Tile{
        return getTile("phosphorus");
    }

    public static function nitrogen(): h2d.Tile{
        return getTile("nitrogen");
    }

    public static function potassium(): h2d.Tile{
        return getTile("potassium");
    }
}