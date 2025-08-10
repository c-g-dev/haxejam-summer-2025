package effects;

import h2d.filter.Shader;
import h2d.RenderContext;

class DreamyShader extends h3d.shader.ScreenShader {
    static var SRC = {
        @param var inverseScreenSize : Vec2;
        @param var texture0          : Sampler2D;
        @param var time              : Float;
        @param var intensity         : Float;          @param var aberration        : Float;          @param var vignette          : Float;          @param var grain             : Float;          @param var blur              : Float;  
        function luma(c:Vec3):Float {
            return dot(c, vec3(0.299, 0.587, 0.114));
        }

                function noise(p:Vec2):Float {
            var n = sin(dot(p, vec2(12.9898, 78.233)) + time * 0.75) * 43758.5453;
            return fract(n);
        }

        function fragment() {
            var uv = input.uv;

                        var wobble = sin(time * 0.4 + uv.y * 6.28318) * 0.25 + sin(time * 0.6 + uv.x * 8.0) * 0.25;
            var warp  = wobble * 0.15 * inverseScreenSize.y;             uv += vec2(0.0, warp);

            var center = vec2(0.5, 0.5);
            var dir    = uv - center;
            var d      = length(dir);
            var ndir   = d > 0.0001 ? dir / d : vec2(0.0, 0.0);

                        var abPixels = aberration * (d * d + 0.05);
            var ab = ndir * abPixels * inverseScreenSize;

            var cR = texture0.get(uv + ab).rgb;
            var cG = texture0.get(uv).rgb;
            var cB = texture0.get(uv - ab).rgb;
            var col = vec3(cR.r, cG.g, cB.b);

                        var rPx = blur * (0.75 + d * 1.25);
            var off = inverseScreenSize * rPx;
            var b1 = texture0.get(uv + vec2( off.x,  0.0)).rgb;
            var b2 = texture0.get(uv + vec2(-off.x,  0.0)).rgb;
            var b3 = texture0.get(uv + vec2( 0.0 ,  off.y)).rgb;
            var b4 = texture0.get(uv + vec2( 0.0 , -off.y)).rgb;
            var blurCol = (b1 + b2 + b3 + b4) * 0.25;

            var lum = luma(col);
            var glowAmt = clamp((lum - 0.55) * 2.2, 0.0, 1.0) * intensity;
            col = mix(col, max(col, blurCol), glowAmt);

                        var cool = vec3(0.85, 1.00, 1.05);
            var warm = vec3(1.05, 0.90, 1.10);
            col = mix(col * warm, col * cool, clamp(lum * 1.2, 0.0, 1.0) * 0.15 * intensity);

                        var g = (noise(uv * vec2(641.512, 913.742)) - 0.5);
            col += g * (grain * 0.04);

                        var vig = 1.0 - smoothstep(0.55, 0.98, d);
            col *= (1.0 - vignette * (1.0 - vig));

                        col = clamp(col, vec3(0.0), vec3(1.0));
            output.color = vec4(col, 1.0);
        }
    };
}

class DreamyFilter extends Shader<DreamyShader> {
    public var intensity:Float = 0.6;         public var aberration:Float = 1.25;       public var vignette:Float = 0.35;         public var grain:Float = 0.6;             public var blur:Float = 1.35;         
    var _time:Float = 0.0;

    public function new() {
        super(new DreamyShader(), "texture0");
    }

    override function draw(ctx:RenderContext, t:h2d.Tile) {
        _time += hxd.Timer.dt;
        shader.inverseScreenSize.set(1.0 / t.width, 1.0 / t.height);
        shader.time = _time;
        shader.intensity = intensity;
        shader.aberration = aberration;
        shader.vignette = vignette;
        shader.grain = grain;
        shader.blur = blur;
        return super.draw(ctx, t);
    }
} 