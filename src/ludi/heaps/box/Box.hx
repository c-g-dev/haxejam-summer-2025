package ludi.heaps.box;

import hxd.Res;
import ludi.heaps.box.Plugins.PopupPlugin;
import h2d.Video;
import ludi.heaps.box.Plugins.BackgroundColorPlugin;
import ludi.heaps.box.Plugins.VerticalGradientPlugin;
import ludi.heaps.box.Plugins.RoundedCornersPlugin;
import ludi.heaps.box.Plugins.DrawRoundedBorderPlugin;
import ludi.heaps.box.Plugins.DrawBorderPlugin;
import ludi.heaps.box.Plugins.BackgroundPlugin;
import ludi.heaps.box.Plugins.TextPlugin;
import format.abc.Data.ABCData;
import h2d.Interactive;
import h2d.Object;
import h2d.Drawable;

abstract CallbackCollection<T>(Array<T-> Void>) {
    public function new() {
        this = [];
    }

    public function add(cb:T -> Void): Void {
        this.push(cb);
    }

    public function fire(?value:T): Void {
        for (callback in this) {
            callback(value);
        }
    }
}

@:allow(Box)
class BoxEvents {
    private var clickEvents: CallbackCollection<hxd.Event> = new CallbackCollection<hxd.Event>();
    var mouseDownEvents: CallbackCollection<hxd.Event> = new CallbackCollection<hxd.Event>();
    var mouseUpEvents: CallbackCollection<hxd.Event> = new CallbackCollection<hxd.Event>();
    var mouseOverEvents: CallbackCollection<hxd.Event> = new CallbackCollection<hxd.Event>();
    var mouseOutEvents: CallbackCollection<hxd.Event> = new CallbackCollection<hxd.Event>();
    var childAddedEvents: CallbackCollection<h2d.Object> = new CallbackCollection<h2d.Object>();
    var childRemovedEvents: CallbackCollection<h2d.Object> = new CallbackCollection<h2d.Object>();
    var showEvents: CallbackCollection<hxd.Event> = new CallbackCollection<hxd.Event>();
    var hideEvents: CallbackCollection<hxd.Event> = new CallbackCollection<hxd.Event>();
    var resizeEvents: CallbackCollection<{width:Float, height:Float}> = new CallbackCollection<{width:Float, height:Float}>();
        
    public function new() {}

    public function onClick(cb: hxd.Event -> Void) {
        clickEvents.add(cb);
    }

    public function onMouseDown(cb: hxd.Event -> Void) {
        mouseDownEvents.add(cb);
    }

    public function onMouseUp(cb: hxd.Event -> Void) {
        mouseUpEvents.add(cb);
    }

    public function onMouseOver(cb: hxd.Event -> Void) {
        mouseOverEvents.add(cb);
    }

    public function onMouseOut(cb: hxd.Event -> Void) {
        mouseOutEvents.add(cb);
    }

    public function onChildAdded(cb: h2d.Object -> Void) {
        childAddedEvents.add(cb);
    }

    public function onChildRemoved(cb: h2d.Object -> Void) {
        childRemovedEvents.add(cb);
    }

    public function onShow(cb: hxd.Event -> Void) {
        showEvents.add(cb);
    }

    public function onHide(cb: hxd.Event -> Void) {
        hideEvents.add(cb);
    }

    public function onResize(cb: {width:Float, height:Float} -> Void) {
        resizeEvents.add(cb);
    }
}


abstract class BoxPlugin {
    public var box: Box;
    public var events: BoxEvents;
    public function setBox(box:Box) {
        this.box = box;
        @:privateAccess this.events = box.events;
    }
    public abstract function apply(box:Box, events:BoxEvents): Void;
}

@:access(ludi.heaps.box.BoxEvents)
class Box extends h2d.Object {
    public var width:Float;
    public var height:Float;
    private var background: Drawable;
    private var interactive:Interactive;
    private var untrackedChildren:Array<Object> = [];
    private var events: BoxEvents;
    private var plugins: Array<BoxPlugin> = [];
    public var data: Map<String, Dynamic> = [];

    public static function build(width:Float, height:Float): BoxBuilder {
        return new BoxBuilder(new Box(width, height));
    }

    public function new(width:Float, height:Float) {
        super();
        this.width = width;
        this.height = height;
        this.events = new BoxEvents();

        interactive = new h2d.Interactive(width, height);
        interactive.onClick = function(e:hxd.Event) { 
            events.clickEvents.fire(e);
        }
        interactive.onPush =  function(e:hxd.Event) { 
            events.mouseDownEvents.fire(e);
            e.propagate = true;
        }
        interactive.onRelease =  function(e:hxd.Event) { 
            events.mouseUpEvents.fire(e);
            e.propagate = true;
        }
        interactive.onOver = function(e:hxd.Event) { 
            events.mouseOverEvents.fire(e);
            e.propagate = true;
        }
        interactive.onOut = function(e:hxd.Event) {  
            events.mouseOutEvents.fire(e);
            e.propagate = true;
        }
        this.addToBackground(interactive);
    }

    public function onClick(cb: hxd.Event -> Void) {
        events.onClick(cb);
    }

    public function setBackground(drawable:Drawable) {
        if(background != null) {
            removeChild(background);
        }

        background = drawable;
        addToBackground(drawable);
    }

    public function addPlugin(plugin:BoxPlugin) {
        plugins.push(plugin);
        plugin.setBox(this);
        plugin.apply(this, events);
    }

    public function addToBackground(child:Object) {
        if(child == null) return;
        untrackedChildren.push(child);
        super.addChildAt(child, 0);
    }

    public override function addChild(child:Object) {
        super.addChild(child);
        events.childAddedEvents.fire(child);
    }

    public override function removeChild(child:Object) {
        trace("box remove child called: " + this.children.length + " " + untrackedChildren.length);
        if(untrackedChildren != null && untrackedChildren.indexOf(child) != -1) {
            untrackedChildren.remove(child);
        }
        super.removeChild(child);
        events.childRemovedEvents.fire(child);
    }

    public function clear() {
        var childrenToRemove = [];
        for (child in this.children) {
            if(untrackedChildren != null && untrackedChildren.indexOf(child) != -1) {
            }
            else{
                childrenToRemove.push(child);
            }
        }
        for (child in childrenToRemove) {
            removeChild(child);
        }
    }
    

    public function show() {
        this.visible = true;
        events.showEvents.fire(null);
    }

    public function hide() {
        this.visible = false;
        events.hideEvents.fire(null);
    }

    public function resize(newWidth:Float, newHeight:Float) {
        this.width = newWidth;
        this.height = newHeight;
    
        if (interactive != null) {
            interactive.width = newWidth;
            interactive.height = newHeight;
        }
        
        events.resizeEvents.fire({width: newWidth, height: newHeight});
    }

    public static function enhance(box:Box): BoxBuilder {
        return new BoxBuilder(box);        
    }
}



abstract BoxPluginAppender<T: BoxPlugin>(T) {
    public function new(plugin:T) {
        this = plugin;
    }

    public function and(cb: T -> Void) {
        cb(this);
    }

}

abstract BoxBuilder(Box) {
    public function new(box:Box) {
        this = box;
    }

    public function withPlugins(cb: BoxBuilder -> Void): BoxBuilder {
        cb(abstract);
        return abstract;
    }

    /** Adds a TextPlugin to the box with optional color and font parameters. */
    public function text(text:String, ?color:Int = 0xFFFFFF, ?font:h2d.Font): BoxPluginAppender<TextPlugin> {
        var plugin = new TextPlugin(text, color, font);
        this.addPlugin(plugin);
        return new BoxPluginAppender<TextPlugin>(plugin);
    }

    /** Adds a BackgroundPlugin to the box with a specified tile. */
    public function background(tile:h2d.Tile): BoxPluginAppender<BackgroundPlugin> {
        var plugin = new BackgroundPlugin(tile);
        this.addPlugin(plugin);
        return new BoxPluginAppender<BackgroundPlugin>(plugin);
    }

    /** Adds a DrawBorderPlugin to the box with specified thickness and color. */
    public function border(thickness:Float, color:Int): BoxPluginAppender<DrawBorderPlugin> {
        var plugin = new DrawBorderPlugin(thickness, color);
        this.addPlugin(plugin);
        return new BoxPluginAppender<DrawBorderPlugin>(plugin);
    }

    /** Adds a DrawRoundedBorderPlugin to the box with specified thickness, color, and corner radius. */
    public function roundedBorder(thickness:Float, color:Int, cornerRadius:Float): BoxPluginAppender<DrawRoundedBorderPlugin> {
        var plugin = new DrawRoundedBorderPlugin(thickness, color, cornerRadius);
        this.addPlugin(plugin);
        return new BoxPluginAppender<DrawRoundedBorderPlugin>(plugin);
    }

    /** Adds a RoundedCornersPlugin to the box with a specified corner radius. */
    public function roundedCorners(cornerRadius:Float): BoxPluginAppender<RoundedCornersPlugin> {
        var plugin = new RoundedCornersPlugin(cornerRadius);
        this.addPlugin(plugin);
        return new BoxPluginAppender<RoundedCornersPlugin>(plugin);
    }

    /** Adds a VerticalGradientPlugin to the box with specified top and bottom colors. */
    public function verticalGradient(topColor:Int, bottomColor:Int): BoxPluginAppender<VerticalGradientPlugin> {
        var plugin = new VerticalGradientPlugin(topColor, bottomColor);
        this.addPlugin(plugin);
        return new BoxPluginAppender<VerticalGradientPlugin>(plugin);
    }

    public function backgroundColor(color:Int): BoxPluginAppender<BackgroundColorPlugin> {
        var plugin = new BackgroundColorPlugin(color);
        this.addPlugin(plugin);
        return new BoxPluginAppender<BackgroundColorPlugin>(plugin);
    }

    public function asPopup(): BoxPluginAppender<PopupPlugin> {
        var plugin = new PopupPlugin();
        this.addPlugin(plugin);
        return new BoxPluginAppender<PopupPlugin>(plugin);
    }

    public function addEvents(cb: BoxEvents -> Void) {
        @:privateAccess cb(this.events);
    }

    public function get(): Box {
        return this;
    }
}