package ludi.heaps.box;

import h2d.Mask;
import ludi.commons.process.CallbackCollection;
import h2d.Drawable;
import h2d.Mask;
import h2d.Object;
import h2d.Interactive;
import h2d.Text;
import h2d.Graphics;
import hxd.App;

class HBox extends Box {
    private var padding:Float = 0;
    private var forcedWidths:Array<Float> = [];

    public function new(width:Float, height:Float) {
        super(width, height);
        forcedWidths = [];
    }

    override public function addChild(child:Object) {
        super.addChild(child);
        forcedWidths.push(-1);
        layoutChildren();
    }

    public function setPadding(pad:Float) {
        this.padding = pad;
        layoutChildren();
    }

    private function layoutChildren() {
        var currentX:Float = 0;
        var j = 0;
        for (i in 0...children.length) {
            var child = children[i];
            if(untrackedChildren.indexOf(child) != -1) {
                continue;
            }
            //trace("h child set at " + child.x);
            child.x = currentX;
            child.y = 0;
            var childWidth = (forcedWidths[j] >= 0) ? forcedWidths[j] : child.getBounds().width;
            currentX += childWidth + padding;
            j++;
        }
    }

    override public function removeChild(child:Object) {
        var index = children.indexOf(child);
        if (index != -1) {
            forcedWidths.splice(index, 1);
            super.removeChild(child);
            layoutChildren();
        }
    }

    public function setColumnWidth(idx:Int, width:Float) {
        if (idx >= 0 && idx < forcedWidths.length) {
            forcedWidths[idx] = width;
            layoutChildren();
        }
    }
}

class VBox extends Box {
    private var padding:Float = 0;
    private var rowHeight:Int = -1;
    
    public function new(width:Float, height:Float) {
        super(width, height);
        @:privateAccess this.events.onChildRemoved((child:Object) -> {
            layoutChildren();
        });
        @:privateAccess this.events.onChildAdded((child:Object) -> {
            layoutChildren();
        });
    }

    public function setPadding(pad:Float) {
        this.padding = pad;
        layoutChildren();
    }
    
    private function layoutChildren() {
        var currentY:Float = 0;
        var maxWidth: Float = 0;
        for (child in children) {
            child.x = padding;
            child.y = currentY;
            //trace("v child set at " + child.y);
            if(rowHeight >= 0) {
                currentY += rowHeight + padding;
            }
            else {
                currentY += child.getBounds().height + padding;
            }
            maxWidth = Math.max(maxWidth, child.getBounds().width + (padding * 2));
        }
        this.resize(Std.int(maxWidth), Std.int(currentY));
    }



    public function forceRowHeight(height: Int){
        this.rowHeight = height;
        layoutChildren();
    }
}


class Viewport extends h2d.Object {
    public var width: Int;
    public var height: Int;
    private var restrictBounds: Bool = true;

    public function new(width: Int, height: Int) {
        super();
        this.width = width;
        this.height = height;
    }

    override function drawRec(ctx:h2d.RenderContext) {
        Mask.maskWith(ctx, this, Math.ceil(width), Math.ceil(height), 0, 0);
        super.drawRec(ctx);
        Mask.unmask(ctx);
    }

    public function getChildrenBounds(): h2d.col.Bounds {
        restrictBounds = false;
        var out = new h2d.col.Bounds();
        if( posChanged ) {
            calcAbsPos();
            for( c in children )
                c.posChanged = true;
            posChanged = false;
        }
        var n = children.length;
        if( n == 0 ) {
            out.empty();
            return out;
        }
        if( n == 1 ) {
            var c = children[0];
            if( c.visible ) c.getBoundsRec(null, out, false) else out.empty();
            return out;
        }
        var xmin = hxd.Math.POSITIVE_INFINITY, ymin = hxd.Math.POSITIVE_INFINITY;
        var xmax = hxd.Math.NEGATIVE_INFINITY, ymax = hxd.Math.NEGATIVE_INFINITY;
        for( c in children ) {
            if( !c.visible ) continue;
            c.getBoundsRec(null, out, false);
            if( out.xMin < xmin ) xmin = out.xMin;
            if( out.yMin < ymin ) ymin = out.yMin;
            if( out.xMax > xmax ) xmax = out.xMax;
            if( out.yMax > ymax ) ymax = out.yMax;
        }
        out.xMin = xmin;
        out.yMin = ymin;
        out.xMax = xmax;
        out.yMax = ymax;
        restrictBounds = true;
        return out;
    }

    override function getBoundsRec(relativeTo:Object, out:h2d.col.Bounds, forSize:Bool) : Void {
        super.getBoundsRec(relativeTo, out, forSize);
        if(restrictBounds){
            restrictSize(out, this.width, this.height);
        }
    }

    public static function restrictSize(bounds: h2d.col.Bounds, width: Int, height: Int) {
        if (bounds.width > width) {
            bounds.xMax = bounds.xMin + width;
        }
        
        if (bounds.height > height) {
            bounds.yMax = bounds.yMin + height;
        }
    }
}

class ScrollBox extends Box {
    private var viewport: Viewport;
    private var content: VBox;
    private var scrollInteractive: Interactive;
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
        scrollInteractive = new Interactive(width, height);
        scrollInteractive.propagateEvents = true;
        scrollInteractive.onWheel = onWheelEvent;
        scrollInteractive.onPush = onPush;
        scrollInteractive.onMove = onMove;
        scrollInteractive.onRelease = onRelease;
        addToBackground(scrollInteractive);
        rerouteChildren = true;
    }

    override public function addChild(child: Object) {
        trace("Scrollbox adding child " + rerouteChildren );
        if(rerouteChildren) {
            content.addChild(child);
        }
        else{
            super.addChild(child);
        }
    }

    private function onWheelEvent(e: hxd.Event) {
        var delta = e.wheelDelta;
        scrollBy(0, -delta * scrollSpeed);
    }

    private function onPush(event: hxd.Event) {
        isDragging = true;
        lastX = event.relX;
        lastY = event.relY;
        event.propagate = true;
    }

    private function onMove(event: hxd.Event) {
        if (isDragging) {
            var deltaX = event.relX - lastX;
            var deltaY = event.relY - lastY;
            scrollBy(deltaX, deltaY);
            lastX = event.relX;
            lastY = event.relY;
        }
        event.propagate = true;
    }

    public override function clear() {
        trace("Clearing scrollbox");
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