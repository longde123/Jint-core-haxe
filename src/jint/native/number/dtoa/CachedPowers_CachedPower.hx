package jint.native.number.dtoa;
using StringTools;
import system.*;
import anonymoustypes.*;

class CachedPowers_CachedPower
{
    public var Significand:Float;
    public var BinaryExponent:Int;
    public var DecimalExponent:Int;
    public function new(significand:Float, binaryExponent:Int, decimalExponent:Int)
    {
        Significand = 0;
        BinaryExponent = 0;
        DecimalExponent = 0;
        Significand = significand;
        BinaryExponent = binaryExponent;
        DecimalExponent = decimalExponent;
    }
}
