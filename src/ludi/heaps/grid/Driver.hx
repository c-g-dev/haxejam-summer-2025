package ludi.heaps.grid;

import ludi.heaps.grid.Mover.MoveDirection;

interface IGridActorDriver {
    public function currentMoveRequest(): MoveRequest;
}

enum MoveRequest {
    Walk(direction: MoveDirection);
    Stand(direction: MoveDirection);
    None;
}