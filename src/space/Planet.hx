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
import h2d.Bitmap;
import hxd.BufferFormat;
import hxd.FloatBuffer;
import hxd.IndexBuffer;
import h3d.shader.FixedColor;
import h3d.Matrix;

class Planet extends h3d.scene.Object {

    var sphere: Object;
    var labels: Array<{pos: h3d.Vector, text: h2d.Text}> = [];
    var plantIcons: Array<h2d.Bitmap> = [];
    var newVerts: Array<h3d.Vector>;
    var subFaces: Array<Array<Int>>;
    public var adjMap: Map<Int, Array<Int>>;

    public var cameraMover: PlanetCamera;

    // One overlay mesh per subdivided triangle for tinting/highlighting
    var triMeshes: Array<h3d.scene.Mesh> = [];
    var triColors: Array<h3d.shader.FixedColor> = [];


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
        sphereMesh.scale(.935);

        initGrid(s2d);

        // DEBUG: add a visible test triangle in front of camera to validate pipeline
      //  addDebugTestTriangle();
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

        // Build triangle overlay meshes BEFORE drawing edges so edges render on top
        buildTriangleOverlays();

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
            var icon = new h2d.Bitmap(hxd.Res.sprite_placeholder.toTile(), s2d);
            icon.visible = false;
            plantIcons.push(icon);
        }
    }

    // Create a simple single-triangle primitive and mesh for each subFace, slightly above sphere surface
    function buildTriangleOverlays(): Void {
        triMeshes = [];
        triColors = [];

        // Constant slight offset to avoid z-fighting with the sphere surface
        var pushOut = 1.004;

        for (i in 0...subFaces.length) {
            var sf = subFaces[i];
            var v1 = newVerts[sf[0]].clone(); v1.scale(pushOut);
            var v2 = newVerts[sf[1]].clone(); v2.scale(pushOut);
            var v3 = newVerts[sf[2]].clone(); v3.scale(pushOut);

            var mesh = createTriMesh(v1, v2, v3);
            sphere.addChild(mesh);

            // Use FixedColor, but render in the PBR "overlay" pass so alpha is respected
            var fixed = new FixedColor(0xFFFFFF, 0);
            mesh.material.mainPass.addShader(fixed);
            mesh.material.mainPass.enableLights = false;
            mesh.material.mainPass.culling = None;
            mesh.material.shadows = false;
            mesh.material.blendMode = h3d.mat.BlendMode.Alpha;
            mesh.material.mainPass.setPassName("overlay");
        
            // Now that we validated rendering, use sane depth test
            mesh.material.mainPass.depth(false, h3d.mat.Data.Compare.LessEqual);
            // removed overlay pass code because this doesn't do anything

            triMeshes.push(mesh);
            triColors.push(fixed);
        }
    }

    // Build a single-triangle RawPrimitive mesh from 3 points; normals point outward
    function createTriMesh(p1: h3d.Vector, p2: h3d.Vector, p3: h3d.Vector): h3d.scene.Mesh {
        // Include UVs to match common mesh pipeline expectations
        @:privateAccess var format = new BufferFormat([
            { name: "position", type: DVec3 },
            { name: "normal", type: DVec3 },
            { name: "uv", type: DVec2 }
        ]);

        var floats = new FloatBuffer();
        // Compute flat face normal for reliable shading
        var e1 = p2.sub(p1);
        var e2 = p3.sub(p1);
        var n = e1.cross(e2); n.normalize();
        function pushVertex(p: h3d.Vector, u: Float, v: Float) {
            floats.push(p.x); floats.push(p.y); floats.push(p.z);
            floats.push(n.x); floats.push(n.y); floats.push(n.z);
            floats.push(u); floats.push(v);
        }
        // Simple UVs for triangle
        pushVertex(p1, 0.0, 0.0);
        pushVertex(p2, 1.0, 0.0);
        pushVertex(p3, 0.5, 1.0);

        var idx = new IndexBuffer();
        idx.push(0); idx.push(1); idx.push(2);

        var bounds = new h3d.col.Bounds();
        bounds.addPos(p1.x, p1.y, p1.z);
        bounds.addPos(p2.x, p2.y, p2.z);
        bounds.addPos(p3.x, p3.y, p3.z);

        var prim = new RawPrimitive({ format: format, vbuf: floats, ibuf: idx, bounds: bounds });
        return new Mesh(prim);
    }

    // Places a large magenta triangle facing the camera near the origin as a visibility test
    function addDebugTestTriangle(): Void {
        // Triangle in front of origin, facing +Z camera; with Always depth test it should show regardless
        var p1 = new h3d.Vector(-0.8, -0.8, 0.2);
        var p2 = new h3d.Vector(0.8, -0.8, 0.2);
        var p3 = new h3d.Vector(0.0, 0.8, 0.2);
        var m = createTriMesh(p1, p2, p3);
        this.getScene().addChild(m);

        var fixed = new FixedColor(0xFF00FF, 1);
        m.material.mainPass.addShader(fixed);
        m.material.mainPass.enableLights = false;
        m.material.mainPass.culling = None;
        m.material.shadows = false;
        m.material.blendMode = h3d.mat.BlendMode.Alpha;
        m.material.mainPass.depth(false, h3d.mat.Data.Compare.Always);
    }

    // Set the overlay color (RGBA) for a given triangle id
    public function colorTriOverlay(index: Int, r: Float, g: Float, b: Float, a: Float): Void {
        if (index < 0 || index >= triColors.length) return;
        var c = triColors[index];
        c.color.set(r, g, b, a);
    }

    // Clear all overlays (make fully transparent)
    public function clearTriOverlays(): Void {
        for (c in triColors) c.color.set(0, 0, 0, 0);
    }

    public function updateLabels(camera: h3d.Camera, s2d: h2d.Scene) {
        var tanFov = Math.tan(camera.fovY * Math.PI / 180 / 2);
        // Use planet's absolute transform so labels follow any planet rotation
        var rotM = this.getAbsPos();
        var world = engine.Game.world;
        for (i in 0...labels.length) {
            var l = labels[i];
            var icon = plantIcons[i];

            var lp = l.pos.clone();
            lp.transform(rotM);

            var dot = lp.dot(camera.pos);
            if (dot <= 1) {
                l.text.visible = false;
                icon.visible = false;
                continue;
            }

            var p = lp.clone();
            p.project(camera.m);
            if (p.z < 0) {
                l.text.visible = false;
                icon.visible = false;
                continue;
            }

            var hasPlant = world != null && world.zones != null && i < world.zones.length && world.zones[i] != null && world.zones[i].plant != null;

            var dist = camera.pos.distance(lp);
            var px_per_world = s2d.height * camera.zoom / (2 * dist * tanFov);
            var desired_world_size = 0.06;
            var target_px = desired_world_size * px_per_world;

            var screenX = (p.x * 0.5 + 0.5) * s2d.width;
            var screenY = (-p.y * 0.5 + 0.5) * s2d.height;

            if (hasPlant) {
                // Show icon, hide text
                var tile = icon.tile;
                var scaleIcon = target_px / tile.width;
                icon.scaleX = scaleIcon;
                icon.scaleY = scaleIcon;
                icon.visible = true;
                l.text.visible = false;

                icon.x = screenX - (tile.width * scaleIcon) / 2;
                icon.y = screenY - (tile.height * scaleIcon) / 2;
            } else {
                // Show text, hide icon
                var scale = target_px / l.text.textWidth;
                l.text.scaleX = scale;
                l.text.scaleY = scale;
                l.text.visible = true;
                icon.visible = false;

                l.text.x = screenX - l.text.textWidth * scale / 2;
                l.text.y = screenY - l.text.textHeight * scale / 2;
            }
        }
    }

    public function getTriangleCenter(index: Int): h3d.Vector {
        if (index < 0 || index >= labels.length) return null;
        var p = labels[index].pos.clone();
        var m = this.getAbsPos();
        p.transform(m);
        p.normalize();
        return p;
    }

    public function centerOnTriangle(index: Int, camera: h3d.Camera) {
        if (index < 0 || index >= labels.length) return;
        var cent = getTriangleCenter(index);
        var dist = camera.pos.length();
        cent.scale(dist);
        camera.pos.load(cent);
        camera.update();
    }
}
