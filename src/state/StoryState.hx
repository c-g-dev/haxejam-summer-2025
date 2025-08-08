package state;

import state.HState;
import heaps.coroutine.Future;

class StoryState extends HState {

    function lifecycle(e: HStateLifeCycle) : Future {
        return Future.immediate();
    }

    public function onUpdate(dt:Float) {}
}