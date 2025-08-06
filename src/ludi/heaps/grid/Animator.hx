package ludi.heaps.grid;

import ludi.heaps.grid.Mover.MoveDirection;

interface IGridActorAnimator {
    public function playWalk(dir: MoveDirection): Void;
    public function playIdle(): Void;
}