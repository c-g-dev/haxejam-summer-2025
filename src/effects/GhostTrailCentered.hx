package effects;

import h2d.Bitmap;
import h2d.BlendMode;
import hxd.Timer;


private typedef Ghost = {
	var sp:h2d.Object;
	var timeLeft:Float;
	var vx:Float;
	var vy:Float;
}

class GhostTrailCentered extends h2d.Object {
	/* The sprite that sits in the centre of the screen */
	public var target:h2d.Bitmap;

	/* Called each frame – you return the camera/world delta (dx,dy) */
	public var getScroll:Void->{dx: Float, dy: Float};

	public var spawnDelay = 0.1;
	public var lifeTime = 0.30;
	public var startAlpha = 0.70;

	var _accum = 0.0;
	var _ghosts:Array<Ghost> = [];

	public function new(target:h2d.Bitmap, getScroll) {
		super();
		this.target = target;
		this.getScroll = getScroll;
	}

	override function sync(ctx:h2d.RenderContext) {
		super.sync(ctx);
		var dt = Timer.dt;
		_accum += dt;

		/* camera speed the last frame */
		var cam = getScroll();

		/* If the scenery is scrolling, create a new copy every spawnDelay */
		if (_accum >= spawnDelay && (cam.dx * cam.dx + cam.dy * cam.dy) > 0) {
			_accum -= spawnDelay;
			trace("spawning ghost: " + -cam.dx);
			spawnGhost(-cam.dx, -cam.dy); // opposite direction of scrolling
		}

		/* Update existing ghosts */
		for (g in _ghosts.copy()) {
			g.timeLeft -= dt;
			if (g.timeLeft <= 0) {
				g.sp.remove();
				_ghosts.remove(g);
				continue;
			}

			/* Move the ghost along its stored velocity */
			g.sp.x += g.vx;
			g.sp.y += g.vy;

			trace("ghost: " + g.sp.x + ", " + g.sp.y + " " + g.vx + " " + g.vy);

			/* Fade it out */
			g.sp.alpha = startAlpha * (g.timeLeft / lifeTime);
		}

	
	}

	function spawnGhost(vx:Float, vy:Float) {
		var s = new h2d.Bitmap(target.tile, this);
		//s.setPosition(target.x, target.y); // same spot as the mech
		s.rotation = target.rotation;
		s.scaleX = target.scaleX;
		s.scaleY = target.scaleY;
		s.alpha = startAlpha;
		s.blendMode = BlendMode.Add;
		s.color = new h3d.Vector4( 0.85, 0.25, 1.0, 1.0 );

		_ghosts.push({
			sp: s,
			timeLeft: lifeTime,
			vx: vx,
			vy: vy
		});
	}
}
