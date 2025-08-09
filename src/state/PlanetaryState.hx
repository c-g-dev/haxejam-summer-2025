package state;

import state.HState;
import heaps.coroutine.Future;
import space.Planet;
import space.Sun;
import overlay.MechSpriteOverlay;
import overlay.WorldActionChoice;
import effects.UICircler;
import h3d.scene.fwd.DirLight;
import input.GameControls.GameControlActions;
import input.GameControls;
import ui.Nav.ArrowNav;
import ui.Nav.ArrowNavEvent;
import ui.SeedListView;
import engine.EventImpl.ZoneService;
import engine.Game;
import engine.WorldEngine;
import state.planetary.SelectSeedSubstate;
import space.SpaceEffects;
import space.Stars;
import ludi.heaps.form.controls.FormButton;
import ludi.heaps.box.Box;

enum PlanetaryMode {
    Idle;
    CameraPanning;
    WaitingEffect;
    MenusOpen;
}

class PlanetaryState extends HState {

    var planet: Planet;
    var sun: Sun;
    var dirLight: DirLight;
    var overlay: MechSpriteOverlay;
    var input: PlanetaryStateControls;
    var effects: SpaceEffects;
    var stars: Stars;

    var currentTri: Int = 0;
    var mode: PlanetaryMode = Idle;

    // Action menu state
    var menuCircler: UICircler;
    var menuNav: ArrowNav;
    var menuChoices: Array<WorldActionChoice>;

    // Seed list UI (debug/inventory)debug
    var seedList: SeedListView;
    // Cache of adjacents for current tri to avoid rebuilding arrays
    var currentAdjacents: Array<Int> = [];
    var rotateButton: Box;

    function setup(): Void {
        input = new PlanetaryStateControls();

        // Ensure a world exists
        if (Game.world == null) {
            Game.seedInitialWorld();
            WorldEngine.world = Game.world;
        }

        dirLight = new DirLight(new h3d.Vector(0.5, 0.5, -0.5), this.app.s3d);
        dirLight.enableSpecular = true;

        // Background sky dome
        stars = new Stars(this.app.s3d, this.app.s3d.camera);

        planet = new Planet(this.app.s3d, this.app.s2d, this.app.s3d.camera);

        this.app.s3d.camera.pos.set(0, 0, 5); 
        this.app.s3d.camera.target.set(0, 0, 0);

        sun = new Sun(this.app.s3d);

        overlay = new MechSpriteOverlay(planet);
        this.app.s2d.addChild(overlay);

        effects = new SpaceEffects(planet);

        // Bottom-right rotate button
        rotateButton = new FormButton("Rotate 90°");
        this.app.s2d.addChild(rotateButton);
        positionRotateButton();
        rotateButton.onClick((_) -> {
            if (mode == WaitingEffect || mode == CameraPanning || mode == MenusOpen) return;
            mode = WaitingEffect;
            effects.rotatePlanetQuarterTurn().then((_) -> {
                mode = Idle;
            });
        });

        // Create seed list UI docked on right side
        seedList = new SeedListView(360, this.app.s2d.height);
        seedList.x = this.app.s2d.width - seedList.totalWidth;
        seedList.y = 0;
     //   this.app.s2d.addChild(seedList);

        // Initial overlay paint
        refreshTriZoneOverlays();
    }

    public function lifecycle(e:HStateLifeCycle):Future<Dynamic> {
        switch e {
            case Create: {
                setup();
                return Future.immediate();
            }
            case Activate: {
                currentTri = 0;
                mode = Idle;
                return Future.immediate();
            }
            case Deactivate: {
                return Future.immediate();
            }
            case Destroy: {
                if (stars != null) {
                    this.app.s3d.removeChild(stars);
                    stars = null;
                }
                if (overlay != null) {
                    this.app.s2d.removeChild(overlay);
                    overlay = null;
                }
                if (rotateButton != null) {
                    this.app.s2d.removeChild(rotateButton);
                    rotateButton = null;
                }
                if (seedList != null) {
                    this.app.s2d.removeChild(seedList);
                    seedList = null;
                }
                if (sun != null) {
                    this.app.s3d.removeChild(sun);
                    sun = null;
                }
                if (planet != null) {
                    this.app.s3d.removeChild(planet);
                    planet = null;
                }
                if (dirLight != null) {
                    this.app.s3d.removeChild(dirLight);
                    dirLight = null;
                }
                return Future.immediate();
            }
        }
    }

    // Pick adjacent triangle whose on-screen direction from current center best matches (dirX, dirY) in NDC
    function findNeighborInDirection(dirX: Float, dirY: Float): Int {
        var neighbors = planet.adjMap.get(currentTri);
        if (neighbors == null || neighbors.length == 0) return -1;

        var len = Math.sqrt(dirX * dirX + dirY * dirY);
        if (len == 0) return -1;
        var ndx = dirX / len;
        var ndy = dirY / len;

        var cam = this.app.s3d.camera;
        var c0 = planet.getTriangleCenter(currentTri);
        var p0 = c0.clone();
        p0.project(cam.m);

        var best = -1;
        var bestDot = -1.0;

        for (ni in neighbors) {
            var c1 = planet.getTriangleCenter(ni);
            if (c1 == null) continue;
            var p1 = c1.clone();
            p1.project(cam.m);
            var dx = p1.x - p0.x;
            var dy = p1.y - p0.y;
            var dlen = Math.sqrt(dx * dx + dy * dy);
            if (dlen == 0) continue;
            dx /= dlen; dy /= dlen;
            var dot = dx * ndx + dy * ndy;
            if (dot > bestDot) {
                bestDot = dot;
                best = ni;
            }
        }
        return best;
    }

    function openActionMenu():Void {
        if (menuCircler != null || mode == MenusOpen) return;

        var cx = hxd.Window.getInstance().width / 2;
        var cy = hxd.Window.getInstance().height / 2;

        menuNav = new ArrowNav();
        menuCircler = new UICircler(this.app.s2d, cx, cy, 140);
        menuChoices = [];

        // Build actions from ZoneService using the current triangle as zone id
        var zoneId = currentTri;
        var world = Game.world;
        var zone = world.zones[zoneId];
        var labels = ZoneService.getPlayerActionsOnZone(zone, world);
        if (labels == null || labels.length == 0) {
            // Nothing to show
            menuCircler.remove();
            menuCircler = null;
            menuNav = null;
            return;
        }

        for (lbl in labels) {
            var choice = new WorldActionChoice(lbl);
            choice.onSelected = () -> {
                trace('Selected action: ' + lbl + ' on zone #' + zoneId);
                closeActionMenu();
                if (lbl == "Plant Seed") {
                    this.openSubState(new SelectSeedSubstate(zoneId));
                }
            };
            menuChoices.push(choice);
            menuCircler.addItem(choice, 1);
            menuNav.bind(choice, (e:ArrowNavEvent) -> {
                switch e {
                    case Enter:
                        choice.setSelected(true);
                    case Leave:
                        choice.setSelected(false);
                    case Selected: {
                        menuCircler.remove();
                        choice.trigger();
                    }
                }
            });
        }

        mode = MenusOpen;
        // Fire the entrance animation; we do not block input while animating
        menuCircler.start();
    }

    function closeActionMenu():Void {
        if (menuCircler != null) {
            menuCircler.remove();
            menuCircler = null;
        }
        menuNav = null;
        menuChoices = null;
        mode = Idle;
    }

    public function onUpdate(dt:Float):Void {
        if (planet == null) return;
        if (rotateButton != null) positionRotateButton();

        if (mode == Idle) {
            if (input.isActionPressed()) {
                openActionMenu();
            } else {
                var mv = input.readMovement();
                if (mv.anyPress) {
                    var next = findNeighborInDirection(mv.x, mv.y);
                    if (next != -1) {
                        currentTri = next;
                        mode = CameraPanning;
                        planet.cameraMover.moveToTriangle(currentTri, 2).then((_) -> {
                            mode = Idle;
                            // After camera move completes, refresh overlays
                            refreshTriZoneOverlays();
                        });
                    }
                }
            }
        } else if (mode == MenusOpen) {
            if (menuNav != null) menuNav.update();
            if (input.isActionPressed()) {
                openActionMenu();
            }
        }

        overlay.updateFacingFromCamera();

        planet.updateLabels(this.app.s3d.camera, this.app.s2d);

        if (seedList != null) seedList.update(dt);

        // Sky follows camera in its own sync

        // Update tints/highlights each frame in case world changes or selection moved
        refreshTriZoneOverlays();
    }

    // Recompute hostile red fills and friendly-adjacent glow from currentTri
    function refreshTriZoneOverlays(): Void {
        if (planet == null) return;
        var world = Game.world;
        if (world == null || world.zones == null || world.zones.length == 0) return;

        // Clear all overlays first
        planet.clearTriOverlays();

        // 1) Hostile zones -> solid/semi-transparent red fill
        // 2) Friendly adjacent to currentTri -> soft glow
        // Note: use labels length as authoritative number of trizones drawn on sphere
        var total = world.zones.length;
        if (total > 80) total = 80; // safety; sphere has 80 subfaces

        // Mark hostile across all indices
        for (i in 0...total) {
            var z = world.zones[i];
            if (z != null && z.isHostile) {
                // Red with some transparency so base texture shows through
                planet.colorTriOverlay(i, 1.0, 0.0, 0.0, 0.35);
            }
        }

        // Friendly-adjacent glow: neighbors of currentTri that are not hostile
        currentAdjacents = planet.adjMap.get(currentTri);
        if (currentAdjacents != null) {
            for (nid in currentAdjacents) {
                if (nid < 0 || nid >= total) continue;
                var nz = world.zones[nid];
                if (nz == null || nz.isHostile) continue;
                // Soft light blue-ish glow, add on top of any red? No: red means hostile, skip
                planet.colorTriOverlay(nid, 0.4, 0.8, 1.0, 0.25);
            }
        }

        // Highlight current triangle subtly for verification
        if (currentTri >= 0 && currentTri < total)
            planet.colorTriOverlay(currentTri, 0.0, 1.0, 0.0, 0.3);
    }

    inline function positionRotateButton(): Void {
        if (rotateButton == null) return;
        var b = rotateButton.getBounds();
        rotateButton.x = this.app.s2d.width - b.width - 12;
        rotateButton.y = this.app.s2d.height - b.height - 12;
    }
}


class PlanetaryStateControls {
    var controls: GameControls;

    public function new() {
        controls = GameControls.get();
    }

    public function readMovement(): { x: Float, y: Float, anyPress: Bool } {
        var moveX = 0.0;
        var moveY = 0.0;
        var anyPress = false;
        if (controls.isPressed(MoveUp)) { moveY += 1; anyPress = true; }
        if (controls.isPressed(MoveDown)) { moveY -= 1; anyPress = true; }
        if (controls.isPressed(MoveRight)) { moveX += 1; anyPress = true; }
        if (controls.isPressed(MoveLeft)) { moveX -= 1; anyPress = true; }
        return { x: moveX, y: moveY, anyPress: anyPress };
    }

    public inline function isActionPressed(): Bool {
        return controls.isPressed(Action);
    }
}