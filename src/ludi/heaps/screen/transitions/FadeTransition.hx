package ludi.heaps.screen.transitions;

import heaps.coroutine.Coroutine.FrameYield;

class FadeTransition extends ScreenTransition {
    var fadeOutDuration: Float;      var fadeInDuration: Float;       var fadeOutProgress: Float = 0.0;      var fadeInProgress: Float = 0.0;       var isFadingOut: Bool = true;      
    public function new(fadeOutDuration: Float, fadeInDuration: Float) {
        super();          this.fadeOutDuration = fadeOutDuration;
        this.fadeInDuration = fadeInDuration;
    }

    public override function onStart(): Void {
                if (outScreen != null) {
            outScreen.alpha = 1.0;          }
        if (inScreen != null) {
            inScreen.alpha = 0.0;           }
        fadeOutProgress = 0.0;              fadeInProgress = 0.0;               isFadingOut = true;             }

    public override function onUpdate(elapsed: Float): FrameYield {
        if (isFadingOut) {
                        if (outScreen != null) {
                fadeOutProgress += elapsed;                  var ratio = fadeOutProgress / fadeOutDuration;                  outScreen.alpha = 1.0 - ratio;                  if (ratio >= 1.0) {
                    outScreen.alpha = 0.0;                          isFadingOut = false;                        }
            } else {
                isFadingOut = false;              }
        } else {
                        if (inScreen != null) {
                fadeInProgress += elapsed;                  var ratio = fadeInProgress / fadeInDuration;                  inScreen.alpha = ratio;                     if (ratio >= 1.0) {
                    inScreen.alpha = 1.0;                       return FrameYield.Stop;                  }
            } else {
                return FrameYield.Stop;              }
        }
        return FrameYield.WaitNextFrame;      }

    public override function onComplete(): Void {
                if (outScreen != null) {
            outScreen.alpha = 0.0;          }
        if (inScreen != null) {
            inScreen.alpha = 1.0;           }
    }
}