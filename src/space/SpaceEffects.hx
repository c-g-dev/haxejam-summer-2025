package space;

import heaps.coroutine.Coro;
import heaps.coroutine.Future;
import heaps.coroutine.Coroutine.CoroutineContext;
import h3d.Quat;
import h3d.Matrix;

class SpaceEffects {

    var planet: Planet;

    public function new(planet: Planet) {
        this.planet = planet;
    }

    // Tween the planet and camera around Y by exactly 90 degrees in-place, then resolve.
    public function rotatePlanetQuarterTurn(durationSeconds: Float = 0.6): Future {
        var targetAngle = Math.PI / 2; // 90 degrees in radians
        if (durationSeconds <= 0) {
            // rotate scene about origin without changing camera-to-origin distance
            rotateSceneY(targetAngle);
            return Future.immediate();
        }

        var rotated = 0.0;
        var speed = targetAngle / durationSeconds; // radians per second
        return Coro.start((ctx: CoroutineContext) -> {
            var step = speed * ctx.dt;
            var remaining = targetAngle - rotated;
            if (step < remaining) {
                rotateSceneY(step);
                rotated += step;
                return WaitNextFrame;
            }
            // Final snap to ensure exact 90°
            rotateSceneY(remaining);
            return Stop;
        }).future();
    }

    inline function rotateSceneY(angle: Float): Void {
        if (angle == 0) return;
        // 1) Rotate planet object (sphere, grid, overlays all children)
        planet.rotate(0, angle, 0);
        // 2) Rotate camera around origin by the same angle so relative view of the planet stays identical
        var cam = planet.getScene().camera;
        var q = new Quat();
        q.initRotateAxis(0, 1, 0, angle);
        var m = new Matrix();
        q.toMatrix(m);
        cam.pos.transform(m);
        cam.target.set(0, 0, 0);
        cam.update();
    }
}

