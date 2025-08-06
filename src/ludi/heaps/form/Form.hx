package ludi.heaps.form;

import ludi.heaps.box.Containers.VBox;
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

using Lambda;
using StringTools;

typedef FormSchemaItem = {
    label:String,
    type:String
}

typedef FormSchema = Array<FormSchemaItem>;

typedef FormValues = Map<String, {value:Dynamic, ?subform:FormValues}>;

// Renderer typedef
typedef FormItemRenderer = {
    type:String,
    renderer:(form:Form, item:FormSchemaItem) -> h2d.Object,
    getValue:(form:Form, item:FormSchemaItem, control:h2d.Object) -> Dynamic,
    setValue:(form:Form, item:FormSchemaItem, control:h2d.Object, value:Dynamic) -> Void
}

class Form extends VBox {
    public var schema:Array<FormSchemaItem>;
    public var subforms:Map<String, Form>;
    public var controls:Map<String, h2d.Object>;
    public var changeCallbacks:Map<String, Void->Void>;
    public var validators:Map<String, Dynamic->Bool>;

    private static var renderers:Map<String, FormItemRenderer> = new Map();

    // Register a renderer for a specific form item type
    public static function registerRenderer(type:String, renderer:FormItemRenderer):Void {
        renderers.set(type, renderer);
    }

    // Constructor
    public function new(schema:Array<FormSchemaItem>) {
        super(200, 200);
        this.schema = schema;
        this.subforms = new Map();
        this.controls = new Map();
        this.changeCallbacks = new Map();
        this.validators = new Map();
      //  this.layout = Vertical;
       // this.verticalSpacing = 5;
        this.setPadding(10);
        this.forceRowHeight(30);
        // Initialize form items
        for (item in schema) {
            var control = renderItem(item);
            this.addChild(control);
            controls.set(item.label, control);
        }
    }

    // Render an individual form item (to be implemented via registered renderers)
    private function renderItem(item:FormSchemaItem):h2d.Object {
        var renderer = renderers.get(item.type);
        if (renderer != null) {
            return renderer.renderer(this, item);
        }
        // Placeholder for unregistered types
        var text = new h2d.Text(DefaultFont.get());
        text.text = 'Unknown type: ${item.type}';
        return text;
    }

    // Trigger change callbacks
    private function handleChange(label:String):Void {
        if (changeCallbacks.exists(label)) {
            changeCallbacks.get(label)();
        }
    }

    // Register a change callback for a form item
    public function onChange(itemLabel:String, cb:Void->Void):Void {
        changeCallbacks.set(itemLabel, cb);
    }

    // Set a subform for a specific form item
    public function setSubform(itemLabel:String, schema:Array<FormSchemaItem>):Void {
        var control = controls.get(itemLabel);
        if (control != null) {
            if (subforms.exists(itemLabel)) {
                var existingSubform = subforms.get(itemLabel);
                existingSubform.remove();
                subforms.remove(itemLabel);
            }
            var subform = new Form(schema);
            subforms.set(itemLabel, subform);
        } else {
            trace('Warning: Could not find control for label "${itemLabel}"');
        }
    }

    // Remove a subform
    public function removeSubform(itemLabel:String):Void {
        if (subforms.exists(itemLabel)) {
            var subform = subforms.get(itemLabel);
            subform.remove();
            subforms.remove(itemLabel);
        }
    }

    // Collect values from all form items and subforms
    public function getValues():FormValues {
        var values = new Map<String, {value:Dynamic, ?subform:FormValues}>();
        
        for (item in schema) {
            var control = controls.get(item.label);
            if (control != null) {
                var renderer = renderers.get(item.type);
                if (renderer != null) {
                    var value = renderer.getValue(this, item, control);
                    values.set(item.label, {value: value});
                }
            }
        }

        for (key in subforms.keys()) {
            var subformValues = subforms[key].getValues();
            if (values.exists(key)) {
                var existing = values.get(key);
                values.set(key, {value: existing.value, subform: subformValues});
            } else {
                values.set(key, {value: null, subform: subformValues});
            }
        }

        return values;
    }

    // Add a validator for a form item
    public function addValidation(itemLabel:String, validator:Dynamic->Bool):Void {
        validators.set(itemLabel, validator);
    }

    // Validate all form items and subforms
    public function validate():Bool {
        var values = getValues();
        var isValid = true;

        for (item in schema) {
            if (validators.exists(item.label)) {
                var value = values.get(item.label) != null ? values.get(item.label).value : null;
                var validator = validators.get(item.label);
                var valid = validator(value);
                if (!valid) {
                    isValid = false;
                    trace('Validation failed for ${item.label}');
                    // Add visual feedback here later if needed
                }
            }
        }

        for (subform in subforms) {
            if (!subform.validate()) {
                isValid = false;
            }
        }

        return isValid;
    }

    // Set the value of a specific form item
    public function setValue(itemLabel:String, value:Dynamic):Void {
        var control = controls.get(itemLabel);
        if (control != null) {
            var item = schema.find(i -> i.label == itemLabel);
            if (item != null) {
                var renderer = renderers.get(item.type);
                if (renderer != null) {
                    renderer.setValue(this, item, control, value);
                    handleChange(itemLabel);
                }
            }
        } else {
            trace('Warning: Could not find control for label "${itemLabel}"');
        }
    }

    // Convenience method to create and configure a form
    public static inline function create(schema:Array<FormSchemaItem>, setup:(Form)->Void):Form {
        var form = new Form(schema);
        setup(form);
        return form;
    }
}