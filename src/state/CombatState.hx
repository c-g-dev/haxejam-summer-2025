package state;

import state.HState;
import heaps.coroutine.Future;
import heaps.coroutine.Coro;
import heaps.coroutine.Coroutine;
import heaps.coroutine.Coroutine.CoroutineContext;

import ui.Nav.ArrowNav;
import ui.Nav.ArrowNavEvent;
import ludi.heaps.form.controls.FormButton;
import ludi.heaps.box.Box;
import effects.Lightning;
import hxd.res.DefaultFont;
import engine.Game;


enum CombatTurn { Player; Enemy; }

class CombatState extends HState {
    var root: h2d.Object;
    var nav: ArrowNav;

        var playerGroup: h2d.Object;
    var enemyGroup: h2d.Object;
    var playerBmp: h2d.Bitmap;
    var enemyBmp: h2d.Bitmap;

    var playerHp:Int = 100;
    var enemyHp:Int = 100;

        var playerHpBar: HpBar;
    var enemyHpBar: HpBar;

        var playerHpLabel: h2d.Text;
    var enemyHpLabel: h2d.Text;

        var playerNameText: h2d.Text;
    var enemyNameText: h2d.Text;
    var playerName:String = "Player";
    var enemyName:String = "Enemy";

    var lightning: Lightning;

    var playerWeapons:Array<String> = ["Slash", "Zap", "Blast"];
    var enemyWeapons:Array<String> = ["Claw", "Bite", "Roar"];

    var turn: CombatTurn = Player;

        var bgBase:h2d.Graphics;
    var bgOverlay:h2d.Graphics;
    var bgW:Int = -1;
    var bgH:Int = -1;

        var playerMaskG: h2d.Graphics;
    var enemyMaskG: h2d.Graphics;

        var zoneId:Int;

    public function new(zoneId:Int) {
        super();
        this.zoneId = zoneId;
    }

    function setup(): Void {
        root = new h2d.Object();
        this.app.s2d.add(root);

                bgBase = new h2d.Graphics(root);
        bgOverlay = new h2d.Graphics(root);
        redrawBackgrounds();

                lightning = new Lightning(root, 24, this.app.s2d.height - 24, this.app.s2d.width - 24, 24);
        lightning.glowRadius = 18;
        lightning.segments = 22;
        lightning.lineColor = 0x66CCFF;
        lightning.thickness = 2;
        lightning.glow();

                playerNameText = new h2d.Text(DefaultFont.get(), root);
        playerNameText.textColor = 0xE8F0FF;
        playerNameText.text = playerName;
        playerNameText.x = 24;
        playerNameText.y = 8;

        enemyNameText = new h2d.Text(DefaultFont.get(), root);
        enemyNameText.textColor = 0xE8F0FF;
        enemyNameText.text = enemyName;
        enemyNameText.y = 8;
        enemyNameText.x = this.app.s2d.width - enemyNameText.textWidth - 24;

                playerGroup = new h2d.Object(root);
        enemyGroup = new h2d.Object(root);

                playerBmp = new h2d.Bitmap(hxd.Res.guy1.toTile(), playerGroup);
        enemyBmp = new h2d.Bitmap(hxd.Res.enemies.wdebp.toTile(), enemyGroup);

                playerMaskG = new h2d.Graphics(root);
        enemyMaskG = new h2d.Graphics(root);
        playerGroup.filter = new h2d.filter.Mask(playerMaskG, false, true);
        enemyGroup.filter = new h2d.filter.Mask(enemyMaskG, false, true);
        redrawMasks();

                var barW = Std.int(Math.min(300, Math.max(180, this.app.s2d.width * 0.28)));
        playerHpBar = new HpBar(root, barW, 10, 0x1C1C1C, 0x00FF66, 0x000000);
        enemyHpBar = new HpBar(root, barW, 10, 0x1C1C1C, 0xFF6666, 0x000000);
        playerHpBar.setMax(100);
        playerHpBar.setValue(playerHp);
        enemyHpBar.setMax(100);
        enemyHpBar.setValue(enemyHp);

                playerHpLabel = new h2d.Text(DefaultFont.get(), root);
        playerHpLabel.textColor = 0xE8F0FF;
        enemyHpLabel = new h2d.Text(DefaultFont.get(), root);
        enemyHpLabel.textColor = 0xE8F0FF;
        refreshHpBars();

                layoutPortraits();
        positionBarsAndLabels();

                nav = new ArrowNav();
        var bx = 24;
        var by = playerHpBar.y + playerHpBar.height() + 16;
        var spacing = 8;
        for (i in 0...playerWeapons.length) {
            var label = playerWeapons[i];
            var btn: Box = (new FormButton(label) : Box);
            root.addChild(btn);
            btn.x = bx;
            btn.y = by + i * (btn.height + spacing);

                        btn.onClick(_ -> {
                if (turn == Player) playerAttack(label);
            });

                        nav.bind(btn, (e:ArrowNavEvent) -> {
                switch e {
                    case Selected:
                        if (turn == Player) playerAttack(label);
                    default:
                }
            });
        }
    }

    inline function refreshHpBars(): Void {
        playerHpBar.setValue(playerHp);
        enemyHpBar.setValue(enemyHp);
        if (playerHpLabel != null) playerHpLabel.text = playerHp + "/" + playerHpBar.maxValue;
        if (enemyHpLabel != null) enemyHpLabel.text = enemyHp + "/" + enemyHpBar.maxValue;
        updateHpLabelPositions();
    }

    inline function portraitCenterBmp(bmp:h2d.Bitmap): { x: Float, y: Float } {
        return { x: bmp.x + bmp.width / 2, y: bmp.y + bmp.height / 2 };
    }

    function playerAttack(weapon:String): Void {
        if (turn != Player) return;
        turn = Enemy; 
        var p = portraitCenterBmp(playerBmp);
        var e = portraitCenterBmp(enemyBmp);

        Coro.start((ctx: CoroutineContext) -> {
                        AttackFx.lightning(root, p.x, p.y, e.x, e.y, 0.45).await();
            var dmg = 8 + Std.random(9);             var newEnemyHp = enemyHp - dmg;
            enemyHp = (newEnemyHp < 0) ? 0 : newEnemyHp;
            refreshHpBars();
            DamagePopup.show(root, '-' + dmg, e.x, enemyBmp.y - 8).await();

            if (enemyHp <= 0) {
                onEnemyDefeated();
                                exitState();
                return Stop;
            }

                        enemyTurn().await();
            turn = Player;
            return Stop;
        });
    }

    function onEnemyDefeated():Void {
        var w = Game.world;
        var z = w != null ? w.zones[zoneId] : null;
        if (z == null) return;
        var removed = false;
                for (m in z.monsters) {
            if (Reflect.hasField(m, "_inCombat")) {
                z.monsters.remove(m);
                removed = true;
                break;
            }
        }
        if (!removed && z.monsters.length > 0) {
            z.monsters.shift();
        }
    }

    function enemyTurn(): Future {
        return Coro.start((ctx: CoroutineContext) -> {
            var idx = Std.random(enemyWeapons.length);
            var weapon = enemyWeapons[idx];
            var p = portraitCenterBmp(playerBmp);
            var e = portraitCenterBmp(enemyBmp);
            AttackFx.lightning(root, e.x, e.y, p.x, p.y, 0.45).await();
            var dmg = 6 + Std.random(7);             var newPlayerHp = playerHp - dmg;
            playerHp = (newPlayerHp < 0) ? 0 : newPlayerHp;
            refreshHpBars();
            DamagePopup.show(root, '-' + dmg, p.x, playerBmp.y - 8).await();
            if (playerHp <= 0) {
                exitState();
                return Stop;
            }
            return Stop;
        }).future();
    }

    public function lifecycle(e: HStateLifeCycle) : Future {
        switch e {
            case Create: {
                setup();
                return Future.immediate();
            }
            case Activate: {
                turn = Player;
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

    public function onUpdate(dt:Float): Void {
        if (turn == Player && nav != null) nav.update();
                if (lightning != null) {
            lightning.startX = 24;
            lightning.startY = this.app.s2d.height - 24;
            lightning.endX = this.app.s2d.width - 24;
            lightning.endY = 24;
        }
                var w = Std.int(this.app.s2d.width);
        var h = Std.int(this.app.s2d.height);
        if (w != bgW || h != bgH) {
            redrawBackgrounds();
            redrawMasks();
            layoutPortraits();
            positionBarsAndLabels();
        }
        if (enemyNameText != null) {
            enemyNameText.x = this.app.s2d.width - enemyNameText.textWidth - 24;
        }
    }

    inline function redrawBackgroundsIfNeeded():Void {
        var w = Std.int(this.app.s2d.width);
        var h = Std.int(this.app.s2d.height);
        if (w != bgW || h != bgH) {
            redrawBackgrounds();
        }
    }

    function redrawBackgrounds():Void {
        var w = Std.int(this.app.s2d.width);
        var h = Std.int(this.app.s2d.height);
        bgW = w; bgH = h;

        bgBase.clear();
        bgBase.beginFill(0x0E0E12, 1);
        bgBase.drawRect(0, 0, w, h);
        bgBase.endFill();

        bgOverlay.clear();
        bgOverlay.beginFill(0x15202B, 1);
                bgOverlay.moveTo(0, 0);
        bgOverlay.lineTo(w - 24, 24);
        bgOverlay.lineTo(24, h - 24);
        bgOverlay.lineTo(0, h);
        bgOverlay.lineTo(0, 0);
        bgOverlay.endFill();
    }

    function redrawMasks():Void {
        var w = this.app.s2d.width;
        var h = this.app.s2d.height;
        playerMaskG.clear();
        playerMaskG.beginFill(0xFFFFFF, 1);
        playerMaskG.moveTo(0, 0);
        playerMaskG.lineTo(w - 24, 24);
        playerMaskG.lineTo(24, h - 24);
        playerMaskG.lineTo(0, h);
        playerMaskG.lineTo(0, 0);
        playerMaskG.endFill();

        enemyMaskG.clear();
        enemyMaskG.beginFill(0xFFFFFF, 1);
        enemyMaskG.moveTo(w, 0);
        enemyMaskG.lineTo(w, h);
        enemyMaskG.lineTo(24, h - 24);
        enemyMaskG.lineTo(w - 24, 24);
        enemyMaskG.lineTo(w, 0);
        enemyMaskG.endFill();

        playerMaskG.smooth = true;
        enemyMaskG.smooth = true;
    }

    function layoutPortraits():Void {
        var w = this.app.s2d.width;
        var h = this.app.s2d.height;
        var margin = 24.0;
                var targetH = h - margin * 2 - 48;         var scaleP = targetH / playerBmp.tile.height;
        var scaleE = targetH / enemyBmp.tile.height;
        playerBmp.scaleX = playerBmp.scaleY = scaleP;
        enemyBmp.scaleX = enemyBmp.scaleY = scaleE;
                playerBmp.x = margin;
        playerBmp.y = h - margin - playerBmp.height;
        enemyBmp.x = w - margin - enemyBmp.width;
        enemyBmp.y = h - margin - enemyBmp.height;
    }

    inline function positionBarsAndLabels():Void {
        var topY = 8 + playerNameText.textHeight + 8;
        playerHpBar.x = 24;
        playerHpBar.y = topY;
        enemyHpBar.x = this.app.s2d.width - enemyHpBar.width() - 24;
        enemyHpBar.y = 8 + enemyNameText.textHeight + 8;
        updateHpLabelPositions();
    }

    inline function updateHpLabelPositions():Void {
                if (playerHpLabel != null) {
            playerHpLabel.y = playerHpBar.y - 14;
            playerHpLabel.x = playerHpBar.x + (playerHpBar.width() - playerHpLabel.textWidth) / 2;
        }
        if (enemyHpLabel != null) {
            enemyHpLabel.y = enemyHpBar.y - 14;
            enemyHpLabel.x = enemyHpBar.x + (enemyHpBar.width() - enemyHpLabel.textWidth) / 2;
        }
    }
}


class CombatView extends h2d.Object {
                        
}

class AttackFx {
    public static function lightning(parent:h2d.Object, x1:Float, y1:Float, x2:Float, y2:Float, duration:Float): Future {
        return Coro.start((ctx: CoroutineContext) -> {
            var lt = new Lightning(parent, x1, y1, x2, y2);
            lt.glowRadius = 14;
            lt.segments = 18;
            lt.thickness = 2;
            if (ctx.elapsed >= duration) {
                lt.remove();
                return Stop;
            }
            return WaitNextFrame;
        }).future();
    }
}

class DamagePopup {
    public static function show(parent:h2d.Object, text:String, x:Float, y:Float, duration:Float = 0.7): Future {
        return Coro.start((ctx: CoroutineContext) -> {
            var t = new h2d.Text(DefaultFont.get(), parent);
            t.textColor = 0xFF4444;
            t.text = text;
            t.x = x - t.calcTextWidth(text) / 2;
            t.y = y;
                        var p = ctx.elapsed / duration;
            t.y = y - 20 * p;
            t.alpha = 1 - p;
            if (p >= 1) {
                t.remove();
                return Stop;
            }
            return WaitNextFrame;
        }).future();
    }
}

class HpBar extends h2d.Object {
    public var maxValue(default, null):Int;
    public var currentValue(default, null):Int;

    final widthPx:Float;
    final heightPx:Float;

    final backColor:Int;
    final fillColor:Int;
    final borderColor:Int;

    var back:h2d.Graphics;
    var fill:h2d.Graphics;
    var border:h2d.Graphics;

    public function new(parent:h2d.Object, widthPx:Float, heightPx:Float, backColor:Int, fillColor:Int, borderColor:Int) {
        super(parent);
        this.widthPx = widthPx;
        this.heightPx = heightPx;
        this.backColor = backColor;
        this.fillColor = fillColor;
        this.borderColor = borderColor;
        this.maxValue = 100;
        this.currentValue = 100;

        back = new h2d.Graphics(this);
        fill = new h2d.Graphics(this);
        border = new h2d.Graphics(this);

        redraw();
    }

    public function setMax(max:Int):Void {
        maxValue = max;
        if (currentValue > maxValue) currentValue = maxValue;
        redraw();
    }

    public function setValue(v:Int):Void {
        currentValue = (v < 0) ? 0 : (v > maxValue ? maxValue : v);
        redraw();
    }

    public inline function width():Float return widthPx;
    public inline function height():Float return heightPx;

    inline function redraw():Void {
                back.clear();
        back.beginFill(backColor, 1);
        back.drawRoundedRect(0, 0, widthPx, heightPx, Std.int(heightPx / 2));
        back.endFill();

                var pct = (maxValue == 0) ? 0.0 : (currentValue / maxValue);
        var fillW = widthPx * pct;
        fill.clear();
        fill.beginFill(fillColor, 1);
        fill.drawRoundedRect(0, 0, fillW, heightPx, Std.int(heightPx / 2));
        fill.endFill();

                border.clear();
        border.lineStyle(1, borderColor, 1);
        border.drawRoundedRect(0, 0, widthPx, heightPx, Std.int(heightPx / 2));
    }
}