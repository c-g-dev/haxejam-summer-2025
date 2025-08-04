import h3d.scene.fwd.DirLight;
import hxd.BufferFormat;
import h3d.col.Point;
import hxd.FloatBuffer;
import hxd.IndexBuffer;
import h3d.scene.*;
import h3d.mat.*;
import h3d.prim.*;
import hxd.App;
import hxd.Key;

typedef Tri = { v1: Int, v2: Int, v3: Int };

class Main extends App {
    var mesh: Mesh;

    override function init() {
        hxd.Res.initEmbed();
        // Generate icosphere mesh data
        var positions: Array<Point> = [];
        var index: Int = 0;
        var middlePointIndexCache: Map<String, Int> = new Map();

        function addVertex(p: Point): Int {
            var length = Math.sqrt(p.x * p.x + p.y * p.y + p.z * p.z);
            positions.push(new Point(p.x / length, p.y / length, p.z / length));
            return index++;
        }

        function getMiddlePoint(p1: Int, p2: Int): Int {
            var firstIsSmaller = p1 < p2;
            var smaller = firstIsSmaller ? p1 : p2;
            var greater = firstIsSmaller ? p2 : p1;
            var key = '$smaller-$greater';
            if (middlePointIndexCache.exists(key)) {
                return middlePointIndexCache.get(key);
            }
            var point1 = positions[p1];
            var point2 = positions[p2];
            var middle = new Point(
                (point1.x + point2.x) / 2,
                (point1.y + point2.y) / 2,
                (point1.z + point2.z) / 2
            );
            var ret = addVertex(middle);
            middlePointIndexCache.set(key, ret);
            return ret;
        }

        // Initial icosahedron vertices
        var t = (1.0 + Math.sqrt(5.0)) / 2.0;
        addVertex(new Point(-1, t, 0));
        addVertex(new Point(1, t, 0));
        addVertex(new Point(-1, -t, 0));
        addVertex(new Point(1, -t, 0));
        addVertex(new Point(0, -1, t));
        addVertex(new Point(0, 1, t));
        addVertex(new Point(0, -1, -t));
        addVertex(new Point(0, 1, -t));
        addVertex(new Point(t, 0, -1));
        addVertex(new Point(t, 0, 1));
        addVertex(new Point(-t, 0, -1));
        addVertex(new Point(-t, 0, 1));

        // Initial 20 faces
        var faces: Array<Tri> = [
            { v1: 0, v2: 11, v3: 5 }, { v1: 0, v2: 5, v3: 1 }, { v1: 0, v2: 1, v3: 7 },
            { v1: 0, v2: 7, v3: 10 }, { v1: 0, v2: 10, v3: 11 }, { v1: 1, v2: 5, v3: 9 },
            { v1: 5, v2: 11, v3: 4 }, { v1: 11, v2: 10, v3: 2 }, { v1: 10, v2: 7, v3: 6 },
            { v1: 7, v2: 1, v3: 8 }, { v1: 3, v2: 9, v3: 4 }, { v1: 3, v2: 4, v3: 2 },
            { v1: 3, v2: 2, v3: 6 }, { v1: 3, v2: 6, v3: 8 }, { v1: 3, v2: 8, v3: 9 },
            { v1: 4, v2: 9, v3: 5 }, { v1: 2, v2: 4, v3: 11 }, { v1: 6, v2: 2, v3: 10 },
            { v1: 8, v2: 6, v3: 7 }, { v1: 9, v2: 8, v3: 1 }
        ];

        // Subdivide faces
        var recursionLevel: Int = 2; // Adjust for detail (each level multiplies faces by 4)
        for (i in 0...recursionLevel) {
            var faces2: Array<Tri> = [];
            for (tri in faces) {
                var a = getMiddlePoint(tri.v1, tri.v2);
                var b = getMiddlePoint(tri.v2, tri.v3);
                var c = getMiddlePoint(tri.v3, tri.v1);
                faces2.push({ v1: tri.v1, v2: a, v3: c });
                faces2.push({ v1: tri.v2, v2: b, v3: a });
                faces2.push({ v1: tri.v3, v2: c, v3: b });
                faces2.push({ v1: a, v2: b, v3: c });
            }
            faces = faces2;
        }

        // Define the vertex format: position (vec3), normal (vec3)
        @:privateAccess var format = new hxd.BufferFormat([
            { name: "position", type: DVec3 },
            { name: "normal", type: DVec3 },
            { name: "uv", type: DVec2 }
        ]);

        // Build vertex buffer data
        var numVerts = positions.length;
        var floats = new FloatBuffer(numVerts * 6);
        for (p in positions) {
            floats.push(p.x);
            floats.push(p.y);
            floats.push(p.z);
            floats.push(p.x); // Normal = position (unit sphere)
            floats.push(p.y);
            floats.push(p.z);
        }

        // Build index buffer data
        var numIndices = faces.length * 3;
        var idx = new IndexBuffer(numIndices);
        for (tri in faces) {
            idx.push(tri.v1);
            idx.push(tri.v2);
            idx.push(tri.v3);
        }

        // Compute bounds
        var bounds = new h3d.col.Bounds();
        for (p in positions) {
            bounds.addPos(p.x, p.y, p.z);
        }

        // Create RawPrimitive with raw data
        var prim = new RawPrimitive({ format: format, vbuf: floats, ibuf: idx, bounds: bounds });

        mesh = new Mesh(prim, s3d);
        mesh.material.mainPass.wireframe = true;

        var tex = hxd.Res.palettetown.toTexture(); // Assumes the resource is embedded as 'earth_jpg'
             tex.wrap = Clamp; // Clamp wrapping to avoid seams on the sphere
             tex.filter = Linear; // Smooth filtering for better appearance
             mesh.material.texture = tex;

        // Optional: Scale to desired radius (default is unit sphere)
        // mesh.scale(5.0); // Example radius of 5

        // Add a directional light (optional, but helps if you disable wireframe later)
        var light = new DirLight(new h3d.Vector(-1, -3, -5), s3d);
        light.enableSpecular = true;

        // Position the camera
        s3d.camera.pos.set(0, 0, 3);
        s3d.camera.target.set(0, 0, 0);
    }

    override function update(dt: Float) {
        var rotationSpeed = 2.0; // Radians per second; adjust as needed for sensitivity

        // Rotate around Y-axis (left-right) with left and right arrow keys
        if (Key.isDown(Key.LEFT)) {
            mesh.rotate(0, rotationSpeed * dt, 0);
        }
        if (Key.isDown(Key.RIGHT)) {
            mesh.rotate(0, -rotationSpeed * dt, 0);
        }

        // Rotate around X-axis (up-down) with up and down arrow keys
        if (Key.isDown(Key.UP)) {
            mesh.rotate(-rotationSpeed * dt, 0, 0); // Negative to tilt top towards camera
        }
        if (Key.isDown(Key.DOWN)) {
            mesh.rotate(rotationSpeed * dt, 0, 0);
        }
    }

    static function main() {
        new Main();
    }
}