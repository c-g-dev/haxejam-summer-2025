package ludi.heaps;

import h2d.RenderContext;

class Behavior extends Node {
    public var active: Bool = true;

    public function new(?onFrame: Float -> Void) {
        super();
        if (onFrame != null) {
            this.onFrame = onFrame;
        }
    }

    public override function sync(ctx:RenderContext) {
        super.sync(ctx);
        if(active) {
            onFrame(ctx.elapsedTime);
        }
    }

    public dynamic function onFrame(dt:Float) {}
}