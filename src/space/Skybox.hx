package space;

import h3d.Camera;

class Skybox {
    public var mesh:h3d.scene.Mesh;
    
    public function new(scene:h3d.scene.Scene, tex:h3d.mat.Texture, radius:Float = 1000.) {
        // Sphere with equirect UVs; segments can be adjusted
        var prim = new h3d.prim.Sphere(radius, 32, 16);
        prim.addNormals();
        prim.addUVs();
        mesh = new h3d.scene.Mesh(prim, scene);
    
        // Basic unlit material setup
        var m = mesh.material;
        m.texture = tex;
        // Clamp is usually preferred for skies to avoid seams at poles/edges
        tex.wrap = Clamp;
    
        var pass = m.mainPass;
        pass.enableLights = false;     // unlit
        pass.culling = Front; // render inside of the sphere
        pass.depthWrite = false;       // don't write depth (so other objects render over it)
    
        // Draw very early so everything else overlays it
      //  mesh.layer = -1000;
    }
    
    public function setTexture(tex:h3d.mat.Texture) {
        mesh.material.texture = tex;
        tex.wrap = Clamp;
    }
    
    // Call each frame so the sky follows the camera position (no parallax)
    public inline function updateToCamera(cam:h3d.Camera) {
        mesh.setPosition(cam.pos.x, cam.pos.y, cam.pos.z);
    }
    }