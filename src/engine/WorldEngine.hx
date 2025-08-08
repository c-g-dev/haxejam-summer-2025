package engine;

import data.Data.World;
import heaps.coroutine.Future;

interface IWorldEvent {
    function changeWorld(world: World): Future;
}

class WorldEngine {
    public static var queue: Array<IWorldEvent> = [];
    public static var isProcessing: Bool = false;
    public static var world: World;



    public static function enqueue(event: IWorldEvent) {
        queue.push(event);
        processEvents();
    }

    static function processEvents() {
        if(isProcessing) return;
        isProcessing = true;
        var event = queue.shift();
        event.changeWorld(world).then((_) -> {
            if(queue.length > 0) {
                processEvents();
            } else {
                isProcessing = false;
            }
        });
    }
}


class WorldEvent implements IWorldEvent {
    public var callback: (World) -> Future;

    public function new(callback: (World) -> Future) {
        this.callback = callback;
    }

    public function changeWorld(world: World): Future {
        return callback(world);
    }
}
