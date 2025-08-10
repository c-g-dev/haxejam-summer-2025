import state.PlanetaryState;
import state.OpeningCutsceneState;
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
         
             var startMenu = new OpeningCutsceneState();
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
        h3d.mat.MaterialSetup.current = new h3d.mat.PbrMaterialSetup();
    }
}