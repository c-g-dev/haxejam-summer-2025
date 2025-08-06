package ludi.heaps.screen;

enum ScreenTimelineAction {
    Screen(screen: Screen);            // Displays a screen
    Transition(transition: ScreenTransition); // Sets a transition for the next screen
    Clear;                            // Clears the timeline
    Label(label: String);             // Marks a point in the timeline
    Goto(label: String);              // Jumps to a labeled point
    Do(cb: ScreenTimeline -> Void);   // Executes a callback
}

class ScreenTimeline {
    var actions: Array<ScreenTimelineAction>;  // List of timeline actions
    var history: Array<ScreenTimelineAction>;  // History of visited screens
    var currentIndex: Int;                     // Current position in the timeline
    var labels: Map<String, Int>;              // Maps labels to action indices
    var currentTransition: ScreenTransition;   // Transition for the next screen
    var backTransition: ScreenTransition;      // Default transition for going back

    public function new(initialActions: Array<ScreenTimelineAction>) {
        this.actions = initialActions;
        this.history = [];
        this.currentIndex = -1;
        this.labels = new Map();
        this.currentTransition = null;
        this.backTransition = new FadeTransition(0.5, 0.5); // Default back transition
    }

    /** Advances to the next action in the timeline. */
    public function next(): Void {
        if (currentIndex + 1 < actions.length) {
            currentIndex++;
            executeAction(actions[currentIndex]);
        }
    }

    /** Goes back to the previous screen in the history. */
    public function back(): Void {
        if (history.length > 1) {
            history.pop(); // Remove current screen
            var prevAction = history[history.length - 1];
            switch (prevAction) {
                case Screen(screen):
                    // Update currentIndex to match the previous screen
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

    /** Pushes a new screen onto the timeline and displays it. */
    public function push(screen: Screen): Void {
        actions.push(Screen(screen));
        currentIndex = actions.length - 1;
        executeAction(Screen(screen));
    }

    /** Checks if there’s a next action in the timeline. */
    public function hasNext(): Bool {
        return currentIndex + 1 < actions.length;
    }

    /** Executes the given timeline action. */
    private function executeAction(action: ScreenTimelineAction): Void {
        switch (action) {
            case Screen(screen):
                history.push(action);
                ScreenManager.switchTo(screen, currentTransition);
                currentTransition = null; // Reset after use
            case Transition(transition):
                currentTransition = transition;
                next(); // Proceed to next action
            case Clear:
                actions = [];
                history = [];
                currentIndex = -1;
                labels.clear();
            case Label(label):
                labels.set(label, currentIndex);
                next();
            case Goto(label):
                if (labels.exists(label)) {
                    currentIndex = labels.get(label) - 1; // Set to jump on next()
                    next();
                } else {
                    next();
                }
            case Do(cb):
                cb(this);
                next();
        }
    }
}