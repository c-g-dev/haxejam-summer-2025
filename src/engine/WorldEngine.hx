package engine;


interface IWorldEvent {
    function changeWorld(world: World): Future;
}

class WorldEngine {
    static var queue: Array<IWorldEvent> = [];
    static var isProcessing: Bool = false;
    static var world: World;



    public static function enqueue(event: IWorldEvent) {
        queue.push(event);
        processEvents();
    }

    static function processEvents() {
        if(isProcessing) return;
        isProcessing = true;
        var event = queue.shift();
        event(world).then(() -> {
            if(queue.length > 0) {
                processEvents();
            } else {
                isProcessing = false;
            }
        });
    }
}


class WorldEvent implements IWorldEvent {
    public callback: (World) -> Future;

    public function new(callback: (World) -> Future) {
        this.callback = callback;
    }

    public function changeWorld(world: World): Future {
        return callback(world);
    }
}
