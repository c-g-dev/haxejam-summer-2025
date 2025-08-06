package ludi.heaps.grid;

class WalkingSprite extends h2d.Object implements IGridActor {
    public var uuid(default, null): String;
    public var mover: GridActorMover;

    public function new(uuid: String) {
        super();
        this.uuid = uuid;
        var driver = new HeadlessGridDriver();
        var animator = new HeadlessGridAnimator();
        this.mover = new GridActorMover(this, animator, driver);
    }
}