package ludi.heaps.util;

import h2d.Tile;
import hxd.res.Gradients;
import hxd.fmt.grd.Data.Color;


abstract Gradient(hxd.Pixels) {
    function new(pixels:hxd.Pixels) {
        this = pixels;
    }

    public static function create(stops: Array<{location: Float, color: Color, opacity: Float}>, resolution: Int = 256): Gradient {
        if (!hxd.Math.isPOT(resolution)) throw "gradient resolution should be a power of two";

		var ghei = 1;
		var thei = hxd.Math.nextPOT(ghei);

		function uploadPixels() {
			var pixels = hxd.Pixels.alloc(resolution, thei, ARGB);
			var yoff   = 0;
            var grad = createGradientObject(stops, resolution);
			//for (g in stops) {
				@:privateAccess Gradients.appendPixels(pixels, grad, resolution, ghei, yoff);
				yoff += ghei;
			//}
			//tex.uploadPixels(pixels);
			//pixels.dispose();
            return pixels;
		}
        var p = uploadPixels();
        trace("p.width: " + p.width);
        trace("p.height: " + p.height);
		return new Gradient(p);
    }

    static function createGradientObject(stops: Array<{location: Float, color: Color, opacity: Float}>, resolution: Int = 256): hxd.fmt.grd.Data.Gradient {

        trace("stops: " + stops);
        // Create a new Gradient object
        var gradient = new hxd.fmt.grd.Data.Gradient();
        gradient.interpolation = 100; // Locations are interpreted as percentages
        gradient.gradientStops = [];
    
        // Populate gradient stops
        for (stop in stops) {
            // Create a ColorStop for the color and location
            var colorStop = new hxd.fmt.grd.Data.ColorStop();
            colorStop.color = stop.color; // Color as RGB or HSB
            colorStop.location = Std.int(stop.location * 100); // Convert 0-1 to 0-100
            colorStop.midpoint = 50; // Default, not used in rendering
            colorStop.type = User; // Default type, not used in rendering
    
            // Create a GradientStop combining color and opacity
            var gradientStop = new hxd.fmt.grd.Data.GradientStop();
            gradientStop.colorStop = colorStop;
            gradientStop.opacity = stop.opacity * 100; // Convert 0-1 to 0-100
    
            // Add to the gradient
            gradient.gradientStops.push(gradientStop);
        }
    
        // Generate and return the texture
        return gradient;
    }

    public function toTile(): h2d.Tile {
        return Tile.fromPixels(this);
    }

    public function rotate90Clockwise(): Gradient {
        return new Gradient(_rotatePixels(this));
    }

    private static function _rotatePixels(original: hxd.Pixels): hxd.Pixels {
        // Get original dimensions
        trace("original.width: " + original.width);
        trace("original.height: " + original.height);
        var originalWidth = original.width;
        var originalHeight = original.height;
        
        // Create new hxd.Pixels with swapped dimensions
        var rotated = hxd.Pixels.alloc(originalHeight, originalWidth, original.format);
        
        // Fill the new image with rotated pixel data
        for (newY in 0...originalWidth) {
            for (newX in 0...originalHeight) {
                var originalX = newY;
                var originalY = originalHeight - 1 - newX;
                var color = original.getPixel(originalX, originalY);
                rotated.setPixel(newX, newY, color);
            }
        }
        
        return rotated;
    }
}