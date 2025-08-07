import effects.FXAA.FXAAFilter;
import ui.ScrollListView;

class UITestMain extends hxd.App {

    var scrollList: ScrollListView;

    override function init() {
        hxd.Res.initEmbed();
        
        scrollList = new ScrollListView(350, 250);
        s2d.addChild(scrollList);

        scrollList.addItem("Item 1");
        scrollList.addItem("Item 2");
        scrollList.addItem("Item 3");
        scrollList.addItem("Item 4");
        scrollList.addItem("Item 5");
        scrollList.addItem("Item 6");
        scrollList.addItem("Item 7");
        scrollList.addItem("Item 8");

        
        /*
        var text = new h2d.Text(hxd.Res.fonts.plex_mono_64.toFont(), s2d);
        text.text = "Hello, World!";
        text.textColor = 0xFFFFFF;
        text.x = 100;
        text.y = 100;
        text.scaleX = 0.5;
        text.scaleY = 0.5;
        */
        s2d.filter = new FXAAFilter();
    }

    public static function main() {
        new UITestMain();
    }
}