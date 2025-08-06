package ludi.heaps.proc;

class NextFrame {
    
    public static function run(f: Void -> Void) {
        haxe.Timer.delay(f, 0);
    }

}