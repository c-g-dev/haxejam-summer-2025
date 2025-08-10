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
							@:privateAccess Gradients.appendPixels(pixels, grad, resolution, ghei, yoff);
				yoff += ghei;
									            return pixels;
		}
        var p = uploadPixels();
        trace("p.width: " + p.width);
        trace("p.height: " + p.height);
		return new Gradient(p);
    }

    static function createGradientObject(stops: Array<{location: Float, color: Color, opacity: Float}>, resolution: Int = 256): hxd.fmt.grd.Data.Gradient {

        trace("stops: " + stops);
                var gradient = new hxd.fmt.grd.Data.Gradient();
        gradient.interpolation = 100;         gradient.gradientStops = [];
    
                for (stop in stops) {
                        var colorStop = new hxd.fmt.grd.Data.ColorStop();
            colorStop.color = stop.color;             colorStop.location = Std.int(stop.location * 100);             colorStop.midpoint = 50;             colorStop.type = User;     
                        var gradientStop = new hxd.fmt.grd.Data.GradientStop();
            gradientStop.colorStop = colorStop;
            gradientStop.opacity = stop.opacity * 100;     
                        gradient.gradientStops.push(gradientStop);
        }
    
                return gradient;
    }

    public function toTile(): h2d.Tile {
        return Tile.fromPixels(this);
    }

    public function rotate90Clockwise(): Gradient {
        return new Gradient(_rotatePixels(this));
    }

    private static function _rotatePixels(original: hxd.Pixels): hxd.Pixels {
                trace("original.width: " + original.width);
        trace("original.height: " + original.height);
        var originalWidth = original.width;
        var originalHeight = original.height;
        
                var rotated = hxd.Pixels.alloc(originalHeight, originalWidth, original.format);
        
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