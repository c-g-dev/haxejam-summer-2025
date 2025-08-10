package space;

import h3d.Camera;

class Skybox {
    public var mesh:h3d.scene.Mesh;
    
    public function new(scene:h3d.scene.Scene, tex:h3d.mat.Texture, radius:Float = 1000.) {
                var prim = new h3d.prim.Sphere(radius, 32, 16);
        prim.addNormals();
        prim.addUVs();
        mesh = new h3d.scene.Mesh(prim, scene);
    
                var m = mesh.material;
        m.texture = tex;
                tex.wrap = Clamp;
    
        var pass = m.mainPass;
        pass.enableLights = false;             pass.culling = Front;         pass.depthWrite = false;           
                  }
    
    public function setTexture(tex:h3d.mat.Texture) {
        mesh.material.texture = tex;
        tex.wrap = Clamp;
    }
    
        public inline function updateToCamera(cam:h3d.Camera) {
        mesh.setPosition(cam.pos.x, cam.pos.y, cam.pos.z);
    }
    }