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
        q.project(camera.m);                         return new Vec2(
            ( q.x * 0.5 + 0.5 ) * hxd.Window.getInstance().width,
            (-q.y * 0.5 + 0.5 ) * hxd.Window.getInstance().height
        );
    }


    
    static function slerp(u:h3d.Vector, v:h3d.Vector, t:Float):h3d.Vector {
                var dot = Math.max(-1.0, Math.min(1.0, u.dot(v)));
        var theta = Math.acos(dot);                         if (theta < 1e-4){
            var c = u.clone();
            c.lerp(u, v, t);    
            return c;
        }                           
        var sinT = Math.sin(theta);
        var w1 = Math.sin((1 - t) * theta) / sinT;
        var w2 = Math.sin(t * theta)       / sinT;

        return new h3d.Vector(
            u.x * w1 + v.x * w2,
            u.y * w1 + v.y * w2,
            u.z * w1 + v.z * w2
        );
    }


    public function moveToTriangle(idx:Int, speed:Float):Future {
        var tgt = planet.getTriangleCenter(idx);
        return moveCameraTo(tgt, speed);
    }

    
    public function moveCameraTo(target:h3d.Vector, speed:Float):Future {

                                var startPos   = camera.pos.clone();
        var radius     = startPos.length();                 var startDir   = startPos.clone(); startDir.normalize();
        var targetDir  = target.clone();  targetDir.normalize();

                var angle      = Math.acos(Math.max(-1, Math.min(1, startDir.dot(targetDir))));
        var arcLength  = angle * radius;            
        var duration   = (speed <= 0) ? 0 : arcLength / speed;
        if (duration == 0) {
            camera.pos.load(target);
            camera.update();
            return Future.immediate();
        }

                                var elapsed = 0.0;
        var newMove = Coro.start((ctx: heaps.coroutine.Coroutine.CoroutineContext) -> {
            elapsed += ctx.dt;
            var t = elapsed / duration;         
            if (t < 1) {
                var dir = slerp(startDir, targetDir, t);
                dir.scale(radius);
                camera.pos.load(dir);
                camera.target.set(0,0,0);                           camera.update();
                return WaitNextFrame;
            }

                        targetDir.scale(radius);
            camera.pos.load(targetDir);
            camera.target.set(0,0,0);
            camera.update();
            return Stop;
        }).future();

                cast currentMove   = newMove;
        currentTarget = target;
        return cast newMove;
    }
}