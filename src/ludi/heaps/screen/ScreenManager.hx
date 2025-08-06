package ludi.heaps.screen;

import heaps.coroutine.effect.Effect;
import ludi.heaps.screen.ScreenTimeline.ScreenTimelineAction;

class ScreenManager extends h2d.Object {
    static var instance: ScreenManager;
    static var currentScreen: Screen;          // The currently active screen
    static var currentEffect: Effect;          // The current transition effect
    static var pendingOldScreen: Screen;       // The screen to remove after transition
    static var _timeline: ScreenTimeline;       // The timeline orchestrating screens

    function new() {
        super();
    }

    public static function attach(scene: h2d.Scene): Void {
        if (instance == null) {
            instance = new ScreenManager();
        }
        scene.addChild(instance);
    }

    /**
     * Sets up the timeline with a list of actions and starts it.
     * @param actions The sequence of actions to execute.
     */
    public static function timeline(actions: Array<ScreenTimelineAction>): Void {
        timeline = new ScreenTimeline(actions);
        timeline.next(); // Begin with the first action
    }

    /**
     * Pushes a new screen onto the timeline and switches to it.
     * @param screen The screen to add and display.
     */
    public static function push(screen: Screen): Void {
        if (_timeline != null) {
            _timeline.push(screen);
        } else {
            switchTo(screen); // Fallback if no timeline exists
        }
    }

    /**
     * Switches to a new screen, with an optional transition effect.
     * @param screen The new screen to display.
     * @param transition An optional ScreenTransition effect.
     */
    public static function switchTo(screen: Screen, ?transition: ScreenTransition): Void {
        // Stop any ongoing transition
        if (currentEffect != null) {
            currentEffect.forceStop();
            currentEffect = null;
        }

        // Clean up any pending old screen
        if (pendingOldScreen != null) {
            instance.removeChild(pendingOldScreen);
            pendingOldScreen.teardown();
            pendingOldScreen = null;
        }

        // Store the current screen as the old screen
        var oldScreen = currentScreen;
        currentScreen = screen;

        // Handle screen disposal to advance or rewind the timeline
        screen.on(function(event: ScreenEvent) {
            switch (event) {
                case Disposed:
                    if (_timeline != null) {
                        if (_timeline.hasNext()) {
                            _timeline.next();
                        } else {
                            _timeline.back();
                        }
                    }
            }
        });

        if (transition != null) {
            // Handle transition
            if (oldScreen != null) {
                pendingOldScreen = oldScreen; // Keep old screen until transition ends
            }
            instance.addChild(currentScreen);
            currentScreen.setup();
            transition.doTransition(oldScreen, currentScreen); // Start the transition
            currentEffect = transition;

            // Listen for Effect events
            transition.topic.subscribe(handleEffectEvent);
        } else {
            // Immediate switch with no transition
            if (oldScreen != null) {
                instance.removeChild(oldScreen);
                oldScreen.teardown();
            }
            instance.addChild(currentScreen);
            currentScreen.setup();
            currentScreen.onShown();
        }
    }

    /**
     * Handles EffectEvent events from the transition.
     * @param event The event (Start or Complete).
     */
    private static function handleEffectEvent(event: EffectEvent): Void {
        switch (event) {
            case Start:
                // Transition started; no action needed
            case Complete:
                // Transition finished
                if (pendingOldScreen != null) {
                    instance.removeChild(pendingOldScreen);
                    pendingOldScreen.teardown();
                    pendingOldScreen = null;
                }
                if (currentScreen != null) {
                    currentScreen.onShown();
                }
                // Clean up event listener
                if (currentEffect != null) {
                    currentEffect.topic.removeListener(handleEffectEvent);
                    currentEffect = null;
                }
        }
    }
}