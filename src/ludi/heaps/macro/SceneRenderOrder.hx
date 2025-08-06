package ludi.heaps.macro;

//init macro to let sd3 render after s2d
//usage: --init ludi.heaps.macro.SceneRenderOrder.swap();
class StageRenderOrder {

    public static function swap() {
        no.Spoon.bend("hxd.App", macro class {
            public function render(e:h3d.Engine) {
                s2d.render(e);
                s3d.render(e);
            }
        });
    }
}