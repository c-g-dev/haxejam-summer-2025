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
        // Set default durations if not provided in config
        this.fadeInDuration = config != null && config.fadeInDuration != null ? config.fadeInDuration : 1.0;
        this.holdDuration = config != null && config.holdDuration != null ? config.holdDuration : 2.0;
        this.fadeOutDuration = config != null && config.fadeOutDuration != null ? config.fadeOutDuration : 1.0;

        // Setup is called in constructor to initialize visuals immediately
        setup();
        // Center the bitmap using the provided tile
        bitmap = new h2d.Bitmap(tile, this);
        var scene = this.getScene();
        bitmap.x = (scene.width - tile.width) / 2; // Center horizontally
        bitmap.y = (scene.height - tile.height) / 2; // Center vertically
        bitmap.alpha = 0.0; // Start fully transparent
    }

    override function setup(): Void {
        // Create a black background
        var scene = this.getScene();
        bg = new h2d.Graphics(this);
        bg.beginFill(0x000000);
        bg.drawRect(0, 0, scene.width, scene.height);
        bg.endFill();
    }

    override function onShown(): Void {
        // Initialize effect state
        var phase = SplashPhase.FadeIn;
        var time = 0.0;

        // Create and start the effect
        var effect = Effect.from(function(dt) {
            time += dt;

            switch (phase) {
                case FadeIn:
                    // Fade the tile in by increasing alpha from 0 to 1
                    var ratio = time / fadeInDuration;
                    if (ratio >= 1.0) {
                        bitmap.alpha = 1.0;
                        phase = SplashPhase.Hold;
                        time = 0.0;
                    } else {
                        bitmap.alpha = ratio;
                    }
                case Hold:
                    // Hold the tile fully visible for the specified duration
                    if (time >= holdDuration) {
                        phase = SplashPhase.FadeOut;
                        time = 0.0;
                    }
                case FadeOut:
                    // Fade the tile out by decreasing alpha from 1 to 0
                    var ratio = time / fadeOutDuration;
                    if (ratio >= 1.0) {
                        bitmap.alpha = 0.0;
                        return CoroutineResult.Stop; // Effect completes
                    } else {
                        bitmap.alpha = 1.0 - ratio;
                    }
            }
            return CoroutineResult.WaitNextFrame; // Continue to next frame
        });

        // Dispose of the screen when the effect completes
        effect.onComplete = function() {
            this.dispose();
        };

        // Start the effect
        effect.run();
    }

    override function teardown(): Void {
        // Clean up by removing all children
        this.removeChildren();
    }
}