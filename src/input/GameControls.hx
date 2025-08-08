package input;


import dn.heaps.input.Controller;
import dn.heaps.input.ControllerAccess;

enum abstract GameControlActions(Int) to Int {
    var MoveUp;
    var MoveDown;
    var MoveLeft;
    var MoveRight;
    var Action;
}

@:forward
abstract GameControls(ControllerAccess<GameControlActions>) to ControllerAccess<GameControlActions> from ControllerAccess<GameControlActions> {
    public static function get(): GameControls {
        return GameControlsManager.get();
    }

    public static function lock() {
        GameControlsManager.lock();
    }

    public static function release() {
        GameControlsManager.release();
    }
}

class GameControlsManager {
    static var ctrl: Controller<GameControlActions>;
    static var prime: GameControls;
    static var didInit: Bool = false;

    public static function init() {
        if (didInit) return;
        ctrl = Controller.createFromAbstractEnum(GameControlActions);
        ctrl.bindKeyboard(MoveUp, hxd.Key.UP);
        ctrl.bindKeyboard(MoveDown, hxd.Key.DOWN);
        ctrl.bindKeyboard(MoveLeft, hxd.Key.LEFT);
        ctrl.bindKeyboard(MoveRight, hxd.Key.RIGHT);
        ctrl.bindKeyboard(Action, hxd.Key.SPACE);
        prime = ctrl.createAccess();
        didInit = true;
    }

    public static function get(): GameControls {
        if (!didInit) init();
        return ctrl.createAccess();
    }

    public static function lock() {
        prime.takeExclusivity();
    }

    public static function release() {
        prime.releaseExclusivity();
    }
}