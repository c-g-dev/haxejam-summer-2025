package ludi.heaps.grid;

import ludi.commons.UUID;
import ludi.heaps.grid.Actor.IGridActor;
import ludi.heaps.grid.Mover.GridActorMover;
import ludi.heaps.grid.Driver.IGridActorDriver;
import ludi.heaps.grid.Animator.IGridActorAnimator;
import ludi.heaps.grid.Driver.MoveRequest;
import ludi.heaps.grid.Mover.MoveDirection;

class BasicGridActor extends h2d.Object implements IGridActor {
    public var uuid(default, null): String;
    public var mover: GridActorMover;
    public var speed(default, set):Float = 2.0;
    function set_speed(s:Float):Float {
        return this.speed = s;
    }


    public function new() {
        super();
        uuid = UUID.generate();
        mover = new GridActorMover(this, new BasicGridAnimator(this), new BasicGridDriver(this));
    }

    public function getSprite():h2d.Object {
        return this;
    }

    public function updateSpritePosition(x: Float, y: Float): Void {
        this.x = Std.int(x);
        this.y = Std.int(y);
    }
}


class BasicGridDriver implements IGridActorDriver {

    var actor:IGridActor;
    public function new(actor:IGridActor) {
        this.actor = actor;
    }

    public function currentMoveRequest(): MoveRequest {
        if(hxd.Key.isDown(hxd.Key.LEFT)) return MoveRequest.Walk(MoveDirection.Left);
        if(hxd.Key.isDown(hxd.Key.RIGHT)) return MoveRequest.Walk(MoveDirection.Right);
        if(hxd.Key.isDown(hxd.Key.UP)) return MoveRequest.Walk(MoveDirection.Up);
        if(hxd.Key.isDown(hxd.Key.DOWN)) return MoveRequest.Walk(MoveDirection.Down);
        return MoveRequest.None;
    }
}

class BasicGridAnimator implements IGridActorAnimator {

    var actor:IGridActor;
    public function new(actor:IGridActor) {
        this.actor = actor;
    }

    public function playWalk(dir: MoveDirection): Void {
    }

    public function playIdle(): Void {
    }
}
