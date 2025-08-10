import haxe.Timer;
import effects.GhostTrailCentered;

class TestMain extends hxd.App {

    
    override function init() {
        hxd.Res.initEmbed();

        var test = new h2d.Bitmap(hxd.Res.guy.guy.toTile());
        test.x = 100;
        test.y = 100;
        var ghost = new GhostTrailCentered(test, () -> {return {dx: 10, dy: 0};});
        ghost.x = 100;
        ghost.y = 100;
        s2d.addChild(ghost);
        s2d.addChild(test);
    }

    public static function main() {
        new TestMain();
    }

}