package ludi.heaps;

class Node extends h2d.Object {
    
    public function new(?parent: h2d.Object) {
        super(parent);
        this.visible = false;
    }

    override function set_visible(b) {
        this.visible = false;
		return false;
	}
}