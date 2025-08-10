package ludi.heaps.screen;

enum SplashPhase {
    FadeIn;
    Hold;
    FadeOut;
}
typedef SplashScreenConfig = {
    ?fadeInDuration: Float,
    ?holdDuration: Float,
    ?fadeOutDuration: Float
}

class SplashScreen extends Screen {
    
    var bg: h2d.Graphics;
    var bitmap: h2d.Bitmap;
    var fadeInDuration: Float;
    var holdDuration: Float;
    var fadeOutDuration: Float;

    public function new(tile: h2d.Tile, ?config: SplashScreenConfig) {
        super();
                this.fadeInDuration = config != null && config.fadeInDuration != null ? config.fadeInDuration : 1.0;
        this.holdDuration = config != null && config.holdDuration != null ? config.holdDuration : 2.0;
        this.fadeOutDuration = config != null && config.fadeOutDuration != null ? config.fadeOutDuration : 1.0;

                setup();
                bitmap = new h2d.Bitmap(tile, this);
        var scene = this.getScene();
        bitmap.x = (scene.width - tile.width) / 2;         bitmap.y = (scene.height - tile.height) / 2;         bitmap.alpha = 0.0;     }

    override function setup(): Void {
                var scene = this.getScene();
        bg = new h2d.Graphics(this);
        bg.beginFill(0x000000);
        bg.drawRect(0, 0, scene.width, scene.height);
        bg.endFill();
    }

    override function onShown(): Void {
                var phase = SplashPhase.FadeIn;
        var time = 0.0;

                var effect = Effect.from(function(dt) {
            time += dt;

            switch (phase) {
                case FadeIn:
                                        var ratio = time / fadeInDuration;
                    if (ratio >= 1.0) {
                        bitmap.alpha = 1.0;
                        phase = SplashPhase.Hold;
                        time = 0.0;
                    } else {
                        bitmap.alpha = ratio;
                    }
                case Hold:
                                        if (time >= holdDuration) {
                        phase = SplashPhase.FadeOut;
                        time = 0.0;
                    }
                case FadeOut:
                                        var ratio = time / fadeOutDuration;
                    if (ratio >= 1.0) {
                        bitmap.alpha = 0.0;
                        return CoroutineResult.Stop;                     } else {
                        bitmap.alpha = 1.0 - ratio;
                    }
            }
            return CoroutineResult.WaitNextFrame;         });

                effect.onComplete = function() {
            this.dispose();
        };

                effect.run();
    }

    override function teardown(): Void {
                this.removeChildren();
    }
}