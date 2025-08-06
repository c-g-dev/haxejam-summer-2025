package ludi.heaps.grid;

import ludi.heaps.grid.Mover.GridActorMover;
import ludi.heaps.grid.Driver.IGridActorDriver;
import ludi.heaps.grid.Driver.MoveRequest;
import ludi.heaps.grid.Animator.IGridActorAnimator;
import ludi.heaps.grid.Mover.MoveDirection;
import ludi.heaps.grid.Actor.IGridActor;

class HeadlessGridActor implements IGridActor {
    public var uuid(default, null): String;
    public var mover: GridActorMover;
    public var x: Float = 0;
    public var y: Float = 0;
    
    public function new(uuid: String) {
        this.uuid = uuid;
        var driver = new HeadlessGridDriver();
        var animator = new HeadlessGridAnimator();
        this.mover = new GridActorMover(this, animator, driver);
    }
    
    public function updateSpritePosition(x: Float, y: Float): Void {
        this.x = x;
        this.y = y;
    }
    
    public function getDriver(): HeadlessGridDriver {
        return cast @:privateAccess mover.driver;
    }
}

class HeadlessGridDriver implements IGridActorDriver {
    public var current: MoveRequest = None;
    
    public function new() {}

    public function currentMoveRequest(): MoveRequest {
        return current;
    }
    
    public function requestMove(dir: MoveDirection): Void {
        current = Walk(dir);
    }
    
    public function requestStand(dir: MoveDirection): Void {
        current = Stand(dir);
    }
    
    public function clearRequest(): Void {
        current = None;
    }
}

class HeadlessGridAnimator implements IGridActorAnimator {
    public var lastPlayedAnimation: String = "idle";
    public var lastDirection: Null<MoveDirection> = null;
    
    public function new() {}
    
    public function playWalk(dir: MoveDirection): Void {
        lastPlayedAnimation = "walk";
        lastDirection = dir;
    }
    
    public function playIdle(): Void {
        lastPlayedAnimation = "idle";
        lastDirection = null;
    }
}

