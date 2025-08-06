package ludi.heaps.screen;

import heaps.coroutine.Coroutine.FrameYield;
import heaps.coroutine.effect.Effect;

abstract class ScreenTransition extends Effect {
    var outScreen: Screen;
    var inScreen: Screen;

    public function doTransition(outScreen: Screen, inScreen: Screen) {
        this.inScreen = inScreen;
        this.outScreen = outScreen;
        this.run();
    }
}