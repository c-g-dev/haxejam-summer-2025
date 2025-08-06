package ludi.heaps.input;

import haxe.ds.StringMap;
import hxd.Key;

interface IInputSystem {
    public function isKeyDown(code: Int): Bool;
    public function isKeyPressed(code: Int): Bool;
    public function isKeyReleased(code: Int): Bool;
    public function other(tag: String): Dynamic;
}

class InputSystem {
    public static var instance: IInputSystem = new BaseInputSystem();
}

class BaseInputSystem extends StringMap<Dynamic> implements IInputSystem {

    public inline function isKeyDown(code:Int):Bool {
        return Key.isDown(code);
    }

    public inline function isKeyPressed(code:Int):Bool {
        return Key.isPressed(code);
    }

    public inline function isKeyReleased(code:Int):Bool {
        return Key.isReleased(code);
    }

    public inline function other(tag:String):Dynamic {
        return get(tag);
    }
}
