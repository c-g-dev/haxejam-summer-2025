package ludi.heaps.form.controls;

import ludi.heaps.box.Box;
import h2d.filter.DropShadow;
import h2d.Bitmap;
import heaps.feathericons.FeatherIcon;
import heaps.feathericons.FeatherIcons;
import hxd.Res;
import h2d.Graphics;
import h2d.Text;
import h2d.Object;
import h2d.Flow;
import h2d.Text;
import h2d.TextInput;
import h2d.Interactive;
import hxd.res.DefaultFont;
import ludi.heaps.form.FormControl.FormControlPair;

class DropdownControl extends FormControlPair<String> {
        private var selectedText: Text;
    private var border: Graphics;
    private var dropdownList: Object;
    private var listItems: Array<Text>;
    private var isOpen: Bool = false;
    private var bg: Box;

        private var dropdownWidth: Int = 200;
    private var controlHeight: Int = 30;
    private var itemHeight: Int = 25;     private var thinBorderWidth: Float = 1;     private var thickBorderWidth: Float = 3; 
        private var items: Array<String>;
    private var selectedIndex: Int = 0;

    public function new(labelText: String, items: Array<String>) {
        
        this.items = items;

        /*
        var gradient = createGradientBitmap(dropdownWidth, controlHeight);
        background = new Bitmap(Tile.fromBitmap(gradient), this);
        background.x = dropdownX;
        background.y = 0;
        */

        bg = new Box(dropdownWidth, controlHeight);
        bg.interactive.onClick = function(e) {
            toggleDropdown();
        };
        bg.interactive.onFocus = function(e) {
            trace("Focus");
            updateFocus();
        }
        bg.interactive.onFocusLost = function(e) {
            trace("Focus lost");
            updateFocus();
                   };
        bg.interactive.onOver = function(e) {
            interactive.focus();
        };
        bg.interactive.onOut = function(e) {
            interactive.blur();
        };

        Box.enhance(bg).border(thinBorderWidth, 0x808080);

        selectedText = new Text(DefaultFont.get());
        selectedText.text = items[selectedIndex];
        selectedText.textColor = 0x000000;         selectedText.x = 5;         selectedText.y = (controlHeight - selectedText.textHeight) / 2;

        bg.addChild(selectedText);
                dropdownList = new Object(bg);
        dropdownList.visible = false;
        createDropdownList();

        border = new Graphics();
        bg.addChild(border);

        super(labelText, bg);

        
                     
              
        /*
                label = new Text(font, this);
        label.text = labelText;
        label.textColor = 0x808080;         label.x = 0;
        label.y = (controlHeight - label.textHeight) / 2; 
                var dropdownX = label.textWidth + padding;

                

                interactive = new Interactive(dropdownWidth, controlHeight, this);
        interactive.x = dropdownX;
        interactive.y = 0;
        interactive.onClick = function(e) {
            toggleDropdown();
        };
        interactive.onFocus = function(e) {
            trace("Focus");
            updateFocus();
        }
        interactive.onFocusLost = function(e) {
            trace("Focus lost");
            updateFocus();
                   };
        interactive.onOver = function(e) {
            interactive.focus();
        };
        interactive.onOut = function(e) {
            interactive.blur();
        }

                dropdownList = new Object(this);
        dropdownList.visible = false;
        createDropdownList(dropdownX, font);
        */
    }

       /* private function createGradientBitmap(width: Int, height: Int): BitmapData {
        var gradient = new BitmapData(width, height);
        var startColor = 0xDDDDFF;         var endColor = 0xBBBBFF; 
        for (x in 0...width) {
            var ratio = x / (width - 1);
            var r = Math.round((startColor >> 16) + ratio * ((endColor >> 16) - (startColor >> 16)));
            var g = Math.round(((startColor >> 8) & 0xFF) + ratio * (((endColor >> 8) & 0xFF) - ((startColor >> 8) & 0xFF)));
            var b = Math.round((startColor & 0xFF) + ratio * ((endColor & 0xFF) - (startColor & 0xFF)));
            var color = 0xFF000000 | (r << 16) | (g << 8) | b;

            for (y in 0...height) {
                gradient.setPixel(x, y, color);
            }
        }
        return gradient;
    }*/

        private function createDropdownList() {
        var listBackground = new Graphics(dropdownList);
        listBackground.beginFill(0xF0F0F0);         listBackground.drawRect(0, 0, dropdownWidth, itemHeight * items.length);
        listBackground.endFill();
        listBackground.lineStyle(thinBorderWidth, 0x000000);         listBackground.drawRect(0, 0, dropdownWidth, itemHeight * items.length);

        listItems = [];
        for (i in 0...items.length) {
            var itemText = new Text(DefaultFont.get(), dropdownList);
            itemText.text = items[i];
            itemText.textColor = 0x000000;
            itemText.x = 5;             itemText.y = i * itemHeight + (itemHeight - itemText.textHeight) / 2;
            itemText.smooth = true;
            
            var itemInteractive = new Interactive(dropdownWidth, itemHeight, dropdownList);
            itemInteractive.x = 0;
            itemInteractive.y = i * itemHeight;
            itemInteractive.onOver = function(e) {
                itemText.textColor = 0xFFFFFF;                 listBackground.beginFill(0xBBBBFF);                 listBackground.drawRect(0, i * itemHeight, dropdownWidth, itemHeight);
                listBackground.endFill();
            };
            itemInteractive.onOut = function(e) {
                itemText.textColor = 0x000000;                 listBackground.beginFill(0xF0F0F0);                 listBackground.drawRect(0, i * itemHeight, dropdownWidth, itemHeight);
                listBackground.endFill();
            };
            itemInteractive.onClick = function(e) {
                selectItem(i);
                closeDropdown();
            };

            listItems.push(itemText);
        }

                dropdownList.y = controlHeight;         listBackground.filter = new DropShadow(    4.0,                   3.14159 * 0.25,                   0x000000,              0.5,                   6.0,                   1.0,                   2.0,                   true               );
    }

        private function toggleDropdown() {
        isOpen = !isOpen;
        dropdownList.visible = isOpen;
        var x = dropdownList.absX;
        var y = dropdownList.absY;
        this.getScene().addChild(dropdownList);
        dropdownList.x = x;
        dropdownList.y = y;
        if(isOpen) {
            bg.interactive.focus();
        }
        else {
            bg.interactive.blur();
        }
    }

        private function closeDropdown() {
        isOpen = false;
        dropdownList.visible = false;
        this.addChild(dropdownList);
        dropdownList.x = 0;
        dropdownList.y = 0;
    }

        private function selectItem(index: Int) {
        selectedIndex = index;
        selectedText.text = items[selectedIndex];
    }

        public function updateFocus() {
        border.clear();
        var isFocused = !bg.interactive.hasFocus() || isOpen;
        var borderWidth = isFocused ? thickBorderWidth : thinBorderWidth;
        border.lineStyle(borderWidth, 0x000000);         border.drawRect(0, 0, dropdownWidth, controlHeight);
    }

        public var selected(get, never): String;
    private inline function get_selected(): String {
        return items[selectedIndex];
    }

    public function setValue(value:String) {}

    public function getValue():String {
        throw new haxe.exceptions.NotImplementedException();
    }

    public function onChange(cb:(newValue:String, oldValue:String) -> Void) {}
}