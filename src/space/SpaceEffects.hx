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

        public function rotatePlanetQuarterTurn(durationSeconds: Float = 0.6): Future {
        var targetAngle = Math.PI / 2;         if (durationSeconds <= 0) {
                        rotateSceneY(targetAngle);
            return Future.immediate();
        }

        var rotated = 0.0;
        var speed = targetAngle / durationSeconds;         return Coro.start((ctx: CoroutineContext) -> {
            var step = speed * ctx.dt;
            var remaining = targetAngle - rotated;
            if (step < remaining) {
                rotateSceneY(step);
                rotated += step;
                return WaitNextFrame;
            }
                        rotateSceneY(remaining);
            return Stop;
        }).future();
    }

    inline function rotateSceneY(angle: Float): Void {
        if (angle == 0) return;
                planet.rotate(0, angle, 0);
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

