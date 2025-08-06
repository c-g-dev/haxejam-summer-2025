package ludi.heaps.input;


//var i = Input.scope("Controls");
    //i.isKeyPressed (this.enabled && window.isKeyPressed)
    //i.of(ControlType).
    //i.get("tag") //direct access
    //i.createBehavior(); //behavior to allow for listener reactions

//Input.stashPush();
//Input.scope("GUI").only();
//...
//Input.stashPop();

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
        // Get the current state of all nodes
        var state = getState();
        // Push the state onto the stash
        stash.push(state);
    }

    public static function stashPop(): Void {
        init();
        if (stash.length == 0) return; // No state to pop
        
        // Turn off all nodes
        root.off();
        
        // Pop the last state from the stash
        var state = stash.pop();
        
        // Apply the enablements by name
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
        // Find node by name, starting from root
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
        // Add current node's state
        state.push({ name: node.name, enabled: node.enabled });
        // Recursively collect state for all children
        for (child in node.children) {
            collectState(child, state);
        }
    }

    private static function findNodeByName(node: InputNode, name: String): InputNode {
        // Check if current node matches the name
        if (node.name == name) return node;
        
        // Recursively search children
        for (child in node.children) {
            var found = findNodeByName(child, name);
            if (found != null) return found;
        }
        
        return null;
    }
}

#if !macro
//@:using(ludi.heaps.input.InputMacros)
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
        // Find root
        var root = this;
        while (root.parent != null) {
            root = root.parent;
        }
        
        // Disable everything from root
        root.off();
        
        // Enable this node and its parents
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