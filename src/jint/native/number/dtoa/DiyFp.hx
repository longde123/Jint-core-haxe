package jint.native.number.dtoa;
using StringTools;
import system.*;
import anonymoustypes.*;

class DiyFp
{
    public static inline var KSignificandSize:Int = 64;
    private static inline var KUint64MSB:Float = 0x8000000000000000L;
    public function new(f:Float, e:Int)
    {
        F = f;
        E = e;
    }
    public var F:Float;
    public var E:Int;
    private static function Uint64Gte(a:Float, b:Float):Bool
    {
        return (a == b) || ((a > b) ^ (a < 0) ^ (b < 0));
    }
    private function Subtract(other:jint.native.number.dtoa.DiyFp):Void
    {
        system.diagnostics.Debug.Assert(E == other.E);
        system.diagnostics.Debug.Assert(Uint64Gte(F, other.F));
        F -= other.F;
    }
    public static function Minus(a:jint.native.number.dtoa.DiyFp, b:jint.native.number.dtoa.DiyFp):jint.native.number.dtoa.DiyFp
    {
        var result:jint.native.number.dtoa.DiyFp = new jint.native.number.dtoa.DiyFp(a.F, a.E);
        result.Subtract(b);
        return result;
    }
    private function Multiply(other:jint.native.number.dtoa.DiyFp):Void
    {
        var kM32:Float = 0xFFFFFFFFL;
        var a:Float = jint.native.number.dtoa.NumberExtensions.UnsignedShift(F, 32);
        var b:Float = F & kM32;
        var c:Float = jint.native.number.dtoa.NumberExtensions.UnsignedShift(other.F, 32);
        var d:Float = other.F & kM32;
        var ac:Float = a * c;
        var bc:Float = b * c;
        var ad:Float = a * d;
        var bd:Float = b * d;
        var tmp:Float = jint.native.number.dtoa.NumberExtensions.UnsignedShift(bd, 32) + (ad & kM32) + (bc & kM32);
        tmp += 1L << 31;
        var resultF:Float = ac + jint.native.number.dtoa.NumberExtensions.UnsignedShift(ad, 32) + jint.native.number.dtoa.NumberExtensions.UnsignedShift(bc, 32) + jint.native.number.dtoa.NumberExtensions.UnsignedShift(tmp, 32);
        E += other.E + 64;
        F = resultF;
    }
    public static function Times(a:jint.native.number.dtoa.DiyFp, b:jint.native.number.dtoa.DiyFp):jint.native.number.dtoa.DiyFp
    {
        var result:jint.native.number.dtoa.DiyFp = new jint.native.number.dtoa.DiyFp(a.F, a.E);
        result.Multiply(b);
        return result;
    }
    public function Normalize():Void
    {
        var f:Float = F;
        var e:Int = E;
        var k10MsBits:Float = 0xFFC00000L << 32;
        while ((f & k10MsBits) == 0)
        {
            f <<= 10;
            e -= 10;
        }
        while ((f & KUint64MSB) == 0)
        {
            f <<= 1;
            e--;
        }
        F = f;
        E = e;
    }
    public function toString():String
    {
        return "[DiyFp f:" + F + ", e:" + E + "]";
    }
}
