package ui;

import ui.Nav.ArrowNav;
import ui.Nav.ArrowNavEvent;
import ludi.heaps.box.Plugins.BackgroundColorPlugin;
import ludi.heaps.box.Plugins.BackgroundPlugin;
import ludi.heaps.box.Plugins.VerticalGradientPlugin;
import ludi.heaps.box.Containers.VBox;
import ludi.heaps.box.Plugins.DrawRoundedBorderPlugin;
import ludi.heaps.box.Box;
import ludi.heaps.box.Containers.ScrollBox;

class ScrollListItem extends h2d.Object {
    var text: h2d.Text;

    public function new(text:String) {
        super();
        this.text = new h2d.Text(hxd.Res.fonts.plex_mono_64.toFont(), this);
        this.text.text = text;
        this.text.textColor = 0xFFFFFF;
        this.text.x = 10;
        this.text.y = 10;

        this.scaleX = 0.5;
        this.scaleY = 0.5;
    }

    public function setSelected(selected:Bool) {
        if(selected) {
            this.text.textColor = 0xFFFFFF;
        }
        else {
            this.text.textColor = 0x000000;
        }
    }

    public override function sync(ctx:h2d.RenderContext) {
        super.sync(ctx);
        this.text.x = Std.int(this.text.x);
        this.text.y = Std.int(this.text.y);
        this.x = Std.int(this.x);
        this.y = Std.int(this.y);
    }
}

class ScrollListView extends h2d.Object {
    var scrollbox: NavScrollBox;
    var nav: ArrowNav;

    public function new(width:Float, height:Float) {
        super();

        var container = new VBox(350, 250);

        var header = new Box(350, 20);
        header.addPlugin(new VerticalGradientPlugin(0xA5A5A5, 0x6E6E6E));
        container.addChild(header);

        scrollbox = new NavScrollBox(350, 230);
        scrollbox.addPlugin(new BackgroundColorPlugin(0x292929));
        container.addChild(scrollbox);

        var footer = new Box(350, 10);
        footer.addPlugin(new VerticalGradientPlugin(0xA5A5A5, 0x6E6E6E));
        container.addChild(footer);
        
        this.addChild(container);

                nav = new ArrowNav();
    }

    public function addItem(text:String) {
        var item = new ScrollListItem(text);
        scrollbox.addChild(item);
        nav.bind(item, function(event:ArrowNavEvent) {
            switch(event) {
                case Enter:
                    item.setSelected(true);
                case Leave:
                    item.setSelected(false);
                case Selected:
                                }
        });
    }
}