package ludi.heaps.screen.transitions;

import heaps.coroutine.Coroutine.FrameYield;

class FadeTransition extends ScreenTransition {
    var fadeOutDuration: Float;  // Duration for fading out the outgoing screen
    var fadeInDuration: Float;   // Duration for fading in the incoming screen
    var fadeOutProgress: Float = 0.0;  // Tracks progress of fade-out phase
    var fadeInProgress: Float = 0.0;   // Tracks progress of fade-in phase
    var isFadingOut: Bool = true;      // Indicates whether we're in fade-out or fade-in phase

    public function new(fadeOutDuration: Float, fadeInDuration: Float) {
        super();  // Call the parent constructor
        this.fadeOutDuration = fadeOutDuration;
        this.fadeInDuration = fadeInDuration;
    }

    public override function onStart(): Void {
        // Initialize screen opacities
        if (outScreen != null) {
            outScreen.alpha = 1.0;  // Outgoing screen starts fully visible
        }
        if (inScreen != null) {
            inScreen.alpha = 0.0;   // Incoming screen starts fully transparent
        }
        fadeOutProgress = 0.0;      // Reset fade-out progress
        fadeInProgress = 0.0;       // Reset fade-in progress
        isFadingOut = true;         // Start with fade-out phase
    }

    public override function onUpdate(elapsed: Float): FrameYield {
        if (isFadingOut) {
            // Fade-out phase: decrease opacity of outgoing screen
            if (outScreen != null) {
                fadeOutProgress += elapsed;  // Increment progress based on elapsed time
                var ratio = fadeOutProgress / fadeOutDuration;  // Calculate progress ratio
                outScreen.alpha = 1.0 - ratio;  // Decrease alpha from 1 to 0
                if (ratio >= 1.0) {
                    outScreen.alpha = 0.0;      // Ensure fully transparent
                    isFadingOut = false;        // Switch to fade-in phase
                }
            } else {
                isFadingOut = false;  // Skip fade-out if no outgoing screen
            }
        } else {
            // Fade-in phase: increase opacity of incoming screen
            if (inScreen != null) {
                fadeInProgress += elapsed;  // Increment progress based on elapsed time
                var ratio = fadeInProgress / fadeInDuration;  // Calculate progress ratio
                inScreen.alpha = ratio;     // Increase alpha from 0 to 1
                if (ratio >= 1.0) {
                    inScreen.alpha = 1.0;   // Ensure fully visible
                    return FrameYield.Stop;  // Transition complete
                }
            } else {
                return FrameYield.Stop;  // Stop if no incoming screen
            }
        }
        return FrameYield.WaitNextFrame;  // Continue transition
    }

    public override function onComplete(): Void {
        // Finalize screen opacities
        if (outScreen != null) {
            outScreen.alpha = 0.0;  // Ensure outgoing screen is fully transparent
        }
        if (inScreen != null) {
            inScreen.alpha = 1.0;   // Ensure incoming screen is fully visible
        }
    }
}