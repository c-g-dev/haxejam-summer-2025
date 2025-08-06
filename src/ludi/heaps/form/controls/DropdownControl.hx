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
    // Components
    private var selectedText: Text;
    private var border: Graphics;
    private var dropdownList: Object;
    private var listItems: Array<Text>;
    private var isOpen: Bool = false;
    private var bg: Box;

    // Dimensions and styling
    private var dropdownWidth: Int = 200;
    private var controlHeight: Int = 30;
    private var itemHeight: Int = 25; // Height of each dropdown item
    private var thinBorderWidth: Float = 1; // Thin border when not focused
    private var thickBorderWidth: Float = 3; // Thick border when focused

    // Data
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
           // closeDropdown(); // Close when focus is lost
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
        selectedText.textColor = 0x000000; // Black text for contrast
        selectedText.x = 5; // Padding inside the dropdown
        selectedText.y = (controlHeight - selectedText.textHeight) / 2;

        bg.addChild(selectedText);
        // Initialize the dropdown list (hidden by default)
        dropdownList = new Object(bg);
        dropdownList.visible = false;
        createDropdownList();

        border = new Graphics();
        bg.addChild(border);

        super(labelText, bg);

        // Add border graphics

      //  this.addToBackground(border);
       // border.x = dropdownX;
        //border.y = 0;

        // Display the selected item
      
        /*
        // Initialize the label
        label = new Text(font, this);
        label.text = labelText;
        label.textColor = 0x808080; // Gray color for the label
        label.x = 0;
        label.y = (controlHeight - label.textHeight) / 2; // Vertically center the label

        // Calculate the starting x-position for the dropdown
        var dropdownX = label.textWidth + padding;

        // Create gradient background for the dropdown button
        

        // Add an interactive area to toggle the dropdown
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
           // closeDropdown(); // Close when focus is lost
        };
        interactive.onOver = function(e) {
            interactive.focus();
        };
        interactive.onOut = function(e) {
            interactive.blur();
        }

        // Initialize the dropdown list (hidden by default)
        dropdownList = new Object(this);
        dropdownList.visible = false;
        createDropdownList(dropdownX, font);
        */
    }

    // Function to create a gradient bitmap
   /* private function createGradientBitmap(width: Int, height: Int): BitmapData {
        var gradient = new BitmapData(width, height);
        var startColor = 0xDDDDFF; // Light blue
        var endColor = 0xBBBBFF; // Slightly darker blue

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

    // Function to create the dropdown list
    private function createDropdownList() {
        var listBackground = new Graphics(dropdownList);
        listBackground.beginFill(0xF0F0F0); // Light gray background for the list
        listBackground.drawRect(0, 0, dropdownWidth, itemHeight * items.length);
        listBackground.endFill();
        listBackground.lineStyle(thinBorderWidth, 0x000000); // Thin black border
        listBackground.drawRect(0, 0, dropdownWidth, itemHeight * items.length);

        listItems = [];
        for (i in 0...items.length) {
            var itemText = new Text(DefaultFont.get(), dropdownList);
            itemText.text = items[i];
            itemText.textColor = 0x000000;
            itemText.x = 5; // Padding inside the list
            itemText.y = i * itemHeight + (itemHeight - itemText.textHeight) / 2;
            itemText.smooth = true;
            
            var itemInteractive = new Interactive(dropdownWidth, itemHeight, dropdownList);
            itemInteractive.x = 0;
            itemInteractive.y = i * itemHeight;
            itemInteractive.onOver = function(e) {
                itemText.textColor = 0xFFFFFF; // White text on hover
                listBackground.beginFill(0xBBBBFF); // Highlight color
                listBackground.drawRect(0, i * itemHeight, dropdownWidth, itemHeight);
                listBackground.endFill();
            };
            itemInteractive.onOut = function(e) {
                itemText.textColor = 0x000000; // Reset to black
                listBackground.beginFill(0xF0F0F0); // Reset background
                listBackground.drawRect(0, i * itemHeight, dropdownWidth, itemHeight);
                listBackground.endFill();
            };
            itemInteractive.onClick = function(e) {
                selectItem(i);
                closeDropdown();
            };

            listItems.push(itemText);
        }

        //dropdownList.x = dropdownX;
        dropdownList.y = controlHeight; // Position below the button\
        listBackground.filter = new DropShadow(    4.0,       // distance: offset downward
            3.14159 * 0.25,       // angle: 0 radians = straight down
            0x000000,  // color: black for a classic shadow
            0.5,       // alpha: semi-transparent for softness
            6.0,       // radius: larger glow for spread effect
            1.0,       // gain: full intensity
            2.0,       // quality: decent quality without heavy performance hit
            true       // smoothColor: gradient shadow for a beautiful, soft look
        );
    }

    // Toggle the dropdown visibility
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

    // Close the dropdown
    private function closeDropdown() {
        isOpen = false;
        dropdownList.visible = false;
        this.addChild(dropdownList);
        dropdownList.x = 0;
        dropdownList.y = 0;
    }

    // Select an item
    private function selectItem(index: Int) {
        selectedIndex = index;
        selectedText.text = items[selectedIndex];
    }

    // Update function to handle focus-based border thickness
    public function updateFocus() {
        border.clear();
        var isFocused = !bg.interactive.hasFocus() || isOpen;
        var borderWidth = isFocused ? thickBorderWidth : thinBorderWidth;
        border.lineStyle(borderWidth, 0x000000); // Black border
        border.drawRect(0, 0, dropdownWidth, controlHeight);
    }

    // Getter for the selected item
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