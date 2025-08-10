import hxd.App;
import hxd.Window;
import h2d.Camera;
import h2d.Graphics;
import h2d.filter.Glow;
import h2d.Bitmap;
import h2d.Tile;
import hxd.res.DefaultFont;
import hxd.Math;
import hxd.Timer;
import h3d.Vector4;

class TestMain extends App {

var camLeft   : Camera;
var camRight  : Camera;
var camHUD    : Camera;      
var ballLeft  : Bitmap;
var ballRight : Bitmap;

var g : Graphics;

static inline var LINE_COLOR   = 0x66CCFF;
static inline var LINE_THICK   = 2;
static inline var GLOW_RADIUS  = 12;
static inline var SEGMENTS     = 24;
static inline var MAX_X_JITTER = 8;
static inline var SPEED        = 5;

override function init() {
    hxd.Res.initEmbed();
    

				camLeft  = new Camera();
	camRight = new Camera();
	camHUD   = new Camera();          
    s2d.addCamera(camLeft);
    s2d.addCamera(camRight);
    s2d.addCamera(camHUD);

	updateViewports();                
				var tile = hxd.Res.guy.guy.toTile();
	ballLeft  = new Bitmap(tile, s2d);
	ballLeft.color = new Vector4(1, 0, 0, 1);
	ballLeft.setPosition(  0,  
0);
    ballLeft.alpha = 0;
	ballRight = new Bitmap(tile, s2d);
	ballRight.color = new Vector4(0, 1, 0, 1);
		ballRight.setPosition(200, 0);
    ballRight.alpha = 0;

				g = new Graphics(s2d);
	g.filter = new Glow(GLOW_RADIUS, LINE_COLOR, 1);
}

function updateViewports() {
	var w = Window.getInstance().width;
	var h = Window.getInstance().height;

	camLeft .setViewport(0,     0, w>>1, h);
	camRight.setViewport(w>>1,  0, w>>1, h);
	camHUD  .setViewport(0,     0, w,    h);   }

override function onResize() {
	super.onResize();
	updateViewports();
}

override function update(dt:Float) {
	var t = Timer.dt;

	ballLeft .x = Math.cos(t)*40;
	ballLeft .y = Math.sin(t)*40 + 60;

	ballRight.x = 200 + Math.cos(t*1.3)*50;
	ballRight.y = Math.abs(Math.sin(t*0.8))*80 + 60;

	drawLightningDiagonal(Window.getInstance().width,
	                      Window.getInstance().height,
	                      t);
}


function drawLightningDiagonal(w:Int, h:Int, time:Float) {
	g.clear();
	g.lineStyle(LINE_THICK, LINE_COLOR);

		var len      = Math.sqrt(w*w + h*h);
	var perpX    = -h / len;          	var perpY    =  w / len;

	g.moveTo(0, 0);

	for (i in 1...SEGMENTS) {
		var t      = i / (SEGMENTS-1);    		var baseX  = t * w;
		var baseY  = t * h;

		var jitter = (Math.sin(time * SPEED + i*1.3) +
		              (Math.random()*2 - 1)) * MAX_X_JITTER;

		var x = baseX + perpX * jitter;
		var y = baseY + perpY * jitter;

		g.lineTo(x, y);
	}
}

public static function main() {
	new TestMain();

}
}