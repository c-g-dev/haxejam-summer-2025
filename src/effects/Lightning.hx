package effects;

import h2d.filter.Blur;
import hxd.Timer;
import h2d.Object;
import h2d.Graphics;
import h2d.filter.Glow;
import hxd.Math;

class Lightning extends Object {

//---------------------------------------------
// public parameters you can tweak at runtime
//---------------------------------------------
public var startX : Float;
public var startY : Float;
public var endX   : Float;
public var endY   : Float;

public var lineColor   : Int     = 0x66CCFF;
public var thickness   : Int     = 2;
public var segments    : Int     = 24;
public var maxJitter   : Float   = 8;
public var speed       : Float   = 5;
public var glowRadius  : Float   = 12;

//---------------------------------------------
var gfx : Graphics;

public function new(parent:Object,
                    startX:Float, startY:Float,
                    endX:Float,   endY:Float)
{
	super(parent);

	this.startX = startX;
	this.startY = startY;
	this.endX   = endX;
	this.endY   = endY;

	gfx = new Graphics(parent);
	// Pre-draw once so bounds are valid before filter runs
	//update(0);
}

	//---------------------------------------------
	// Call once per frame
	//---------------------------------------------
	public function update(dt:Float) {
		gfx.clear();
		gfx.lineStyle(thickness, lineColor);

		// unit perpendicular to main segment
		var dx  = endX - startX;
		var dy  = endY - startY;
		var len = Math.sqrt(dx*dx + dy*dy);
		if (len == 0) return;
		var perpX = -dy / len;
		var perpY =  dx / len;

		gfx.moveTo(startX, startY);

		for (i in 1...segments) {
			var t = i / (segments - 1);
			var bx = startX + dx * t;
			var by = startY + dy * t;

			var jitter = (Math.sin(Timer.elapsedTime * speed + i*1.3)
						+ (Math.random()*2 - 1)) * maxJitter;

			var x = bx + perpX * jitter;
			var y = by + perpY * jitter;

			gfx.lineTo(x, y);
		}
	}
}