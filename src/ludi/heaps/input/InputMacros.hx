package ludi.heaps.input;

import haxe.macro.Expr;
import haxe.macro.Expr.ComplexType;
import ludi.heaps.input.Input.InputNode;

class InputMacros {
    
    public static macro function of(callingExpr: ExprOf<InputNode>, t: haxe.macro.Expr): haxe.macro.Expr  {
        var typepath = MacroTools.getTypePath(t);
        var ct = MacroTools.getComplexType(t);
        var tpe = MacroTools.getTypePathExpr(typepath);
        var getExpr  = macro @:privateAccess $callingExpr._get($tpe);
        var ce = MacroTools.castExpr(getExpr, ct);
        return ce; 
    }

}

class MacroTools {
    public static function getTypePath(e:Expr):String
    {
        function loop(e:Expr):String
        {
            #if macro
            return switch (e.expr)
            {
                case EConst(CIdent(s)): s;
                case EField(sub, field): loop(sub) + "." + field;
                default: Context.error("Expected a type path here", e.pos);
            }
            #end
            return null;
        }
        return loop(e);
    }

    public static function getComplexType(e:Expr):ComplexType {
        return haxe.macro.TypeTools.toComplexType(Context.getType(getTypePath(typePath)));
    }

    public static function getTypePathExpr(typepath:String):Expr {
        return macro $v{typePath};
    }

    public static function castExpr(e: Expr, ct:ComplexType):Expr {
        var typedExpr:Expr = {
            expr : ECheckType(e, ct),
            pos  : Context.currentPos()
        };
        return typedExpr;
    }
    
}