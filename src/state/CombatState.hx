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

//when it is the players turn, the weapon buttons are a nav that are choosable
//when it is the enemy turn, the enemy will attack the player with a random weapon
//there should be a weapon attack animation class that returns a future that resolves when the animation is done
//add a basic animation class for default
//when damage is done to a combatant, a little number should pop up on their portait and then fade out

enum CombatTurn { Player; Enemy; }

class CombatState extends HState {
    var root: h2d.Object;
    var nav: ArrowNav;

    var playerPortrait: Box;
    var enemyPortrait: Box;

    var playerHp:Int = 100;
    var enemyHp:Int = 100;
    var playerHpText: h2d.Text;
    var enemyHpText: h2d.Text;

    var lightning: Lightning;

    var playerWeapons:Array<String> = ["Slash", "Zap", "Blast"];
    var enemyWeapons:Array<String> = ["Claw", "Bite", "Roar"];

    var turn: CombatTurn = Player;

    function setup(): Void {
        root = new h2d.Object();
        this.app.s2d.add(root);

        // Diagonal lightning backdrop
        lightning = new Lightning(root, 24, this.app.s2d.height - 24, this.app.s2d.width - 24, 24);
        lightning.glowRadius = 18;
        lightning.segments = 22;
        lightning.lineColor = 0x66CCFF;
        lightning.thickness = 2;

        // Portraits
        var pb = Box.build(180, 180);
        pb.backgroundColor(0x2C2C2C);
        pb.roundedCorners(10);
        pb.roundedBorder(4, 0x000000, 10);
        playerPortrait = pb.get();

        var eb = Box.build(180, 180);
        eb.backgroundColor(0x2C2C2C);
        eb.roundedCorners(10);
        eb.roundedBorder(4, 0x000000, 10);
        enemyPortrait  = eb.get();
        root.addChild(playerPortrait);
        root.addChild(enemyPortrait);

        playerPortrait.x = 24;
        playerPortrait.y = (this.app.s2d.height - playerPortrait.height) / 2;
        enemyPortrait.x = this.app.s2d.width - enemyPortrait.width - 24;
        enemyPortrait.y = (this.app.s2d.height - enemyPortrait.height) / 2;

        // HP labels
        playerHpText = new h2d.Text(DefaultFont.get(), root);
        enemyHpText = new h2d.Text(DefaultFont.get(), root);
        playerHpText.textColor = 0x00FF66;
        enemyHpText.textColor = 0xFF6666;
        playerHpText.x = playerPortrait.x;
        playerHpText.y = playerPortrait.y - 28;
        enemyHpText.x = enemyPortrait.x + enemyPortrait.width - 96;
        enemyHpText.y = enemyPortrait.y - 28;
        refreshHpTexts();

        // Player weapon buttons (navigable)
        nav = new ArrowNav();
        var bx = playerPortrait.x;
        var by = playerPortrait.y + playerPortrait.height + 16;
        var spacing = 8;
        for (i in 0...playerWeapons.length) {
            var label = playerWeapons[i];
            var btn: Box = (new FormButton(label) : Box);
            root.addChild(btn);
            btn.x = bx;
            btn.y = by + i * (btn.height + spacing);

            // Mouse click still works
            btn.onClick(_ -> {
                if (turn == Player) playerAttack(label);
            });

            // ArrowNav select
            nav.bind(btn, (e:ArrowNavEvent) -> {
                switch e {
                    case Selected:
                        if (turn == Player) playerAttack(label);
                    default:
                }
            });
        }
    }

    function refreshHpTexts(): Void {
        playerHpText.text = 'HP: ' + playerHp;
        enemyHpText.text = 'HP: ' + enemyHp;
    }

    inline function portraitCenter(obj: Box): { x: Float, y: Float } {
        return { x: obj.x + obj.width / 2, y: obj.y + obj.height / 2 };
    }

    function playerAttack(weapon:String): Void {
        if (turn != Player) return;
        turn = Enemy; // lock input until sequence completes

        var p = portraitCenter(playerPortrait);
        var e = portraitCenter(enemyPortrait);

        Coro.start((ctx: CoroutineContext) -> {
            // Attack FX -> damage -> popup
            AttackFx.lightning(root, p.x, p.y, e.x, e.y, 0.45).await();
            var dmg = 8 + Std.random(9); // 8..16
            var newEnemyHp = enemyHp - dmg;
            enemyHp = (newEnemyHp < 0) ? 0 : newEnemyHp;
            refreshHpTexts();
            DamagePopup.show(root, '-' + dmg, e.x, enemyPortrait.y - 8).await();

            if (enemyHp <= 0) {
                // End combat (for now just exit the state if a parent exists)
                exitState();
                return Stop;
            }

            // Enemy turn
            enemyTurn().await();
            turn = Player;
            return Stop;
        });
    }

    function enemyTurn(): Future {
        return Coro.start((ctx: CoroutineContext) -> {
            var idx = Std.random(enemyWeapons.length);
            var weapon = enemyWeapons[idx];
            var p = portraitCenter(playerPortrait);
            var e = portraitCenter(enemyPortrait);
            AttackFx.lightning(root, e.x, e.y, p.x, p.y, 0.45).await();
            var dmg = 6 + Std.random(7); // 6..12
            var newPlayerHp = playerHp - dmg;
            playerHp = (newPlayerHp < 0) ? 0 : newPlayerHp;
            refreshHpTexts();
            DamagePopup.show(root, '-' + dmg, p.x, playerPortrait.y - 8).await();
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
        // keep backdrop lightning endpoints anchored to corners
        if (lightning != null) {
            lightning.startX = 24;
            lightning.startY = this.app.s2d.height - 24;
            lightning.endX = this.app.s2d.width - 24;
            lightning.endY = 24;
        }
    }
}


class CombatView extends h2d.Object {
    //effect.Lightning diagonally across the screen
    //left side and right side both have a settable character portrait
    //on each side, for each weapon/attack that combatant has, have a button
    //HP bars on each side
    //display player's resources
    
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
            // animate up and fade out over duration
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