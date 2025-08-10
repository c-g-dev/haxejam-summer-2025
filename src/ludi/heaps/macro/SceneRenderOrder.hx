package ludi.heaps.macro;

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