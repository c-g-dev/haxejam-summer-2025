package ludi.heaps.form;

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
import ludi.heaps.box.Containers.HBox;

interface FormControl<T = Dynamic> {
    public function setValue(value: T): Void;
    public function getValue(): T;
    public function onChange(cb: (newValue: T, oldValue: T) -> Void): Void;
}

abstract class FormControlPair<T = Dynamic> extends HBox {
    private var label: Text; 
    public var subform: Form;
    private var control: h2d.Object;

    public function new(labelText: String, controlObj: h2d.Object) {
        control = controlObj;
        label = createLabel(labelText);
        var width = label.textWidth + control.getBounds().width + 20;
        var height = Math.max(label.textHeight, control.getBounds().height);

        super(width, height);
        this.addChild(label);
        this.addChild(control);
    }

    public function createLabel(text: String): Text {
        label = new Text(DefaultFont.get());
        label.text = text + ":";
        label.textColor = 0x000000;
        label.smooth = true;
        //label.setScale(20 / label.font.size);
        return label;
    }

    public function getControl(): h2d.Object {
        return control;
    }

    public function getLabel(): Text {
        return label;
    }
    
    public abstract function setValue(value: T): Void;
    public abstract function getValue(): T;
    public abstract function onChange(cb: (newValue: T, oldValue: T) -> Void): Void;
}