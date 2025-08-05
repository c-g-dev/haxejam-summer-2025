package overlay;

import h2d.Object;

class MechSpriteOverlay extends Object {
    public function new() {
        super();
        this.addChild(new h2d.Bitmap(hxd.Res.sprite_placeholder.toTile()));

        //center this in screen
        this.x = (hxd.Window.getInstance().width / 2) - (this.getBounds().width / 2);
        this.y = (hxd.Window.getInstance().height / 2) - (this.getBounds().height / 2);
    }
}