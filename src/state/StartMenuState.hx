package state;

import state.HState;
import heaps.coroutine.Future;

class StartMenuState extends HState {

    function lifecycle(e: HStateLifeCycle) : Future {
        switch e {
            case Create: {
                //add background
                //add start button
            }
            case Activate: {
                //start button on click -> set story state
            }
            case Deactivate:
            case Destroy:
        }
    }

    override function onUpdate(dt:Float) {
        
    }
}