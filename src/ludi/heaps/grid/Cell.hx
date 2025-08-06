package ludi.heaps.grid;

abstract Cell(Array<Int>) {
    public function new(x: Int, y: Int) {
        this = [x, y];
    }
    public var x(get, never): Int;
    public var y(get, never): Int;
    function get_x(): Int {
        return this[0];
    }
    function get_y(): Int {
        return this[1];
    }

    public function translate(x: Int, y: Int): Cell {
        return new Cell(this[0] + x, this[1] + y);
    }
}

