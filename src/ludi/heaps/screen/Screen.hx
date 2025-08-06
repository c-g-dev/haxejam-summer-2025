package ludi.heaps.screen;

import ludi.commons.messaging.Topic;

enum ScreenEvent {
    Disposed;
}

abstract class Screen extends h2d.Object {
    var topic: Topic<ScreenEvent> = new Topic();

    abstract function setup(): Void;
    public abstract function onShown(): Void;
    abstract function teardown(): Void;

    public function dispose(): Void {
        this.remove();
        topic.notify(ScreenEvent.Disposed);
    }

    public function on(cb: (ScreenEvent) -> Void): Void {
        topic.subscribeOnce(cb);
    }
}