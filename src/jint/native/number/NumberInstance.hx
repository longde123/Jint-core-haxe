package jint.native.number;
using StringTools;
import system.*;
import anonymoustypes.*;

class NumberInstance extends jint.native.object.ObjectInstance implements jint.native.IPrimitiveInstance
{
    private static inline var NegativeZeroBits:Float = (-0.0);
    public function new(engine:jint.Engine)
    {
        super(engine);
    }
    override public function get_Class():String
    {
        return "Number";
    }

    var Type(get_Type, never):Int;
    function get_Type():Int
    {
        return jint.runtime.Types.Number;
    }
 

    public var PrimitiveValue:jint.native.JsValue;
    public static function IsNegativeZero(x:Float):Bool
    {
        return x == 0 && system.BitConverter.DoubleToInt64Bits(x) == NegativeZeroBits;
    }
    public static function IsPositiveZero(x:Float):Bool
    {
        return x == 0 && system.BitConverter.DoubleToInt64Bits(x) != NegativeZeroBits;
    }
}
