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
import effects.DreamyScreen.DreamyFilter;
import hxd.snd.Channel;

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
    MechFlyingOverlay;
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
    var INITIAL_SCALE: Float = 6;

        var spaceScrollContainer: Object;
    var spaceScrollTile: Tile;
    var spaceScrollLeft: Bitmap;
    var spaceScrollRight: Bitmap;
    var spaceScrollOffset: Float = 0;
    var spaceScrollSpeed: Float = 40; 
    var dreamyFilter: DreamyFilter;
    var bgmChannel: Channel;

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

        var bg = makeBitmap(tileFor(DreamFlower));
        bg.scaleX = INITIAL_SCALE;
        bg.scaleY = INITIAL_SCALE;
        currentCG = bg;
        cgContainer.addChild(bg);
        
        dreamyFilter = new DreamyFilter();
        dreamyFilter.intensity = 5;
        dreamyFilter.aberration = 20;
        dreamyFilter.vignette = 5;
        dreamyFilter.grain =  0.6;
        dreamyFilter.blur = 70;
        this.app.s2d.filter = dreamyFilter;
    }

    function dispose(): Void {
        if (root != null) {
            deactivateSpaceScroll();
            this.app.s2d.removeChild(root);
            root = null;
            cgContainer = null;
            overlayContainer = null;
            textContainer = null;
            currentCG = null;
            overlayCG = null;
        }
        if (dreamyFilter != null) {
            this.app.s2d.filter = null;
            dreamyFilter = null;
        }
        if (bgmChannel != null) {
            bgmChannel.stop();
            bgmChannel = null;
        }
    }

    public function lifecycle(e: HStateLifeCycle):Future {
        switch e {
            case Create: {
                setup();
                return Future.immediate();
            }
            case Activate: {
                if (bgmChannel == null) {
                    bgmChannel = hxd.Res.load("sounds/opening.mp3").toSound().play(true, 0.2);
                }
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

    public function onUpdate(dt:Float):Void {
                if (spaceScrollContainer != null && spaceScrollTile != null) {
            spaceScrollOffset += spaceScrollSpeed * dt;
            var w = spaceScrollTile.width;
            var baseX = -w * 0.5;
            var offs = spaceScrollOffset % w;
            spaceScrollLeft.x = baseX - offs;
            spaceScrollLeft.y = -spaceScrollTile.height * 0.5;
            spaceScrollRight.x = spaceScrollLeft.x + w;
            spaceScrollRight.y = spaceScrollLeft.y;
        }
    }

    function playSequence(): Future {
        return Coro.start((ctx: CoroutineContext) -> {
                        Coro.once(() -> {
                var cg = setCG(DreamFlower, 1.0);
                                cg.scaleX = INITIAL_SCALE;
                cg.scaleY = INITIAL_SCALE;
                zoomTo(2, 12.0);
            });
            
         
            poem([
                "In the last days of Plant World",
                "the flora learned to grow their roots UP",
                "and they called these",
                "DREAMS"
            ]).await();
          
            poem([
                "And thus no longer were they chained to the dirt",
                "In those days the plants had no roots",
                "and so every plant could do as it saw fit"
            ]).await();


            crossfadeTo(Deadworld1, 2.5).await();
            poem([
                "Without the plants' wise grip",
                "The dirt below disgorged its ancient tensions",
                "And the earth churned",
                "And the land rotted into a dusty sea",
                "And never again were there children"
            ]).await();
            waitSeconds(3.0).await();

            crossfadeTo(Deadworld2, 2.0).await();
            waitSeconds(3.0).await();

                        fadeToBlack(1.0).await();
            Coro.once(() -> { setCG(Deadworld3, 1.0); });
            fadeFromBlack(1.0).await();

            fadeOverlayIn(Dreamseed, 1.0).await();
            poem([
                "Their only hope",
                "The Dreamseed",
                "In which the DNA of all Plantae slept",
                "",
                "But what wind will blow it?",
                "What bird would scatter it?"
            ]).await();

            fadeOverlayOut(1.0).await();

            crossfadeTo(Deadworld3, 2.0).await();
            fadeOverlayIn(DreamSunflower, 2.0).await();
            poem([
                "And so",
                "In the last days of Plant World"
            ]).await();

                        var off: Float = 0;
            Coro.once(() -> {
                               var mechR = makeBitmap(tileFor(MechHalf1));
                var mechL = makeBitmap(tileFor(MechHalf2));
                overlayContainer.addChild(mechL);
                overlayContainer.addChild(mechR);
                mechL.scale(2);
                mechR.scale(2);
                var y = 0.0;
                off = Math.max(this.app.s2d.width, this.app.s2d.height);
                mechL.x = -off; mechL.y = y;
                mechR.x = off; mechR.y = y;
                ctx.setData("mechL", mechL);
                ctx.setData("mechR", mechR);
                ctx.setData("off", off);
            });

            var mechLRef: Bitmap = ctx.getData("mechL");
            var mechRRef: Bitmap = ctx.getData("mechR");
            var offRef: Float = ctx.getData("off");

            var collideTime = 0.5;
            Coro.start((cctx: CoroutineContext) -> {
                Coro.once(() -> {
                    cctx.setData("mechL", mechLRef);
                    cctx.setData("mechR", mechRRef);
                    cctx.setData("off", offRef);
                });
                var t = cctx.elapsed / collideTime;
                if (t >= 1) {
                    var ml: Bitmap = cctx.getData("mechL");
                    var mr: Bitmap = cctx.getData("mechR");
                    ml.remove();
                    mr.remove();
                    return Stop;
                }
                var ml: Bitmap = cctx.getData("mechL");
                var mr: Bitmap = cctx.getData("mechR");
                var offv: Float = cctx.getData("off");
                var mlHalfW = ml.tile.width * ml.scaleX * 0.5;
                var mrHalfW = mr.tile.width * mr.scaleX * 0.5;
                ml.x = (-offv) * (1 - t) + (-mlHalfW) * t;
                mr.x = (offv) * (1 - t) + (mrHalfW) * t;
                
                return WaitNextFrame;
            }).await();

                        Coro.once(() -> { clearOverlays(); });
            fadeToBlack(0.2).await();
            Coro.once(() -> { setCG(MechFull, 1.0); });
            fadeFromBlack(0.8).await();
            poem(["The flora built a MACHINE"]).await();

                                  waitSeconds(2).await();

            crossfadeTo(FlyingThroughSpace, 2.5).await();
            fadeOverlayIn(MechFlyingOverlay, 2.5).await();
       
            poem([
                "To search for a new garden",
                "In the unknown eons",
                "Billions of years",
                "Dreaming",
                "Dreaming",
                "Until..."
            ]).await();

            waitSeconds(2).await();
            fadeToBlack(0.2).await();

            
            Coro.once(() -> { setState(new PlanetaryState()); });
            return Stop;
        }).future();
    }

    function poem(lines: Array<String>): Future {
        return Coro.start((ctx: CoroutineContext) -> {
            var scale = 0.50;
            var lineSpacing = 1.45;
            var font: Font = hxd.Res.fonts.plex_mono_64.toFont();

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

    function setCG(cg: CutsceneCGs, alpha: Float): Bitmap {
        clearOverlays();
        if (currentCG != null) {
            cgContainer.removeChild(currentCG);
            currentCG = null;
        }
        if (cg == null) return null;
        if (cg == FlyingThroughSpace) activateSpaceScroll(); else deactivateSpaceScroll();
        currentCG = makeBitmap(tileFor(cg));
        currentCG.alpha = alpha;
        cgContainer.addChild(currentCG);
        return currentCG;
    }

    function crossfadeTo(cg: CutsceneCGs, duration: Float): Future {
        return Coro.start((ctx: CoroutineContext) -> {
            var next: Bitmap = null;
            var start: Bitmap = null;
            Coro.once(() -> {
                if (cg == FlyingThroughSpace) activateSpaceScroll();
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
                                if (cg == FlyingThroughSpace) activateSpaceScroll(); else deactivateSpaceScroll();
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

        function activateSpaceScroll(): Void {
        if (spaceScrollContainer != null) return;
        spaceScrollTile = hxd.Res.cutscene.skybox.toTile();
        spaceScrollContainer = new Object(root);
                root.addChildAt(spaceScrollContainer, 0);

                var s = this.app.s2d.height / spaceScrollTile.height;
        spaceScrollContainer.scaleX = s;
        spaceScrollContainer.scaleY = s;
        spaceScrollContainer.x = this.app.s2d.width * 0.5;
        spaceScrollContainer.y = this.app.s2d.height * 0.5;

        spaceScrollLeft = new Bitmap(spaceScrollTile, spaceScrollContainer);
        spaceScrollRight = new Bitmap(spaceScrollTile, spaceScrollContainer);
        spaceScrollOffset = 0;
    }

    function deactivateSpaceScroll(): Void {
        if (spaceScrollContainer == null) return;
        spaceScrollContainer.remove();
        spaceScrollContainer = null;
        spaceScrollLeft = null;
        spaceScrollRight = null;
        spaceScrollTile = null;
        spaceScrollOffset = 0;
    }

    function zoomTo(scale: Float, duration: Float): Future {
        var startScale = currentCG != null ? currentCG.scaleX : 1.0;
        return Coro.start((ctx: CoroutineContext) -> {
            trace("zoomTo " + scale + " " + duration);
            var r = ctx.elapsed / duration;
            if (r >= 1) {
                currentCG.scaleX = scale;
                currentCG.scaleY = scale;
                return Stop;
            }
            var s = startScale + (scale - startScale) * r;
            currentCG.scaleX = s;
            currentCG.scaleY = s;
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
                var centered = t.center();
        var b = new Bitmap(centered);
        b.x = 0;
        b.y = 0;
        return b;
    }

    function tileFor(cg: CutsceneCGs): Tile {
                return switch (cg) {
            case Deadworld1: hxd.Res.cutscene.deadworld1.toTile().center();
            case DreamFlower: hxd.Res.cutscene.dreamflower.toTile().center();
            case Deadworld2: hxd.Res.cutscene.deadworld2.toTile().center();
            case Deadworld3: Tile.fromColor(0x0F0F0F, Std.int(this.app.s2d.width), Std.int(this.app.s2d.height)).center();
            case DreamSunflower: hxd.Res.cutscene.dreamsunflower.toTile().center();
            case MechHalf1:  hxd.Res.cutscene.mechhalf.toTile();
            case MechHalf2: hxd.Res.cutscene.mechhalf2.toTile();
            case MechFull: hxd.Res.guy1.toTile();
            case Dreamseed: hxd.Res.cutscene.seed.toTile().center();
                        case FlyingThroughSpace: Tile.fromColor(0x00000000, Std.int(this.app.s2d.width), Std.int(this.app.s2d.height)).center();
            case MechFlyingOverlay: hxd.Res.cutscene.guymove.toTile().center();
            case PlanetCG: Tile.fromColor(0x003300, Std.int(this.app.s2d.width), Std.int(this.app.s2d.height)).center();
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