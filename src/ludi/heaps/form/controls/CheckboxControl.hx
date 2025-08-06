package ludi.heaps.form.controls;

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
import ludi.heaps.box.Box;
import ludi.heaps.form.FormControl.FormControlPair;

class CheckboxControl extends FormControlPair<Bool> {
    private var checkboxContainer: h2d.Object;  // Container for border and checkmark
    private var borderGraphics: Graphics;      // Graphics for the border box
    private var checkmarkGraphics: Graphics;   // Graphics for the checkmark
    //private var label: Text;                   // Label text
    private var checked: Bool = false;         // Checkbox state
    private var changeCallback: (Bool, Bool) -> Void;  // Callback for state changes

    public function new(labelText: String) {
        // Define sizes and layout parameters

        var checkboxSize = 30;

        var checkbox = new Box(checkboxSize, checkboxSize);
        borderGraphics = new Graphics();
        borderGraphics.beginFill(0xFFFFFF);        // White fill
        borderGraphics.lineStyle(1, 0x000000);     // Black border
        borderGraphics.drawRect(0, 0, checkboxSize, checkboxSize);     // 20x20 rectangle
        borderGraphics.endFill();
        checkbox.setBackground(borderGraphics);
        checkmarkGraphics = getCheckmarkGraphics(checkboxSize);
        checkbox.addChild(checkmarkGraphics);
        checkbox.onClick((e) -> {
            var oldValue = checked;
            checked = !checked;
            updateCheckboxAppearance();
            if (changeCallback != null) {
                changeCallback(checked, oldValue);
            }
        });


        super(labelText, checkbox); // Transparent background

       
    }

    /** Updates the checkbox appearance by toggling the checkmark visibility. */
    private function updateCheckboxAppearance() {
        checkmarkGraphics.visible = checked;
    }

    /** Stub method to get the checkmark graphics, to be implemented by the user. */
    private function getCheckmarkGraphics(checkboxSize: Float): Graphics {
       // var g = new Graphics();
        // Default checkmark implementation (can be overridden)
       /* g.beginFill(0x000000);    // Black fill
        g.moveTo(4, 10);
        g.lineTo(8, 14);
        g.lineTo(16, 6);
        g.endFill();
        return g;*/

        var icon = FeatherIcon.resolve("check");
        icon.color = 0x4EB455;
        icon.unitSize = 2;
        icon.strokeWidth = 4;
        var g = icon.toGraphics();
        trace("g.getBounds().width: " + g.getBounds().width);
        trace("g.getBounds().height: " + g.getBounds().height);
        g.scaleX = (checkboxSize / g.getBounds().width);
        g.scaleY = (checkboxSize / g.getBounds().height);
        g.y -= (checkboxSize / 20) * 5;
        g.x -= (checkboxSize / 20) * 2;
      //  g.x -= g.getBounds().width / 2;
      //  g.y -= g.getBounds().height / 2;

        return g;
    }

    /** Sets the checkbox value and updates its appearance. */
    public function setValue(value: Bool) {
        checked = value;
        updateCheckboxAppearance();
    }

    /** Returns the current checkbox value. */
    public function getValue(): Bool {
        return checked;
    }

    /** Sets a callback function to be called when the checkbox value changes. */
    public function onChange(callback: (Bool, Bool) -> Void) {
        changeCallback = callback;
    }
}