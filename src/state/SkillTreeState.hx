package state;

import state.HState;
import heaps.coroutine.Future;
import ui.Nav.ArrowNav;
import ui.Nav.ArrowNavEvent;
import ludi.heaps.box.Box;
import ludi.heaps.form.controls.FormButton;
import engine.Game;
import engine.WorldEngine;
import engine.EventImpl.ActivateSkillTreeNodeEvent;
import data.Data.SkillTree;
import data.Data.SkillNode;

class SkillTreeState extends HState {
    var root: h2d.Object;
    var graphLayer: h2d.Object;
    var lines: h2d.Graphics;
    var nav: ArrowNav;

        var panelRoot: h2d.Object;
    var titleText: h2d.Text;
    var descText: h2d.Text;
    var costText: h2d.Text;
    var pointsText: h2d.Text;

        var nodeViews: Map<String, Box> = new Map();
        var nodeCenters: Map<String, {x:Float, y:Float}> = new Map();
    var selectedNodeId: String = null;

    function setup(): Void {
        root = new h2d.Object();
        this.app.s2d.add(root);

        graphLayer = new h2d.Object();
        root.addChild(graphLayer);
        lines = new h2d.Graphics(graphLayer);

        panelRoot = new h2d.Object(root);

        nav = new ArrowNav();

        layoutAndBuild();
    }

    function layoutAndBuild(): Void {
                graphLayer.removeChildren();
        lines = new h2d.Graphics(graphLayer);
        nodeViews = new Map();
        nodeCenters = new Map();
        nav = new ArrowNav();

        var s2dW = this.app.s2d.width;
        var s2dH = this.app.s2d.height;
        var margin = 16.0;
        var panelW = Math.max(280.0, s2dW * 0.3);
        var graphW = s2dW - panelW - margin * 3;
        var graphH = s2dH - margin * 2;

        graphLayer.x = margin;
        graphLayer.y = margin;

        buildPanel(s2dW - panelW - margin, margin, panelW, graphH);
        buildGraph(graphW, graphH);
        redrawEdges();
    }

    inline function getTree(): SkillTree {
        return Game.world.player.skillTree;
    }

    function buildPanel(x:Float, y:Float, w:Float, h:Float): Void {
        panelRoot.removeChildren();
        panelRoot.x = x;
        panelRoot.y = y;
        var bg = new h2d.Bitmap(h2d.Tile.fromColor(0x2B2B2B, 1, 1), panelRoot);
        bg.scaleX = w;
        bg.scaleY = h;

        var font = hxd.Res.fonts.plex_mono_64.toFont();
        titleText = new h2d.Text(font, panelRoot);
        titleText.textColor = 0xFFFFFF;
        titleText.scale(0.5);
        titleText.x = 8;
        titleText.y = 8;

        descText = new h2d.Text(font, panelRoot);
        descText.textColor = 0xCCCCCC;
        descText.scale(0.4);
        descText.x = 8;
        descText.y = 48;

        costText = new h2d.Text(font, panelRoot);
        costText.textColor = 0xFFD166;
        costText.scale(0.5);
        costText.x = 8;
        costText.y = h - 80;

        pointsText = new h2d.Text(font, panelRoot);
        pointsText.textColor = 0xA0FFA0;
        pointsText.scale(0.5);
        pointsText.x = 8;
        pointsText.y = h - 40;

        updatePanel(null);
    }

    function buildGraph(w:Float, h:Float): Void {
        var tree = getTree();
        if (tree == null || tree.nodes == null) return;

                var cols = new Map<Int, Array<SkillNode>>();
        for (n in tree.nodes) {
            var lvl = (n.prerequisites == null) ? 0 : n.prerequisites.length;
            var arr = cols.get(lvl);
            if (arr == null) { arr = []; cols.set(lvl, arr); }
            arr.push(n);
        }

                var levels:Array<Int> = [];
        for (k in cols.keys()) levels.push(k);
        levels.sort((a,b) -> a - b);

        var colCount = Math.max(1, levels.length);
        var colGap = w / colCount;
        var nodeW = 180.0;
        var nodeH = 44.0;

                for (i in 0...levels.length) {
            var lvl = levels[i];
            var list = cols.get(lvl);
            if (list == null) continue;
                        var rowGap = (h - 32) / (list.length + 1);
            for (j in 0...list.length) {
                var node = list[j];
                var btn: Box = (new FormButton(node.name) : Box);
                graphLayer.addChild(btn);
                var cx = (i + 0.5) * colGap;
                var cy = (j + 1) * rowGap;
                btn.x = cx - nodeW / 2;
                btn.y = cy - nodeH / 2;
                nodeViews.set(node.id, btn);
                nodeCenters.set(node.id, { x: cx, y: cy });

                                var state = getNodeState(node);
                switch state {
                    case 0:                         btn.alpha = 1.0;
                    case 1:                         btn.alpha = 0.95;
                    case 2:                         btn.alpha = 0.5;
                }

                                if (state != 2) {
                    final nodeId = node.id;
                    btn.onClick(_ -> onSelectNode(nodeId));
                    nav.bind(btn, (e:ArrowNavEvent) -> {
                        switch e {
                            case Enter:
                                selectedNodeId = nodeId;
                                updatePanel(nodeId);
                            case Leave:
                            case Selected:
                                onSelectNode(nodeId);
                        }
                    });
                }
            }
        }
    }

        function getNodeState(n: SkillNode): Int {
        if (n.purchased) return 0;
        var tree = getTree();
        if (n.prerequisites == null || n.prerequisites.length == 0) return 1;
        for (pre in n.prerequisites) {
            var pn = tree.nodes.get(pre);
            if (pn == null || !pn.purchased) return 2;
        }
        return 1;
    }

    function redrawEdges(): Void {
        lines.clear();
        lines.lineStyle(2, 0x666666);
        var tree = getTree();
        if (tree == null) return;
        for (n in tree.nodes) {
            if (n.prerequisites == null) continue;
            var toC = nodeCenters.get(n.id);
            if (toC == null) continue;
            for (pre in n.prerequisites) {
                var fromC = nodeCenters.get(pre);
                if (fromC == null) continue;
                lines.moveTo(fromC.x, fromC.y);
                lines.lineTo(toC.x, toC.y);
            }
        }
    }

    function onSelectNode(nodeId:String): Void {
        var tree = getTree();
        var node = tree.nodes.get(nodeId);
        if (node == null) return;
        var state = getNodeState(node);
        if (state == 2) {
                        updatePanel(nodeId);
            return;
        }

                if (!node.purchased && state == 1) {
            WorldEngine.enqueue(new ActivateSkillTreeNodeEvent(nodeId));
                        layoutAndBuild();
        } else {
            updatePanel(nodeId);
        }
    }

    function updatePanel(nodeId:String): Void {
        var tree = getTree();
        pointsText.text = 'Skill Points: ' + tree.points;
        if (nodeId == null) {
            titleText.text = 'Skill Tree';
            descText.text = 'Select a node to view details.';
            costText.text = '';
            return;
        }
        var n = tree.nodes.get(nodeId);
        if (n == null) return;
        titleText.text = n.name;
        descText.text = n.description;
        var state = getNodeState(n);
        if (n.purchased) {
            costText.text = 'Purchased';
            costText.textColor = 0xA0FFA0;
        } else if (state == 1) {
            costText.text = 'Cost: ' + n.costPoints + ' point(s)';
            costText.textColor = 0xFFD166;
        } else {
                        costText.text = 'Locked. Requires: ' + (n.prerequisites == null ? '(none)' : n.prerequisites.join(', '));
            costText.textColor = 0xFF8C8C;
        }
    }

    public function lifecycle(e: HStateLifeCycle) : Future {
        switch e {
            case Create: {
                setup();
                return Future.immediate();
            }
            case Activate: {
                updatePanel(selectedNodeId);
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
        if (nav != null) nav.update();
    }
}