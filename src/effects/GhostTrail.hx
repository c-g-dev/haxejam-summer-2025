package effects;

import h2d.Bitmap;
import h2d.BlendMode;
import hxd.Timer;

// A tiny structure that remembers the fading sprite + its remaining life
private typedef Ghost = {
    var sprite:Bitmap;
    var timeLeft:Float;
}

class GhostTrail extends h2d.Object {
	/* the sprite we want to copy every couple of frames */
	public var target:h2d.Bitmap;

	/** seconds between two copies                                   */
	public var spawnDelay:Float = 0.04;

	/** how long one copy lives (in seconds)                          */
	public var lifeTime:Float = 0.30;

	/** start alpha of a fresh copy                                   */
	public var startAlpha:Float = 0.70;

	/** minimum speed at which ghosting is active                     */
	public var minSpeed:Float = 5;

	// --------------------------------------------------------------------
	var _accum:Float = 0; // time accumulator
	var _ghostPool:Array<Ghost> = []; // active ghosts

	public function new(target:h2d.Bitmap) {
		super();
		this.target = target;
	}

    var previousTargetX:Float = 0;
    var previousTargetY:Float = 0;

	override function sync(ctx:h2d.RenderContext) {
		var dt = Timer.dt;

		// ----------------------------------------------------------------
		// Do we want to spawn a new copy?
		// ----------------------------------------------------------------
		_accum += dt;
		var vx = target.x - previousTargetX;
		var vy = target.y - previousTargetY;

		if (_accum >= spawnDelay && Math.sqrt(vx * vx + vy * vy) > minSpeed) {
			_accum -= spawnDelay;
			spawnGhost();
		}

		// ----------------------------------------------------------------
		// Update all ghosts
		// ----------------------------------------------------------------
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

	// --------------------------------------------------------------------

	inline function spawnGhost() {
		var g = new h2d.Bitmap(target.tile, this);
		g.setPosition(target.x, target.y);
		g.rotation = target.rotation;
        g.scaleX = target.scaleX;
        g.scaleY = target.scaleY;

		g.alpha = startAlpha;
		g.blendMode = BlendMode.Add; // Add, Screen or Alpha all look nice

		_ghostPool.push({sprite: g, timeLeft: lifeTime});
	}


}
