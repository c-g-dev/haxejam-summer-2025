package space;

import h3d.scene.Object;
import h3d.scene.Mesh;
import h3d.prim.Sphere;
import h3d.mat.Material;
import h3d.mat.Data.Face;
import h3d.mat.Data.Compare;
import h3d.Camera;

class Stars extends Object {
    var mesh:Mesh;
    var camera:Camera;
    var rotationSpeed:Float = 0.02; 
    public function new(parent:Object, camera:Camera) {
        super(parent);
        this.camera = camera;

        var prim = new Sphere(100, 48, 48);         prim.addNormals();
        prim.addUVs();

        mesh = new Mesh(prim, this);

        var mat = Material.create();
        mat.mainPass.enableLights = false;         mat.mainPass.culling = Face.Front;         mat.mainPass.depth(true, Compare.LessEqual);
        mat.mainPass.depthWrite = false; 
        var tex = hxd.Res.skybox.toTexture();
        tex.wrap = Repeat;
        tex.filter = Linear;
        mat.texture = tex;

        mesh.material = mat;

                setPosition(camera.pos.x, camera.pos.y, camera.pos.z);
    }

    override function sync(ctx:h3d.scene.RenderContext) {
        super.sync(ctx);
                setPosition(camera.pos.x, camera.pos.y, camera.pos.z);
        rotate(0, rotationSpeed * ctx.elapsedTime, 0);
    }
}