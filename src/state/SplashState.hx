package state;

import state.HState.HStateLifeCycle;
import state.HState.HStateManager;
import state.HState.HStateTransitionInFade;
import state.HState.HStateTransitionOutFade;
import heaps.coroutine.Future;

class SplashState extends HState {
    var obj: h2d.Object;
    var nextState: HState;
    var waitSeconds: Float = 3;
    var elapsed: Float = 0;

    public function new(obj: h2d.Object, nextState: HState) {
        super();
        this.obj = obj;
        this.nextState = nextState;
        this.transitionIn = new HStateTransitionInFade();
        this.transitionOut = new HStateTransitionOutFade();
    }

    private function setup(): Void {
        this.app.s2d.add(this.obj, 0);
        this.obj.x = (this.app.s2d.width / 2) - this.obj.getBounds().width / 2;
        this.obj.y = (this.app.s2d.height / 2) - this.obj.getBounds().height / 2;
    }

    public function lifecycle(e: HStateLifeCycle):Future {
        trace("SplashState.lifecycle: " + e);
        switch(e) {
            case Create: {
                setup();
                return Future.immediate();
            }
            case Activate: {
                this.elapsed = 0;
                return Future.immediate();
            }
            case Destroy: {
                this.app.s2d.removeChild(this.obj);
                return Future.immediate();
            }
            default: return Future.immediate();
        }
    }

    
    public function onUpdate(dt:Float):Void {
                this.elapsed += dt;
        if(this.elapsed >= this.waitSeconds) {
            setState(this.nextState);
        }
    }
    
}