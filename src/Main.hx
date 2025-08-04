import space.Sun;
import hxd.Key;
import heaps.coroutine.Coroutine.FrameYield;
import heaps.coroutine.Sequence;
import heaps.coroutine.Coro;
import h3d.scene.fwd.DirLight;
import h3d.scene.*;
import h3d.prim.*;
import hxd.Event;

class Main extends hxd.App {

    var sphere: Object;

    
    override function init() {
        hxd.Res.initEmbed();
        

        sphere = new Object(s3d);

        var dirLight = new DirLight(new h3d.Vector(0.5, 0.5, -0.5), s3d);
        dirLight.enableSpecular = true;

        // Create the sphere primitive (radius 1, with sufficient resolution for smoothness)
        var spherePrim = new Sphere(1, 32, 32);
        spherePrim.addNormals(); // Required for lighting
        spherePrim.addUVs(); // Optional, if using textures

        var sphereMesh = new Mesh(spherePrim);
        sphereMesh.material.mainPass.enableLights = true;
        sphereMesh.material.mainPass.culling = None;

        var tex = hxd.Res.topography.toTexture(); // Assumes the resource is embedded as 'earth_jpg'
        tex.wrap = Clamp; // Clamp wrapping to avoid seams on the sphere
        tex.filter = Linear; // Smooth filtering for better appearance
        sphereMesh.material.texture = tex;
        

        sphere.addChild(sphereMesh); // NEW: Add to scene for interaction to work
        sphereMesh.scale(.95);
        
        drawGrid();

        // Set up the camera (adjust as needed)
        s3d.camera.pos.set(0, 0, 5);
        s3d.camera.target.set(0, 0, 0);

        s3d.addChild(new Sun(s3d));

    }

    function drawGrid() {
                // Golden ratio and normalization (unchanged)
                var phi = (1 + Math.sqrt(5)) / 2;
                var norm = Math.sqrt(1 + phi * phi);
        
                // Original 12 vertices (unchanged)
                var verts = [
                    new h3d.Vector(phi / norm, 1 / norm, 0 / norm),
                    new h3d.Vector(-phi / norm, 1 / norm, 0 / norm),
                    new h3d.Vector(phi / norm, -1 / norm, 0 / norm),
                    new h3d.Vector(-phi / norm, -1 / norm, 0 / norm),
                    new h3d.Vector(1 / norm, 0 / norm, phi / norm),
                    new h3d.Vector(1 / norm, 0 / norm, -phi / norm),
                    new h3d.Vector(-1 / norm, 0 / norm, phi / norm),
                    new h3d.Vector(-1 / norm, 0 / norm, -phi / norm),
                    new h3d.Vector(0 / norm, phi / norm, 1 / norm),
                    new h3d.Vector(0 / norm, -phi / norm, 1 / norm),
                    new h3d.Vector(0 / norm, phi / norm, -1 / norm),
                    new h3d.Vector(0 / norm, -phi / norm, -1 / norm)
                ];
        
                // Original 20 faces (unchanged)
                var faces = [
                    [0, 8, 4],
                    [0, 5, 10],
                    [2, 4, 9],
                    [2, 11, 5],
                    [1, 6, 8],
                    [1, 10, 7],
                    [3, 9, 6],
                    [3, 7, 11],
                    [0, 10, 8],
                    [1, 8, 10],
                    [2, 9, 11],
                    [3, 9, 11],
                    [4, 2, 0],
                    [5, 0, 2],
                    [6, 1, 3],
                    [7, 3, 1],
                    [8, 6, 4],
                    [9, 4, 6],
                    [10, 5, 7],
                    [11, 7, 5]
                ];
        
                // Subdivide: create new vertices (midpoints) and subdivided faces
                var newVerts = verts.copy(); // Start with originals (indices 0-11)
                var midMap = new Map<String, Int>(); // Key: "min-max", Value: new vertex index
                var subFaces = []; // Array<Array<Int>> for 80 subdivided faces
        
                // Helper to get/create midpoint index
                function getMid(a: Int, b: Int): Int {
                    var min = a < b ? a : b;
                    var max = a > b ? a : b;
                    var key = '$min-$max';
                    if (midMap.exists(key)) return midMap.get(key);
                    var va = verts[a];
                    var vb = verts[b];
                    var mid = va.clone();
                    mid = mid.add(vb);
                    mid.normalize();
                    var idx = newVerts.length;
                    newVerts.push(mid);
                    midMap.set(key, idx);
                    return idx;
                }
        
                // Subdivide each face
                for (f in faces) {
                    var a = f[0];
                    var b = f[1];
                    var c = f[2];
                    var d = getMid(a, b); // Mid AB
                    var e = getMid(b, c); // Mid BC
                    var mf = getMid(c, a); // Mid CA (avoid 'f' name conflict)
                    
                    // Four subtriangles per original (orders preserve orientation for detection)
                    subFaces.push([a, d, mf]); // Corner at A
                    subFaces.push([b, e, d]); // Corner at B
                    subFaces.push([c, mf, e]); // Corner at C
                    subFaces.push([d, e, mf]); // Middle
                }
        
                var edgeCount = 0;
                // Now draw lines for subdivided edges
                var edges = new Map<String, Array<Int>>();
                function addEdge(a: Int, b: Int) {
                    var key = a < b ? '$a-$b' : '$b-$a';
                    if (!edges.exists(key)) {
                        edges.set(key, [a, b]);
                        edgeCount++;
                    }
                }
                for (sf in subFaces) {
                    addEdge(sf[0], sf[1]);
                    addEdge(sf[1], sf[2]);
                    addEdge(sf[2], sf[0]);
                }
        
        var g = new h3d.scene.Graphics(s3d);
        g.material.mainPass.depth(true, h3d.mat.Data.Compare.LessEqual); 
        g.lineStyle(2, 0x000000, 0.5);
    

        // Arc drawing function (updated to use newVerts)
        function drawArc(v1: h3d.Vector, v2: h3d.Vector, segments: Int = 16) {
            var theta = Math.acos(v1.dot(v2));
            var sinTheta = Math.sin(theta);
            if (sinTheta == 0) return;

            for (i in 0...segments) {
                var t1 = i / segments;
                var t2 = (i + 1) / segments;
                var a1 = Math.sin((1 - t1) * theta) / sinTheta;
                var a2 = Math.sin(t1 * theta) / sinTheta;
                var b1 = Math.sin((1 - t2) * theta) / sinTheta;
                var b2 = Math.sin(t2 * theta) / sinTheta;

                var p1 = new h3d.Vector(
                    a1 * v1.x + a2 * v2.x,
                    a1 * v1.y + a2 * v2.y,
                    a1 * v1.z + a2 * v2.z
                );
                var p2 = new h3d.Vector(
                    b1 * v1.x + b2 * v2.x,
                    b1 * v1.y + b2 * v2.y,
                    b1 * v1.z + b2 * v2.z
                );
                p1.normalize();
                p2.normalize();

                g.moveTo(p1.x, p1.y, p1.z);
                g.lineTo(p2.x, p2.y, p2.z);
            }
        }

        // Draw all subdivided edges
        for (edge in edges) {
            var v1 = newVerts[edge[0]];
            var v2 = newVerts[edge[1]];
            drawArc(v1, v2);
        }
        
        sphere.addChild(g);
         
    }

    static function main() {
        new Main();
    }

    public function new() {
        super();
        h3d.mat.MaterialSetup.current = new h3d.mat.PbrMaterialSetup();
    }

    override function update(dt: Float) {
        var rotationSpeed = 2.0; // Radians per second; adjust as needed for sensitivity
        var q_delta = new h3d.Quat();
        q_delta.identity();
        
        if (Key.isDown(Key.LEFT)) {
            var q_temp = new h3d.Quat();
            q_temp.initRotateAxis(0, 1, 0, rotationSpeed * dt);
            q_delta.multiply(q_delta, q_temp);
        }
        if (Key.isDown(Key.RIGHT)) {
            var q_temp = new h3d.Quat();
            q_temp.initRotateAxis(0, 1, 0, -rotationSpeed * dt);
            q_delta.multiply(q_delta, q_temp);
        }
        
        if (Key.isDown(Key.UP)) {
            var q_temp = new h3d.Quat();
            q_temp.initRotateAxis(1, 0, 0, -rotationSpeed * dt); // Negative to tilt top towards camera
            q_delta.multiply(q_delta, q_temp);
        }
        if (Key.isDown(Key.DOWN)) {
            var q_temp = new h3d.Quat();
            q_temp.initRotateAxis(1, 0, 0, rotationSpeed * dt);
            q_delta.multiply(q_delta, q_temp);
        }
        
        // Apply the inverse rotation to the camera position
        var q_inv = q_delta.clone();
        q_inv.conjugate();
        var m = new h3d.Matrix();
        q_inv.toMatrix(m);
        
        s3d.camera.pos.transform(m);
        
        if (Key.isDown(Key.SPACE)) {
            s3d.camera.zoom += 0.1;
        }
        if (Key.isDown(Key.SHIFT)) {
            s3d.camera.zoom -= 0.1;
        }
    }
        
    
    
}