import h2d.filter.Glow;
import hxd.Window;
import effects.Lightning;
import state.HState.HStateManager;
import state.StartMenuState;
import state.CombatState;


class UITestMain extends hxd.App {

    var stars: space.Stars;
    var lightning: Lightning;

    override function init() {
        hxd.Res.initEmbed();

       HStateManager.app = this;
          
       
       var startMenu = new CombatState();
    HStateManager.setState(startMenu);
    
       // lightning = new Lightning(s2d, 0, 0, Window.getInstance().width, Window.getInstance().height);



       

    }

    override function update(dt:Float) {
       HStateManager.update(dt);
       if(lightning != null) lightning.update(dt);
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