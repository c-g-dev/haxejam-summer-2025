package state;

import state.HState;
import heaps.coroutine.Future;

class CombatState extends HState {
    function lifecycle(e: HStateLifeCycle) : Future {
        switch e {
            case Create:
            case Activate:
            case Deactivate:
            case Destroy:
        }
    }
}