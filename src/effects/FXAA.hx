package effects;

import h2d.filter.Shader;
import h2d.RenderContext;


class FXAAShader extends h3d.shader.ScreenShader {
        
    static var SRC = {
    
        @param var inverseScreenSize : Vec2;
        @param var texture0          : Sampler2D;
    
        /*  user controllable 0–1 parameters (supplied by the wrapper)  */
        @param var spanMul      : Float;           @param var reduceMinInv : Float;           @param var blendStrength: Float;       
        function luma(c:Vec3):Float {
            return dot(c, vec3(0.299, 0.587, 0.114));
        }
    
        function fragment() {
            var uv       = input.uv;
            var rcpFrame = inverseScreenSize;
    
            /*              3×3 neighbourhood                               */
            var rgbNW = texture0.get(uv + vec2(-1, -1)*rcpFrame).rgb;
            var rgbNE = texture0.get(uv + vec2( 1, -1)*rcpFrame).rgb;
            var rgbSW = texture0.get(uv + vec2(-1,  1)*rcpFrame).rgb;
            var rgbSE = texture0.get(uv + vec2( 1,  1)*rcpFrame).rgb;
            var rgbM  = texture0.get(uv).rgb;
    
            var lumaNW = luma(rgbNW);
            var lumaNE = luma(rgbNE);
            var lumaSW = luma(rgbSW);
            var lumaSE = luma(rgbSE);
            var lumaM  = luma(rgbM);
    
            var lumaMin = min(lumaM, min(min(lumaNW, lumaNE), min(lumaSW, lumaSE)));
            var lumaMax = max(lumaM, max(max(lumaNW, lumaNE), max(lumaSW, lumaSE)));
    
            /*              edge direction                                   */
            var dir:Vec2;
            dir.x = -((lumaNW + lumaNE) - (lumaSW + lumaSE));
            dir.y =  ((lumaNW + lumaSW) - (lumaNE + lumaSE));
    
            /*              reduce step size                                 */
            var dirReduce = max((lumaNW + lumaNE + lumaSW + lumaSE) * 0.25 * 0.5,
                                1.0 / reduceMinInv);
            var rcpDirMin = 1.0 / (min(abs(dir.x), abs(dir.y)) + dirReduce);
    
            dir = clamp(dir * rcpDirMin * spanMul, vec2(-8.0,-8.0), vec2(8.0,8.0))
                  * rcpFrame;
    
            /*              samples along edge                               */
            var rgbA = texture0.get(uv + dir * ( 1.0/3.0 - 0.5)).rgb;
            var rgbB = texture0.get(uv + dir * ( 2.0/3.0 - 0.5)).rgb;
            var rgbC = texture0.get(uv + dir * ( 0.0/3.0 - 0.5)).rgb;
            var rgbD = texture0.get(uv + dir * ( 3.0/3.0 - 0.5)).rgb;
    
            var rgbAvg  = (rgbA + rgbB + rgbC + rgbD) * 0.25;
            var lumaAvg = luma(rgbAvg);
    
            /*              final colour                                     */
            var result : Vec3;
            if ( (lumaAvg <= lumaMin) || (lumaAvg >= lumaMax) )
                result = rgbM;                          else
                result = mix(rgbM, rgbAvg, blendStrength);
    
            output.color = vec4(result, 1.0);
        }
    };
    }


/**

h2d filter wrapper around FXAAShader so you can do:
scene.addFilter( new fx.FXAAFilter() );
*/
class FXAAFilter extends Shader<FXAAShader> {
    public var spanMul      : Float   = 1.0 / 8.0;      public var reduceMinInv : Float   = 128.0;     public var blendStrength: Float   = 1.0;     
    public function new() {
        super(new FXAAShader(), "texture0");
    }
    
    override function draw(ctx:RenderContext, t:h2d.Tile) {
        shader.inverseScreenSize.set(1.0 / t.width, 1.0 / t.height);
        shader.spanMul       = spanMul;
        shader.reduceMinInv  = reduceMinInv;
        shader.blendStrength = blendStrength;
        return super.draw(ctx, t);
    }
    }