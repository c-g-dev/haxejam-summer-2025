package ludi.heaps;

class ObjectPluginNode extends Behavior {
    var plugins: Array<ObjectPlugin> = [];

    public function addPlugin(plugin:ObjectPlugin) {
        plugins.push(plugin);
    }

    public override function onFrame(dt:Float) {
        for(plugin in plugins) {
            plugin.onFrame(dt);
        }
    }
}


abstract class ObjectPlugin<T: h2d.Object = Dynamic> {
    var target: T;

    public function new(obj: T) {
        target = obj;
    }

    public function attach(obj: T) {
        var pluginNode: ObjectPluginNode = cast obj.find((o) -> {
            if(Std.isOfType(o, ObjectPluginNode)){
                return o;
            }
            return null;
        });
        
        if (pluginNode == null) {
            pluginNode = new ObjectPluginNode(obj);
        }

        pluginNode.addPlugin(this);
        onAttach();
    }

    public abstract function onAttach(): Void;
    public abstract function onFrame(dt: Float): Void;
    public abstract function onDetach(): Void;
}