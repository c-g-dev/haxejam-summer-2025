package state;

import state.HState;
import heaps.coroutine.Future;
import ludi.heaps.box.Box;

class StartMenuState extends HState {

    var root: h2d.Object;
    var startButton: Box;

    function setup(): Void {
        root = new h2d.Object();
        this.app.s2d.add(root);

        var bg = new h2d.Bitmap(h2d.Tile.fromColor(0x202020, 1, 1));
        bg.scaleX = this.app.s2d.width;
        bg.scaleY = this.app.s2d.height;
        root.addChild(bg);

        var b = Box.build(220, 64);
        b.backgroundColor(0xC6C9C6);
        b.verticalGradient(0xFFFFFF, 0xC6C9C6);
        b.roundedCorners(8);
        b.roundedBorder(4, 0x000000, 8);
        b.text("Start", 0x000000);
        startButton = b.get();
        root.addChild(startButton);
        startButton.x = (this.app.s2d.width - startButton.width) / 2;
        startButton.y = (this.app.s2d.height - startButton.height) / 2;

        startButton.onClick(_ -> {
            setState(new PlanetaryState());
        });
    }

    function lifecycle(e: HStateLifeCycle) : Future {
        switch e {
            case Create: {
                setup();
                return Future.immediate();
            }
            case Activate: {
                return Future.immediate();
            }
            case Deactivate: {
                return Future.immediate();
            }
            case Destroy: {
                if (root != null) {
                    this.app.s2d.removeChild(root);
                    root = null;
                }
                return Future.immediate();
            }
        }
    }

    public function onUpdate(dt:Float) : Void {
            }

}