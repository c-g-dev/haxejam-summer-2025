package effects;

import h2d.Bitmap;
import h2d.BlendMode;
import hxd.Timer;

private typedef Ghost = {
    var sprite:Bitmap;
    var timeLeft:Float;
}

class GhostTrail extends h2d.Object {
	/* the sprite we want to copy every couple of frames */
	public var target:h2d.Bitmap;

	
	public var spawnDelay:Float = 0.04;

	
	public var lifeTime:Float = 0.30;

	
	public var startAlpha:Float = 0.70;

	
	public var minSpeed:Float = 5;

		var _accum:Float = 0; 	var _ghostPool:Array<Ghost> = []; 
	public function new(target:h2d.Bitmap) {
		super();
		this.target = target;
	}

    var previousTargetX:Float = 0;
    var previousTargetY:Float = 0;

	override function sync(ctx:h2d.RenderContext) {
		var dt = Timer.dt;

								_accum += dt;
		var vx = target.x - previousTargetX;
		var vy = target.y - previousTargetY;

		if (_accum >= spawnDelay && Math.sqrt(vx * vx + vy * vy) > minSpeed) {
			_accum -= spawnDelay;
			spawnGhost();
		}

								for (i in _ghostPool.copy()) {
			i.timeLeft -= dt;
			if (i.timeLeft <= 0) {
				i.sprite.remove();
				_ghostPool.remove(i);
			} else
				i.sprite.alpha = startAlpha * (i.timeLeft / lifeTime);
		}

		super.sync(ctx);
	}

	
	inline function spawnGhost() {
		var g = new h2d.Bitmap(target.tile, this);
		g.setPosition(target.x, target.y);
		g.rotation = target.rotation;
        g.scaleX = target.scaleX;
        g.scaleY = target.scaleY;

		g.alpha = startAlpha;
		g.blendMode = BlendMode.Add; 
		_ghostPool.push({sprite: g, timeLeft: lifeTime});
	}


}
