package ludi.heaps.screen;

enum ScreenTimelineAction {
    Screen(screen: Screen);                Transition(transition: ScreenTransition);     Clear;                                Label(label: String);                 Goto(label: String);                  Do(cb: ScreenTimeline -> Void);   }

class ScreenTimeline {
    var actions: Array<ScreenTimelineAction>;      var history: Array<ScreenTimelineAction>;      var currentIndex: Int;                         var labels: Map<String, Int>;                  var currentTransition: ScreenTransition;       var backTransition: ScreenTransition;      
    public function new(initialActions: Array<ScreenTimelineAction>) {
        this.actions = initialActions;
        this.history = [];
        this.currentIndex = -1;
        this.labels = new Map();
        this.currentTransition = null;
        this.backTransition = new FadeTransition(0.5, 0.5);     }

    
    public function next(): Void {
        if (currentIndex + 1 < actions.length) {
            currentIndex++;
            executeAction(actions[currentIndex]);
        }
    }

    
    public function back(): Void {
        if (history.length > 1) {
            history.pop();             var prevAction = history[history.length - 1];
            switch (prevAction) {
                case Screen(screen):
                                        for (i in 0...actions.length) {
                        if (actions[i] == prevAction) {
                            currentIndex = i;
                            break;
                        }
                    }
                    ScreenManager.switchTo(screen, backTransition);
                default:
            }
        }
    }

    
    public function push(screen: Screen): Void {
        actions.push(Screen(screen));
        currentIndex = actions.length - 1;
        executeAction(Screen(screen));
    }

    
    public function hasNext(): Bool {
        return currentIndex + 1 < actions.length;
    }

    
    private function executeAction(action: ScreenTimelineAction): Void {
        switch (action) {
            case Screen(screen):
                history.push(action);
                ScreenManager.switchTo(screen, currentTransition);
                currentTransition = null;             case Transition(transition):
                currentTransition = transition;
                next();             case Clear:
                actions = [];
                history = [];
                currentIndex = -1;
                labels.clear();
            case Label(label):
                labels.set(label, currentIndex);
                next();
            case Goto(label):
                if (labels.exists(label)) {
                    currentIndex = labels.get(label) - 1;                     next();
                } else {
                    next();
                }
            case Do(cb):
                cb(this);
                next();
        }
    }
}