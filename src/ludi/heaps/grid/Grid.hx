package ludi.heaps.grid;

import ludi.heaps.grid.Actor.IGridActor;
import ludi.heaps.grid.Actor.PhysicalGridActor;
import ludi.heaps.grid.Cell;
import ludi.heaps.grid.Trigger.ITrigger;
import ludi.commons.collections.GridMap;

class CellInfo<T> {
    public var cellData: T;
    public var reservedBy: String = null;
    public var trigger: ITrigger;

    public function new(cellData: T) {
        this.cellData = cellData;
    }
}

typedef ActorInfo = {
    actor: IGridActor,
    gridX: Int,
    gridY: Int,
}

class Grid<T = Dynamic> {
    public var width: Int;
    public var height: Int;
    public var cellSize: Int;
    public var actors: Map<String, ActorInfo> = [];
    var cells: GridMap<CellInfo<T>> = new GridMap<CellInfo<T>>();

    public function new(width: Int, height: Int, cellSize: Int) {
        this.width = width;
        this.height = height;
        this.cellSize = cellSize;
    }

    public function getTrigger(cell: Cell): ITrigger {
        var info = cells.get(cell.x, cell.y);
        if (info == null) return null;
        return info.trigger;
    }

    public function reserve(cell: Cell, actor: IGridActor): Void {
        var info = cells.get(cell.x, cell.y);
        if (info == null) {
            info = new CellInfo<T>(null);
            cells.add(cell.x, cell.y, info);
        }
        info.reservedBy = actor.uuid;
    }

    public function release(cell: Cell): Void {
        var info = cells.get(cell.x, cell.y);
        if (info != null) {
            info.reservedBy = null;
        }
    }

    public function placeActor(actor: IGridActor, cell: Cell): Bool {
        var info = cells.get(cell.x, cell.y);
        if (info != null && info.reservedBy != null && info.reservedBy != actor.uuid) return false;

        if(actors.exists(actor.uuid)) {
            var aInfo = actors.get(actor.uuid);
            aInfo.gridX = cell.x;
            aInfo.gridY = cell.y;
            return true;
        }
        else {
            actors.set(actor.uuid, {
                actor: actor,
                gridX: cell.x,
                gridY: cell.y,
            });
        }

        if (info == null) {
            info = new CellInfo<T>(null);
            cells.add(cell.x, cell.y, info);
        }
        return true;
    }

    public function getCellAt(cell: Cell): CellInfo<T> {
        return cells.get(cell.x, cell.y);
    }

    public function getActorPos(actor: IGridActor): Cell {
        var info = actors.get(actor.uuid);
        if (info == null) return null;
        return new Cell(info.gridX, info.gridY);
    }

}

class GridContainer extends h2d.Object {
    public var grid: Grid<Dynamic>;

    public function new(width: Int, height: Int, cellSize: Int) {
        super();
        this.grid = new Grid<Dynamic>(width, height, cellSize);
        this.addChild(new Behavior((dt) -> {
            for (actor in this.grid.actors) {
                actor.actor.mover.update(this.grid, dt);
            }
        }));
    }

    public function placeActor(actor: PhysicalGridActor, cell: Cell): Void {
        grid.placeActor(actor, cell);
        this.addChild(actor);
        @:privateAccess actor.mover.origin = cell;
        actor.mover.updateSpritePosition(grid, cell, cell, 0);
    }
}