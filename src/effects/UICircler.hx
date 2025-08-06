package effects;

// ui/UICircler.hx
package ui;

import h2d.Object;
import h2d.Ease;
import h2d.Scene;
import h2d.Tween;     // Heaps built-in tween helper
import haxe.ds.ArrayIterator;

class UICircler extends Object {
	/**
	 * How far the objects will travel from the circler’s center.
	 */
	public var radius : Float;

	/**
	 * Seconds the tween takes.
	 */
	public var duration : Float = 0.35;

	/**
	 * Easing function used for the tween.
	 */
	public var ease : Ease = Ease.quadOut;

	/**
	 * Internal storage of children + their final scale.
	 */
	var items : Array<{ obj:Object, targetScale:Float }> = [];

	/**
	 * @param parent     where the circler itself will be added to.
	 * @param x,y        position of the circler.
	 * @param radius     distance from centre to which the items should fly.
	 */
	public function new( parent:Object, x:Float, y:Float, radius:Float = 120 ) {
		super( parent );
		this.x = x;
		this.y = y;
		this.radius = radius;
	}

	public function addItem( obj:Object, targetScale:Float = 1 ) {
		items.push( { obj: obj, targetScale: targetScale } );
		addChild( obj );               // re-parent under the circler
		obj.setPosition( 0, 0 );
		obj.setScale( 0 );
	}

	public function start(): Future {
		if ( items.length == 0 ) return Future.immediate();

		final count = items.length;
		final step  = (count == 1) ? 0 : (Math.PI * 2) / count; // angular distance
		final base  = -Math.PI/2;         
        
        var coros: Array<Coroutine> = [];

		for (i in 0...count) {
			var item = items[i];
			var angle = base + i * step;
			var tx = Math.cos(angle) * radius;
			var ty = Math.sin(angle) * radius;


            coros.push(Coro.defer((ctx) -> {
                if(ctx.dt >= duration) {
                    item.obj.x = tx;
                    item.obj.y = ty;
                    item.obj.scaleX = item.targetScale;
                    item.obj.scaleY = item.targetScale;
                    return Stop;
                }
                var currentRadius = ctx.dt / duration * radius;
                item.obj.x = Math.cos(angle) * currentRadius;
                item.obj.y = Math.sin(angle) * currentRadius;
                item.obj.scaleX = item.targetScale * ctx.dt / duration;
                item.obj.scaleY = item.targetScale * ctx.dt / duration;
                return WaitNextFrame;
            }));
		}

        return new Parallel(coros).future();
	}

	public function reset( withScale:Bool = true ) {
		for (item in items) {
			item.obj.setPosition( 0, 0 );
			if (withScale) item.obj.setScale( 0 );
		}
	}
}