package jint.native.number;
using StringTools;
import system.*;
import anonymoustypes.*;

class NumberInstance extends jint.native.object.ObjectInstance implements jint.native.IPrimitiveInstance
{
    private static inline var NegativeZeroBits:Float = ( 0.0);
    public function new(engine:jint.Engine)
    {
        super(engine);
    }
    override public function get_JClass():String
    {
        return "Number";
    }

    public var JType(get , never):Int;
    function get_JType():Int
    {
        return jint.runtime.Types.Number;
    }
 

    public var PrimitiveValue:jint.native.JsValue;
    public static function IsNegativeZero(x:Float):Bool
    {
        return x == 0 ;
    }
    public static function IsPositiveZero(x:Float):Bool
    {
        return x == 0 ;
    }
}
