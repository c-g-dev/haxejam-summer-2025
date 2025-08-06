package ludi.heaps.grid;

import ludi.heaps.grid.Mover.GridActorMover;

interface IGridActor {
    public var uuid(default, null): String;
    var mover: GridActorMover;
    public function updateSpritePosition(x: Float, y: Float): Void;
}

typedef PhysicalGridActor<T: (IGridActor & h2d.Object) = Dynamic> = T;