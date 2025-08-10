package ludi.heaps.screen;

import heaps.coroutine.effect.Effect;
import ludi.heaps.screen.ScreenTimeline.ScreenTimelineAction;

class ScreenManager extends h2d.Object {
    static var instance: ScreenManager;
    static var currentScreen: Screen;              static var currentEffect: Effect;              static var pendingOldScreen: Screen;           static var _timeline: ScreenTimeline;       
    function new() {
        super();
    }

    public static function attach(scene: h2d.Scene): Void {
        if (instance == null) {
            instance = new ScreenManager();
        }
        scene.addChild(instance);
    }

    
    public static function timeline(actions: Array<ScreenTimelineAction>): Void {
        timeline = new ScreenTimeline(actions);
        timeline.next();     }

    
    public static function push(screen: Screen): Void {
        if (_timeline != null) {
            _timeline.push(screen);
        } else {
            switchTo(screen);         }
    }

    
    public static function switchTo(screen: Screen, ?transition: ScreenTransition): Void {
                if (currentEffect != null) {
            currentEffect.forceStop();
            currentEffect = null;
        }

                if (pendingOldScreen != null) {
            instance.removeChild(pendingOldScreen);
            pendingOldScreen.teardown();
            pendingOldScreen = null;
        }

                var oldScreen = currentScreen;
        currentScreen = screen;

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
                        if (oldScreen != null) {
                pendingOldScreen = oldScreen;             }
            instance.addChild(currentScreen);
            currentScreen.setup();
            transition.doTransition(oldScreen, currentScreen);             currentEffect = transition;

                        transition.topic.subscribe(handleEffectEvent);
        } else {
                        if (oldScreen != null) {
                instance.removeChild(oldScreen);
                oldScreen.teardown();
            }
            instance.addChild(currentScreen);
            currentScreen.setup();
            currentScreen.onShown();
        }
    }

    
    private static function handleEffectEvent(event: EffectEvent): Void {
        switch (event) {
            case Start:
                            case Complete:
                                if (pendingOldScreen != null) {
                    instance.removeChild(pendingOldScreen);
                    pendingOldScreen.teardown();
                    pendingOldScreen = null;
                }
                if (currentScreen != null) {
                    currentScreen.onShown();
                }
                                if (currentEffect != null) {
                    currentEffect.topic.removeListener(handleEffectEvent);
                    currentEffect = null;
                }
        }
    }
}