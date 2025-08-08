package overlay;

import h2d.Object;
import h2d.Bitmap;
import h2d.Text;
import hxd.Res;
import hxd.res.DefaultFont;

class WorldActionChoice extends Object {
    public var label:String;
    var icon:Bitmap;
    var text:Text;
    var selected:Bool = false;
    var baseScale:Float = 1.0;

    public dynamic function onSelected():Void {}

    public function new(label:String, ?parent:Object) {
        super(parent);
        this.label = label;

        icon = new Bitmap(Res.sprite_placeholder.toTile());
        addChild(icon);

        text = new Text(DefaultFont.get());
        text.text = label;
        text.textColor = 0xFFFFFF;
        text.dropShadow = { dx: 1, dy: 1, color: 0x000000, alpha: 1 };
        // center text under icon
        text.x = -Std.int(text.textWidth / 2);
        text.y = icon.getBounds().height + 4;
        addChild(text);

        // center icon around this node origin for nicer circling
        var b = icon.getBounds();
        icon.x = -Std.int(b.width / 2);
        icon.y = -Std.int(b.height / 2);

        setScale(baseScale);
    }

    public function setSelected(v:Bool):Void {
        selected = v;
        if (selected) {
            scaleX = baseScale * 1.15;
            scaleY = baseScale * 1.15;
            text.textColor = 0xFFD37A;
        } else {
            scaleX = baseScale;
            scaleY = baseScale;
            text.textColor = 0xFFFFFF;
        }
    }

    public function trigger():Void {
        onSelected();
    }
} 