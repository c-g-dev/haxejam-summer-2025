package state;

import heaps.coroutine.Coro;
import heaps.coroutine.Coroutine.CoroutineContext;
import heaps.coroutine.Future;
import h2d.Bitmap;
import h2d.Object;
import h2d.Tile;
import h2d.Text;
import h2d.Font;
import ui.PoignantText;
import state.HState.HStateLifeCycle;
import state.HState.HStateTransitionInFade;
import state.HState.HStateTransitionOutFade;
import state.HState.HStateTransitionFadeManager;

enum CutsceneCGs {
    Deadworld1;
    DreamFlower;
    Deadworld2;
    Deadworld3;
    DreamSunflower;
    MechHalf1;
    MechHalf2;
    MechFull;
    Dreamseed;
    FlyingThroughSpace;
    PlanetCG;
}

class OpeningCutsceneState extends HState {

    var root: Object;
    var cgContainer: Object;
    var overlayContainer: Object;
    var textContainer: Object;

    var currentCG: Bitmap;
    var overlayCG: Bitmap;

    var running: Future;

    public function new() {
        super();
        this.transitionIn = new HStateTransitionInFade();
        this.transitionOut = new HStateTransitionOutFade();
    }

    function setup(): Void {
        root = new Object();
        cgContainer = new Object(root);
        overlayContainer = new Object(root);
        textContainer = new Object(root);
        this.app.s2d.add(root, 0);

        cgContainer.x = this.app.s2d.width * 0.5;
        cgContainer.y = this.app.s2d.height * 0.5;
        overlayContainer.x = cgContainer.x;
        overlayContainer.y = cgContainer.y;

        var bg = makeBitmap(tileFor(Deadworld1));
        currentCG = bg;
        cgContainer.addChild(bg);
    }

    function dispose(): Void {
        if (root != null) {
            this.app.s2d.removeChild(root);
            root = null;
            cgContainer = null;
            overlayContainer = null;
            textContainer = null;
            currentCG = null;
            overlayCG = null;
        }
    }

    public function lifecycle(e: HStateLifeCycle):Future {
        switch e {
            case Create: {
                setup();
                return Future.immediate();
            }
            case Activate: {
                running = playSequence();
                return Future.immediate();
            }
            case Deactivate: {
                return Future.immediate();
            }
            case Destroy: {
                dispose();
                return Future.immediate();
            }
        }
    }

    public function onUpdate(dt:Float):Void {}

    function playSequence(): Future {
        return Coro.start((ctx: CoroutineContext) -> {
            // Black screen fade-in is handled by transitionIn
            Coro.once(() -> { setCG(Deadworld1, 1.6); });
            zoomTo(1.3, 6.0).await();
            fadeOverlayIn(DreamFlower, 3.0).await();

            poem([
                "In the last days of PlantWorld,",
                "the flora learned to grow their roots UP",
                "and they called these",
                "DREAMS"
            ]).await();
            fadeOverlayOut(2.0).await();

            poem([
                "And thus no longer were they chained to the dirt.",
                "In those days the plants had no roots,",
                "and so every plant could do as it saw fit."
            ]).await();

            crossfadeTo(Deadworld2, 2.5).await();
            poem([
                "Without the plants' wise grip",
                "The dirt below disgorged its ancient tensions",
                "And the earth churned",
                "And the land rotted into a dusty sea",
                "And never again were there children."
            ]).await();

            crossfadeTo(Dreamseed, 2.0).await();
            poem([
                "Their only hope",
                "The Dreamseed",
                "In which the DNA of all Plantae slept",
                "",
                "But what wind will blow it?",
                "What bird would scatter it?"
            ]).await();

            crossfadeTo(Deadworld3, 2.0).await();
            fadeOverlayIn(DreamSunflower, 2.0).await();
            poem([
                "And so",
                "In the last days of PlantWorld"
            ]).await();
            fadeOverlayOut(1.0).await();

            // Mech halves collide
            var off: Float = 0;
            Coro.once(() -> {
                setCG(null, 1.0);
                var mechL = makeBitmap(tileFor(MechHalf1));
                var mechR = makeBitmap(tileFor(MechHalf2));
                overlayContainer.addChild(mechL);
                overlayContainer.addChild(mechR);
                var y = 0.0;
                off = Math.max(this.app.s2d.width, this.app.s2d.height);
                mechL.x = -off; mechL.y = y;
                mechR.x = off - mechR.tile.width; mechR.y = y;
                ctx.setData("mechL", mechL);
                ctx.setData("mechR", mechR);
                ctx.setData("off", off);
            });

            var mechLRef: Bitmap = ctx.getData("mechL");
            var mechRRef: Bitmap = ctx.getData("mechR");
            var offRef: Float = ctx.getData("off");

            var collideTime = 1.5;
            Coro.start((cctx: CoroutineContext) -> {
                Coro.once(() -> {
                    cctx.setData("mechL", mechLRef);
                    cctx.setData("mechR", mechRRef);
                    cctx.setData("off", offRef);
                });
                var t = cctx.elapsed / collideTime;
                if (t >= 1) return Stop;
                var ml: Bitmap = cctx.getData("mechL");
                var mr: Bitmap = cctx.getData("mechR");
                var offv: Float = cctx.getData("off");
                ml.x = -ml.tile.width - (offv - ml.tile.width) * (1 - t);
                mr.x = (offv - mr.tile.width) * (1 - t);
                return WaitNextFrame;
            }).await();

            // Cut to black then show full mech
            Coro.once(() -> { clearOverlays(); });
            fadeToBlack(0.2).await();
            Coro.once(() -> { setCG(MechFull, 1.0); });
            fadeFromBlack(0.8).await();
            poem(["The flora built a MACHINE"]).await();

            crossfadeTo(FlyingThroughSpace, 2.5).await();
            poem([
                "To search for a new garden",
                "In the unknown eons",
                "Billions of years",
                "Dreaming",
                "Dreaming",
                "Until..."
            ]).await();

            crossfadeTo(PlanetCG, 2.5).await();

            Coro.once(() -> { setState(new PlanetaryState()); });
            return Stop;
        }).future();
    }

    function poem(lines: Array<String>): Future {
        return Coro.start((ctx: CoroutineContext) -> {
            var scale = 0.28;
            var lineSpacing = 1.25;
            var font: Font = hxd.Res.fonts.plex_mono_64.toFont();

            // Pre-measure to center without needing getBounds()
            var measured = measureTextBlock(lines, font, scale, lineSpacing);

            Coro.once(() -> {
                var pt = new PoignantText(lines, font, scale);
                textContainer.addChild(pt);
                pt.x = (this.app.s2d.width - measured.w) * 0.5;
                pt.y = (this.app.s2d.height - measured.h) * 0.5;
                ctx.setData("pt", pt);
            });

            (ctx.getData("pt"): PoignantText).start().await();
            waitSeconds(0.6).await();
            Coro.once(() -> { (ctx.getData("pt"): PoignantText).remove(); });
            return Stop;
        }).future();
    }

    function setCG(cg: CutsceneCGs, alpha: Float): Void {
        clearOverlays();
        if (currentCG != null) {
            cgContainer.removeChild(currentCG);
            currentCG = null;
        }
        if (cg == null) return;
        currentCG = makeBitmap(tileFor(cg));
        currentCG.alpha = alpha;
        cgContainer.addChild(currentCG);
    }

    function crossfadeTo(cg: CutsceneCGs, duration: Float): Future {
        return Coro.start((ctx: CoroutineContext) -> {
            var next: Bitmap = null;
            var start: Bitmap = null;
            Coro.once(() -> {
                next = makeBitmap(tileFor(cg));
                next.alpha = 0;
                ctx.setData("next", next);
                cgContainer.addChild(next);
                start = currentCG;
                ctx.setData("start", start);
            });
            var r = ctx.elapsed / duration;
            if (r >= 1) {
                var st: Bitmap = ctx.getData("start");
                if (st != null) cgContainer.removeChild(st);
                currentCG = ctx.getData("next");
                return Stop;
            }
            var st2: Bitmap = ctx.getData("start");
            if (st2 != null) st2.alpha = 1 - r;
            (ctx.getData("next"): Bitmap).alpha = r;
            return WaitNextFrame;
        }).future();
    }

    function fadeOverlayIn(cg: CutsceneCGs, duration: Float): Future {
        clearOverlays();
        return Coro.start((ctx: CoroutineContext) -> {
            Coro.once(() -> {
                overlayCG = makeBitmap(tileFor(cg));
                overlayCG.alpha = 0;
                overlayContainer.addChild(overlayCG);
            });
            var r = ctx.elapsed / duration;
            if (r >= 1) {
                overlayCG.alpha = 1;
                return Stop;
            }
            overlayCG.alpha = r;
            return WaitNextFrame;
        }).future();
    }

    function fadeOverlayOut(duration: Float): Future {
        if (overlayCG == null) return Future.immediate();
        return Coro.start((ctx: CoroutineContext) -> {
            var r = ctx.elapsed / duration;
            if (r >= 1) {
                overlayContainer.removeChild(overlayCG);
                overlayCG = null;
                return Stop;
            }
            overlayCG.alpha = 1 - r;
            return WaitNextFrame;
        }).future();
    }

    function clearOverlays(): Void {
        if (overlayCG != null) {
            overlayContainer.removeChild(overlayCG);
            overlayCG = null;
        }
    }

    function zoomTo(scale: Float, duration: Float): Future {
        var startScale = cgContainer.scaleX;
        if (startScale == 0) startScale = 1.0;
        return Coro.start((ctx: CoroutineContext) -> {
            var r = ctx.elapsed / duration;
            if (r >= 1) {
                cgContainer.scaleX = scale;
                cgContainer.scaleY = scale;
                overlayContainer.scaleX = scale;
                overlayContainer.scaleY = scale;
                return Stop;
            }
            var s = startScale + (scale - startScale) * r;
            cgContainer.scaleX = s;
            cgContainer.scaleY = s;
            overlayContainer.scaleX = s;
            overlayContainer.scaleY = s;
            return WaitNextFrame;
        }).future();
    }

    function fadeToBlack(duration: Float): Future {
        return Coro.start((ctx: CoroutineContext) -> {
            Coro.once(() -> {
                HStateTransitionFadeManager.attach();
                HStateTransitionFadeManager.blackScreen.alpha = 0;
            });
            var r = ctx.elapsed / duration;
            if (r >= 1) {
                HStateTransitionFadeManager.blackScreen.alpha = 1;
                return Stop;
            }
            HStateTransitionFadeManager.blackScreen.alpha = r;
            return WaitNextFrame;
        }).future();
    }

    function fadeFromBlack(duration: Float): Future {
        return Coro.start((ctx: CoroutineContext) -> {
            Coro.once(() -> {
                HStateTransitionFadeManager.attach();
                HStateTransitionFadeManager.blackScreen.alpha = 1;
            });
            var r = ctx.elapsed / duration;
            if (r >= 1) {
                HStateTransitionFadeManager.blackScreen.alpha = 0;
                HStateTransitionFadeManager.detach();
                return Stop;
            }
            HStateTransitionFadeManager.blackScreen.alpha = 1 - r;
            return WaitNextFrame;
        }).future();
    }

    function waitSeconds(sec: Float): Future {
        return Coro.start((ctx: CoroutineContext) -> {
            trace("waiting " + ctx.elapsed);
            if (ctx.elapsed >= sec) return Stop;
            return WaitNextFrame;
        }).future();
    }

    function makeBitmap(t: Tile): Bitmap {
        var b = new Bitmap(t);
        b.x = -t.width * 0.5;
        b.y = -t.height * 0.5;
        return b;
    }

    function tileFor(cg: CutsceneCGs): Tile {
        // Placeholder tiles; replace with actual assets later
        return switch (cg) {
            case Deadworld1: Tile.fromColor(0x101010, Std.int(this.app.s2d.width), Std.int(this.app.s2d.height));
            case DreamFlower: Tile.fromColor(0x556B2F, Std.int(this.app.s2d.width), Std.int(this.app.s2d.height));
            case Deadworld2: Tile.fromColor(0x1A1A1A, Std.int(this.app.s2d.width), Std.int(this.app.s2d.height));
            case Deadworld3: Tile.fromColor(0x0F0F0F, Std.int(this.app.s2d.width), Std.int(this.app.s2d.height));
            case DreamSunflower: Tile.fromColor(0xB8860B, Std.int(this.app.s2d.width), Std.int(this.app.s2d.height));
            case MechHalf1: Tile.fromColor(0x224488, 512, 512);
            case MechHalf2: Tile.fromColor(0x882244, 512, 512);
            case MechFull: Tile.fromColor(0x6699CC, 768, 512);
            case Dreamseed: Tile.fromColor(0x2F4F4F, Std.int(this.app.s2d.width), Std.int(this.app.s2d.height));
            case FlyingThroughSpace: Tile.fromColor(0x000022, Std.int(this.app.s2d.width), Std.int(this.app.s2d.height));
            case PlanetCG: Tile.fromColor(0x003300, Std.int(this.app.s2d.width), Std.int(this.app.s2d.height));
        }
    }

    static function measureTextBlock(lines: Array<String>, font: Font, scale: Float, lineSpacingMultiplier: Float): { w: Float, h: Float } {
        var t = new Text(font, null);
        var maxW: Float = 0;
        for (line in lines) {
            t.text = line;
            var w = t.textWidth * scale;
            if (w > maxW) maxW = w;
        }
        var h = lines.length * font.lineHeight * scale * lineSpacingMultiplier;
        return { w: maxW, h: h };
    }
}