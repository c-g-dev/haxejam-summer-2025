package state;

import state.HState;
import heaps.coroutine.Future;
import ui.SeedListView;
import heaps.coroutine.Coro;
import heaps.coroutine.Coroutine.CoroutineContext;
import hxd.Key;

class InventoryState extends HState {

    var seedList: SeedListView;

    public function new() {
        super();
    }

    public function lifecycle(e: HStateLifeCycle):Future {
        switch e {
            case Create: {
                seedList = new SeedListView(Std.int(this.app.s2d.width * 0.7), this.app.s2d.height);
                seedList.x = Std.int((this.app.s2d.width - seedList.totalWidth) / 2);
                seedList.y = Std.int((this.app.s2d.height - seedList.totalHeight) / 2);
                seedList.alpha = 0.0;

                this.app.s2d.addChild(seedList);

                return Coro.start((ctx: CoroutineContext) -> {
                    seedList.alpha += ctx.dt * 2.0;
                    if (seedList.alpha >= 1.0) {
                        return Stop;
                    }
                    return WaitNextFrame;
                }).future();
            }
            case Activate: return Future.immediate();
            case Deactivate: return Future.immediate();
            case Destroy: {
                if (seedList != null) {
                    seedList.remove();
                    seedList = null;
                }
                return Future.immediate();
            }
        }
    }

    public function onUpdate(dt:Float):Void {
        if (seedList != null) seedList.update(dt);
        if (Key.isPressed(Key.ESCAPE)) {
            exitState();
        }
    }
}