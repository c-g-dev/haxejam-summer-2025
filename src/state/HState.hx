package state;

enum HStateLifeCycle {
    Create;
    Activate;
    Deactivate;
    Destroy;
}

abstract AppContextH2D(h2d.Scene) from h2d.Scene {}
abstract AppContextH3D(h3d.Scene) from h3d.Scene {}

class AppContext {
    var app: hxd.App;
    var s2d: AppContextH2D;
    var s3d: AppContextH3D;

    var 2dObjects: Array<h2d.Object> = [];
    var 3dObjects: Array<h3d.Object> = [];

    public function new(app: hxd.App) {
        this.app = app;
    }
}

abstract class HState {
    var app: hxd.App;

    var transitionIn: HStateTransitionIn;
    var transitionOut: HStateTransitionOut;

    public function new(app: hxd.App) {
        this.app = app;
    }

    public abstract function lifecycle(e: HStateLifeCycle) : Future;

    public abstract function update(dt:Float) : Void;

}

interface HStateTransitionIn {}
interface HStateTransitionOut {}