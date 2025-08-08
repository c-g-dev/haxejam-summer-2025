package space;

import space.Sun;
import hxd.Key;
import heaps.coroutine.Coroutine.FrameYield;
import heaps.coroutine.Sequence;
import heaps.coroutine.Coro;
import h3d.scene.fwd.DirLight;
import h3d.scene.*;
import h3d.prim.*;
import hxd.Event;
import h2d.Text;

class Planet extends h3d.scene.Object {

    var sphere: Object;
    var labels: Array<{pos: h3d.Vector, text: h2d.Text}> = [];
    var newVerts: Array<h3d.Vector>;
    var subFaces: Array<Array<Int>>;
    public var adjMap: Map<Int, Array<Int>>;

    public var cameraMover: PlanetCamera;

    public function new(parent: Object, s2d: h2d.Scene, camera: h3d.Camera) {
        super(parent);

        cameraMover = new PlanetCamera(this, camera);

        sphere = new Object(this);

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

        initGrid(s2d);
    }

    private function initGrid(s2d: h2d.Scene) {
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
        newVerts = verts.copy(); // Start with originals (indices 0-11)
        var midMap = new Map<String, Int>(); // Key: "min-max", Value: new vertex index
        subFaces = []; // Array<Array<Int>> for 80 subdivided faces

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

        // Build edge to triangles map
        var edgeToTris = new Map<String, Array<Int>>();
        for (triIdx in 0...subFaces.length) {
            var tri = subFaces[triIdx];
            var triEdges = [[tri[0], tri[1]], [tri[1], tri[2]], [tri[2], tri[0]]];
            for (e in triEdges) {
                e.sort((a,b) -> a - b);
                var key = '${e[0]}-${e[1]}';
                if (!edgeToTris.exists(key)) {
                    edgeToTris.set(key, []);
                }
                edgeToTris.get(key).push(triIdx);
            }
        }

        // Build adjacency map
        adjMap = new Map<Int, Array<Int>>();
        for (triIdx in 0...subFaces.length) {
            var tri = subFaces[triIdx];
            var adjs = [];
            var triEdges = [[tri[0], tri[1]], [tri[1], tri[2]], [tri[2], tri[0]]];
            for (e in triEdges) {
                e.sort((a,b) -> a - b);
                var key = '${e[0]}-${e[1]}';
                var tris = edgeToTris.get(key);
                var other = (tris[0] == triIdx) ? tris[1] : tris[0];
                adjs.push(other);
            }
            adjMap.set(triIdx, adjs);
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

        var g = new h3d.scene.Graphics(sphere);
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

        // Add labels for each subdivided face
        var font = hxd.res.DefaultFont.get();
        for (i in 0...subFaces.length) {
            var sf = subFaces[i];
            var centroid = new h3d.Vector(0, 0, 0);
            for (vidx in sf) {
                var v = newVerts[vidx];
                centroid.x += v.x;
                centroid.y += v.y;
                centroid.z += v.z;
            }
            centroid.scale(1 / 3);
            centroid.normalize();  // Project back to sphere surface

            var t = new h2d.Text(font, s2d);
            t.text = Std.string(i);
            t.textColor = 0xFF0000;
            t.dropShadow = { dx: 1, dy: 1, color: 0x000000, alpha: 0.5 };  // For better visibility

            labels.push({ pos: centroid, text: t });
        }
    }

    public function updateLabels(camera: h3d.Camera, s2d: h2d.Scene) {
        var tanFov = Math.tan(camera.fovY * Math.PI / 180 / 2);
        for (l in labels) {
            var dot = l.pos.dot(camera.pos);
            if (dot <= 1) {
                l.text.visible = false;
                continue;
            }

            var p = l.pos.clone();
            p.project(camera.m);
            if (p.z < 0) {
                l.text.visible = false;
                continue;
            }
            l.text.visible = true;

            var dist = camera.pos.distance(l.pos);
            var px_per_world = s2d.height * camera.zoom / (2 * dist * tanFov);
            var desired_world_size = 0.05;  // Adjust this value to change the apparent size of the labels on the sphere
            var target_px = desired_world_size * px_per_world;
            var scale = target_px / l.text.textWidth;

            l.text.scaleX = scale;
            l.text.scaleY = scale;

            l.text.x = (p.x * 0.5 + 0.5) * s2d.width;
            l.text.y = (-p.y * 0.5 + 0.5) * s2d.height;

            // Center the text
            l.text.x -= l.text.textWidth * scale / 2;
            l.text.y -= l.text.textHeight * scale / 2;
        }
    }

    public function getTriangleCenter(index: Int): h3d.Vector {
        if (index < 0 || index >= labels.length) return null;
        return labels[index].pos.clone();
    }

    public function centerOnTriangle(index: Int, camera: h3d.Camera) {
        if (index < 0 || index >= labels.length) return;
        var cent = labels[index].pos.clone();
        var dist = camera.pos.length();
        cent.scale(dist);
        camera.pos.load(cent);
        camera.update();
    }
}
