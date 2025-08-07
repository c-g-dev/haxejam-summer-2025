import state.HState.HStateManager;
import state.HState;
import state.SplashState;

class StateTestMain extends hxd.App {

    

    override function init() {
        hxd.Res.initEmbed();
        
        HStateManager.app = this;

        var splash1 = new h2d.Bitmap(hxd.Res.guy.toTile());
        var splash2 = new h2d.Bitmap(hxd.Res.palettetown.toTile());

        var splashState1 = new SplashState(splash1, new SplashState(splash2, new MainState()));

        HStateManager.setState(splashState1);
    }

    override function update(dt:Float) {
        HStateManager.update(dt);
    }

    public static function main() {
        new StateTestMain();
    }
}