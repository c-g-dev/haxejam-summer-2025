package ludi.heaps.grid;

import haxe.display.Display.Package;
import ludi.heaps.grid.Actor.IGridActor;
import ludi.heaps.grid.Cell;
import ludi.heaps.grid.Trigger.ITrigger;
import ludi.heaps.grid.Driver.IGridActorDriver;
import ludi.heaps.grid.Animator.IGridActorAnimator;
import heaps.coroutine.Future;
import ludi.heaps.grid.Trigger.TriggerEvent;
import ludi.heaps.grid.Grid.GridContainer;
import ludi.commons.math.MathTools;
import hxd.Math;

enum MoveTest {
    Blocked;
    Free;
    Trigger(trigger: ITrigger);
}

enum MoveState {
    Idle;
    Waiting;
    Stepping(t:Float);
}

enum abstract MoveDirection(Int) {
    var Up;
    var Down;
    var Left;
    var Right;

    public var dx(get, never): Int;
    public var dy(get, never): Int;

    function get_dx(): Int {
        return switch (abstract) {
            case Up: 0;
            case Down: 0;
            case Left: -1;
            case Right: 1;
            case _: 0;
        }
    }

    function get_dy(): Int {
        return switch (abstract) {
            case Up: -1;
            case Down: 1;
            case Left: 0;
            case Right: 0;
            case _: 0;
        }   
    }
}

class GridActorMover {
    var actor: IGridActor;
    var state: MoveState = Idle;
    var origin:Cell;
    var dest: Cell;
    var speed: Float = 1;
    var progress: Float = 0;
    var animator: IGridActorAnimator;
    var driver: IGridActorDriver;

    var stepPromise: Future;
    
    var prevTrigger:ITrigger;
    var nextTrigger:ITrigger;

    public function new(actor: IGridActor, animator: IGridActorAnimator, driver: IGridActorDriver) {
        this.actor = actor;
        this.animator = animator;
        this.driver = driver;
    }

    public function testCell(grid: Grid, x: Int, y: Int): MoveTest {
        return MoveTest.Free;
    }

    public function updateSpritePosition(grid: Grid, origin: Cell, dest: Cell, progress: Float): Void {
        var x = Math.lerp(origin.x * grid.cellSize, dest.x * grid.cellSize, progress);
        var y = Math.lerp(origin.y * grid.cellSize, dest.y * grid.cellSize, progress);
        trace("from " + origin + " to " + dest + " progress: " + progress + " x: " + x + " y: " + y);
        actor.updateSpritePosition(x, y);
    }
    
    public inline function lerp(a: Int, b: Int, t: Float): Float {
        return a + (b - a) * t;
    }

    public function tryMove(grid: Grid, cell: Cell): Future {
        if (state != Idle) return Future.immediate();

        var dst = cell;
        var wt  = testCell(grid, dst.x, dst.y);
    
        switch (wt) {
        case Blocked:
            return Future.immediate();
    
        case Free:
            return startStep(grid, cell);
    
        case Trigger(tr):
            state = Waiting;
            var promise = new Future();
    
            var e = tr.onEvent(TryEnter, {actor: actor, cell: cell, grid: grid});
            if (e == null || e.immediateData) {
                promise = startStep(grid, cell);
            }
            else {
                state = Idle;
                promise = e;
            }

            return promise;
        }
    }

    public function startStep(grid: Grid, cell: Cell): Future {

        grid.reserve(cell, actor);

        origin       = grid.getActorPos(actor);
        dest         = cell;
        prevTrigger  = grid.getTrigger(origin);
        nextTrigger  = grid.getTrigger(dest);
        
        animator.playWalk(dir(origin, dest));

        stepPromise = new Future();

        state = Stepping(0);

        return stepPromise;
    }

    public function dir(origin: Cell, dest: Cell): MoveDirection {
        if (origin.x < dest.x) return Right;
        if (origin.x > dest.x) return Left;
        if (origin.y < dest.y) return Down;
        return Up;
    }

    public function onStepDone(grid: Grid, x: Int, y: Int): Future  {
        grid.release(origin);

        grid.placeActor(actor, dest);

        animator.playIdle();

        stepPromise.resolve(null);

        state = Idle;
        origin = dest;

        var futures: Array<Future> = [];

        if (prevTrigger != null) futures.push(prevTrigger.onEvent(Left, {actor: actor, cell: origin, grid: grid}));
        if (nextTrigger != null) futures.push(nextTrigger.onEvent(Entered, {actor: actor, cell: dest, grid: grid}));

        return Future.all(futures);
    }

    public function update(grid: Grid, dt: Float): Void {
        switch (state) {
            case Idle: {
                switch driver.currentMoveRequest() {
                    case Walk(direction): {
                        var cell = origin.translate(direction.dx, direction.dy);
                        this.tryMove(grid, cell);
                        return;
                    }
                    case Stand(direction):
                    case None:
                }
            }
            case Waiting: {
                return;
            }
            case Stepping(t):
                t += dt * speed;
                updateSpritePosition(grid, origin, dest, t);
    
                if (t >= 1) onStepDone(grid, dest.x, dest.y) else state = Stepping(t);
            }
    }
}