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
    private var checkboxContainer: h2d.Object;      private var borderGraphics: Graphics;          private var checkmarkGraphics: Graphics;           private var checked: Bool = false;             private var changeCallback: (Bool, Bool) -> Void;  
    public function new(labelText: String) {
        
        var checkboxSize = 30;

        var checkbox = new Box(checkboxSize, checkboxSize);
        borderGraphics = new Graphics();
        borderGraphics.beginFill(0xFFFFFF);                borderGraphics.lineStyle(1, 0x000000);             borderGraphics.drawRect(0, 0, checkboxSize, checkboxSize);             borderGraphics.endFill();
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


        super(labelText, checkbox); 
       
    }

    
    private function updateCheckboxAppearance() {
        checkmarkGraphics.visible = checked;
    }

    
    private function getCheckmarkGraphics(checkboxSize: Float): Graphics {
                      /* g.beginFill(0x000000);            g.moveTo(4, 10);
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
            
        return g;
    }

    
    public function setValue(value: Bool) {
        checked = value;
        updateCheckboxAppearance();
    }

    
    public function getValue(): Bool {
        return checked;
    }

    
    public function onChange(callback: (Bool, Bool) -> Void) {
        changeCallback = callback;
    }
}