import state.HState.HStateManager;
import state.StartMenuState;


class UITestMain extends hxd.App {

    override function init() {
        hxd.Res.initEmbed();

        HStateManager.app = this;
       
        var startMenu = new StartMenuState();
        HStateManager.setState(startMenu);

        
        /*
        var text = new h2d.Text(hxd.Res.fonts.plex_mono_64.toFont(), s2d);
        text.text = "Hello, World!";
        text.textColor = 0xFFFFFF;
        text.x = 100;
        text.y = 100;
        text.scaleX = 0.5;
        text.scaleY = 0.5;
        */
        //s2d.filter = new FXAAFilter();
    }

    override function update(dt:Float) {
        HStateManager.update(dt);
    }

    public static function main() {
        new UITestMain();
    }
}