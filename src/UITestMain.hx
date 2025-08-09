import state.HState.HStateManager;
import state.StartMenuState;


class UITestMain extends hxd.App {

    var stars: space.Stars;

    override function init() {
        hxd.Res.initEmbed();

       HStateManager.app = this;
          
       
       var startMenu = new StartMenuState();
        HStateManager.setState(startMenu);

    }

    override function update(dt:Float) {
       HStateManager.update(dt);
    }

    public static function main() {
        new UITestMain();
    }

    public function new() {
        super();
        // Use default material setup to avoid PBR pipeline requirements during the test
        h3d.mat.MaterialSetup.current = new h3d.mat.PbrMaterialSetup();
    }
}