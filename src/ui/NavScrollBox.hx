package ui;

import h2d.Object;
import ludi.heaps.box.Containers.Viewport;
import ludi.heaps.box.Box;
import ludi.heaps.box.Containers.VBox;

class NavScrollBox extends Box {
    private var viewport: Viewport;
    private var content: VBox;
    private var scrollSpeed: Float = 20;
    private var isDragging: Bool = false;
    private var lastX: Float;
    private var lastY: Float;
    private var rerouteChildren: Bool = false;
    
    public function new(width: Float, height: Float) {
        super(width, height);
        viewport = new Viewport(Std.int(width), Std.int(height));
        addToBackground(viewport);
        content = new VBox(width, height);
        this.viewport.addChild(content);
        rerouteChildren = true;
    }

    override public function addChild(child: Object) {
        if(rerouteChildren) {
            content.addChild(child);
        }
        else{
            super.addChild(child);
        }
    }


    public override function clear() {
        this.content.clear();    
    }

    private function onRelease(event: hxd.Event) {
        isDragging = false;
    }

    public function scrollBy(deltaX: Float, deltaY: Float) {
        var bounds = viewport.getChildrenBounds();
        var maxX = Math.max(0, bounds.width - viewport.width);
        var maxY = Math.max(0, bounds.height - viewport.height);
        var newX = content.x + deltaX;
        var newY = content.y + deltaY;
        newX = hxd.Math.clamp(newX, -maxX, 0);
        newY = hxd.Math.clamp(newY, -maxY, 0);
        content.x = newX;
        content.y = newY;
    }

    public function scrollTo(x: Float, y: Float) {
        var bounds = viewport.getChildrenBounds();
        var maxX = Math.max(0, bounds.width - viewport.width);
        var maxY = Math.max(0, bounds.height - viewport.height);
        content.x = hxd.Math.clamp(-x, -maxX, 0);
        content.y = hxd.Math.clamp(-y, -maxY, 0);
    }
}