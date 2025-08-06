package ludi.heaps.form.controls;

import hxd.res.DefaultFont;
import hxd.Res;
import ludi.heaps.box.Box;

abstract FormButton(Box) from Box to Box {

    public function new(labelText: String) {
        var bgPlugin = null;
        var vgPlugin = null;
        var b = Box.build(100, 30);
        b.backgroundColor(0xC6C9C6).and((plugin) -> {
            bgPlugin = plugin;
        });
        b.verticalGradient(0xFFFFFF, 0xC6C9C6).and((plugin) -> {
            plugin.changeToOnHover(0xC6C9C6, 0x888888);
            vgPlugin = plugin;
        });
        b.roundedCorners(6);
        b.roundedBorder(4, 0x000000, 6);
        b.text(labelText, 0x000000, DefaultFont.get());
        b.addEvents((events) -> {
            events.onMouseDown((e) -> {
                bgPlugin.activate();
            });
            events.onMouseUp((e) -> {
                vgPlugin.activate();            
            });
        });
        this = b.get();
    }
    
    @:to
    public function toFormControl(): FormControl {
        return cast abstract;
    }

    public function setValue(value: Bool): Void {}
    public function getValue(): Bool {return true;}
    public function onChange(action: (newValue: Dynamic, oldValue: Dynamic) -> Void): Void {
        var wasMouseDown = false;
        @:privateAccess this.events.onMouseDown((e) -> {
            wasMouseDown = true;
        });
        @:privateAccess this.events.onMouseUp((e) -> {
            if(wasMouseDown) {
                wasMouseDown = false;
                action(true, true);    
            }      
        });
    }
}