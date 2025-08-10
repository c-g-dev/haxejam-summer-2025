package overlay;

import ludi.commons.math.Vec2;
import h2d.Object;
import space.Planet;
import effects.GhostTrailCentered;
import h2d.Tile;
import hxd.snd.Channel;

enum Facing { Left; Right; Up; Down; Stopped; }

class MechSpriteOverlay extends Object {

    var planet: Planet;
    var bmp: h2d.Bitmap;
    var lastFacing: Facing = Stopped;

    var baseTile: Tile;
    var moveLeftTile: Tile;
    var moveRightTile: Tile;

    var engineChannel: Channel; 
    public dynamic function onFacingChanged(f: Facing): Void {}

    public function new(planet: Planet) {
        super();
        this.planet = planet;

        baseTile = hxd.Res.guy.guy.toTile();
        moveLeftTile = hxd.Res.guy.guymoveleft.toTile();
        moveRightTile = hxd.Res.guy.guymoveright.toTile();

        bmp = new h2d.Bitmap(baseTile);
        bmp.scaleX = 0.3;
        bmp.scaleY = 0.3;
        this.addChild(bmp);

        var ghost = new GhostTrailCentered(bmp, () -> {
            if(planet.cameraMover.currentMove != null && !planet.cameraMover.currentMove.isComplete && planet.cameraMover.currentTarget != null) {
                var screenPos = planet.cameraMover.projectToScreen();
                var cx = hxd.Window.getInstance().width / 2;
                var cy = hxd.Window.getInstance().height / 2;
                var dx = screenPos.x - cx;
                var dy = screenPos.y - cy;
                screenPos = new Vec2(dx, dy).normalize();
                screenPos = screenPos.scale(3);
                return {dx: screenPos.x, dy: screenPos.y};
            }
            return {dx: 0, dy: 0};
        });
        addChild(ghost);

                this.x = (hxd.Window.getInstance().width / 2) - (this.getBounds().width / 2);
        this.y = (hxd.Window.getInstance().height / 2) - (this.getBounds().height / 2);
    }

    public function updateFacingFromCamera(): Void {
        var newFacing = computeFacing();
        if (newFacing != lastFacing) {
            lastFacing = newFacing;
            applyFacingVisual(newFacing);
            onFacingChanged(newFacing);
        }
    }

    inline function computeFacing(): Facing {
        var moving = planet.cameraMover.currentMove != null && !planet.cameraMover.currentMove.isComplete && planet.cameraMover.currentTarget != null;
        if (!moving) return Stopped;

        var screenPos = planet.cameraMover.projectToScreen();
        var cx = hxd.Window.getInstance().width / 2;
        var cy = hxd.Window.getInstance().height / 2;
        var dx = screenPos.x - cx;
        var dy = screenPos.y - cy;
        var mag = Math.sqrt(dx*dx + dy*dy);
        if (mag < 1e-3) return Stopped;
                if (Math.abs(dx) >= Math.abs(dy)) {
            return dx >= 0 ? Right : Left;
        } else {
            return dy >= 0 ? Down : Up;
        }
    }

    function setEnginePlaying(on:Bool):Void {
        if (on) {
            if (engineChannel == null) {
                engineChannel = hxd.Res.engine.play(true, 0.3);
            }
        } else {
            if (engineChannel != null) {
                engineChannel.stop();
                engineChannel = null;
            }
        }
    }

    function applyFacingVisual(f: Facing): Void {
        switch f {
            case Left:
                bmp.tile = moveLeftTile;
                setEnginePlaying(true);
            case Right:
                bmp.tile = moveRightTile;
                setEnginePlaying(true);
            case Up | Down:
                bmp.tile = baseTile;
                setEnginePlaying(true);
            case Stopped:
                bmp.tile = baseTile;
                setEnginePlaying(false);
        }
    }
}