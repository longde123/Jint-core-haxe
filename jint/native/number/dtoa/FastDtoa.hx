package jint.native.number.dtoa;
using StringTools;
import system.*;
import anonymoustypes.*;

class FastDtoa
{
    public static inline var KFastDtoaMaximalLength:Int = 17;
    private static inline var MinimalTargetExponent:Int = -60;
    private static inline var MaximalTargetExponent:Int = -32;
    private static function RoundWeed(buffer:jint.native.number.dtoa.FastDtoaBuilder, distanceTooHighW:Float, unsafeInterval:Float, rest:Float, tenKappa:Float, unit:Float):Bool
    {
        var smallDistance:Float = distanceTooHighW - unit;
        var bigDistance:Float = distanceTooHighW + unit;
        while (rest < smallDistance && unsafeInterval - rest >= tenKappa && (rest + tenKappa < smallDistance || smallDistance - rest >= rest + tenKappa - smallDistance))
        {
            buffer.DecreaseLast();
            rest += tenKappa;
        }
        if (rest < bigDistance && unsafeInterval - rest >= tenKappa && (rest + tenKappa < bigDistance || bigDistance - rest > rest + tenKappa - bigDistance))
        {
            return false;
        }
        return (2 * unit <= rest) && (rest <= unsafeInterval - 4 * unit);
    }
    private static inline var KTen4:Int = 10000;
    private static inline var KTen5:Int = 100000;
    private static inline var KTen6:Int = 1000000;
    private static inline var KTen7:Int = 10000000;
    private static inline var KTen8:Int = 100000000;
    private static inline var KTen9:Int = 1000000000;
    private static function BiggestPowerTen(number:Int, numberBits:Int):Float
    {
        return 0;
    }
    private static function DigitGen(low:jint.native.number.dtoa.DiyFp, w:jint.native.number.dtoa.DiyFp, high:jint.native.number.dtoa.DiyFp, buffer:jint.native.number.dtoa.FastDtoaBuilder, mk:Int):Bool
    {
        var unit:Float = 1;
        var tooLow:jint.native.number.dtoa.DiyFp = new jint.native.number.dtoa.DiyFp(low.F - unit, low.E);
        var tooHigh:jint.native.number.dtoa.DiyFp = new jint.native.number.dtoa.DiyFp(high.F + unit, high.E);
        var unsafeInterval:jint.native.number.dtoa.DiyFp = jint.native.number.dtoa.DiyFp.Minus(tooHigh, tooLow);
        var one:jint.native.number.dtoa.DiyFp = new jint.native.number.dtoa.DiyFp(1L << -w.E, w.E);
        var integrals:Int = Std.int(jint.native.number.dtoa.NumberExtensions.UnsignedShift(tooHigh.F, -one.E) & 0xffffffffL);
        var fractionals:Float = tooHigh.F & (one.F - 1);
        var result:Float = BiggestPowerTen(integrals, jint.native.number.dtoa.DiyFp.KSignificandSize - (-one.E));
        var divider:Int = Std.int(jint.native.number.dtoa.NumberExtensions.UnsignedShift(result, 32) & 0xffffffffL);
        var dividerExponent:Int = Std.int(result & 0xffffffffL);
        var kappa:Int = dividerExponent + 1;
        while (kappa > 0)
        {
            var digit:Int = integrals / divider;
            buffer.Append((48 + digit));
            integrals %= divider;
            kappa--;
            var rest:Float = (integrals << -one.E) + fractionals;
            if (rest < unsafeInterval.F)
            {
                buffer.Point = buffer.End - mk + kappa;
                return RoundWeed(buffer, jint.native.number.dtoa.DiyFp.Minus(tooHigh, w).F, unsafeInterval.F, rest, divider << -one.E, unit);
            }
            divider /= 10;
        }
        while (true)
        {
            fractionals *= 5;
            unit *= 5;
            unsafeInterval.F = unsafeInterval.F * 5;
            unsafeInterval.E = unsafeInterval.E + 1;
            one.F = jint.native.number.dtoa.NumberExtensions.UnsignedShift(one.F, 1);
            one.E = one.E + 1;
            var digit:Int = Std.int((jint.native.number.dtoa.NumberExtensions.UnsignedShift(fractionals, -one.E)) & 0xffffffffL);
            buffer.Append((48 + digit));
            fractionals &= one.F - 1;
            kappa--;
            if (fractionals < unsafeInterval.F)
            {
                buffer.Point = buffer.End - mk + kappa;
                return RoundWeed(buffer, jint.native.number.dtoa.DiyFp.Minus(tooHigh, w).F * unit, unsafeInterval.F, fractionals, one.F, unit);
            }
        }
    }
    private static function Grisu3(v:Float, buffer:jint.native.number.dtoa.FastDtoaBuilder):Bool
    {
        var bits:Float = system.BitConverter.DoubleToInt64Bits(v);
        var w:jint.native.number.dtoa.DiyFp = jint.native.number.dtoa.DoubleHelper.AsNormalizedDiyFp(bits);
        var boundaryMinus:jint.native.number.dtoa.DiyFp = new jint.native.number.dtoa.DiyFp(0, 0);
        var boundaryPlus:jint.native.number.dtoa.DiyFp = new jint.native.number.dtoa.DiyFp(0, 0);
        jint.native.number.dtoa.DoubleHelper.NormalizedBoundaries(bits, boundaryMinus, boundaryPlus);
        system.diagnostics.Debug.Assert(boundaryPlus.E == w.E);
        var tenMk:jint.native.number.dtoa.DiyFp = new jint.native.number.dtoa.DiyFp(0, 0);
        var mk:Int = jint.native.number.dtoa.CachedPowers.GetCachedPower(w.E + jint.native.number.dtoa.DiyFp.KSignificandSize, MinimalTargetExponent, MaximalTargetExponent, tenMk);
        system.diagnostics.Debug.Assert(MinimalTargetExponent <= w.E + tenMk.E + jint.native.number.dtoa.DiyFp.KSignificandSize && MaximalTargetExponent >= w.E + tenMk.E + jint.native.number.dtoa.DiyFp.KSignificandSize);
        var scaledW:jint.native.number.dtoa.DiyFp = jint.native.number.dtoa.DiyFp.Times(w, tenMk);
        system.diagnostics.Debug.Assert(scaledW.E == boundaryPlus.E + tenMk.E + jint.native.number.dtoa.DiyFp.KSignificandSize);
        var scaledBoundaryMinus:jint.native.number.dtoa.DiyFp = jint.native.number.dtoa.DiyFp.Times(boundaryMinus, tenMk);
        var scaledBoundaryPlus:jint.native.number.dtoa.DiyFp = jint.native.number.dtoa.DiyFp.Times(boundaryPlus, tenMk);
        return DigitGen(scaledBoundaryMinus, scaledW, scaledBoundaryPlus, buffer, mk);
    }
    public static function Dtoa(v:Float, buffer:jint.native.number.dtoa.FastDtoaBuilder):Bool
    {
        system.diagnostics.Debug.Assert(v > 0);
        system.diagnostics.Debug.Assert(!system.Double.IsNaN(v));
        system.diagnostics.Debug.Assert(!system.Double.IsInfinity(v));
        return Grisu3(v, buffer);
    }
    public static function NumberToString(v:Float):String
    {
        var buffer:jint.native.number.dtoa.FastDtoaBuilder = new jint.native.number.dtoa.FastDtoaBuilder();
        return NumberToString_Double_FastDtoaBuilder(v, buffer) ? buffer.Format() : null;
    }
    public static function NumberToString_Double_FastDtoaBuilder(v:Float, buffer:jint.native.number.dtoa.FastDtoaBuilder):Bool
    {
        buffer.Reset();
        if (v < 0)
        {
            buffer.Append(45);
            v = -v;
        }
        return Dtoa(v, buffer);
    }
    public function new()
    {
    }
}
