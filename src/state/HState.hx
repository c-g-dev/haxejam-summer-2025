package state;

import heaps.coroutine.Coroutine;
import heaps.coroutine.Coroutine.CoroutineContext;
import heaps.coroutine.Coro;
import heaps.coroutine.Future;

enum HStateLifeCycle {
    Create;
    Activate;
    Deactivate;
    Destroy;
}

abstract class HState {
    var app: hxd.App;

    var transitionIn: HStateTransitionIn;
    var transitionOut: HStateTransitionOut;
    var parentState: HState;
    var substate: HState;

    var killed:Bool = false;

    public function new() {
        this.app = HStateManager.app;
    }


    public abstract function lifecycle(e: HStateLifeCycle) : Future;

    public function update(dt:Float) : Void {
        if(killed) {
            return;
        }
        if (substate != null) {
            substate.update(dt);
            return;
        }
        else {
            onUpdate(dt);
        }
    }

    public abstract function onUpdate(dt:Float) : Void;

    public function openSubState(substate:HState):Future {
        return HStateManager.openSubState(this, substate);
    }

    public function closeSubState():Future {
        return HStateManager.closeSubState(this);
    }

    public function exitState(): Future {
        if(this.parentState == null) {
            return Future.immediate();
        }
                        return HStateManager.closeSubState(this.parentState);
    }
    
    public function setState(state:HState):Future {
        if(killed) {
            return Future.immediate();
        }
        killed = true;
        return HStateManager.setState(state);
    }

}

interface HStateTransitionIn {
    function run() : Future;
}
interface HStateTransitionOut {
    function run() : Future;
}

@:access(state.HState)
class HStateManager {
    public static var app: hxd.App;
    static var currentState: HState;
    static var blockUpdate:Bool = false;
    static var currentCoro:Future;

    public static function setState(state: HState):Future {
        trace("QUEUING STATE CHANGE: " + Type.getClassName(Type.getClass(state)));
        var c =  Coro.defer((ctx) -> {
            Coro.start((ctx) -> {
                if(currentState != null) {
                    currentState.lifecycle(Deactivate).await();
                    if(currentState.transitionOut != null) {
                        blockUpdate = true;
                        currentState.transitionOut.run().await();
                        blockUpdate = false;
                    }
                    currentState.lifecycle(Destroy).await();
                }
                return Stop;
            }).await();

            
            Coro.start((ctx) -> {
                Coro.once(() -> { currentState = state; });
             
                currentState.lifecycle(Create).await();
                if(currentState.transitionIn != null) {
                    blockUpdate = true;
                    currentState.transitionIn.run().await();
                    blockUpdate = false;
                }
                currentState.lifecycle(Activate).await();
                return Stop;
            }).await();

            return Stop;

        });

        if(currentCoro != null && !currentCoro.isComplete) {
            currentCoro = currentCoro.map((_) -> {
                c.start();
                return c.future();
            });
        }
        else {
            c.start();
            currentCoro = c.future();
        }
        return currentCoro;
    }

    public static function openSubState(parent: HState, state: HState):Future {
        return Coro.start((_) -> {
            Coro.start((_) -> {
                if(parent.substate != null) {
                    parent.closeSubState().await();
                }
                parent.substate = state;
                state.parentState = parent;
                return Stop;
            }).await();

            state.lifecycle(Create).await();

            Coro.start((_) -> {
            if(state.transitionIn != null) {
                    blockUpdate = true;
                    state.transitionIn.run().await();
                    blockUpdate = false;
                }
                state.lifecycle(Activate).await();
                return Stop;
            }).await();
            return Stop;
        }).future();
    }

    public static function closeSubState(parent: HState):Future {
        if(parent.substate == null) {
            return Future.immediate();
        }
        return Coro.start((_) -> {
            var state = parent.substate;
            state.lifecycle(Deactivate).await();
            if(state.transitionOut != null) {
                blockUpdate = true;
                state.transitionOut.run().await();
                blockUpdate = false;
            }
            state.lifecycle(Destroy).await();
            parent.substate = null;
            return Stop;
        }).future();
    }

    public static function update(dt:Float):Void {
        if(blockUpdate) {
            return;
        }
        if(currentState != null) {
            currentState.update(dt);
        }
    }
}

class HStateTransitionFadeManager {
    public static var blackScreen (get, null): h2d.Object;
    static var didInit:Bool = false;

    public static function init():Void {
        if(didInit) {
            return;
        }
        didInit = true;
        blackScreen = new h2d.Bitmap(h2d.Tile.fromColor(0x000000, 1, 1));
        blackScreen.alpha = 0;
        blackScreen.scaleX = HStateManager.app.s2d.width;
        blackScreen.scaleY = HStateManager.app.s2d.height;
    }

    public static function isBlackScreenVisible():Bool {
        init();
        return blackScreen.getScene() != null;
    }

    public static function attach(): Void {
        init();
        HStateManager.app.s2d.add(blackScreen, 999);
    }

    public static function detach(): Void {
        init();
        HStateManager.app.s2d.removeChild(blackScreen);
    }

    static function get_blackScreen():h2d.Object {
        init();
        return blackScreen;
    }
}

class HStateTransitionInFade implements HStateTransitionIn {
    var duration: Float = 3;

    public function new() {
    }

    public function run():Future {
        return Coro.start((ctx: CoroutineContext) -> {
            Coro.once(() -> {trace("HStateTransitionInFade.run");});
            Coro.once(() -> {                
                    HStateTransitionFadeManager.attach();
                    HStateTransitionFadeManager.blackScreen.alpha = 1;
            });
                      HStateTransitionFadeManager.blackScreen.alpha = 1 - (ctx.elapsed / this.duration);
            if(HStateTransitionFadeManager.blackScreen.alpha <= 0) {
                return Stop;
            }
            return WaitNextFrame;
        }).future();
    }
}

class HStateTransitionOutFade implements HStateTransitionOut {
    var duration: Float = 3;

    public function new() {
    }

    public function run():Future {
        return Coro.start((ctx: CoroutineContext) -> {
                      Coro.once(() -> {trace("HStateTransitionOutFade.run");});
            Coro.once(() -> {
                HStateTransitionFadeManager.attach();
                HStateTransitionFadeManager.blackScreen.alpha = 0;
            });
            HStateTransitionFadeManager.blackScreen.alpha = (ctx.elapsed / this.duration);

            if(HStateTransitionFadeManager.blackScreen.alpha >= 1) {
                return Stop;
            }
            return WaitNextFrame;
        }).future();
    }
}

class MainState extends HState {

    public function new() {
        super();
    }

    public function lifecycle(e: HStateLifeCycle):Future { return Future.immediate(); }

    public function onUpdate(dt:Float):Void {}

}