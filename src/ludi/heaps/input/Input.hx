package ludi.heaps.input;


                

typedef InputState = Array<{
    name: String,
    enabled: Bool
}>;



class Input {
    static var root: InputNode = null;
    static var stash: Array<InputState> = [];

    private static function init(): Void {
        if (root == null) {
            root = new InputNode("root");
        }
    }

    public static function stashPush(): Void {
        init();
                var state = getState();
                stash.push(state);
    }

    public static function stashPop(): Void {
        init();
        if (stash.length == 0) return;         
                root.off();
        
                var state = stash.pop();
        
                for (nodeState in state) {
            var node = scope(nodeState.name);
            if (node != null) {
                node.enabled = nodeState.enabled;
            }
        }
    }
        public static function resolve(s:String): InputNode {
            init();
            var node = new InputNode(s);
            root.addChild(node);
            return node;
        }
    

    public static function scope(name: String): InputNode {
        init();
                if (root == null) return null;
        return findNodeByName(root, name);
    }

    private static function getState(): InputState {
        var state: InputState = [];
        if (root != null) {
            collectState(root, state);
        }
        return state;
    }

    private static function collectState(node: InputNode, state: InputState): Void {
                state.push({ name: node.name, enabled: node.enabled });
                for (child in node.children) {
            collectState(child, state);
        }
    }

    private static function findNodeByName(node: InputNode, name: String): InputNode {
                if (node.name == name) return node;
        
                for (child in node.children) {
            var found = findNodeByName(child, name);
            if (found != null) return found;
        }
        
        return null;
    }
}

#if !macro
#end
class InputNode {
    public var name: String;
    public var parent: InputNode;
    public var children: Array<InputNode> = [];
    public var enabled: Bool = true;

    public function new(name: String) {
        this.name = name;
    }

    public function createChild(name: String): InputNode {
        var child = new InputNode(name);
        child.name = name;
        child.parent = this;
        children.push(child);
        return child;
    }

    public function addChild(child: InputNode): Void {
        child.parent = this;
        children.push(child);
    }

    public function on(): Void {
        trace('InputNode on: ${this.name}');
        this.enabled = true;
        for (child in children) {
            child.on();
        }
    }

    public function off(): Void {
        trace('InputNode off: ${this.name}');
        this.enabled = false;
        for (child in children) {
            child.off();
        }
    }

    public function only(): Void {
                var root = this;
        while (root.parent != null) {
            root = root.parent;
        }
        
                root.off();
        
                this.on();
        var current = this;
        while (current.parent != null) {
            current.parent.enabled = true;
            current = current.parent;
        }
    }

    public inline function isKeyDown(code: Int): Bool { 
        return enabled && InputSystem.instance.isKeyDown(code);
    }

    public inline function isKeyPressed(code: Int): Bool { 
        return enabled && InputSystem.instance.isKeyPressed(code);
    }

    public inline function isKeyReleased(code: Int): Bool { 
        return enabled && InputSystem.instance.isKeyReleased(code);
    } 

    private inline function _get(tag: String): Dynamic  { 
        return InputSystem.instance.other(tag);
    }
}

class InputListenBehavior extends Behavior {

}