package ludi.heaps.box;

import h2d.Tile;
import h2d.Bitmap;
import hxd.Window;
import hxd.fmt.grd.Data;
import ludi.heaps.util.Gradient;
import ludi.heaps.box.Box.BoxEvents;
import ludi.heaps.box.Box.BoxPlugin;

class TextPlugin extends BoxPlugin {
    private var text:String;
    private var textObject:h2d.Text;
    private var color:Int;  // Optional: for text color
    private var font:h2d.Font;  // Optional: for custom font
    private var textSize:Float;

    public function new(text:String, ?color:Int = 0xFFFFFF, ?font:h2d.Font, ?textSize:Float = -1) {
        this.text = text;
        this.color = color;
        this.font = font != null ? font : hxd.res.DefaultFont.get();
    }

    public function apply(box:Box, events:BoxEvents) {
        textObject = new h2d.Text(font, box);
        textObject.text = this.text;
        textObject.textColor = this.color;

        if(textSize > 0) {
            textObject.setScale(textSize / textObject.font.size);
        }
        
        // Center the text
        textObject.x = (box.width - textObject.textWidth) / 2;
        textObject.y = (box.height - textObject.textHeight) / 2;
        
        box.addChild(textObject);
    }


}

class BackgroundColorPlugin extends BoxPlugin {
    private var color:Int;
    private var bitmap:h2d.Bitmap;
    public function new(color:Int) {
        this.color = color;
        var tile = h2d.Tile.fromColor(color);
        bitmap = new h2d.Bitmap(tile);
    }

    public function apply(box:Box, events:BoxEvents) {
        bitmap.width = box.width;
        bitmap.height = box.height;
        box.setBackground(bitmap);
    }

    public function activate() {
        box.setBackground(bitmap);
    }
}

class BackgroundPlugin extends BoxPlugin {
    private var tile:h2d.Tile;
    private var bitmap:h2d.Bitmap;

    public function new(tile:h2d.Tile) {
        this.tile = tile;
    }

    public function apply(box:Box, events:BoxEvents) {
        // Create bitmap with the scaled tile
        bitmap = new h2d.Bitmap(tile);
        bitmap.width = box.width;
        bitmap.height = box.height;
        
        // Add it to the background layer
        box.setBackground(bitmap);
        
    }

    public function setTile(tile:h2d.Tile) {
        this.tile = tile;
        bitmap.tile = tile;
    }
}


class DrawRoundedBorderPlugin extends BoxPlugin {
    private var thickness:Float;
    private var color:Int;
    private var cornerRadius:Float;
    private var border:h2d.Graphics;

    public function new(thickness:Float, color:Int, cornerRadius:Float) {
        this.thickness = thickness;
        this.color = color;
        this.cornerRadius = cornerRadius;
    }

    public function apply(box:Box, events:BoxEvents) {
        // Create a new Graphics object
        border = new h2d.Graphics();
        
        // Draw the rounded border
        updateBorder(box.width, box.height);
        
        // Add to background layer
        box.addToBackground(border);
        
        // Update border when box size changes
        events.onChildAdded(function(child:h2d.Object) {
            updateBorder(box.width, box.height);
        });
    }

    private function updateBorder(width:Float, height:Float) {
        border.clear();
        
        //basic
        
        border.lineStyle(thickness * 10, color, 1);
        border.drawRoundedRect(0, 0, width * 10, height * 10, cornerRadius * 10);
        border.lineStyle(thickness * 10, color, 0.3);
        border.drawRoundedRect(0, 0, width * 10, height * 10, cornerRadius * 12);
        border.lineStyle(thickness * 10, color, 0.1);
        border.drawRoundedRect(0, 0, width * 10, height * 10, cornerRadius * 13);
        /*border.scaleX = 0.1;
        border.scaleY = 0.1;
        */

        //double draw
        /*
        border.lineStyle(thickness * 10, color, 0.5);
        border.drawRoundedRect(0, 0, width * 10, height * 10, cornerRadius * 10);
        var pxDiff = ((thickness * 10) - (thickness * 8)) / 2;
        border.lineStyle(thickness * 5, color, 1);
        border.drawRoundedRect(pxDiff, pxDiff, (width * 10) - pxDiff, (height * 10) - pxDiff, cornerRadius * 10);
        border.scaleX = 0.1;
        border.scaleY = 0.1;
        */

      

        /* 1 px inside
        border.lineStyle(thickness * 10, color, 0.6);
        border.drawRoundedRect(10, 10, (width * 10) - 20, (height * 10) - 20, cornerRadius * 11);
        */

        /*
        border.lineStyle(thickness * 10, color, 0.1);
        border.drawRoundedRect(0, 0, width * 10, height * 10, cornerRadius * 9);

        border.lineStyle(thickness * 10, color, 0.1);
        border.drawRoundedRect(0, 0, width * 10, height * 10, cornerRadius * 14);


        border.lineStyle(thickness * 10, color, 0.3);
        border.drawRoundedRect(0, 0, width * 10, height * 10, cornerRadius * 13);

        border.lineStyle(thickness * 10, color, 1);
        border.drawRoundedRect(0, 0, width * 10, height * 10, cornerRadius * 11);

        */

        border.scaleX = 0.1;
        border.scaleY = 0.1;


        // Enable smoothing for better quality
        border.smooth = true;
    }
}

class RoundedCornersPlugin extends BoxPlugin {
    private var cornerRadius:Float;
    private var maskGraphics:h2d.Graphics;

    public function new(cornerRadius:Float) {
        this.cornerRadius = cornerRadius;
    }

    public function apply(box:Box, events:BoxEvents) {
        // Create graphics object for the mask
        maskGraphics = new h2d.Graphics();
        
        // Draw the mask
        updateMask(box.width, box.height);
        
        // Add mask to box as a child (not background)
        box.addChild(maskGraphics);
        
        // Apply the mask filter to the box
        box.filter = new h2d.filter.Mask(maskGraphics, false, true);
        
        // Update mask when box size changes
        events.onChildAdded(function(child:h2d.Object) {
            updateMask(box.width, box.height);
        });
    }

    private function updateMask(width:Float, height:Float) {
        maskGraphics.clear();


                
        maskGraphics.beginFill(0xFFFFFF, 0.6);
        maskGraphics.drawRoundedRect(0, 0, width, height, cornerRadius * 0.9);
        maskGraphics.endFill();

        maskGraphics.beginFill(0xFFFFFF, 1);
        maskGraphics.drawRoundedRect(0, 0, width, height, cornerRadius * 1.1);
        maskGraphics.endFill();

        /*better to do fxaa:

        var fxaa =  new FXAAFilter() ;
        fxaa.blendStrength = 3;
        s2d.filter = fxaa;

        */

        
        // Enable smoothing for better quality
        maskGraphics.smooth = true;
    }
}


class DrawBorderPlugin extends BoxPlugin {
    private var thickness:Float;
    private var color:Int;
    private var border:h2d.Graphics;

    public function new(thickness:Float, color:Int) {
        this.thickness = thickness;
        this.color = color;
    }

    public function apply(box:Box, events:BoxEvents) {
        // Create a new Graphics object for drawing
        border = new h2d.Graphics();
        
        // Draw the border
        updateBorder(box.width, box.height);
        
        // Add to background layer
        box.addToBackground(border);
        
        // Update border when children are added (in case box size changes)
        events.onChildAdded(function(child:h2d.Object) {
            updateBorder(box.width, box.height);
        });
    }

    private function updateBorder(width:Float, height:Float) {
        border.clear();
        
        // Set line style
        border.lineStyle(thickness, color);
        
        // Draw rectangle border
        border.drawRect(0, 0, width, height);
    }
}

class VerticalGradientPlugin extends BoxPlugin {
    private var topColor:Int;
    private var bottomColor:Int;
    private var tile:h2d.Tile;
    private var hoverTile:h2d.Tile;
    private var bitmap:h2d.Bitmap;

    public function new(topColor:Int, bottomColor:Int) {
        this.topColor = topColor;
        this.bottomColor = bottomColor;
        this.tile = Gradient.create([
            { location: 0.0, color: hexToRGB(topColor), opacity: 1.0 },   
            { location: 1.0, color: hexToRGB(bottomColor), opacity: 1.0 } 
        ], 256).rotate90Clockwise().toTile();
    }

    function hexToRGB(hex:Int): hxd.fmt.grd.Data.Color {
        // Ensure the hex value is positive and within valid range
        if (hex < 0 || hex > 0xFFFFFF) {
            throw "Invalid hex color value. Expected range: 0x000000 to 0xFFFFFF";
        }
    
        // Extract RGB components using bitwise operations
        var r = (hex >> 16) & 0xFF; // Extract red (first 8 bits)
        var g = (hex >> 8) & 0xFF;  // Extract green (middle 8 bits)
        var b = hex & 0xFF;         // Extract blue (last 8 bits)
        return RGB(r, g, b);
    }

    public function apply(box:Box, events:BoxEvents) {
        bitmap = new h2d.Bitmap(tile);
        bitmap.width = box.width;
        bitmap.height = box.height;
        box.setBackground(bitmap);
    }

    public function activate() {
        box.setBackground(bitmap);
    }

    public function changeToOnHover(topColor:Int, bottomColor:Int) {
        if(this.hoverTile == null) {
            this.hoverTile = Gradient.create([
                {location: 0.0, color: hexToRGB(topColor), opacity: 1.0},
                {location: 1.0, color: hexToRGB(bottomColor), opacity: 1.0}
            ], 256).rotate90Clockwise().toTile();
        }
        this.events.onMouseOver(function(e:hxd.Event) {
            bitmap.tile = hoverTile;
        });
        this.events.onMouseOut(function(e:hxd.Event) {
            bitmap.tile = tile;
        });
    } 


}


class PopupPlugin extends BoxPlugin {
    private var color:Int;       // Tint color (e.g., 0x000000 for black)
    private var alpha:Float;     // Tint transparency (0.0 to 1.0)
    private var tint:Bitmap;     // The tint overlay object

    // Constructor with optional color and alpha parameters
    public function new(color:Int = 0x000000, alpha:Float = 0.5) {
        this.color = color;
        this.alpha = alpha;
    }

    // Apply the plugin to the box
    public function apply(box:Box, events:BoxEvents) {
        box.hide();
        var scene = box.getScene();

        var tintTile = Tile.fromColor(color, 1, 1, alpha);
        tint = new Bitmap(tintTile);

        // Set tint size to match the scene
        tint.width = scene.width;
        tint.height = scene.height;


        if (scene != null) {
            events.onShow((_) -> {
                // Add tint to the scene (behind the box)
                scene.addChild(tint);
                scene.over(box);
                // Center the box in the scene
                box.x = Std.int((scene.width - box.width) / 2);
                box.y = Std.int((scene.height - box.height) / 2);

                // Handle window resize events
                /*var win = Window.getInstance();
                win.addResizeEvent(function() {
                    // Update tint size to match new scene dimensions
                    tint.width = scene.width;
                    tint.height = scene.height;

                    // Recenter the box
                    box.x = (scene.width - box.width) / 2;
                    box.y = (scene.height - box.height) / 2;
                });*/
            });

            events.onHide((_) -> {
                // Remove tint from the scene
                scene.removeChild(tint);

                // Remove the box from the scene
                //scene.removeChild(box);
            });

            
        }
    }
}