package ludi.heaps.grid;

import ludi.heaps.grid.Actor.IGridActor;
import ludi.heaps.grid.Cell;
import heaps.coroutine.Future;

typedef TriggerArg = {actor: IGridActor, cell: Cell, grid: Grid};
enum NoReturn { NoReturn; }

enum TriggerEvent<Req, Res> {
    TryEnter : TriggerEvent<TriggerArg, Bool>;
    Entered  : TriggerEvent<TriggerArg, NoReturn>;
    Left     : TriggerEvent<TriggerArg, NoReturn>;
    Bump     : TriggerEvent<TriggerArg, NoReturn>;
    Other    : TriggerEvent<TriggerArg, NoReturn>;
}

class TriggerFuture<T> extends Future<Void> {
    public var immediateData (default, null): T;

    public function new(immediateData: T) {
        super();
        this.immediateData = immediateData;
    }
}

interface ITrigger {
    public function onEvent<Req, Res>(event: TriggerEvent<Req, Res>, args: Req): TriggerFuture<Res>;

    /*
    public abstract function onEvent<Req, Res>(event: TriggerEvent<Req, Res>, args: Req): Future<Res> {
        handle(Bump, (req) -> {

        });
        return handleEvent(event, args).get();
    }


    private macro function handle<Req, Res>(e: ExprOf<TriggerEvent<Req, Res>>, handler: ExprOf<Req -> Future<Res>>): Expr {
        return macro {
            if(event == $e){
                return cast $handler(args);
            }
        }
    }
        */
}
