package space;

import h3d.scene.Object;
import h3d.scene.Mesh;
import h3d.prim.Sphere;
import h3d.mat.Material;
import h3d.mat.Data.Face;
import h3d.mat.Data.Compare;
import h3d.Camera;

// Simple sky dome that renders a large inward-facing sphere textured with a sky image.
// It is unlit, follows the camera, and gently rotates over time.
class Stars extends Object {
    var mesh:Mesh;
    var camera:Camera;
    var rotationSpeed:Float = 0.02; // radians per second, very subtle

    public function new(parent:Object, camera:Camera) {
        super(parent);
        this.camera = camera;

        var prim = new Sphere(100, 48, 48); // Large radius so we are always inside
        prim.addNormals();
        prim.addUVs();

        mesh = new Mesh(prim, this);

        var mat = Material.create();
        mat.mainPass.enableLights = false; // Unlit
        mat.mainPass.culling = Face.Front; // Render inside faces
        mat.mainPass.depth(true, Compare.LessEqual);
        mat.mainPass.depthWrite = false; // Do not write depth so it never occludes scene

        var tex = hxd.Res.skybox.toTexture();
        tex.wrap = Repeat;
        tex.filter = Linear;
        mat.texture = tex;

        mesh.material = mat;

        // Start centered on camera
        setPosition(camera.pos.x, camera.pos.y, camera.pos.z);
    }

    override function sync(ctx:h3d.scene.RenderContext) {
        super.sync(ctx);
        // Keep centered on camera and apply a very slight rotation
        setPosition(camera.pos.x, camera.pos.y, camera.pos.z);
        rotate(0, rotationSpeed * ctx.elapsedTime, 0);
    }
}