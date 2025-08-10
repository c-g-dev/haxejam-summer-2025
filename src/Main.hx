import overlay.MechSpriteOverlay;
import space.Planet;
import space.Sun;
import hxd.Key;
import heaps.coroutine.Coroutine.FrameYield;
import heaps.coroutine.Sequence;
import heaps.coroutine.Coro;
import h3d.scene.fwd.DirLight;
import h3d.scene.*;
import h3d.prim.*;
import hxd.Event;
import h2d.Text;

class Main extends hxd.App {

    
    var planet: Planet;

    
    override function init() {
        hxd.Res.initEmbed();

        var dirLight = new DirLight(new h3d.Vector(0.5, 0.5, -0.5), s3d);
        dirLight.enableSpecular = true;

        planet = new Planet(s3d, s2d, s3d.camera);
        
        s3d.camera.pos.set(0, 0, 5);
        s3d.camera.target.set(0, 0, 0);

        s3d.addChild(new Sun(s3d));

        s2d.addChild(new MechSpriteOverlay(planet));

    }

    static function main() {
        new Main();
    }

    public function new() {
        super();
        h3d.mat.MaterialSetup.current = new h3d.mat.PbrMaterialSetup();
    }

    var currentTri: Int = 0;

    override function update(dt: Float) {
        var rotationSpeed = 2.0;         var q_delta = new h3d.Quat();
        q_delta.identity();
        
        if(Key.isPressed(Key.UP)) {
            planet.cameraMover.moveToTriangle(currentTri++, 2);
        }

        /*
        if (Key.isDown(Key.LEFT)) {
            var q_temp = new h3d.Quat();
            q_temp.initRotateAxis(0, 1, 0, rotationSpeed * dt);
            q_delta.multiply(q_delta, q_temp);
        }
        if (Key.isDown(Key.RIGHT)) {
            var q_temp = new h3d.Quat();
            q_temp.initRotateAxis(0, 1, 0, -rotationSpeed * dt);
            q_delta.multiply(q_delta, q_temp);
        }
        
        if (Key.isDown(Key.UP)) {
            var q_temp = new h3d.Quat();
            q_temp.initRotateAxis(1, 0, 0, -rotationSpeed * dt);             q_delta.multiply(q_delta, q_temp);
        }
        if (Key.isDown(Key.DOWN)) {
            var q_temp = new h3d.Quat();
            q_temp.initRotateAxis(1, 0, 0, rotationSpeed * dt);
            q_delta.multiply(q_delta, q_temp);
        }

        
        
        
                var q_inv = q_delta.clone();
        q_inv.conjugate();
        var m = new h3d.Matrix();
        q_inv.toMatrix(m);
        
        s3d.camera.pos.transform(m);

                */
        
        if (Key.isDown(Key.SPACE)) {
            s3d.camera.zoom += 0.1;
        }
        if (Key.isDown(Key.SHIFT)) {
            s3d.camera.zoom -= 0.1;
        }

        planet.updateLabels(s3d.camera, s2d);
    }
        
    
}