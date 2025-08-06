package ludi.heaps.form.controls;

import ludi.heaps.box.Box;
import h2d.filter.DropShadow;
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

class TextInputControl extends FormControlPair<String> {
    // Components
    //private var label: Text;
    private var textInput: TextInput;
    //private var background: Bitmap;

    // Dimensions and styling
    private var inputWidth: Int = 200;
    private var inputHeight: Int = 30;
    //private var padding: Float = 10; // Space between label and input
    private var inputPadding: Float = 5; // Padding inside the input field

    public function new(labelText: String) {
       // super();

        // Initialize the label
    /*    label = new Text(font, this);
        label.text = labelText;
        label.textColor = 0x808080; // Gray color for the label
        label.x = 0;
        label.y = (inputHeight - label.textHeight) / 2; // Vertically center the label

        // Calculate the starting x-position for the input field
        var inputX = label.textWidth + padding;

        // Create a gradient bitmap for the background
        var gradient = createGradientBitmap(inputWidth, inputHeight);

        // Initialize the background bitmap
        background = new Bitmap(Tile.fromBitmap(gradient), this);
        background.x = inputX;
        background.y = 0;*/

        var box = new Box(inputWidth, inputHeight);
        var border = new Graphics();
        border.lineStyle(1, 0x000000);
        border.drawRect(0, 0, inputWidth, inputHeight);
       // border.endFill();
        box.addToBackground(border);

        // Initialize the text input
        textInput = new TextInput(DefaultFont.get());
    
        //textInput.x = inputX + inputPadding;
      //  textInput.y = (inputHeight - textInput.textHeight) / 2; // Vertically center the text
        //textInput.maxWidth = inputWidth - 2 * inputPadding; // Limit text width with padding
        textInput.textColor = 0x000000; // Black text for contrast
        var textScale = 0.8;
        textInput.scaleX = textScale;
        textInput.scaleY = textScale;
        textInput.x  = inputPadding;
        textInput.y = (inputHeight - textInput.textHeight * textScale) / 2;
        textInput.inputWidth = Std.int(inputWidth - (2 * inputPadding));
        textInput.smooth = true;
        box.addChild(textInput);

        // Add a drop shadow filter for depth
      //  this.filter = new DropShadow(2, 0.785, 0x000000, 0.5);

        super(labelText, box);
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

    // Getter and setter for the text input value
    public var text(get, set): String;
    private inline function get_text(): String {
        return textInput.text;
    }
    private inline function set_text(value: String): String {
        return textInput.text = value;
    }

    public function setValue(value:String) {}

    public function getValue():String {
        throw new haxe.exceptions.NotImplementedException();
    }

    public function onChange(cb:(newValue:String, oldValue:String) -> Void) {}
}
