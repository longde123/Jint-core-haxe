package jint.native.number.dtoa;
using StringTools;
import system.*;
import anonymoustypes.*;

class DoubleHelper
{
    private static inline var KExponentMask:Float = 0x7FF0000000000000L;
    private static inline var KSignificandMask:Float = 0x000FFFFFFFFFFFFFL;
    private static inline var KHiddenBit:Float = 0x0010000000000000L;
    private static function AsDiyFp(d64:Float):jint.native.number.dtoa.DiyFp
    {
        system.diagnostics.Debug.Assert(!IsSpecial(d64));
        return new jint.native.number.dtoa.DiyFp(Significand(d64), Exponent(d64));
    }
    public static function AsNormalizedDiyFp(d64:Float):jint.native.number.dtoa.DiyFp
    {
        var f:Float = Significand(d64);
        var e:Int = Exponent(d64);
        system.diagnostics.Debug.Assert(f != 0);
        while ((f & KHiddenBit) == 0)
        {
            f <<= 1;
            e--;
        }
        f <<= jint.native.number.dtoa.DiyFp.KSignificandSize - KSignificandSize - 1;
        e -= jint.native.number.dtoa.DiyFp.KSignificandSize - KSignificandSize - 1;
        return new jint.native.number.dtoa.DiyFp(f, e);
    }
    private static function Exponent(d64:Float):Int
    {
        if (IsDenormal(d64))
        {
            return KDenormalExponent;
        }
        var biasedE:Int = Std.int(jint.native.number.dtoa.NumberExtensions.UnsignedShift((d64 & KExponentMask), KSignificandSize) & 0xffffffffL);
        return biasedE - KExponentBias;
    }
    private static function Significand(d64:Float):Float
    {
        var significand:Float = d64 & KSignificandMask;
        if (!IsDenormal(d64))
        {
            return significand + KHiddenBit;
        }
        else
        {
            return significand;
        }
    }
    private static function IsDenormal(d64:Float):Bool
    {
        return (d64 & KExponentMask) == 0L;
    }
    private static function IsSpecial(d64:Float):Bool
    {
        return (d64 & KExponentMask) == KExponentMask;
    }
    public static function NormalizedBoundaries(d64:Float, mMinus:jint.native.number.dtoa.DiyFp, mPlus:jint.native.number.dtoa.DiyFp):Void
    {
        var v:jint.native.number.dtoa.DiyFp = AsDiyFp(d64);
        var significandIsZero:Bool = (v.F == KHiddenBit);
        mPlus.F = (v.F << 1) + 1;
        mPlus.E = v.E - 1;
        mPlus.Normalize();
        if (significandIsZero && v.E != KDenormalExponent)
        {
            mMinus.F = (v.F << 2) - 1;
            mMinus.E = v.E - 2;
        }
        else
        {
            mMinus.F = (v.F << 1) - 1;
            mMinus.E = v.E - 1;
        }
        mMinus.F = mMinus.F << (mMinus.E - mPlus.E);
        mMinus.E = mPlus.E;
    }
    private static inline var KSignificandSize:Int = 52;
    private static inline var KExponentBias:Int = 0x3FF + KSignificandSize;
    private static inline var KDenormalExponent:Int = -KExponentBias + 1;
    public function new()
    {
    }
}
