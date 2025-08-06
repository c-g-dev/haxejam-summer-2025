package overlay;

import h2d.Object;
import space.Planet;
import effects.GhostTrailCentered;

class MechSpriteOverlay extends Object {
    var planet: Planet;
    public function new(planet: Planet) {
        super();
        this.planet = planet;
        var bmp = new h2d.Bitmap(hxd.Res.guy.toTile());
        this.addChild(bmp);

        var ghost = new GhostTrailCentered(bmp, () -> {
            if(planet.cameraMover.currentMove != null && !planet.cameraMover.currentMove.isComplete && planet.cameraMover.currentTarget != null) {
                var screenPos = planet.cameraMover.projectToScreen();
                screenPos.x -= hxd.Window.getInstance().width / 2;
                screenPos.y -= hxd.Window.getInstance().height / 2;
                screenPos.normalize();
                screenPos.scale(3);
                return {dx: screenPos.x, dy: screenPos.y};
            }
            return {dx: 0, dy: 0};
        });
        addChild(ghost);

        //center this in screen
        this.x = (hxd.Window.getInstance().width / 2) - (this.getBounds().width / 2);
        this.y = (hxd.Window.getInstance().height / 2) - (this.getBounds().height / 2);
    }
}