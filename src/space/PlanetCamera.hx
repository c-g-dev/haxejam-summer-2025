package space;

import ludi.commons.math.Vec2;
import hxd.WaitEvent;
import heaps.coroutine.Coro;
import heaps.coroutine.Future;

class PlanetCamera {
    public var currentMove : Future;
    public var currentTarget : h3d.Vector;

    public var planet  : Planet;
    public var camera  : h3d.Camera;

    public function new(planet:Planet, camera:h3d.Camera) {
        this.planet  = planet;
        this.camera  = camera;
    }

    public inline function projectToScreen() : Vec2 {
        var q = currentTarget.clone();
        q.project(camera.m);                 // => NDC (-1 … 1)
        return new Vec2(
            ( q.x * 0.5 + 0.5 ) * hxd.Window.getInstance().width,
            (-q.y * 0.5 + 0.5 ) * hxd.Window.getInstance().height
        );
    }

    /* ------------------------------------------------------------------
       Helpers
       ------------------------------------------------------------------ */

    /** Classic SLERP between two unit vectors. */
    static function slerp(u:h3d.Vector, v:h3d.Vector, t:Float):h3d.Vector {
        // Clamp the dot product so acos is always valid
        var dot = Math.max(-1.0, Math.min(1.0, u.dot(v)));
        var theta = Math.acos(dot);                 // angle between the two
        if (theta < 1e-4){
            var c = u.clone();
            c.lerp(u, v, t);    
            return c;
        }                           // almost the same dir

        var sinT = Math.sin(theta);
        var w1 = Math.sin((1 - t) * theta) / sinT;
        var w2 = Math.sin(t * theta)       / sinT;

        return new h3d.Vector(
            u.x * w1 + v.x * w2,
            u.y * w1 + v.y * w2,
            u.z * w1 + v.z * w2
        );
    }

    /* ------------------------------------------------------------------
       Public API
       ------------------------------------------------------------------ */

    public function moveToTriangle(idx:Int, speed:Float):Future {
        var tgt = planet.getTriangleCenter(idx);
        return moveCameraTo(tgt, speed);
    }

    /**
     * Move the camera from its current position to the given point
     * on a great-circle arc, at the requested *linear* speed (units / second).
     */
    public function moveCameraTo(target:h3d.Vector, speed:Float):Future {

        // ----------------------------------------------------------------
        // 1. Prepare data
        // ----------------------------------------------------------------
        var startPos   = camera.pos.clone();
        var radius     = startPos.length();         // keep this constant
        var startDir   = startPos.clone(); startDir.normalize();
        var targetDir  = target.clone();  targetDir.normalize();

        // Angular distance & arc length
        var angle      = Math.acos(Math.max(-1, Math.min(1, startDir.dot(targetDir))));
        var arcLength  = angle * radius;            // metres along the sphere

        var duration   = (speed <= 0) ? 0 : arcLength / speed;
        if (duration == 0) {
            camera.pos.load(target);
            camera.update();
            return Future.immediate();
        }

        //-----------------------------------------------------------------
        // 2. Coroutine
        //-----------------------------------------------------------------
        var elapsed = 0.0;
        var newMove = Coro.start((ctx: heaps.coroutine.Coroutine.CoroutineContext) -> {
            elapsed += ctx.dt;
            var t = elapsed / duration;         // 0 … 1

            if (t < 1) {
                var dir = slerp(startDir, targetDir, t);
                dir.scale(radius);
                camera.pos.load(dir);
                camera.target.set(0,0,0);           // always look at planet
                camera.update();
                return WaitNextFrame;
            }

            // Final snap
            targetDir.scale(radius);
            camera.pos.load(targetDir);
            camera.target.set(0,0,0);
            camera.update();
            return Stop;
        }).future();

        // cancel / chain earlier moves if you want
        cast currentMove   = newMove;
        currentTarget = target;
        return cast newMove;
    }
}